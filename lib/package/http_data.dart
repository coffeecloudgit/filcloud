import 'dart:convert';
import 'dart:typed_data';

import 'package:fils_link/package/save_data.dart';
import 'package:http/http.dart' as http;

import '../page/login_page.dart';
import 'data.dart';

class HttpData {
  /// 解析业务 API 的 JSON 体；遇 404/非 JSON（如 nginx 纯文本）时返回结构化错误，避免 FormatException。
  static Map<String, dynamic> _parseJsonApiResponse(http.Response response) {
    final status = response.statusCode;
    if (status == 404) {
      return {
        'code': 404,
        'msg': '暂无法使用，请稍后再试',
      };
    }
    final trimmed = response.body.trim();
    if (trimmed.isEmpty) {
      return {
        'code': status,
        'msg': '网络异常，请稍后再试',
      };
    }
    final looksJson =
        trimmed.startsWith('{') || trimmed.startsWith('[');
    if (!looksJson) {
      return {
        'code': status,
        'msg': '服务繁忙，请稍后再试',
      };
    }
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {'code': status, 'msg': '请求异常，请稍后再试'};
    } catch (_) {
      return {
        'code': status,
        'msg': '请求异常，请稍后再试',
      };
    }
  }

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

  // 登录。失败时 [message] 为服务端 `msg`（如「用户名或密码错误」）。
  static Future<({bool ok, String? message})> loginUser(String username,
      String password, String code, String uuid, String url) async {
    try {
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
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final codeVal = jsonData['code'];
      final serverMsg = jsonData['msg']?.toString();
      if (codeVal != 200) {
        return (
          ok: false,
          message: _normalizeLoginErrorMessage(serverMsg, codeVal),
        );
      }
      final saved = await _handleLoginResponse(jsonData, username);
      return (
        ok: saved,
        message: saved ? null : (serverMsg ?? '登录数据处理失败'),
      );
    } catch (e) {
      return (ok: false, message: e.toString());
    }
  }

  static String _normalizeLoginErrorMessage(String? raw, dynamic code) {
    if (raw != null && raw.isNotEmpty) {
      switch (raw) {
        case 'incorrect Username or Password':
          return '用户名或密码错误';
        case '请先完成验证码验证':
          return '请先完成安全验证';
        default:
          return raw;
      }
    }
    return '登录失败（$code）';
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

  // Passkey: register finish（登录态 begin-authed 与此共用）
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
    return _parseJsonApiResponse(response);
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
    return _parseJsonApiResponse(response);
  }

  /// Passkey 登录完成。成功时写 token 与用户缓存，与账号密码登录一致。
  /// [message] 为服务端 `msg` 或本地解析说明，发布环境可据此对照后端日志。
  static Future<({bool ok, String? message})> passkeyLoginFinish(
      String username, Map<String, dynamic> assertionResponse) async {
    try {
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
      final jsonData = _parseJsonApiResponse(response);
      final serverMsg = jsonData['msg']?.toString();
      if (jsonData['code'] != 200) {
        return (
          ok: false,
          message: (serverMsg != null && serverMsg.isNotEmpty)
              ? serverMsg
              : '服务端错误 code=${jsonData['code']}',
        );
      }
      final ok = await _handleLoginResponse(jsonData, username);
      return (
        ok: ok,
        message: ok ? null : (serverMsg ?? '登录数据处理失败'),
      );
    } catch (e) {
      return (ok: false, message: e.toString());
    }
  }

  static Future<Map<String, String>?> _bearerHeaders() async {
    final token = await SaveData.getLoginData();
    if (token == null) return null;
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// 已登录用户发起通行密钥注册（无需再验证密码或滑块）。
  static Future<Map<String, dynamic>> passkeyRegisterBeginAuthed() async {
    final h = await _bearerHeaders();
    if (h == null) {
      return <String, dynamic>{'code': 401, 'msg': '未登录'};
    }
    final response = await http.post(
      Uri.parse(Data.passkeyRegisterBeginAuthedUrl),
      headers: h,
    );
    return _parseJsonApiResponse(response);
  }

  /// 已登录绑定的 finish：复用公开 /register/finish，会话键一致，无需单独接口。
  static Future<Map<String, dynamic>> passkeyRegisterFinishAuthed(
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
    return _parseJsonApiResponse(response);
  }

  static Future<Map<String, dynamic>> passkeyCredentialsList() async {
    final h = await _bearerHeaders();
    if (h == null) {
      return <String, dynamic>{'code': 401, 'msg': '未登录'};
    }
    final response = await http.get(
      Uri.parse(Data.passkeyCredentialsUrl),
      headers: h,
    );
    return _parseJsonApiResponse(response);
  }

  static Future<Map<String, dynamic>> passkeyCredentialDeleteBegin(
      int id) async {
    final h = await _bearerHeaders();
    if (h == null) {
      return <String, dynamic>{'code': 401, 'msg': '未登录'};
    }
    final response = await http.post(
      Uri.parse(Data.passkeyCredentialDeleteBeginUrl),
      headers: h,
      body: jsonEncode(<String, int>{'id': id}),
    );
    return _parseJsonApiResponse(response);
  }

  static Future<Map<String, dynamic>> passkeyCredentialDeleteFinish(
      int id, Map<String, dynamic> assertionResponse) async {
    final h = await _bearerHeaders();
    if (h == null) {
      return <String, dynamic>{'code': 401, 'msg': '未登录'};
    }
    final response = await http.post(
      Uri.parse(Data.passkeyCredentialDeleteFinishUrl),
      headers: h,
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'response': assertionResponse,
      }),
    );
    return _parseJsonApiResponse(response);
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
