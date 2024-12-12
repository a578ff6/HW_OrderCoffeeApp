//
//  UserProfileRow.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/10.
//

// MARK: - 重點筆記：UserProfileRow 的設計理念與實現
/**
 
 ## 重點筆記：UserProfileRow 的設計理念與實現
 
` * What`
 
 
 - `UserProfileRow` 是一個數據結構，專門用於描述個人資料頁面中每一行列表的顯示內容及行為，用於 TableView 的數據源管理。
 - 主要為了避免在設置「`GeneralOption`」的欄位點擊行爲時，採用硬編碼，導致可讀性變差。
 - 而後來在設置 `UserProfileDataSource` 時，發現管理的參數越來越多，以及避免硬編碼，提高封裝性，因此設置了 `UserProfileRow`。

 `* Why`

 - `清晰數據表達`：每行的圖示、文字、副標題和操作行為被封裝在同一結構中，方便管理。
 - `高度可重用性`：將數據與顯示邏輯分離，無論是普通選項還是社交媒體連結，都可使用同一結構。
 - `擴展性`：可輕鬆添加更多屬性（例如 `accessoryType` 或 `isEnabled`），以適應未來需求。
 
 `* How`

 `1.封裝數據結構`

 - 使用 struct 描述列表行數據，確保每個屬性皆與顯示需求對應。
 - 提供 `action` 屬性，專門用於應用內功能（如跳轉到編輯個人資料頁面）。
 - 提供 `urlString` 屬性，專門用於外部連結。
 
 `2.分離數據邏輯與顯示邏輯`

 - `數據邏輯`：`UserProfileRow` 僅負責定義`行數據`，描述應顯示的內容及行為。
 - `顯示邏輯`：由 `UITableViewDelegate` 處理點擊事件時根據 `action` 或 `urlString` 執行相應操作，將行為執行延遲到委派中處理，避免在數據層混入額外邏輯。
 */


// MARK: - (v)

import Foundation

/// 用於描述每一行列表內容的結構
///
/// 此結構被設計用來表示個人資料頁面中每一行的數據，包括圖示、標題、副標題、相關連結及行為操作。
///
/// - `icon`: 每行的圖示，可以使用 SF Symbols 或自定義圖標名稱。
/// - `title`: 每行的主要標題文字，用來描述此行功能。
/// - `subtitle`: 可選的副標題文字，提供額外的描述。
/// - `urlString`: 可選的網址字串，用於跳轉至外部連結（如社交媒體頁面）。
/// - `action`: 可選的操作行為，用於觸發應用內相關功能（如編輯個人資料、查看歷史訂單）。
struct UserProfileRow {
    let icon: String
    let title: String
    let subtitle: String?
    let urlString: String?
    let action: GeneralOptionAction?
}

// MARK: - GeneralOptionAction

/// 定義`常規選項`的操作行為
///
/// 此枚舉包含應用內的特定操作行為，與 `UserProfileRow` 的 `action` 屬性配合使用。
enum GeneralOptionAction {
    case editProfile
    case orderHistory
    case favorites
}
