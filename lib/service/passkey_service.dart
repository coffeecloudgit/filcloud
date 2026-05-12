import 'dart:convert';

import 'package:flutter/services.dart';

/// iOS Passkeys bridge (AuthenticationServices).
///
/// 冷启动后首次调用时，系统偶发 `passkey_transient`（关联 webcredentials 域名），在此层自动重试，
/// 尽量无感，无需用户再点一次。
class PasskeyService {
  static const MethodChannel _channel =
      MethodChannel('com.fil.links/passkey');

  /// 含首次调用在内最多尝试次数。
  static const int _transientMaxAttempts = 4;

  static Future<void> _delayTransientBackoff(int failedAttemptIndex) async {
    await Future<void>.delayed(
      Duration(milliseconds: 350 + failedAttemptIndex * 450),
    );
  }

  static Future<Map<String, dynamic>> register({
    required String rpId,
    required Map<String, dynamic> creationOptionsPublicKey,
  }) async {
    for (var attempt = 0; attempt < _transientMaxAttempts; attempt++) {
      try {
        final result = await _channel.invokeMethod<String>(
          'register',
          <String, dynamic>{
            'rpId': rpId,
            'publicKey': creationOptionsPublicKey,
          },
        );
        if (result == null) {
          throw PlatformException(code: 'passkey_null', message: 'null result');
        }
        return jsonDecode(result) as Map<String, dynamic>;
      } on PlatformException catch (e) {
        final last = attempt == _transientMaxAttempts - 1;
        if (e.code != 'passkey_transient' || last) {
          rethrow;
        }
        await _delayTransientBackoff(attempt);
      }
    }
    throw StateError('passkey register');
  }

  static Future<Map<String, dynamic>> authenticate({
    required String rpId,
    required Map<String, dynamic> requestOptionsPublicKey,
  }) async {
    for (var attempt = 0; attempt < _transientMaxAttempts; attempt++) {
      try {
        final result = await _channel.invokeMethod<String>(
          'authenticate',
          <String, dynamic>{
            'rpId': rpId,
            'publicKey': requestOptionsPublicKey,
          },
        );
        if (result == null) {
          throw PlatformException(code: 'passkey_null', message: 'null result');
        }
        return jsonDecode(result) as Map<String, dynamic>;
      } on PlatformException catch (e) {
        final last = attempt == _transientMaxAttempts - 1;
        if (e.code != 'passkey_transient' || last) {
          rethrow;
        }
        await _delayTransientBackoff(attempt);
      }
    }
    throw StateError('passkey authenticate');
  }
}
