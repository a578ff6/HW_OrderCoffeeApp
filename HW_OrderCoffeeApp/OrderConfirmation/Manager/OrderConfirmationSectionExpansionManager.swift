//
//  OrderConfirmationSectionExpansionManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - OrderConfirmationSectionExpansionManager 設計筆記
/**
 
 ## OrderConfirmationSectionExpansionManager 設計筆記

 `* What`

 - `OrderConfirmationSectionExpansionManager` 是一個專門用於管理訂單確認頁面中 Section 展開與收起狀態的工具類別。

 - 核心職責：
 
   - 提供簡單的接口來檢查和切換 Section 的展開狀態。
   - 集中管理所有 Section 的展開狀態，避免將這部分邏輯分散在其他類別中。

 - 功能：
 
   - `isSectionExpanded(_:)`：檢查指定的 Section 是否展開。
   - `toggleSection(_:)`：切換指定 Section 的展開狀態。

 - 使用場景：
 
   - 當用戶在訂單確認頁面中點擊 Section Header 時，動態切換展開或收起狀態。

 ---------

 `* Why`

 1. 單一職責原則 (SRP)：
 
    - 管理 Section 展開/收起的狀態是一個獨立的邏輯，應與其他模組（例如數據展示、視圖更新等）分離。
    - 將這部分邏輯集中到一個專門的管理器中，能更清晰地劃分責任，降低類別的複雜性。

 2. 解耦設計：
 
    - 與視圖層解耦： `OrderConfirmationSectionExpansionManager` 只負責狀態的管理，不直接參與視圖的更新邏輯。
    - 與業務層解耦： 它僅專注於展開與收起的狀態管理，不涉及業務數據的處理。

 3. 高效狀態管理：
 
    - 使用 `Set` 結構存儲展開的 Section，支持高效的查詢、插入與移除操作，適合頻繁的狀態切換場景。

 4. 提高可測試性：
 
    - `OrderConfirmationSectionExpansionManager` 提供的公共方法（例如 `isSectionExpanded` 和 `toggleSection`），讓單元測試更容易模擬並驗證其行為。

 ---------

 `* How`

 `1. 管理狀態的核心方法`

 - `isSectionExpanded(_:)`
 
   - 功能： 檢查指定的 Section 是否處於展開狀態。
   - 邏輯：查詢內部的 `Set` 是否包含該 Section 索引。
   - 用例： 當需要決定某 Section 的顯示內容時，使用此方法判斷是否展開。

 - `toggleSection(_:)`
 
   - 功能：切換指定 Section 的展開狀態。
   - 邏輯：
     - 如果 Section 已展開，則將其從 `Set` 中移除。
     - 如果 Section 尚未展開，則將其添加到 `Set`。
   - 用例：當用戶點擊 Section Header 時，調用此方法切換狀態。
 
 ----
 
 `2. 與外部模組的協作`

 - 用戶點擊操作
 
    - `OrderConfirmationHeaderGestureHandler` 捕捉點擊事件，調用 `toggleSection` 切換狀態。

 - 狀態管理
 
    - `OrderConfirmationSectionExpansionManager` 更新內部的展開狀態。

 - 通知外部更新
 
    - 通過 `OrderConfirmationSectionDelegate` 通知外部模組進行視圖刷新。

 ----

 `3. 整合流程圖`

 - 用戶點擊 Section Header
    - 捕捉點擊事件。
 
 - 切換展開狀態
    - 調用 `toggleSection(_:)` 方法。
 
 - 通知更新
    - 通知外部模組刷新 Section。

 ---------

 `* 總結`

 1. 它是什麼？
 
 - 一個專門管理 Section 展開/收起狀態的工具，提供高效的接口來查詢和切換狀態。

 2. 為什麼需要它？
 
 - 確保責任單一，避免其他模組負責過多邏輯。
 - 降低視圖層和業務層的耦合性。
 - 提供更高效和易測試的狀態管理。

 3. 它如何運作？
 
 - 使用 `Set` 來追蹤展開的 Section。
 - 提供簡單的公共方法 (`isSectionExpanded`, `toggleSection`)。
 - 通過協作，確保狀態變更後正確通知相關視圖更新。

 ---------

 `* 設計優勢`

 1. 簡單易用： 提供兩個關鍵方法，適合不同場景的狀態查詢與切換需求。
 2. 高效操作： 使用 `Set` 確保狀態切換和查詢的性能。
 3. 靈活性高： 可方便地適配不同數量的 Section 或需求變更。
 4. 可測試性： 獨立的狀態管理邏輯，便於模擬各種場景進行單元測試。

 ---------

 `* 適用場景`
 
 - 訂單確認頁面需要頻繁切換展開與收起的內容區域，且需與視圖層進行解耦時，此管理器是一個理想的解決方案。
 */


// MARK: - (v)

import UIKit

/// `OrderConfirmationSectionExpansionManager`
///
/// 此類負責集中管理 `OrderConfirmation` 頁面的 Section 展開與收起狀態，
/// 提供簡潔的接口來檢查和切換 Section 狀態，確保顯示的內容符合用戶需求。
///
/// - 設計目的:
///   1. 集中管理狀態：
///      - 提供一個專用管理器來追蹤各 Section 的展開狀態，避免將狀態管理分散到其他類別，確保單一職責原則 (SRP)。
///   2. 解耦邏輯：
///      - 確保展開/收起邏輯與業務層或視圖更新邏輯分離，降低系統耦合度。
///
/// - 使用場景:
///   當用戶在訂單確認頁面中點擊 Section Header 切換展開狀態時，此管理器負責更新內部狀態並提供查詢接口，
///   後續由其他組件（ `OrderConfirmationHandler`）處理視圖更新。
class OrderConfirmationSectionExpansionManager {
    
    // MARK: - Properties
    
    /// 記錄當前處於展開狀態的 Sections 索引
    ///
    /// - 說明: 使用 `Set` 存儲展開的 Section，確保每個 Section 僅出現一次，並支持高效的查詢和移除操作。
    private var expandedSections: Set<Int> = []
    
    // MARK: - Public Methods
    
    /// 檢查指定的 Section 是否展開
    ///
    /// - Parameter section: 要檢查的 Section 索引
    /// - Returns: 是否展開
    ///   - `true`: 該 Section 為展開狀態。
    ///   - `false`: 該 Section 為收起狀態。
    ///
    /// - 使用場景:
    ///   在需要決定某個 Section 的顯示內容時，通過此方法判斷是否需要顯示展開內容。
    func isSectionExpanded(_ section: Int) -> Bool {
        return expandedSections.contains(section)
    }
    
    /// 切換指定 Section 的展開狀態
    ///
    /// - Parameter section: 要切換展開狀態的 Section 索引
    ///
    /// - 邏輯:
    ///   - 若該 Section 已展開，則收起（從 `expandedSections` 移除）。
    ///   - 若該 Section 尚未展開，則展開（加入 `expandedSections`）。
    ///
    /// - 使用場景:
    ///   當用戶點擊某個 Section Header 時，調用此方法切換其展開狀態，並由外部組件執行後續的視圖更新操作。
    func toggleSection(_ section: Int) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
    }
    
}
