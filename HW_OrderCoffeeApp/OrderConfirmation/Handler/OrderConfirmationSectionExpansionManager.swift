//
//  OrderConfirmationSectionExpansionManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - OrderConfirmationSectionExpansionManager 筆記
/**
 ## OrderConfirmationSectionExpansionManager 筆記

 `* 功能簡介`
    - 這部分主要會給「ItemDeatils」使用，因為考量到會有很多飲品項目，因此提供該功能。
    - OrderConfirmationSectionExpansionManager 是一個管理訂單確認頁面中各個區塊（Section）展開和收起狀態的管理器。
    - 它的主要目的在於集中管理各個區塊的展開狀態，確保頁面顯示符合使用者的需求，例如顯示更多或更少的訂單詳細內容。
 
` * 主要功能`
 
 `1.管理展開狀態`
    - 使用 `Set` 來記錄哪些區塊（`Section`）是處於展開狀態的。
    - 透過 `expandedSections` 這個屬性來追蹤當前哪些區塊是展開的，避免在 UI 中展開和收起的狀態混亂。
 
` 2.檢查展開狀態`
    - `isSectionExpanded(_ section: Int) -> Bool`
    - 根據提供的 section 索引，檢查該區塊是否處於展開狀態。
    - `回傳值`：true 代表該區塊目前是展開的；false 代表該區塊是收起的。
 
 `3,切換展開狀態`
    - `toggleSection(_ section: Int)`
    - 用於切換某個區塊的展開狀態。
    - 若該區塊已展開，則將其收起；若未展開，則展開它。
    - 這樣的切換功能方便使用者在界面中擴展或隱藏部分詳細資訊，增加操作靈活性。
 
 `* 使用情境`
    - 在`OrderConfirmationViewController`中，每個區塊都有可能包含不同的資訊（例如商品明細、顧客資料等）。
    - 使用者有時會需要查看詳細的商品資訊，而有時又希望僅查看摘要。可以幫助確保不同區塊的展開和收起能夠同步且一致地呈現。

 `* 實作重點`
    - `展開狀態儲存`：利用 `Set` 來儲存展開的 `section`，因為 Set 可以快速查詢和移除元素，並且確保不會有重複的元素。
    - `切換展開`：提供 `toggleSection` 方法來切換指定 section 的狀態，實作簡潔，便於其他管理器或控制器調用來更新 UI。

 */

import UIKit

/// 負責管理 Section 展開和收起狀態的管理器
/// - 主要功能：集中管理訂單確認頁面的展開狀態，確保顯示內容符合使用者需求。
class OrderConfirmationSectionExpansionManager {
    
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
