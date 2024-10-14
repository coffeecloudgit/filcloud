import 'package:dio/dio.dart';
import 'package:fils_link/service/api_service.dart';
import 'package:fils_link/package/save_data.dart';

class SectorData {
  static Future<Map> getSectorData(String url, String nodeName) async {
    // 获取token
    String? token = await SaveData.getLoginData();

    // // 将请求体转换为表单数据格式
    // String encodedBody = body.entries
    //     .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
    //     .join('&');
    //
    // http.Response response =
    // await http.post(Uri.parse(url), headers: <String, String>{
    //   'Content-Type': 'application/x-www-form-urlencoded',
    //   'Authorization': 'Bearer $token',
    // }, body: encodedBody);
    //
    // 定义请求体，使用键值对形式
    Map<String, String> body = {
      'node': nodeName,
    };

    // 发起 POST 请求
    Response response = await ApiService.dio.post(
      url,
      data: body,  // 直接传递 Map，Dio 会自动处理为表单格式
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = response.data;
      if (jsonData['code'] == 200) {
        var data = jsonData['data'];

        return data['list'];
      } else {
        throw Exception('请求失败');
      }
    } else {
      throw Exception('请求失败${response.statusCode}');
    }
  }
}