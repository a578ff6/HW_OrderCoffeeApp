//
//  StoreManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//


// MARK: - StoreManager 筆記
/**
 
 ## StoreManager 筆記

 `* What`
 
 - `StoreManager` 是一個負責管理店鋪資料的類別，主要功能包括：
 
 1. 從 Firebase Firestore 獲取 `stores` 集合中的所有店鋪資料。
 2. 將 Firestore 的數據解析為 `Store` 模型，供應用中的其他模組使用。
 3. 以單例模式提供全局訪問，確保資料管理的統一性。

 ------------

 `* Why`
 
` 1. 單一責任：`
 
    - 集中處理店鋪資料的獲取與解析，減少資料處理邏輯分散於各個模組。
    - 與 `Store` 模型解耦，避免 Firestore 特定邏輯侵入 `Store` 結構。
 
 `2. 簡化代碼與維護性：`
 
    - 提供一個統一的入口管理店鋪資料，減少重複代碼。
    - 當 Firestore 結構變更時，只需修改 `StoreManager`，不影響其他模組。
 
` 3. 支援擴展：`
 
    - 可以在未來擴展更多資料處理功能，例如：快取機制、資料篩選、實時監控。

 ------------

 `* How`
 
 `1. 單例設計：`
 
    - 使用 `static let shared` 實現單例模式，提供全局唯一的 `StoreManager` 實例。
    - 確保所有模組訪問相同的資料來源，保持一致性。

 `2. 資料獲取：`
 
    - 使用 Firebase Firestore 的 `getDocuments` 方法異步獲取 `stores` 集合中的所有文件。
    - 通過 `parseStore(from:)` 方法將 Firestore 的每個文件解析為 `Store` 模型。

 `3. 資料解析：`
 
    - 驗證 Firestore 文件中的必要字段是否存在：
      - 店鋪名稱（`name`）
      - 地址（`address`）
      - 電話號碼（`phoneNumber`）
      - 地理位置（`location`）
      - 營業時間（`openingHours`）
    - 若某些字段缺失或類型不符，跳過該文件並返回 `nil`，確保資料質量。

 `4. 擴展功能（未來可選）：`
 
    - 增加本地快取：在記憶體或磁碟中快取資料，減少頻繁的 Firestore 請求。
    - 支援實時更新：透過 Firestore 的 `addSnapshotListener` 方法，監控數據變化。

 ------------

 `* 使用範例`

 ```swift
 // 在某個 ViewController 中使用 StoreManager 獲取店鋪資料
 Task {
     do {
         let stores = try await StoreManager.shared.fetchStores()
         print("成功獲取店鋪數量：\(stores.count)")
     } catch {
         print("獲取店鋪資料失敗：\(error.localizedDescription)")
     }
 }
 ```

 ------------

 `* 改進想法`
 
 1. 錯誤記錄：
 
    - 若 `parseStore(from:)` 解析失敗，可考慮將錯誤原因記錄至日誌，便於追蹤與調試。
    
 2. 快取支持：
 
    - 引入快取機制，優先返回本地快取資料，並在背景中同步更新 Firestore 資料。

 3. 條件篩選：
 
    - 提供條件參數，例如按地理位置篩選店鋪，或只獲取營業中的店鋪。

 */


// MARK: - (v)

import Foundation
import Firebase


/// **StoreManager**
///
/// 負責處理店鋪相關資料的管理類別，提供與 Firestore 的交互邏輯，專注於店鋪數據的獲取和解析。
///
/// 功能：
/// 1. 從 Firestore 中獲取所有店鋪資料，並解析為 `Store` 模型。
/// 2. 提供單例模式，方便全局使用。
///
/// 設計目標：
/// - 單一責任：專注於店鋪資料的管理與 Firestore 的交互，避免與其他模組混合邏輯。
/// - 高效性：通過批量獲取和解析資料，減少 Firestore 請求次數。
/// - 可測試性：將資料獲取和解析邏輯集中，便於測試與維護。
class StoreManager {
    
    // MARK: - Singleton
    
    /// 單例物件，提供全域存取
    static let shared = StoreManager()
    
    // MARK: - Fetch Stores (獲取店鋪資料)
    
    /// 從 Firestore 獲取所有店鋪資料
    ///
    /// 此方法使用 Firebase Firestore 的 `getDocuments` 方法，異步獲取所有 `stores` 集合中的文件，並將其解析為 `Store` 模型。
    ///
    /// - Returns: 包含所有店鋪的 `Store` 陣列。
    /// - Throws: 如果 Firestore 請求或解析過程中發生錯誤，會拋出異常。
    func fetchStores() async throws -> [Store] {
        
        let db = Firestore.firestore()
        let snapshot = try await db.collection("stores").getDocuments()
        
        return snapshot.documents.compactMap { parseStore(from: $0) }
    }
    
    // MARK: - Private Method
    
    /// 解析 Firestore Document 為 Store 資料模型
    ///
    /// 此方法將 Firestore 文件的數據映射到 `Store` 模型中。如果資料不完整或格式錯誤，會返回 `nil`。
    ///
    /// - Parameter document: Firestore 中的單個文件 (`QueryDocumentSnapshot`)。
    /// - Returns: 解析成功則返回 `Store`，失敗則返回 `nil`。
    ///
    /// 解析過程：
    /// 1. 驗證文件中的必須欄位是否存在。
    /// 2. 將數據轉換為 `Store` 模型中對應的屬性。
    ///
    /// 注意：
    /// - 如果文件中的數據結構發生變更，可能需要同步更新此方法的邏輯。
    private func parseStore(from document: QueryDocumentSnapshot) -> Store? {
        let data = document.data()
        
        guard let name = data["name"] as? String,
              let location =  data["location"] as? GeoPoint,
              let address = data["address"] as? String,
              let phoneNumber = data["phoneNumber"] as? String,
              let openingHours = data["openingHours"] as? [String: String]
        else {
            return nil
        }
        
        return Store(
            id: document.documentID,
            name: name,
            location: location,
            address: address,
            phoneNumber: phoneNumber,
            openingHours: openingHours
        )
    }
    
}
