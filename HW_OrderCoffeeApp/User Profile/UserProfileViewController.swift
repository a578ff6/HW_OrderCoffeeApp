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
 
 ----------------------
 
 設置步驟：
 先處理顯示使用者資料的功能。確保頁面能正確顯示使用者的基本資訊，後續添加其他功能（選取照片功能）

 大致流程：
 設置Firebase連接，並且在使用者登入後正確地從後端獲取資料。
 將資料顯示在個人資料頁面上，確保資料的顯示格式、佈局和邏輯都正確。
 確認資料顯示無誤後，再處理選取照片的功能，讓使用者可以修改他們的個人資料照片。
 
 ------------------------- ------------------------- ------------------------- -------------------------

 A. UserProfileViewController 負責顯示使用者的個人資訊，如名稱、電子郵件和頭像。這個視圖控制器會接收來自其他視圖控制器的使用者資訊，並在畫面上顯示。

 * 配置方法 (Configuration):
    - 根據 userDetails 的內容來設置 UI 元素的顯示。如果 userDetails 為 nil，顯示預設值。若 userDetails 包含頭像圖片 URL，使用 Kingfisher 加載圖片，否則顯示預設圖片。
 
 * 協議實現 (UserDetailsReceiver):
    - receiveUserDetails(_:)：接收使用者資訊，並將其存儲在 userDetails 屬性中。接收到資料後，會調用 configureUserData() 更新 UI 顯示。
 
 
 B. 「receiveUserDetails 中的 configureUserData」 和 「viewDidLoad 中的 configureUserData」 兩者的觸發時機和使用情境差異。
 
    * 觸發時機：
        - viewDidLoad 中的 configureUserData 是在視圖載入時設定初始狀態。
        - receiveUserDetails 中的 configureUserData 是在收到新的使用者資訊時更新 UI。
 
    * 使用情境：
        - viewDidLoad 中的 configureUserData 主要用於設置視圖載入時的預設資料或狀態。
        - receiveUserDetails 中的 configureUserData 用於根據最新的使用者資訊更新 UI 顯示。

 ------------------------- ------------------------- ------------------------- -------------------------

 */


import UIKit
import Kingfisher
import Firebase


/// 個人資訊頁面
///
/// `UserProfileViewController` 顯示使用者的個人資訊，包括名字、電子郵件和頭像。這個視圖控制器會在載入時設置使用者資料，並且實現 `UserDetailsReceiver` 協議來接收來自其他視圖控制器的使用者資訊。
class UserProfileViewController: UIViewController {

    // MARK: - Properties
    
    /// 用來顯示個人資訊的自定義視圖
    private let userProfileView = UserProfileView()
    
    /// 保存使用者詳細資訊
    private var userDetails: UserDetails?

    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        view = userProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserData()
        
    }
    
    
    // MARK: - Configuration

    /// 設置使用者資料顯示在視圖上
    ///
    /// 若 `userDetails` 有值，則使用其資料填充 `userProfileView` 的相關 UI 元件。否則，顯示預設圖片或文字。
    private func configureUserData() {
        guard let userDetails = userDetails else {
            userProfileView.nameLabel.text = "userName"
            userProfileView.emailLabel.text = "user@example.com"
            userProfileView.profileImageView.image = UIImage(systemName: "person.fill")
            return
        }
        
        userProfileView.nameLabel.text = userDetails.fullName
        userProfileView.emailLabel.text = userDetails.email
        if let profileImageURL = userDetails.profileImageURL {
            userProfileView.profileImageView.kf.setImage(with: URL(string: profileImageURL))
        } else {
            userProfileView.profileImageView.image = UIImage(systemName: "person.fill")
        }
    }

}

// MARK: - UserDetailsReceiver Delegate

extension UserProfileViewController: UserDetailsReceiver {
    
    func receiveUserDetails(_ userDetails: UserDetails?) {
        self.userDetails = userDetails
        configureUserData()                     // 在接收到使用者資訊後更新 UI
    }
    
}
