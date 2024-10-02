import 'dart:async';
import 'dart:core';
import 'dart:ui';

import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/node_data.dart';
import 'package:fils_link/page/sector_page.dart';
import 'package:fils_link/tool/void_future_builder.dart';
import 'package:fils_link/tool/node_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../tool/sector_state_controller.dart';

class NodePage extends StatefulWidget {
  const NodePage({super.key});

  @override
  State<NodePage> createState() => _NodePageState();
}

class _NodePageState extends State<NodePage> {
  final NodeStateController _nodeStateController =
      Get.put(NodeStateController(currentIndex: 0));

  final PageController _pageController = PageController(initialPage: 0);
  final RxInt _currentPage = 0.obs;

  final List _title = [
    '节点',
    '余额',
    '算力',
    '收益',
  ];

  final List _blockTitle = [
    '高度',
    '节点',
    '时间',
  ];

  final List _list = [
    '节点列表',
    '孤块列表',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 10,
        right: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '节点算力',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
              width: double.infinity,
              height: (MediaQuery.of(context).size.width) / 2 - 15,
              child: Row(
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width) / 2 - 15,
                    height: (MediaQuery.of(context).size.width) / 2 - 15,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F1F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                width: 50,
                                height: 50,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xffAFD7F9),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/node_3.svg',
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const Text(
                              '总算力',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            VoidFutureBuilder(
                                future:
                                    _nodeStateController.fetchTotalNodeData(),
                                builder: (context) {
                                  return Obx(
                                    () => Text(
                                      _nodeStateController
                                          .totalNodeData['qualityAdjPower'],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }),
                            const SizedBox(width: 8),
                            const Text(
                              'PiB',
                              style: TextStyle(
                                color: Color(0xffACACAC),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width) / 2 - 15,
                    height: (MediaQuery.of(context).size.width) / 2 - 15,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F1F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                width: 50,
                                height: 50,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xffC3FDA9),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/node_5.svg',
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const Text(
                              '24h增量',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        VoidFutureBuilder(
                            future: _nodeStateController.fetchTotalNodeData(),
                            builder: (context) {
                              return Obx(
                                () => Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        double.parse(_nodeStateController
                                                            .totalNodeData[
                                                        'qualityAdjPowerDelta24H']) >
                                                    0 ||
                                                double.parse(_nodeStateController
                                                            .totalNodeData[
                                                        'qualityAdjPowerDelta24H']) ==
                                                    0
                                            ? Transform.rotate(
                                                angle: 3.14159,
                                                child: SvgPicture.asset(
                                                  'assets/icons/node_6.svg',
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                          Color(0xff59df5a),
                                                          BlendMode.srcIn),
                                                  width: 22,
                                                  height: 22,
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                'assets/icons/node_6.svg',
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        Color(0xffEB4E3D),
                                                        BlendMode.srcIn),
                                                width: 22,
                                                height: 22,
                                              ),
                                        Text(
                                          _nodeStateController.totalNodeData[
                                              'qualityAdjPowerDelta24H'],
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: double.parse(_nodeStateController
                                                                .totalNodeData[
                                                            'qualityAdjPowerDelta24H']) >
                                                        0 ||
                                                    double.parse(_nodeStateController
                                                                .totalNodeData[
                                                            'qualityAdjPowerDelta24H']) ==
                                                        0
                                                ? const Color(0xff59df5a)
                                                : const Color(0xffEB4E3D),
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _nodeStateController
                                          .totalNodeData['powerDeltaUnit'],
                                      style: const TextStyle(
                                        color: Color(0xffACACAC),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 30),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _list.map((e) {
                return InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    _pageController.animateToPage(
                      _list.indexOf(e),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    _currentPage.value = _list.indexOf(e);
                    _nodeStateController.currentIndex = _list.indexOf(e);
                  },
                  child: AnimatedContainer(
                    width: _currentPage.value == _list.indexOf(e)
                        ? MediaQuery.of(context).size.width / 2.5
                        : MediaQuery.of(context).size.width / 4,
                    height: 50,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: _currentPage.value == _list.indexOf(e)
                          ? const Color(0xff4677EF)
                          : const Color(0xff4677EF).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    duration: const Duration(milliseconds: 300),
                    child: Center(
                      child: Text(
                        e,
                        style: TextStyle(
                          color: _currentPage.value == _list.indexOf(e)
                              ? Colors.white
                              : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _currentPage.value = index;
                _nodeStateController.currentIndex = index;
              },
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _title.map((e) {
                            return Text(e,
                                style: const TextStyle(
                                  color: Color(0xff9FA2A5),
                                  fontSize: 15,
                                ));
                          }).toList()),
                    ),
                    Expanded(
                      child: VoidFutureBuilder(
                          future: _nodeStateController.fetchNodeData(),
                          builder: (context) {
                            return Obx(() => ListView(
                                  padding: EdgeInsets.only(
                                    top: 0,
                                    right: 0,
                                    left: 0,
                                    bottom:
                                        MediaQuery.of(context).padding.bottom +
                                            75,
                                  ),
                                  children:
                                      _nodeStateController.nodeData.map((e) {
                                    return Container(
                                      width: double.infinity,
                                      height: 100,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF1F1F6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e['node'],
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  final formKey =
                                                      GlobalKey<FormState>();
                                                  TextEditingController
                                                      controller =
                                                      TextEditingController(
                                                          text: e['title']);

                                                  showGeneralDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    barrierLabel: '修改',
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.2),
                                                    transitionDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    pageBuilder: (context,
                                                        animation1,
                                                        animation2) {
                                                      return Center(
                                                        child: Material(
                                                          type: MaterialType
                                                              .transparency,
                                                          child: ListView(
                                                            padding:
                                                                EdgeInsets.only(
                                                              top: MediaQuery.of(
                                                                          context)
                                                                      .padding
                                                                      .top +
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      4 -
                                                                  20,
                                                              left: 30,
                                                              right: 30,
                                                            ),
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter: ImageFilter
                                                                      .blur(
                                                                          sigmaX:
                                                                              50,
                                                                          sigmaY:
                                                                              50),
                                                                  child:
                                                                      Container(
                                                                    height: 170,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.6),
                                                                    ),
                                                                    child: Form(
                                                                        key:
                                                                            formKey,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.stretch,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                                                                child: Center(
                                                                                  child: TextFormField(
                                                                                    controller: controller,
                                                                                    focusNode: FocusNode(),
                                                                                    decoration: InputDecoration(
                                                                                      prefixIcon: const Icon(Icons.edit),
                                                                                      filled: true,
                                                                                      fillColor: Colors.grey.withOpacity(0.5),
                                                                                      focusColor: Colors.black,
                                                                                      border: const OutlineInputBorder(
                                                                                        borderSide: BorderSide.none,
                                                                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                                      ),
                                                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                                                    ),
                                                                                    validator: (value) {
                                                                                      if (value == null) {
                                                                                        return '请输入节点名称';
                                                                                      }
                                                                                      return null;
                                                                                    },
                                                                                    onSaved: (value) {
                                                                                      // e['title'] = value!;
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                '取消',
                                                                                '确定'
                                                                              ].map((i) {
                                                                                return InkWell(
                                                                                  onTap: i == '确定'
                                                                                      ? () async {
                                                                                          if (formKey.currentState!.validate()) {
                                                                                            formKey.currentState!.save();
                                                                                            if (await NodeData.changeNodeName(Data.nodeNameUrl, e['id'].toString(), controller.text)) {
                                                                                              Get.back();
                                                                                              Get.snackbar(
                                                                                                '提示',
                                                                                                '修改成功',
                                                                                              );
                                                                                              _nodeStateController.fetchNodeData();
                                                                                            } else {
                                                                                              Get.snackbar('提示', '修改失败');
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      : () {
                                                                                          Get.back(); // 取消
                                                                                        },
                                                                                  splashColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  child: Container(
                                                                                    width: MediaQuery.of(context).size.width / 2 - 30,
                                                                                    height: 50,
                                                                                    decoration: BoxDecoration(
                                                                                      border: i == '确定'
                                                                                          ? const Border(
                                                                                              top: BorderSide(color: Color(0xffCCCCCC), width: 0.5),
                                                                                              left: BorderSide(color: Color(0xffCCCCCC), width: 0.25),
                                                                                            )
                                                                                          : const Border(
                                                                                              top: BorderSide(color: Color(0xffCCCCCC), width: 0.5),
                                                                                              right: BorderSide(color: Color(0xffCCCCCC), width: 0.25),
                                                                                            ),
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        i,
                                                                                        style: TextStyle(
                                                                                          color: const Color(0xff005FEB),
                                                                                          fontSize: 20,
                                                                                          fontWeight: i == '确定' ? FontWeight.w400 : FontWeight.bold,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      e['title'],
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xffACACAC),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    SvgPicture.asset(
                                                      'assets/icons/node_4.svg',
                                                      colorFilter:
                                                          const ColorFilter
                                                              .mode(
                                                              Color(0xffACACAC),
                                                              BlendMode.srcIn),
                                                      width: 16,
                                                      height: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    e['syncStatus']
                                                        ? 'assets/icons/node_1.svg'
                                                        : 'assets/icons/node_2.svg',
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                            e['syncStatus']
                                                                ? const Color(
                                                                    0xff65C466)
                                                                : const Color(
                                                                    0xffEB4E3D),
                                                            BlendMode.srcIn),
                                                    width: 12,
                                                    height: 12,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    e['syncStatus']
                                                        ? e['height'].toString()
                                                        : '断开监控',
                                                    style: TextStyle(
                                                      color: e['syncStatus']
                                                          ? const Color(
                                                              0xff65C466)
                                                          : const Color(
                                                              0xffEB4E3D),
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              'availableBalance',
                                              'balance'
                                            ].map((i) {
                                              return Text(
                                                e[i],
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ...[
                                                'qualityAdjPower',
                                                'qualityAdjPowerDelta24h'
                                              ].map((i) {
                                                // 单位
                                                List unit = [
                                                  'powerUnit',
                                                  'powerDeltaUnit'
                                                ];

                                                return Text(
                                                  e[i] +
                                                      ' ' +
                                                      e[unit[[
                                                        'qualityAdjPower',
                                                        'qualityAdjPowerDelta24h'
                                                      ].indexOf(i)]],
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                );
                                              }),
                                              InkWell(
                                                onTap: () {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (context) {
                                                        return ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              topRight: Radius
                                                                  .circular(20),
                                                            ),
                                                            child: SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height -
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .padding
                                                                        .top -
                                                                    60,
                                                                child:
                                                                    SectorPage(
                                                                  nodeName:
                                                                      e['node'],
                                                                )));
                                                      }).whenComplete(
                                                    // 确保在 BottomSheet 关闭时，销毁控制器
                                                    () {
                                                      Get.delete<
                                                          SectorStateController>();
                                                    },
                                                  );
                                                },
                                                highlightColor:
                                                    Colors.transparent,
                                                splashColor: Colors.transparent,
                                                child: const Text(
                                                  '扇区详情',
                                                  style: TextStyle(
                                                    color: Color(0xff005FEB),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              'miningEfficiency',
                                              'rewardValue'
                                            ].map((i) {
                                              // 单位
                                              List unit = ['FIL/PiB', 'FIL'];

                                              return Text(
                                                e[i] +
                                                    ' ' +
                                                    unit[[
                                                      'miningEfficiency',
                                                      'rewardValue'
                                                    ].indexOf(i)],
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ));
                          }),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _blockTitle.map((e) {
                            return Text(e,
                                style: const TextStyle(
                                  color: Color(0xff9FA2A5),
                                  fontSize: 15,
                                ));
                          }).toList()),
                    ),
                    Expanded(
                      child: VoidFutureBuilder(
                          future: _nodeStateController.fetchNodeBlockData(),
                          builder: (context) {
                            return Obx(() => ListView(
                                  padding: EdgeInsets.only(
                                    top: 0,
                                    right: 0,
                                    left: 0,
                                    bottom:
                                        MediaQuery.of(context).padding.bottom +
                                            75,
                                  ),
                                  children:
                                      _nodeStateController.blockData.map((e) {
                                    return Container(
                                      width: double.infinity,
                                      height: 60,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF1F1F6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          'height',
                                          'node',
                                          'blockTime'
                                        ].map((i) {
                                          // 在blockTime中间插入换行符
                                          if (i == 'blockTime') {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  e[i].substring(0, 10),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  e[i].substring(11),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                )
                                              ],
                                            );
                                          }

                                          return Text(
                                            e[i].toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: i == 'height'
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  }).toList(),
                                ));
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
