import UIKit
import Flutter
import UserNotifications

/// `AppDelegate` 类继承自 `FlutterAppDelegate`，并负责管理 iOS 应用的生命周期，
/// 同时处理推送通知和与 Flutter 之间的通信。
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    /// 用于存储用户登录时从 Flutter 传递过来的用户身份令牌（User Token）。
    var userToken: String?
    /// 设备的 APNs 令牌，缓存起来等待用户登录后发送。
    var deviceToken: String?

    /// 应用启动时被系统调用。此方法用于配置推送通知和初始化与 Flutter 的通信通道。
    /// - Parameters:
    ///   - application: 当前正在运行的应用实例。
    ///   - launchOptions: 应用启动时的选项字典，例如从 URL 启动应用的信息。
    /// - Returns: 如果应用启动成功则返回 `true`。
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        /// 尝试从 UserDefaults 中获取设备令牌
        if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") {
            /// 如果设备令牌存在，则将其存储在 `deviceToken` 变量中。
            self.deviceToken = savedDeviceToken
            print("Device token found: \(savedDeviceToken)")
        }

        /// 设置 Flutter 与 iOS 原生代码之间的通信通道，用于传递用户 Token 和控制推送通知。
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.file.monitor/user_token", binaryMessenger: controller.binaryMessenger)

        /// 监听 Flutter 端发送的消息，并处理接收到的不同方法调用（例如设置用户 Token，启用或禁用推送通知）。
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "setUserToken" {
                /// 当 Flutter 请求设置用户 Token 时，将 Token 存储在 `userToken` 变量中，并启用推送通知。
                if let arguments = call.arguments as? [String: Any], let token = arguments["token"] as? String {
                    self?.userToken = token
                    print("Received user token: \(token)")
                    self?.enablePushNotifications()
                }
            } else if call.method == "disablePushNotifications" {
                /// 当 Flutter 请求禁用推送通知时，调用相应的函数禁用。
                self?.disablePushNotifications()
            } else if call.method == "enablePushNotifications" {
                /// 当 Flutter 请求重新启用推送通知时，调用相应的函数启用。
                self?.enablePushNotifications()
            }
        }

        /// 设置通知中心的代理为当前类，以便处理前台通知和其他推送通知事件。
        UNUserNotificationCenter.current().delegate = self

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// 启用推送通知，注册设备以接收 APNs 推送通知。
    func enablePushNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
        print("Push notifications have been enabled")
    }

    /// 禁用推送通知，取消设备的 APNs 注册，使其不再接收推送通知。
    func disablePushNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
        print("Push notifications have been disabled")
    }

    /// 当设备成功注册推送通知时，系统会调用此方法，并返回设备的 APNs 令牌。
    /// - Parameters:
    ///   - application: 当前正在运行的应用实例。
    ///   - deviceToken: 注册成功后，系统分配的设备 APNs 令牌。
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /// 将设备令牌（`deviceToken`）转换为字符串格式以便后续处理。
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        /// 缓存设备令牌，等待用户登录后发送到服务器。
        UserDefaults.standard.set(token, forKey: "deviceToken")
        self.deviceToken = token

        /// 当用户已登录并且 `userToken` 已设置时，将设备令牌与用户令牌一起发送到服务器。
        if let userToken = self.userToken {
            sendTokenToServer(userToken: userToken, deviceToken: token)
        }
    }

    /// 将用户的 APNs 设备令牌和用户 Token 发送到服务器进行关联和保存。
    /// - Parameters:
    ///   - userToken: 用户登录时生成的身份认证令牌。
    ///   - deviceToken: 设备在 APNs 注册时生成的设备令牌。
    func sendTokenToServer(userToken: String, deviceToken: String) {
        /// 设置要发送设备令牌的服务器 URL。
        guard let url = URL(string: "http://116.92.243.5:8000/api/v1/user/device_token") else {
            print("Invalid URL")
            return
        }

        /// 创建 HTTP 请求并设置请求头（包括认证令牌）和请求体。
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        /// 请求体包含设备令牌，以 JSON 格式发送到服务器。
        let body: [String: String] = [
            "deviceToken": deviceToken
        ]

        /// 将请求体编码为 JSON 数据格式。
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Failed to encode JSON")
            return
        }
        request.httpBody = httpBody

        /// 使用 URLSession 发送 HTTP 请求，并处理响应和错误。
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token: \(error)")
                return
            }

            /// 处理来自服务器的响应数据并输出状态码。
            guard let data = data else {
                print("No data received")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status: \(httpResponse.statusCode)")
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("Response data: \(jsonResponse)")
            }
        }

        /// 启动 HTTP 请求任务。
        task.resume()
    }

    /// 当设备注册推送通知失败时，系统会调用此方法，并返回错误信息。
    /// - Parameters:
    ///   - application: 当前正在运行的应用实例。
    ///   - error: 注册过程中发生的错误信息。
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error.localizedDescription)")
    }

    /// 当应用在前台运行时收到推送通知时，系统会调用此方法以展示通知。
    /// - Parameters:
    ///   - center: 当前的通知中心。
    ///   - notification: 收到的通知对象。
    ///   - completionHandler: 用于处理通知展示的回调，指定展示选项。
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        /// 指定通知在应用前台时的展示选项（如声音、徽章、警告框）。
        completionHandler([.alert, .badge, .sound])
    }
}