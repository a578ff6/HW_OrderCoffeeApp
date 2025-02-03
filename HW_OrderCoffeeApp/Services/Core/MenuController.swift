//
//  MenuController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/1.
//


// MARK: - 「統一使用異步處理方式」與「根據情境選擇」的比較：（主要是針對目前專案重構部分去考量）
/**
 
 ## 「統一使用異步處理方式」與「根據情境選擇」的比較：（主要是針對目前專案重構部分去考量）
 
 & 統一使用同一種異步處理方式的好處：
     
    1. 一致性和可維護性： 使用統一的處理方式（如全部使用 async/await 或 DispatchQueue），可以讓代碼結構保持一致，便於開發者理解和維護。
    2. 降低學習成本： 團隊只需熟悉一種處理方式，減少學習和使用的複雜度。
    3. 減少錯誤： 混用多種異步處理方式容易導致錯誤，例如閉包處理時的強引用問題或混合使用 async/await 和 DispatchQueue 時的過度嵌套。

 -----
 
 & 根據情境選擇異步處理方式的優勢：

 1. async/await 更適合複雜數據流： 當處理需要多步驟的數據查詢、數據加載，async/await 提供了更高的可讀性和簡潔性。

    - 適用情境： 例如菜單數據讀取，涉及到多次數據查詢，彼此依賴，async/await 更加適合。

 ---
 
 2. DispatchQueue 適合即時響應操作： 如果是即時響應的操作，或需要簡單的異步切換執行緒來處理計算或 UI 更新，DispatchQueue 是更輕量且有效的選擇。

    - 適用情境： 像使用者的註冊、登入操作，通常只需短暫的網路請求，用 DispatchQueue 處理已足夠。

 ---

 3. 並行處理需求不同： 某些操作需要依序進行，async/await 讓邏輯更簡潔；而某些情況需要並行處理多個任務，像上傳多個文件，這時候 DispatchQueue 或 OperationQueue 可能更合適。

 ---

 4. 過渡期專案： 如果專案中已有大量使用 DispatchQueue 的代碼，為了降低重構風險，可以在新功能中逐步引入 async/await。

 -----

 & 範例情境：
     
    1. 使用者註冊、登入、大頭照上傳： 這些操作通常只需一次網絡請求，閉包或 DispatchQueue 已足夠。
    2. 菜單數據讀取： 涉及多個依賴數據查詢，async/await 能讓代碼邏輯更加清晰。

 -----

 & 結論：
     
    1. 統一使用異步處理方式： 適合需要一致性與可維護性的專案，尤其是團隊協作中，統一方式能避免潛在錯誤。
    2. 根據情境選擇： 當操作需求不同，選擇最合適的異步處理方式能提高代碼靈活性和可讀性。
 */


// MARK: - 使用 async/await 的優缺點與適用場景
/**
 
 ## 使用 async/await 的優缺點與適用場景
 
 
 `& 何時應該使用 async/await`

 1. 異步數據處理： 當處理像 Firebase 查詢這類需要等待結果的異步數據操作時，async/await 讓代碼更直觀、簡潔。避免了回調地獄（callback hell），使異步操作像同步代碼一樣順暢。
    
    - 適用情境： 從 Firebase 或 API 加載數據並更新 UI 時，async/await 讓數據流更清晰。

 ---
 
 2. 多個異步操作的連續處理： 當多個異步操作有依賴關係且需要依次進行時，async/await 可以讓代碼邏輯更加清楚，避免多重回調嵌套。
        
    - 適用情境： 例如先加載子類別資料，再加載對應的飲品資料，這種連續執行的異步操作適合使用 async/await。

 -----

 `& 何時不一定需要使用 async/await`

 1. 簡單的異步操作： 如果異步處理較簡單，且不需要多步驟，傳統的閉包或 DispatchQueue 已經夠用。
     
    - 適用情境： 一次性下載圖片、簡單的按鈕回應等，使用閉包可能比 async/await 更簡潔。

 ---

 2. 一些即時回應操作如動畫回調或按鈕點擊事件，用閉包會更靈活。
       
    - 適用情境： 例如動畫完成後的狀態更新，這類操作不需要等待結果。

 ---

 3. 即時回應的小型閉包處理： 一些即時回應操作如動畫回調或按鈕點擊事件，用閉包會更靈活。

    - 適用情境： 例如動畫完成後的狀態更新，這類操作不需要等待結果。

 -----

 `& 其他注意事項`

 - async/await 改善可讀性，但不一定提升性能： 它主要優化異步程式碼結構，而不是直接改善數據處理性能。如果數據查詢本身較慢，還是需要進行性能優化。
 - 並發處理要小心： 在同時執行大量任務時，要適當使用並行控制，如 TaskGroup，避免資源衝突。

 -----

 `& 總結`
     
 - 適合使用 async/await 的情境： 異步數據處理、多個步驟有依賴的操作。
 - 不一定要使用 async/await 的情境： 簡單回調、閉包能解決的小型異步操作。
 - 選擇依據： 根據具體情境和需求來決定。
 */


