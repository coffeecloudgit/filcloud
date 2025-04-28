import 'package:dio/dio.dart';
import 'package:fils_link/service/api_service.dart';
import 'package:fils_link/package/save_data.dart';

class HomeData {
  // 获取首页数据
  static Future<Map> getHomeData(String url, {int? deptId}) async {
    // 获取token
    String? token = await SaveData.getLoginData();
    
    // 准备查询参数
    Map<String, dynamic> queryParams = {};
    
    // 如果提供了deptId且不为1（非默认部门），添加到查询参数中
    if (deptId != null && deptId != 1) {
      queryParams['deptId'] = deptId; // 直接传递整数值
    }

    Response response = await ApiService.dio.get(
      url,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      })
    );

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
  static Future<List> getChartData(String url, {int? deptId}) async {
    // 获取token
    String? token = await SaveData.getLoginData();
    
    // 准备查询参数
    Map<String, dynamic> queryParams = {};
    
    // 如果提供了deptId且不为1（非默认部门），添加到查询参数中
    if (deptId != null && deptId != 1) {
      queryParams['deptId'] = deptId; // 直接传递整数值
    }

    Response response = await ApiService.dio.get(
      url,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      })
    );

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