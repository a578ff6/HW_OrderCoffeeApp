//
//  OrderHistoryDetailSectionExpansionManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//

// MARK: - OrderHistoryDetailSectionExpansionManager 重點筆記
/**
 ## OrderHistoryDetailSectionExpansionManager 重點筆記

 `1. Section 展開/收起管理的集中化並專欄化的設計觀念`
    - 這個管理器主要有一個調用主題，就是使用一個獨立的管理器集中處理 Section 展開和收起的狀態。

 `2. 使用 Set 儲存展開的 Section`
    - 利用 `Set` 來記錄很多個展開的 Section，允許可以快速地測試狀態是否展開。Set 有優秀的加入、移除和檢查性能，非常適合用來記錄這類單一狀態。

 `3. 公開方法來管理展開和切換狀態`
    - 提供兩個公開的方法：
      - `isSectionExpanded(_:)` 用於檢查特定的 Section 是否已展開。
      - `toggleSection(_:)` 用於切換特定 Section 的展開狀態。如果當前是展開狀態，則收起之；反之也然。

 `4. 設計目的`
    - 這樣的管理器設計可以確保 UI 帶有活動的可控以並且是決策模型，無論是需要體現數據的部分還是雙向通知都能夠更好地製作。

 `5. 展開和收起的互動模式`
    - 維持展開和收起的狀態以影響 UI 顯示，這類方法非常適用於詳細的各種歷史數據及微纖的現有信息展示。經由它的更好使用而增強觀看維持性。
 */


// MARK: - (v)

import UIKit

/// `OrderHistoryDetailSectionExpansionManager`
///
/// 此類負責集中管理 `OrderHistoryDetail` 頁面的 Section 展開與收起狀態，
/// 提供簡潔的接口來檢查和切換 Section 狀態，確保顯示的內容符合用戶需求。
///
/// - 設計目的:
///   1. 集中管理狀態：
///      - 提供一個專用管理器來追蹤各 Section 的展開狀態，避免將狀態管理分散到其他類別，確保單一職責原則 (SRP)。
///   2. 解耦邏輯：
///      - 確保展開/收起邏輯與業務層或視圖更新邏輯分離，降低系統耦合度。
///
/// - 使用場景:
///   當用戶在歷史訂單詳細頁面中點擊 Section Header 切換展開狀態時，此管理器負責更新內部狀態並提供查詢接口，
///   後續由其他組件（ `OrderHistoryDetailHandler`）處理視圖更新。
class OrderHistoryDetailSectionExpansionManager {
    
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
