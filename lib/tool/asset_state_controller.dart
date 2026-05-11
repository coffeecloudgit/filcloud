import 'package:fils_link/package/asset_data.dart';
import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/tool/home_state_controller.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'app_tabs.dart';

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

  // 存储当前部门ID的本地变量，确保在所有情况下都能正确获取
  final RxInt _currentDeptId = 1.obs;
  
  // 初始化完成标志
  final RxBool _initialized = false.obs;
  
  @override
  void onInit() async {
    super.onInit();
    
    // 检查管理员状态 - 使用 await 确保在继续之前完成
    await _checkAdminStatus();
    
    if (isAdmin.value) {
      // 如果是管理员，先从存储中获取部门ID
      final savedDeptId = await SaveData.getSelectedDeptId();
      
      if (savedDeptId != null) {
        // 如果有保存的部门ID，使用它
        _currentDeptId.value = savedDeptId;
        
        // 同步到 HomeStateController
        if (_homeStateController.selectedDeptId.value != savedDeptId) {
          _homeStateController.selectedDeptId.value = savedDeptId;
        }
      } else {
        // 如果没有保存的部门ID，使用默认值1
        _currentDeptId.value = 1;
        _homeStateController.selectedDeptId.value = 1;
      }
    }
    
    // 标记初始化完成
    _initialized.value = true;
    
    // 监听 HomeStateController 中的部门ID变化
    ever(_homeStateController.selectedDeptId, (deptId) {
      if (deptId != _currentDeptId.value) {
        // 确保 deptId 不为 null
        _currentDeptId.value = deptId ?? 1;
        // 刷新数据
        if (_initialized.value) {
          fetchAssetData();
          fetchBlockData();
        }
      }
    });
    
    // 使用当前部门ID初始化数据
    await fetchAssetData();
    await fetchBlockData();
    
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
    // 定时器只负责定期刷新，不需要立即获取数据
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!await SaveData.checkLoginStatus()) return;
      if (AppTabs.activeIndex.value != 3) return;
      // 直接使用当前部门ID，不需要传递参数
      fetchAssetData(); // 获取资产数据
      fetchBlockData(); // 获取块数据
    });
  }

  /// 获取资产数据
  Future<void> fetchAssetData({int? deptId}) async {
    try {
      // 如果未初始化完成且没有直接提供 deptId，则等待初始化
      if (!_initialized.value && deptId == null) {
        // 等待初始化完成
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_initialized.value) {
          return;
        }
      }
      
      error.value = ''; // 清空之前的错误
      
      // 如果没有直接提供 deptId，则使用当前部门ID
      if (deptId == null) {
        deptId = _currentDeptId.value;
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
      // 如果未初始化完成且没有直接提供 deptId，则等待初始化
      if (!_initialized.value && deptId == null) {
        // 等待初始化完成
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_initialized.value) {
          return;
        }
      }
      
      error.value = ''; // 清空之前的错误
      
      // 如果没有直接提供 deptId，则使用当前部门ID
      if (deptId == null) {
        deptId = _currentDeptId.value;
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