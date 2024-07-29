//
//  MainTabBarController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/4.
//


/*

 因為 App 會有多個 ViewController（EX: 菜單頁面、個人頁面、訂單頁面等），並且他們通過 UITabBarController 連結，因此在用戶登入或註冊成功後直接導航到包含 TabBarController 的 主視圖控制器。
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
 */

import UIKit

class MainTabBarController: UITabBarController {
    
    var userDetails: UserDetails?

    override func viewDidLoad() {
        super.viewDidLoad()
        passUserDetailsToChildren()
        
        // 使用 userDetails 進行初始化操作（測試）
        if let userDetails = userDetails {
            print("User logged in: \(userDetails.fullName)")
        }
    }
    
    private func passUserDetailsToChildren() {
        guard let viewControllers = viewControllers else { return }
        
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController,
               let rootController = navController.viewControllers.first {
                
            }
        }
    }

}

// MARK: - 重要
/*
 import UIKit
 class MainTabBarController: UITabBarController {

     var userDetails: UserDetails?
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // 傳遞 userDetails 給子視圖控制器
         if let viewControllers = viewControllers {
             for viewController in viewControllers {
                 if let navController = viewController as? UINavigationController,
                    let rootViewController = navController.viewControllers.first as? UserDetailHandling {
                     rootViewController.userDetails = userDetails
                 }
             }
         }
     }
 }

 /// 供需要處理用戶詳細資料的視圖控制器實現
 protocol UserDetailHandling {
     var userDetails: UserDetails? { get set }
 }

 */


// MARK: - 相關視圖控制器實現 UserDetailHandling 協議

// 確保需要使用 userDetails 的視圖控制器實現 UserDetailHandling 協議：

/*
 import UIKit

 class ProfileViewController: UIViewController, UserDetailHandling {
     
     var userDetails: UserDetails?
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // 使用 userDetails 進行配置
         if let userDetails = userDetails {
             // 配置視圖
         }
     }
 }

 class OrderViewController: UIViewController, UserDetailHandling {
     
     var userDetails: UserDetails?
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // 使用 userDetails 進行配置
         if let userDetails = userDetails {
             // 配置視圖
         }
     }
 }

 */
