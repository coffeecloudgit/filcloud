import 'package:get/get.dart';

/// 全局当前底部 Tab 索引（0=首页 1=节点 2=消息 3=资产）
///
/// 用于控制定时刷新只在“当前可见页”执行，避免后台重复请求。
abstract final class AppTabs {
  AppTabs._();

  static final RxInt activeIndex = 0.obs;
}

