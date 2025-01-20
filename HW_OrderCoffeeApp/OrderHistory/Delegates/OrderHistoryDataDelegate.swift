//
//  OrderHistoryDataDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - OrderHistoryDataDelegate 的筆記
/**
 
 ## OrderHistoryDataDelegate 的筆記

 ---

` * What`
 
 - `OrderHistoryDataDelegate` 是一個協議，用於定義與歷史訂單相關的數據操作方法，負責協調數據層與視圖層之間的交互。
 
 該協議的主要作用是標準化數據操作接口，包括：
 
 1. 獲取歷史訂單列表。
 2. 單筆訂單的刪除。
 3. 多筆訂單的批量刪除。

 ---

 `* Why`

 1. 解耦數據與表格視圖邏輯：
 
    - 讓數據操作由 `OrderHistoryViewController` 提供，而不是直接在表格視圖 (`UITableView`) 中處理，確保視圖層與邏輯層的責任分離，增強模組化。

 2. 提升靈活性與可測試性：
 
    - 通過協議的抽象層，允許隨時替換數據源的實現（例如從本地數據切換到 Firebase 或其他後端），而不影響其他組件。

 3. 協調多組件工作：
 
    - 提供統一的數據操作接口，使得 `OrderHistoryHandler` 和 `OrderHistoryEditingHandler` 等組件可以專注於視圖邏輯，而不直接操作數據。

 4. 支援表格視圖的核心交互行為：
 
    - 包括顯示數據、單筆刪除（滑動刪除）、以及多選刪除，確保視圖與數據的同步。

 ---

 `* How`

 1. 協議定義：
 
    - 定義三個核心方法，分別處理數據的獲取 (`getOrders`) 和刪除操作 (`deleteOrder`、`deleteOrders`)。

 2. 協議實現：
 
    - 在 `OrderHistoryViewController` 中實現該協議，集中處理數據的邏輯，並與後端（如 Firebase）交互，確保數據的一致性。

 3. 組件間的協作：
 
    - `OrderHistoryHandler`：透過 `getOrders()` 提供表格數據源，顯示歷史訂單列表。
    - `OrderHistoryEditingHandler`：在編輯模式下，調用 `deleteOrders(at:)` 執行多選刪除操作。
    - `UITableView`：在`一般模式下`觸發滑動刪除時，透過 `deleteOrder(at:)` 單筆刪除訂單。

 ---

 `* 使用範例`

 1. 提供表格數據源：
 
    ```swift
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderHistoryDataDelegate?.getOrders().count ?? 0
    }
    ```

 2. 滑動刪除操作：
 
    ```swift
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        orderHistoryDataDelegate?.deleteOrder(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    ```

 3. 多選刪除操作：
 
    ```swift
    func deleteSelectedRows() {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return }
        let indices = selectedRows.map { $0.row }
        orderHistoryDataDelegate?.deleteOrders(at: indices)
        tableView.deleteRows(at: selectedRows, with: .automatic)
    }
    ```

 ---

 `* 總結`

 - 核心功能： 提供標準化的數據操作接口，用於支持表格數據的顯示與刪除操作。
 - 設計優點： 解耦數據與視圖邏輯，提升模組化與可測試性。
 - 典型場景： 單筆刪除（滑動刪除）和多選刪除操作的實現，數據與視圖的同步更新。

 */



// MARK: - (v)

import UIKit

/// `OrderHistoryDataDelegate` 協議
///
/// 用於定義歷史訂單資料相關的委託方法，協調數據層與視圖層之間的交互。
/// 此協議被多個處理邏輯組件（例如 `OrderHistoryHandler` 和 `OrderHistoryEditingHandler`）使用，
/// 用於操作和獲取訂單資料。
///
/// ### 功能與用途
/// - 提供標準化的數據操作接口，例如獲取和刪除歷史訂單資料。
/// - 支援表格視圖 (`UITableView`) 的數據源和用戶交互行為，包括單筆刪除和多選刪除。
///
/// ### 為何需要
/// - 解耦數據與表格視圖邏輯：
///   - 將數據操作責任從視圖層中分離，使得數據管理更具模組化和可重用性。
///
/// - 提升靈活性與可測試性：
///   - 通過協議的抽象層，允許方便地替換數據實現（如本地數據或 Firebase 後端），而不影響其他邏輯。
///
/// - 多組件協調的核心：
///   - 提供統一的數據操作接口，允許 `OrderHistoryHandler` 和 `OrderHistoryEditingHandler` 等邏輯組件通過協議協調工作。
///
/// ### 典型使用場景
/// 1. `OrderHistoryHandler`：
///    - 使用 `getOrders()` 方法提供表格視圖數據源，顯示歷史訂單列表。
///    - 使用 `deleteOrder(at:)` 處理單筆訂單的`滑動刪除操作`。
///
/// 2. `OrderHistoryEditingHandler`：
///    - 使用 `deleteOrders(at:)` 方法處理`多選刪除功能`。
///    - 使用 `getOrders()` 確認訂單列表是否為空，或判斷選取的行數。
///
/// ### 設計細節
/// - 依賴方向：
///   - `OrderHistoryViewController` 實現了該協議，負責提供數據邏輯；
///     其他邏輯組件（如 `OrderHistoryHandler` 和 `OrderHistoryEditingHandler`）通過該協議與數據交互。
///
/// - 數據流：
///   - 表格視圖的所有數據操作，如新增、刪除或更新，都通過該協議的方法進行間接操作，
///     保持邏輯清晰和責任分明。
protocol OrderHistoryDataDelegate: AnyObject {
    
    
    /// 獲取所有歷史訂單資料
    ///
    /// - Returns: 一個包含所有歷史訂單的陣列
    ///
    /// - 使用場景：
    ///   - 提供表格視圖的數據源，返回完整的訂單列表。
    ///   - 用於檢查訂單是否為空或判斷列表的總數量。
    func getOrders() -> [OrderHistory]
    
    /// 刪除指定索引的歷史訂單
    ///
    /// - Parameter index: 要刪除的訂單在陣列中的索引
    ///
    /// - 使用場景：
    ///   - 在`一般模式`下，通過`滑動刪除功能`移除單筆訂單。
    ///   - 用於同步更新數據並移除對應的表格視圖行。
    func deleteOrder(at index: Int)
    
    /// 刪除指定的多筆歷史訂單
    ///
    /// - Parameter indices: 要刪除的訂單在陣列中的索引列表
    /// - 使用場景：
    ///   - 在`編輯模式`下，通過多選刪除功能移除多筆訂單。
    ///   - 用於批量操作，確保數據和視圖的同步更新。
    func deleteOrders(at indices: [Int])
    
}
