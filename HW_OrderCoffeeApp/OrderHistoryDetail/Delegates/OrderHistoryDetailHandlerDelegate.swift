//
//  OrderHistoryDetailHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

// MARK: - OrderHistoryDetailHandlerDelegate 筆記
/**
 
 ## OrderHistoryDetailHandlerDelegate 筆記

 `* What`
 
 - `OrderHistoryDetailHandlerDelegate` 是一個協議，用於協助 `OrderHistoryDetailHandler` 與外部類別（例如 `OrderHistoryDetailViewController`）進行數據溝通。

 - 主要功能:
 
   1. 提供 `OrderHistoryDetail`：透過協議方法，讓 `OrderHistoryDetailHandler` 獲取完整的歷史訂單詳細資料。
   2. 確保數據完整性：協議實現類別（如 `OrderHistoryDetailViewController`）需要保證提供的數據是完整且正確的。

 - 相關類別:
 
   - `OrderHistoryDetailHandler`：依賴協議獲取數據。
   - `OrderHistoryDetailViewController`：負責實現協議，並返回 `OrderHistoryDetail`。

 -----------

 `* Why`
 
 1. 解耦合：
 
    - 協議將數據提供的責任從 `OrderHistoryDetailHandler` 中分離，使其只專注於處理視圖邏輯。
    - 實現數據提供和視圖邏輯的分工，符合單一職責原則 (SRP)。

 2. 數據安全性與完整性：
 
    - 通過協議的契約約束，確保數據供應方（如 `OrderHistoryDetailViewController`）提供的數據符合預期。

 3. 提高可測試性：
 
    - 使用協議的依賴注入模式，允許在單元測試中輕鬆模擬數據，無需依賴具體的數據提供類。

 4. 靈活擴展：
 
    - 如果將來需要改變數據來源（例如從網絡改為本地存儲），只需更換協議的實現類別，無需更改 `OrderHistoryDetailHandler` 的邏輯。

 -----------

 `* How`

 1. 定義協議:
 
    - 定義協議 `OrderHistoryDetailHandlerDelegate`，包含方法 `getOrderHistoryDetail()`：
 
    ```swift
    protocol OrderHistoryDetailHandlerDelegate: AnyObject {
        func getOrderHistoryDetail() -> OrderHistoryDetail
    }
    ```

 ----
 
 2. 實現協議:
 
    - 在 `OrderHistoryDetailViewController` 中實現該協議，提供 `OrderHistoryDetail` 數據：
    
 ```swift
    extension OrderHistoryDetailViewController: OrderHistoryDetailHandlerDelegate {
        func getOrderHistoryDetail() -> OrderHistoryDetail {
            guard let orderHistoryDetail = orderHistoryDetail else {
                fatalError("OrderHistoryDetail is not available")
            }
            return orderHistoryDetail
        }
    }
    ```

 ----

 3. 注入依賴:
 
    - 在初始化 `OrderHistoryDetailHandler` 時，注入協議實現類別作為代理：
    
 ```swift
    private func initializeDetailHandler() {
        let handler = OrderHistoryDetailHandler(
            orderHistoryDetailHandlerDelegate: self,
            orderHistoryDetailSectionDelegate: self
        )
        self.orderHistoryDetailHandler = handler
        configureCollectionView(handler: handler)
    }
    ```

 ----

 4. 數據流動過程:
 
    - `OrderHistoryDetailHandler` 透過協議方法 `getOrderHistoryDetail()` 獲取訂單數據。
    - 實現類別（`OrderHistoryDetailViewController`）提供數據來源並保證完整性。
    - 此設計確保數據流動清晰且易於追蹤。

 -----------

 `* 備註`
 
 1.最佳實踐:
 
   - 確保協議返回的數據在調用前已加載完成。
   - 考慮支持異步方法 (`async throws`)，處理數據加載的延遲場景。
 
 2.擴展方向:
 
   - 如果需要處理更多數據相關操作，可擴展協議方法，例如支持增量更新、錯誤處理等。
 */


// MARK: - (v)

import Foundation


/// `OrderHistoryDetailHandlerDelegate`
///
/// 此協議用於協助 `OrderHistoryDetailHandler` 與外部類別進行溝通，
/// 提供歷史訂單詳細資料的獲取方法，確保 `OrderHistoryDetailHandler` 能獲取必要的數據進行處理。
///
/// ### 功能:
/// 1. 提供 `OrderHistoryDetail` 物件: 讓 `OrderHistoryDetailHandler` 獲取完整的訂單詳細資料。
/// 2. 確保資料完整性: 通過協議保證 `OrderHistoryDetailHandler` 委託的類別能返回所需數據，避免數據不一致的問題。
///
/// ### 使用場景:
/// 當 `OrderHistoryDetailHandler` 需要從外部類別（如 `OrderHistoryDetailViewController`）獲取歷史訂單詳細資料時，
/// 通過此協議與外部進行交互。
///
/// ### 相關類別:
/// - `OrderHistoryDetailHandler`: 透過此協議獲取數據。
/// - `OrderHistoryDetailViewController`: 實現協議，並返回歷史訂單詳細資料。
protocol OrderHistoryDetailHandlerDelegate: AnyObject {
    
    /// 獲取歷史訂單的詳細資料
    ///
    /// - Returns: 一個 `OrderHistoryDetail` 物件，包含完整的歷史訂單詳細資訊，例如顧客資訊、商品項目等。
    func getOrderHistoryDetail() -> OrderHistoryDetail
    
}
