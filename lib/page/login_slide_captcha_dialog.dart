import 'dart:async';

import 'package:fils_link/service/slide_captcha_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 滑块验证码弹窗（与后端 `/api/v1/slide-captcha` 配套）。
///
/// 校验通过时 `Navigator.pop<String>(context, captchaKey)`，取消为 `null`。
class LoginSlideCaptchaDialog extends StatefulWidget {
  const LoginSlideCaptchaDialog({super.key});

  @override
  State<LoginSlideCaptchaDialog> createState() =>
      _LoginSlideCaptchaDialogState();
}

/// 校验状态机：
/// - `idle`     等待用户拖动
/// - `verifying` 已经 POST，等待后端结果（盖一层菊花）
/// - `success`  后端返回通过，显示 ✓ + 「验证通过」绿色反馈
/// - `failed`   后端返回失败，显示 ✕ + 「验证失败」红色反馈
enum _VerifyState { idle, verifying, success, failed }

class _LoginSlideCaptchaDialogState extends State<LoginSlideCaptchaDialog> {
  static const double _panelMaxWidth = 320;

  /// 成功 / 失败反馈在用户面前停留的时长。线上常见 ~600~800ms。
  static const Duration _successHold = Duration(milliseconds: 700);
  static const Duration _failedHold = Duration(milliseconds: 600);

  bool _loading = true;
  String? _error;
  SlideCaptchaChallenge? _challenge;

  /// 拼图块左上角在**原生像素**下的 X。这是 widget 内部唯一的"位置真相"。
  int _tileNativeX = 0;
  _VerifyState _verifyState = _VerifyState.idle;

