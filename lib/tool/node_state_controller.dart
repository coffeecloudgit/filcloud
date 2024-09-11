import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/node_data.dart';
import 'package:get/get.dart';
import 'dart:async';

/// `NodePageController` 是一个节点页面状态控制器
///
/// 通过 `fetch` 方法获取数据，并存储于 `.obs` 变量中
/// 最后通过 `Obx` 达成组件的响应式更新
class NodeStateController extends GetxController {
  var totalNodeData = {}.obs;
  var nodeData = [].obs;
  var blockData = [].obs;
  Timer? _timer;
  int currentIndex = 0;

  NodeStateController({required this.currentIndex});

  @override
  void onInit() {
    super.onInit();

    _startTimer(); // 启动定时器
  }

  /// 启动定时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchTotalNodeData(); // 获取总节点数据
      if (currentIndex == 0) {
        fetchNodeData(); // 获取节点数据
      } else {
        fetchNodeBlockData(); // 获取区块数据
      }
    });
  }

  /// 获取总节点数据
  Future<void> fetchTotalNodeData() async {
    final Map data = await NodeData.getTotalNodeData(Data.totalNodeUrl); // 获取数据
    totalNodeData.value = data; // 更新数据
  }

  /// 获取节点数据
  Future<void> fetchNodeData() async {
    final List data = await NodeData.getNodeData(Data.nodeUrl); // 获取数据
    nodeData.value = data; // 更新数据

  }

  /// 获取区块数据
  Future<void> fetchNodeBlockData() async {
    final List data = await NodeData.getBlockData(Data.nodeBlockUrl); // 获取数据
    blockData.value = data; // 更新数据
  }

  @override
  void onClose() {
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}
