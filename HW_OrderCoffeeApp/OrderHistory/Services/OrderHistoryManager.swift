//
//  OrderHistoryManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//


// MARK: - Firebase 登入與歷史訂單查詢指南
/**
 
 ### Firebase 登入與歷史訂單查詢指南

 `1. Firebase 登入與訂單查詢`
 
    - 使用 `Firebase Authentication` 提供的登入功能，取得當前登入的使用者資訊。
    - 透過 `Auth.auth().currentUser` 獲取已登入使用者的 `uid`，作為查詢歷史訂單的依據。

 ----
 
 `2. 為何這樣做：`
 
 - 唯一標識符 uid：
 
    - 每個 Firebase 使用者都有一個唯一的 `uid`，可用來區分使用者，確保查詢 Firestore 訂單時只取得當前登入使用者的資料。
    
 - 避免未登入的狀態：
 
    - 通過 `Auth.auth().currentUser`，確保只有在已登入的情況下進行訂單資料查詢，未登入則進行相應的處理。
 
 - 提高資料安全性：
 
    - 透過 `uid` 來查詢訂單集合，可以避免用戶誤讀或修改其他用戶的資料，確保每個用戶只能管理自己的訂單。

 ----

` 3. Firestore 中的數據結構：`
    
 - 數據結構設計：
    
    users (collection)
    └── {userId} (document)
          └── orders (subcollection)
              └── {orderId} (document)
    
 - 使用目前使用者的 `uid` 查詢其下的 `orders` 子集合，能精準定位該使用者的所有訂單。
 
    - db.collection("users").document(userId).collection("orders").getDocuments()

 ----

 `4. 小結`
 
    - 利用 Firebase 的帳號登入功能，確保取得的訂單數據是屬於當前登入使用者的。
    - 使用 `Auth.auth().currentUser` 來取得使用者的 `uid`，並作為查詢依據，增強資料的安全性與精確性。
    - 只顯示與當前使用者相關的資料，有效防止用戶之間的資料誤取，提供安全的使用體驗。
 */


// MARK: - fetchOrderHistory 方法的設計目標
/**
 
`1.fetchOrderHistory 方法的設計目標`
 
 `* fetchOrderHistory 方法是通用的，適用於多個場景，例如：`
 
    - 初次進入 `OrderHistoryViewController` 時加載訂單。
    - 按鈕切換排序方式時重新加載訂單。
 
 ---
 
 `2.支持多種排序方式`

    - 方法透過 `sortOption` 參數來靈活選擇不同的排序方式，包括按時間、金額、取件方式等。
    - 初次加載時，通常使用默認的`按時間戳遞減（最新的訂單顯示在最上方）`排序。
    - 在按鈕點擊切換排序方式時，只需調用相同的方法，並傳入不同的 `sortOption`，即可對訂單列表進行重排序。

 ---

` 3.使用方法的場景示例`
 
    - `初次加載訂單`：`viewDidLoad` 中調用` fetchOrderHistory(sortOption: .byDateDescending)`，獲取按時間遞減排序的訂單列表。
    - `點擊按鈕切換排序`：按鈕點擊後決定新的排序方式，再使用` fetchOrderHistory(sortOption: <新的排序方式>)` 獲取排序後的訂單。
 
 ---

 `4.程式碼的靈活性和易維護性`
 
    - `代碼重用`：同一個方法可以適應不同場景，只需傳入不同的排序選項，避免撰寫多個類似方法。
    - `提高可讀性`：排序邏輯集中於 `OrderHistoryManager`，UI 部分只需負責用戶交互及顯示，讓代碼清晰易懂且易於維護。
 
 ---

` 5.小結`
    
    - `單一方法多用途`：`fetchOrderHistory` 方法可以一開始進入訂單頁面時使用，也可以在用戶切換排序方式時使用。
    - `減少重複代碼`：統一的數據處理邏輯集中於一個方法中，通過不同的參數來控制行為，這樣可以減少重複的代碼並提高靈活性。
    - `簡化 UI 層邏輯`：UI 層只需決定排序方式並調用相應方法即可，簡化了界面的邏輯處理。
 */


