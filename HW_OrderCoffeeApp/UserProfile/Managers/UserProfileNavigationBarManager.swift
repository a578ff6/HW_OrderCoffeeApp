//
//  UserProfileNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/10.
//

// MARK: - 分離 Tab Bar 和 Navigation Bar 標題設定 （重要）
/**
 
 ## 筆記：分離 Tab Bar 和 Navigation Bar 標題設定
 
 - 在` Main Storyboard` 上，我已經將` Tab Bar Item `的名稱設置為 `Profile`。
 - 而在程式碼中，我在 `UserProfileViewController` 裡將 `UIViewController` 的 `title` 屬性設置為 `User Profile`，以顯示在 `Navigation Ba`r 中。
 - 因為 `iOS 預設情況`下，`UIViewController` 的` title` 屬性會同時影響 `Navigation Bar` 的標題 和 `Tab Bar Item` 的標題。
 - 所以當我點擊 `Tab Bar Item `進入到 `UserProfileViewController` 時，Tab Bar Item 的名稱從 `Profile` 被改為` User Profile`。
 - 這種行為是由於 `title` 和 `tabBarItem.title` 預設同步所導致的。
 
 ---------------------------


 `* 問題 (What)`
 
 - 當使用者點擊 `Profile` tab 項目進入到 `UserProfileViewController` 時，發現 `tab bar item` 的名稱會從原本設定的 "`Profile`" 變成 "`User Profile`"。
 
 ---------------------------

 `* 原因 (Why)`
 
 - 這個問題的發生是因為 iOS 的 `UIViewController` 中 `title` 屬性同時影響了：
 
 1. Navigation Bar 的標題 (`navigationItem.title`)
 2. Tab Bar 的標題 (`tabBarItem.title`)

 - 在 `UserProfileViewController` 中，
 - 這行程式碼將 `title` 設為 "`User Profile`"，導致 `Tab Bar` 的 `tabBarItem.title` 也被同步修改。
 - 這是 iOS 的預設行為，當 `title` 被改變時，如果沒有特別指定 `tabBarItem.title`，兩者會保持一致。
 
 ```swift
 /// 設置導航欄的標題
 private func setupNavigationTitle() {
     title = "User Profile"     // 這行程式碼影響
     self.navigationController?.navigationBar.prefersLargeTitles = true
     self.navigationItem.largeTitleDisplayMode = .always
 }
 ```
 
 ---------------------------

 `* 解決方式 (How)`
 
 - 要解決這個問題並保留 `Tab Bar` 的名稱為 "`Profile`"，而 `Navigation Bar` 顯示 "`User Profile`"，可以透過以下步驟進行：

 
 `方法一：`
 
 - 分開設置 `navigationItem.title` 和 `tabBarItem.title`
 - 在 `UserProfileViewController` 中：

 ```swift
 override func viewDidLoad() {
     super.viewDidLoad()
     
     // 設置 Navigation Bar 的標題
     self.navigationItem.title = "User Profile" // 僅影響 Navigation Bar

     // 確保 Tab Bar 的標題不變
     self.tabBarItem.title = "Profile"
 }
 ```

 `方法二：`
 
 - 在 `MainTabBarController` 確保 Tab Bar 標題
 - 在 `MainTabBarController` 中初始化 Tab Bar 項目時，明確設定每個 tab 的標題：

 ```swift
 override func viewDidLoad() {
     super.viewDidLoad()

     if let viewControllers = self.viewControllers {
         viewControllers[TabIndex.profile.rawValue].tabBarItem.title = "Profile"
     }
 }
 ```

 `方法三：`
 
 - 避免修改 `title`，僅修改 `navigationItem.title`
 - 如果不需要使用 `title` 來設置 `Navigation Bar `的標題，可以直接設定 `navigationItem.title`：

 ```swift
 private func setupNavigationTitle() {
     self.navigationItem.title = "User Profile" // 僅影響 Navigation Bar 標題
     self.navigationController?.navigationBar.prefersLargeTitles = true
     self.navigationItem.largeTitleDisplayMode = .always
 }
 ```

 ---------------------------

 `* 補充說明`
 
 - 這種分開設置 `tabBarItem.title` 和 `navigationItem.title` 的情況是非常常見的設計需求。例如：
 - Tab Bar 簡潔顯示 "Profile"，而頁面標題提供更多上下文，如 "User Profile"。
 - Tab Bar 顯示 "Orders"，頁面標題可能顯示 "My Recent Orders"。

 通過以上方式，可以達到 Tab Bar 和 Navigation Bar 標題的分離，提升用戶體驗和設計一致性。
 */

// MARK: - (v)
import UIKit

/// 負責設置 UserProfile 頁面的導航欄邏輯
class UserProfileNavigationBarManager {
    
    // MARK: - Properties
    private weak var navigationItem: UINavigationItem?
    private weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationItem: UINavigationItem?, navigationController: UINavigationController?) {
        self.navigationItem = navigationItem
        self.navigationController = navigationController
    }
    
    // MARK: - Configuration Methods

    /// 配置導航欄標題
    ///
    /// - Parameters:
    ///   - title: 導航欄標題文字
    ///   - prefersLargeTitles: 是否使用大標題模式，默認為 `true`
    func configureNavigationBarTitle(title: String, prefersLargeTitles: Bool = true) {
        navigationItem?.title = title
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        navigationItem?.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
    }
}
