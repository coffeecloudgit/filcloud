import 'package:fils_link/package/asset_data.dart';
import 'package:fils_link/package/data.dart';
import 'package:get/get.dart';
import 'dart:async';

/// `AssetStateController` 是一个资产页面状态控制器
///
/// 通过 `fetch` 方法获取数据，并存储于 `.obs` 变量中
/// 最后通过 `Obx` 达成组件的响应式更新
class AssetStateController extends GetxController {
  var assetData = {}.obs;
  var blockData = [].obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    _startTimer(); // 启动定时器
  }

  /// 启动定时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchAssetData(); // 获取资产数据
      fetchBlockData(); // 获取块数据
    });
  }

  /// 获取资产数据
  Future<void> fetchAssetData() async {
    final Map data = await AssetData.getAssetData(Data.totalAssetUrl); // 获取数据
    assetData.value = data; // 更新数据
  }

  /// 获取块数据
  Future<void> fetchBlockData() async {
    final List data = await AssetData.getBlockData(Data.blockUrl); // 获取数据
    blockData.value = data; // 更新数据
  }

  @override
  void onClose() {
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}