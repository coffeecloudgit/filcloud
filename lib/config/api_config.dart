import 'package:flutter/foundation.dart';

/// 后端 API 根地址（不含路径，无末尾 `/`）。
///
/// - **Debug**：默认 `http://127.0.0.1:8000`（iOS 模拟器访问本机后端）。
/// - **Release**：默认线上正式环境。
///
/// 任意模式都可用编译参数覆盖，例如连到临时环境：
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000`
abstract final class ApiConfig {
  ApiConfig._();

  static const String _productionOrigin = 'https://api.coffeecloud.info';
  static const String _developmentOrigin = 'http://127.0.0.1:8000';

  static const String _dartDefineOrigin = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseOrigin {
    final override = _dartDefineOrigin.trim();
    if (override.isNotEmpty) {
      return _stripTrailingSlash(override);
    }
    return kDebugMode ? _developmentOrigin : _productionOrigin;
  }

  /// [path] 须以 `/` 开头，例如 `/api/v1/login`。
  static String resolve(String path) {
    if (!path.startsWith('/')) {
      throw ArgumentError.value(path, 'path', 'must start with /');
    }
    return '$baseOrigin$path';
  }

  static String _stripTrailingSlash(String value) {
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}
