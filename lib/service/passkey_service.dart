import 'dart:convert';

import 'package:flutter/services.dart';

/// iOS Passkeys bridge (AuthenticationServices).
class PasskeyService {
  static const MethodChannel _channel =
      MethodChannel('com.fil.links/passkey');

  static Future<Map<String, dynamic>> register({
    required String rpId,
    required Map<String, dynamic> creationOptionsPublicKey,
  }) async {
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
  }

  static Future<Map<String, dynamic>> authenticate({
    required String rpId,
    required Map<String, dynamic> requestOptionsPublicKey,
  }) async {
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
  }
}