// MARK: - OrderHistoryManager 的筆記
/**
 
 ### OrderHistoryManager 的筆記


 `* What`
 
 - `OrderHistoryManager` 是負責處理與 Firebase Firestore 的歷史訂單相關業務邏輯的核心管理器。
 
 它的職責包含：
 
 1. 獲取歷史訂單：
 
    - 從 Firebase 中檢索當前使用者的訂單資料。
    - 使用 `OrderHistorySortOption` 提供的 `sort(_:)` 方法，根據不同的排序條件對訂單進行排序。
  
 2. 刪除訂單：
 
    - 支援單筆刪除與批量刪除的功能，確保 Firebase 資料庫與應用內展示邏輯保持一致。
 
 3. 資料處理集中化：
 
    - 將與 Firestore 通訊的邏輯封裝於一處，簡化其他模組的實現，提升可維護性。
 
 4. 支援多種排序方式：`

    - 使用 `OrderHistorySortOption` 枚舉來支援多種排序方式，包括：依時間、依金額大小、依取件方式等。
    - 可以根據用戶選擇的排序方式來重新獲取訂單，提供靈活的訂單顯示方式。
 
 --------

 `* Why `
 
 1. 職責劃分清晰：
 
    - 排序邏輯已被封裝於 `OrderHistorySortOption`，使得 `OrderHistoryManager` 專注於資料存取與管理。
    - 將排序邏輯從管理器中抽離後，能降低重複實現的風險，提升可讀性與易用性。

 2. 提升模組化設計：
 
    - 排序選項透過標準化的 `sort(_:)` 方法實現，使排序邏輯能在其他地方重用，例如 UI 排序選單。

 3. 降低複雜性：
 
    - 使用者無需關注排序的內部細節，只需調用 `fetchOrderHistory` 方法並傳遞對應的排序選項即可。

 --------

 `* How`
 
 1. 設計核心方法：
 
 - `fetchOrderHistory(sortOption:)`:
   - 從 Firebase 獲取訂單資料。
   - 解析 Firebase 返回的訂單快照。
   - 調用 `OrderHistorySortOption.sort(_:)`，根據排序條件對訂單排序。
 
 - `deleteOrder`:
   - 驗證使用者身份，刪除指定的單筆訂單。

 - `deleteMultipleOrders`:
   - 使用 Firebase 的批次處理刪除多筆訂單，確保效率與一致性。
 
 - 與排序邏輯的結合
    - 排序邏輯被封裝至 `OrderHistorySortOption`，每個選項都定義了自己的排序規則，避免了重複的 `switch` 分支實現。

 2. 方法實現細節：
 
    - 獲取歷史訂單
      - 驗證當前使用者是否登入。
      - 使用 Firestore 查詢指定使用者的訂單集合。
      - 將查詢結果轉換為應用所需的 `OrderHistory` 結構。
      - 根據參數中的排序選項對資料進行排序後返回。
 
    - 刪除單筆訂單
      - 驗證當前使用者是否登入。
      - 通過指定的 `orderId`，操作 Firestore 中的對應文件進行刪除。
 
    - 批量刪除訂單
      - 驗證當前使用者是否登入。
      - 使用 Firestore 的批次操作（Batch）進行多筆訂單的刪除，提高效率並確保資料一致性。

 3. 錯誤處理：
 
    - 使用 `guard` 檢查使用者登入狀態，未登入時拋出錯誤。
    - 捕捉 Firestore 操作中的異常，記錄詳細的錯誤日誌。

 4. 與應用邏輯的結合：
 
    - 在 UI 控制器中調用 `OrderHistoryManager` 的方法，通過非同步方式獲取或更新資料。
    - 控制器負責處理資料的展示邏輯，確保與管理器的職責分離。

 --------

 `* 結論`
 
 - `OrderHistoryManager` 是符合職責單一原則的模組化設計，為應用內與 Firebase 的歷史訂單交互提供了高效且可靠的解決方案。
 - 通過其集中化的資料管理方式，減少了代碼的重複和錯誤的可能性，同時也提升了模組的可測試性與擴展性。
 - 通過與 `OrderHistorySortOption` 的結合，實現了靈活的排序處理與高效的資料管理，提升了應用的可維護性與擴展性。

 */



