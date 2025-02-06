//
//  SplashViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/2/3.
//

// MARK: - SplashViewController 筆記
/**
 
 ### SplashViewController 筆記

 
` * What`
 
 - `SplashViewController` **負責管理應用程式的啟動畫面**，顯示 `SplashView` 並播放 Lottie 動畫。
 - 當動畫播放結束時，通知 `SceneDelegate` 來**切換 `rootViewController`**。
 - `SplashViewController` 不直接變更 `rootViewController`，而是讓 `SceneDelegate` 負責畫面切換，確保 `ViewController` 只關注 UI 與動畫邏輯。

 --------

 `* Why`
 
 1. 職責架構
 
 - View（`SplashView`）
 
   - 只負責 UI 顯示與動畫播放，不涉及業務邏輯。
 
 - Controller（`SplashViewController`）
 
   - 負責管理動畫邏輯，監聽動畫結束事件，不直接處理 `rootViewController` 切換。
 
 - App 管理層（`SceneDelegate`）
 
   - 負責 `rootViewController` 的變更，確保畫面切換統一管理。

 2. 符合單一職責原則（SRP）
 
 - `SplashViewController` 只專注於 UI 動畫邏輯，它不應該負責決定應用程式的 `rootViewController`。
 - `SceneDelegate` 負責 `rootViewController` 切換，確保所有畫面轉場邏輯集中管理。

 3. 提高可維護性
 
    - 未來若要更換 `HomePageViewController` 或 `MainTabBarController`，只需修改 `SceneDelegate`，不影響 `SplashViewController`。
    - 確保 `SplashViewController` 只管理動畫，與畫面切換的業務邏輯解耦，降低耦合度，提高靈活性。

 --------

` * How`
 
 1. `SplashViewController` 只負責動畫播放
 
     ```swift
     import UIKit

     /// `SplashViewController` 負責管理啟動畫面邏輯
     ///
     /// - 主要職責是顯示 `SplashView`，並在動畫播放完畢後執行轉場邏輯。
     /// - `SplashViewController` 不直接變更 `rootViewController`，而是通知 `SceneDelegate` 來處理畫面切換。
     class SplashViewController: UIViewController {
         
         // MARK: - UI Components
         
         /// `SplashView` 負責 UI 顯示與動畫播放
         private let splashView = SplashView()
         
         // MARK: - Lifecycle Methods

         /// `loadView()` 設定 `SplashView` 作為主視圖
         override func loadView() {
             self.view = splashView
         }
         
         /// `viewDidLoad()` 觸發動畫播放
         override func viewDidLoad() {
             super.viewDidLoad()
             playAnimation()
         }
         
         // MARK: - Private Methods
         
         /// 播放 Lottie 動畫，動畫結束後通知 `SceneDelegate` 切換畫面
         private func playAnimation() {
             splashView.playAnimation { [weak self] in
                 self?.navigateToMainApp()
             }
         }
         
         /// `navigateToMainApp()` 負責通知 `SceneDelegate` 切換 `rootViewController`
         private func navigateToMainApp() {
             guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                 return
             }
             sceneDelegate.switchToHomePageNavigation()
         }
     }
     ```

 ---

 2.`SceneDelegate` 統一管理 `rootViewController` 切換
 
     ```swift
     import UIKit

     class SceneDelegate: UIResponder, UIWindowSceneDelegate {
         
         var window: UIWindow?

         func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
             guard let windowScene = (scene as? UIWindowScene) else { return }
             
             window = UIWindow(windowScene: windowScene)
             
             if Auth.auth().currentUser != nil {
                 // 使用者已登入，顯示 MainTabBarController
                 switchToMainTabBar()
             } else {
                 // 未登入，顯示 SplashViewController
                 let splashVC = SplashViewController()
                 window?.rootViewController = splashVC
             }
             
             window?.makeKeyAndVisible()
         }
     }
     ```

 --------

 `* 結論`
 
 1. `SplashViewController` 只負責動畫播放，不直接處理 `rootViewController` 切換
 2. `SceneDelegate` 統一管理 `rootViewController` 變更，確保畫面切換的邏輯一致
 3. 這樣的架構符合 MVC 原則，確保 `ViewController` 責任單一，提高可維護性

 */



// MARK: - (v)

import UIKit


/// `SplashViewController` 負責管理啟動畫面邏輯
///
/// - 主要職責是顯示 `SplashView`，並在動畫播放完畢後執行轉場邏輯。
/// - `SplashViewController` 不負責 `rootViewController` 的切換，而是通知 `SceneDelegate` 來處理畫面變更。
/// - 使用 `loadView()` 設定 `SplashView` 作為主視圖，確保 `ViewController` 只關注業務邏輯，而不處理 UI 細節。
class SplashViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// `SplashView` 負責 UI 顯示與動畫播放
    private let splashView = SplashView()
    
    // MARK: - Lifecycle Methods
    
    /// 設定 `SplashView` 作為主視圖
    override func loadView() {
        self.view = splashView
    }
    
    /// `viewDidLoad()` 觸發動畫播放
    override func viewDidLoad() {
        super.viewDidLoad()
        playAnimation()
    }
    
    // MARK: - Private Method
    
    /// `playAnimation()` 負責觸發 `SplashView` 的動畫播放
    ///
    /// - 當動畫播放結束時，會自動呼叫 `navigateToMainApp()` 進行畫面轉場。
    private func playAnimation() {
        splashView.playAnimation { [weak self] in
            self?.navigateToMainApp()
        }
    }
    
    /// `navigateToMainApp()` 負責畫面轉場，通知 `SceneDelegate`
    ///
    /// - 這個方法不應該直接變更 `rootViewController`，而是交由 `SceneDelegate` 統一管理畫面切換。
    /// - `SceneDelegate` 會決定應該進入 `HomePageViewController。
    private func navigateToMainApp() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }
        sceneDelegate.switchToHomePageNavigation()
    }
    
}
