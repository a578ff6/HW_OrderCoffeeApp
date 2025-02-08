//
//  SceneDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - SplashViewController 與 SceneDelegate 的 `switchToHomePageNavigation()` 責任劃分
/**
 
 ### SplashViewController 與 SceneDelegate 的 `switchToHomePageNavigation()` 責任劃分

 
 `* What`
 
 - `SplashViewController` 負責 **顯示動畫**，並在動畫播放結束後**觸發畫面切換**。
 - `SceneDelegate` 負責 **管理 `rootViewController` 的切換**，確保應用程式的起始畫面正確。
 - `switchToHomePageNavigation()` 方法應該放在 `SceneDelegate`，不應該放到 `SplashViewController`，因為它負責**切換 `rootViewController`**。

 --------

 `* Why`
 
 1. 符合 MVC 架構
 
    - `SplashViewController` 屬於 **Controller 層**，它的主要職責是管理 UI 和處理動畫，不應該直接處理 `rootViewController` 切換邏輯。
    - `SceneDelegate` 負責 **應用程式啟動時的畫面管理**，這包括 **`rootViewController` 的設置與切換**，應該統一管理。

 2. 符合單一職責原則（SRP）
 
    - `SplashViewController` 只負責 **動畫播放**，它不應該知道 **主畫面的初始化邏輯**。
    - `SceneDelegate` 負責 **應用畫面的切換**，確保畫面轉場邏輯集中管理，避免分散到 `ViewController`。

 3. 提高可維護性
 
    - 如果 `HomePageViewController` 需要變更成 `其他 ViewController`，只需修改 `SceneDelegate`，不影響 `SplashViewController`。
    - 所有 `rootViewController` 變更的邏輯都在 `SceneDelegate`，未來維護時不需要到 `SplashViewController` 進行修改。

 --------

 `* How`
 
 1. `SplashViewController` 只負責播放動畫，動畫結束後通知 `SceneDelegate`
 
     ```swift
     import UIKit

     /// `SplashViewController` 負責管理啟動畫面邏輯
     ///
     /// - 主要職責是顯示 `SplashView`，並在動畫播放完畢後執行轉場邏輯。
     /// - 使用 `loadView()` 設定 `SplashView` 作為主視圖。
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
         
         /// 觸發 `SplashView` 的動畫播放，並在動畫結束後切換至主畫面
         private func playAnimation() {
             splashView.playAnimation { [weak self] in
                 self?.navigateToMainApp()
             }
         }
         
         /// `navigateToMainApp` 負責畫面轉場，通知 `SceneDelegate`
         private func navigateToMainApp() {
             guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                 return
             }
             sceneDelegate.switchToHomePage()
         }
     }
     ```

 ---

 2.`SceneDelegate` 負責 `rootViewController` 的切換
 
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

 `* 總結`
 
 1. `SceneDelegate` 統一管理 `rootViewController` 切換
 
    -  確保 `rootViewController` 變更的邏輯集中管理，符合 MVC 原則。
    -  如果未來 `HomePageViewController` 變更為 `其他 ViewController`，只需改 `SceneDelegate`，不影響 `SplashViewController`。

 2. `SplashViewController` 只負責動畫，不處理 `rootViewController` 切換
 
    -  `SplashViewController` 只負責動畫播放，符合單一職責原則（SRP）。
    -  當動畫播放結束時，通知 `SceneDelegate` 進行畫面切換。

 3. `switchToHomePageNavigation()` 應該保留在 `SceneDelegate`
 
    - `SceneDelegate` 本來就負責管理 `UIWindow`，所以應該由它來決定 `rootViewController`。
    -  不應該把 `switchToHomePageNavigation()` 移到 `SplashViewController`，因為這會讓 Controller 變得太複雜。

 4. 符合單一職責原則（SRP）
 
    - `SceneDelegate` 只負責 UI 切換，`SplashViewController` 只負責動畫，不互相干涉。

 5. 提高可維護性
 
    - 任何畫面變更只需要修改 `SceneDelegate`，不用影響 `SplashViewController`，未來變更更容易。
 */


// MARK: - 關係圖
/**
 
 SceneDelegate
   ├── switchToMainTabBar()  (`登入成功進入 MainTabBarController`)
   ├── switchToHomePageNavigation()  (`未登入時進入 HomePageNavigationController`)
   └── window 管理

 SplashViewController (Controller)
   ├── 管理動畫播放
   ├── 動畫結束後通知 SceneDelegate 切換畫面
   └── 不負責初始化 HomePageViewController

 SplashView (View)
   ├── 負責顯示 Lottie 動畫
   └── 不包含任何業務邏輯

 */


