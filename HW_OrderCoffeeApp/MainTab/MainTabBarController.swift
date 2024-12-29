//
//  MainTabBarController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/4.
//

// MARK: - MainTabBarController 筆記
/**
 
 ## MainTabBarController 筆記
 
 - 因為 App 會有多個 ViewController（EX: 菜單頁面、個人頁面、訂單頁面等），並且他們通過 UITabBarController 連結。
 - 因此在用戶登入或註冊成功後直接導航到包含 `TabBarController` 的 主視圖控制器。
 
 `* What`
 
 1.在用戶完成註冊或登入後，應導航到 `MainTabBarController`，而非直接導航到子頁面的 `MenuViewController`。

 2.`MainTabBarController` 是應用的核心容器，負責管理多個功能模組頁面，包括：

 - Menu（飲品分類頁面）
 - Search（搜尋頁面）
 - Order（訂單頁面）
 - UserProfile（用戶個人資料頁面）
 
 3.`MenuViewController` 是 `MainTabBarController` 的子頁面，僅負責展示飲品分類，並不具備整體應用導航的能力。
 
 4.管理` Tab Bar `上的訂單數量 `Badge`，根據訂單變化即時更新顯示。
 
 ---------------

` * Why`
 
 `1.符合應用架構設計：`

 - `MainTabBarController` 是應用導航的核心，包含多個子頁面，確保用戶能輕鬆切換功能模組。
 - 若直接進入 `MenuViewController`，將失去其他頁面的可見性，破壞整體應用架構。
 
 `2.提升用戶體驗：`

 - 用戶登入後應能看到應用所有功能，而不僅限於某一個頁面（如 `MenuViewController`）。
 - 通過 `MainTabBarController`，用戶能快速切換到訂單、搜尋或個人資料頁面，提升使用效率。
 
 `3.責任清晰：`

 - `MainTabBarController` 管理整體導航，子頁面如 `MenuViewController` 負責特定的內容顯示與交互。
 - 確保各自的職責單一，便於維護與擴展。
 
 `4.方便擴展與維護：`

 - 將導航集中在 `MainTabBarController`，未來新增功能（如新增 Tab 頁面）時，不需要更改子頁面邏輯。
 - 減少各子頁面之間的耦合度，提高代碼可維護性。
 
 ---------------
 
 `* How`
 
` 1.設置導航到 MainTabBarController 的邏輯：`

 - 在用戶完成登入或註冊後，通過 `NavigationHelper` 導航到 `MainTabBarController`。
 
 ```
 static func navigateToMainTabBar(from viewController: UIViewController) {
 }
 ```
  
 -----
 
` 2.在 MainTabBarController 中負責 Tab 頁面管理：`

 - 添加 `Menu`、`Search`、`Order`、`UserProfile` 等頁面。
 - 確保每個 `Tab` 頁面自行處理與 `Firebase` 的資料請求，減少跨頁面數據依賴。
 
 -----

 `3.設置 MainTabBarController 的附加功能：`

 - 訂單數量 Badge 更新：
    - 使用 `NotificationCenter` 監聽訂單數量的變化，及時更新 `TabBar` 上的訂單 `Badge`。
    - 當訂單數量發生變化時，會觸發 updateOrderBadge() 方法，該方法根據當前訂單數量動態更新 Tab Bar 上的 badge 值。
    - 如果訂單數量為 0，badge 將被隱藏；否則，badge 顯示訂單數量。
 
 ```
 private func setupOrderBadgeListener() {
     NotificationCenter.default.addObserver(self, selector: #selector(updateOrderBadge), name: .orderUpdatedNotification, object: nil)
 }

 @objc private func updateOrderBadge() {
     let itemCount = OrderItemManager.shared.orderItems.count
     self.viewControllers?[TabIndex.order.rawValue].tabBarItem.badgeValue = itemCount == 0 ? nil : "\(itemCount)"
 }
```
 
 -----

 `4. 監聽與更新訂單數量 Badge 的步驟：`
 
 - 註冊 `orderUpdatedNotification` 通知，監控訂單數量的變化。
 - 每當訂單數量變化時，通過 `updateOrderBadge() 更新` `TabBar` 的 Badge，若訂單數量為 0，則隱藏 Badge。
 
 ---------------

 `* 流程概述：`
 
 `1.導航與初始化：`
 
 - 當用戶註冊或登入成功後，會從登入頁面導航到 MainTabBarController，並將用戶詳細資訊傳遞過去。

` 2.訂單數量監聽與更新：`
 
 - `setupOrderBadgeListener() `會註冊一個「通知監聽器」，當訂單數量發生變化時，更新 Tab Bar 上的 badge，使用戶隨時了解訂單數量

 */


