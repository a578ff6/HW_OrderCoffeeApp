//
//  StoreManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - StoreManager 重點筆記

/*
 ## StoreManager 重點筆記
 
 1. 類別說明
    - StoreManager 是用來管理店鋪相關資料的管理器，負責從 Firestore 中拉取店鋪資料，並處理與店鋪相關的其他操作。
 
 2. 主要方法
 
    * fetchStores()：
        - 從 Firestore 中拉取店鋪的數據，並將其轉換為 Store 結構的陣列。
        - 地理位置改為使用 `GeoPoint`，可以更方便地進行地理位置的查詢和操作。

    * getTodayOpeningHours(for:)：
        - 根據當前的日期，返回所有店鋪的今日營業時間。
        - 使用 DateFormatter 格式化出今天是星期幾，並以此查找店鋪的營業時間。
        - 回傳一個字典，字典的 key 是店鋪的 ID，值則是今日營業時間。
 
    * getNearestStores(to:from:maxDistance:)（被註解掉的部分）：
        - 這個方法是根據使用者的當前位置來篩選附近的店鋪（範圍以距離來決定），目前還未啟用。（後續再重新測試）
 
 3. Helper 方法的設計
    - getTodayOpeningHours 方法：這個方法將每個店鋪的今日營業時間計算集中在 StoreManager 中，這樣可以減少重複邏輯，也便於管理營業時間的顯示邏輯。
    - 使用 Locale 來設定地區：DateFormatter 的地區設置為 "zh_TW"，確保顯示的星期幾與台灣本地文化匹配。

 4. 使用情境
    - 當應用需要顯示店鋪資訊時，StoreSelectionViewController 可以通過 StoreManager.shared 來呼叫 fetchStores()，非同步地獲取所有店鋪資訊。
    - 使用 getTodayOpeningHours(for:) 方法來取得店鋪的營業時間，這樣在顯示地圖標註資訊時可以同步顯示店鋪的當日營業時間。
 */

// MARK: - 設置「與門市的距離」功能

import Foundation
import Firebase
import CoreLocation

/// 用於處理與店鋪相關的資料操作
class StoreManager {
    
    static let shared = StoreManager()
    
    // MARK: - Fetch Stores

    /// 從 Firestore 中獲取所有店鋪資料
    /// - Returns: 返回包含所有店鋪的陣列
    func fetchStores() async throws -> [Store] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("stores").getDocuments()
        
        var stores: [Store] = []
        for document in snapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String,
               let location = data["location"] as? GeoPoint,
               let address = data["address"] as? String,
               let phoneNumber = data["phoneNumber"] as? String,
               let openingHours = data["openingHours"] as? [String: String]{
                
                let store = Store(id: document.documentID, name: name, location: location, address: address, phoneNumber: phoneNumber, openingHours: openingHours)
                stores.append(store)
            }
        }
        return stores
    }
    
    // MARK: - Helper Methods
    
    /// 根據當前日期返回所有店鋪的今日營業時間
    /// - Parameter stores: 包含所有店鋪的陣列
    /// - Returns: 每個店鋪 ID 與其對應今日營業時間的字典
    func getTodayOpeningHours(for stores: [Store]) -> [String: String] {
        var todayOpeningHoursDict: [String: String] = [:]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")  // 設定地區
        formatter.dateFormat = "EEEE"                   // 取得今天是星期幾

        let today = formatter.string(from: Date())

        for store in stores {
            if let todayHours = store.openingHours[today] {
                todayOpeningHoursDict[store.id] = todayHours
            } else {
                todayOpeningHoursDict[store.id] = "營業時間未提供"
            }
        }
        
        return todayOpeningHoursDict
    }

}


/*
/// 根據用戶的當前位置來篩選最近的店家
func getNearestStores(to location: CLLocation, from stores: [Store], maxDistance: Double) -> [Store] {
    return stores.filter { store in
        let storeLocation = CLLocation(latitude: store.latitude, longitude: store.longitude)
        return storeLocation.distance(from: location) <= maxDistance
    }
}
*/


// MARK: - 距離（想法）

/*
 可以考慮加入「店家距離使用者幾公尺」
 */
