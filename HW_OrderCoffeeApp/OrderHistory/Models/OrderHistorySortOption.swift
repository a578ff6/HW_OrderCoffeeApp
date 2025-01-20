//
//  OrderHistorySortOption.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/15.
//


// MARK: - OrderHistorySortOption 筆記
/**
 
 ## OrderHistorySortOption 筆記

 `* What`
 
 - `OrderHistorySortOption` 是一個枚舉，負責定義歷史訂單排序方式的選項，用於指定排序時的規則或條件。
 
 - 定義內容：
 
   - **byDateDescending**: 按時間排序，從新到舊。
   - **byDateAscending**: 按時間排序，從舊到新。
   - **byAmountDescending**: 按金額排序，從高到低。
   - **byAmountAscending**: 按金額排序，從低到高。
   - **byPickupMethod**: 按取件方式排序。

 - 功能：
 
   - 提供統一的排序選項，避免硬編碼的排序條件。
   - 通過 `sort(_:)` 方法，封裝排序邏輯，實現排序功能模組化。

 --------

 `* Why:`
 
 1. 降低耦合性：
 
    - 排序邏輯集中於 `OrderHistorySortOption`，避免散落在不同模組中，提升維護性。
    - 確保排序選項與其具體邏輯的關聯性，減少跨模組依賴。

 2. 提升可讀性：
 
    - 封裝排序邏輯，使程式碼更加語義化，易於理解與使用。
    - 在使用排序功能時，開發者不需要關注具體實現，只需選擇適當的 `OrderHistorySortOption`。

 3. 增強可重用性：
 
    - `sort(_:)` 方法提供通用接口，可以在任何需要排序的場景下使用。
    - 未來若新增排序條件，只需擴展枚舉和 `sort(_:)` 方法，不影響現有模組。

 4. 強化擴展性：
 
    - 若需新增排序邏輯，例如基於自定義欄位排序，只需擴展枚舉並添加對應邏輯。

 --------

 `* How:`

 1. 定義枚舉，列舉所有排序選項：
 
    ```swift
    enum OrderHistorySortOption {
        case byDateDescending
        case byDateAscending
        case byAmountDescending
        case byAmountAscending
        case byPickupMethod
    }
    ```

 -----
 
 2. 添加 `sort(_:)` 方法到擴展中：
 
    ```swift
    extension OrderHistorySortOption {
        func sort(_ orders: [OrderHistory]) -> [OrderHistory] {
            switch self {
            case .byDateDescending:
                return orders.sorted { $0.timestamp > $1.timestamp }
            case .byDateAscending:
                return orders.sorted { $0.timestamp < $1.timestamp }
            case .byAmountDescending:
                return orders.sorted { $0.totalAmount > $1.totalAmount }
            case .byAmountAscending:
                return orders.sorted { $0.totalAmount < $1.totalAmount }
            case .byPickupMethod:
                return orders.sorted { $0.customerDetails.pickupMethod.rawValue < $1.customerDetails.pickupMethod.rawValue }
            }
        }
    }
    ```

 -----

 3. 使用範例：
 
    ```swift
    let orders: [OrderHistory] = [...] // 訂單陣列
    let sortedOrders = OrderHistorySortOption.byDateDescending.sort(orders)
    ```

 --------

 `* 優化考量：`
 
 1. 強調排序邏輯集中化：
 
    - 將與排序相關的邏輯統一管理於 `OrderHistorySortOption`，避免分散在其他模組中。
 
 2. 支援本地化與後端儲存：
 
    - 可以擴展 `OrderHistorySortOption` 為 `RawRepresentable`，使用字串或整數作為原始值，方便儲存與本地化。

    ```swift
    enum OrderHistorySortOption: String {
        case byDateDescending = "date_desc"
        case byDateAscending = "date_asc"
        case byAmountDescending = "amount_desc"
        case byAmountAscending = "amount_asc"
        case byPickupMethod = "pickup_method"
    }
    ```

 --------

 `* 總結`
 
 - `OrderHistorySortOption` 通過新增的 `sort(_:)` 方法實現排序邏輯封裝，進一步提升模組的可讀性、可維護性和擴展性。
 - 作為統一的排序選項與邏輯管理單位，它在資料處理與 UI 排序選單等多個場景中具備良好的重用性與一致性。
 */


// MARK: - (v)

import Foundation

/// 排序選項，用於指定歷史訂單的不同排序方式。
///
/// - **byDateDescending**: 依時間由新到舊。
/// - **byDateAscending**: 依時間由舊到新。
/// - **byAmountDescending**: 依金額從高到低。
/// - **byAmountAscending**: 依金額從低到高。
/// - **byPickupMethod**: 依取件方式排序。
enum OrderHistorySortOption {
    case byDateDescending
    case byDateAscending
    case byAmountDescending
    case byAmountAscending
    case byPickupMethod
}


// MARK: - Extension
extension OrderHistorySortOption {
    
    /// 根據排序選項對訂單進行排序的邏輯。
    ///
    /// 此方法使用 `OrderHistorySortOption` 的具體值，應用對應的排序規則。
    ///
    /// - Parameter orders: 要排序的歷史訂單陣列。
    /// - Returns: 排序後的訂單陣列，根據當前 `OrderHistorySortOption` 的規則進行排列。
    func sort(_ orders: [OrderHistory]) -> [OrderHistory] {
        switch self {
        case .byDateDescending:
            return orders.sorted { $0.timestamp > $1.timestamp }
        case .byDateAscending:
            return orders.sorted { $0.timestamp < $1.timestamp }
        case .byAmountDescending:
            return orders.sorted { $0.totalAmount > $1.totalAmount }
        case .byAmountAscending:
            return orders.sorted { $0.totalAmount < $1.totalAmount }
        case .byPickupMethod:
            return orders.sorted { $0.customerDetails.pickupMethod.rawValue < $1.customerDetails.pickupMethod.rawValue }
        }
    }
    
}
