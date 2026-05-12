import 'dart:async';

import 'package:fils_link/config/api_config.dart';
import 'package:fils_link/package/data.dart';
import 'package:fils_link/package/http_data.dart';
import 'package:fils_link/package/save_data.dart';
import 'package:fils_link/service/passkey_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../tool/app_session.dart';
import 'login_page.dart';

/// 通行密钥等安全相关能力入口。
class SecurityCenterPage extends StatefulWidget {
  const SecurityCenterPage({super.key});

  @override
  State<SecurityCenterPage> createState() => _SecurityCenterPageState();
}

class _SecurityCenterPageState extends State<SecurityCenterPage> {
  static final DateFormat _createdFormat = DateFormat('yyyy-MM-dd HH:mm');

  bool _loadingPasskeys = true;
  bool _passkeyActionBusy = false;
  List<Map<String, dynamic>> _passkeys = [];

  @override
  void initState() {
    super.initState();
    unawaited(_refreshPasskeys());
  }

  Future<void> _refreshPasskeys() async {
    setState(() => _loadingPasskeys = true);
    try {
      final res = await HttpData.passkeyCredentialsList();
      if (res['code'] == 200) {
        final data = res['data'];
        if (data is Map && data['list'] is List) {
          final raw = data['list'] as List;
          _passkeys = raw
              .map(
                (e) => Map<String, dynamic>.from(e as Map),
              )
              .toList();
        } else {
          _passkeys = [];
        }
      } else {
        _passkeys = [];
      }
    } finally {
      if (mounted) setState(() => _loadingPasskeys = false);
    }
  }

  Future<void> _addPasskey() async {
    if (_passkeyActionBusy) return;
    final username = await SaveData.getUserInfo();
    if (username == null || username.isEmpty) {
      Get.snackbar('提示', '请先重新登录');
      return;
    }
    setState(() => _passkeyActionBusy = true);
    try {
      final regBegin = await HttpData.passkeyRegisterBeginAuthed();
      if (regBegin['code'] != 200) {
        if (mounted) {
          Get.snackbar('提示', regBegin['msg']?.toString() ?? '无法开始绑定');
        }
        return;
      }
      final regPk =
          (regBegin['data'] as Map)['publicKey'] as Map<String, dynamic>;
      final cred = await PasskeyService.register(
        rpId: (regPk['rp'] as Map)['id'] as String,
        creationOptionsPublicKey: regPk,
      );
      final regFinish =
          await HttpData.passkeyRegisterFinishAuthed(username, cred);
      if (!mounted) return;
      if (regFinish['code'] == 200) {
        Get.snackbar('提示', '通行密钥已添加');
        await _refreshPasskeys();
      } else {
        Get.snackbar(
          '提示',
          regFinish['msg']?.toString() ?? '绑定未完成',
        );
      }
    } on PlatformException catch (e) {
      if (e.code != 'passkey_cancelled' && mounted) {
        Get.snackbar('提示', e.message ?? e.code);
      }
    } catch (e) {
      if (mounted) Get.snackbar('提示', '$e');
    } finally {
      if (mounted) setState(() => _passkeyActionBusy = false);
    }
  }

  String _createdSubtitle(dynamic raw) {
    if (raw == null) return '';
    final s = raw.toString().trim();
    if (s.isEmpty) return '';
    final d = DateTime.tryParse(s);
    if (d == null) return '';
    return '添加于 ${_createdFormat.format(d.toLocal())}';
  }

  Future<void> _confirmDelete(Map<String, dynamic> row) async {
    final id = (row['id'] as num?)?.toInt();
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移除通行密钥'),
        content: const Text('请先使用通行密钥再次验证，通过后方可移除，需要重新登录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('继续'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (_passkeyActionBusy) return;

    setState(() => _passkeyActionBusy = true);
    try {
      final begin = await HttpData.passkeyCredentialDeleteBegin(id);
      if (begin['code'] != 200) {
        if (mounted) {
          Get.snackbar('提示', begin['msg']?.toString() ?? '无法开始验证');
        }
        return;
      }
      final publicKey =
          (begin['data'] as Map)['publicKey'] as Map<String, dynamic>;
      final host = Uri.tryParse(ApiConfig.baseOrigin)?.host;
      final assertion = await PasskeyService.authenticate(
        rpId: (publicKey['rpId'] as String?) ?? host ?? 'localhost',
        requestOptionsPublicKey: publicKey,
      );
      if (!mounted) return;
      final finish = await HttpData.passkeyCredentialDeleteFinish(id, assertion);
      if (!mounted) return;
      if (finish['code'] != 200) {
        Get.snackbar('提示', finish['msg']?.toString() ?? '移除失败');
        return;
      }
      final rootNav = Navigator.of(context, rootNavigator: true);
      await HttpData.logout(Data.logoutUrl);
      AppSession.logoutAndReset();
      if (!mounted) return;
      rootNav.popUntil((route) => route.isFirst);
      Get.offAll(() => const LoginPage());
    } on PlatformException catch (e) {
      if (e.code != 'passkey_cancelled' && mounted) {
        Get.snackbar('提示', e.message ?? e.code);
      }
    } catch (e) {
      if (mounted) Get.snackbar('提示', '$e');
    } finally {
      if (mounted) setState(() => _passkeyActionBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '安全中心',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffF2F3F6),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xffF2F3F6),
      body: ListView(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '通行密钥',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '添加成功后可直接使用通行密钥登录',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_loadingPasskeys)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_passkeys.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '尚未绑定通行密钥',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                else
                  ..._passkeys.map((row) {
                    final name =
                        row['displayName']?.toString().trim() ?? '通行密钥';
                    final sub = _createdSubtitle(row['createdAt']);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: sub.isEmpty
                          ? null
                          : Text(
                              sub,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _passkeyActionBusy
                            ? null
                            : () => unawaited(_confirmDelete(row)),
                        tooltip: '移除',
                      ),
                    );
                  }),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _passkeyActionBusy
                        ? null
                        : () => unawaited(_addPasskey()),
                    child: _passkeyActionBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('添加通行密钥'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
