//
//  UserProfile.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/9.
//

// MARK: - UserProfile 設計筆記
/**
 
 ## UserProfile 設計筆記
 
 `* What`
 
 - `UserProfile` 是一個用於描述個人資料頁面的數據模型，包含基本的用戶資訊，例如全名、電子郵件及頭像 URL。
 - 它遵循 `Codable` 協議，方便與 `Firebase Firestore `的 JSON 格式資料進行直接轉換。
 
 `* Why`
 
 `1.清晰的數據結構`

 - 將與用戶資料相關的屬性集中在一個結構中，便於管理和擴展。
 - 減少硬編碼，讓代碼更具可讀性和可維護性。
 
 `2.與 Firebase Firestore 無縫整合`

 - 透過 `Codable` 協議，能直接使用 `Firestore` 的 `getDocument(as:) 方法`解析資料，簡化數據處理流程，減少手動解析 JSON 的錯誤風險。
 
 `3.高擴展性`

 - 可根據需求輕鬆新增屬性，例如電話號碼、生日或地址，以支持未來功能。
 
 `* How`
 
 `1.設計數據模型`

 - 使用 struct，確保數據是值類型，並提供良好的性能表現。
 - 包含以下屬性：
    - `fullName`：用戶全名，為必填項。
    - `email`：用戶電子郵件，為必填項。
    - `profileImageURL`：用戶頭像的 URL，可選，適合用於`未上傳頭像`的情況。
 
 `2.與 Firestore 整合`

 - 確保 `UserProfile` 遵循 `Codable` 協議，直接支持與 Firestore 資料的序列化與反序列化。
 - 在需要時可透過 `Firestore` 的` getDocument(as:) `方法直接加載資料。
 */

// MARK: - (v)

import UIKit

/// 表示用戶個人資料的數據結構
///
/// 此結構用於描述個人資料頁面中每位用戶的基本資訊。
/// 遵循 `Codable` 協議以支援與 `Firebase Firestore` 的數據序列化與反序列化。
///
/// - `fullName`: 用戶全名
/// - `email`: 用戶電子郵件
/// - `profileImageURL`: 用戶頭像的 URL（可選，因為註冊時沒有要求設置大頭照）
struct UserProfile: Codable {
    let fullName: String
    let email: String
    let profileImageURL: String?
}
