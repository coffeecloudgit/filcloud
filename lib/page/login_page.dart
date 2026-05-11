import 'dart:async';

import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/service/passkey_service.dart';
import 'package:fils_link/service/push_notification_service.dart';
import 'package:fils_link/tool/app_session.dart';
import 'package:fils_link/tool/home_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../package/data.dart';
import '../package/http_data.dart';
import 'login_slide_captcha_dialog.dart';
import '../start/start.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// 旧图形验证码 ([HttpData.verify]) 用的服务端 uuid 暂存，新滑块流程不再依赖。
String deUuid = '';

enum _LoginStep {
  /// 仅用户名 +「继续」
  enterUsername,

  /// 点击继续后的过渡（加载密码验证区域）
  preparingPassword,

  /// 同一卡片内展开密码 +「登录」
  enterPassword,
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  Future<String?>? _userFuture;

  final RxBool _passkeyBusy = false.obs;
  /// 密码登录从「滑块校验通过」到「跳首页前」一直为 true，期间禁用所有提交入口。
  bool _loggingIn = false;
  _LoginStep _step = _LoginStep.enterUsername;

  @override
  void initState() {
    super.initState();
    _userFuture = SaveData.getUserInfo();
    _userFuture!.then((value) {
      if (value != null && mounted) {
        _usernameController.text = value;
        // 异步回填不会触发 onChanged，需刷新一次才能启用「继续」
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final u = _usernameController.text.trim();
    if (u.isEmpty) {
      Get.snackbar('提示', '请输入用户名');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _step = _LoginStep.preparingPassword);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() => _step = _LoginStep.enterPassword);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (mounted) _passwordFocus.requestFocus();
  }

  void _backToUsername() {
    // 先断开密码框焦点并收起键盘，再在下一帧再重建 UI，避免 iOS 在
    // TextInput 连接已销毁时仍尝试弹出系统上下文菜单而触发断言崩溃。
    _passwordFocus.unfocus();
    _usernameFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _step = _LoginStep.enterUsername;
        _passwordController.clear();
      });
    });
  }

  Future<void> _submitPasswordLogin() async {
    if (_loggingIn) return;
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (password.isEmpty) {
      Get.snackbar('提示', '请输入密码');
      return;
    }

    final captchaKey = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoginSlideCaptchaDialog(),
    );
    if (!mounted || captchaKey == null) return;

    // 滑块已校验通过，下面是真正的登录请求。锁住按钮以免慢网时被误以为没点。
    setState(() => _loggingIn = true);
    try {
      final result = await HttpData.loginUser(
        username,
        password,
        '',
        captchaKey,
        Data.url,
      );
      if (!mounted) return;
      if (!result.ok) {
        Get.snackbar('提示', result.message ?? '登录失败');
        return;
      }
      final suggest =
          await _shouldSuggestPasskeyOnboardingAfterPasswordLogin(username);
      if (!mounted) return;
      AppSession.pendingPasskeyOnboardingSuggestion = suggest;
      _enterHome();
    } finally {
      if (mounted) setState(() => _loggingIn = false);
    }
  }

  void _enterHome() {
    PushNotificationService.loginUser();
    try {
      if (Get.isRegistered<HomeStateController>()) {
        Get.delete<HomeStateController>();
      }
      Get.put(HomeStateController());
    } catch (e) {
      debugPrint('重置 HomeStateController 失败: $e');
    }
    Get.offAll(() => const Start());
  }

  /// 尚无通行密钥且本账号未接受过「前往设置」引导时，在首页首帧后再提示（不重复验证码）。
  Future<bool> _shouldSuggestPasskeyOnboardingAfterPasswordLogin(
      String username) async {
    if (!await SaveData.shouldPromptPasskeyOnboarding(username)) {
      return false;
    }
    return _userHasNoPasskey(username);
  }

  Future<bool> _userHasNoPasskey(String username) async {
    try {
      final begin = await HttpData.passkeyLoginBegin(username);
      if (begin['code'] == 200) return false;
      final msg = begin['msg']?.toString() ?? '';
      return begin['code'] == 400 && msg.contains('未注册');
    } catch (_) {
      return false;
    }
  }

  Future<void> _loginWithPasskey() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      Get.snackbar('提示', '请先输入用户名');
      return;
    }
    _passkeyBusy.value = true;
    try {
      Map<String, dynamic> begin = await HttpData.passkeyLoginBegin(username);

      if (begin['code'] != 200) {
        final msg = begin['msg']?.toString() ?? '';
        final needRegister =
            begin['code'] == 400 && msg.contains('未注册');
        if (needRegister) {
          Get.snackbar(
            '提示',
            '您还没有通行密钥，请先用密码登录，再在设置里添加通行密钥。',
          );
          return;
        }
        Get.snackbar(
          '提示',
          msg.isNotEmpty ? msg : '通行密钥登录开始失败',
        );
        return;
      }

      final publicKey =
          (begin['data'] as Map)['publicKey'] as Map<String, dynamic>;
      final assertion = await PasskeyService.authenticate(
        rpId: (publicKey['rpId'] as String?) ?? 'api.coffeecloud.info',
        requestOptionsPublicKey: publicKey,
      );
      final finish = await HttpData.passkeyLoginFinish(username, assertion);
      if (!finish.ok) {
        Get.snackbar(
          '提示',
          finish.message ?? '通行密钥登录失败',
        );
        return;
      }

      AppSession.pendingPasskeyOnboardingSuggestion = false;
      _enterHome();
    } catch (e) {
      if (e is PlatformException) {
        if (e.code == 'passkey_cancelled' ||
            ((e.message?.contains('AuthorizationError') ?? false) &&
                (e.message?.contains('1001') ?? false))) {
          return;
        }
      }
      Get.snackbar('提示', '通行密钥登录失败: $e');
    } finally {
      _passkeyBusy.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usernameFilled = _usernameController.text.trim().isNotEmpty;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xffF3F1F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/login_2.svg',
                          colorFilter: const ColorFilter.mode(
                            Color(0xff4184EC),
                            BlendMode.srcIn,
                          ),
                          width: 44,
                          height: 44,
                        ),
                        Text(
                          'ilCloud',
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: 26,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '使用账号登录',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffD1D1D6)),
                      ),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        alignment: Alignment.topCenter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                4,
                                14,
                                4,
                              ),
                              child: TextFormField(
                                controller: _usernameController,
                                focusNode: _usernameFocus,
                                style: textTheme.bodyLarge,
                                readOnly: _step == _LoginStep.enterPassword ||
                                    _step == _LoginStep.preparingPassword,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: '用户名',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '请输入用户名';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_step == _LoginStep.preparingPassword)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                                child: SizedBox(
                                  height: 3,
                                  child: LinearProgressIndicator(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            if (_step == _LoginStep.enterPassword) ...[
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey.shade300,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  4,
                                  14,
                                  10,
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  style: textTheme.bodyLarge,
                                  obscureText: true,
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                    labelText: '密码',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_step == _LoginStep.enterUsername) ...[
                      FilledButton(
                        onPressed: usernameFilled
                            ? () => unawaited(_onContinue())
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff0071E3),
                          disabledBackgroundColor:
                              const Color(0xff0071E3).withValues(alpha: 0.35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '继续',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ] else if (_step == _LoginStep.preparingPassword) ...[
                      FilledButton(
                        onPressed: null,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              const Color(0xff0071E3).withValues(alpha: 0.45),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '继续',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: _loggingIn
                                  ? null
                                  : () => unawaited(_submitPasswordLogin()),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xff0071E3),
                                disabledBackgroundColor: const Color(0xff0071E3)
                                    .withValues(alpha: 0.5),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _loggingIn
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      '登录',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(
                              () => FilledButton(
                                onPressed: (_passkeyBusy.value || _loggingIn)
                                    ? null
                                    : () => unawaited(_loginWithPasskey()),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  disabledBackgroundColor:
                                      Colors.black.withValues(alpha: 0.5),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  '通行密钥',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '通行密钥需 iOS 15+ 且已在系统内配置',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: _loggingIn ? null : _backToUsername,
                        child: Text(
                          '返回',
                          style: textTheme.labelLarge,
                        ),
                      ),
                    ],
                    if (_step == _LoginStep.enterUsername) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Obx(
                          () => TextButton(
                            onPressed: _passkeyBusy.value
                                ? null
                                : () => unawaited(_loginWithPasskey()),
                            child: Text(
                              '通行密钥登录',
                              style: textTheme.labelLarge,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '首次请密码登录，之后在设置中添加',
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
