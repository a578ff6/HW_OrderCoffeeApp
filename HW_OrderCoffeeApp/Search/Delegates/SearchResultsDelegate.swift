//
//  SearchResultsDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//


// MARK: - `SearchResultsDelegate` 的設置重點筆記
/**
 
## `SearchResultsDelegate` 的設置重點筆記

`1. 主要目的`
 
    - `SearchResultsDelegate` 協議，用於定義 `SearchHandler` 與 `SearchViewController` 之間的溝通接口。
    - 它的主要作用是讓 `SearchHandler` 能夠使用 `SearchViewController` 的資料和操作，特別是處理搜尋結果的顯示和用戶互動。

 ----
 
`2. 職責分離`
 
    - `SearchHandler` 負責 `UITableView` 的數據管理及用戶互動。
    - `SearchViewController` 負責搜索和顯示，並持有搜索結果的資料。
    - `SearchResultsDelegate` 讓 `SearchHandler` 可以從 `SearchViewController` 獲取搜尋結果 (`getSearchResults()`) 並處理用戶操作 (`didSelectSearchResult`)，以達成職責分離，保持代碼的模組化和清晰性。

 ----

`3. 成員方法說明`
 
    - `getSearchResults() -> [SearchResult]`
 
      - `SearchHandler` 通過此方法獲取目前的搜尋結果，以便展示於 `UITableView`。
      - 確保資料只由 `SearchViewController` 管理，避免 `SearchHandler` 直接持有資料。
      
    - `didSelectSearchResult(_ result: SearchResult)`
 
      - 當使用者選擇某個搜尋結果時觸發。
      - 通知 `SearchViewController` 對應的操作，如導航至飲品的詳細頁面或顯示相關資訊。

 ----

`4. 總結`
 
    - 資料管理：`SearchViewController` 持有資料，`SearchHandler` 負責展示，通過委託接口 (`SearchResultsDelegate`) 進行協同。
    - 交互清晰：當資料或選擇改變時，使用委託方法通知，確保資料與 UI 互動的一致性。
    - 職責明確：各模組職責劃分明確，利於維護和擴展。
 */


import UIKit

/// `SearchResultsDelegate` 協議，用於處理搜尋結果和使用者的選擇行為。
///
/// - 主要負責 `SearchHandler` 與 `SearchViewController` 之間的溝通與資料交換。
/// - `SearchHandler` 使用此協議來獲取顯示資料和處理使用者交互。
protocol SearchResultsDelegate: AnyObject {
    
    /// 返回目前的搜尋結果
    ///
    /// - 說明：提供目前的搜尋結果，以便 `SearchHandler` 能夠用來配置 `tableView` 中的每個 Cell。
    /// - 返回：`[SearchResult]` 型別的陣列，包含當前的搜尋結果。
    func getSearchResults() -> [SearchResult]
    
    /// 當使用者選擇搜尋結果時觸發
    ///
    /// - 說明：當使用者點選某個搜尋結果時，會通知 `SearchViewController`，以便進一步處理（例如導航至詳細頁面）。
    /// - 參數 result：被選擇的 `SearchResult`，表示使用者選中的飲品資訊。
    func didSelectSearchResult(_ result: SearchResult)
    
}
