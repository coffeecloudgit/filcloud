import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../package/save_data.dart';

class PushNotificationService {
  static const MethodChannel _channel =
      MethodChannel('com.fil.links/user_token');
  static const String _deviceTokenKey = 'device_token';

  // 初始化监听器，实时更新设备令牌
  static Future<void> initialize() async {
    // 检查是否有保存的设备令牌，并加载到内存
    final String? savedToken = await getDeviceToken();

    if (savedToken != null) {
      print("Loaded saved device token: $savedToken");
      // 令牌已经保存，可以随时使用
    }

    // 监听来自 iOS 端的设备令牌更新
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "updateDeviceToken") {
        String? deviceToken = call.arguments as String?;
        if (deviceToken != null) {
          // 实时保存新令牌
          await saveDeviceToken(deviceToken);
          print("Received new device token: $deviceToken");

          // 此时令牌已保存，无论登录状态如何，随时可以使用

          // 检查登录状态
          if (await SaveData.checkLoginStatus()) {
            // 用户已登录，通知后端开始推送
            await loginUser();
          }
        }
      }
    });
  }

  // 保存设备令牌到 SharedPreferences
  static Future<void> saveDeviceToken(String deviceToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceTokenKey, deviceToken);
  }

  // 获取已保存的设备令牌
  static Future<String?> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceTokenKey);
  }

  // 登录成功后调用此方法，通知后端开始推送
  static Future<void> loginUser() async {
    // 获取已保存的设备令牌
    final deviceToken = await PushNotificationService.getDeviceToken();

    // 获取token
    final token = await SaveData.getLoginData();

    if (deviceToken != null && token != null) {
      // 通知后端开始推送
      print("Notifying backend to start push with token: $deviceToken");
      http.Response response = await http.post(
        Uri.parse('http://116.92.243.5:8000/api/v1/user/device_token'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'deviceToken': deviceToken,
        }),
      );

      if (response.statusCode != 200) {
        // 如果状态码不是 200，打印错误信息
        print('Failed to login. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      } else {
        // 转换为json格式
        final jsonData = jsonDecode(response.body);

        if (jsonData['code'] == 200) {
          print('Push notification service started');
        } else {
          print('Failed to start push notification service');
        }
      }
    } else {
      print('Failed to start push notification service');
    }
  }

  // 登出时调用此方法，通知后端停止推送
  static Future<void> logoutUser() async {
    // 获取已保存的设备令牌
    final deviceToken = await PushNotificationService.getDeviceToken();
    // 获取token
    final token = await SaveData.getLoginData();

    SaveData.logout(); // 清除token

    if (deviceToken != null && token != null) {
      // 通知后端停止推送
      print("Notifying backend to stop push with token: $deviceToken");
      http.Response response = await http.post(
        Uri.parse('http://116.92.243.5:8000/api/v1/user/device_token'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'status': '2',
        }),
      );

      // 转换为json格式
      final jsonData = jsonDecode(response.body);

      if (jsonData['code'] == 200) {
        print('stop200');
      } else {
        print('stopFailed');
      }
    } else {
      print('stopFailed');
    }
  }
}
