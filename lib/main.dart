import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/page/login_page.dart';
import 'package:fils_link/service/api_service.dart';
import 'package:fils_link/service/push_notification_service.dart';
import 'package:fils_link/start/start.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  // 初始化 Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化推送通知服务
  await PushNotificationService.initialize();

  ApiService.setupDio();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: ApiService.navigatorKey, // 绑定全局 navigatorKey
      title: 'FilCloud',
      builder: (context, child) {
        // 设置字体大小不随系统设置变化
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: FutureBuilder<bool>(
        future: SaveData.checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data ?? false) {
              return const Start(); // 用户已登录，跳转到首页
            } else {
              return const LoginPage(); // 用户未登录，跳转到登录页面
            }
          } else {
            return const CircularProgressIndicator(); // 加载中显示等待圈
          }
        },
      ),
    );
  }
}
