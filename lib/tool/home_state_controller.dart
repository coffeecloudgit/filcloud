import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/http_data.dart';
import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/service/fil_price_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../package/home_data.dart';
import 'app_tabs.dart';

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
  // 部门列表
  var deptList = <Map<String, dynamic>>[].obs;
  // 选中的部门ID
  var selectedDeptId = RxnInt();
  Timer? _timer;

  @override
  void onInit() async {
    super.onInit();

    // 只在应用启动时从 SaveData 读取数据
    await _loadInitialData(); // 加载初始数据
    
    // 注册事件监听器，监听部门变化事件
    ever(selectedDeptId, (deptId) {
      // 部门变化时刷新数据
      if (deptId != null) {
        fetchHomeData();
        fetchCaptchaData();
        
        // 注意：不在这里保存部门ID，因为 selectDept 方法中已经保存了
        // 避免重复保存导致的问题
      }
    });
    
    _startTimer(); // 启动定时器
  }
  
  /// 加载初始数据，只在应用启动时调用一次
  Future<void> _loadInitialData() async {
    // 获取初始数据
    await _loadAdminData(); // 加载管理员数据
    
    // 确保在加载完管理员数据和部门列表后，再获取首页数据
    // 这样可以确保使用正确的部门ID获取数据
    await fetchHomeData(); // 获取首页数据
    await fetchCaptchaData(); // 获取图表数据
  }
  
  /// 加载管理员数据，只在应用启动时调用一次
  Future<void> _loadAdminData() async {
    try {
      // 检查管理员状态
      bool admin = await SaveData.isAdmin();
      isAdmin.value = admin;
      
      if (isAdmin.value) {
        // 如果是管理员，先获取部门列表
        await fetchDeptList(); // 获取部门列表
        
        // 从 SaveData 中加载部门 ID，只在应用启动时调用一次
        await _loadDeptIdFromStorage();
      }
    } catch (e) {
      print('加载管理员数据失败: $e');
    }
  }
  
  /// 从存储中加载部门 ID，只在应用启动时调用一次
  Future<void> _loadDeptIdFromStorage() async {
    try {
      // 确保部门列表已经加载
      if (deptList.isEmpty) {
        // 如果部门列表为空，设置默认部门ID
        selectedDeptId.value = 1; // 默认部门ID为1
        return;
      }
      
      // 优先使用用户的部门ID
      final int? userDeptId = await SaveData.getUserDeptId();
      
      if (userDeptId != null) {
        // 验证用户部门ID是否在当前部门列表中
        bool userDeptExists = deptList.any((dept) => dept['deptId'] == userDeptId);
        
        if (userDeptExists) {
          // 如果用户部门ID在当前部门列表中，使用它
          selectedDeptId.value = userDeptId;
          return;
        }
      }
      
      // 如果没有有效的用户部门ID，尝试使用上次选择的部门ID
      final int? savedDeptId = await SaveData.getSelectedDeptId();
      
      if (savedDeptId != null) {
        // 验证保存的部门ID是否在当前部门列表中
        bool savedDeptExists = deptList.any((dept) => dept['deptId'] == savedDeptId);
        
        if (savedDeptExists) {
          // 如果保存的部门ID在当前部门列表中，使用它
          selectedDeptId.value = savedDeptId;
          return;
        }
      }
      
      // 如果没有有效的保存部门ID，使用第一个部门
      final firstDeptId = deptList[0]['deptId'];
      selectedDeptId.value = firstDeptId;
      // 保存新选择的部门ID
      await SaveData.saveSelectedDeptId(firstDeptId);
    } catch (e) {
      print('从存储中加载部门ID失败: $e');
      // 异常情况下，设置默认部门ID
      selectedDeptId.value = 1;
    }
  }

  /// 启动定时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      // 仅在已登录且当前页可见时刷新，避免后台重复请求
      if (!await SaveData.checkLoginStatus()) return;
      if (AppTabs.activeIndex.value != 0) return;
      // 定期获取数据，但不从 SaveData 中读取部门 ID
      fetchFilPrice(); // 获取FIL价格
      
      // 如果是管理员，只获取部门列表，不重新读取部门 ID
      if (isAdmin.value) {
        fetchDeptList(); // 只获取部门列表
      }
      
      fetchHomeData(); // 获取首页数据
      fetchCaptchaData(); // 获取图表数据
    });
  }

  /// 获取首页数据
  Future<void> fetchHomeData() async {
    try {
      error.value = ''; // 清空之前的错误
      
      // 如果是管理员，获取当前选中的部门 ID
      int? deptId;
      if (isAdmin.value) {
        deptId = selectedDeptId.value;
      }
      
      final Map data = await HomeData.getHomeData(Data.homeUrl, deptId: deptId); // 获取数据
      
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
      
      // 如果是管理员，获取当前选中的部门 ID
      int? deptId;
      if (isAdmin.value) {
        deptId = selectedDeptId.value;
      }
      
      final List data = await HomeData.getChartData(Data.chartUrl, deptId: deptId); // 获取数据
      captchaData.value = data; // 更新数据
    } catch (e) {
      // 捕获并记录错误，不更新 captchaData
      error.value = e.toString();
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
  
  /// 获取部门列表
  Future<void> fetchDeptList() async {
    try {
      // 获取部门列表
      final List<Map<String, dynamic>> data = await HttpData.getDeptList();
      
      // 检查是否已包含默认部门（ID为1）
      bool hasDefaultDept = data.any((dept) => dept['deptId'] == 1);
      
      // 如果没有默认部门，添加一个
      if (!hasDefaultDept) {
        data.insert(0, {
          'deptId': 1,
          'deptName': '默认',
          'parentId': 0,
          'status': 2
        });
      }
      
      // 保存当前选中的部门ID
      final currentDeptId = selectedDeptId.value;
      
      // 更新部门列表
      deptList.value = data;
      
      // 验证当前部门ID是否仍然有效
      bool currentDeptExists = data.any((dept) => dept['deptId'] == currentDeptId);
      
      // 如果当前部门ID不再有效，则选择第一个部门
      if (!currentDeptExists && data.isNotEmpty) {
        final newDeptId = data[0]['deptId'];
        selectedDeptId.value = newDeptId;
        await SaveData.saveSelectedDeptId(newDeptId);
      }
    } catch (e) {
      print('获取部门列表失败: $e');
    }
  }
  
  /// 选择部门
  Future<void> selectDept(int deptId) async {
    // 如果选择的是当前部门，不做任何操作
    if (selectedDeptId.value == deptId) {
      return;
    }
    // 同时保存到存储中，但在应用运行期间不再从存储中读取
    await SaveData.saveSelectedDeptId(deptId);
    
    // 更新 RxInt 变量，这将触发 ever 监听器
    selectedDeptId.value = deptId;
  }
  


  @override
  void onClose() {
    /// 页面关闭时，关闭定时器
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}
