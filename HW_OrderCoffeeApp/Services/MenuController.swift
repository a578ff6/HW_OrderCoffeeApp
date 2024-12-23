//
//  MenuController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/1.
//

// MARK: - MenuController（async/await重構筆記）
/*
 ## MenuController（重構筆記）
 
    * 功能：
        - 管理從 Firebase Firestore 中加載類別、子類別以及飲品資料的邏輯，並支援異步處理。
 
    * 主要調整點：
        - 使用 async/await 替代傳統的 callback 處理方式。
        - 引入 loadDrinkById 方法，讓使用者可以根據 categoryId、subcategoryId 和 drinkId 精確加載單一飲品的詳細資料。（ 不再依賴於使用 DrinksCategoryViewController 的 loadDrinksForCategory ）
 
 &. 主要方法：

    1. loadCategories
        * 功能：
            - 從 Firestore 中的 Categories 集合異步加載所有類別資料。
        * 特點：
            - 使用 async/await 來簡化異步操作，避免了 callback 的層層嵌套。
            - 若無法加載到任何類別資料，則會拋出 categoriesNotFound 錯誤。

    2. loadDrinksForCategory：
        * 功能：
            - 根據傳入的 categoryId，從 Firestore 中加載該類別下所有子類別及其對應的飲品資料。
        * 特點：
            - 使用 async/await 來分別異步加載子類別及其飲品資料，並將結果組合返回。
            - 若找不到對應資料，則會拋出 menuItemsNotFound 錯誤。
 
    3. loadSubcategories：
        * 功能：
            - 根據 categoryId 從 Firestore 加載對應的子類別資料。
        * 特點：
            - 使用 Firestore 的 getDocuments() 方法來讀取 Subcategories 集合，並將結果轉換為 Subcategory 物件。
            - 若資料為空，則拋出 menuItemsNotFound 錯誤。

    4. loadDrinks：
        * 功能：
            - 根據每個子類別的 ID，從 Firestore 中加載對應的飲品資料。
        * 特點：
            - 使用 for 迴圈遍歷每個子類別，並查詢其 Drinks 子集合中的資料。
            - 將每個子類別與對應的飲品組合為 SubcategoryDrinks，並返回結果。
 
    5. loadDrinkById：
        * 功能：
            - 根據傳入的 categoryId、subcategoryId 和 drinkId，從 Firestore 中精確加載單一飲品的詳細資料。
        * 特點：
            - 透過傳入的 ID 精準查詢，並將結果轉換為 Drink 物件。
            - 若查詢失敗或資料不存在，則拋出 menuItemsNotFound 錯誤。
 
    6.loadSubcategoryById：
        * 功能：
            - 根據傳入的 categoryId 和 subcategoryId，從 Firestore 中加載對應的子類別名稱。
            - 特別用於顯示收藏的飲品，讓 FavoritesViewController 能將子類別名稱作為 section header。
 
        * 特點：
            - 當資料加載成功時，會返回子類別名稱，若查詢失敗或資料不存在，則拋出 menuItemsNotFound 錯誤。

 &. 優勢：
 
    * 簡化異步操作：
        - 使用 async/await 徹底簡化了異步操作，取代了傳統的 completion handler 或 DispatchGroup 處理方式，讓程式碼邏輯更為清晰。
 
    * 錯誤處理更具一致性：
        - 使用 throws 和 MenuControllerError 來統一處理錯誤，讓錯誤的傳遞與處理更加清晰、直觀。

    * 提升程式碼可讀性：
        - async/await 使得程式碼邏輯更加接近同步處理，易於理解和維護。
 
 &. 主要流程：
 
    1. loadCategories： 從 Firestore 加載所有類別資料，並在資料加載失敗時拋出錯誤。
    2. loadDrinksForCategory： 根據指定的 categoryId 加載該類別下的所有子類別及飲品，並將結果組合為 SubcategoryDrinks 陣列。
    3. loadDrinkById： 根據傳入的 categoryId、subcategoryId 和 drinkId 精準加載單一飲品的詳細資料，用於詳細頁面。

 -------------------------------------------------------------------------------------------------------------------------------------------------------------------

 ## 數據流的流程：
 
    1. MenuViewController：
        * 功能：
            - 最頂層的控制器，用來顯示飲品的主要類別（如「CoffeeBeverages」、「Teavana」等）。
        * 操作：
            - 使用 MenuController 的 loadCategories 方法從 Firestore 的 Categories 集合中獲取所有類別資料。
            - 當資料加載完成後，類別資料會顯示在 UICollectionView 中。
            - 當使用者選擇某個類別時，觸發 segue，並將該類別的 categoryId 和 categoryTitle 傳遞給 DrinksCategoryViewController 進行後續處理。
 
    2. DrinksCategoryViewController：
        * 功能：
            - 用來顯示特定類別下的飲品子類別（如「DailySpecialsCoffeeSeries」、「HotEspresso」、「IcedEspresso」等）。
        * 操作：
            - 使用 MenuController 的 loadDrinksForCategory 方法，根據選擇的 categoryId，從 Firestore 的 Subcategories 子集合中讀取所有子類別及其對應的飲品資料。
            - 加載過程中，先加載子類別，並對每個子類別進一步讀取該子類別的 Drinks 子集合中的飲品資料。（這樣做是為了能顯示 Drinks 中每個飲品的圖片、名稱等資訊）。
            - 當所有資料加載完成後，將資料顯示在 UICollectionView 中，並根據不同的佈局（網格或列表）來呈現飲品資訊。
            - 使用者選擇某個飲品時，會將對應的 drinkId、categoryId、subcategoryId 傳遞給 DrinkDetailViewController，讓使用者查看飲品的詳細資料。
 
    3. DrinkDetailViewController：
        * 功能：
            - 用來顯示單一飲品的詳細資料，包括飲品名稱、描述、不同尺寸的價格、咖啡因含量、卡路里等資訊。
        * 操作：
            - 根據 DrinksCategoryViewController 傳遞的 drinkId、categoryId 和 subcategoryId，使用 MenuController 的 loadDrinkById 方法，從 Firestore 中精確加載該飲品的詳細資料。
            - 飲品資料加載完成後，透過 UICollectionView 顯示飲品的詳細資訊，並允許使用者選擇不同的尺寸。
            - 使用者可以將選擇的飲品加入購物車，並根據需求進行編輯或新增操作。
        * 補充：
            - 原先資料來自於 DrinksCategoryViewController 傳遞的 Drink 結構，透過 UICollectionView 顯示飲品的詳細資訊，並允許使用者選擇不同的尺寸，最終可以將飲品加入購物車。（導致我在設計「添加我的最愛」時，設計不太良好）
 
    4. FavoritesViewController：
        * 功能：
            - 顯示使用者收藏的飲品清單，並使用 MenuController 的 loadSubcategoryById 方法加載子類別名稱，將其作為 section header 顯示。
            - 使用 MenuController 的 loadDrinkById 來加載具體的飲品詳細資料。
        * 操作：
            - 每次進入 FavoritesViewController 時，會首先檢查使用者的收藏清單，使用 userDetails 中的收藏資料，根據子類別來分類顯示飲品清單。
            - 透過 loadSubcategoryById 加載子類別名稱作為 section header，並使用 loadDrinkById 加載對應的飲品資料。
            - 這些資料加載後，依照收藏順序呈現在畫面上，讓使用者可以瀏覽、刪除或查看飲品詳細資訊。

 &.數據處理總結：
    
    1. Firebase 結構：
        - Categories 是頂層集合，代表飲品的主要分類（如「CoffeeBeverages」）。
        - 每個 Category 文檔包含 Subcategories 子集合，存放該類別下的飲品子類別（如「DailySpecialsCoffeeSeries」、「HotEspresso」）。
        - 每個子類別下有 Drinks 子集合，存放具體的飲品資料（如飲品名稱、描述、價格等）。

    2. MenuController 的資料加載：
 
        * loadCategories 方法：
            - 從 Categories 集合中讀取所有類別資料，並在主畫面 MenuViewController 中展示。
 
        * loadDrinksForCategory 方法：
            - 根據指定的 categoryId，先讀取該類別的 Subcategories，再讀取每個子類別對應的 Drinks 資料，並在 DrinksCategoryViewController 中展示。
 
        * loadDrinkById 方法：
            - 根據傳入的 categoryId、subcategoryId 和 drinkId，從 Firestore 中精確加載單一飲品的詳細資料，並在 DrinkDetailViewController 中顯示。

 -------------------------------------------------------------------------------------------------------------------------------------------------------------------

 ## 使用 async/await 的優缺點與適用場景：
 
    & 何時應該使用 async/await
 
        1. 異步數據處理： 當處理像 Firebase 查詢這類需要等待結果的異步數據操作時，async/await 讓代碼更直觀、簡潔。避免了回調地獄（callback hell），使異步操作像同步代碼一樣順暢。
            * 適用情境： 從 Firebase 或 API 加載數據並更新 UI 時，async/await 讓數據流更清晰。
 
        2. 多個異步操作的連續處理： 當多個異步操作有依賴關係且需要依次進行時，async/await 可以讓代碼邏輯更加清楚，避免多重回調嵌套。
            * 適用情境： 例如先加載子類別資料，再加載對應的飲品資料，這種連續執行的異步操作適合使用 async/await。

    & 何時不一定需要使用 async/await
 
        1. 簡單的異步操作： 如果異步處理較簡單，且不需要多步驟，傳統的閉包或 DispatchQueue 已經夠用。
            * 適用情境： 一次性下載圖片、簡單的按鈕回應等，使用閉包可能比 async/await 更簡潔。

        2. 一些即時回應操作如動畫回調或按鈕點擊事件，用閉包會更靈活。
            * 適用情境： 例如動畫完成後的狀態更新，這類操作不需要等待結果。
 
        3. 即時回應的小型閉包處理： 一些即時回應操作如動畫回調或按鈕點擊事件，用閉包會更靈活。
            * 適用情境： 例如動畫完成後的狀態更新，這類操作不需要等待結果。
 
    & 其他注意事項

        * async/await 改善可讀性，但不一定提升性能： 它主要優化異步程式碼結構，而不是直接改善數據處理性能。如果數據查詢本身較慢，還是需要進行性能優化。
        * 並發處理要小心： 在同時執行大量任務時，要適當使用並行控制，如 TaskGroup，避免資源衝突。

    & 總結
        
        * 適合使用 async/await 的情境： 異步數據處理、多個步驟有依賴的操作。
        * 不一定要使用 async/await 的情境： 簡單回調、閉包能解決的小型異步操作。
        * 選擇依據： 根據具體情境和需求來決定。

 -------------------------------------------------------------------------------------------------------------------------------------------------------------------

 ## 「統一使用異步處理方式」與「根據情境選擇」的比較：（主要是針對目前專案重構部分去考量）

    & 統一使用同一種異步處理方式的好處：
        
        1. 一致性和可維護性： 使用統一的處理方式（如全部使用 async/await 或 DispatchQueue），可以讓代碼結構保持一致，便於開發者理解和維護。
        2. 降低學習成本： 團隊只需熟悉一種處理方式，減少學習和使用的複雜度。
        3. 減少錯誤： 混用多種異步處理方式容易導致錯誤，例如閉包處理時的強引用問題或混合使用 async/await 和 DispatchQueue 時的過度嵌套。
 
    & 根據情境選擇異步處理方式的優勢：

        1. async/await 更適合複雜數據流： 當處理需要多步驟的數據查詢、數據加載，async/await 提供了更高的可讀性和簡潔性。
            * 適用情境： 例如菜單數據讀取，涉及到多次數據查詢，彼此依賴，async/await 更加適合。
 
        2. DispatchQueue 適合即時響應操作： 如果是即時響應的操作，或需要簡單的異步切換執行緒來處理計算或 UI 更新，DispatchQueue 是更輕量且有效的選擇。
            * 適用情境： 像使用者的註冊、登入操作，通常只需短暫的網路請求，用 DispatchQueue 處理已足夠。
 
        3. 並行處理需求不同： 某些操作需要依序進行，async/await 讓邏輯更簡潔；而某些情況需要並行處理多個任務，像上傳多個文件，這時候 DispatchQueue 或 OperationQueue 可能更合適。
 
        4. 過渡期專案： 如果專案中已有大量使用 DispatchQueue 的代碼，為了降低重構風險，可以在新功能中逐步引入 async/await。
 
    & 範例情境：
        
        1. 使用者註冊、登入、大頭照上傳： 這些操作通常只需一次網絡請求，閉包或 DispatchQueue 已足夠。
        2. 菜單數據讀取： 涉及多個依賴數據查詢，async/await 能讓代碼邏輯更加清晰。

    & 結論：
        
        1. 統一使用異步處理方式： 適合需要一致性與可維護性的專案，尤其是團隊協作中，統一方式能避免潛在錯誤。
        2. 根據情境選擇： 當操作需求不同，選擇最合適的異步處理方式能提高代碼靈活性和可讀性。
 */



