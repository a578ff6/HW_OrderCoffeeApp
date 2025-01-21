//
//  SearchDrinkDataService.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/20.
//

// MARK: - SearchDrinkDataService 筆記
/**

 ## SearchDrinkDataService 筆記
 
 `* 設計目的`

 - SearchDrinkDataService 是專門負責從 Firebase Firestore 加載與飲品相關資料的服務類別。
 - 提供類別、子類別以及飲品詳細資料的加載功能，以支援資料的預加載、搜尋及展示功能。
 - 通過將 Firebase 的交互操作集中在此類別中，讓資料加載邏輯與其他業務邏輯解耦合，提高了代碼的可讀性和可維護性。
 
 --------
 
 `* 屬性與責任分配`
 
 - `db`：Firebase Firestore 的資料庫實例，提供存取 Firebase 的能力。
 - `loadCategories()`：加載所有類別 (Categories)，供`飲品分類的展示`或`資料的初始化使用`。
 - `loadSubcategories(for categoryId:)`：根據指定類別 ID 加載該類別下的子類別，用於精細化篩選與展示。
 - `loadDrinks(for categoryId:, subcategoryId:)`：加載指定類別及子類別下的所有飲品資料，並轉換為 SearchResult 物件用於搜尋和展示飲品詳細資訊。
 
 --------

 `* 分離責任的實踐`

 - `SearchDrinkDataService`
 
    - 僅負責與 Firebase Firestore 進行資料的存取，專注於加載飲品相關資料。
    - 這樣的設計使得資料加載邏輯與應用的其他部分（如快取管理和搜尋邏輯）保持獨立，確保代碼更加模組化和易於維護。
 
 --------

 `* 錯誤處理機制`
 
 - 每個資料加載方法都會拋出錯誤 (throws)，這樣可以讓上層控制器或處理器（如 SearchDrinkDataLoader 或 SearchManager）處理不同情況的錯誤，例如網路連接問題或 Firebase 資料庫讀取錯誤。
 - 錯誤處理的分層設計使得上層可以根據具體情況進行適當的 UI 提示或重新嘗試加載，提供更好的用戶體驗。
 
 --------

 `* 設計考量`
 
 - `專注資料加載`：
 
    - `SearchDrinkDataService` 的唯一責任是從 Firebase 獲取資料，這樣可以減少 `SearchDrinkDataLoader` 或 `SearchManager` 對底層 Firebase 操作的依賴，達到責任分離的效果。
 */


import UIKit
import Firebase

/// 負責從 `Firebase Firestore` 加載飲品相關的資料，供搜尋功能使用
class SearchDrinkDataService {
    
    // MARK: - Properties

    /// Firestore 資料庫實例
    private let db = Firestore.firestore()

    // MARK: - Public Methods

    /// 加載所有類別 (`Categories`)
    ///
    /// - Returns: 包含類別 (Categories) 資料的 `QuerySnapshot`
    /// - Throws: 當加載資料時遇到錯誤會拋出錯誤
    func loadCategories() async throws -> QuerySnapshot {
        return try await db.collection("Categories").getDocuments()
    }

    /// 加載指定類別 (`Category`) 下的所有子類別 (Subcategories)
    ///
    /// - Parameter categoryId: 類別的 ID
    /// - Returns: 包含子類別 (Subcategories) 資料的 `QuerySnapshot`
    /// - Throws: 當加載資料時遇到錯誤會拋出錯誤
    func loadSubcategories(for categoryId: String) async throws -> QuerySnapshot {
        return try await db.collection("Categories")
            .document(categoryId)
            .collection("Subcategories")
            .getDocuments()
    }

    /// 加載指定子類別 (`Subcategory`) 下的所有飲品資料
    ///
    /// - Parameters:
    ///   - categoryId: 類別的 ID
    ///   - subcategoryId: 子類別的 ID
    /// - Returns: 飲品資料的 `[SearchResult]` 陣列
    /// - Throws: 當加載資料或轉換資料時遇到錯誤會拋出錯誤
    func loadDrinks(for categoryId: String, subcategoryId: String) async throws -> [SearchResult] {
        let drinksSnapshot = try await db.collection("Categories")
            .document(categoryId)
            .collection("Subcategories")
            .document(subcategoryId)
            .collection("Drinks")
            .getDocuments()

        print("正在處理 Drinks 資料 (Category: \(categoryId), Subcategory: \(subcategoryId))，共 \(drinksSnapshot.documents.count) 筆")

        /// 將每個 `Drink` 轉換為 `SearchResult` 物件
        return drinksSnapshot.documents.compactMap { document in
            do {
                var searchResult = try document.data(as: SearchResult.self)
                searchResult.categoryId = categoryId
                searchResult.subcategoryId = subcategoryId
                searchResult.drinkId = document.documentID
                return searchResult
            } catch {
                print("Error decoding drink document: \(error)")
                return nil
            }
        }
    }
    
}
