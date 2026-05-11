import 'dart:ui';

import 'package:fils_link/tool/message_state_controller.dart';
import 'package:fils_link/tool/void_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

// 与 assets/icons 中实际存在的 message_*.svg 对齐。
// type 6：无独立资源（如余额不足），与 type 3 共用电池形状图标。
String _messageIconAsset(int typeMod10) {
  final t = typeMod10 == 6 ? 3 : typeMod10;
  switch (t) {
    case 1:
      return 'assets/icons/message_1.svg';
    case 2:
      return 'assets/icons/message_2.svg';
    case 3:
      return 'assets/icons/message_3.svg';
    case 4:
      return 'assets/icons/message_4.svg';
    case 5:
      return 'assets/icons/message_5.svg';
    default:
      return 'assets/icons/message_4.svg';
  }
}

// 消息
class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final MessageStateController _messageStateController =
      Get.put(MessageStateController());

  final PageController _pageController = PageController(initialPage: 0);
  final RxInt _currentIndex = 0.obs;

  final _list = [
    '全部',
    '预警',
    '系统',
  ];

  /// 预警类消息列表（当前接口与「全部」同源，均为预警记录）
  Widget _buildAlertMessageList(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: MediaQuery.of(context).padding.top + 55,
          bottom: MediaQuery.of(context).padding.bottom + 55,
        ),
        itemCount: _messageStateController.messageData.length,
        itemBuilder: (BuildContext context, int index) {
          // 取data[index]['type']个位数的值
          final int type =
              _messageStateController.messageData[index]['type'] % 10;

          // 根据type值判断5种颜色
          Color color;
          switch (type) {
            case 1:
              color = const Color(0xffB7D6F6);
              break;
            case 2:
              color = const Color(0xffCFFBB1);
              break;
            case 3:
              color = const Color(0xffCAD6F7);
              break;
            case 4:
              color = const Color(0xffEECEAE);
              break;
            case 5:
              color = const Color(0xff5282E5);
              break;
            default:
              color = const Color(0xffE38C7F);
              break;
          }

          return Container(
            width: double.infinity,
            height: 165,
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xffF7F7F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.asset(
                              _messageIconAsset(type),
                              colorFilter: const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _messageStateController.messageData[index]
                                    ['node'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _messageStateController.messageData[index]
                                    ['typeStr'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _messageStateController.messageData[index]['content'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        _messageStateController.messageData[index]['timeShow'],
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      VoidFutureBuilder(
        future: _messageStateController.fetchMessageData(),
        builder: (context) {
          return PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _currentIndex.value = index;
            },
            children: [
              _buildAlertMessageList(context),
              _buildAlertMessageList(context),
              const Center(
                child: Text(
                  '无消息',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      Positioned(
        top: 0,
        right: 0,
        left: 0,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.top + 40,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top - 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3), // 透明度
                border: const Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 0.1,
                  ),
                ),
              ),
              child: Obx(
                () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _list.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            _currentIndex.value = _list.indexOf(item);

                            // 动画
                            _pageController.animateToPage(
                              _list.indexOf(item),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.linearToEaseOut,
                            );
                          },
                          child: AnimatedContainer(
                            padding: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      _currentIndex.value == _list.indexOf(item)
                                          ? const Color(0xff005FEB)
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              item,
                              style: TextStyle(
                                  color:
                                      _currentIndex.value == _list.indexOf(item)
                                          ? const Color(0xff005FEB)
                                          : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
