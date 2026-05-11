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

    final jsonData = jsonDecode(response.body);
    return await _handleLoginResponse(jsonData, username);
  }

  static Future<bool> _handleLoginResponse(
      Map<String, dynamic> jsonData, String username) async {
    if (jsonData['code'] != 200) return false;

    await SaveData.saveLoginData(jsonData['token']);
    await SaveData.saveUserInfo(username);

    if (jsonData['data'] != null && jsonData['data']['user'] != null) {
      final userData = jsonData['data']['user'];
      if (userData['roleId'] != null) {
        await SaveData.saveUserRole(userData['roleId']);
      }
      if (userData['deptId'] != null) {
        await SaveData.saveUserDeptId(userData['deptId']);
        await SaveData.clearSelectedDeptId();
      }
    } else {
      await getUserInfo();
    }

    return true;
  }

  // Passkey: register begin
  static Future<Map<String, dynamic>> passkeyRegisterBegin(String username) async {
    final response = await http.post(
      Uri.parse(Data.passkeyRegisterBeginUrl),
      headers: const <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'username': username}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Passkey: register finish
  static Future<Map<String, dynamic>> passkeyRegisterFinish(
      String username, Map<String, dynamic> credentialResponse) async {
    final response = await http.post(
      Uri.parse(Data.passkeyRegisterFinishUrl),
      headers: const <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'response': credentialResponse,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Passkey: login begin
  static Future<Map<String, dynamic>> passkeyLoginBegin(String username) async {
    final response = await http.post(
      Uri.parse(Data.passkeyLoginBeginUrl),
      headers: const <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'username': username}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Passkey: login finish (returns token like normal login)
  static Future<bool> passkeyLoginFinish(
      String username, Map<String, dynamic> assertionResponse) async {
    final response = await http.post(
      Uri.parse(Data.passkeyLoginFinishUrl),
      headers: const <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'response': assertionResponse,
      }),
    );
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return await _handleLoginResponse(jsonData, username);
  }

  /// 获取滑块拼图验证码数据（与后端 [slide_basic] 一致）。
  static Future<Map<String, dynamic>> fetchSlideCaptcha() async {
    final response = await http.get(Uri.parse(Data.slideCaptchaUrl));
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    if (jsonData['code'] != 200) {
      throw Exception(jsonData['msg']?.toString() ?? '滑块验证码获取失败');
    }
    return jsonData;
  }

  /// 校验滑块位置；成功时服务端会将 [key] 标记为已通过，登录时 [uuid] 传该 key、[code] 传空即可。
  static Future<bool> checkSlideCaptcha({
    required String key,
    required int pointX,
    required int pointY,
  }) async {
    final point = '$pointX,$pointY';
    final body =
        'point=${Uri.encodeQueryComponent(point)}&key=${Uri.encodeQueryComponent(key)}';
    final response = await http.post(
      Uri.parse(Data.checkSlideCaptchaUrl),
      headers: const <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: body,
    );
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    if (jsonData['code'] != 200) return false;
    return jsonData['data'] == true;
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

  // 获取用户详细信息
  static Future<void> getUserInfo() async {
    try {
      // 获取token
      String? token = await SaveData.getLoginData();
      
      if (token == null) {
        return;
      }
      
      final response = await http.get(
        Uri.parse(Data.getUserInfoUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      
      // 转换为json格式
      final jsonData = jsonDecode(response.body);
      
      if (jsonData['code'] == 200 && jsonData['data'] != null && jsonData['data']['user'] != null) {
        final userData = jsonData['data']['user'];
        
        // 检查是否包含roleId字段
        if (userData['roleId'] != null) {
          // 保存用户角色ID
          await SaveData.saveUserRole(userData['roleId']);
        }
        
        // 检查是否包含deptId字段
        if (userData['deptId'] != null) {
          // 保存用户部门ID
          await SaveData.saveUserDeptId(userData['deptId']);
          // 清除上次选择的部门ID，确保重新登录时使用用户的默认部门
          await SaveData.clearSelectedDeptId();
        }
      }
    } catch (e) {
      print('获取用户信息失败: $e');
    }
  }
  
  // 获取部门列表
  static Future<List<Map<String, dynamic>>> getDeptList() async {
    try {
      // 获取token
      String? token = await SaveData.getLoginData();
      if (token == null) {
        return [];
      }
      final response = await http.get(
        Uri.parse(Data.deptListUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      
      // 转换为json格式
      final jsonData = jsonDecode(response.body);
      
      if (jsonData['code'] == 200 && jsonData['data'] != null) {
        // 返回部门列表
        return List<Map<String, dynamic>>.from(jsonData['data']);
      }
      
      return [];
    } catch (e) {
      print('获取部门列表失败: $e');
      return [];
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
