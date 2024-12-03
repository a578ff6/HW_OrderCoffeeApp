//
//  HomePageViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - HomePageViewController 筆記
/**
 ### HomePageViewController 筆記

 `1. 主視圖設定`
 
 - loadView() 方法：
    - 使用 `loadView()` 將 `HomePageView` 設置為主視圖，這樣在 `HomePageViewController` 中可以直接使用自訂的 HomePageView 作為主要的介面。

 `2. 委派設置`
 
 - setupActionHandler() 方法：
    - 將按鈕行為處理交給 `HomePageActionHandler`，這樣可以減少控制器內部對於按鈕點擊的直接處理，達到職責分離。
    - 初始化 `HomePageActionHandler`，並傳入 `HomePageView` 和 `HomePageViewDelegate`，確保按鈕行為被正確處理。

 `3. 頁面跳轉`
 
 - 跳轉至登入頁面和註冊頁面：
   - `navigateToLoginViewController()` 與 `navigateToSignUpViewController()` 兩個方法負責頁面跳轉。
   - 使用 `guard let` 安全地從 Storyboard 中實例化目標視圖控制器，確保型別正確且避免潛在的崩潰問題。
   - 如果找不到目標視圖控制器，會打印錯誤訊息以便調試。

 `4. 擴展委派實作`
 
 - HomePageViewDelegate 擴展：
   - 將按鈕點擊的處理邏輯放在 `HomePageViewDelegate` 的擴展中，方便管理與 HomePageView 的互動行為。
   - 如 `didTapLoginButton()` 和 `didTapSignUpButton()`，各自呼叫對應的導航方法來完成頁面跳轉。

 `5. 使用常量管理 Storyboard ID`
 
 - Constants.Storyboard：
    - 使用常量來管理 Storyboard ID，如 `Constants.Storyboard.loginViewController` 和 `Constants.Storyboard.signUpViewController`，這樣可以避免硬編碼造成的錯誤，同時更方便進行維護與修改。

 `6. 單一職責原則`
 
 - 遵循單一職責原則 (SRP)：
    - 按鈕的行為由 `HomePageActionHandler` 管理，頁面導航邏輯則由控制器負責。
    - 這樣的職責分離使得程式碼結構更加清晰，容易理解，也便於後續的維護與擴展。
 */

import UIKit

/// 選擇登入、註冊頁面
class HomePageViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 自定義的 `HomePageView`
    private let homePageView = HomePageView()
    
    /// `HomePageActionHandler` 負責處理按鈕行為
    private var actionHandler: HomePageActionHandler?
    
    // MARK: - Lifecycle Methods
    
    // 取得 HomePageView 作為主視圖
    override func loadView() {
        self.view = homePageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionHandler()
    }
    
    // MARK: - Setup Methods
    
    /// 初始化 `HomePageActionHandler` 並設置按鈕行為
     private func setupActionHandler() {
         actionHandler = HomePageActionHandler(view: homePageView, delegate: self)
     }
    
    // MARK: - Navigation Methods
    
    /// 跳轉到登入頁面
    private func navigateToLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as? LoginViewController else {
            print("找不到 LoginViewController")
            return
        }
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    /// 跳轉到註冊頁面
    private func navigateToSignUpViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let signUpViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.signUpViewController) as? SignUpViewController else {
            print("找不到 SignUpViewController")
            return
        }
        navigationController?.pushViewController(signUpViewController, animated: true)
    }

}

// MARK: - HomePageViewDelegate
extension HomePageViewController: HomePageViewDelegate {
    
    /// 按下登入按鈕的動作
    func didTapLoginButton() {
        navigateToLoginViewController()
    }
    
    /// 按下註冊按鈕的動作
    func didTapSignUpButton() {
        navigateToSignUpViewController()
    }
    
}
