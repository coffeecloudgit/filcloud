import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/node_data.dart';
import 'package:fils_link/package/save_data.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'home_state_controller.dart';

/// `NodePageController` 是一个节点页面状态控制器
///
/// 通过 `fetch` 方法获取数据，并存储于 `.obs` 变量中
/// 最后通过 `Obx` 达成组件的响应式更新
class NodeStateController extends GetxController {
  // 是否是管理员
  final isAdmin = false.obs;
  
  var totalNodeData = {}.obs;
  var nodeData = [].obs;
  var blockData = [].obs;
  Timer? _timer;
  int currentIndex = 0;

  NodeStateController({required this.currentIndex});

  @override
  void onInit() {
    super.onInit();
    
    // 检查是否为管理员
    _checkAdminStatus();
    
    // 注册事件监听器，监听部门变化事件
    ever(Get.find<HomeStateController>().selectedDeptId, (deptId) {
      // 打印调试信息，部门变化
      print('[调试] NodeStateController: 部门变化事件触发，新部门ID = $deptId');
      
      // 直接使用事件中的 deptId 值，而不是从 SaveData 中获取
      // 部门变化时刷新数据
      fetchTotalNodeData(deptId: deptId);
      if (currentIndex == 0) {
        fetchNodeData(deptId: deptId);
      } else {
        fetchNodeBlockData();
      }
    });

    _startTimer(); // 启动定时器
  }
  
  /// 检查是否为管理员
  Future<void> _checkAdminStatus() async {
    final roleId = await SaveData.getUserRole();
    isAdmin.value = (roleId == 1); // 假设角色ID为1的是管理员
  }

  /// 启动定时器
  void _startTimer() {
    // 定时器只负责定期刷新，不需要立即获取数据
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      // 获取当前选中的部门 ID，使用 HomeStateController 中的值
      final deptId = Get.find<HomeStateController>().selectedDeptId.value;
      print('[调试] NodeStateController: 定时器触发，当前部门ID = $deptId');
      
      fetchTotalNodeData(deptId: deptId); // 获取总节点数据
      if (currentIndex == 0) {
        fetchNodeData(deptId: deptId); // 获取节点数据
      } else {
        fetchNodeBlockData(); // 获取区块数据
      }
    });
  }

  /// 获取总节点数据
  Future<void> fetchTotalNodeData({int? deptId}) async {
    // 如果没有直接提供 deptId，则从 HomeStateController 中获取
    if (deptId == null && isAdmin.value) {
      // 直接使用 HomeStateController 中的 selectedDeptId
      final homeController = Get.find<HomeStateController>();
      deptId = homeController.selectedDeptId.value;
    }
    
    // 打印调试信息，获取总节点数据
    print('[调试] NodeStateController: 获取总节点数据，deptId = $deptId');
    
    // 如果不是管理员或者 deptId 为默认值 1，则不传递 deptId
    if (!isAdmin.value || deptId == 1) {
      deptId = null;
    }
    
    // 打印调试信息，实际调用 API 时使用的 deptId
    print('[调试] NodeStateController: 实际调用总节点数据 API，deptId = $deptId');
    final Map data = await NodeData.getTotalNodeData(Data.totalNodeUrl, deptId: deptId); // 获取数据
    totalNodeData.value = data; // 更新数据
  }

  /// 获取节点数据
  Future<void> fetchNodeData({int? deptId}) async {
    // 如果没有直接提供 deptId，则从 HomeStateController 中获取
    if (deptId == null && isAdmin.value) {
      // 直接使用 HomeStateController 中的 selectedDeptId
      final homeController = Get.find<HomeStateController>();
      deptId = homeController.selectedDeptId.value;
    }
    
    // 打印调试信息，获取节点数据
    print('[调试] NodeStateController: 获取节点数据，deptId = $deptId');
    
    // 如果不是管理员或者 deptId 为默认值 1，则不传递 deptId
    if (!isAdmin.value || deptId == 1) {
      deptId = null;
    }
    
    // 打印调试信息，实际调用 API 时使用的 deptId
    print('[调试] NodeStateController: 实际调用节点数据 API，deptId = $deptId');
    final List data = await NodeData.getNodeData(Data.nodeUrl, deptId: deptId); // 获取数据
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
