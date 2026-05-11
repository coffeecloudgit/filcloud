import 'dart:convert';

import 'package:fils_link/config/api_config.dart';
import 'package:http/http.dart' as http;

/// `FilPriceService` 是一个服务类，用于获取FIL价格。
class FilPriceService {
  /// 获取FIL价格
  static Future<Map> getFilPrice() async {
    http.Response response = await http.get(
      Uri.parse(ApiConfig.resolve('/api/v1/filprice')),
    );

    /// 转换为json格式
    final jsonData = jsonDecode(response.body);

    if (jsonData['code'] == 200) {
      return jsonData['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
