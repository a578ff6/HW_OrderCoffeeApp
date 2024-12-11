//
//  UserProfileTableHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/10.
//

// MARK: - 重點筆記：UserProfileTableHandlerDelegate 的設計理念與實現

/**
 
 ## 重點筆記：UserProfileTableHandlerDelegate 的設計理念與實現
 
 `* What`

 - `UserProfileTableHandlerDelegate` 是一個協議，負責作為 `UserProfileTableHandler` 與 `UserProfileViewController` 的溝通橋樑。
 
 - 它涵蓋了以下功能：
 
 1.提供用戶資料（如姓名、電子郵件）以支援表格顯示。
 2.處理點擊行為，進行頁面導航（如編輯個人資料、我的最愛）。
 3.管理登出操作與處理社交連結的點擊事件。
 
 -----------------------
 
 `* Why`

 `1.職責分工：`
 
 - 通過 `Delegate`，將列表顯示邏輯與互動邏輯分離。
 - `UserProfileTableHandler` 專注於管理列表的顯示，具體的行為操作則委派給 ViewController。
 
 `2.單一責任：`
 
 - `TableHandler` 僅處理表格的視圖邏輯，`ViewController` 負責具體業務邏輯和頁面導航。
 
 `3.靈活性與擴展性：`
 
 - 透過協議方法，方便添加新功能（例如新增頁面跳轉或更多社交媒體支持）。
 
 -----------------------

 `* How`

 `1.協議定義：`

 - 設計清晰且專注的方法集合，涵蓋：
    - 資料提供（getUserProfile）
    - 導航操作（如 navigateToEditProfile）
    - 社交連結點擊行為處理（didSelectSocialLink）
 
` 2.實現方式：`

 - 在 `UserProfileViewController` 實現協議方法，處理具體行為邏輯。
 - 將 `UserProfileTableHandler` 的 `delegate` 設為 `UserProfileViewController`。
 
 ```swift
 tableHandler.delegate = self
 ```
 
 `3.資料提供：`

 - `getUserProfile` 方法直接返回當前用戶的個人資料，避免複雜的邏輯。
 - 補充說明：若需加強快取機制，可透過本地變數儲存。
 
 `4.互動處理：`

 - 確保頁面跳轉與業務邏輯分離，如：
    - `navigateToEditProfile` 負責進入編輯頁面。
    - `confirmLogout` 統一處理登出確認與邏輯。
 */

// MARK: - (v)

import Foundation

/// `UserProfileTableHandlerDelegate`
///
/// 此協議定義了 `UserProfileTableHandler` 與其委派之間的通訊介面，
/// 負責提供用戶資料、處理導航及互動行為，實現個人資料頁面與相關功能的解耦設計。
protocol UserProfileTableHandlerDelegate: AnyObject {
    
    /// 提供當前用戶的個人資料
    ///
    /// - Returns: 一個可選的 `UserProfile`，包含當前用戶的資料。
    /// - 用途: 用於更新表格內容，例如顯示用戶名稱或電子郵件。
    func getUserProfile() -> UserProfile?
    
    /// 導航至編輯個人資料頁面
    ///
    /// - 說明: 用於處理點擊「編輯個人資料」時的頁面跳轉。
    func navigateToEditProfile()
    
    /// 導航至我的最愛頁面
    ///
    /// - 說明: 用於處理點擊「我的最愛」時的頁面跳轉。
    func navigateToFavorites()
    
    /// 導航至歷史訂單頁面
    ///
    /// - 說明: 用於處理點擊「歷史訂單」時的頁面跳轉。
    func navigateToOrderHistory()
    
    /// 確認並執行登出操作
    ///
    /// - 說明: 用於處理點擊「登出」時的確認彈窗及執行邏輯。
    func confirmLogout()
    
    /// 處理社交連結的點擊事件
    ///
    /// - Parameters:
    ///   - title: 連結的標題，例如 "Facebook" 或 "Instagram"。
    ///   - urlString: 連結的網址字串，用於開啟對應的外部網站。
    /// - 說明: 用於處理點擊社交媒體連結時的行為，例如顯示確認彈窗後跳轉至瀏覽器。
    func didSelectSocialLink(title: String, urlString: String)
    
}
