import UIKit
import Flutter
import UserNotifications
import AuthenticationServices

@main
@objc class AppDelegate: FlutterAppDelegate {

    /// 设备令牌
    var deviceToken: String?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        /// 注册 Flutter 插件
        GeneratedPluginRegistrant.register(with: self)
        
        // Passkeys channel
        if let controller = window?.rootViewController as? FlutterViewController {
            PasskeyChannel.register(with: controller)
        }

        
        /// 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications permission granted")
                
                /// 在主线程中注册 APNs 推送通知
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notifications permission denied: \(String(describing: error?.localizedDescription))")
            }
        }

        /// 返回应用程序启动结果
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// 成功注册推送通知及令牌更新时，并将设备令牌发送给 Flutter
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        /// 打印设备令牌
        print("Device Token: \(token)")
        /// 保存设备令牌
        self.deviceToken = token

        /// 将设备令牌发送给 Flutter
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.fil.links/user_token", binaryMessenger: controller.binaryMessenger)
        /// 发送设备令牌
        methodChannel.invokeMethod("updateDeviceToken", arguments: token)
    }

    /// 注册推送通知失败时，打印错误信息
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
