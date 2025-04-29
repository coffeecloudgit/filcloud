import 'package:fils_link/package/asset_data.dart';
import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/tool/home_state_controller.dart';
import 'package:get/get.dart';
import 'dart:async';

/// `AssetStateController` 是一个资产页面状态控制器
///
/// 通过 `fetch` 方法获取数据，并存储于 `.obs` 变量中
/// 最后通过 `Obx` 达成组件的响应式更新
class AssetStateController extends GetxController {
  var assetData = {}.obs;
  var blockData = [].obs;
  var error = ''.obs;
  var isAdmin = false.obs;
  Timer? _timer;
  
  // 获取 HomeStateController 的引用
  final HomeStateController _homeStateController = Get.find<HomeStateController>();

  @override
  void onInit() async {
    super.onInit();
    
    // 检查管理员状态 - 使用 await 确保在继续之前完成
    await _checkAdminStatus();
    
    // 获取初始部门ID
    int? initialDeptId;
    
    if (isAdmin.value) {
      // 如果是管理员，尝试获取保存的部门ID
      final savedDeptId = await SaveData.getSelectedDeptId();
      
      if (savedDeptId != null) {
        // 如果有保存的部门ID，使用它
        initialDeptId = savedDeptId;
        
        // 同步到 HomeStateController
        // 只有当当前选中的部门ID与保存的不同时才更新
        if (_homeStateController.selectedDeptId.value != savedDeptId) {
          _homeStateController.selectedDeptId.value = savedDeptId;
        }
      } else {
        // 如果没有保存的部门ID，使用 HomeStateController 中的值
        initialDeptId = _homeStateController.selectedDeptId.value;
      }
    }
    
    // 使用正确的部门ID初始化数据
    await fetchAssetData(deptId: initialDeptId);
    await fetchBlockData(deptId: initialDeptId);
    
    // 注册事件监听器，监听部门变化事件
    ever(_homeStateController.selectedDeptId, (deptId) {
      // 部门变化时刷新数据
      if (isAdmin.value) {
        fetchAssetData(deptId: deptId);
        fetchBlockData(deptId: deptId);
      }
    });
    
    _startTimer(); // 启动定时器
  }
  
  /// 检查用户是否是管理员
  Future<void> _checkAdminStatus() async {
    try {
      bool admin = await SaveData.isAdmin();
      isAdmin.value = admin;
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// 启动定时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // 获取当前选中的部门 ID
      int? deptId;
      if (isAdmin.value) {
        deptId = _homeStateController.selectedDeptId.value;
      }
      
      fetchAssetData(deptId: deptId); // 获取资产数据
      fetchBlockData(deptId: deptId); // 获取块数据
    });
  }

  /// 获取资产数据
  Future<void> fetchAssetData({int? deptId}) async {
    try {
      error.value = ''; // 清空之前的错误
      
      // 如果没有直接提供 deptId，则从 HomeStateController 中获取
      if (deptId == null && isAdmin.value) {
        deptId = _homeStateController.selectedDeptId.value;
      }
      
      // 如果不是管理员或者 deptId 为默认值 1，则不传递 deptId
      if (!isAdmin.value || deptId == 1) {
        deptId = null;
      }
      
      final Map data = await AssetData.getAssetData(Data.totalAssetUrl, deptId: deptId); // 获取数据
      assetData.value = data; // 更新数据
    } catch (e) {
      // 捕获并记录错误
      error.value = e.toString();
    }
  }

  /// 获取块数据
  Future<void> fetchBlockData({int? deptId}) async {
    try {
      error.value = ''; // 清空之前的错误
      
      // 如果没有直接提供 deptId，则从 HomeStateController 中获取
      if (deptId == null && isAdmin.value) {
        deptId = _homeStateController.selectedDeptId.value;
      }
      
      // 如果不是管理员或者 deptId 为默认值 1，则不传递 deptId
      if (!isAdmin.value || deptId == 1) {
        deptId = null;
      }
      
      final List data = await AssetData.getBlockData(Data.blockUrl, deptId: deptId); // 获取数据
      blockData.value = data; // 更新数据
    } catch (e) {
      // 捕获并记录错误
      error.value = e.toString();
    }
  }

  @override
  void onClose() {
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}