import 'dart:async';
import 'dart:ui';

import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/page/security_center_page.dart';
import 'package:fils_link/tool/app_session.dart';
import 'package:fils_link/page/asset_page.dart';
import 'package:fils_link/page/home_page.dart';
import 'package:fils_link/page/node_page.dart';
import 'package:fils_link/tool/app_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../page/message_page.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  final PageController _pageController = PageController(initialPage: 0);
  final RxInt _currentIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_consumePasskeyOnboardingIfNeeded());
    });
  }

  final List<Widget> _pages = const [
    HomePage(),
    NodePage(),
    MessagePage(),
    AssetPage(),
  ];

  final List _bar = [
    'bar_1.svg',
    'bar_2.svg',
    'bar_3.svg',
    'bar_4.svg',
  ];

  final List _title = [
    '首页',
    '节点',
    '消息',
    '资产',
  ];

  Future<void> _consumePasskeyOnboardingIfNeeded() async {
    if (!AppSession.pendingPasskeyOnboardingSuggestion) return;
    AppSession.pendingPasskeyOnboardingSuggestion = false;
    final username = await SaveData.getUserInfo();
    if (username == null || !mounted) return;
    if (!await SaveData.shouldPromptPasskeyOnboarding(username)) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('添加通行密钥'),
        content: const Text('可在「设置 → 安全中心」里添加通行密钥，以后免输密码登录。'),
        actions: [
          TextButton(
            onPressed: () async {
              await SaveData.markPasskeyOnboardingPrompted(username);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('我知道了'),
          ),
          FilledButton(
            onPressed: () async {
              await SaveData.markPasskeyOnboardingPrompted(username);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (!mounted) return;
              await Navigator.of(context, rootNavigator: true).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const SecurityCenterPage(),
                ),
              );
            },
            child: const Text('前往安全中心'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 同步一次，确保冷启动/热重载后状态一致
    AppTabs.activeIndex.value = _currentIndex.value;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                  child: Container(
                    width: double.infinity,
                    height: 50 + MediaQuery.of(context).padding.bottom,
                    padding: EdgeInsets.only(
                        top: 5,
                        bottom: MediaQuery.of(context).padding.bottom - 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3), // 透明度
                      border: const Border(
                        top: BorderSide(
                          color: Colors.grey,
                          width: 0.1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _bar.map((e) {
                        return InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            _pageController.animateToPage(
                              _bar.indexOf(e),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            final idx = _bar.indexOf(e);
                            _currentIndex.value = idx;
                            AppTabs.activeIndex.value = idx;
                          },
                          child: Column(
                            children: [
                              SvgPicture.asset('assets/icons/$e',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                    _currentIndex.value == _bar.indexOf(e)
                                        ? const Color(0xff3378F7)
                                        : const Color(0xff959595),
                                    BlendMode.srcIn,
                                  )),
                              const SizedBox(height: 1),
                              Text(
                                _title[_bar.indexOf(e)],
                                style: TextStyle(
                                  color:
                                      _currentIndex.value == _bar.indexOf(e)
                                          ? const Color(0xff3378F7)
                                          : const Color(0xff959595),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
