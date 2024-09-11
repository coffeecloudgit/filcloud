import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/home_data.dart';
import 'package:fils_link/package/http_data.dart';
import 'package:fils_link/tool/home_state_controller.dart';
import 'package:fils_link/tool/void_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List>? _captchaFuture;
  Future<Map>? _homeFuture;

  final HomeStateController _homeStateController =
      Get.put(HomeStateController());

  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _captchaFuture = HttpData.getChartData(Data.chartUrl);
    _homeFuture = HomeData.getHomeData(Data.homeUrl);

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _captchaFuture = HttpData.getChartData(Data.chartUrl);
        _homeFuture = HomeData.getHomeData(Data.homeUrl);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 取消定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: MediaQuery.of(context).padding.top,
        ),
        children: [
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
                            Text(
                              _homeStateController.homeData['qualityAdjPower'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                Text(
                                  '节点数：${_homeStateController.homeData['nodesCount']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
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
              '算力图表',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
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
          ),
        ]);
  }
}
