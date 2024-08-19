//
//  MainTabBarController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/4.
//


/*
 A. 因為 App 會有多個 ViewController（EX: 菜單頁面、個人頁面、訂單頁面等），並且他們通過 UITabBarController 連結，因此在用戶登入或註冊成功後直接導航到包含 TabBarController 的 主視圖控制器。
    因此只需要將 UserDetails 數據傳遞到主視圖控制器，然後讓其將數據傳遞給其他子視圖控制器。
 
 1. 通過使用 UITabBarController 管理多個 ViewController，並在用戶燈入或註冊成功後將用戶資訊傳遞給 UITabBarController。
    - 集中管理：
        - 將用戶資訊集中在 UITabBarController 管理，使得訊息傳遞和管理更加集中。
    
    - 簡化資訊傳遞：
        - 通過在 UITabBarController 中傳遞用戶資訊，避免在每個 ViewController 之間手動傳遞資訊，簡化過程。
 
2. 具體步驟：
    - 用戶註冊、登入成功後，將用戶資訊傳遞給 UITabBarController：
        - 在登入或註冊 ViewController 中獲取用戶資訊後，導航到 UITabBarController 並將用戶資訊傳遞過去。
 
    - 在 UITabBarController 中接收並管理用戶資訊：
        - 建立或更新 MainTabBarController ， 添加一個屬性來存取用戶資訊，並在 viewDidLoad 中將用戶資訊傳遞給各個子視圖控制器。
    
    - 在各個子視圖控制器中接手並使用用戶資訊：
        - 如 MenuCollectionViewController、ProfileViewController 和 OrdersViewController，已接收並使用 UITabBarController 傳遞過來的用戶資訊。
 
 3. 流程：
    - 登入或註冊成功後，MainTabBarController 被初始化並顯示。
    - 在 viewDidLoad 方法中，passUserDetailsToChildren() 會被調用，這個方法的目的是將用戶資訊 (userDetails) 傳遞到 UITabBarController 內的所有子視圖控制器。
    - passUserDetailsToChildren() 方法遍歷 UITabBarController 的所有子視圖控制器，並檢查它們是否為 UINavigationController。
    - 對於每個 UINavigationController，它會取得其根視圖控制器並檢查是否符合 UserDetailsReceiver 協定。
    - 如果符合協定，則調用 receiveUserDetails(_:) 方法，將 userDetails 傳遞給根視圖控制器。
 */

import UIKit

/// 用戶註冊、登入成功後，將用戶資訊傳遞給 UITabBarController
class MainTabBarController: UITabBarController {
    
    /// 用戶詳細資訊，將會傳遞給子視圖控制器
    var userDetails: UserDetails?

    override func viewDidLoad() {
        super.viewDidLoad()
        passUserDetailsToChildren()             // 傳遞用戶資訊到子視圖控制器
        
        // 使用 userDetails 進行初始化操作（測試）
        if let userDetails = userDetails {
            print("User logged in: \(userDetails.fullName)")
        }
    }
    
    /// 傳遞用戶資訊到所有子視圖控制器
    private func passUserDetailsToChildren() {
        guard let viewControllers = viewControllers else { return }
        
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController,
               let rootController = navController.viewControllers.first as? UserDetailsReceiver {
                rootController.receiveUserDetails(userDetails)
            }
        }
    }

}
