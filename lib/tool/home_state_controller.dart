import 'package:fils_link/package/data.dart';
import 'package:fils_link/service/fil_price_service.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../package/home_data.dart';
import '../package/http_data.dart';

/// `HomeStateController` 是一个首页页面状态控制器
///
/// 通过 `fetch` 方法获取数据，并存储于 `.obs` 变量中
/// 最后通过 `Obx` 达成组件的响应式更新
class HomeStateController extends GetxController {
  var captchaData = [].obs;
  var homeData = {}.obs;
  var filPrice = {}.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    _startTimer(); // 启动定时器
  }

  /// 启动定时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchHomeData(); // 获取首页数据
      fetchCaptchaData(); // 获取图表数据
    });
  }

  /// 获取首页数据
  Future<void> fetchHomeData() async {
    final Map data = await HomeData.getHomeData(Data.homeUrl); // 获取数据
    homeData.value = data; // 更新数据
  }

  /// 获取FIL价格
  Future<void> fetchFilPrice() async {
    final Map data = await FilPriceService.getFilPrice(); // 获取数据
    filPrice.value = data; // 更新数据
  }

  /// 获取图表数据
  Future<void> fetchCaptchaData() async {
    final List data = await HttpData.getChartData(Data.chartUrl); // 获取数据
    captchaData.value = data; // 更新数据
  }

  @override
  void onClose() {
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}
