//
//  OrderHistoryNavigationDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/19.
//


// MARK: - OrderHistoryNavigationDelegate 筆記
/**
 
 ### OrderHistoryNavigationDelegate 筆記

 - 本來 `navigateToOrderHistoryDetail` 是設置在 `OrderHistoryDataDelegate` ，但是考量到有一般模式、編輯模式，而導航的邏輯如果位於 `OrderHistoryDataDelegate`，會導致與模式的切換混亂。
 - 因此才將`navigateToOrderHistoryDetail`特別拆出設置`OrderHistoryDataDelegate`處理。
 
 ---

 `* What`

 - `OrderHistoryNavigationDelegate` 是一個用於處理導航邏輯的協定，負責從歷史訂單列表中，將使用者導引至特定訂單的詳細資訊頁面。

 - 主要功能：
 
   - 提供一個介面，用於執行「導航至詳細頁面」的操作。
   - 解耦表格視圖與導航邏輯，讓 `UITableView` 和導航功能分開，遵循單一責任原則。

 ---

 `* Why`

 1. 解耦責任：
 
    - 表格視圖的資料管理 (`UITableViewDataSource` 和 `UITableViewDelegate`) 與導航邏輯是不同的功能，應分開處理，讓程式碼更清晰、易維護。

 2. 提升可測試性：
 
    - 使用協定可以讓導航邏輯抽象化，方便撰寫單元測試，驗證導航行為是否正確實現。

 3. 靈活性：
 
    - 不同的 `ViewController` 可以根據需求實現各自的導航邏輯，而不需要更改核心功能。

 4. 符合設計原則：
 
    - 單一職責原則 (Single Responsibility Principle) 和開放封閉原則 (Open-Closed Principle)。

 ------------

 `* How`

 1. 定義協定
 
    ```swift
    import Foundation

    /// `OrderHistoryNavigationDelegate`
    ///
    /// - 用於處理導航至歷史訂單詳細頁面的邏輯。
    protocol OrderHistoryNavigationDelegate: AnyObject {
        
        /// 導航至指定的歷史訂單詳細頁面
        ///
        /// - Parameter order: 要查看詳細資訊的歷史訂單資料
        func navigateToOrderHistoryDetail(with order: OrderHistory)
    }
    ```

 ---

 2. 實現協定
 
    - 在 `OrderHistoryViewController` 中實現該協定，用以導航至詳細頁面。
 
    ```swift
    extension OrderHistoryViewController: OrderHistoryNavigationDelegate {
        func navigateToOrderHistoryDetail(with order: OrderHistory) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(
                withIdentifier: Constants.Storyboard.orderHistoryDetailViewController
            ) as? OrderHistoryDetailViewController else { return }
            
            detailVC.orderId = order.id
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    ```

 ---

 3. 設置代理
 
    - 在 `OrderHistoryHandler` 初始化時，設置 `orderHistoryNavigationDelegate`。
 
    ```swift
    private func setupOrderHistoryHandler() {
        let handler = OrderHistoryHandler(
            orderHistoryDataDelegate: self,
            orderHistorySelectionDelegate: self,
            orderHistoryNavigationDelegate: self // 設置導航代理
        )
        self.orderHistoryHandler = handler
        configureTableView(with: handler)
    }
    ```

 ---
 
 4. 觸發導航邏輯
 
    - 在表格行被選取時，觸發導航代理的方法：
 
    ```swift
    private func handleSelectionStateChange(for tableView: UITableView, at indexPath: IndexPath, isSelected: Bool) {
        if !tableView.isEditing && isSelected {
            guard let orders = orderHistoryDataDelegate?.getOrders() else { return }
            let selectedOrder = orders[indexPath.row]
            orderHistoryNavigationDelegate?.navigateToOrderHistoryDetail(with: selectedOrder)
        }
    }
    ```

 ------------

 `* 總結`

 - What
 
   `OrderHistoryNavigationDelegate` 提供了一個抽象化的導航邏輯，讓視圖控制器與導航行為解耦，提升程式碼的模組化與可維護性。

 - Why
 
   1. 解耦責任，遵循單一職責原則。
   2. 增加靈活性，不同視圖控制器可實現自訂導航行為。
   3. 提升測試與擴展能力，導航邏輯可單獨測試與替換。

 - How
 
   - 定義協定並實作具體邏輯。
   - 在 `OrderHistoryHandler` 中設置代理。
   - 在表格行選取邏輯中，觸發協定方法執行導航操作。

 */


// MARK: - (v)

import Foundation

/// `OrderHistoryNavigationDelegate`
///
/// 用於處理表格視圖中「導航至歷史訂單詳細頁面」的邏輯。
///
/// ### 使用場景
/// 1. 當使用者在`正常模式`點選某筆歷史訂單行時，觸發導航邏輯，進入詳細資訊頁面。
/// 2. 解耦表格視圖與導航邏輯，提升程式碼可維護性與可讀性。
/// 3. 提供靈活的導航方式，允許不同的視圖控制器實現自訂導航行為。
///
/// ### 實現範例
/// 在 `UITableViewDelegate` 的 `didSelectRowAt` 方法中，檢測到非編輯模式並呼叫該協定方法。
protocol OrderHistoryNavigationDelegate: AnyObject {
    
    /// 導航至指定的歷史訂單詳細頁面
    ///
    /// - Parameter order: 要查看詳細資訊的歷史訂單資料
    /// - 說明：當使用者點選某筆歷史訂單行時，調用此方法執行導航邏輯，會跳轉到一個新頁面顯示詳細資訊。
    func navigateToOrderHistoryDetail(with order: OrderHistory)
    
}
