import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../page/login_page.dart';
import '../tool/app_session.dart';

/// `ApiService` 是一个全局的网络请求和监听服务
///
/// 通过 `dio` 实现网络请求
/// 通过 `navigatorKey` 实现全局的 navigator key
/// 通过 `ApiInterceptor` 实现全局的响应拦截
class ApiService {
  static Dio dio = Dio();

  // 全局的 navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void setupDio() {
    dio.interceptors.add(ApiInterceptor());
  }
}

/// `ApiInterceptor` 是一个全局的响应拦截器，确保 token 过期时能够正确处理
class ApiInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data != null && response.data['code'] == 401) {
      // 使用全局 navigatorKey 来获取 context
      final BuildContext? context = ApiService.navigatorKey.currentContext;

      // 清理会话并停止所有定时刷新
      AppSession.logoutAndReset();

      // 退出登录
      Get.offAll(() => const LoginPage());

      if (context != null) {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '通知',
          barrierColor: Colors.black.withOpacity(0.2),
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation1, animation2) {
            return Center(
              child: Material(
                type: MaterialType.transparency,
                child: ListView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        MediaQuery.of(context).size.height / 4 -
                        20,
                    left: 50,
                    right: 50,
                  ),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: Container(
                          height: 170,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: Center(
                                    child: Text(
                                      '登录已过期，请重新登录',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.back(); // 取消
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    top: BorderSide(
                                        color: Color(0xffCCCCCC), width: 0.5),
                                  )),
                                  child: const Center(
                                    child: Text(
                                      '确认',
                                      style: TextStyle(
                                        color: Color(0xff005FEB),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }
    }
    super.onResponse(response, handler);
  }
}
