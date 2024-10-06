//
//  UserDetails.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/3.
//


/*
 
 ## UserDetails 結構設計筆記

 1. 添加 uid 的考量

    * 引用用戶資料：
        - 在多個地方引用用戶數據（如訂單、訊息、評論等）時，uid 非常重要，因為它可以唯一標示用戶，便於跨模組操作。
 
    * 用戶身份驗證：
        - 如果需要驗證用戶身份，uid 作為唯一標示符號是必要的，以確保數據的安全性和準確性。
 
    * 資料同步：
        - 若需要在多個設備之間同步用戶資料，uid 可以幫助確保每個設備上的數據是屬於相同用戶的，確保資料一致性。
 
 2. 不需要添加 uid 的情況
 
    * 單一操作：
        - 如果操作只針對當前用戶，且不涉及多用戶數據交互，這時 uid 就不是必須的。例如：本地端的一次性操作。

    * 簡單展示：
        - 若只是簡單顯示用戶資訊，如 email 或 fullName，不涉及到後續交互或數據追溯，那麼 uid 也不是必須的。
 
 3. 訂單使用非可選型別的考量
 
    * 固定結構與簡化代碼邏輯：
        - 由於 orders 屬性現在已經設定為空陣列 [OrderItem] = []，不再使用可選型別。這樣做可以簡化代碼邏輯，避免不必要的解包操作，確保即使沒有訂單，orders 也能以空陣列的形式存在。
 
    * 更好地管理數據：
        - 不使用可選型別能使訂單管理更直接，例如在加載歷史訂單時，不需要考慮 nil 的情況，從而提高代碼的穩定性和可讀性。
 */

// MARK: - 還未修改註冊頁面的版本

import Foundation

/// 使用者資訊
struct UserDetails: Codable {
    var uid: String                         // 使用者唯一標示符，用於身份驗證及跨模組引用
    var email: String                       // 使用者的電子郵件
    var fullName: String                    // 使用者的全名
    var profileImageURL: String?            // 儲存大頭照的 URL（選填）
    var phoneNumber: String?                // 使用者的電話號碼（選填）
    var birthday: Date?                     // 使用者的生日（選填）
    var address: String?                    // 使用者的地址（選填）
    var gender: String?                     // 使用者的性別（選填）
    var orders: [OrderItem] = []            // 訂單列表，初始化為空陣列，以避免空值的情況
    var favorites: [FavoriteDrink] = []     // 使用者的最愛飲品列表，初始化為空陣列
}
