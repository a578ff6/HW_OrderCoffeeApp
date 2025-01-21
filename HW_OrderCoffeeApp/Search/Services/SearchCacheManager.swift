//
//  SearchCacheManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/20.
//

// MARK: -  SearchCacheManager 筆記

/**
 
 ## SearchCacheManager 筆記
 
 `* 設計目的`

 - SearchCacheManager 是負責管理本地飲品資料快取的類別。目的是減少 Firebase 的請求次數，從而提升 App 的效能。
 - 這可以大幅提升搜尋飲品資料時的速度，特別是在網路不穩定或頻寬有限的情況下。
 
 --------
 
 `* 屬性與責任分配`

 - `cachedDrinks`：存放從 Firebase 加載的飲品資料快取，用於減少頻繁的網路請求。
 - `lastFetchTime`：記錄最後一次成功加載飲品資料的時間，以判斷快取資料是否過期。
 - `cacheValidityDuration`：設定快取資料的有效期間，這裡為 1 小時。
 
 --------

 `* 方法說明`

 `* getCachedDrinks()：`
    - 根據最後一次加載時間，判斷快取資料是否仍然有效。
    - 如果有效，回傳快取的飲品資料；如果無效，回傳 nil，讓上層決定是否需要重新加載。
 
 `* cacheDrinks(_:)：`
    - 將最新的飲品資料存入快取，並更新 lastFetchTime 為當前時間。
 
 --------

 `* 設計考量`

 - `快取效能`：透過在本地快取飲品資料，減少頻繁的 Firebase 請求，提升使用者體驗，特別是在網路連線不穩定的情況下。
 - `快取有效期間的設計`：1 小時的有效期是一個折衷方案，既能保持資料更新，又不會太頻繁地進行請求。可以根據業務需求進行調整。
 
 --------

 `* SearchCacheManager 和 SearchDrinkDataLoader 的職責`
 
 - `SearchCacheManager`：專注於管理本地快取資料，確保資料的有效性和持久性，並在查詢時提供高效的存取途徑。
 - `SearchDrinkDataLoader`：負責從 Firebase 加載最新資料，並通過 `SearchCacheManager` 進行快取的存儲和更新，確保資料始終保持最新。
 
 --------

 `* 本地快取與無網路狀態下的搜尋`
 
 - 「飲品資料」是透過快取的方式儲存於本地。因此，只要「飲品資料」有成功加載並且在有效期內，即使在無網路的情況下，也能使用這些快取資料進行搜尋操作。
 - 這樣的設計確保了在網路不可用時仍能有基本的搜尋功能，改善使用者體驗。

 */

import UIKit

/// `SearchCacheManager` 負責管理本地飲品資料的快取。
///
/// - 目的是確保在執行搜尋功能時可以有效利用快取的資料，從而減少對 Firebase 的請求次數，並提升應用的效能和反應速度。
/// - 快取有效期可以防止應用過久使用舊資料，確保用戶看到的是最新的飲品資訊。
/// - 尤其在搜尋過程中，可以通過快速存取本地資料來提升使用者體驗，減少資料查詢時間。
class SearchCacheManager {
    
    // MARK: - Properties

    /// 單例模式，提供唯一的 `SearchCacheManager` 實例以供全局使用。
    static let shared = SearchCacheManager()
    
    /// 本地快取，用於存儲從 Firebase 加載的飲品資料，減少重複的請求次數。
    private var cachedDrinks: [SearchResult]?
    
    /// 最後一次加載資料的時間戳，這有助於檢查快取是否過期。
    private var lastFetchTime: Date?
    
    /// 資料快取有效期， 1 小時
    private let cacheValidityDuration: TimeInterval = 60 * 60
    
//    private let cacheValidityDuration: TimeInterval = 1 * 60    // 測試用
    
    // MARK: - Initializer

    /// 私有化初始化方法，防止外部實例化
    private init() {}
    
    // MARK: - Public Methods

    /// 取得本地快取的飲品資料。
    ///
    /// - Returns: `[SearchResult]`：如果快取資料仍在有效期內則返回快取資料；如果已過期或未加載過，則返回 `nil`。
    /// - 說明：此方法用於檢查快取資料是否仍可用，以便在進行搜尋操作時優先使用本地快取資料，而不是重新從 Firebase 加載。
    func getCachedDrinks() -> [SearchResult]? {
        
        /// 檢查是否有上次加載的時間戳。
        /// - 如果 `lastFetchTime` 為 `nil`，說明飲品資料未被加載，因此直接返回 `nil`。
        guard let lastFetchTime = lastFetchTime else {
            return nil
        }
        
        /// 計算距離上次成功加載飲品資料所經過的時間。
        let timeSinceLastFetch = Date().timeIntervalSince(lastFetchTime)
        
        /// 檢查快取資料是否仍在有效期內。
        /// - 如果經過的時間大於 `cacheValidityDuration`，說明快取已經過期，需要重新加載資料，因此返回 `nil`。
        guard timeSinceLastFetch < cacheValidityDuration else {
            return nil
        }
        
        // 若快取資料在有效期內，返回快取的飲品資料。
        return cachedDrinks
    }
    
    /// 將飲品資料存入快取中，並更新快取時間。
    ///
    /// - Parameter drinks: 要存入快取的飲品資料 `[SearchResult]`。
    /// - 說明：此方法用於在成功從 Firebase 加載資料後，將其快取到本地以供未來的搜尋操作快速使用。
    func cacheDrinks(_ drinks: [SearchResult]) {
        cachedDrinks = drinks
        lastFetchTime = Date()
    }
    
}