// MARK: - async/await

import UIKit
import FirebaseFirestore

/// 用於處理所有菜單的單例模式
class MenuController {
    
    static let shared = MenuController()
    
    // MARK: - Public Methods

    /// 從 Firestore 的 "Categories" 集合中異步加載所有類別資料。
    /// - Returns: 類別資料的陣列 [Category]
    /// - Throws: 若未找到類別資料或發生錯誤，則拋出相應的錯誤
    func loadCategories() async throws -> [Category] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("Categories").getDocuments()
        
        let categories = snapshot.documents.compactMap { try? $0.data(as: Category.self) }
        
        guard !categories.isEmpty else {
            throw MenuControllerError.categoriesNotFound
        }
        return categories
    }
  
    /// 從 Firestore 異步加載「特定類別」下的「所有子類別」及其「對應的飲品」資料。
    /// - Parameter categoryId: 類別的 ID（例如 "CoffeeBeverages"）
    /// - Returns: 一個包含各子類別及其飲品資料的陣列 [SubcategoryDrinks]
    /// - Throws: 如果未能成功加載資料或資料為空，會拋出錯誤
    func loadDrinksForCategory(categoryId: String) async throws -> [SubcategoryDrinks] {
        let subcategories = try await loadSubcategories(for: categoryId)                                // 先異步加載所有子類別
        return try await loadDrinks(for: subcategories, categoryId: categoryId)                         // 再根據子類別加載對應的飲品資料
    }
    
    /// 從 Firestore 加載特定的飲品資料
    /// - Parameters:
    ///   - categoryId: 類別的 ID
    ///   - subcategoryId: 子類別的 ID
    ///   - drinkId: 飲品的 ID
    /// - Returns: 加載的 Drink 資料
    /// - Throws: 如果資料加載失敗，拋出錯誤
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
    
    /// 從 Firestore 加載飲品時，透過` subcategoryId` 將`Subcategory`名稱加載出來。藉此在 FavoritesViewController 中使用該名稱來作為 section header。
    ///
    /// - Parameters:
    ///   - categoryId: 類別的 ID
    ///   - subcategoryId: 子類別的 ID
    /// - Returns: 加載的 Subcategory 資料
    /// - Throws: 如果資料加載失敗，拋出錯誤
    func loadSubcategoryById(categoryId: String, subcategoryId: String) async throws -> Subcategory {
        let db = Firestore.firestore()
        let document = try await db.collection("Categories").document(categoryId).collection("Subcategories").document(subcategoryId).getDocument()
        
        guard let subcategory = try? document.data(as: Subcategory.self) else {
            throw MenuControllerError.menuItemsNotFound
        }
        return subcategory
    }
    
    // MARK: - Private Methods

    /// 從 Firestore 異步加載指定類別下的子類別資料。
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

    /// 異步加載每個子類別下的飲品資料，並組合為 SubcategoryDrinks 陣列。
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

