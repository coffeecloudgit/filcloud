import 'package:fils_link/config/api_config.dart';

/// 业务接口完整 URL（随 [ApiConfig] 在 Debug/Release 间切换根地址）。
class Data {
  static String get url => ApiConfig.resolve('/api/v1/login');
  static String get verifyUrl => ApiConfig.resolve('/api/v1/captcha');
  static String get slideCaptchaUrl =>
      ApiConfig.resolve('/api/v1/slide-captcha');
  static String get checkSlideCaptchaUrl =>
      ApiConfig.resolve('/api/v1/check-slide-captcha');
  static String get chartUrl =>
      ApiConfig.resolve('/api/v1/fil-pool/app-chart');
  static String get logoutUrl => ApiConfig.resolve('/api/v1/logout');
  static String get nodeUrl => ApiConfig.resolve('/api/v1/nodes-app');
  static String get totalNodeUrl =>
      ApiConfig.resolve('/api/v1/nodes-app/total');
  static String get totalAssetUrl =>
      ApiConfig.resolve('/api/v1/nodes-app/finance');
  static String get blockUrl =>
      ApiConfig.resolve('/api/v1/nodes-app/blockstats');
  static String get messageUrl => ApiConfig.resolve('/api/v1/send-msg');
  static String get homeUrl =>
      ApiConfig.resolve('/api/v1/fil-pool/app-get');
  static String get nodeNameUrl =>
      ApiConfig.resolve('/api/v1/nodes-app/:id');
  static String get nodeBlockUrl => ApiConfig.resolve('/api/v1/block');
  static String get sectorUrl =>
      ApiConfig.resolve('/api/v1/nodes-app/sectors');
  static String get getUserInfoUrl =>
      ApiConfig.resolve('/api/v1/user/getuser');
  static String get deptListUrl => ApiConfig.resolve('/api/v1/dept/list');

  // Passkey / WebAuthn
  static String get passkeyRegisterBeginUrl =>
      ApiConfig.resolve('/api/v1/passkey/register/begin');
  static String get passkeyRegisterFinishUrl =>
      ApiConfig.resolve('/api/v1/passkey/register/finish');
  static String get passkeyLoginBeginUrl =>
      ApiConfig.resolve('/api/v1/passkey/login/begin');
  static String get passkeyLoginFinishUrl =>
      ApiConfig.resolve('/api/v1/passkey/login/finish');
}
