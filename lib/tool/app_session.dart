import 'package:get/get.dart';

import '../package/save_data.dart';
import 'app_tabs.dart';
import 'asset_state_controller.dart';
import 'home_state_controller.dart';
import 'message_state_controller.dart';
import 'node_state_controller.dart';
import 'sector_state_controller.dart';

/// 统一处理登出/会话失效时的资源释放，防止定时器继续请求。
abstract final class AppSession {
  AppSession._();

  static Future<void> logoutAndReset() async {
    await SaveData.logout();

    // 重置活跃 Tab
    AppTabs.activeIndex.value = 0;

    // 删除所有带定时器的控制器（触发 onClose -> cancel timer）
    if (Get.isRegistered<SectorStateController>()) {
      Get.delete<SectorStateController>(force: true);
    }
    if (Get.isRegistered<NodeStateController>()) {
      Get.delete<NodeStateController>(force: true);
    }
    if (Get.isRegistered<MessageStateController>()) {
      Get.delete<MessageStateController>(force: true);
    }
    if (Get.isRegistered<AssetStateController>()) {
      Get.delete<AssetStateController>(force: true);
    }
    if (Get.isRegistered<HomeStateController>()) {
      Get.delete<HomeStateController>(force: true);
    }
  }
}

