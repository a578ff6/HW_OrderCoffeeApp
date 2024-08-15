//
//  UserProfileViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/14.
//

/*
 大頭照、使用者名稱、信箱
 
 按鈕：
 編輯使用者資料（地址、電話、使用者名稱）
 
 歷史訂單
 
 我的最愛
 
 登出按鈕
 */


import UIKit

/// 個人資訊頁面
class UserProfileViewController: UIViewController {

    // MARK: - Properties
    private let userProfileView = UserProfileView()
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = userProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserData()
        
    }
    
    
    // MARK: - Configuration
    private func configureUserData() {
        // 模擬這些資料是從資料模型中取得的（測試觀察用）
        userProfileView.nameLabel.text = "userName"
        userProfileView.emailLabel.text = "user@example.com"
        userProfileView.profileImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
    }

}

