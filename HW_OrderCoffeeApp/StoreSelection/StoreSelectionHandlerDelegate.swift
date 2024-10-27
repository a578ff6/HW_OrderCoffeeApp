//
//  StoreSelectionHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/26.
//

/*
 ## StoreSelectionHandlerDelegate 重點筆記
 
 1. 協議用途：
    - StoreSelectionHandlerDelegate 是用來協調 StoreSelectionHandler 和 StoreSelectionViewController 之間的互動。
    - 這個協議提供了必要的接口，讓 StoreSelectionHandler 可以請求店鋪資料、營業時間，並由 StoreSelectionViewController 來顯示相關訊息。

 2. 方法說明
 
    * getStores()：
        - 功能：取得所有店鋪的資料，通常用於在地圖上標註所有店鋪位置。
        - 回傳：返回一個包含所有 Store 的陣列，讓 StoreSelectionHandler 可以透過這些資料進行操作。
 
    * getTodayOpeningHours(for storeId: String)：
        - 功能：根據店鋪的唯一 ID，取得該店鋪的今日營業時間。
        - 參數：storeId，用於標識要查詢的店鋪。
        - 回傳：返回該店鋪的今日營業時間，如果該店鋪沒有營業時間的資料，則返回預設的「營業時間未提供」訊息。
 
    * presentStoreDetailsAlert(for store: Store, todayOpeningHours: String)：
        - 功能：顯示用戶選定店鋪的詳細訊息。
        - 參數：
            store：被選定的店鋪，包含名稱、地址、電話等資料。
            todayOpeningHours：該店鋪今日的營業時間，通常是透過 getTodayOpeningHours 方法取得。
        - 用途：在用戶選擇地圖上的店鋪後，顯示彈窗以呈現該店鋪的相關訊息，讓用戶可以查看店鋪的詳細資訊。
 
 3. 想法：
    - 資料集中管理：所有的店鋪資料與營業時間的管理都集中在 StoreSelectionViewController，而 StoreSelectionHandler 只需要透過代理來請求這些資料。
    - 高靈活性：使用代理讓處理店鋪的展示邏輯變得靈活。如果要修改資料的取得方式或顯示方式，只需修改代理的方法實現，而不需要修改 StoreSelectionHandler 的內部邏輯。
 */

// MARK: - fetchDistanceToStore 方法重點筆記


/*
 ## fetchDistanceToStore 方法重點筆記
 
 1. 方法功能：
    - 該方法的作用是從 storeDistances 字典中，查找並返回特定店鋪與使用者之間的距離。
 
 2. 參數與返回值：

    * 參數：
        - storeId: String：店鋪的唯一標識符，用於查找該店鋪的距離。
 
    * 返回值：
        - 返回該店鋪與使用者之間的距離 (CLLocationDistance)。
        - 如果該店鋪的距離尚未計算，則返回 nil。
 
    * 使用方式：
        - 該方法由 StoreSelectionHandlerDelegate 的代理協議提供，因此可以在代理中使用此方法來獲取特定店鋪的距離，例如在用戶選擇店鋪時顯示該店鋪的詳細資訊時使用。
 
    * 記錄位置：
        - 由於距離的計算依賴於使用者的當前位置，因此需要在獲取使用者位置後，更新 storeDistances 字典。
        - 在 StoreSelectionViewController 中，透過 CLLocationManager 來獲取使用者的位置，並使用 StoreManager.shared.calculateDistances() 方法計算每個店鋪的距離，然後更新 storeDistances。

 
 &. 使用 fetchDistanceToStore 的流程：
 
 1. 位置獲取：
    - StoreSelectionViewController 使用 CLLocationManager 來獲取使用者的當前位置。
    - 當位置更新後，調用 StoreManager.shared.calculateDistances() 來計算每個店鋪的距離，並將結果保存在 storeDistances 中。
 
 2. 距離展示：
    - 當使用者選擇某個店鋪時，透過 fetchDistanceToStore(for:) 方法查找該店鋪與使用者之間的距離。
    - 在店鋪詳細信息的彈窗中展示該距離，增強使用者對店鋪位置的感知。
 */

import Foundation
import CoreLocation

/// 用於協調 StoreSelectionHandler 與 StoreSelectionViewController 的代理協議
protocol StoreSelectionHandlerDelegate: AnyObject {
    
    /// 取得所有的店鋪資料
    /// - Returns: 一個包含所有店鋪 (`Store`) 的陣列
    func getStores() -> [Store]
    
    /// 取得特定店鋪的今日營業時間
    /// - Parameter storeId: 店鋪的唯一標識符
    /// - Returns: 該店鋪今日的營業時間，若無資料則返回預設訊息
    func getTodayOpeningHours(for storeId: String) -> String
    
    /// 顯示選定店鋪的詳細訊息
    /// - Parameters:
    ///   - store: 被選定的店鋪 (`Store`)
    ///   - todayOpeningHours: 該店鋪今日的營業時間
    func presentStoreDetailsAlert(for store: Store, todayOpeningHours: String)
    
    /// 取得特定店鋪的距離（通過 StoreManager）
    /// - Parameter storeId: 店鋪的唯一標識符
    /// - Returns: 與用戶位置之間的距離
    func fetchDistanceToStore(for storeId: String) -> CLLocationDistance?

}