// MARK: - (v)


import UIKit
import Firebase


/// `OrderHistoryManager` 負責與 Firebase Firestore 進行通訊，處理歷史訂單的資料存取和業務邏輯。
///
/// ### 功能概述
/// - 資料獲取：從 Firebase 獲取當前使用者的歷史訂單，並依據指定的排序選項進行排序。
/// - 單筆刪除：刪除指定的單筆歷史訂單資料。
/// - 批量刪除：一次性刪除多筆歷史訂單資料。
///
/// ### 設計目標
/// - 集中化資料處理：通過集中管理與 Firebase 的資料交互邏輯，簡化其他模組的開發。
/// - 模組化與擴展性：將排序和刪除操作分離為具體方法，方便未來擴展或修改。
/// - 錯誤處理：當使用者未登入或操作失敗時，返回清晰的錯誤信息。
class OrderHistoryManager {
    
    /// Firebase Firestore 的資料庫實例，用於操作訂單資料。
    private let db = Firestore.firestore()
    
    
    // MARK: - Helper Methods
    
    /// 獲取當前登入使用者的 User ID。
    ///
    /// - Returns: 當前使用者的 UID。
    /// - Throws: 若未登入，則拋出 `AuthError` 錯誤。
    private func getCurrentUserId() throws -> String {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in"])
        }
        return currentUser.uid
    }
    
    // MARK: - Fetch Order History
    
    /// 從 Firebase 獲取指定使用者的歷史訂單，並依據給定的排序選項進行排序。
    ///
    /// - Parameters:
    ///   - sortOption: 指定的排序方式，透過 `OrderHistorySortOption` 處理。
    ///
    /// - Returns: 排序後的歷史訂單陣列。
    /// - Throws: 若無法獲取當前使用者或 Firebase 通訊失敗，則拋出錯誤。
    func fetchOrderHistory(sortOption: OrderHistorySortOption) async throws -> [OrderHistory] {
        
        let userId = try getCurrentUserId()
        
        // 獲取訂單集合的快照資料。
        let snapshot = try await db.collection("users").document(userId).collection("orders").getDocuments()
        
        // 解析快照資料為 `OrderHistory` 模型。
        let orders = snapshot.documents.compactMap { document -> OrderHistory? in
            try? document.data(as: OrderHistory.self)
        }
        
        // 根據排序選項進行排序。
        return sortOption.sort(orders)
    }
    
    // MARK: - Delete Single Order
    
    /// 刪除指定的單筆訂單。
    ///
    /// - Parameters:
    ///   - orderId: 要刪除的訂單 ID
    /// - Throws: 若使用者未登入或刪除操作失敗，則拋出錯誤
    func deleteOrder(orderId: String) async throws {
        let userId = try getCurrentUserId()
        let orderRef = db.collection("users").document(userId).collection("orders").document(orderId)
        try await orderRef.delete()
    }
    
    // MARK: - Delete Multiple Orders
    
    /// 批量刪除多筆訂單。
    ///
    /// - Parameters:
    ///   - orderIds: 要刪除的訂單 ID 陣列
    /// - Throws: 若使用者未登入或批量刪除失敗，則拋出錯誤
    func deleteMultipleOrders(orderIds: [String]) async throws {
        let userId = try getCurrentUserId()
        let batch = db.batch()
        
        // 將刪除操作加入批次處理
        for orderId in orderIds {
            let orderRef = db.collection("users").document(userId).collection("orders").document(orderId)
            batch.deleteDocument(orderRef)
        }
        try await batch.commit()
    }
    
}