// MARK: - SceneDelegate 筆記
/**
 
 ### SceneDelegate 筆記

 
 `* What`
 
 - `SceneDelegate` **負責管理應用程式的 `UIWindow`**，確保正確的 `rootViewController` 在應用啟動時顯示。
 - 它根據 `使用者登入狀態` 決定顯示 `MainTabBarController`（登入狀態）或 `SplashViewController`（未登入狀態）。
 - 提供 `switchToMainTabBar()` 與 `switchToHomePageNavigation()` ，負責 `rootViewController` 變更，確保畫面切換邏輯統一。

 ---------

 `* Why`
 
 1. `SceneDelegate` 負責 UI 啟動
 
    - 應用程式的 UI 初始化與管理從 `AppDelegate` 分離，由 `SceneDelegate` 負責 `UIWindow` 和 `rootViewController` 切換。
    - 如果不使用 `SceneDelegate`，可能會導致 `AppDelegate` 處理過多 UI 相關邏輯，與 `SceneDelegate` 職責混雜。

 2. 使用者登入狀態應該在 `SceneDelegate` 層級決定
 
    - `Auth.auth().currentUser` 讓我們可以在應用啟動時判斷 **使用者是否登入**，並決定初始畫面。
    - 如果 `SplashViewController` 處理登入狀態，將會讓它的職責變得混亂，導致不必要的登入狀態判斷邏輯。

 3. 提供統一的 `switchToViewController()`，減少畫面切換的耦合
 
    - 所有畫面切換邏輯都集中在 `SceneDelegate`，確保未來有新需求（如 `OnboardingViewController`）時，變更點最少，維護性最高。
    - 避免 `SplashViewController` 或其他 `ViewController` 直接變更 `rootViewController`，確保 **畫面管理的一致性**。

 ---------

 `* How`
 
 1.檢查登入狀態並決定 `rootViewController`
 
     ```swift
     import UIKit
     import FirebaseAuth

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

 ---

 2. 提供畫面切換方法，確保畫面管理統一
 
     ```swift
     extension SceneDelegate {
         
         func switchToMainTabBar() {
             guard let window = self.window else { return }
             
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let mainTabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBarController)
             
             window.rootViewController = mainTabBarController
             UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
         }
         
         func switchToHomePageNavigation() {
             guard let window = self.window else { return }
             
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let homeNavVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageNavigationController)
             
             window.rootViewController = homeNavVC
             UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
         }
     }
     ```

 ---------

 `* 總結`
 
    1. `SceneDelegate` 統一管理 `rootViewController`，確保應用啟動邏輯清晰
    2. 根據 `FirebaseAuth` 判斷使用者登入狀態，決定 `SplashViewController` 或 `MainTabBarController`
    3. 提供 `switchToMainTabBar()` 和 `switchToHomePageNavigation()`，確保畫面切換統一管理，提高可維護性
    4. `SplashViewController` 只負責動畫顯示，不直接修改 `rootViewController`

 */


// MARK: - App啟動時如何處理登入狀態與啟動畫面
/**
 
 ### App啟動時如何處理登入狀態與啟動畫面


 `* What`
 
 - 當應用程式啟動時，需要 `根據使用者的登入狀態`來 `決定初始畫面`：
 
 1. 使用者已登入 → 直接進入 `MainTabBarController`。
 
 2. 使用者未登入 → 顯示 `SplashViewController`，動畫結束後進入 `HomePageViewController`。

    - `SceneDelegate` 負責 檢查登入狀態並決定 `rootViewController`。
    - `SplashViewController` 只在未登入時才會顯示，播放完動畫後切換至 `HomePageViewController`。

 -------

 `* Why`
 
 1. 提高使用者體驗
 
    - `已登入使用者`不需要看到啟動畫面動畫，應該直接進入 `MainTabBarController`，確保應用啟動速度最快。
    - `未登入使用者` 才需要 `SplashViewController`，讓動畫播放完後 導向 `HomePageViewController`。

 2. 避免不必要的動畫顯示
 
    - 如果每次啟動 App 都顯示 `SplashViewController`，即使已登入，會造成使用者不必要的等待。
    - 因此 `SplashViewController` 僅在使用者未登入時顯示，已登入時則直接進入 `MainTabBarController`。

 3. `SceneDelegate` 負責畫面初始化，確保架構清晰
 
    - `SceneDelegate` 應該負責 UI 初始化與 `rootViewController` 切換，確保畫面管理統一。
    - `SplashViewController` 只應該負責動畫顯示，不應該決定應用程式的初始畫面，這樣可以確保單一職責（SRP）。

 -------

 `* How`
 
 1.`SceneDelegate` 根據登入狀態決定 `rootViewController`
 
     ```swift
     import UIKit
     import FirebaseAuth

     class SceneDelegate: UIResponder, UIWindowSceneDelegate {
         
         var window: UIWindow?
         
         func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
             guard let windowScene = (scene as? UIWindowScene) else { return }
             
             window = UIWindow(windowScene: windowScene)
             if Auth.auth().currentUser != nil {
                 switchToMainTabBar()
             } else {
                 let splashVC = SplashViewController()
                 window?.rootViewController = splashVC
             }
             window?.makeKeyAndVisible()
         }
     }
     ```

 ---

 2. `SceneDelegate` 提供畫面切換方法
 
     ```swift
     // MARK: - 畫面切換功能
     extension SceneDelegate {
         
         func switchToMainTabBar() {
             guard let window = self.window else { return }
             
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let mainTabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBarController)
             
             window.rootViewController = mainTabBarController
             UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
         }
         
         func switchToHomePageNavigation() {
             guard let window = self.window else { return }
             
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let homeNavVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageNavigationController)
             
             window.rootViewController = homeNavVC
             UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
         }
     }
     ```

 ---

 3.`SplashViewController` 只負責動畫，動畫結束後導向 `HomePageViewController`
 
     ```swift
     class SplashViewController: UIViewController {
         
         // MARK: - UI Components
         
         private let splashView = SplashView()
         
         // MARK: - Lifecycle Methods
         
         override func loadView() {
             self.view = splashView
         }
         
         override func viewDidLoad() {
             super.viewDidLoad()
             playAnimation()
         }
         
         // MARK: - Private Method
         
         private func playAnimation() {
             splashView.playAnimation { [weak self] in
                 self?.navigateToMainApp()
             }
         }
         
         private func navigateToMainApp() {
             guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                 return
             }
             sceneDelegate.switchToHomePageNavigation()
         }
         
     }
     ```

 -------

 `* 總結`
 
 1. `SplashViewController` 只會在「未登入」時顯示，動畫結束後才導向 `HomePageViewController`
 2. `SceneDelegate` 會在應用啟動時，根據登入狀態決定 `rootViewController`，避免不必要的動畫顯示
 3. `switchToMainTabBar()` 讓已登入的使用者直接進入 `MainTabBarController`，提高啟動速度
 4. `SplashViewController` 只負責動畫顯示，不處理登入狀態，符合單一職責原則（SRP）

 */




