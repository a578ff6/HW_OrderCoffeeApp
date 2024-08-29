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
struct Constants {
    
    /// 定義結構 Storyboard，用於存放與 Storyboard 相關的常數
    struct Storyboard {
        
        static let homePageViewController = "HomePageViewController"
        static let loginViewController = "LoginViewController"
        static let signUpViewController = "SignUpViewController"
        static let forgotPasswordViewController = "ForgotPasswordViewController"
    
        static let mainTabBarController = "MainTabBarController"
        static let menuCollectionViewController = "MenuCollectionViewController"
        static let drinkDetailViewController = "DrinkDetailViewController"
        
        static let editProfileViewController = "EditProfileViewController"
    }
}
