//
//  NavigationHelper.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/14.
//

/*

 ## 根據使用者「體驗App邏輯」選擇適合的導航方式。只要「避免產生堆棧問題」和「不必要的內存佔用」，就可以使用不同的導航方式。
 
 1. 選擇導航方式：
    * push 和 pop：
        - 適用於需要在「導航欄」中顯示back按鈕的情況，如一個 ViewController 在邏輯上是另一個 ViewController 的延續。
        - 畫面之間有邏輯延續關係，且需要顯示返回按鈕的情況。常見於一層一層深入的結構，比如從列表點進去查看詳細資料。

    * present 和 dismiss：
        - 適用於 modallypresent 展示的情況，如彈出一個「獨立」的功能 ViewController，不需要在導航欄中顯示back按鈕。
        - 適合獨立功能模組的展示，如使用模態方式彈出視圖控制器。這些畫面不需要返回按鈕，且通常有獨立的關閉方式（例如 "取消" 按鈕）。
 
    * 使用模態呈現 (present) 時：
        - 可以考慮移除 Storyboard 中的 Segue，直接用程式碼處理畫面呈現邏輯，這樣更具彈性。
        - 但當有些畫面轉換是頻繁或簡單的情境，保留 Storyboard Segue 使用 performSegue 是更方便的選擇。

 
 2. 避免堆棧問題：
    * 避免循環導航，即確保使用者可以順利返回上一級 ViewController 而不會陷入無限循環！！
    * 控制導航堆棧的深度，變免不必要的 ViewCOntroller 留在堆棧中。
 
 3. 使用者體驗：
    * 符合使用者預期：
        - 使用 push 導航時，系統自動顯示 back按鈕 ，給予一致的導航體驗。（「back按鈕」和 「關閉按鈕」 應在適當的地方出現。）

    * 模態呈現 (present) 時：
        - 應在畫面中 「提供」 明確的關閉或返回按鈕，讓使用者能快速瞭解如何返回上一頁。
 
 4. 我的使用場景：
    * 用戶註冊和登入流程：
        - 從 HomeViewController 到 LoginViewController 和 SignUpViewController 可以使用 push，確保用戶可以通過 back 回到主頁面。
 
        - 在 LoginViewController 中，使用 present 道行進入 ForgotPasswordViewController，並在 ForgotPasswordViewController 提供關閉按鈕，通過 dismiss 返回！
 
 5. 嵌入 NavigtaionController ：
    * 因為我在 ForgotPasswordViewController 的部分，雖然是使用 present 呈現 large。
    * 但我又希望在 ViewController 中顯示 NavigtaionBar 和關閉按鈕，因此需要將其嵌入 NavigtaionController 中。
    * 即使嵌入 NavigtaionController，仍然可以使用 dismiss 來關閉 modallypresent 視圖，避免堆棧問題。
 
 ------------------------- ------------------------- ------------------------- -------------------------

 A.登出功能相關邏輯：
 
    * 重設根視圖控制器：
        - 在用戶成功登出後，重設 App 的根視圖控制器為 HomePageViewController，這樣可以完全清除 MainTabBarController 及其子視圖控制器的狀態，避免它們在後台繼續存在。

 
*/


import UIKit

/// 負責處理 App 內的各種導航操作，如登入、登出、頁面跳轉等。
class NavigationHelper {
    
    /// 登入、註冊成功後，進行跳轉頁面
    /// - Parameters:
    ///   - viewController: 目前的視圖控制器
    ///   - userDetails: 使用者的詳細資訊，將傳遞給 MainTabBarController
    static func navigateToMainTabBar(from viewController: UIViewController, with userDetails: UserDetails) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBarController) as? MainTabBarController {
            // 將使用者資訊傳遞給 MainTabBarController
            mainTabBarController.userDetails = userDetails
            mainTabBarController.modalPresentationStyle = .fullScreen
            
            // 取得目前的 UIWindowScene，並設置 rootViewController
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = .moveIn
                transition.subtype = .fromTop
                window.layer.add(transition, forKey: kCATransition)
                window.rootViewController = mainTabBarController
            } else {
                viewController.present(mainTabBarController, animated: true, completion: nil)
            }
        }
    }
    
    /// 跳轉到 ForgotPasswordViewController （使用 present ）
    /// 將其坎 入NavigtaionController，因為有設置關閉按鈕在 Navigationbar
    static func navigateToForgotPassword(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let forgotPasswordVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.forgotPasswordViewController) as? ForgotPasswordViewController {
            forgotPasswordVC.modalPresentationStyle = .pageSheet
            let navController = UINavigationController(rootViewController: forgotPasswordVC)
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
            }
            viewController.present(navController, animated: true, completion: nil)
        }
    }
    
    /// 跳轉到 signUpViewController（ 使用 push 進行導航，確保顯示返回按鈕）
    static func navigateToSignUp(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.signUpViewController) as? SignUpViewController {
            viewController.navigationController?.pushViewController(signUpViewController, animated: true)
        }
    }
    
    /// 登出後，將 App 的根視圖控制器完全重設為 HomePageViewController
    ///
    /// - Parameters:
    ///   - viewController: 當前的視圖控制器
    static func navigateToLogin(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homePageViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageViewController) as? HomePageViewController {
            
            let navigationController = UINavigationController(rootViewController: homePageViewController)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            
            // 設置根視圖控制器為包含 HomePageViewController 的導航控制器
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
}
