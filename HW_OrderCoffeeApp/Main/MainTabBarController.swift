//
//  MainTabBarController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/4.
//


/*
 
 ## MainTabBarController：
 
    - 因為 App 會有多個 ViewController（EX: 菜單頁面、個人頁面、訂單頁面等），並且他們通過 UITabBarController 連結。
    - 因此在用戶登入或註冊成功後直接導航到包含 TabBarController 的 主視圖控制器。
    - 只需要將 UserDetails 數據傳遞到主視圖控制器，然後讓其將數據傳遞給其他子視圖控制器。
 
    * 功能：
        - 在用戶註冊或登入成功後，導航到包含 MainTabBarController 的主頁面，並將用戶資訊傳遞給各個子視圖控制器。
        - 管理 Tab Bar 上的 badge，根據訂單數量變化即時更新顯示。

    * 視圖設置：
        - 當 MainTabBarController 被初始化時，通過 passUserDetailsToChildren() 方法將用戶資訊傳遞給所有子視圖控制器。
        - 通過 setupOrderBadgeListener() 方法設置訂單更新監聽器，確保在訂單變動時更新 Tab Bar 上的訂單數量 badge。

    * 用戶資訊傳遞：
        - 將用戶資訊集中在 UITabBarController 管理，使得訊息傳遞和管理更加集中。通過在 UITabBarController 中傳遞用戶資訊，避免在每個 ViewController 之間手動傳遞資訊，簡化過程。
        - 將用戶詳細資訊 (UserDetails) 傳遞給所有子視圖控制器，使每個子視圖都能夠根據用戶資訊進行個性化顯示或操作。
        - 使用 UserDetailsReceiver 協定來處理「子視圖控制器」接收「用戶資訊」的邏輯。

    * 訂單 badge 更新：
        - 監聽訂單變化通知（orderUpdatedNotification），每當訂單數量變化時，通過 updateOrderBadge() 更新 Tab Bar 的 badge，顯示當前訂單數量。

 ## 使用的自定義功能：

    * UserDetailsReceiver 協定：
        - 子視圖控制器通過實現該協定，接收來自 MainTabBarController 傳遞的用戶詳細資訊。

 ## 主要功能概述：
 
    * 用戶資訊傳遞流程：
        - 使用 passUserDetailsToChildren() 方法遍歷所有子視圖控制器，檢查是否是 UINavigationController。
        - 若是 UINavigationController，則進一步檢查其根視圖控制器是否實現了 UserDetailsReceiver 協定。
        - 實現協定的視圖控制器會通過 receiveUserDetails(_:) 方法接收用戶詳細資訊。
 
    * 資訊傳遞具體步驟：
        1. 用戶註冊、登入成功後，將用戶資訊傳遞給 UITabBarController：
            - 在登入或註冊 ViewController 中獲取用戶資訊後，導航到 UITabBarController 並將用戶資訊傳遞過去。
  
        2. 在 UITabBarController 中接收並管理用戶資訊：
            - 建立或更新 MainTabBarController，添加一個屬性來存取用戶資訊，並在 viewDidLoad 中將用戶資訊傳遞給各個子視圖控制器。
     
        3. 在各個子視圖控制器中接手並使用用戶資訊：
            - 如 MenuCollectionViewController、ProfileViewController 和 OrdersViewController，已接收並使用 UITabBarController 傳遞過來的用戶資訊。
 
    * 訂單數量 badge 更新：
        - 當訂單數量發生變化時，會觸發 updateOrderBadge() 方法，該方法根據當前訂單數量動態更新 Tab Bar 上的 badge 值。
        - 如果訂單數量為 0，badge 將被隱藏；否則，badge 顯示訂單數量。

 ## 流程概述：

    * 導航與初始化：
        - 當用戶註冊或登入成功後，會從登入頁面導航到 MainTabBarController，並將用戶詳細資訊傳遞過去。

    * 用戶資訊傳遞：
        - MainTabBarController 在 viewDidLoad 方法中，調用 passUserDetailsToChildren()，將用戶資訊傳遞給各個子視圖控制器。

    * 訂單數量監聽與更新：
        - setupOrderBadgeListener() 會註冊一個「通知監聽器」，當訂單數量發生變化時，更新 Tab Bar 上的 badge，使用戶隨時了解訂單數量。
 
 -----------------------------------------------------------------------------------------------------------------------------------------------------------
 
 ## 使用 SceneDelegate 與 MainTabBarController 處理 TabBar 的 Badge 更新差異筆記： 
   （原先參考蘋果官方教材 （https://reurl.cc/Mj3D3v） 先前筆記，但與我使用「註冊/登入」的流程不同。）

    * SceneDelegate 的角色：
        - 在 App 使用多個場景（如多窗口）的情況下，SceneDelegate 用於管理 App 的場景生命周期。
        - 當 App 啟動時，SceneDelegate 負責初始化並監聽整個應用的事件（例如 badge 更新）。
        - 適合全局性或與場景相關的行為監聽，如背景、前景切換。

    * MainTabBarController 的角色：
        - 當 App 的主要頁面是以 TabBarController 為核心，且需要在頁面內部（例如登錄後）進行 badge 的更新，應將邏輯放在 MainTabBarController 中。
        - 因為 TabBarController 是 App 的導航中心，直接在這裡處理與 TabBarItem 相關的更新，能確保導航後仍能處理更新事件。
 
    * 流程與差異：
        - SceneDelegate 處理： 適合 App 啟動時初始化，但若 App 的頁面流程如登入、註冊後再進入 MainTabBarController，由於 SceneDelegate 在這個過程中無法得知 TabBarController 的切換，可能會導致 badge 無法及時更新。
        - MainTabBarController 處理： 因為 MainTabBarController 是在使用者進入主要頁面後才被呈現，將 badge 監聽與更新的邏輯放在這裡，更能符合 App 的導航流程及時反應訂單狀態。

    * 改善實踐：
        - 若 App 有註冊、登入等流程，且 MainTabBarController 是進入主要頁面的入口，則應在 MainTabBarController 中監聽訂單更新並處理 badge，以確保用戶登入後功能正常運作。
 
 */

