import 'dart:async';
import 'dart:typed_data';

import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../package/data.dart';
import '../package/http_data.dart';
import '../start/start.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

String deUuid = '';

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifyController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  Future<Uint8List>? _captchaFuture;
  Future<String?>? _userFuture;

  String? _username;
  String? _password;
  String? _verify;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _captchaFuture = HttpData.verify();
    _userFuture = SaveData.getUserInfo();

    // 确保用户信息加载完成后再填充用户名
    _userFuture!.then((value) {
      if (value != null && mounted) {
        _usernameController.text = value;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _verifyController.dispose();
    _usernameFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F1F8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: ListView(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/login_2.svg',
                          colorFilter: const ColorFilter.mode(
                              Color(0xff4184EC), BlendMode.srcIn),
                          width: 45,
                          height: 45,
                        ),
                        const Text(
                          'ilsLink',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.5),
                        focusColor: Colors.black,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入用户名';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.5),
                        focusColor: const Color(0xff005FEB),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入密码';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 160,
                          child: TextFormField(
                            controller: _verifyController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.verified_user),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.5),
                              focusColor: const Color(0xff005FEB),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入验证码';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _verify = value!;
                            },
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        FutureBuilder<Uint8List>(
                          future: _captchaFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _captchaFuture = HttpData.verify();
                                    });
                                  },
                                  child: SizedBox(
                                      height: 40,
                                      child: Image.memory(snapshot.data!)),
                                );
                              } else if (snapshot.hasError) {
                                return const Center(child: Text('Error'));
                              }
                            }
                            // By default, show a loading spinner.
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (await HttpData.loginUser(
                            _username!,
                            _password!,
                            _verify!,
                            deUuid,
                            Data.url,
                          )) {
                            // 启用推送功能
                            // AuthService.loginUser();
                            Get.offAll(() => const Start());
                          } else {
                            _passwordController.clear();
                            _verifyController.clear();
                            Get.snackbar('提示', '登录失败');
                          }
                        }
                      },
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: const Center(
                          child: Text(
                            '登录',
                            style: TextStyle(
                              color: Color(0xff005FEB),
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
