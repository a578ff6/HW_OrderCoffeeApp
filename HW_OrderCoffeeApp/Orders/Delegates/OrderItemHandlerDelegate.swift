//
//  OrderItemHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/31.
//

// MARK: - OrderItemHandlerDelegate 筆記
/**
 
 ## OrderItemHandlerDelegate 筆記
 
 `* What`
 
 - `OrderItemHandlerDelegate` 是一個統一的協議，負責處理：
 
 1. 訂單操作：如`刪除單個項目`或`清空所有項目`。
 2. 視圖交互：如導航到`編輯頁面`或`顧客資料頁面`。
 3.按鈕狀態更新：根據訂單狀態，動態更新按鈕的可用性。
 4.數據共享：為 OrderItemHandler 提供當前訂單的數據源。

 ------------
 
 `* Why`
 
 1. 減少耦合性：
 - 將訂單操作與視圖交互邏輯從具體類別中解耦，透過委託統一處理。
 
 2. 清晰責任劃分：
 - 避免多個協議（如 `OrderItemActionDelegate` 和 `OrderItemViewInteractionDelegate`）重疊或模糊責任。
 
 3. 提升可讀性：
 - 使用單一協議統一管理相關行為，方便開發和維護。
 
 4.按鈕動態更新：
 - 確保當訂單狀態改變（如清空或新增）時，按鈕狀態能即時反映。
 
 5.數據傳遞：
 - 提供 getOrderItems()，讓 OrderItemHandler 獲取當前訂單數據，保持數據源統一。
 
 ------------

 `* How`
 
 `1. 統一處理`
 
 - 整合原本的 `OrderItemActionDelegate` 和 `OrderItemViewInteractionDelegate`，避免分散責任。
 - 提供統一的方法接口處理：
    - 訂單的增刪操作。
    - 按鈕狀態更新。
    - 訂單數據共享。
    - 導航交互。

 `2. 範例應用`
 
 - 在 `OrderItemHandler` 和 `OrderItemViewController` 之間使用此協議：
    - `OrderItemHandler` 通通知 `OrderItemViewController` 執行具體行為（如刪除、導航或按鈕狀態更新）。
    - `OrderItemViewController` 實現此協議來完成具體的視圖跳轉和操作。

 `3. 示例架構調整`
 
 - 按鈕狀態更新 (`orderItemHandlerDidUpdateButtons`)：
    - 功能：根據訂單是否為空，更新按鈕的啟用或禁用狀態。
    - 範例：
      ```swift
      func orderItemHandlerDidUpdateButtons(isOrderEmpty: Bool) {
          // 根據訂單是否為空，更新按鈕狀態
      }
      ```

 -  數據共享(`getOrderItems`)：
    - 功能：提供當前的訂單數據，供 `OrderItemHandler` 使用。
    - 範例：
      ```swift
      func getOrderItems() -> [OrderItem] {
          return currentOrderItems
      }
      ```

 - 刪除單個訂單項目 (`deleteOrderItem`)：
    - 功能：刪除指定的訂單項目，並同步更新視圖和數據。
    - 範例：
      ```swift
      func deleteOrderItem(_ orderItem: OrderItem) {
          // 刪除邏輯
      }
      ```

 - 清空所有訂單項目 (`clearAllOrderItems`)：
    - 功能：清空訂單列表，並重置相關狀態。
    - 範例：
      ```swift
      func clearAllOrderItems() {
          // 清空邏輯
      }
      ```

 - 導航到編輯頁面 (`navigateToEditOrderItemView`)：
    - 功能：跳轉到編輯指定訂單項目的頁面。
    - 範例：
      ```swift
      func navigateToEditOrderItemView(with orderItem: OrderItem) {
          // 導航邏輯
      }
      ```

 - 導航到顧客資料頁面 (`proceedToCustomerDetails`)：
    - 功能：跳轉到顧客資料頁面。
    - 範例：
      ```swift
      func proceedToCustomerDetails() {
          // 導航邏輯
      }
      ```
 
 ------------

 `* 結論`

 - 採用 `OrderItemHandlerDelegate` 統一管理訂單操作和視圖交互，有以下優點：
   1. 減少類別之間的強耦合。
   2. 提升程式可讀性與維護性。
   3. 確保按鈕狀態和數據源的一致性。
   4. 提高程式的模組化與重用性。
 */


import Foundation

/// `OrderItemHandlerDelegate`
///
/// ### 功能描述
/// 統一處理與訂單相關的業務邏輯（如刪除、清空等操作）及視圖交互邏輯（如導航到編輯頁面或顧客資料頁面），
/// 確保 `OrderItemHandler` 與 `OrderItemViewController` 之間的解耦與職責分明。
///
/// ### 適用場景
/// - 用於 `OrderItemHandler` 與 `OrderItemViewController` 之間的溝通協作。
/// - 簡化不同模組之間的交互，減少邏輯耦合。
protocol OrderItemHandlerDelegate: AnyObject {
    
    // MARK: - 獲取訂單數據相關
    
    /// 獲取當前的訂單項目列表。
    ///
    /// ### 用途
    /// - 用於提供當前的訂單數據，供 `OrderItemHandler` 在顯示列表或進行操作時使用。
    ///
    /// - Returns: 包含當前所有訂單項目的數據列表。
    func getOrderItems() -> [OrderItem]
    
    // MARK: - 按鈕狀態更新相關
    
    /// 當訂單項目列表變更時，更新按鈕狀態。
    ///
    /// ### 用途
    /// - 用於根據當前訂單是否為空，動態更新界面上的按鈕狀態。
    /// - 例如，當訂單為空時禁用「清空」按鈕，或啟用「繼續」按鈕。
    ///
    /// - Parameter isOrderEmpty: 當前訂單是否為空。
    func orderItemHandlerDidUpdateButtons(isOrderEmpty: Bool)
    
    // MARK: - 訂單操作相關
    
    /// 刪除單個訂單項目
    ///
    /// ### 用途
    /// - 用於移除指定的訂單項目，並自動更新訂單列表及相關狀態。
    /// - 例如，當用戶點擊訂單列表中的刪除按鈕時，觸發此方法進行刪除操作。
    ///
    /// - Parameter orderItem: 需要刪除的訂單項目。
    func deleteOrderItem(_ orderItem: OrderItem)
    
    /// 清空所有訂單項目
    ///
    /// ### 用途
    /// - 用於清除當前所有的訂單項目。
    /// - 例如，用戶點擊「清空訂單」按鈕時，調用此方法執行清空操作。
    func clearAllOrderItems()
    
    // MARK: - 視圖交互相關
    
    
    /// 導航到編輯訂單項目頁面 (`EditOrderItemViewController`)
    ///
    /// ### 用途
    /// - 當用戶在訂單列表中點擊某個訂單項目時，觸發此方法進入對應的編輯頁面。
    /// - 傳遞點擊的 `orderItem` 資訊，用於在編輯頁面顯示並修改該訂單內容。
    ///
    /// - Parameter orderItem: 需要編輯的訂單項目。
    func navigateToEditOrderItemView(with orderItem: OrderItem)
    
    /// 進入顧客資料頁面 (`OrderCustomerDetailsViewController`)
    ///
    /// ### 用途
    /// - 用於導航至顧客資料頁面，供用戶填寫或檢視顧客資訊。
    /// - 例如，當用戶完成訂單確認後點擊「繼續」按鈕時，觸發此方法進入顧客資料頁。
    func proceedToCustomerDetails()
    
}
