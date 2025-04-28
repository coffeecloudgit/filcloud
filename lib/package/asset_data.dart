import 'package:fils_link/package/save_data.dart';
import 'package:dio/dio.dart';
import 'package:fils_link/service/api_service.dart';

class AssetData {
  // 获取资产数据
  static Future<Map> getAssetData(String url, {int? deptId}) async {
    // 获取token
    String? token = await SaveData.getLoginData();
    
    // 构建查询参数
    Map<String, dynamic> queryParams = {};
    
    // 如果提供了deptId且不为1（非默认部门），添加到查询参数中
    if (deptId != null && deptId != 1) {
      queryParams['deptId'] = deptId; // 直接传递整数值
    }

    Response response =
    await ApiService.dio.get(
      url, 
      queryParameters: queryParams,
      options: Options(headers:{
        'Authorization': 'Bearer $token',
      })
    );

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      return jsonData['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  // 获取块数据
  static Future<List> getBlockData(String url, {int? deptId}) async {
    // 获取token
    String? token = await SaveData.getLoginData();
    
    // 构建查询参数
    Map<String, dynamic> queryParams = {};
    
    // 如果提供了deptId且不为1（非默认部门），添加到查询参数中
    if (deptId != null && deptId != 1) {
      queryParams['deptId'] = deptId; // 直接传递整数值
    }

    Response response =
    await ApiService.dio.get(
      url, 
      queryParameters: queryParams,
      options: Options(headers:{
        'Authorization': 'Bearer $token',
      })
    );

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      return jsonData['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
