//
//  NavigationHelper.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/14.
//

// MARK: - 導航方式
/**

 ## 根據使用者「體驗App邏輯」選擇適合的導航方式。只要「避免產生堆棧問題」和「不必要的內存佔用」，就可以使用不同的導航方式。
 
 `1. 選擇導航方式：`
 
    * push 和 pop：
        - 適用於需要在「導航欄」中顯示back按鈕的情況，如一個 ViewController 在邏輯上是另一個 ViewController 的延續。
        - 畫面之間有邏輯延續關係，且需要顯示返回按鈕的情況。常見於一層一層深入的結構，比如從列表點進去查看詳細資料。

    * present 和 dismiss：
        - 適用於 modallypresent 展示的情況，如彈出一個「獨立」的功能 ViewController，不需要在導航欄中顯示back按鈕。
        - 適合獨立功能模組的展示，如使用模態方式彈出視圖控制器。這些畫面不需要返回按鈕，且通常有獨立的關閉方式（例如 "取消" 按鈕）。
 
    * 使用模態呈現 (present) 時：
        - 可以考慮移除 Storyboard 中的 Segue，直接用程式碼處理畫面呈現邏輯，這樣更具彈性。
        - 但當有些畫面轉換是頻繁或簡單的情境，保留 Storyboard Segue 使用 performSegue 是更方便的選擇。

 --------
 
 `2. 避免堆棧問題：`
 
    * 避免循環導航，即確保使用者可以順利返回上一級 ViewController 而不會陷入無限循環！！
    * 控制導航堆棧的深度，變免不必要的 ViewCOntroller 留在堆棧中。
 
 --------

 `3. 使用者體驗：`
 
    * 符合使用者預期：
        - 使用 push 導航時，系統自動顯示 back按鈕 ，給予一致的導航體驗。（「back按鈕」和 「關閉按鈕」 應在適當的地方出現。）

    * 模態呈現 (present) 時：
        - 應在畫面中 「提供」 明確的關閉或返回按鈕，讓使用者能快速瞭解如何返回上一頁。
 
 --------

 `4. 我的使用場景：`
 
    * 用戶註冊和登入流程：
        - 從 HomeViewController 到 LoginViewController 和 SignUpViewController 可以使用 push，確保用戶可以通過 back 回到主頁面。
 
        - 在 LoginViewController 中，使用 present 道行進入 ForgotPasswordViewController，並在 ForgotPasswordViewController 提供關閉按鈕，通過 dismiss 返回！
 
 --------

 `5. 嵌入 NavigtaionController ：`
 
    * 因為我在 ForgotPasswordViewController 的部分，雖然是使用 present 呈現 large。
    * 但我又希望在 ViewController 中顯示 NavigtaionBar 和關閉按鈕，因此需要將其嵌入 NavigtaionController 中。
    * 即使嵌入 NavigtaionController，仍然可以使用 dismiss 來關閉 modallypresent 視圖，避免堆棧問題。
 
 --------

 `6.登出功能相關邏輯：`
 
    * 重設根視圖控制器：
        - 在用戶成功登出後，重設 App 的根視圖控制器為 `HomePageViewController`，這樣可以完全清除 `MainTabBarController` 及其子視圖控制器的狀態，避免它們在後台繼續存在。
*/


