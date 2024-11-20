//
//  SearchCacheManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/20.
//

// MARK: -  CacheManager 筆記

/**
 
 ## CacheManager 筆記
 
 `* 設計目的`

 - CacheManager 是負責管理本地飲品資料快取的類別。目的是減少 Firebase 的請求次數，從而提升 App 的效能。
 
 `* 屬性與責任分配`

 - `cachedDrinks`：存放從 Firebase 加載的飲品資料快取，用於減少頻繁的網路請求。
 - `lastFetchTime`：記錄最後一次成功加載飲品資料的時間，以判斷快取資料是否過期。
 - `cacheValidityDuration`：設定快取資料的有效期間，這裡為 1 小時。
 
 `* 方法說明`

 `* getCachedDrinks()：`
    - 根據最後一次加載時間，判斷快取資料是否仍然有效。
    - 如果有效，回傳快取的飲品資料；如果無效，回傳 nil，讓上層決定是否需要重新加載。
 
 `* cacheDrinks(_:)：`
    - 將最新的飲品資料存入快取，並更新 lastFetchTime 為當前時間。
 
 `* shouldReloadData()：`
    - 判斷是否需要重新加載飲品資料。當快取資料不存在或快取已過期時，回傳 true，表示需要重新加載。
 
 `* 設計考量`

 - 快取效能：透過在本地快取飲品資料，減少頻繁的 Firebase 請求，提升使用者體驗，特別是在網路連線不穩定的情況下。
 - 快取有效期間的設計：1 小時的有效期是一個折衷方案，既能保持資料更新，又不會太頻繁地進行請求。可以根據業務需求進行調整。
 */

import UIKit

/// `SearchCacheManager` 負責管理本地搜尋飲品資料快取的類別
class SearchCacheManager {
    
    // MARK: - Properties

    /// 本地快取，用於存儲飲品資料，減少 Firebase 請求次數
    private var cachedDrinks: [SearchResult]?
    /// 最後一次加載資料的時間
    private var lastFetchTime: Date?
    /// 資料快取有效期， 1 小時
    private let cacheValidityDuration: TimeInterval = 60 * 60
    
    // MARK: - Public Methods
    
    /// 取得本地快取的飲品資料
    /// - Returns: 如果快取仍在有效期內，回傳 `[SearchResult]`；否則回傳 `nil`
    func getCachedDrinks() -> [SearchResult]? {
        if let lastFetchTime = lastFetchTime {
            let timeSinceLastFetch = Date().timeIntervalSince(lastFetchTime)
            if timeSinceLastFetch < cacheValidityDuration {
                return cachedDrinks
            }
        }
        return nil
    }
    
    /// 將飲品資料存入快取
    /// - Parameter drinks: 要快取的飲品資料
    func cacheDrinks(_ drinks: [SearchResult]) {
        cachedDrinks = drinks
        lastFetchTime = Date()
    }
    
    /// 判斷是否需要重新加載飲品資料
    /// - Returns: 如果需要重新加載資料，回傳 `true`；否則回傳 `false`
    func shouldReloadData() -> Bool {
        return cachedDrinks == nil || (lastFetchTime == nil) || Date().timeIntervalSince(lastFetchTime!) >= cacheValidityDuration
    }
    
}
