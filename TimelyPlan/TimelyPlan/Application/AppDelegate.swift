//
//  AppDelegate.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/10.
//

import Foundation
import FluentDarkModeKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    override init() {
        super.init()
        /// 扩展方法交换初始化
        ExtensionSwizzler.setup()
        /// 注册转换器
        registerValueTransformers()
        
        /// 初始化暗黑模式
        DarkModeManager.setup(with: DMEnvironmentConfiguration())
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
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

    // MARK: - 加载数据
    func setup() {
        AppInitializer.initialize { success in
            guard success else {
                return
            }
            
            /// 管理视图控制器的生命周期，并设置主视图控制器，
            self.window?.rootViewController?.beginAppearanceTransition(false, animated: false)
            let mainViewController = MainViewController()
            mainViewController.beginAppearanceTransition(true, animated: false)
            self.window?.rootViewController = mainViewController
            mainViewController.endAppearanceTransition()
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    // 处理前台收到的通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.sound, .banner])
        } else {
            completionHandler([.sound, .alert])
        }
    }
    
}

