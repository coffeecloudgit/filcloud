import 'package:shared_preferences/shared_preferences.dart';


class SaveData{
  // 保存用户token
  static Future<void> saveLoginData(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_token', token);  // 保存用户token
  }

  // 保存用户登录状态
  static Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('login_token');

    return token != null;  // 如果token存在，返回true，表示用户已登录
  }

  // 获取保存的用户token
  static Future<String?> getLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_token');
  }

  // 删除用户token
  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('login_token');  // 删除登录token
  }

  // 保存用户信息
  static Future<void> saveUserInfo(String userInfo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', userInfo);  // 保存用户信息
  }

  // 获取用户信息
  static Future<String?> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_info');
  }
  
  // 保存用户角色ID
  static Future<void> saveUserRole(int roleId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_role_id', roleId);
  }
  
  // 获取用户角色ID
  static Future<int> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_role_id') ?? 0; // 默认返回0，表示非管理员
  }
  
  // 检查用户是否是管理员
  static Future<bool> isAdmin() async {
    final int roleId = await getUserRole();
    return roleId == 1; // roleId为1表示系统管理员
  }
}