import 'dart:convert';

import 'package:fils_link/package/save_data.dart';
import 'package:http/http.dart' as http;

class NodeData {
  // 获取节点数据
  static Future<List> getNodeData(String url) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    http.Response response =
        await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer $token',
    });

    // 转换为json格式
    final jsonData = jsonDecode(response.body);

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

    http.Response response =
        await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer $token',
    });

    // 转换为json格式
    final jsonData = jsonDecode(response.body);

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

    http.Response response = await http.put(Uri.parse(url.replaceFirst(':id', id)), headers: <String, String>{
      'Authorization': 'Bearer $token',
    }, body: jsonEncode(<String, String>{
      'title': name,
    }));

    // 转换为json格式
    final jsonData = jsonDecode(response.body);

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

    http.Response response =
        await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer $token',
    });

    // 转换为json格式
    final jsonData = jsonDecode(response.body);

    if (jsonData['code'] == 200) {
      var blockData = jsonData['data'];

      return blockData['list'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}