import 'dart:convert';
import 'dart:typed_data';

import 'package:fils_link/package/save_data.dart';
import 'package:http/http.dart' as http;

import '../page/login_page.dart';
import 'data.dart';

class HttpData {
  // 获取数据
  static Future getData(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    // 转换为json格式
    final jsonData = jsonDecode(response.body);
    if (jsonData['code'] == 200) {
      return response.body;
    } else {
      return '请求失败';
    }
  }

  // 登录
  static Future<bool> loginUser(String username, String password, String code,
      String uuid, String url) async {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'code': code,
        'uuid': uuid,
      }),
    );

    // 转化为json格式
    final jsonData = jsonDecode(response.body);

    if (jsonData['code'] == 200) {
      // 登录成功，处理返回的数据

      // 保存token
      SaveData.saveLoginData(jsonData['token']);

      // 保存用户信息
      SaveData.saveUserInfo(username);

      return true;
    } else {
      // 登录失败，处理错误
      return false;
    }
  }

  // 验证码
  static Future<Uint8List> verify() async {
    final response = await getData(Data.verifyUrl);

    if (response == '请求失败') {
      throw Exception('Failed to load image');
    } else {
      final jsonData = jsonDecode(response);

      // 获取uuid
      deUuid = jsonData['id'];
      // 获取base64字符串
      String base64String = jsonData['data'];
      // 去掉base64字符串的前缀
      final pureBase64Str = base64String.split(',')[1];
      // 解码
      final Uint8List bytes = base64.decode(pureBase64Str);
      // 返回bytes
      return bytes;
    }
  }

  // 退出登录
  static Future<bool> logout(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    http.Response response =
        await http.post(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer $token',
    });

    // 转换为json格式
    final jsonData = jsonDecode(response.body);

    if (jsonData['code'] == 200) {
      return true;
    } else {
      return false;
    }
  }
}
