import 'package:fils_link/package/save_data.dart';
import 'package:dio/dio.dart';
import 'package:fils_link/service/api_service.dart';

class AssetData {
  // 获取资产数据
  static Future<Map> getAssetData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    Response response =
    await ApiService.dio.get(url, options: Options(headers:{
      'Authorization': 'Bearer $token',
    }));

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      return jsonData['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  // 获取块数据
  static Future<List> getBlockData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    Response response =
    await ApiService.dio.get(url, options: Options(headers:{
      'Authorization': 'Bearer $token',
    }));

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      return jsonData['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
