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

  // 删除用户所有数据，但保留用户名以方便下次登录
  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 删除登录token
    await prefs.remove('login_token');
    // 注意：不删除用户信息（user_info），以保留用户名方便下次登录
    // await prefs.remove('user_info');
    // 删除用户角色ID
    await prefs.remove('user_role_id');
    // 删除用户部门ID
    await prefs.remove('user_dept_id');
    // 删除选中的部门ID
    await prefs.remove('selected_dept_id');
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
  
  // 保存用户部门ID
  static Future<void> saveUserDeptId(int deptId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_dept_id', deptId);
  }
  
  // 获取用户部门ID
  static Future<int?> getUserDeptId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_dept_id');
  }
  
  // 保存选中的部门ID
  static Future<void> saveSelectedDeptId(int deptId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_dept_id', deptId);
  }
  
  // 获取选中的部门ID
  static Future<int?> getSelectedDeptId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_dept_id');
  }
  
  // 清除选中的部门ID
  static Future<void> clearSelectedDeptId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_dept_id');
  }
}