/// 處理 MenuController 的錯誤
enum MenuControllerError: Error, LocalizedError {
    case categoriesNotFound
    case menuItemsNotFound
    case unknownError
    case firebaseError(Error)
    
    // 將 Firebase 錯誤轉為 MenuControllerError，使得錯誤處理相對一致
    static func from(_ error: Error) -> MenuControllerError {
        return .firebaseError(error)
    }
    
    /// 錯誤訊息的本地化描述
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




// MARK: - MenuController（ completion handler 原版筆記）
/*
 ### MenuController（原版）

    * loadCategories：
        - 功能：
            - 從 Firebase Firestore 中的 "Categories" 集合加載所有飲品類別的資料。
        - 流程：
            1. Firebase 的 getDocuments 從 "Categories" 集合抓取所有文件。
            2. 透過 compactMap 解析每個文件的資料，轉換為 `Category` 結構。
            3. 如果資料加載失敗或沒有找到資料，則會回傳錯誤。

    * loadDrinksForCategory：
        - 功能：
            - 根據傳入的類別 ID (categoryId)，從 Firebase 中抓取該類別下的所有子類別及其對應的飲品資料。
        - 流程：
            1. 先從指定的 "Categories" 集合中的子集合 "Subcategories" 讀取子類別資料。
            2. 對於每個子類別，再讀取該子類別的 "Drinks" 子集合，獲取對應的飲品列表。
            3. 使用 `DispatchGroup` 確保每個子類別的飲品資料都加載完成後，才調用最終的完成閉包，回傳所有 `SubcategoryDrinks` 結構。
   
    * DispatchGroup：
        - 用於管理並行的資料請求。
        - 當需要從多個子類別中同時請求資料時，`DispatchGroup` 確保所有請求都完成後，才會回傳結果。這樣避免了未完成的請求導致資料不完整。

    * 錯誤處理 (MenuControllerError)：
        - 為了統一處理 Firebase 請求過程中的錯誤，定義了 MenuControllerError，並包括：
        - categoriesNotFound： 找不到類別資料。
        - menuItemsNotFound： 找不到飲品資料。
        - firebaseError： 將 Firebase 的錯誤轉換成通用的菜單控制器錯誤。
        - 提供了對應的 errorDescription，方便顯示錯誤訊息。

    * 總結：
        - loadCategories 是用來加載飲品的頂層類別資料，如「咖啡」、「茶飲」等。
        - loadDrinksForCategory 是針對每個類別，進一步深入加載該類別下的子類別和飲品資料。該方法會同時處理多個子類別的飲品請求，使用 DispatchGroup 確保所有資料在同一時間完成。
 */


// MARK: - 添加錯誤版本（原版）
/*
import UIKit
import FirebaseFirestore

/// 用於處理所有菜單的單例模式
class MenuController {
    
    static let shared = MenuController()
    
    /// 從 Firestore 的 "Categories" 集合中獲取所有類別資料。
    /// - Parameter completion: 當數據加載完成時執行的閉包，返回結果，包含類別陣列或錯誤。
    func loadCategories(completion: @escaping (Result<[Category], MenuControllerError>) -> Void) {
        let db = Firestore.firestore()
        db.collection("Categories").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(.from(error)))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.failure(.categoriesNotFound))
                return
            }
            
            let categories = documents.compactMap { document -> Category? in
                return try? document.data(as: Category.self)
            }
            
            if categories.isEmpty {
                completion(.failure(.categoriesNotFound))
            } else {
                completion(.success(categories))
            }
        }
    }
    
    
    /// 首先從指定類別的 "Subcategories" 子集合中讀取所有子類別，
    /// 然後對於每個子類別，從其 "Drinks" 子集合中獲取相關飲品數據。
    /// - Parameters:
    ///   - categoryId: 要查詢的類別 ID。
    ///   - completion: 當數據加載完成時執行的閉包，返回一個結果，包含 SubcategoryDrinks 陣列或錯誤。
    func loadDrinksForCategory(categoryId: String, completion: @escaping (Result<[SubcategoryDrinks], MenuControllerError>) -> Void) {
        loadSubcategories(for: categoryId) { result in
            switch result {
            case .success(let subcategories):
                self.loadDrinks(for: subcategories, categoryId: categoryId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func loadSubcategories(for categoryId: String, completion: @escaping (Result<[Subcategory], MenuControllerError>) -> Void) {
        let db = Firestore.firestore()
        db.collection("Categories").document(categoryId).collection("Subcategories").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(.from(error)))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.failure(.menuItemsNotFound))
                return
            }
            
            let subcategories = documents.compactMap { try? $0.data(as: Subcategory.self) }
            completion(.success(subcategories))
        }
    }
    
    private func loadDrinks(for subcategories: [Subcategory], categoryId: String, completion: @escaping (Result<[SubcategoryDrinks], MenuControllerError>) -> Void) {
        let db = Firestore.firestore()
        var subcategoryDrinksList: [SubcategoryDrinks] = []
        let group = DispatchGroup()
        
        for subcategory in subcategories {
            group.enter()
            db.collection("Categories").document(categoryId).collection("Subcategories").document(subcategory.id ?? "").collection("Drinks").getDocuments { snapshot, error in
                if let error = error {
                    group.leave()
                    completion(.failure(.from(error)))
                    return
                }
                
                guard let drinkDocuments = snapshot?.documents else {
                    group.leave()
                    completion(.failure(.menuItemsNotFound))
                    return
                }
                
                let drinks = drinkDocuments.compactMap { try? $0.data(as: Drink.self) }
                subcategoryDrinksList.append(SubcategoryDrinks(subcategory: subcategory, drinks: drinks))
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if subcategoryDrinksList.isEmpty {
                completion(.failure(.menuItemsNotFound))
            } else {
                completion(.success(subcategoryDrinksList))
            }
        }
    }
}


 // MARK: - Error

enum MenuControllerError: Error, LocalizedError {
    case categoriesNotFound
    case menuItemsNotFound
    case unknownError
    case firebaseError(Error)
    
    // 將 Firebase 錯誤轉為 MenuControllerError，使得錯誤處理相對一致
    static func from(_ error: Error) -> MenuControllerError {
        return .firebaseError(error)
    }
    
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
*/
