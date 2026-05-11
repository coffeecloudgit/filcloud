import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fils_link/package/http_data.dart';

/// 一次滑块挑战的全部数据（图像 + 原生像素几何 + key）。
///
/// 「原生」指 go-captcha 后端生成的底图像素坐标系（默认 300×220）。
class SlideCaptchaChallenge {
  SlideCaptchaChallenge({
    required this.key,
    required this.masterBytes,
    required this.tileBytes,
    required this.masterW,
    required this.masterH,
    required this.tileW,
    required this.tileH,
    required this.initialTileX,
    required this.tileY,
  });

  final String key;
  final Uint8List masterBytes;
  final Uint8List tileBytes;

  /// 底图原始像素宽 / 高。
  final int masterW;
  final int masterH;

  /// 拼图块原始像素宽 / 高。
  final int tileW;
  final int tileH;

  /// 拼图块出生位置（左上角）X，原生像素坐标系。
  final int initialTileX;

  /// 拼图块需要落到的目标 Y（ModeBasic 下与缺口 Y 一致）。原生像素坐标系。
  final int tileY;

  /// 拖动允许的最大 X，即「贴右边时」的左上角。原生像素。
  int get maxTileX => (masterW - tileW).clamp(0, masterW);
}

/// 抽掉 HTTP / 解码 / 校验，让 widget 只关心绘制与手势。
abstract final class SlideCaptchaService {
  SlideCaptchaService._();

  /// 拉取一次新挑战；同时解码出底图与拼图块的原始像素尺寸。
  static Future<SlideCaptchaChallenge> load() async {
    final json = await HttpData.fetchSlideCaptcha();
    final key = json['captcha_key'] as String?;
    final masterB64 = json['image_base64'] as String?;
    final tileB64 = json['tile_base64'] as String?;
    if (key == null || masterB64 == null || tileB64 == null) {
      throw const SlideCaptchaException('滑块验证码返回数据不完整');
    }

    final masterBytes = _decodeBase64Image(masterB64);
    final tileBytes = _decodeBase64Image(tileB64);

    final masterSize = await _decodeSize(masterBytes);
    final tileFallback = await _decodeSize(tileBytes);

    final tileW = (json['tile_width'] as num?)?.toInt() ?? tileFallback.$1;
    final tileH = (json['tile_height'] as num?)?.toInt() ?? tileFallback.$2;
    final initialTileX = (json['tile_x'] as num?)?.toInt() ?? 0;
    final tileY = (json['tile_y'] as num?)?.toInt() ?? 0;

    return SlideCaptchaChallenge(
      key: key,
      masterBytes: masterBytes,
      tileBytes: tileBytes,
      masterW: masterSize.$1,
      masterH: masterSize.$2,
      tileW: tileW,
      tileH: tileH,
      initialTileX: initialTileX,
      tileY: tileY,
    );
  }

  /// 上送 `(nativeX, nativeY)` 给后端做 ±4 px 校验。
  static Future<bool> verify({
    required String key,
    required int nativeX,
    required int nativeY,
  }) {
    return HttpData.checkSlideCaptcha(
      key: key,
      pointX: nativeX,
      pointY: nativeY,
    );
  }

  static Uint8List _decodeBase64Image(String raw) {
    var s = raw.trim();
    if (s.contains(',')) {
      s = s.split(',')[1];
    }
    return base64.decode(s);
  }

  static Future<(int, int)> _decodeSize(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final w = frame.image.width;
    final h = frame.image.height;
    frame.image.dispose();
    return (w, h);
  }
}

class SlideCaptchaException implements Exception {
  const SlideCaptchaException(this.message);
  final String message;

  @override
  String toString() => message;
}
