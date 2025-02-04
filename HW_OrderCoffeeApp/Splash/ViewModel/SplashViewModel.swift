//
//  SplashViewModel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/2/4.
//

// MARK: - SplashViewModel 筆記
/**
 
 ## SplashViewModel 筆記
 
 `* What`
 
 - `SplashViewModel` 是負責處理應用程式啟動畫面 (`SplashViewController`) 完成後的畫面轉換邏輯。
 - 它的主要功能是 **確保應用程式在啟動動畫結束後，能夠順利切換至主畫面 (`HomePageViewController`)**。

 - 在此專案中，`SplashViewModel` 負責：
 
    - 管理畫面轉場邏輯：在 `SplashViewController` 動畫結束後，透過 `SceneDelegate` 來切換 `rootViewController`。
    - 避免 `SplashViewController` 直接管理 `rootViewController`，符合 **單一職責原則（SRP）**。
    - 確保 `HomePageViewController` 被正確包裝於 `UINavigationController` 中，提供完整的導航功能。

 ---------

 `* Why`
 
 - 在 `SplashViewController` 直接切換 `rootViewController` 雖然可行，但這會導致視圖控制器（ViewController）承擔過多責任，降低可維護性。使用 `SplashViewModel` 有以下優勢：

 1. 符合單一職責原則（SRP）
 
    - `SplashViewController` 應該專注於 UI（動畫），而非畫面切換邏輯。
    - `SplashViewModel` 專門負責應用層級的轉場邏輯，讓 `SplashViewController` 變得更精簡。

 2. 提升程式碼的可讀性與可測試性
 
    - `SplashViewModel` 的方法可以獨立測試，不需要依賴 `SplashViewController` 的 UI。
    - 這樣的架構讓畫面切換的邏輯更直觀，開發者可以更容易理解其作用。

 3. 解耦 UI 與邏輯，提升靈活性
 
    - 透過 `SplashViewModel`，未來若要改變 `rootViewController`（例如加入登入頁面），只需要修改 `ViewModel`，不需要動 `SplashViewController`。
    - `SplashViewController` 只負責動畫，未來可重複使用於其他啟動畫面，不受 `rootViewController` 切換影響。

 4. 符合 iOS 設計模式
 
    - iOS 推薦 **將應用層邏輯與 UI 層解耦**，讓 `ViewModel` 負責邏輯，`ViewController` 負責 UI，這樣架構更清晰。

 ---------

 `* How`

 1. `SplashViewModel` 負責畫面轉換
 
    - 當動畫結束後，`SplashViewModel` 會透過 `SceneDelegate` 來切換 `rootViewController`。

     ```swift
     class SplashViewModel {
         /// 切換應用程式的 `rootViewController` 為主畫面 `HomePageViewController`。
         func switchToMainApp() {
             // 取得 `SceneDelegate`，確保應用程式擁有對 `window` 的訪問權限。
             guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                 return
             }
             
             // 從 `Main.storyboard` 加載 `HomePageViewController`
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let homeVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageViewController)
             
             // 使用 `UINavigationController` 包裝 `HomePageViewController`，確保擁有導航功能。
             let navigationController = UINavigationController(rootViewController: homeVC)
             
             // 呼叫 `SceneDelegate` 的 `switchToViewController` 進行畫面切換，提供平滑的轉場動畫。
             sceneDelegate.switchToViewController(navigationController)
         }
     }
     ```

 ---
 
 2.`SplashViewController` 觸發動畫，動畫結束後請求切換畫面
 
    - 在 `SplashViewController` 中，初始化 `SplashViewModel`，並在動畫完成後請求 `switchToMainApp()`。

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

 這樣一來，`SplashViewController` **不需要知道 `SceneDelegate` 或 `HomePageViewController` 的細節**，它只負責通知 `SplashViewModel` 進行切換。

 ---------

 `* 總結`
 
 1.`SplashViewModel` 負責處理畫面切換邏輯，讓 `SplashViewController` 只專注於動畫。
 2. 解耦 UI 與應用邏輯，符合 **單一職責原則（SRP）**，提升可讀性與可維護性。
 3. 透過 `SceneDelegate` 來切換 `rootViewController`，確保畫面切換方式統一且可擴展。
 4. 未來若要加入登入頁面或其他啟動邏輯，只需修改 `SplashViewModel`，不影響 `SplashViewController`。

 */



// MARK: - (v)

import UIKit

/// `SplashViewModel`
///
///  - 負責處理啟動畫面完成後的畫面轉換邏輯。
///  - 它的主要功能是將應用程式的 `rootViewController` 切換為 `HomePageViewController`。
class SplashViewModel {
    
    
    /// 切換應用程式的 `rootViewController` 為主畫面 `HomePageViewController`。
    /// 該方法透過 `SceneDelegate` 來進行畫面切換，確保 `SplashViewController` 完成動畫後能順利轉場。
    func switchToMainApp() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageViewController)
        let navigationController = UINavigationController(rootViewController: homeVC)
        
        // 呼叫 `SceneDelegate` 的 `switchToViewController` 進行畫面切換，提供平滑的轉場動畫。
        sceneDelegate.switchToViewController(navigationController)
    }
    
}
