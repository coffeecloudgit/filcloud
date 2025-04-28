import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/service/fil_price_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../package/home_data.dart';

/// `HomeStateController` 是一个首页页面状态控制器
///
/// 通过 `fetch` 方法获取数据，并存储于 `.obs` 变量中
/// 最后通过 `Obx` 达成组件的响应式更新
class HomeStateController extends GetxController {
  var captchaData = [].obs;
  var homeData = {}.obs;
  var filPrice = {}.obs;
  // 可观察的错误信息
  var error = ''.obs;
  // 管理员状态
  var isAdmin = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    _startTimer(); // 启动定时器
    fetchHomeData(); // 获取首页数据
    fetchCaptchaData(); // 获取图表数据
    fetchFilPrice(); // 获取FIL价格
    _checkAdminStatus(); // 检查管理员状态
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
    try {
      error.value = ''; // 清空之前的错误
      final Map data = await HomeData.getHomeData(Data.homeUrl); // 获取数据
      homeData.value = data; // 更新数据
    } catch (e) {
      // 捕获并记录错误，不更新 captchaData
      error.value = e.toString();
    }
  }

  /// 获取FIL价格
  Future<void> fetchFilPrice() async {
    try {
      error.value = ''; // 清空之前的错误

      final Map data = await FilPriceService.getFilPrice(); // 获取数据
      filPrice.value = data; // 更新数据
    } catch (e) {
      // 捕获并记录错误，不更新 captchaData
      error.value = e.toString();
    }
  }

  /// 获取图表数据
  Future<void> fetchCaptchaData() async {
    try {
      error.value = ''; // 清空之前的错误
      final List data = await HomeData.getChartData(Data.chartUrl); // 获取数据
      captchaData.value = data; // 更新数据
    } catch (e) {
      // 捕获并记录错误，不更新 captchaData
      error.value = e.toString();
    }
  }
  
  /// 检查用户是否是管理员
  Future<void> _checkAdminStatus() async {
    try {
      bool admin = await SaveData.isAdmin();
      isAdmin.value = admin;
    } catch (e) {
      print('检查管理员状态失败: $e');
    }
  }
  
  /// 打开管理员面板
  void openAdminPanel() {
    // 这里可以导航到管理员面板页面
    Get.snackbar(
      '管理员面板',
      '管理员功能正在开发中...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    /// 页面关闭时，关闭定时器
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}
