import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/http_data.dart';
import 'package:fils_link/tool/app_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_page.dart';
import 'security_center_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置',
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
              Get.back();
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
      body: ListView(
        padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.to(() => const SecurityCenterPage()),
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text('安全中心',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              HttpData.logout(Data.logoutUrl).then((value) {
                if (value) {
                  AppSession.logoutAndReset();
                  Get.offAll(() => const LoginPage());
                } else {
                  Get.snackbar('提示', '退出登录失败');
                }
              });
            },
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text('登出',
                      style: TextStyle(
                          color: Color(0xff005FEB),
                          fontSize: 22,
                          fontWeight: FontWeight.w400)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
