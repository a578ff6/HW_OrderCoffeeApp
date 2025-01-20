//
//  OrderHistorySortMenuDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - OrderHistorySortMenuDelegate 筆記
/**
 
 ### OrderHistorySortMenuDelegate 筆記

 `* What`
 
 - `OrderHistorySortMenuDelegate` 用於定義排序選單的操作回調方法，當使用者從排序選單中選擇某個排序方式後，透過此協議將結果回傳給相關的委託對象。
   
 - 主要功能
 
   1. 接收使用者選擇的排序選項。
   2. 通知委託對象（例如控制器）進一步處理排序邏輯。
   3. 確保選單與排序業務邏輯的解耦。

 - 應用場景
 
   - 與 `OrderHistorySortMenuHandler` 配合使用，用於建立排序選單並將選擇結果通知到實現該協議的對象（如 `OrderHistoryViewController`）。

 --------

 `* Why`
 
 1. 解耦 UI 與業務邏輯
 
    - 通過協議回調的方式，排序選單的 UI 層與具體的排序業務邏輯分離，提升代碼的可讀性與模組化。
   
 2. 統一排序選項的處理
 
    - 避免各個模組單獨實現排序選項處理邏輯，確保回調行為一致，減少重複代碼。
   
 3. 增強靈活性
 
    - 如果未來需要調整排序選單的行為或添加新的排序選項，只需修改協議的實現部分，而不需要改變整體架構。
   
 4. 提升可測試性
 
    - 排序邏輯可以通過實現協議的對象進行測試，方便隔離選單的 UI 測試與排序的業務邏輯測試。

 --------

 `* How`
 
 1. 定義協議
 
    ```swift
    /// `OrderHistorySortMenuDelegate` 協議
    ///
    /// - 用於接收使用者選擇的排序選項，並通知委託對象處理邏輯。
    protocol OrderHistorySortMenuDelegate: AnyObject {
        
        /// 通知已選擇的排序選項
        ///
        /// - Parameter sortOption: 使用者選擇的排序條件
        func didSelectSortOption(_ sortOption: OrderHistorySortOption)
    }
    ```

 -----
 
 2. 實現協議
 
    - 在需要處理排序選項的對象（如 `OrderHistoryViewController`）中實現協議：
 
    ```swift
    extension OrderHistoryViewController: OrderHistorySortMenuDelegate {
        func didSelectSortOption(_ sortOption: OrderHistorySortOption) {
            // 更新當前排序條件並重新獲取訂單
            currentSortOption = sortOption
            fetchOrderHistory(sortOption: currentSortOption)
        }
    }
    ```

 -----

 3. 建立排序選單
 
    - 使用 `OrderHistorySortMenuHandler` 建立排序選單，並傳入協議的實現對象：
 
    ```swift
    let sortMenuHandler = OrderHistorySortMenuHandler(orderHistorySortMenuDelegate: self)
    let sortMenu = sortMenuHandler.createSortMenu()
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "排序", menu: sortMenu)
    ```

 -----

 4. 處理排序選項
 
   -  `OrderHistorySortOption` 負責具體的排序邏輯：
 
    ```swift
    extension OrderHistorySortOption {
        func sort(_ orders: [OrderHistory]) -> [OrderHistory] {
            switch self {
            case .byDateDescending: return orders.sorted { $0.timestamp > $1.timestamp }
            case .byDateAscending: return orders.sorted { $0.timestamp < $1.timestamp }
            case .byAmountDescending: return orders.sorted { $0.totalAmount > $1.totalAmount }
            case .byAmountAscending: return orders.sorted { $0.totalAmount < $1.totalAmount }
            case .byPickupMethod: return orders.sorted { $0.customerDetails.pickupMethod.rawValue < $1.customerDetails.pickupMethod.rawValue }
            }
        }
    }
    ```

 --------

 `* 總結`
 
 - `OrderHistorySortMenuDelegate` 是排序功能中的核心協議，通過回調方法，確保選單選項與業務邏輯的分離。
 
 - 優點：
   - 簡化排序業務邏輯的處理。
   - 增強代碼的可讀性與靈活性。
   - 提升整體模組的擴展性和測試性。

 */



// MARK: - (v)

import UIKit

/// `OrderHistorySortMenuDelegate` 協議
///
/// - 用途：
///   - 定義排序選單的回調方法，處理使用者在排序選單中選擇某一排序方式後的交互邏輯。
///   - 提供與排序相關的操作接口，確保排序選單與業務邏輯的分離。
///
/// - 應用範圍：
///   - 此協議通常由 `OrderHistoryViewController` 或其他負責管理訂單顯示的控制器實現。
///   - 當使用者從 `OrderHistorySortMenuHandler` 中選擇排序方式時，會透過此協議通知相關控制器。
///
/// - 設計目標：
///   - 確保排序選項的回調方法統一，提升代碼的可維護性與可擴展性。
protocol OrderHistorySortMenuDelegate: AnyObject {
    
    
    /// 通知已選擇的排序選項
    ///
    /// - 說明：
    ///   - 當使用者選擇一個排序選項後，透過此方法將選擇的排序條件回傳給實現此協議的物件。
    ///   - 實現方需根據此排序條件更新訂單顯示或執行相應操作。
    ///
    /// - Parameter sortOption: 選擇的排序選項，對應於 `OrderHistorySortOption` 的一個值。
    func didSelectSortOption(_ sortOption: OrderHistorySortOption)
    
}
