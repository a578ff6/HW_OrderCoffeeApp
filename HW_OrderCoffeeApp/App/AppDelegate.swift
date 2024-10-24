//
//  AppDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - 重點筆記：在 AppDelegate 使用 IQKeyboardManager

/*
 ## 重點筆記：在 AppDelegate 使用 IQKeyboardManager
 
 1. 集中管理鍵盤行為
    - 將 IQKeyboardManager 配置放在 AppDelegate 中，意味著它會在 App 啟動時被統一配置。
    - 這使得鍵盤管理成為全局設置， App 中所有視圖控制器的鍵盤行為會自動被管理，省去了每個控制器手動設置的麻煩。
 
 2. 自動處理鍵盤顯示和隱藏
    - 使用 IQKeyboardManager 可以自動處理鍵盤的彈出和收起，並相應地調整屏幕中輸入框的位置。這意味著在應用中使用任何輸入框時，都不需要再為每個視圖控制器設計單獨的鍵盤監聽和滾動邏輯。
    - 省略手動設置：不用再寫 setupKeyboardObservers() 來添加鍵盤顯示和隱藏的通知，或者 setUpHideKeyboardOntap() 來實現點擊空白處收起鍵盤的功能。

 3. 自動處理視圖滾動和輸入框定位
    - IQKeyboardManager 會根據鍵盤的位置，自動調整當前活動輸入框的位置，確保它們始終保持可見。這使得開發者不需要手動編寫代碼來控制滾動視圖和輸入框的位置。
    - 手動處理滾動行為可能會因鍵盤高度、視圖大小等因素變得複雜，而 IQKeyboardManager 提供了一個一致且可靠的滾動解決方案。
 
 4. 支持點擊空白區域收起鍵盤
    - 通過設置 IQKeyboardManager.shared.resignOnTouchOutside = true，可以輕鬆實現點擊空白區域收起鍵盤的功能，避免手動為每個視圖添加手勢識別器。
 
 5. 省略手動設置
    - 也因為這樣原本設計的 setUpHideKeyboardOntap()、setupKeyboardObservers()可以廢除掉。
 */

import UIKit
import UserNotifications
import Firebase
import GoogleSignIn
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 初始化 Firebase，設置 Firebase 的第一步
        FirebaseApp.configure()
        
        // 請求用戶授權發送通知
        setupNotificationAuthorization()
        // 初始化 IQKeyboardManager
        setupIQKeyboardManager()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

    /* 實現 App 委託中的 application:openURL:options: function。
     此方法應該調用 GIDSignIn 的 handleURL，該方法將對 App 在身份驗證過程結束時收到的網址進行適當處理。 */
    
    // Handle URL for Google Sign-In
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: - Private Methods
    
    /// 設置通知授權
    private func setupNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }

    /// 配置 IQKeyboardManager
    private func setupIQKeyboardManager() {
        let manager = IQKeyboardManager.shared
        manager.enable = true
        manager.resignOnTouchOutside = true         // 點擊空白處收起鍵盤
    }

}
