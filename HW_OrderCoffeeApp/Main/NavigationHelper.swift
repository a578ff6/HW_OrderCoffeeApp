//
//  NavigationHelper.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/14.
//

/*

 根據使用者體驗、App邏輯選擇適合的導航方式。只要「避免產生堆棧問題」和「不必要的內存佔用」，就可以使用不同的導航方式。
 
 1. 選擇導航方式：
    * push 和 pop：
        - 適用於需要在導航欄中顯示back按鈕的情況，如一個 ViewController 在邏輯上是另一個 ViewController 的延續。
  
    * present 和 dismiss：
        - 適用於 modallypresent 展示的情況，如彈出一個「獨立」的功能 ViewController，不需要在導航欄中顯示back按鈕。
 
 2. 避免堆棧問題：
    * 避免循環導航，即確保使用者可以順利返回上一級 ViewController 而不會陷入無限循環！！
    * 控制導航堆棧的深度，變免不必要的 ViewCOntroller 留在堆棧中。
 
 3. 使用者體驗：
    * 確保導航方式符合使用者預期，back按鈕和關閉按鈕應在適當的地方出現。
    * 使用 push 導航時，自動顯示的 back 按鈕提供了一致的導航體驗。
    * present 時，添加明確的關閉或返回按鈕，確保用戶知道如何返回。
 
 4. 我的使用場景：
    * 用戶註冊和登入流程：
        - 從 HomeViewController 到 LoginViewController 和 SignUpViewController 可以使用 push，確保用戶可以通過 back 回到主頁面。
 
        - 在 LoginViewController 中，使用 present 道行進入 ForgotPasswordViewController，並在 ForgotPasswordViewController 提供關閉按鈕，通過 dismiss 返回！
 
 5. 嵌入 NavigtaionController ：
    * 因為我在 ForgotPasswordViewController 的部分，雖然是使用 present 呈現 large。
    * 但我又希望在 ViewController 中顯示 NavigtaionBar 和關閉按鈕，因此需要將其嵌入 NavigtaionController 中。
    * 即使嵌入 NavigtaionController，仍然可以使用 dismiss 來關閉 modallypresent 視圖，避免堆棧問題。
 
*/
  
  


import UIKit

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
            
            // 取得目前活躍的UIWindowScene，並設置 rootViewController
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
     
    /// 到 LoginViewController（使用 present ）
    static func navigateToLogin(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as?
            LoginViewController {
            loginViewController.modalPresentationStyle = .fullScreen
            viewController.present(loginViewController, animated: true, completion: nil)
        }
    }
    
}
