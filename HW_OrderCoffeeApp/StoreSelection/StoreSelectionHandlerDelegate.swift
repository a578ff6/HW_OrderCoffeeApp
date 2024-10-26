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
    
}
