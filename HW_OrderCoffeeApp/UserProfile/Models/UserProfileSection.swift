//
//  UserProfileSection.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/10.
//

// MARK: - 重點筆記：UserProfileSection 的設計理念與實現
/**
 
 ## 重點筆記：UserProfileSection 的設計理念與實現
 
 `* What`
 
 - `UserProfileSection` 是個人資料頁面中不同區域的枚舉，用於區分每個區域的類型及其屬性，例如標題和間距需求。

 ----------------------
 
 `* Why`

 `1.結構清晰：`

 - 透過枚舉明確定義各個區域，提升代碼可讀性與邏輯性。
 - 符合分區管理的職責設計，便於擴展和維護。
 
 `2.支援標題顯示：`

 - 為每個區域設置 `title` 屬性，支持顯示區域標題或返回空值。
 
 `3.間距處理：`

 - 新增 `requiresSpacing` 屬性，專門處理第一個分區（如 `userInfo`）與導航欄大標題之間的間距問題。
 - 避免在其他地方硬編碼，讓間距邏輯清晰且模組化。
 
 ----------------------

 `* How`
 
 `1. 定義區域類型：`
 
 - 使用 `CaseIterable` 協議讓所有區域類型可迭代。
 - 為每個區域分配整數值以確保穩定排序，並簡化 `TableView` 的分區管理。

 ```swift
 enum UserProfileSection: Int, CaseIterable {
     case userInfo
     case generalOptions
     case socialLinks
     case logout
 }
 ```

` 2. 動態生成區域標題：`
 
 - 提供 `title` 屬性，根據區域需求返回特定標題或 `nil`。

 ```swift
 var title: String? {
     switch self {
     case .userInfo:
         return nil
     case .generalOptions:
         return "General"
     case .socialLinks:
         return "Follow Us"
     case .logout:
         return nil
     }
 }
 ```

 `3. 控制區域間距：`
 
 - 使用 `requiresSpacing` 屬性，將間距需求模組化。
 - 第一個分區（`userInfo`）返回 `true`，以確保與導航欄標題之間有適當距離，其他分區返回 `false`。

 ```swift
 var requiresSpacing: Bool {
     switch self {
     case .userInfo:
         return true
     default:
         return false
     }
 }
 ```

 `4. 在 TableView 中應用 requiresSpacing：`
 
 - 在 `titleForHeaderInSection` 中檢查分區是否需要間距。
 - 若需要間距，返回空白標題（`" "`）；若不需要，則返回正常標題或 `nil`。

 ```swift
 func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     guard let section = UserProfileSection(rawValue: section) else { return nil }
     return section.requiresSpacing ? " " : section.title
 }
 ```

 ----------------------

 `* 總結`

 - 優化職責分離： `requiresSpacing` 將視圖間距邏輯從其他地方提取出來，與分區管理結合，提升設計一致性。
 - 提升模組化設計： 將間距處理與分區屬性綁定，減少硬編碼，便於未來的維護與調整。
 - 提高可讀性與易用性： 間距處理與區域標題生成的邏輯一目了然，代碼結構更清晰。
 */


// MARK: - (v)

import UIKit

/// 定義個人資料頁面的區域類型
///
/// 此枚舉描述了頁面中不同區域的結構與用途，包括用戶資訊、常規選項、社交媒體及登出按鈕。
///
/// ### 分區介紹
/// - `userInfo`: 顯示用戶個人資訊的區域，例如頭像、名稱、電子郵件。
/// - `generalOptions`: 常規選項區域，例如編輯資料、查看歷史訂單。
/// - `socialLinks`: 社交媒體連結區域，包含外部跳轉功能。
/// - `logout`: 登出按鈕區域。
///
/// ### 功能設計
/// - 提供每個分區的標題（`title`）。
/// - 確認分區是否需要額外的間距（`requiresSpacing`），用於處理 Cell 與導航欄大標題的距離問題。
enum UserProfileSection: Int, CaseIterable {
    case userInfo
    case generalOptions
    case socialLinks
    case logout
    
    /// 區域的標題
    ///
    /// 此屬性用於為特定區域提供標題，若區域不需要標題則返回 nil。
    ///
    /// - `userInfo`: 無標題，僅顯示用戶個人資訊。
    /// - `generalOptions`: 返回 "General" 作為標題。
    /// - `socialLinks`: 返回 "Follow Us" 作為標題。
    /// - `logout`: 無標題，僅顯示登出按鈕。
    var title: String? {
        switch self {
        case .userInfo:
            return nil
        case .generalOptions:
            return "General"
        case .socialLinks:
            return "Follow Us"
        case .logout:
            return nil
        }
    }
    
    /// 分區是否需要間距
    ///
    /// 此屬性用於判斷分區是否需要額外的空白間距。
    ///
    /// - `userInfo`: 返回 `true`，避免第一個 Cell 與導航欄大標題過近。
    /// - 其他分區：返回 `false`，不需要額外間距。
    ///
    /// ### 用途
    /// 配合 TableView 的 `titleForHeaderInSection` 方法：
    /// - 如果需要間距，返回空白標題（`" "`），實現額外的間距。
    /// - 如果不需要，則返回正常標題或 `nil`。
    var requiresSpacing: Bool {
        switch self {
        case .userInfo:
            return true
        default:
            return false
        }
    }
    
}
