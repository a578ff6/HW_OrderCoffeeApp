//
//  SearchDrinkDataLoader.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/22.
//

// MARK: - SearchDrinkDataLoader 筆記
/**
 
 ## SearchDrinkDataLoader 筆記
 
 `* 設計目的`
 
 - `SearchDrinkDataLoader` 的目的是從 Firebase 加載最新的飲品資料並更新快取，確保資料在應用啟動時和快取無效時可用，避免應用啟動後使用搜尋功能時因資料缺失而影響使用體驗。
 - 透過應用啟動時的加載，提升應用的資料使用效能，減少搜尋功能中需要重複加載遠端資料的情況，減少不必要的網路請求。
 - 以及「搜尋」時「飲品資料」無效時，提供加載的功能。
 
 --------------------------------------------
 
 `* 屬性與責任分配`
 
 - `searchDrinkDataService`：負責與 Firebase 進行交互，從 Firebase 中獲取所需飲品資料。
 - `searchCacheManager`：負責快取和管理飲品資料，避免頻繁的遠端資料請求。
 - `shared`：單例模式，用於確保應用中只存在一個 `SearchDrinkDataLoader` 的實例，這樣可以更方便地管理資料預加載過程。
 
 --------------------------------------------

 `* 方法說明`
 
 - `loadOrRefreshDrinksData()`
    - 負責從 Firebase 加載所有飲品資料並將其存入快取。
 
 - 使用情境：
    - 在應用啟動時確保快取中存在最新資料，避免首次搜尋時資料缺失。
    - 當搜尋過程中發現「飲品資料無效」時，提示使用者選擇是否重新加載資料。
 
 - 流程：
    1.調用 `loadAllDrinksFromFirebase() `方法，從 Firebase 加載飲品資料。
    2.使用 `searchCacheManager.cacheDrinks(_:) `方法將加載的飲品資料存入快取。
    3 這個方法確保飲品資料是最新的，以避免首次搜尋操作時因資料缺失而導致的延遲或錯誤。

 
 - `loadAllDrinksFromFirebase()
    - 負責從 Firebase 加載所有飲品資料，包括所有類別和子類別中的飲品。
    - 加載的飲品資料會在後續存入快取，供本地快速查詢。
 
 - `loadDrinksForSubcategories()`
    - 用於從 Firebase 中加載每個子類別下的飲品資料，並返回包含所有飲品的陣列。
 
 --------------------------------------------

 `* 設計考量`
 
 - `提升資料加載效能`：
    - 通過應用啟動時的預加載，確保使用者在進行搜尋時能即時獲取資料，減少等待時間，提升使用體驗。
 
 - `簡化職責分工`：
    - 預加載資料的職責僅由 `SearchDrinkDataLoader` 處理，而不依賴於其他情境的使用，這樣避免了職責模糊，讓 `SearchDrinkDataLoader` 的職能更加專注。
 
 --------------------------------------------

 `* 補充說明`
 
 - `SearchDrinkDataLoader` 負責資料的預加載，而非進行搜尋操作。
 - 預加載的資料由 `SearchCacheManager` 進行管理，`SearchManager` 再從 `SearchCacheManager` 中獲取資料以進行搜尋操作。
 
 --------------------------------------------

 `* 職責劃分`
 
 - `SearchDrinkDataLoader`：負責從遠端加載資料。
 - `SearchCacheManager`：負責管理資料快取及其有效性。
 - `SearchManager`：負責提供搜尋功能，根據快取資料進行搜尋。
 
 --------------------------------------------

 `* Firebase 加載資料的流程`

 - `loadAllDrinksFromFirebase()`
    -  加載所有飲品資料的主方法，負責遍歷 Firebase 中所有類別 (`Categories`) 並從每個子類別 (`Subcategories`) 中逐層加載飲品資料 (`Drinks`)。
    -  該方法依賴於 `searchDrinkDataService` 來進行資料加載，以便將資料存取的細節與業務邏輯分離。
 
 - `loadDrinksForSubcategories()`
    - 作為 `loadAllDrinksFromFirebase()`的輔助方法，專門用於從指定的子類別中加載所有飲品資料。
    - 它的職責是更細緻地處理每個子類別的飲品資料加載，從而與主加載流程 (`loadAllDrinksFromFirebase()`) 形成層層遞進的結構。
 
 --------------------------------------------

 `* 層級關係和責任分離`
 
 - `loadAllDrinksFromFirebase()` 是整個資料加載的入口，負責管理所有類別和子類別的遍歷。
 - `loadDrinksForSubcategories() `則是對某一類別下所有子類別中的飲品資料進行加載，形成了層層深入的資料加載結構。
 */



