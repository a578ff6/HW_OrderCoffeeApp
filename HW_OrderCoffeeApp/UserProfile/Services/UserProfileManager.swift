//
//  UserProfileManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/9.
//

// MARK: - 重點筆記：UserProfileManager 的設計理念與實現
/**
 
 ## 重點筆記：UserProfileManager 的設計理念與實現
 
 `* What`
 
 - `UserProfileManager` 是一個負責管理用戶個人資料存取的類別。
 - 提供了統一的方法，從 `Firebase Firestore` 獲取並解析用戶的個人資料。
 - 採用 單例模式，確保整個應用只存在一個實例，避免多次初始化。
 
 `* Why`
 
 `1.簡化數據存取`

 - 集中管理與用戶個人資料相關的 `Firestore` 請求，讓使用者只需調用簡單的接口即可獲取資料。
 
 `2.提高應用效能與一致性`

 - 單例模式確保資料存取邏輯集中於一處，避免重複實例化造成的記憶體浪費或潛在錯誤。
 
 `3.強化錯誤處理`

 - 提供 `UserProfileError` 列舉，清晰定義資料存取過程中可能發生的錯誤（如用戶未登入）。
 
` 4.支援擴展性`

 - 現在的功能專注於資料獲取，未來可輕鬆新增更多方法，例如更新或刪除個人資料。
 
 `* How`
 
` 1.單例模式的設計`

 - 使用` static let shared `確保類別只會有一個實例。
 - 私有化初始化方法 private init()，防止外部重複創建。
 
 `2.統一的資料存取方法`

 - 提供 `loadUserProfile` 方法，從 `Firestore` 獲取個人資料並解析為 UserProfile。
 - 使用 `getDocument(as:)`，直接將資料轉換為 Codable 結構，簡化資料解析。
 
 `3.錯誤處理與拋出`

 - 若用戶未登入，拋出自定義錯誤 `UserProfileError.userNotLoggedIn`。
 - 若 Firestore 資料無法解析，或請求失敗，拋出 Firebase 的內建錯誤。
 */

// MARK: - (v)

import UIKit
import Firebase

/// 負責管理用戶個人資料存取的類別
///
/// 這個類別提供了統一的資料存取方法，從 Firebase Firestore 獲取用戶資料。
/// 採用單例模式設計，確保應用中只會有一個實例。
class UserProfileManager {
    
    // MARK: - Singleton
    
    /// 單例模式
    static let shared = UserProfileManager()
    
    /// 私有初始化方法，防止其他地方新建實例，強制使用單例
    private init() {}
    
    // MARK: - Fetch User Profile
    
    /// 獲取當前用戶的個人資料，並直接解析為 `UserProfile`
    ///
    /// - Returns: 一個包含用戶個人資料的 `UserProfile` 實例
    /// - Throws: 若用戶未登入，拋出 `UserProfileError.userNotLoggedIn`
    /// - Throws: 若 `Firestore` 資料無法解析，或無法取得資料，則拋出 `Firestore` 錯誤
    func loadUserProfile() async throws -> UserProfile {
        
        /// 確保用戶已登入
        guard let user = Auth.auth().currentUser else {
            throw UserProfileError.userNotLoggedIn
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        /// 使用 `getDocument(as:)` 解析為 `UserProfile`
        let userProfile = try await userRef.getDocument(as: UserProfile.self)
        return userProfile
    }
    
    // MARK: - Errors
    
    /// 定義用戶資料存取相關的錯誤
    ///
    /// - userNotLoggedIn: 用戶尚未登入
    enum UserProfileError: Error {
        case userNotLoggedIn
    }
}