// MARK: - MenuController 筆記
/**
 
 ### MenuController 筆記

 - 跟 `MenuModels.swift` 一樣，當初也是直接採用`MenuController`，但畢竟飲品是鉗套結構，再加上，會有多個視圖控制器去採用到`MenuController`，導致`MenuController`職責模糊。
 - 所以才另外針對各個視圖控制器設置專屬的`Manager`來處理其各自的請求，已達到單一原則。
 
 ----
 
 `* What：`
 
 - `MenuController` 是應用程式的 **數據存取層 (Data Layer)**，負責從 **Firestore** 加載飲品菜單相關的數據，包括：
 
    - 菜單分類 (`Category`)
    - 子分類 (`Subcategory`)
    - 飲品 (`Drink`)

 - 它的主要職責是**提供標準化的 Firestore 讀取接口**，確保其他類別可以獲取結構化數據，而不直接與 Firebase 交互。

 --------

 `* Why：`
 
 1. 解耦 Firebase API 與 UI 層
 
    - `MenuController` **封裝 Firestore 操作**，讓視圖層 (`ViewController`) **不直接與 Firebase 交互**，減少 Firebase 依賴。

 2. 單一職責 (SRP)
 
    - `MenuController` **只負責數據存取**，**不負責 UI 處理** 或 **數據轉換**，這些由 `Manager` 層處理，讓架構更清晰。

 3. 提高可維護性
 
    - **未來如果 Firebase API 變動**，只需修改 `MenuController`，而不影響 UI 層，確保**低耦合、高內聚**。

 4. 非同步數據處理
 
    - 使用 `async/await` 確保數據讀取**不會阻塞 UI**，提升應用流暢度。

 --------

 `* How：`
 
 1. 單一職責 (SRP)：
 
    - 只處理 Firestore 資料存取，不負責數據轉換或 UI 處理。

 2. 依賴倒置 (DIP)：
 
    - `MenuController` 為 **低層數據存取類別**，`Manager` 層（如 `DrinkDetailManager`）依賴它，而 `ViewController` 只與 `Manager` 交互，避免與 Firebase 直接耦合。

 3. 高內聚、低耦合：
 
    - `MenuController` 只專注 Firestore，數據轉換由 `Manager` 負責，UI 層只需關心 `ViewModel`，確保職責分明。

 --------

 `* MenuController 主要功能`
 
 - `loadCategories()`
 
   - 功能：讀取 Firestore 中所有 `Category`，回傳菜單分類數據。
   - 適用對象：`MenuDrinkCategoryManager`
   
 - `loadSubcategoriesWithDrinks()`
 
   - 功能：讀取 `Category` 下所有 `Subcategory` 及其 `Drink` 資料。
   - 適用對象：`DrinkSubCategoryManager`

 - `loadDrinkById()`
 
   - 功能：讀取特定 `Drink` 詳細資訊。
   - 適用對象：`DrinkDetailManager`

 --------
 
 `* 運作流程`
 
    1. `Manager` 層發送請求，例如 `DrinkDetailManager.fetchDrinkDetail()`
    2. `MenuController` 查詢 Firestore，並回傳 **基礎模型 (`Drink`)**
    3. `Manager` 層將 `Drink` 轉換為 **ViewModel (`DrinkDetailModel`)**
    4. `ViewController` 使用 `ViewModel` 更新 UI，完全**不依賴 Firebase API**

 --------

 `* 結論`
 
    1. `MenuController` 是數據存取層，負責 Firestore 資料讀取，不進行數據轉換
    2. UI 層 (ViewController) 不直接調用 `MenuController`，而是透過 `Manager` 獲取數據
    3. 確保應用架構符合 SRP、DIP，提高維護性與可擴展性
 
 */




