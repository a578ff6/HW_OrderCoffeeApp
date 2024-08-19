//
//  UserDetails.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/3.
//


/*
 添加 uid：
    - 引用用戶資料：
        - 如需要在多個地方引用用戶數據（EX: 訂單、訊息、評論等），那麼包含 uid 會很有幫助，因為可以標示用戶。
    - 用戶身份驗證：
        - 假如需要驗證用戶身份，此時 uid 作為唯一標示符號是必要的。
    - 資料同步：
        - 如果需要同步用戶資料或在多個設備上共享用戶數據，uid 可以幫助確保數據的唯一性。

 不需要添加 uid：
    - 單一操作：
        - 操作僅限於當前用戶的單次操作，並且不會涉及到其他用戶的數據交互，那麼 uid 就沒那麼必要。
    - 簡單展示：
        - 如果只是簡單展示用戶資訊，EX: email、fullName 就足夠了。不需要 uid。
 
 使用 Optional 處理訂單：
    - 對於 orders 部分，因為客戶可能還沒有下訂單，所以將其設為可選型別。
 */

// MARK: - 還未修改註冊頁面的版本

import Foundation

/// 使用者資訊
struct UserDetails: Codable {
    var uid: String
    var email: String
    var fullName: String
    var profileImageURL: String? // 儲存大頭照的 URL
    var orders: [OrderItem]?
}


