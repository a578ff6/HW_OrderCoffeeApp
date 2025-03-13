//
//  ProfileEditModel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/4.
//

// MARK: -  ProfileEditModel 筆記

/**
 
 ## ProfileEditModel 筆記
 
 `* What`
 
 `1.ProfileEditModel 的用途：`

 - 用於保存與處理編輯個人資料的數據結構。
 - 包含基本的用戶資訊（如姓名、性別、聯絡方式等）。
 
 `2.核心功能：`

 - 支援序列化與反序列化，通過實現 Codable 與後端進行數據同步。
 - 提供性別預設值，確保資料的完整性與一致性。
 
 `* Why`
 
 `1.提升資料一致性：`

 - 所有資料欄位（包括選填欄位）都有明確的類型或預設值，減少資料異常的可能性。
 
 `2.簡化數據處理：`

 - 預設值使初始化更方便，避免手動設置空值的麻煩。
 - 內建的 Codable 支援讓與後端交互時減少自定義解析邏輯。
 
 `3.靈活性：`

 - 可選欄位（如 `phoneNumber` 和 `address`）為空時不會影響數據結構的使用。
 - `性別`的預設值 "`Other`" 防止因用戶未選擇導致的空值問題。
 
 `* How`
 
 `1.初始化與預設值處理：`

 - 使用初始化方法設置必要欄位（如 uid 和 fullName）。
 - 可選欄位在未提供時會自動設為 `nil` 或 "`Other`"（對應性別）。
 
 ```swift
 let profile = ProfileEditModel(uid: "123", fullName: "John Doe")
 // gender 默認為 "Other"
 ```
 
 `2.與後端數據交互：`

 - 使用 Codable 將結構直接映射為 JSON。
 - 例如，與 Firebase 的 Firestore 交互時，可輕鬆實現數據的保存與加載。
 
 ```swift
 func saveProfile(_ profile: ProfileEditModel) async throws {
     let jsonData = try JSONEncoder().encode(profile)
     // 將 jsonData 上傳至後端
 }
 ```
 
` 3.性別的容錯與預設值：`

 - 性別欄位提供預設值 "`Other`"，避免後端或 UI 操作時因性別為空造成的錯誤。
 - 當從後端獲取數據時，若性別欄位缺失，會自動補全為 "`Other`"。
 
 ```swift
 let gender = userData["gender"] as? String ?? "Other" // 保證性別有值
 ```
 */


