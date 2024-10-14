import 'package:dio/dio.dart';
import 'package:fils_link/service/api_service.dart';
import 'package:fils_link/package/save_data.dart';

class HomeData {
  // 获取首页数据
  static Future<Map> getHomeData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    Response response =
    await ApiService.dio.get(url, options: Options(headers:{
      'Authorization': 'Bearer $token',
    }));

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      var homeData = jsonData['data'];

      return homeData;
    } else {
      throw Exception('请求失败');
    }
  }

  // 获取图表数据
  static Future<List> getChartData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    Response response =
    await ApiService.dio.get(url, options: Options(headers:{
      'Authorization': 'Bearer $token',
    }));

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      var barData = jsonData['data'];

      return barData['barData'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}