// MARK: - (v)

import UIKit
import Firebase


/// `MenuController` 是一個資料層（Data Layer）單例，負責從 Firestore 加載菜單相關數據。
///
/// ### 設計目的
/// - 負責數據存取：處理與 Firestore 互動的所有請求，包括讀取類別、子類別和飲品數據。
/// - 提供標準化的數據接口：確保其他管理類別（如 `DrinkSubCategoryManager`）獲取一致的數據格式。
/// - 減少視圖層的資料處理負擔：讓 `ViewModel` 或 `Manager` 層負責數據轉換，而 `MenuController` 專注於 Firebase 讀取。
///
/// ### 職責
/// - 提供 `加載` 和 `查詢` 菜單分類 (`Category`)、子類別 (`Subcategory`)、飲品 (`Drink`) 的方法。
/// - 確保所有 Firestore 讀取操作為 **非同步 (async/await)**，避免 UI 卡頓。
/// - `不負責數據轉換`，僅負責從 Firestore 讀取並回傳基礎模型 (`MenuModels.swift` 中的 `Category`、`Subcategory`、`Drink` 等)。
///
/// ### 使用場景
/// - 由 `MenuDrinkCategoryManager` 來調用 `loadCategories()` 加載菜單分類資訊。
/// - 由 `DrinkSubCategoryManager` 調用 `loadSubcategoriesWithDrinks()` 來獲取特定類別的子類別與飲品。
/// - 由 `DrinkDetailManager` 調用 `loadDrinkById()` 來獲取特定飲品的詳細資訊。
///
/// ### 設計原則
/// - 單一職責 (SRP)：`MenuController` 只負責 **數據存取**，不進行數據轉換或 UI 處理。
/// - 高內聚低耦合：
///   - `MenuDrinkCategoryManager`：處理 **菜單分類** 業務邏輯。
///   - `DrinkSubCategoryManager`：處理 **飲品子類別** 相關數據管理。
///   - `DrinkDetailManager`：處理 **飲品詳細資訊** 的數據管理。
/// - 依賴倒置原則 (DIP)：
///   - 視圖層 (ViewController) **不直接與 Firebase 交互**，而是透過 `Manager` 類別獲取所需數據，降低對 `MenuController` 的依賴。
class MenuController {
    
    // MARK: - Share
    
    /// 使用 `shared` 單例模式，統一管理 Firestore 的菜單數據存取
    static let shared = MenuController()
    
    /// 防止外部初始化，強制單例模式
    private init() {}
    
    // MARK: - Public Methods
    
    /// 讀取 Firestore 中所有的 `Category` 資料（菜單分類）。
    ///
    /// - Returns: `Category` 陣列，代表不同的飲品大類（如咖啡、茶類等）。
    /// - Throws: 若未找到類別數據，則拋出錯誤 `MenuControllerError.categoriesNotFound`。
    func loadCategories() async throws -> [Category] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("Categories").getDocuments()
        
        let categories = snapshot.documents.compactMap { try? $0.data(as: Category.self) }
        