// MARK: - 註冊、登入成功後導航到 MainTabBarController，而不是 MenuViewController
/**
 
 ## 註冊、登入成功後導航到 MainTabBarController，而不是 MenuViewController

 ---

 `* What`
 
 - 當使用者完成註冊或登入後，應將使用者導航到 `MainTabBarController`，而不是直接導航到 `MenuViewController`。

 1. `MainTabBarController` 是整個應用的核心導航容器，包含 Menu、Search、Order、UserProfile 等多個 Tab 頁面。
 2. `MenuViewController` 是 MainTabBarController 的子頁面，僅負責展示飲品分類。

 ---

 `* Why`
 
 `1. 清晰的應用架構：`
 
 - `MainTabBarController` 是應用的主要框架，統一管理多個頁面。導航到它能確保應用結構一致，不會因為單獨進入某個頁面（如 `MenuViewController`）而影響其他頁面的訪問。
 - 若直接導航到 `MenuViewController`，可能會破壞 TabBar 的整體導航體驗，導致其他頁面無法正確加載或訪問。

 `2. 增強用戶體驗：`
 
 - 使用者完成登入或註冊後，應能立即看到整個應用的功能，包括飲品分類（Menu）、搜尋（Search）、訂單（Order）與用戶資料（UserProfile）。這樣能讓使用者感知應用的完整性，而不只是單一頁面。
 - 將 `MainTabBarController` 作為入口，讓用戶可以在多個功能之間快速切換，而不需要重新進行導航或跳轉。

 `3. 責任分工明確：`
 
 - `MainTabBarController` 負責導航結構，`MenuViewController` 只負責展示內容。
 - 確保每個頁面的責任範圍清晰，有助於後續的擴展與維護。

 ---

 `* How`
 
 `1. 在 NavigationHelper 中定義跳轉邏輯：`
 
 - 當使用者完成註冊或登入時，透過 `NavigationHelper.navigateToMainTabBar()` 導航到 `MainTabBarController`。

    ```swift
    static func navigateToMainTabBar() {
    }
    ```

` 2. 確保 MainTabBarController 負責管理多個 Tab 頁面：`
 
 - 確保 TabBar 包含 Menu、Search、Order、UserProfile 等頁面。
 - 各子頁面自行處理資料請求邏輯。

 */


// MARK: - 筆記：登入、註冊跳轉頁面是否需要設置 UINavigationController
/**
 
 ## 筆記：登入、註冊跳轉頁面是否需要設置 UINavigationController

 ---

 `* What`
 
 1. `navigateToMainTabBar`：
 
    - 導航至 `MainTabBarController` 時，不需要包裹在 `UINavigationController` 中。
    - `MainTabBarController` 是應用的主容器，負責管理多個子頁面（如 Menu、Search、Order、UserProfile），並提供切換功能。

 ---

 `* Why`
 
 1. `navigateToMainTabBar` 不需要 `UINavigationController` 的原因：
 
    - 責任分離：
      - 每個子頁面（如 `MenuViewController`）會各自設置 `UINavigationController`，`MainTabBarController` 不需額外包裹。
 
    - 架構簡化：
      - 保持層級清晰，避免不必要的導航堆疊。
 
    - 標準設計：
      - `UITabBarController` 作為應用的主頁面，通常不被包裹在 `UINavigationController` 中。

 ---

 `* How`
 
 1. 設置 `navigateToMainTabBar` 的邏輯：
 
    - 將 `MainTabBarController` 設置為應用的主頁面，不包裹在 `UINavigationController` 中。
 
 ---

 `* 總結`
 
 1. `navigateToMainTabBar` 不需要設置 `UINavigationController`，因為每個子頁面會自行管理導航。
 2. 設計的關鍵在於根據頁面的職責和功能需求，選擇是否使用 `UINavigationController`。
 */


