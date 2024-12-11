//
//  UserProfileDataSource.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/10.
//

// MARK: - 重點筆記：UserProfileDataSource 的設計理念與實現
/**
 
 ## 重點筆記：UserProfileDataSource 的設計理念與實現
 
 `* What`
 
 - `UserProfileDataSource` 負責提供個人資料頁面的數據源，根據不同區域返回對應的行數據。

 `* Why`

 - `數據集中管理`：將數據邏輯與顯示邏輯分離，便於擴展與維護。
 - `支援多樣行為`：結合 `GeneralOptionAction` 和 `urlString`，支援應用內操作與外部連結。
 
 `* How`

 `1.實現集中數據管理`

 - 使用 `rows(for:) `方法根據區域返回行數據。
 - 利用 `UserProfileRow` 提供統一的數據結構。
 
 `2.分離不同區域數據邏輯`

 - 使用 switch 根據區域返回不同行數據。
 - 區分應用內行為（`action`）和外部連結（`urlString`）。
 */

// MARK: - (v)

import UIKit

/// 負責提供個人資料頁面的行數據
///
/// 此類通過 `UserProfileRow` 和 `UserProfileSection` 提供數據源，
/// 協助 TableView 管理每一行的顯示內容。
class UserProfileDataSource {
    
    /// 根據指定區域返回對應的行數據
    ///
    /// - Parameter section: 指定的頁面區域。
    /// - Returns: 包含該區域行數據的陣列，每一行由 UserProfileRow 定義。
    func rows(for section: UserProfileSection) -> [UserProfileRow] {
        switch section {
            
        case .userInfo:
            return []    // 個人訊息區域無額外行數
            
        case .generalOptions:
            return [
                UserProfileRow(icon: "person.fill", title: "Edit Profile", subtitle: "Change your details", urlString: nil, action: .editProfile),
                UserProfileRow(icon: "clock", title: "Order History", subtitle: "View your past orders", urlString: nil, action: .orderHistory),
                UserProfileRow(icon: "heart", title: "Favorites", subtitle: "Your favorite items", urlString: nil, action: .favorites)
            ]
            
        case .socialLinks:
            return [
                UserProfileRow(icon: "facebook", title: "Facebook", subtitle: "Follow us on Facebook", urlString: "https://www.facebook.com/starbuckstaiwan?ref=nf", action: nil),
                UserProfileRow(icon: "instagram", title: "Instagram", subtitle: "Follow us on Instagram", urlString: "https://www.instagram.com/starbuckstw/", action: nil),
                UserProfileRow(icon: "youtube", title: "YouTube", subtitle: "Subscribe to our channel", urlString: "https://www.youtube.com/user/STARBUCKSTW", action: nil),
                UserProfileRow(icon: "line", title: "Line", subtitle: "Join our Line group", urlString: "https://line.me/R/ti/p/@471vnurh?from=page&openQrModal=true&searchId=471vnurh", action: nil)
            ]
            
        case .logout:
            return []     // 登出區域無行數據
        }
    }
    
}