// MARK: - 使用 SceneDelegate 與 MainTabBarController 處理 TabBar 的 Badge 更新差異筆記
/**
 
 ## 使用 SceneDelegate 與 MainTabBarController 處理 TabBar 的 Badge 更新差異筆記：

 - （原先參考蘋果官方教材 （https://reurl.cc/Mj3D3v） 先前筆記，但與我使用「註冊/登入」的流程不同。）

` 1.SceneDelegate 的角色：`
 
 - 在 App 使用多個場景（如多窗口）的情況下，SceneDelegate 用於管理 App 的場景生命周期。
 - 當 App 啟動時，SceneDelegate 負責初始化並監聽整個應用的事件（例如 badge 更新）
 - 適合全局性或與場景相關的行為監聽，如背景、前景切換。

 ----------
 
 `2.MainTabBarController 的角色：`
       
 - 當 App 的主要頁面是以 TabBarController 為核心，且需要在頁面內部（例如登錄後）進行 badge 的更新，應將邏輯放在 MainTabBarController 中。
 - 因為 TabBarController 是 App 的導航中心，直接在這裡處理與 TabBarItem 相關的更新，能確保導航後仍能處理更新事件。
 
 ----------

 `3.流程與差異：`
 
 - `SceneDelegate 處理：`
 
    - 適合 App 啟動時初始化，但若 App 的頁面流程如登入、註冊後再進入 MainTabBarController，由於 SceneDelegate 在這個過程中無法得知 TabBarController 的切換，可能會導致 badge 無法及時更新。
       
 - `MainTabBarController 處理：`
 
    - 因為 MainTabBarController 是在使用者進入主要頁面後才被呈現，將 badge 監聽與更新的邏輯放在這裡，更能符合 App 的導航流程及時反應訂單狀態。

 ----------

 `4.改善實踐：`
 
 - 若 App 有註冊、登入等流程，且 `MainTabBarController` 是進入主要頁面的入口，則應在 `MainTabBarController` 中監聽訂單更新並處理 badge，以確保用戶登入後功能正常運作。
 */


// MARK: - (v)

import UIKit

/// `MainTabBarController`
///
/// ### 功能描述
/// - 負責管理應用的主要導航架構，包含多個功能頁面（Menu、Search、Order、UserProfile）。
/// - 提供訂單數量的即時更新功能，透過 `Tab Bar` 上的 badge 提示用戶。
/// - 為應用提供統一的入口，便於用戶在各功能頁面之間快速切換。
class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle

    /// 視圖加載完成時的初始化操作
    ///
    /// - 設置訂單數量的 badge 監聽器，以確保 Tab Bar 的訂單頁面顯示正確的訂單數量。
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOrderBadgeListener()
    }
    
    // MARK: - Helper Functions
    
    /// 設置訂單更新監聽器
    ///
    /// - 功能：監聽 `orderUpdatedNotification` 通知，當訂單數量發生變化時，自動更新 Tab Bar 上的訂單數量 badge。
    private func setupOrderBadgeListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrderBadge), name: .orderUpdatedNotification, object: nil)
    }
    
    /// 更新 Tab Bar 上的訂單數量 badge
    ///
    /// - 功能：根據當前訂單數量，動態更新訂單頁面的 badge。
    ///   - 當訂單數量為 0 時，隱藏 badge。
    ///   - 當訂單數量大於 0 時，顯示對應的訂單數量。
    ///
    /// - 注意：`TabIndex.order.rawValue` 應對應 Tab Bar 中訂單頁面的索引，確保 badge 更新正確。
    @objc private func updateOrderBadge() {
        let itemCount = OrderItemManager.shared.orderItems.count
        self.viewControllers?[TabIndex.order.rawValue].tabBarItem.badgeValue = itemCount == 0 ? nil : "\(itemCount)"
    }

}