// MARK: - 記憶體釋放與 `navigateToHomePageNavigation` 的實踐
/**
 
 ###  記憶體釋放與 `navigateToHomePageNavigation` 的最佳實踐


` * What`
 
 - `navigateToHomePageNavigation(from:)` 方法負責將應用的 `rootViewController` 切換為 `HomePageNavigationController`，並確保登出後 `MainTabBarController` 及其所有子視圖控制器`完全被移除，釋放記憶體`。

 - 主要功能：
 
   - 確保 `MainTabBarController` 完全從記憶體釋放，避免佔用多餘的資源。
   - 使用 `CATransition.fade` 提供更平滑的畫面轉場，比 `transitionCrossDissolve` 更自然。
   - 確保 `window.rootViewController` 的替換正確執行，避免 `present` 堆疊問題。

 ---------

 `* Why `

 1.確保 `MainTabBarController` 及其子控制器完全移除
 
    - `window.rootViewController = homeNavController` **完全替換** `MainTabBarController`，`UIKit` 會自動釋放 `MainTabBarController` 及其所有子視圖控制器。
    - 避免**殘留的 `UIViewController` 導致的記憶體洩漏**。

 2. `present` 方法不適合登出後的場景
 
    - 使用 `present` 只是疊加新畫面，不會釋放 `MainTabBarController`，可能造成 記憶體佔用過高。
    - 登出應該「重置應用的 `rootViewController`」，而不是讓新頁面覆蓋舊頁面，確保應用回到乾淨狀態。

 3. `transitionCrossDissolve` 過渡效果不夠自然
 
    - `transitionCrossDissolve` 在某些設備上會導致畫面閃爍，或者切換時「過渡不流暢」。
    - 改用 `CATransition.fade` 可以讓畫面平滑過渡。

 ---------

 `* How`

 1. `navigateToHomePageNavigation`
 
    - 使用 `CATransition.fade` 替換 `transitionCrossDissolve`，確保畫面平滑過渡：
 
     ```swift
     static func navigateToHomePageNavigation(from viewController: UIViewController) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)

         guard let homeNavController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageNavigationController) as? UINavigationController else {
             print("無法實例化 HomePageNavigationController")
             return
         }

         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first else {
             print("無法取得有效的 UIWindow")
             return
         }

         // 設定 CATransition 讓過渡更平滑
         let transition = CATransition()
         transition.type = .fade // 💡 改為 fade，讓畫面自然淡入淡出
         transition.duration = 0.4 // 動畫時間
         transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

         // 加入動畫
         window.layer.add(transition, forKey: kCATransition)
         window.rootViewController = homeNavController
     }
     ```

 ---------

 `* 總結`
 
 1. 使用 `window.rootViewController = homeNavController` 確保 `MainTabBarController` **完全從記憶體移除**，避免記憶體洩漏。
 2. 避免 `present` 方法，確保 `rootViewController` 正確切換，防止畫面堆疊。
 3. 使用 `CATransition.fade` 取代 `transitionCrossDissolve`，提升動畫流暢度。
 4. 檢查 `MainTabBarController` 釋放狀況，確保 UI 元件正確回收，避免資源浪費。
 
 */


