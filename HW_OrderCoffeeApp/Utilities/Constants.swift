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
        
        // MARK: - 主頁面、登入、註冊、忘記密碼相關
        
        static let homePageViewController = "HomePageViewController"
        static let loginViewController = "LoginViewController"
        static let signUpViewController = "SignUpViewController"
        static let forgotPasswordViewController = "ForgotPasswordViewController"
        
        // MARK: - MainTabBar
        
        static let mainTabBarController = "MainTabBarController"

        // MARK: - 菜單主頁、飲品資訊相關_(Menu)
        
        static let menuViewController = "MenuViewController"
        static let drinkDetailViewController = "DrinkDetailViewController"
        
        // MARK: - 編輯個人資料、我的最愛、歷史訂單、歷史訂單項目詳細資訊_(UserProfile)
        
        static let editProfileViewController = "EditProfileViewController"
        static let favoritesViewController = "FavoritesViewController"
        static let orderHistoryViewController = "OrderHistoryViewController"
        static let orderHistoryDetailViewController = "OrderHistoryDetailViewController"

        // MARK: - 編輯訂單、訂單使用者資訊、選取店家、訂單確認_(Order)
        
        static let editOrderItemViewController = "EditOrderItemViewController"
        static let orderCustomerDetailsViewController = "OrderCustomerDetailsViewController"
        static let storeSelectionViewController = "StoreSelectionViewController"
        static let orderConfirmationViewController = "OrderConfirmationViewController"
        
    }
    
    /// 定義結構 `Segue`，用於存放與 Segue 相關的常數
    ///
    /// 表示在 Storyboard 中設定的 Segue 的 Identifier，用來進行導航操作。
    struct Segue {
        static let categoryToDrinksSegue = "CategoryToDrinksSegue"
        static let drinksToDetailSegue = "DrinksToDetailSegue"
    }
    
}
