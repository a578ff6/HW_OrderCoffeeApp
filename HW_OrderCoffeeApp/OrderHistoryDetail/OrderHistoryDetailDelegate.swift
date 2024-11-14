//
//  OrderHistoryDetailDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

// MARK: - OrderHistoryDetailDelegate 重點筆記：
/**
 ## OrderHistoryDetailDelegate 重點筆記：

` * 委託用於解耦合資料管理與 UI：`
 
 - `OrderHistoryDetailDelegate` 的主要作用是將資料管理與 UI 更新的邏輯分離。
 - Handler 可以專注於 UI 呈現，而資料的獲取和展開狀態的變化處理則透過 Delegate 進行通知。

 `* 集中管理訂單資料：`

 - `getOrderHistoryDetail() 方`法確保 UI 的資料來自同一個來源，避免了資料不一致的問題。

 `* 展開/收起狀態的管理：`

 - `didToggleSection(_:) `方法的設計讓 ViewController 可以根據 Section 的展開或收起狀態來更新對應的 UI。
 - 尤其適用於 UICollectionView 的情境，當某個區域需要重新載入時，這樣的設計使得 UI 操作保持流暢且一致。

 `* 適用於資料驅動 UI 的設計：`

 - 透過 `OrderHistoryDetailDelegate`，你能確保 UI 與資料變化同步更新，符合資料驅動 UI 的原則。
 - 可以擴展此協議來添加更多資料或互動邏輯，而不需要直接更改現有的 Handler 或 ViewController。
 */

import Foundation

/// `OrderHistoryDetailDelegate` 用於協助 `OrderHistoryDetailHandler` 與外部類別溝通。
/// - 功能：此協議提供了歷史訂單詳細資料的獲取方法，以及處理每個 Section 展開或收起狀態變更。
protocol OrderHistoryDetailDelegate: AnyObject {
    
    /// 獲取`歷史訂單`的詳細資料
    /// - Returns: `OrderHistoryDetail` 類型，包含完整的歷史訂單詳細資訊，例如顧客資訊、商品項目等
    func getOrderHistoryDetail() -> OrderHistoryDetail
    
    // 當切換某個 Section 展開/收起狀態時的操作
    /// - Parameter section: 被展開或收起的區域的索引
    /// - 說明：這個方法會被呼叫以更新顯示狀態，例如重新載入指定區域的 UI
    func didToggleSection(_ section: Int)
}