  bool get _busy =>
      _verifyState == _VerifyState.verifying ||
      _verifyState == _VerifyState.success;

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
      _verifyState = _VerifyState.idle;
    });
    try {
      final data = await SlideCaptchaService.load();
      if (!mounted) return;
      setState(() {
        _challenge = data;
        _tileNativeX = data.initialTileX;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _verify() async {
    final c = _challenge;
    if (c == null) return;
    if (_verifyState == _VerifyState.verifying ||
        _verifyState == _VerifyState.success) {
      return;
    }
    setState(() => _verifyState = _VerifyState.verifying);
    try {
      final ok = await SlideCaptchaService.verify(
        key: c.key,
        nativeX: _tileNativeX,
        nativeY: c.tileY,
      );
      if (!mounted) return;
      if (ok) {
        setState(() => _verifyState = _VerifyState.success);
        // 让用户看到"验证通过"再退出，符合线上常见拼图体验。
        await Future<void>.delayed(_successHold);
        if (!mounted) return;
        Navigator.of(context).pop<String>(c.key);
        return;
      }
      setState(() => _verifyState = _VerifyState.failed);
      await Future<void>.delayed(_failedHold);
      if (!mounted) return;
      await _reload();
    } catch (e) {
      if (!mounted) return;
      setState(() => _verifyState = _VerifyState.failed);
      Get.snackbar('提示', '网络错误：$e');
      await Future<void>.delayed(_failedHold);
      if (!mounted) return;
      setState(() => _verifyState = _VerifyState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _panelMaxWidth + 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 4),
              Text(
                '拖动下方滑块或拼图块对齐缺口后，点「确认验证」',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '安全验证',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: _busy ? null : () => Navigator.of(context).pop<String>(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final error = _error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => unawaited(_reload()),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    return _SlidePuzzleBoard(
      challenge: _challenge!,
      tileNativeX: _tileNativeX,
      verifyState: _verifyState,
      onTileNativeXChanged: (v) => setState(() => _tileNativeX = v),
      onDragSettled: () => unawaited(_verify()),
      onRefresh: () => unawaited(_reload()),
      onVerify: () => unawaited(_verify()),
    );
  }
}

/// 拼图 + 底部轨道。所有几何计算都由当前帧的 `scale` 推导，
/// 不再跨帧同步，避免之前"双 scale"导致校验对不上的问题。
class _SlidePuzzleBoard extends StatelessWidget {
  const _SlidePuzzleBoard({
    required this.challenge,
    required this.tileNativeX,
    required this.verifyState,
    required this.onTileNativeXChanged,
    required this.onDragSettled,
    required this.onRefresh,
    required this.onVerify,
  });

  final SlideCaptchaChallenge challenge;
  final int tileNativeX;
  final _VerifyState verifyState;
  final ValueChanged<int> onTileNativeXChanged;
  /// 拖动 / 滑条停止抬手时回调，用于自动提交一次校验。
  final VoidCallback onDragSettled;
  final VoidCallback onRefresh;
  final VoidCallback onVerify;

  bool get _locked =>
      verifyState != _VerifyState.idle && verifyState != _VerifyState.failed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _LoginSlideCaptchaDialogState._panelMaxWidth;
        final panelW = maxW.clamp(240.0, _LoginSlideCaptchaDialogState._panelMaxWidth);
        final scale = panelW / challenge.masterW;
        final panelH = challenge.masterH * scale;
        final tileDisplayW = challenge.tileW * scale;
        final tileDisplayH = challenge.tileH * scale;
        final tileTop = challenge.tileY * scale;
        final maxNativeX = challenge.maxTileX;
        final sliderEnabled = verifyState == _VerifyState.idle && maxNativeX > 0;

        double nativeToDisplay(int nx) => nx * scale;

        void changeByDisplayDelta(double dx) {
          if (scale == 0) return;
          final nextNative = (tileNativeX + dx / scale).round().clamp(0, maxNativeX);
          if (nextNative != tileNativeX) onTileNativeXChanged(nextNative);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: panelW,
                height: panelH,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: Image.memory(
                        challenge.masterBytes,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                    ),
                    Positioned(
                      left: nativeToDisplay(tileNativeX),
                      top: tileTop,
                      width: tileDisplayW,
                      height: tileDisplayH,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragUpdate: sliderEnabled
                            ? (d) => changeByDisplayDelta(d.delta.dx)
                            : null,
                        onHorizontalDragEnd:
                            sliderEnabled ? (_) => onDragSettled() : null,
                        child: Image.memory(
                          challenge.tileBytes,
                          fit: BoxFit.fill,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                    _VerifyFeedbackOverlay(state: verifyState),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SliderTrack(
              valueNative: tileNativeX,
              maxNative: maxNativeX,
              enabled: sliderEnabled,
              accent: _accentFor(verifyState),
              onChangedNative: onTileNativeXChanged,
              onChangeEndNative: (_) => onDragSettled(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: '刷新',
                  onPressed: _locked ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _locked ? null : onVerify,
                  child: verifyState == _VerifyState.verifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('确认验证'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Color? _accentFor(_VerifyState s) {
    switch (s) {
      case _VerifyState.success:
        return const Color(0xff2BB673);
      case _VerifyState.failed:
        return const Color(0xffE0463A);
      case _VerifyState.idle:
      case _VerifyState.verifying:
        return null;
    }
  }
}

/// 拼图区域之上的"校验中 / 通过 / 失败"反馈层。空闲态完全透明，不影响交互。
class _VerifyFeedbackOverlay extends StatelessWidget {
  const _VerifyFeedbackOverlay({required this.state});

  final _VerifyState state;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: state == _VerifyState.idle,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (state) {
      case _VerifyState.idle:
        return const SizedBox.expand(key: ValueKey('idle'));
      case _VerifyState.verifying:
        return Container(
          key: const ValueKey('verifying'),
          color: const Color(0x33000000),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
        );
      case _VerifyState.success:
        return const _FeedbackBanner(
          key: ValueKey('success'),
          color: Color(0xCC2BB673),
          icon: Icons.check_circle,
          text: '验证通过',
        );
      case _VerifyState.failed:
        return const _FeedbackBanner(
          key: ValueKey('failed'),
          color: Color(0xCCE0463A),
          icon: Icons.cancel,
          text: '验证失败',
        );
    }
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
  });

  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 44),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTrack extends StatelessWidget {
  const _SliderTrack({
    required this.valueNative,
    required this.maxNative,
    required this.enabled,
    required this.accent,
    required this.onChangedNative,
    required this.onChangeEndNative,
  });

  final int valueNative;
  final int maxNative;
  final bool enabled;
  /// 非 null 时把轨道、滑块染成该色，用于成功 / 失败的视觉提示。
  final Color? accent;
  final ValueChanged<int> onChangedNative;
  final ValueChanged<int> onChangeEndNative;

  @override
  Widget build(BuildContext context) {
    final fraction = maxNative > 0 ? (valueNative / maxNative).clamp(0.0, 1.0) : 0.0;
    final themeBase = SliderTheme.of(context).copyWith(
      trackHeight: 6,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
    );
    final tinted = accent == null
        ? themeBase
        : themeBase.copyWith(
            activeTrackColor: accent,
            inactiveTrackColor: accent!.withValues(alpha: 0.25),
            thumbColor: accent,
            disabledActiveTrackColor: accent,
            disabledInactiveTrackColor: accent!.withValues(alpha: 0.25),
            disabledThumbColor: accent,
          );
    return Row(
      children: [
        Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.grey.shade600),
        Expanded(
          child: SliderTheme(
            data: tinted,
            child: Slider(
              value: fraction.toDouble(),
              onChanged: enabled
                  ? (v) => onChangedNative((v * maxNative).round())
                  : null,
              onChangeEnd: enabled
                  ? (v) => onChangeEndNative((v * maxNative).round())
                  : null,
            ),
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade600),
      ],
    );
  }
}