// MARK: - 筆記：為什麼 `gender` 一定會有值，而不像其他字段設為選填
/**
 
 ## 筆記：為什麼 `gender` 一定會有值，而不像其他字段設為選填？

 `* What`
 
 `1.gender 的設計差異：`

 - 在 `ProfileEditModel` 中，`gender` 字段是非可選型別 (`String`)，並且有預設值 "`Other`"。
 - 其他字段如 `phoneNumber`、`birthday` 和 `address` 設為可選型別 (Optional)，允許為 `nil`。
 
 `2.處理方式：`

 - 性別字段無論是初始化、從後端加載還是更新資料，都會保證有值。
 - 預設值 "`Other`" 用於未選擇性別時的默認值，避免空值問題。
 
----------------------
 
 `* Why`

 `1.UI 顯示需求：`

 - 性別字段是編輯頁面中的必須顯示字段：
 - 即使使用者未選擇性別，頁面上仍需顯示預設選項（如 "`Other`"）。
 - 保證頁面上性別選擇元件的初始化和顯示完整。
 
 `2.資料完整性：`

 - 避免空值造成資料不一致：
 - 在 `Firebase` 等後端系統中，性別字段需要具備具體值，否則可能導致資料操作失敗或 UI 顯示錯誤。（UI控制元件會沒有顯示選擇。）
 - 預設值 "`Other`" 簡化了資料同步與更新過程。
 
 `3.使用者體驗：`

 - 引導用戶選擇：
 - 預設選項讓使用者明確知道性別字段的當前狀態，而非留空。增強了表單的完整性與直觀性。
 - 提供一個預設選項（例如 `"Other"`）可以引導使用者，讓他們在未選擇時也有一個合適的值來填補空白。
 - 而電話號碼、地址等資訊通常在註冊或編輯過程中可以忽略不填，因為並非所有情況下這些字段都是必須的。
 
 ----------------------

` * How`
 
 `1.在模型層級處理：`

 - 非可選型別與預設值：
 - `gender` 在資料模型中設為`非可選型別 (String)`，並且給定預設值 "`Other`"：
 
 ```swift
 var gender: String = "Other"
 ```
 
 - 確保每次從資料模型中讀取性別時，皆有具體值。
 
 `2.從 Firebase 加載資料：`

 - 在獲取資料時，使用預設值 "Other" 作為缺失情況下的容錯：
 
 ```swift
 let gender = userData["gender"] as? String ?? "Other"
 ```
 
 `3.在 UI 層級處理：`

 - 初始化性別選擇元件：
 - 在 GenderSelectionCell 中，使用 EditProfileSegmentedControl 初始化時設置預設值：
 
 ```swift
 func configure(withGender gender: String) {
     genderControl.setSelectedOption(gender)
 }
 ```
 
 - 確保 UI 上性別選擇元件總是有一個有效選項。
 
 `4.在更新資料時處理：`

 - 更新至 Firebase 時的容錯：
 - 確保性別字段永不為空，即使用戶未做選擇：
 
 ```swift
 "gender": profile.gender.isEmpty ? "Other" : profile.gender
 ```
 
 ----------------------
 
 `* 結論`
 
 - `gender` 設置為非可選型別的設計，是基於資料完整性與使用者體驗的綜合考量：
 
 1.預設值 "`Other`" 保證了性別字段的穩定性。
 2.在資料同步與 UI 層面減少處理空值的複雜性。
 3.提升表單使用過程的直觀性與一致性。
 */



import UIKit

/// 用於編輯個人資料的資料結構，包含用戶的基本資訊。
/// - 支援將資料進行序列化與反序列化（`Codable`），方便與後端數據進行交互。
struct ProfileEditModel: Codable {
    
    var uid: String                        // 使用者唯一標示符（用於身份驗證或跨模組的數據引用，確保資料唯一性。）
    var fullName: String                   // 使用者的全名（此欄位為必填，系統要求每位使用者均需提供有效名稱。）
    var profileImageURL: String?           // 儲存大頭照的 URL（可選欄位，當沒有設置圖片時，後端會返回 `nil`。）
    var phoneNumber: String?               // 使用者的電話號碼（可選欄位，用於顯示或更新聯絡資訊。）
    var birthday: Date?                    // 使用者的生日（可選欄位，用於顯示與更新個人資訊。）
    var address: String?                   // 使用者的地址（可選欄位，用於顯示或更新聯絡地址。）
    var gender: String                     // 使用者的性別（此欄位為必填，若未選擇性別，系統會預設為 `"Other"`。）
    
    
    // MARK: - Initializer

    /// 初始化方法，用於快速創建 `ProfileEditModel` 實例。
    ///
    /// - Parameters:
    ///   - uid: 使用者唯一標示符。
    ///   - fullName: 使用者的全名。
    ///   - profileImageURL: 使用者的大頭照 URL，若未提供則預設為 `nil`。
    ///   - phoneNumber: 使用者的電話號碼，若未提供則預設為 `nil`。
    ///   - birthday: 使用者的生日，若未提供則預設為 `nil`。
    ///   - address: 使用者的地址，若未提供則預設為 `nil`。
    ///   - gender: 使用者的性別，若未提供則預設為 `"Other"`。
    init(uid: String, fullName: String, profileImageURL: String? = nil, phoneNumber: String? = nil, birthday: Date? = nil, address: String? = nil, gender: String = "Other") {
        self.uid = uid
        self.fullName = fullName
        self.profileImageURL = profileImageURL
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        self.address = address
        self.gender = gender
    }
    
}
