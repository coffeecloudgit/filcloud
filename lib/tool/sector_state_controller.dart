import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/sector_data.dart';
import 'package:get/get.dart';
import 'dart:async';

/// `SectorStateController` 是一个节点页面状态控制器
///
/// 通过 `fetch` 方法获取数据，并存储于 `.obs` 变量中
/// 最后通过 `Obx` 达成组件的响应式更新
class SectorStateController extends GetxController {
  var sectorData = {}.obs;
  Timer? _timer;
  String nodeName;

  SectorStateController({required this.nodeName});

  /// 初始化
  @override
  void onInit() {
    super.onInit();

    _startTimer(); // 启动定时器
  }

  /// 启动定时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchSectorData(); // 获取扇区数据
    });
  }

  /// 获取扇区数据
  Future<void> fetchSectorData() async {
    final Map data = await SectorData.getSectorData(Data.sectorUrl, nodeName); // 获取数据
    sectorData.value = data; // 更新数据
  }

  @override
  void onClose() {
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}
