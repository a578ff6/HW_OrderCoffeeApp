//
//  OrderHistoryManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - 處理順序跟構想
/**
 ## 處理順序跟構想
 
 - 先處理 `OrderHistoryManager`，再處理 UI 佈局。這樣的順序有助於更好地把資料與邏輯處理獨立出來，讓 UI 部分能更專注於展示。

 `* 為什麼先處理 OrderHistoryManager`
 
 `1. 數據驅動 UI 設計：`
    - UI 的佈局應該基於需要顯示的資料來設計。如果先確保 `OrderHistoryManager` 已經完成，並且可以提供訂單數據，那麼在進行 UI 設計時，可以更直觀地看到應該如何去展示這些數據。
    - `OrderHistoryManager` 的功能如獲取訂單資料、排序、過濾等，這些邏輯的確定將有助於更好地設計 UI，例如確定需要什麼樣的排序按鈕或搜索功能。

 `2. 減少重複工作：`
    - 如果先設計 UI，可能在後續處理資料邏輯時會發現需要調整 UI。
        - 例如，當後來決定增加排序功能，可能需要重新調整某些 UI 元素的位置和行為。先完成 `OrderHistoryManager` 可以減少這種來回修改的情況。
    - 例如，可以先確保 `OrderHistoryManager` 能夠成功地從 Firebase 獲取和處理歷史訂單資料，這樣 UI 就可以根據這些資料直接展示，避免後期增加資料邏輯時需要對 UI 做大幅調整。

 `### 先處理 OrderHistoryManager 的具體步驟`
 
 `1. 定義資料接口：`
    - 在 `OrderHistoryManager` 中設置資料獲取的接口，例如 `fetchOrderHistory`，讓這些方法負責從 Firebase 中抓取歷史訂單資料，並處理排序及過濾。
 
 `2. 處理資料邏輯：`
    - 確保排序、過濾等功能的資料邏輯已經設置完成。例如根據時間戳對訂單進行排序，確保可以按需求獲取所需的訂單列表。
 
 `3. 測試資料處理：`
    - 先測試資料部分是否可以正常地提供訂單數據，這樣可以保證在進行 UI 開發時，資料的來源是穩定和可靠的。

 `### 接下來進行 UI 佈局的優勢`
    - 當開始設計 UI 時，已經擁有了可用的數據源。這樣可以用真實數據來進行設計和測試，確保 UI 元素能夠根據資料的變化正確地顯示。
    - 也可以更好地規劃 UI 與數據的交互，例如當用戶進行滑動刪除訂單時，`OrderHistoryManager` 可以提供相應的刪除方法，UI 只需要調用這些方法。

 `### 總結`
    - `先處理 OrderHistoryManager`：確保資料邏輯完整並可以正確地處理歷史訂單。
    - `再處理 UI 佈局`：基於已經準備好的數據源來設計 UI，可以更直觀地展示數據，減少不必要的調整和重複工作。

 這樣的順序可以讓開發過程更有條理，並且減少在 UI 佈局和資料邏輯之間來回調整的情況。
 */


// MARK: - OrderHistoryManager 重點筆記
/**
 ## OrderHistoryManager 重點筆記
 
` 1. OrderHistoryManager 主要負責與 Firestore 的互動：`

    - 負責從 Firebase Firestore 獲取和管理歷史訂單資料。
    - 包括獲取訂單、刪除單筆訂單、批量刪除以及清空所有訂單等操作。
 
 `2. 使用非同步處理（async/await）來簡化非同步操作：`

    - 各個方法使用 Swift 的 async/await，簡化非同步操作，提升代碼的可讀性。
 
` 3. 方法的功能概述：`

    - `fetchOrderHistory(for:)`：取得特定使用者的所有歷史訂單，並根據指定的排序方式進行排序。
    - `deleteOrder(userId:orderId:)`：刪除指定的單筆訂單。
    - `deleteMultipleOrders(userId:orderIds:)`：批量刪除多筆訂單，使用 Firestore 的批次操作（batch）。
    - `clearAllOrders(for:)`：清空指定使用者的所有訂單。
 
 `4. 支援多種排序方式：`

    - 使用 `OrderHistorySortOption` 枚舉來支援多種排序方式，包括：依時間、依金額大小、依取件方式等。
    - 可以根據用戶選擇的排序方式來重新獲取訂單，提供靈活的訂單顯示方式。
 
` 4. 補充說明`
 
    - `Firestore 查詢`：使用 `db.collection("users").document(userId).collection("orders") `來確保只取得特定使用者的訂單資料。
    - `使用批次操作（batch）`：
        - 在批量刪除訂單和清空訂單時使用 Firestore 的批次操作，可以減少多次網路請求的開銷，確保資料一致性。
 */

