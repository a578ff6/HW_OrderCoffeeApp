//
//  OrderHistorySortMenuDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - SortMenuDelegate 重點筆記
/**
 ## SortMenuDelegate 重點筆記

 `* 概述`
 - `功能`：`OrderHistorySortMenuDelegate` 用於排序選單的操作結果回傳。
 - `用途`：當使用者選擇某個排序選項後，透過該協定來通知 `ViewController` 執行相應的排序邏輯。

 `* 結構`
 
 `1. 協定方法：`
 
 - `didSelectSortOption(_:)`：此方法將用於回傳選擇的排序選項，透過該選項由 `ViewController` 來更新訂單資料。
 - `參數`：`sortOption` 為 `OrderHistoryManager.OrderHistorySortOption` 類型，表示選擇的排序方式。
 */


import UIKit

/// `SortMenuDelegate` 協定
///
/// - 用於定義排序選單的操作回調方法。
/// - 當使用者選擇某個排序選項後，透過該協定將結果回傳給委託對象。
protocol OrderHistorySortMenuDelegate: AnyObject {
    
    /// 通知已選擇的排序選項
    /// - Parameter sortOption: 選擇的排序選項，表示使用者的排序偏好
    func didSelectSortOption(_ sortOption: OrderHistoryManager.OrderHistorySortOption)
}
