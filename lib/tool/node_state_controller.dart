import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/node_data.dart';
import 'package:fils_link/package/save_data.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'home_state_controller.dart';
import 'app_tabs.dart';

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
  /// 部门联动监听；登出时会删除 [HomeStateController]，必须在 [onClose] 里 dispose。
  Worker? _deptEverWorker;
  int currentIndex = 0;

  NodeStateController({required this.currentIndex});

  @override
  void onInit() async {
    super.onInit();
    
    // 检查是否为管理员 - 使用 await 确保在继续之前完成
    await _checkAdminStatus();
    if (isClosed) return;
    
    // 获取初始部门ID
    int? initialDeptId;
    
    if (isAdmin.value) {
      // 如果是管理员，尝试获取保存的部门ID
      final savedDeptId = await SaveData.getSelectedDeptId();
      if (isClosed) return;
      
      if (savedDeptId != null) {
        // 如果有保存的部门ID，使用它
        initialDeptId = savedDeptId;
        
        // 同步到 HomeStateController（登出过程中可能已卸载，需先判断）
        if (Get.isRegistered<HomeStateController>()) {
          final homeController = Get.find<HomeStateController>();
          // 只有当当前选中的部门ID与保存的不同时才更新
          if (homeController.selectedDeptId.value != savedDeptId) {
            homeController.selectedDeptId.value = savedDeptId;
          }
        }
      } else {
        // 如果没有保存的部门ID，使用 HomeStateController 中的值
        if (Get.isRegistered<HomeStateController>()) {
          initialDeptId =
              Get.find<HomeStateController>().selectedDeptId.value;
        }
      }
    }
    
    // 使用正确的部门ID初始化数据
    await fetchTotalNodeData(deptId: initialDeptId);
    if (isClosed) return;
    if (currentIndex == 0) {
      await fetchNodeData(deptId: initialDeptId);
    } else {
      await fetchNodeBlockData();
    }
    if (isClosed) return;
    
    // 注册事件监听器，监听部门变化事件
    if (Get.isRegistered<HomeStateController>()) {
      _deptEverWorker = ever(
        Get.find<HomeStateController>().selectedDeptId,
        (deptId) {
          if (isClosed) return;
          // 直接使用事件中的 deptId 值
          fetchTotalNodeData(deptId: deptId);
          if (currentIndex == 0) {
            fetchNodeData(deptId: deptId);
          } else {
            fetchNodeBlockData();
          }
        },
      );
    }

    _startTimer(); // 启动定时器
  }
  
  /// 检查是否为管理员
  Future<void> _checkAdminStatus() async {
    final roleId = await SaveData.getUserRole();
    isAdmin.value = (roleId == 1); // 假设角色ID为1的是管理员
    return; // 显式返回，确保方法完成
  }

  /// 启动定时器
  void _startTimer() {
    // 定时器只负责定期刷新，不需要立即获取数据
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!await SaveData.checkLoginStatus()) return;
      if (AppTabs.activeIndex.value != 1) return;
      if (isClosed) return;
      if (!Get.isRegistered<HomeStateController>()) return;
      // 获取当前选中的部门 ID，使用 HomeStateController 中的值
      final deptId = Get.find<HomeStateController>().selectedDeptId.value;
      
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
    // 如果没有直接提供 deptId，则从 SaveData 或 HomeStateController 中获取
    if (deptId == null && isAdmin.value) {
      // 先获取保存的部门ID
      final savedDeptId = await SaveData.getSelectedDeptId();
      if (savedDeptId != null) {
        deptId = savedDeptId;
      } else {
        // 如果没有保存的部门ID，则使用 HomeStateController 中的值
        if (Get.isRegistered<HomeStateController>()) {
          final homeController = Get.find<HomeStateController>();
          deptId = homeController.selectedDeptId.value;
        }
      }
    }
    
    // 如果不是管理员或者 deptId 为默认值 1，则不传递 deptId
    if (!isAdmin.value || deptId == 1) {
      deptId = null;
    }
    
    if (isClosed) return;
    final Map data = await NodeData.getTotalNodeData(Data.totalNodeUrl, deptId: deptId); // 获取数据
    totalNodeData.value = data; // 更新数据
  }

  /// 获取节点数据
  Future<void> fetchNodeData({int? deptId}) async {
    // 如果没有直接提供 deptId，则从 SaveData 或 HomeStateController 中获取
    if (deptId == null && isAdmin.value) {
      // 先获取保存的部门ID
      final savedDeptId = await SaveData.getSelectedDeptId();
      if (savedDeptId != null) {
        deptId = savedDeptId;
      } else {
        // 如果没有保存的部门ID，则使用 HomeStateController 中的值
        if (Get.isRegistered<HomeStateController>()) {
          final homeController = Get.find<HomeStateController>();
          deptId = homeController.selectedDeptId.value;
        }
      }
    }
    
    // 如果不是管理员或者 deptId 为默认值 1，则不传递 deptId
    if (!isAdmin.value || deptId == 1) {
      deptId = null;
    }
    
    if (isClosed) return;
    final List data = await NodeData.getNodeData(Data.nodeUrl, deptId: deptId); // 获取数据
    nodeData.value = data; // 更新数据
  }

  /// 获取区块数据
  Future<void> fetchNodeBlockData() async {
    final List data = await NodeData.getBlockData(Data.nodeBlockUrl); // 获取数据
    if (isClosed) return;
    blockData.value = data; // 更新数据
  }

  @override
  void onClose() {
    _deptEverWorker?.dispose();
    _deptEverWorker = null;
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}