import UIKit

/// 用戶註冊、登入成功後，將用戶資訊傳遞給 UITabBarController
class MainTabBarController: UITabBarController {
    
    // MARK: - Properties

    /// 用戶詳細資訊，將會傳遞給子視圖控制器
    var userDetails: UserDetails?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        passUserDetailsToChildren()
        setupOrderBadgeListener()
        
        // 使用 userDetails 進行初始化操作（測試）
        if let userDetails = userDetails { print("User logged in: \(userDetails.fullName)") }
    }
    
    // MARK: - Helper Functions

    /// 傳遞用戶資訊到所有子視圖控制器
    private func passUserDetailsToChildren() {
        guard let viewControllers = viewControllers else { return }
        
        // 尋找所有的 UINavigationController 並將用戶資訊傳遞給第一個視圖控制器
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController,
               let rootController = navController.viewControllers.first as? UserDetailsReceiver {
                rootController.receiveUserDetails(userDetails)
            }
        }
    }
    
    /// 設置`訂單更新`的 `badge 監聽器`，隨訂單數量變化更新 Tab Bar 上的 badge
    private func setupOrderBadgeListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrderBadge), name: .orderUpdatedNotification, object: nil)
    }
    
    /// 更新訂單數量的 badge
    ///
    /// 如果訂單數量為 0 則隱藏 badge，否則顯示訂單數量
    @objc private func updateOrderBadge() {
        let itemCount = OrderItemManager.shared.orderItems.count
        self.viewControllers?[1].tabBarItem.badgeValue = itemCount == 0 ? nil : "\(itemCount)"
    }

}
