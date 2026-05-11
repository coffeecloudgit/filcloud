import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/save_data.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../package/message_data.dart';
import 'app_tabs.dart';

/// `MessageStateController` 是一个消息页面状态控制器
///
/// 通过 `fetch` 方法获取数据，并存储于 `.obs` 变量中
/// 最后通过 `Obx` 达成组件的响应式更新
class MessageStateController extends GetxController {
  var messageData = [].obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    _startTimer(); // 启动定时器
  }

  /// 启动定时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!await SaveData.checkLoginStatus()) return;
      if (AppTabs.activeIndex.value != 2) return;
      fetchMessageData(); // 获取消息数据
    });
  }

  /// 获取消息数据
  Future<void> fetchMessageData() async {
    final List data = await MessageData.getMessageData(Data.messageUrl); // 获取数据
    messageData.value = data; // 更新数据
  }

  @override
  void onClose() {
    _timer?.cancel(); // 关闭定时器
    super.onClose();
  }
}