import UIKit
import Firebase

/// `SearchDrinkDataLoader` 負責從 Firebase 加載飲品資料並存入快取，以確保資料在應用啟動時以及資料無效時進行更新，提升使用者搜尋體驗。
///
/// 其目的是提升搜尋和加載飲品資料的效能，減少頻繁的遠端請求。
class SearchDrinkDataLoader {
    
    // MARK: - Properties
    
    /// 飲品資料服務，用於從 Firebase 加載飲品相關的資料
    private let searchDrinkDataService = SearchDrinkDataService()
    
    /// 搜尋快取管理器，用於快取飲品資料，減少 Firebase 請求次數
    private let searchCacheManager = SearchCacheManager.shared
    
    /// 單例模式，`SearchDrinkDataLoader` 實例
    static let shared = SearchDrinkDataLoader()

    // MARK: - Initializer

    /// 私有化初始化方法，防止外部實例化
    private init() {}
    
    // MARK: - Public Methods
    
    /// 加載或更新飲品資料並存入快取
    ///
    /// - 使用情境：
    ///   1. 在應用啟動時進行調用，確保快取中存在最新的飲品資料，避免搜尋時資料缺失。
    ///   2. 當搜尋過程中發現「飲品資料無效」時，會提示使用者是否需要重新加載資料。
    /// - 這個方法旨在提升應用的效能，減少頻繁的遠端請求並提高使用者體驗。
    func loadOrRefreshDrinksData() async throws {
        print("開始加載飲品資料...")
        let drinks = try await loadAllDrinksFromFirebase()
        searchCacheManager.cacheDrinks(drinks)
        print("已從 Firebase 加載所有飲品資料並存入快取，共 \(drinks.count) 筆資料")
    }
    
    // MARK: - Private Methods

    /// 從 Firebase 加載所有飲品資料
    ///
    /// - Returns: 所有飲品的 `SearchResult` 陣列
    private func loadAllDrinksFromFirebase() async throws -> [SearchResult] {
        var allDrinks: [SearchResult] = []
        
        // 加載所有 Categories 並遍歷每個 Category
        let categoriesSnapshot = try await searchDrinkDataService.loadCategories()
        for categoryDocument in categoriesSnapshot.documents {
            let categoryId = categoryDocument.documentID
            let subcategoriesSnapshot = try await searchDrinkDataService.loadSubcategories(for: categoryId)
            let drinksForSubcategories = try await loadDrinksForSubcategories(subcategoriesSnapshot, categoryId: categoryId)
            allDrinks.append(contentsOf: drinksForSubcategories)
        }
        
        return allDrinks
    }
    
    /// 加載所有子類別下的飲品並返回 `SearchResult` 陣列
    /// 
    /// - Parameters:
    ///   - subcategoriesSnapshot: 子類別 (Subcategories) 的 `QuerySnapshot`
    ///   - categoryId: 類別的 ID
    /// - Returns: 飲品資料的 `[SearchResult]` 陣列
    private func loadDrinksForSubcategories(_ subcategoriesSnapshot: QuerySnapshot, categoryId: String) async throws -> [SearchResult] {
        var allDrinks: [SearchResult] = []
        for subcategoryDocument in subcategoriesSnapshot.documents {
            let subcategoryId = subcategoryDocument.documentID
            let drinks = try await searchDrinkDataService.loadDrinks(for: categoryId, subcategoryId: subcategoryId)
            allDrinks.append(contentsOf: drinks)
        }
        return allDrinks
    }
    
}
