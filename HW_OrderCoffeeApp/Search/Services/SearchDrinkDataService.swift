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
 - 提供類別、子類別以及飲品詳細資料的加載功能，以支援搜尋和瀏覽功能。
 
 `* 屬性與責任分配`
 
 - `db`：Firebase Firestore 的資料庫實例，提供存取 Firebase 的能力。
 - `loadCategories()`：加載所有類別 (Categories)，供飲品分類的展示或搜尋使用。
 - `loadSubcategories(for categoryId:)`：根據指定類別 ID 加載該類別下的子類別，用於精細化篩選。
 - `loadDrinks(for categoryId:, subcategoryId:)`：加載指定類別及子類別下的所有飲品資料，並轉換為 SearchResult 物件。
 
 `* 分離責任的實踐`

 - `SearchDrinkDataService` 僅負責與 Firebase 互動並處理飲品相關的數據。這樣的責任分離設計使數據加載邏輯獨立於其他業務邏輯，提升代碼的可維護性和模組化程度。
 
 `* 錯誤處理機制`

 - 每個資料加載方法都會拋出錯誤 (throws)，這樣可以讓上層控制器處理不同情況的錯誤，例如網路連接問題或者 Firebase 資料庫錯誤。
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
    /// - Returns: 包含類別 (Categories) 資料的 `QuerySnapshot`
    /// - Throws: 當加載資料時遇到錯誤會拋出錯誤
    func loadCategories() async throws -> QuerySnapshot {
        return try await db.collection("Categories").getDocuments()
    }

    /// 加載指定類別 (`Category`) 下的所有子類別 (Subcategories)
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