        guard !categories.isEmpty else {
            throw MenuControllerError.categoriesNotFound
        }
        return categories
    }
    
    /// 讀取特定 `Category` 之下的 `Subcategory` 及其 `Drinks` 資料。
    ///
    /// - Parameter categoryId: `Category` 的 ID（如 "CoffeeBeverages"）。
    /// - Returns: `SubcategoryDrinks` 陣列，包含子類別及其對應的飲品列表。
    /// - Throws: 若找不到數據，則拋出錯誤 `MenuControllerError.menuItemsNotFound`。
    func loadSubcategoriesWithDrinks(forCategoryId categoryId: String) async throws -> [SubcategoryDrinks] {
        let subcategories = try await loadSubcategories(for: categoryId)                          // 先異步加載所有子類別
        return try await loadDrinks(for: subcategories, categoryId: categoryId)                   // 再根據子類別加載對應的飲品資料
    }
    
    /// 讀取特定飲品的詳細資訊。
    ///
    /// - Parameters:
    ///   - categoryId: 飲品所屬 `Category` 的 ID。
    ///   - subcategoryId: 飲品所屬 `Subcategory` 的 ID。
    ///   - drinkId: 飲品的唯一 ID。
    /// - Returns: `Drink` 物件，包含飲品詳細資訊。
    /// - Throws: 若找不到飲品，則拋出錯誤 `MenuControllerError.menuItemsNotFound`。
    func loadDrinkById(categoryId: String, subcategoryId: String, drinkId: String) async throws -> Drink {
        let db = Firestore.firestore()
        let document = try await db.collection("Categories").document(categoryId)
            .collection("Subcategories").document(subcategoryId)
            .collection("Drinks").document(drinkId).getDocument()
        
        guard let drink = try? document.data(as: Drink.self) else {
            throw MenuControllerError.menuItemsNotFound
        }
        return drink
    }
    
    
    // MARK: - Private Methods
    
    /// 讀取 `Category` 下的所有 `Subcategory`。
    ///
    /// - Parameter categoryId: 類別的 ID
    /// - Returns: 一個包含子類別資料的陣列 [Subcategory]
    /// - Throws: 如果資料為空或加載失敗，會拋出錯誤
    private func loadSubcategories(for categoryId: String) async throws -> [Subcategory] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("Categories").document(categoryId).collection("Subcategories").getDocuments()
        
        let subcategories = snapshot.documents.compactMap { try? $0.data(as: Subcategory.self) }
        
        guard !subcategories.isEmpty else {
            throw MenuControllerError.menuItemsNotFound
        }
        
        return subcategories
    }
    
    
    /// 讀取 `Subcategory` 下的所有 `Drink`，並封裝為 `SubcategoryDrinks`。
    ///
    /// - Parameters:
    ///   - subcategories: 子類別資料的陣列
    ///   - categoryId: 對應類別的 ID
    /// - Returns: 一個包含每個子類別及其對應飲品資料的陣列 [SubcategoryDrinks]
    /// - Throws: 如果資料為空或加載失敗，會拋出錯誤
    private func loadDrinks(for subcategories: [Subcategory], categoryId: String) async throws -> [SubcategoryDrinks] {
        let db = Firestore.firestore()
        var subcategoryDrinksList: [SubcategoryDrinks] = []
        
        for subcategory in subcategories {
            let snapshot = try await db.collection("Categories").document(categoryId).collection("Subcategories").document(subcategory.id ?? "").collection("Drinks").getDocuments()
            
            let drinks = snapshot.documents.compactMap { try? $0.data(as: Drink.self) }
            subcategoryDrinksList.append(SubcategoryDrinks(subcategory: subcategory, drinks: drinks))
        }
        
        guard !subcategoryDrinksList.isEmpty else {
            throw MenuControllerError.menuItemsNotFound
        }
        
        return subcategoryDrinksList
    }
}


// MARK: - Error

/// `MenuControllerError` 用於處理 Firestore 加載錯誤。
enum MenuControllerError: Error, LocalizedError {
    case categoriesNotFound
    case menuItemsNotFound
    case unknownError
    case firebaseError(Error)
    
    /// 轉換 Firebase 原始錯誤為 `MenuControllerError`
    static func from(_ error: Error) -> MenuControllerError {
        return .firebaseError(error)
    }
    
    /// 錯誤描述（支援 `NSLocalizedString` 以利於本地化）
    var errorDescription: String? {
        switch self {
        case .categoriesNotFound:
            return NSLocalizedString("Categories not found", comment: "Categories Not Found")
        case .menuItemsNotFound:
            return NSLocalizedString("Menu items not found", comment: "Menu items not found")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "Unknown Error")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}
