//
//  AppDelegate.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit
import AppsFlyerLib
import AppTrackingTransparency
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging
@main
class AppDelegate: UIResponder, UIApplicationDelegate ,AppsFlyerLibDelegate, UNUserNotificationCenterDelegate {

    private var didStartAF = false
    private func startAppsFlyerOnce() {
        guard !didStartAF else { return }
        didStartAF = true
        AppsFlyerLib.shared().start() // 只启动一次
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.isEnabled = true

        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = UIViewController.getAppsFlyerDevKey()
        appsFlyer.appleAppID = "6754586368"
        appsFlyer.delegate = self
        
        if #available(iOS 14, *) {
            appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        }
        FirebaseApp.configure()
               
               requestPushPermission()
               return true
    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    private func requestPushPermission() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([[.sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }
        
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("success appsflyer")
    }
    
    func onConversionDataFail(_ error: Error) {
        print("error appsflyer")
    }
    func requestATTAndStartIfNeeded() {
        if #available(iOS 14, *) {
            DispatchQueue.main.async {
                ATTrackingManager.requestTrackingAuthorization { _ in
                    // 无论授权与否，都启动 AF（AF 内部会根据状态/超时决定是否带 IDFA）
                    self.startAppsFlyerOnce()
                }
            }
        } else {
            // iOS13- 直接启动
            startAppsFlyerOnce()
        }
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

