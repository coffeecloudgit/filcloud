import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../package/save_data.dart';

class AuthService {
  static const platform = MethodChannel('com.file.monitor/user_token');

  // 登录用户，启动推送通知
  static Future<void> loginUser() async {
    // 获取token
    String? userToken = await SaveData.getLoginData();

    // 将用户 token 传递给 iOS 原生代码
    await platform.invokeMethod('setUserToken', {"token": userToken});

    // 重新启用推送通知
    await platform.invokeMethod('enablePushNotifications');
  }

  // 注销用户，禁用推送通知
  static Future<void> logoutUser() async {
    // 获取当前用户的 token
    String? userToken = await SaveData.getLoginData();
    if (userToken != null) {
      // 通知服务器移除该用户的设备令牌
      await removeTokenFromServer(userToken);
    }

    // 调用 Flutter 桥接方法通知 iOS 禁用推送通知
    await platform.invokeMethod('disablePushNotifications');
  }

  // 从服务器移除用户设备令牌
  static Future<void> removeTokenFromServer(String userToken) async {
    final response = await http.post(
      Uri.parse('http://116.92.243.5:8000/api/v1/user/device_token'),
      headers: <String, String>{
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode(<String, String>{
        'status': '2',
      }),
    );
  }
}