// MARK: - NavigationHelper 筆記
/**
 
 ### NavigationHelper 筆記


` * What`
 
 - `NavigationHelper` 是一個 **導航管理工具類別**，用來統一處理應用內的頁面切換，例如：
 
    - 進入 `MainTabBarController`（登入成功或註冊後）
    - 跳轉 `ForgotPasswordViewController`（忘記密碼頁面）
    - 跳轉 `SignUpViewController`（註冊頁面）
    - 返回 `HomePageNavigationController`（登出後回到首頁）

 - 它提供 `統一的 API` 來處理 `rootViewController` 的變更，以及 `push`、`present` 操作，確保導航體驗的一致性。

 --------

 `* Why`
 
 1. 統一管理導航邏輯，提升可維護性
 
 - 在 App 中，導航（頁面切換）會發生在不同的情境，例如：
 
   - 登入 / 註冊成功 → 進入 `MainTabBarController`
   - 忘記密碼 → 彈出 `ForgotPasswordViewController`
   - 登出 → 返回 `HomePageNavigationController`
 
 - 若在 **各個 `ViewController` 內部** 分別處理導航邏輯，會導致 **重複程式碼** 和 **難以維護**。

 - 解決方案：
 
    - `NavigationHelper` 將主要 導航操作集中在一個地方，確保頁面切換邏輯可重用、易維護。

 ---

 2.確保 rootViewController 切換時釋放記憶體
 
 - `navigateToMainTabBar()` 和 `navigateToHomePageNavigation()` 會 **切換 `rootViewController`**，確保舊的 `ViewController` 完全移除，釋放記憶體，避免 **內存泄漏**。

 - 解決方案：
 
    - `window.rootViewController = newViewController` 確保舊畫面完全移除
    - 登出時，完全移除 `MainTabBarController`，避免仍然在記憶體中占用資源。

 ---

 3. 提供一致的過場動畫，提升使用者體驗
 
    - 頁面切換時，使用 `CATransition`  來提供更平滑的體驗，提升 UI 過渡效果。

 - 解決方案：
 
    - 登入 / 註冊成功後：`navigateToMainTabBar()` 使用 `fade` 過場動畫
    - 登出後返回首頁：`navigateToHomePageNavigation()` 也使用 `fade` 過場動畫

 --------

 `* How`
 
 1. 切換至 `MainTabBarController`
 
    - 登入或註冊成功後
     
     ```swift
     static func navigateToMainTabBar() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         
         guard let mainTabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBarController) as? MainTabBarController else {
             print("無法實例化 MainTabBarController")
             return
         }

         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first else {
             print("無法取得有效的 UIWindow")
             return
         }

         let transition = CATransition()
         transition.type = .fade
         transition.duration = 0.5
         transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

         window.layer.add(transition, forKey: kCATransition)
         window.rootViewController = mainTabBarController
     }
     ```
 
 -  關鍵點：
 
    - `fade` 動畫提供更流暢的過場效果
    - 完全移除 `HomePageNavigationController`，釋放記憶體

 ---

 2. 跳轉至 `ForgotPasswordViewController`
 
    - 需要 `UINavigationController` 來提供返回按鈕
 
     ```swift
     static func navigateToForgotPassword(from viewController: UIViewController) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         
         guard let forgotPasswordVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.forgotPasswordViewController) as? ForgotPasswordViewController else {
             print("無法實例化 ForgotPasswordViewController")
             return
         }
         
         forgotPasswordVC.modalPresentationStyle = .pageSheet
         let navController = UINavigationController(rootViewController: forgotPasswordVC)

         if let sheet = navController.sheetPresentationController {
             sheet.detents = [.large()]
         }

         viewController.present(navController, animated: true, completion: nil)
     }
     ```
 
 - 為什麼使用 `UINavigationController`？
 
    - `ForgotPasswordViewController` 內 **有關閉按鈕**，所以包在 `UINavigationController` 裡，讓 `NavigationBar` 提供返回功能。
    - `.pageSheet` 模式符合 iOS **標準 UI 規範**，不會影響當前頁面狀態。

 ---

 3. 切換回 `HomePageNavigationController`
 
    - 登出時完全重置 `rootViewController`
 
     ```swift
     static func navigateToHomePageNavigation() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         
         guard let homeNavController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageNavigationController) as? UINavigationController else {
             print("無法實例化 HomePageNavigationController")
             return
         }

         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first else {
             print("無法取得有效的 UIWindow")
             return
         }

         let transition = CATransition()
         transition.type = .fade
         transition.duration = 0.4
         transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

         window.layer.add(transition, forKey: kCATransition)
         window.rootViewController = homeNavController
     }
 ```
 
 - 關鍵點：
 
    - 登出時，完全移除 `MainTabBarController`
    - 確保 `HomePageNavigationController` 內部畫面是新的

 --------

 `* 總結`
 
 - `NavigationHelper` 設計的三大目標
 
    1. 統一導航邏輯，減少重複代碼，提升可維護性
    2. 確保 `rootViewController` 切換時釋放記憶體，避免內存泄漏
    3. 使用 `fade` 動畫提升 UI 過渡體驗

 */



// MARK: - (v)

import UIKit

/// `NavigationHelper`
///
/// - 負責管理應用內的導航邏輯，如登入、登出、頁面跳轉等操作。
/// - 提供統一的方法來切換 `rootViewController` 或執行 `push` / `present` 操作，確保導航體驗的一致性。
class NavigationHelper {
    
    // MARK: - navigateToMainTabBar
    
