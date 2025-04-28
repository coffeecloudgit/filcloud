import 'package:fils_link/tool/home_state_controller.dart';
import 'package:fils_link/tool/void_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeStateController _homeStateController =
      Get.put(HomeStateController());

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: MediaQuery.of(context).padding.top,
        ),
        children: [
          Obx(() => _homeStateController.isAdmin.value
              ? const Padding(
            padding: EdgeInsets.only(
              left: 8,
              bottom: 10,
              right: 8,
            ),
            child: Text(
              '高级管理',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : const SizedBox.shrink()),
          // 管理员面板 - 只有管理员可见
          Obx(() => _homeStateController.isAdmin.value
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 30),
                  padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(() {
                    if (_homeStateController.deptList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final deptList = _homeStateController.deptList;
                    final selectedDeptId = _homeStateController.selectedDeptId.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 部门选择标题行
                        // const Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Icon(
                        //       Icons.business_center,
                        //       color: Color(0xFF4677EF),
                        //       size: 18,
                        //     ),
                        //     SizedBox(width: 8),
                        //     Text(
                        //       '部门选择',
                        //       style: TextStyle(
                        //         fontSize: 17,
                        //         fontWeight: FontWeight.w700,
                        //         color: Colors.black,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 4),
                        // 部门列表
                        ...deptList.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final dept = entry.value;
                          final int deptId = dept['deptId'];
                          final String deptName = dept['deptName'] ?? '';

                          return InkWell(
                            onTap: () => _homeStateController.selectDept(deptId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: index < deptList.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 0.5,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      deptName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // 真正的 iOS 风格开关
                                  CupertinoSwitch(
                                    value: selectedDeptId == deptId,
                                    onChanged: (value) {
                                      if (value) {
                                        _homeStateController.selectDept(deptId);
                                      }
                                    },
                                    activeColor: Colors.blue,
                                    // 不需要设置边框，CupertinoSwitch 默认就没有边框
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }),
                )
              : const SizedBox.shrink()),
              // 结束
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '挖矿统计',
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
              height: (MediaQuery.of(context).size.width) / 2,
              child: VoidFutureBuilder(
                future: _homeStateController.fetchHomeData(),
                builder: (context) {
                  return Container(
                    width: double.infinity,
                    height: (MediaQuery.of(context).size.width) / 2,
                    decoration: BoxDecoration(
                      color: const Color(0xff3379F7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            left: 20,
                            right: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '总算力',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'FIL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(width: 20),
                            Obx(() => Text(
                                  _homeStateController
                                      .homeData['qualityAdjPower'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const SizedBox(width: 10),
                            const Text(
                              'PiB',
                              style: TextStyle(
                                color: Color(0xffACACAC),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: (MediaQuery.of(context).size.width) / 8,
                            color: Colors.white.withOpacity(0.3),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                SvgPicture.asset(
                                  'assets/icons/home_2.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Obx(() => Text(
                                      '节点数：${_homeStateController.homeData['nodesCount']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '货币价格',
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
                                  color: const Color(0xffCCD6F4),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/home_3.svg',
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const Text(
                              '价格',
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
                                future: _homeStateController.fetchFilPrice(),
                                builder: (context) {
                                  return Obx(
                                    () {
                                      return Text(
                                        _homeStateController
                                            .filPrice['newlyPrice']
                                            .toStringAsFixed(2),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  );
                                }),
                            const SizedBox(width: 8),
                            const Text(
                              'USD',
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
                                  'assets/icons/home_4.svg',
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const Text(
                              '24h涨跌',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        VoidFutureBuilder(
                            future: _homeStateController.fetchFilPrice(),
                            builder: (context) {
                              return Obx(
                                () {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          _homeStateController.filPrice[
                                                          'percentChange'] >
                                                      0 ||
                                                  _homeStateController.filPrice[
                                                          'percentChange'] ==
                                                      0
                                              ? Transform.rotate(
                                                  angle: 3.14159,
                                                  child: SvgPicture.asset(
                                                    'assets/icons/home_5.svg',
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                            Color(0xff59df5a),
                                                            BlendMode.srcIn),
                                                    width: 25,
                                                    height: 25,
                                                  ),
                                                )
                                              : SvgPicture.asset(
                                                  'assets/icons/home_5.svg',
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                          Color(0xffEB4E3D),
                                                          BlendMode.srcIn),
                                                  width: 25,
                                                  height: 25,
                                                ),
                                          Text(
                                            _homeStateController
                                                .filPrice['percentChange']
                                                .toString(),
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: _homeStateController
                                                                  .filPrice[
                                                              'percentChange'] >
                                                          0 ||
                                                      _homeStateController
                                                                  .filPrice[
                                                              'percentChange'] ==
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
                                      const Text(
                                        '%',
                                        style: TextStyle(
                                          color: Color(0xffACACAC),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              )),
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
                                  color: const Color(0xffEECEAE),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/home_6.svg',
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const Text(
                              '\$ 1 =',
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
                                future: _homeStateController.fetchFilPrice(),
                                builder: (context) {
                                  return Obx(() {
                                    return Text(
                                      _homeStateController.filPrice['cnyRate']
                                          .toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  });
                                }),
                            const SizedBox(width: 8),
                            const Text(
                              'CNY',
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
                                  color: const Color(0xffB7D6F6),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/home_7.svg',
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const Text(
                              '24h成交',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        VoidFutureBuilder(
                            future: _homeStateController.fetchFilPrice(),
                            builder: (context) {
                              return Obx(
                                () => Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _homeStateController
                                              .filPrice['flowTotal'],
                                          maxLines: 2,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'CNY',
                                      style: TextStyle(
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '算力图表',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Container(
                width: double.infinity,
                height: 350,
                padding: const EdgeInsets.only(
                  left: 0,
                  right: 20,
                  top: 10,
                  bottom: 20,
                ),
                child: VoidFutureBuilder(
                  future: _homeStateController.fetchCaptchaData(),
                  builder: (context) {
                    RxList dataX = [].obs;
                    RxList dataY = [].obs;
                    RxDouble maxY = 0.0.obs;

                    for (var element in _homeStateController.captchaData) {
                      dataX.add(element['x']); // 字符串
                      dataY.add(element['y'].toDouble());
                    }

                    // dataY 的最大值
                    maxY.value = dataY.reduce((value, element) {
                      return value > element ? value : element;
                    });

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          verticalInterval: 6,
                          getDrawingVerticalLine: (value) {
                            return const FlLine(
                              color: Color(0xffE1E1E1),
                              strokeWidth: 0.5,
                            );
                          },
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Color(0xffE1E1E1),
                              strokeWidth: 0.5,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 6,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                Widget text = Text(dataX[value.toInt()],
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14));

                                return SideTitleWidget(
                                  axisSide: meta.axisSide, // 轴线的位置
                                  space: 16, // 调整标题与条形图的间隙
                                  child: text,
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 40,
                              interval: 25,
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 10,
                                  child: Text(
                                    meta.formattedValue,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Color(0xffE1E1E1),
                              width: 0.5,
                            ),
                            top: BorderSide(
                              color: Color(0xffE1E1E1),
                              width: 0.5,
                            ),
                          ),
                        ),
                        minY: 0,
                        maxY: (maxY / 25).ceil() * 25 + 25,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (spot) => Colors.transparent,
                            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                              return lineBarsSpot.map((lineBarSpot) {
                                // 时间
                                final time = dataX[lineBarSpot.x.toInt()];

                                return LineTooltipItem(
                                  '$time\n${lineBarSpot.y.toStringAsFixed(2)}',
                                  const TextStyle(
                                    color: Color(0xff5594F1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: dataY
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: const Color(0xff63B6F6),
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xffAFD2FC).withOpacity(0.6),
                                    const Color(0xffAFD2FC).withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )),
        ]);
  }
}
