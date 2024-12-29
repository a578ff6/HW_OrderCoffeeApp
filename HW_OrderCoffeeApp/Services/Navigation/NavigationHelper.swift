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
    static func navigateToMainTabBar(from viewController: UIViewController) {
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

 2. `navigateToLogin`：
 
    - 導航至 `HomePageViewController` 時，需要包裹在 `UINavigationController` 中。
    - 登入頁面及其相關頁面（如註冊、忘記密碼）需要返回功能，因此需要導航容器進行管理。

 ---

 `* Why`
 
 1. `navigateToMainTabBar` 不需要 `UINavigationController` 的原因：
 
    - 責任分離：
      - 每個子頁面（如 `MenuViewController`）會各自設置 `UINavigationController`，`MainTabBarController` 不需額外包裹。
 
    - 架構簡化：
      - 保持層級清晰，避免不必要的導航堆疊。
 
    - 標準設計：
      - `UITabBarController` 作為應用的主頁面，通常不被包裹在 `UINavigationController` 中。

 2. `navigateToLogin` 需要 `UINavigationController` 的原因：
 
    - 支持堆疊導航：
      - 登錄頁面通常會包含進一步的子頁面導航需求（如跳轉至註冊、忘記密碼頁面）。
 
    - 提供返回功能：
      - `UINavigationController` 自帶返回按鈕，符合用戶習慣。

 ---

 `* How`
 
 1. 設置 `navigateToMainTabBar` 的邏輯：
 
    - 將 `MainTabBarController` 設置為應用的主頁面，不包裹在 `UINavigationController` 中。
 
 2. 設置 `navigateToLogin` 的邏輯：
 
    - 使用 `UINavigationController` 包裹 `HomePageViewController`，以支持子頁面的導航功能。

 ---

 `* 總結`
 
 1. `navigateToMainTabBar` 不需要設置 `UINavigationController`，因為每個子頁面會自行管理導航。
 2. `navigateToLogin` 需要設置 `UINavigationController`，因為它需要支持進一步的堆疊導航和返回功能。
 3. 設計的關鍵在於根據頁面的職責和功能需求，選擇是否使用 `UINavigationController`。
 */



// MARK: - (v)

import UIKit

/// 負責處理 App 內的各種導航操作，如登入、登出、頁面跳轉等。
class NavigationHelper {
    
    // MARK: - navigateToMainTabBar
    
    /// 用戶登入或註冊成功後，導航到主頁面 MainTabBarController。
    ///
    /// - Parameters:
    ///   - viewController: 當前的視圖控制器，作為導航的起點。
    ///
    /// 此方法將 MainTabBarController 設置為應用的主頁面，並使用淡入淡出的動畫效果切換畫面。
    static func navigateToMainTabBar(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let mainTabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBarController) as? MainTabBarController else {
            print("無法實例化 MainTabBarController")
            return
        }
        
        mainTabBarController.modalPresentationStyle = .fullScreen
        
        // 嘗試取得 windowScene 和 window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("無法取得有效的 UIWindow")
            return
        }
        
        // 使用系統預設動畫：淡入淡出
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = mainTabBarController
        }, completion: nil)
        
    }
    
    // MARK: - navigateToForgotPassword
    
    /// 跳轉到 ForgotPasswordViewController，並包裹於 UINavigationController 中。
    ///
    /// - Parameters:
    ///   - viewController: 當前的視圖控制器，作為導航的起點。
    ///
    /// 此方法顯示 ForgotPasswordViewController，並設置為 `.pageSheet` 模式。使用 `UINavigationController` 方便用戶`關閉頁面`或進行後續操作。
    /// 將其坎 入UINavigationController，因為有設置關閉按鈕在 Navigationbar
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
    
    /// 跳轉到 SignUpViewController，使用 UINavigationController 的 push 方法。
    ///
    /// - Parameters:
    ///   - viewController: 當前的視圖控制器，應為 UINavigationController 的子控制器。
    ///
    /// 此方法透過 push 導航，確保用戶可以返回到先前的頁面，符合導航設計的使用體驗。
    static func navigateToSignUp(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let signUpViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.signUpViewController) as? SignUpViewController else {
            print("無法實例化 SignUpViewController")
            return
        }
        
        viewController.navigationController?.pushViewController(signUpViewController, animated: true)
    }

    // MARK: - navigateToLogin
    
    /// 登出後，導航至 HomePageViewController，並設置為應用的主頁面。
    ///
    /// - Parameters:
    ///   - viewController: 當前的視圖控制器，作為導航的起點。
    ///
    /// 此方法將 HomePageViewController 包裹於 UINavigationController 中，並使用淡入淡出的動畫效果切換畫面。
    static func navigateToLogin(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let homePageViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageViewController) as? HomePageViewController else {
            print("無法實例化 HomePageViewController")
            return
        }
        
        // 設置 rootViewController
        let navigationController = UINavigationController(rootViewController: homePageViewController)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("無法取得有效的 UIWindow")
            return
        }
        
        // 使用系統預設動畫：淡入淡出
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = navigationController
        }, completion: nil)
    }

}


