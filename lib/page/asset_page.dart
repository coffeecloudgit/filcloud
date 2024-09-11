import 'dart:async';

import 'package:fils_link/page/setting_page.dart';
import 'package:fils_link/tool/asset_state_controller.dart';
import 'package:fils_link/tool/void_future_builder.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../package/save_data.dart';

// 资产
class AssetPage extends StatefulWidget {
  const AssetPage({super.key});

  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  Future<String?>? _userFuture;

  final AssetStateController _assetStateController =
      Get.put(AssetStateController());

  final RxString _username = ''.obs;

  final List _dataBalance = [
    {
      'svg': 'assets/icons/asset_4.svg',
      'key': 'sectorPledgeBalance',
      'title': '扇区抵押',
      'color': '0xffEB4E3D',
    },
    {
      'svg': 'assets/icons/asset_5.svg',
      'key': 'vestingFunds',
      'title': '存储锁仓',
      'color': '0xff5594F1',
    },
    {
      'svg': 'assets/icons/asset_6.svg',
      'key': 'availableBalance',
      'title': '可用余额',
      'color': '0xff65C466',
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userFuture = SaveData.getUserInfo();

    // 确保用户信息加载完成后再填充用户名
    _userFuture!.then((value) {
      if (value != null && mounted) {
        _username.value = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: MediaQuery.of(context).padding.bottom + 75,
        left: 10,
        right: 10,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  'Hi, ${_username.value}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height -
                                    MediaQuery.of(context).padding.top -
                                    60,
                                child: const SettingPage()));
                      });
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffE0E0E0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/asset_1.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xff4184EC), BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '资产估值',
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
          child: VoidFutureBuilder(
              future: _assetStateController.fetchAssetData(),
              builder: (context) {
                RxString totalRewards24H = ''.obs;

                totalRewards24H.value = (double.parse(_assetStateController
                            .assetData['totalRewards24H']) *
                        double.parse(
                            _assetStateController.assetData['newlyPrice']))
                    .toStringAsFixed(2);

                return Obx(
                  () => Row(
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
                                      color: const Color(0xffF4CDAA),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/asset_2.svg',
                                      colorFilter: const ColorFilter.mode(
                                          Colors.black, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                                const Text(
                                  '总资产',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${(double.parse(_assetStateController.assetData['balance']) * double.parse(_assetStateController.assetData['newlyPrice'])).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
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
                                      color: const Color(0xffC6D3F5),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/asset_3.svg',
                                      colorFilter: const ColorFilter.mode(
                                          Colors.black, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                                const Text(
                                  '24h新增',
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
                                Row(
                                  children: [
                                    double.parse(totalRewards24H.value) > 0 ||
                                            double.parse(
                                                    totalRewards24H.value) ==
                                                0
                                        ? Transform.rotate(
                                            angle: 3.14159,
                                            child: SvgPicture.asset(
                                              'assets/icons/node_6.svg',
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                      Color(0xff59df5a),
                                                      BlendMode.srcIn),
                                              width: 18,
                                              height: 18,
                                            ),
                                          )
                                        : SvgPicture.asset(
                                            'assets/icons/node_6.svg',
                                            colorFilter: const ColorFilter.mode(
                                                Color(0xffEB4E3D),
                                                BlendMode.srcIn),
                                            width: 18,
                                            height: 18,
                                          ),
                                    Text(
                                      '\$${totalRewards24H.value}',
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: double.parse(
                                                        totalRewards24H.value) >
                                                    0 ||
                                                double.parse(totalRewards24H
                                                        .value) ==
                                                    0
                                            ? const Color(0xff59df5a)
                                            : const Color(0xffEB4E3D),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
        const SizedBox(
          height: 30,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '资产详情',
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        VoidFutureBuilder(
          future: _assetStateController.fetchAssetData(),
          builder: (context) {
            return Obx(
              () => Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 3.5,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 5,
                            sections: [
                              PieChartSectionData(
                                radius: 15,
                                value: double.parse(_assetStateController
                                    .assetData['sectorPledgeBalance']),
                                color: const Color(0xffEB4E3D),
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                radius: 15,
                                value: double.parse(_assetStateController
                                    .assetData['vestingFunds']),
                                color: const Color(0xff5594F1),
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                radius: 15,
                                value: double.parse(_assetStateController
                                    .assetData['availableBalance']),
                                color: const Color(0xff65C466),
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  double.parse(_assetStateController
                                          .assetData['balance'])
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'FIL',
                                  style: TextStyle(
                                    color: Color(0xffACACAC),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              '账户余额',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ..._dataBalance.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            e['svg'],
                            colorFilter: ColorFilter.mode(
                              Color(int.parse(e['color'])),
                              BlendMode.srcIn,
                            ),
                            width: 35,
                            height: 35,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      e['title'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      double.parse(_assetStateController
                                              .assetData[e['key']])
                                          .toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'FIL',
                                      style: TextStyle(
                                        color: Color(0xffACACAC),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: double.parse(_assetStateController
                                          .assetData[e['key']]) /
                                      double.parse(_assetStateController
                                          .assetData['balance']),
                                  minHeight: 5,
                                  borderRadius: BorderRadius.circular(2.5),
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(int.parse(e['color'])),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
        const SizedBox(
          height: 30,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '24h出块',
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 17),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 3,
            child: VoidFutureBuilder(
                future: _assetStateController.fetchBlockData(),
                builder: (context) {
                  // 请求成功
                  RxList dataX = [].obs;
                  RxList dataY = [].obs;
                  RxDouble maxY = 0.0.obs;

                  for (var element in _assetStateController.blockData) {
                    dataX.add(element['heightTimeStr']); // string
                    dataY.add(element['blocksGrowth'].toDouble()); // double
                  }

                  // dataY 的最大值
                  maxY.value = dataY.reduce(
                      (value, element) => value > element ? value : element);

                  return Obx(
                    () => BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        minY: 0, // 设置 Y 轴的最小值
                        maxY: maxY.value + 1, // 设置 Y 轴的最大值
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (BarChartGroupData group) =>
                                Colors.transparent,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              // 显示时间和块数
                              return BarTooltipItem(
                                '${dataX[group.x.toInt()]}\n${rod.toY}',
                                const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                // 只显示 6 的倍数和 23
                                if (value.toInt() % 6 != 0 &&
                                    value.toInt() != 23) {
                                  return const SizedBox.shrink();
                                }

                                Widget text = Text(dataX[value.toInt()],
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14));

                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 16, // 调整标题与条形图的间隙
                                  child: text,
                                );
                              },
                              reservedSize: 42,
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(dataY.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: dataY[index],
                                color: const Color(0xff4677EF),
                                width: 10,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  );
                }),
          ),
        )
      ],
    );
  }
}
