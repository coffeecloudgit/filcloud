import 'dart:convert';

import 'package:fils_link/package/save_data.dart';
import 'package:http/http.dart' as http;

class HomeData {
  // 获取首页数据
  static Future<Map> getHomeData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    http.Response response =
    await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer $token',
    });

    // 转换为json格式
    final jsonData = jsonDecode(response.body);

    if (jsonData['code'] == 200) {
      var homeData = jsonData['data'];

      return homeData;
    } else {
      throw Exception('请求失败');
    }
  }
}