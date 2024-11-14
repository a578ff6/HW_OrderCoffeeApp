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

import UIKit

/// 負責管理 Section 展開和收起狀態的管理器
/// - 主要功能：集中管理歷史訂單細項頁面的展開狀態，確保顯示內容符合使用者需求。
class OrderHistoryDetailSectionExpansionManager {
    
    // MARK: - Properties

    /// 記錄目前處於展開狀態的 Sections
    private var expandedSections: Set<Int> = []

    // MARK: - Public Methods

    /// 檢查指定的 Section 是否展開
    /// - Parameter section: 要檢查的 Section 索引
    /// - Returns: 是否展開，true 表示展開，false 表示收起
    func isSectionExpanded(_ section: Int) -> Bool {
        return expandedSections.contains(section)
    }
    
    /// 切換 Section 的展開狀態
    /// - Parameter section: 要切換展開狀態的 Section 索引
    /// - 說明：若該 Section 已展開則收起，若尚未展開則將其展開
    func toggleSection(_ section: Int) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
    }
}