    /// 用戶登入或註冊成功後，導航至 `MainTabBarController`
    ///
    /// - 用途:
    ///   - 當用戶成功登入或註冊後，進入 `MainTabBarController`，讓使用者可切換不同功能頁面。
    ///
    /// - 實作細節:
    ///   - 透過 `Storyboard` 取得 `MainTabBarController`，確保 UI 配置正確。
    ///   - 使用 `CATransition` 的 `fade` 動畫，確保畫面過渡流暢。
    static func navigateToMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let mainTabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBarController) as? MainTabBarController else {
            print("無法實例化 MainTabBarController")
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("無法取得有效的 UIWindow")
            return
        }
        
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        window.layer.add(transition, forKey: kCATransition)
        window.rootViewController = mainTabBarController
    }
    
    
    // MARK: - navigateToForgotPassword
    
    /// 導航至 `ForgotPasswordViewController`，並包裹於 `UINavigationController` 中
    ///
    /// - 用途:
    ///   - 讓使用者可以透過獨立頁面進行密碼重置。
    ///   - 由於 `ForgotPasswordViewController` 需要提供 **關閉按鈕**，因此使用 `UINavigationController` 來確保返回按鈕的可用性。
    ///
    /// - 實作細節:
    ///   - 透過 `Storyboard` 取得 `ForgotPasswordViewController`，確保頁面配置正確。
    ///   - 設置為 `.pageSheet` 模式，符合 iOS 預設的彈出視窗體驗。
    ///   - 透過 `UINavigationController` 提供 `NavigationBar`，確保使用者可以透過按鈕關閉頁面。
    ///
    /// - 參數:
    ///   - `viewController`: 當前的視圖控制器，作為 `present` 的起點。
    static func navigateToForgotPassword(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let forgotPasswordVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.forgotPasswordViewController) as? ForgotPasswordViewController else {
            print("無法實例化 ForgotPasswordViewController")
            return
        }
        
        forgotPasswordVC.modalPresentationStyle = .pageSheet
        let navController = UINavigationController(rootViewController: forgotPasswordVC)
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
        }
        
        viewController.present(navController, animated: true, completion: nil)
    }
    
    
    // MARK: - navigateToSignUp
    
    /// 導航至 `SignUpViewController`，使用 `push` 方式
    ///
    /// - 用途:
    ///   - 讓使用者透過 NavigationController 進入註冊頁面，以便之後返回登入頁面。
    ///
    /// - 實作細節:
    ///   - `SignUpViewController` 需要透過 `push` 方法進入，確保 `NavigationController` 的返回按鈕可用。
    ///
    /// - 參數:
    ///   - `viewController`: 當前的視圖控制器，應該是 `UINavigationController` 的子控制器。
    static func navigateToSignUp(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let signUpViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.signUpViewController) as? SignUpViewController else {
            print("無法實例化 SignUpViewController")
            return
        }
        
        viewController.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    // MARK: - navigateToHomePageNavigation
    
    /// 導航至 `HomePageNavigationController`（登出後返回首頁）
    ///
    /// - 用途:
    ///   - 當使用者**登出**時，應用應該返回 `HomePageNavigationController`，讓使用者可以重新登入或註冊。
    ///
    /// - 實作細節:
    ///   - 透過 `Storyboard` 取得 `HomePageNavigationController`，確保首頁導航可用。
    ///   - 使用 `CATransition` 設置 `fade` 動畫，確保畫面切換平滑。
    ///   - 直接切換 `rootViewController`，確保 `MainTabBarController` 及其所有子視圖完全移除，釋放記憶體。
    static func navigateToHomePageNavigation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let homeNavController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageNavigationController) as? UINavigationController else {
            print("無法實例化 HomePageNavigationController")
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("無法取得有效的 UIWindow")
            return
        }
        
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 加入動畫
        window.layer.add(transition, forKey: kCATransition)
        window.rootViewController = homeNavController
    }
    
}
