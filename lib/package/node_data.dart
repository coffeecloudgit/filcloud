import 'package:fils_link/package/save_data.dart';
import 'package:dio/dio.dart';
import 'package:fils_link/service/api_service.dart';

class NodeData {
  // 获取节点数据
  static Future<List> getNodeData(String url, {int? deptId}) async {
    // 获取token
    String? token = await SaveData.getLoginData();
    if (token == null || token.isEmpty) {
      return [];
    }
    
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
      var nodeData = jsonData['data'];

      return nodeData['list'];
    } else {
      return [];
    }
  }

  // 获取总节点数据
  static Future<Map> getTotalNodeData(String url, {int? deptId}) async {
    // 获取token
    String? token = await SaveData.getLoginData();
    if (token == null || token.isEmpty) {
      return {};
    }
    
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
      var nodeData = jsonData['data'];

      return nodeData;
    } else {
      return {};
    }
  }

  // 修改节点名称
  static Future<bool> changeNodeName(String url, String id, String name) async {
    // 获取token
    String? token = await SaveData.getLoginData();
    if (token == null || token.isEmpty) {
      return false;
    }

    // 构建请求 URL
    String apiUrl = url.replaceFirst(':id', id);

    // 发起 PUT 请求
    Response response = await ApiService.dio.put(
      apiUrl,
      data: {'title': name}, // 请求体 data 使用 Map 形式
      options: Options(
        headers: {'Authorization': 'Bearer $token'}, // 请求头
      ),
    );

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      return true;
    } else {
      return false;
    }
  }

  // 获取孤块列表
  static Future<List> getBlockData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();
    if (token == null || token.isEmpty) {
      return [];
    }

    Response response =
    await ApiService.dio.get(url, options: Options(headers:{
      'Authorization': 'Bearer $token',
    }));

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      var blockData = jsonData['data'];

      return blockData['list'];
    } else {
      return [];
    }
  }
}