// MARK: - fetchOrderHistory 方法的設計目標
/**
 
`1.fetchOrderHistory 方法的設計目標`
 
 `* ffetchOrderHistory 方法是通用的，適用於多個場景，例如：`
 
    - 初次進入 `OrderHistoryViewController` 時加載訂單。
    - 按鈕切換排序方式時重新加載訂單。
 
 `2.支持多種排序方式`

    - 方法透過 `sortOption` 參數來靈活選擇不同的排序方式，包括按時間、金額、取件方式等。
    - 初次加載時，通常使用默認的`按時間戳遞減（最新的訂單顯示在最上方）`排序。
    - 在按鈕點擊切換排序方式時，只需調用相同的方法，並傳入不同的 `sortOption`，即可對訂單列表進行重排序。

` 3.使用方法的場景示例`
 
    - `初次加載訂單`：`viewDidLoad` 中調用` fetchOrderHistory(for: userId, sortOption: .byDateDescending)`，獲取按時間遞減排序的訂單列表。
    - `點擊按鈕切換排序`：按鈕點擊後決定新的排序方式，再使用` fetchOrderHistory(for: userId, sortOption: <新的排序方式>)` 獲取排序後的訂單。
 
 `4.程式碼的靈活性和易維護性`
 
    - `代碼重用`：同一個方法可以適應不同場景，只需傳入不同的排序選項，避免撰寫多個類似方法。
    - `提高可讀性`：排序邏輯集中於 `OrderHistoryManager`，UI 部分只需負責用戶交互及顯示，讓代碼清晰易懂且易於維護。
 
` 5.小結`
    
    - `單一方法多用途`：`fetchOrderHistory` 方法可以一開始進入訂單頁面時使用，也可以在用戶切換排序方式時使用。
    - `減少重複代碼`：統一的數據處理邏輯集中於一個方法中，通過不同的參數來控制行為，這樣可以減少重複的代碼並提高靈活性。
    - `簡化 UI 層邏輯`：UI 層只需決定排序方式並調用相應方法即可，簡化了界面的邏輯處理。
 */

import UIKit
import Firebase

/// OrderHistoryManager 負責從 Firebase Firestore 獲取和管理歷史訂單資料。
///
/// - 包括獲取訂單、刪除單筆訂單、批量刪除以及清空所有訂單等操作。
class OrderHistoryManager {
    
    /// 初始化 Firestore 資料庫連結
    private let db = Firestore.firestore()
    
    // MARK: - Fetch Order History

    /// 排序選項，用於指定歷史訂單的不同排序方式
    enum OrderHistorySortOption {
        case byDateDescending        // 依時間由新到舊
        case byDateAscending         // 依時間由舊到新
        case byAmountDescending      // 依金額從高到低
        case byAmountAscending       // 依金額從低到高
        case byPickupMethod          // 依取件方式排序
    }
    
    /// 獲取指定使用者的所有歷史訂單，並根據給定的排序選項進行排序
    /// - Parameters:
    ///   - userId: 使用者的唯一標識符
    ///   - sortOption: 指定的排序方式
    /// - Returns: 排序後的歷史訂單陣列
    func fetchOrderHistory(for userId: String, sortOption: OrderHistorySortOption) async throws -> [OrderHistory] {
        let snapshot = try await db.collection("users").document(userId).collection("orders").getDocuments()
        
        print("Document snapshot: \(snapshot.documents)")
        
        let orders = snapshot.documents.compactMap { document -> OrderHistory? in
            do {
                return try document.data(as: OrderHistory.self)
            } catch {
                print("Failed to parse document: \(document.data()) with error: \(error)")
                return nil
            }
        }
        
        // 根據選擇的排序方式進行排序
        let sortedOrders: [OrderHistory]
        switch sortOption {
        case .byDateDescending:
            sortedOrders = orders.sorted(by: { $0.timestamp > $1.timestamp })
        case .byDateAscending:
            sortedOrders = orders.sorted(by: { $0.timestamp < $1.timestamp })
        case .byAmountDescending:
            sortedOrders = orders.sorted(by: { $0.totalAmount > $1.totalAmount })
        case .byAmountAscending:
            sortedOrders = orders.sorted(by: { $0.totalAmount < $1.totalAmount })
        case .byPickupMethod:
            sortedOrders = orders.sorted(by: { $0.customerDetails.pickupMethod.rawValue < $1.customerDetails.pickupMethod.rawValue })
        }
        
        return sortedOrders
    }
    
    // MARK: - Delete Single Order

    /// 刪除指定的單筆訂單
    /// - Parameters:
    ///   - userId: 使用者的唯一標識符
    ///   - orderId: 要刪除的訂單 ID
    func deleteOrder(userId: String, orderId: String) async throws {
        let orderRef = db.collection("users").document(userId).collection("orders").document(orderId)
        try await orderRef.delete()
    }
    
    // MARK: - Delete Multiple Orders

    /// 批量刪除多筆訂單
    /// - Parameters:
    ///   - userId: 使用者的唯一標識符
    ///   - orderIds: 要刪除的訂單 ID 陣列
    func deleteMultipleOrders(userId: String, orderIds: [String]) async throws {
        let batch = db.batch()
        for orderId in orderIds {
            let orderRef = db.collection("users").document(userId).collection("orders").document(orderId)
            batch.deleteDocument(orderRef)
        }
        try await batch.commit()
    }
    
    // MARK: - Clear All Orders

    /*
    /// 清空指定使用者的所有訂單
    /// - Parameter userId: 使用者的唯一標識符
    func clearAllOrders(for userId: String) async throws {
        let snapshot = try await db.collection("users").document(userId).collection("orders").getDocuments()
        let batch = db.batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        try await batch.commit()
    }
    */
    
}
