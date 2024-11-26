//
//  Constants.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/15.
//


/*
 EX：在 Main.storyboard 中，為 MenuCollectionViewController 設置ID:
    - 在 "Storyboard ID" 中輸入相對應的名稱。例如："MenuCollectionViewController"。
 */


import UIKit

/// 處理與 Storyboard 相關的常數。
///
/// `Constants` 結構用來統一管理 App 中與 Storyboard 有關的所有「識別符號」，
/// 包括視圖控制器的識別符號、Segue 的識別符號，以及表格或集合視圖中的 Cell 識別符號。
struct Constants {
    
    /// 定義結構 `Storyboard`，用於存放與 Storyboard 相關的常數
    ///
    /// 表示在 Storyboard 中設定的視圖控制器的 Identifier，方便引用。
    struct Storyboard {
        
        // 主頁面、登入、註冊、忘記密碼相關
        static let homePageViewController = "HomePageViewController"
        static let loginViewController = "LoginViewController"
        static let signUpViewController = "SignUpViewController"
        static let forgotPasswordViewController = "ForgotPasswordViewController"
        
        static let mainTabBarController = "MainTabBarController"
        //static let menuCollectionViewController = "MenuCollectionViewController"
        static let menuViewController = "MenuViewController"

        static let drinkDetailViewController = "DrinkDetailViewController"
        
        static let editProfileViewController = "EditProfileViewController"
        static let favoritesViewController = "FavoritesViewController"
        
        static let orderCustomerDetailsViewController = "OrderCustomerDetailsViewController"
        
        static let storeSelectionViewController = "StoreSelectionViewController"
        
        static let orderConfirmationViewController = "OrderConfirmationViewController"
        
        static let orderHistoryViewController = "OrderHistoryViewController"
        
        static let orderHistoryDetailViewController = "OrderHistoryDetailViewController"
    }
    
    /// 定義結構 `Segue`，用於存放與 Segue 相關的常數
    ///
    /// 表示在 Storyboard 中設定的 Segue 的 Identifier，用來進行導航操作。
    struct Segue {
        static let categoryToDrinksSegue = "CategoryToDrinksSegue"
        static let drinksToDetailSegue = "DrinksToDetailSegue"
    }
    
}