// MARK: - (v)

import UIKit
import FirebaseAuth

/// `SceneDelegate` 負責應用程式的 `UIWindow` 管理
///
/// - `SceneDelegate` 主要職責是決定應用程式的初始 `rootViewController`，並處理畫面切換邏輯。
/// - `SceneDelegate` 會根據使用者的登入狀態，決定顯示 `MainTabBarController` 或 `SplashViewController`。
/// - 提供 `switchToMainTabBar()` 和 `switchToHomePageNavigation()` 方法，統一管理 `rootViewController` 變更，確保畫面切換一致性。
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    /// `scene(_:willConnectTo:options:)` 方法負責設定 `UIWindow` 並決定應用程式的初始畫面。
    ///
    /// - 這裡會先檢查 `FirebaseAuth` 的 `currentUser` 是否存在：
    ///   - 已登入：直接進入 `MainTabBarController`。
    ///   - 未登入：顯示 `SplashViewController`（播放啟動畫面動畫）。
    /// - `makeKeyAndVisible()` 讓 `window` 成為應用的主要視窗，確保畫面能正確顯示。
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if Auth.auth().currentUser != nil {
            switchToMainTabBar()
        } else {
            let splashVC = SplashViewController()
            window?.rootViewController = splashVC
        }
        window?.makeKeyAndVisible()
    }
    
}


// MARK: - 畫面切換功能擴充
extension SceneDelegate {
    
    /// 切換 `rootViewController` 為 `MainTabBarController`
    ///
    /// - 用途：當使用者登入後，或啟動時已登入，應用程式會直接進入 `MainTabBarController`。
    /// - 實作細節：
    ///   - 透過 `Storyboard` 取得 `MainTabBarController`，確保 UI 維持一致性。
    ///   - 使用 `UIView.transition(with:window,...)` 來提供平滑的轉場動畫。
    func switchToMainTabBar() {
        guard let window = self.window else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBarController)
        
        window.rootViewController = mainTabBarController
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
    }
    
    /// 進入 `HomePageNavigationController`
    ///
    /// - 用途：當 `SplashViewController` 的動畫播放結束時，應用會進入 `HomePageNavigationController`，以確保 `HomePageViewController` 具有完整的導航控制。
    /// - 實作細節：
    ///   - 透過 `Storyboard` 取得 `HomePageNavigationController`，確保導航結構一致。
    ///   - `HomePageNavigationController` 的 `rootViewController` 為 `HomePageViewController`，所以 `HomePageViewController` 會自動顯示。
    ///   - 使用 `UIView.transition(with:window,...)` 提供流暢的轉場動畫，提升使用者體驗。
    func switchToHomePageNavigation() {
        guard let window = self.window else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeNavVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageNavigationController)
        
        window.rootViewController = homeNavVC
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
    }
    
}
