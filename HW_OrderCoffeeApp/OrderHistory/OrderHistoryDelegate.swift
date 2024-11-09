//
//  OrderHistoryDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - OrderHistoryDelegate 重點筆記
/**
 
 ## OrderHistoryDelegate 重點筆記
 
 `* 用途：`
    - `OrderHistoryDelegate` 協議用於解耦 `OrderHistoryHandler` 和 `OrderHistoryViewController` 之間的關係，允許 `OrderHistoryHandler` 在不知道訂單具體資料的情況下，通過委託方式獲取資料。
 
 `* 適用場景：`
    - 當 `OrderHistoryHandler` 需要取得訂單資料來顯示時，它不直接持有訂單資料，而是透過 `OrderHistoryDelegate` 來請求資料。
 
 `* 弱引用 (weak)：`
    - `OrderHistoryDelegate` 使用 AnyObject 並在 `OrderHistoryHandler` 中設置為 weak，這樣可以避免循環引用，確保控制器可以正確地被釋放以避免記憶體洩漏。
 
 `* 解耦設計：`
    - 這樣的設計有助於職責分離，`OrderHistoryHandler` 只負責表格的 UI 和邏輯處理，而資料管理留在 `OrderHistoryViewController`。這讓程式碼更容易維護，也更具擴展性。
 */

import UIKit

/// `OrderHistoryDelegate` 協議
///
/// 用於定義`歷史訂單`相關的委託方法，使 `OrderHistoryHandler` 能夠透過該協議來獲取訂單資料。
/// 應用於 `OrderHistoryHandler` 和 `OrderHistoryViewController` 之間的溝通。
protocol OrderHistoryDelegate: AnyObject {
    
    /// 獲取所有訂單資料
    ///
    /// - Returns: 一個包含所有歷史訂單的陣列
    func getOrders() -> [OrderHistory]
    
    /// 刪除指定索引的訂單
    ///
    /// - Parameter index: 要刪除的訂單在陣列中的索引
    func deleteOrder(at index: Int)
    
    /// 刪除指定的多筆訂單
    /// - Parameter indices: 要刪除的訂單在陣列中的索引列表
    func deleteOrders(at indices: [Int])
}
