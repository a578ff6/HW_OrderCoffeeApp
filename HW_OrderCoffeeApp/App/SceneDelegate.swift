//
//  SceneDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - Scene Delegate 筆記 _ 啟動動畫
/**
 
 ## Scene Delegate 筆記 _ 啟動動畫
 
 
 `* What`
 
 - `SceneDelegate` 負責應用程式的 `UIWindow` 管理。它決定 App 啟動時要顯示哪個 `rootViewController`，並在應用程式狀態變化（如進入背景、回到前景）時執行相應的處理。

 - 在專案中，`SceneDelegate` 的主要角色是：
 
    - 初始化並設定 `UIWindow`，讓應用程式能夠顯示 UI。
    - 決定應用程式啟動時的初始畫面，例如顯示 `SplashViewController`。
    - 支援多場景（Multi-Window）功能，雖然大多數應用只會使用單一 `Scene`。
    - 管理 `rootViewController` 的切換，例如從 `SplashViewController` 轉換到 `HomePageViewController`。

 ---------

 `* Why`
 
 1. 分離應用程式的生命週期管理
 
    - `AppDelegate` 現在只負責應用程式層級的事件（如推播通知、背景下載）。
    - `SceneDelegate` 則專注於 UI 管理，使 `AppDelegate` 的職責更單純。

 2. 支援多場景（Multi-Window）
 
    - `SceneDelegate` 讓 iPadOS 和 macOS Catalyst 可以同時開啟多個應用程式視窗（不同 `scene`）。
    - 即使 iPhone 仍然使用單一場景，將 UI 管理交給 `SceneDelegate` 仍然是符合 Apple 架構設計的最佳實踐。

 3. 清晰的 `rootViewController` 切換機制
 
    - `SceneDelegate` 負責啟動畫面和主要畫面（如登入頁面、首頁）之間的切換，讓 `AppDelegate` 不需要處理這些細節。
    - 例如，在 `SplashViewController` 動畫播放結束後，透過 `SceneDelegate` 來切換 `rootViewController`。

 ---------

 `* How`
 
 - 透過 `SceneDelegate` 來設定 `SplashViewController` 作為啟動畫面，然後再切換到 `HomePageViewController`。

 1. 設定 `SplashViewController` 為初始畫面
 
    - 在 `SceneDelegate.swift` 中，將 `SplashViewController` 設定為 `rootViewController`，讓它作為應用程式啟動時的第一個畫面。
 
     ```swift
     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
         guard let windowScene = (scene as? UIWindowScene) else { return }
         
         window = UIWindow(windowScene: windowScene)
         let splashVC = SplashViewController()
         window?.rootViewController = splashVC
         window?.makeKeyAndVisible()
     }
     ```

 ---
 
 2. 提供畫面切換功能
 
    - 為了讓 `SplashViewController` 在動畫結束後能夠順利切換到 `HomePageViewController`，擴充 `SceneDelegate`，提供 `switchToViewController(_:)` 方法。

     ```swift
     extension SceneDelegate {
         func switchToViewController(_ viewController: UIViewController) {
             guard let window = self.window else { return }
             
             window.rootViewController = viewController
             UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
         }
     }
     ```

 ---

 3.`SplashViewModel` 觸發畫面切換
 
    - 當 `SplashViewController` 動畫結束後，使用 `SplashViewModel` 來呼叫 `switchToViewController(_:)`，完成畫面轉場。

 ```swift
 class SplashViewModel {
     func switchToMainApp() {
         guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
             return
         }
         
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let homeVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageViewController)
         let navigationController = UINavigationController(rootViewController: homeVC)
         
         sceneDelegate.switchToViewController(navigationController)
     }
 }
 ```

 ---

 4. `SplashViewController` 負責動畫，並在結束後通知 `SplashViewModel`
 
     ```swift
     class SplashViewController: UIViewController {
         
         private let splashViewModel = SplashViewModel()
         private let splashView = SplashView()
         
         override func loadView() {
             self.view = splashView
         }
         
         override func viewDidLoad() {
             super.viewDidLoad()
             playAnimation()
         }
         
         private func playAnimation() {
             splashView.playAnimation { [weak self] in
                 self?.splashViewModel.switchToMainApp()
             }
         }
     }
     ```

 ---------

 `* 總結`
 
 1.`SceneDelegate` 負責 `UIWindow` 初始化與 `rootViewController` 管理，確保 App 啟動時顯示 `SplashViewController`。
 2. 將 `rootViewController` 切換的邏輯獨立到 `SceneDelegate`，避免 `SplashViewController` 直接處理 UI 變更，提高可維護性。
 3. 透過 `SplashViewModel` 負責業務邏輯，讓 `SplashViewController` 專注於動畫顯示，提高單一職責原則（SRP）。
 4. 使用 `switchToViewController(_:)` 方法，讓畫面切換更加統一，未來可以重複使用。

 */



// MARK: - (v)

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    /// `scene(_:willConnectTo:options:)` 方法是應用程式啟動時的主要入口，負責設定主視窗 (`window`) 並選擇初始畫面。
    /// 在這裡，手動建立 `SplashViewController` 作為 `rootViewController`，確保啟動時先顯示動畫畫面。
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // 設定啟動畫面 (`SplashViewController`) 作為 rootViewController
        let splashVC = SplashViewController()
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()         // 讓 `window` 成為主視窗並顯示
    }

}


// MARK: - 畫面切換功能擴充
extension SceneDelegate {
    
    /// 切換 `rootViewController`，用於在應用程式內進行主畫面的轉換。
    /// - Parameter viewController: 要切換的目標 `UIViewController`
    func switchToViewController(_ viewController: UIViewController) {
        guard let window = self.window else { return }
        
        // 替換 `rootViewController`，使用 `crossDissolve` 動畫來提供流暢的轉場效果
        window.rootViewController = viewController
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
    }
    
}
