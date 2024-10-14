import 'package:fils_link/package/save_data.dart';
import 'package:dio/dio.dart';
import 'package:fils_link/service/api_service.dart';

class NodeData {
  // 获取节点数据
  static Future<List> getNodeData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    Response response = await ApiService.dio.get(url,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      var nodeData = jsonData['data'];

      return nodeData['list'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  // 获取总节点数据
  static Future<Map> getTotalNodeData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    Response response = await ApiService.dio.get(url,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));

    // 转换为json格式
    final jsonData = response.data;

    if (jsonData['code'] == 200) {
      var nodeData = jsonData['data'];

      return nodeData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // 修改节点名称
  static Future<bool> changeNodeName(String url, String id, String name) async {
    // 获取token
    String? token = await SaveData.getLoginData();

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
      throw Exception('Failed to load data');
    }
  }

  // 获取孤块列表
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
      var blockData = jsonData['data'];

      return blockData['list'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
