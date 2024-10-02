import 'package:fils_link/tool/sector_state_controller.dart';
import 'package:fils_link/tool/void_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SectorPage extends StatefulWidget {
  final String nodeName;
  const SectorPage({super.key, required this.nodeName});

  @override
  State<SectorPage> createState() => _SectorPageState();
}

class _SectorPageState extends State<SectorPage> {
  late SectorStateController _sectorStateController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sectorStateController = Get.put(
      SectorStateController(nodeName: widget.nodeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扇区详情',
            style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xffF2F3F6),
        actions: [
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('完成',
                  style: TextStyle(
                      color: Color(0xff005FEB),
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ),
          )
        ],
        leading: const SizedBox(),
      ),
      backgroundColor: const Color(0xffF2F3F6),
      body: VoidFutureBuilder(
        future: _sectorStateController.fetchSectorData(),
        builder: (BuildContext context) {
          return Obx(
            () => ListView(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 20),
              children: [
                Container(
                  width: double.infinity,
                  height: 165,
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                                    color: const Color(0xffCAD6F7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/sector_1.svg',
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _sectorStateController
                                          .sectorData['miner'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _sectorStateController
                                          .sectorData['sector_size'],
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
                            const SizedBox(height: 15),
                            Text(
                              _sectorStateController
                                  .sectorData['sector_status'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['到期日', '扇区区间', '算力'].map((e) {
                    return Text(e,
                        style: const TextStyle(
                          color: Color(0xff9FA2A5),
                          fontSize: 15,
                        ));
                  }).toList(),
                ),
                const SizedBox(height: 10),
                ..._sectorStateController.sectorData['sectors'].map((e) {
                  return Container(
                    width: double.infinity,
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['day', 'fromTo', 'power'].map((i) {
                        return Text(
                          e[i],
                          style: TextStyle(
                            color: i == 'day'
                                ? Colors.black87
                                : Colors.black,
                            fontSize: i == 'power' ? 16 : 14,
                            fontWeight: i == 'power'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
