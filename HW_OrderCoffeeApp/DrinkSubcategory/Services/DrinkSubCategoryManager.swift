//
//  DrinkSubCategoryManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/25.
//

// MARK: - DrinkSubCategoryManager 筆記
/**
 
 ### DrinkSubCategoryManager 筆記


` * What`
 
 - `DrinkSubCategoryManager` 是一個負責處理飲品子類別數據操作的管理類別。
 - 核心功能是從`資料層`加載子類別及其飲品數據，並將其轉換為`視圖層`可用的展示模型（`DrinkSubCategoryViewModel`）。

 - 功能描述：
 
   1. 加載指定父類別（`categoryId`）下的所有子類別及其對應的飲品數據。
   2. 將資料層模型（`SubcategoryDrinks`）轉換為簡化的展示模型（`DrinkSubCategoryViewModel`）。
   3. 支援異步數據加載，確保 UI 反應流暢且不受阻塞影響。

 - 關鍵方法：
 
   - `fetchDrinkSubcategories(for:)`：負責與資料層交互，返回對應分類的所有子類別與飲品的展示數據列表。

 ---------

 `* Why`
 
 - `DrinkSubCategoryManager` 的設計目的是實現數據處理與視圖展示的解耦。

 1. 提升模組化與可維護性：
 
    - 將數據邏輯集中到一個管理類別中，避免控制器過於臃腫（Fat Controller）。
    - 使用展示模型（ViewModel）適配視圖需求，減少視圖層對資料層細節的依賴。

 2. 加強靈活性與可測試性：
 
    - 通過統一的接口加載與轉換數據，方便測試與調試。
    - 異步方法支援，避免阻塞主線程，提高用戶體驗。

 3. 實現單一職責原則（SRP）：
 
    - 僅專注於飲品子類別數據的加載與轉換，其他業務邏輯（如導航、UI 操作）由其他類別負責。

 ---------

 `* How`

 - 架構與實現：
 
 1. 屬性：
 
    - `menuController`：負責與資料層交互的單例類，用於加載子類別及飲品的原始數據。

 2. 方法：
 
    - `fetchDrinkSubcategories(for:)`：
      - 接收父類別 ID（`categoryId`），調用資料層方法獲取子類別及飲品數據。
      - 使用 `map` 將原始模型轉換為 `DrinkSubCategoryViewModel` 列表。
      - 支援異步處理，避免主線程阻塞。

     - 範例：
 
     ```swift
     let drinkSubCategoryManager = DrinkSubCategoryManager()
     Task {
         do {
             drinkSubcategoryViewModels = try await drinkSubCategoryManager.fetchDrinkSubcategories(for: categoryId)
             print("[Load Data]: Loaded \(drinkSubcategoryViewModels.count) subcategories")
         } catch {
             print("加載子類別數據失敗: \(error.localizedDescription)")
         }
     }
     ```

 ---------

 `* 設計原則：`
 
 1. 高內聚：
 
    - 將子類別相關的數據邏輯集中於此類別，便於管理與維護。
 
 2. 低耦合：
 
    - 視圖層僅依賴展示模型與 `DrinkSubCategoryManager`，無需關心資料層細節。
 
 3. 異步加載：
 
    - 使用 `async/await` 進行數據操作，確保用戶體驗流暢。

 ---------

 `* 總結`
 
 - `DrinkSubCategoryManager` 是架構中負責數據處理的核心模組之一，實現了資料層與視圖層的高效解耦。
 - 它的設計符合單一職責與依賴倒置原則，並透過異步加載優化用戶體驗。同時，其提供的統一數據接口使代碼更易於測試與擴展，適合在多層結構的應用中使用。
 
 */




// MARK: - (v)

import UIKit


/// 負責處理與飲品子類別相關的數據操作與轉換的管理類別。
///
/// - 設計目的:
///   1. 將資料層的原始數據（如 Firestore 返回的子類別及其飲品數據）轉換為視圖層所需的展示模型（`DrinkSubCategoryViewModel`）。
///   2. 提供統一的數據加載接口，減少視圖層對資料層細節的依賴，實現高內聚低耦合的架構設計。
///   3. 支援異步操作，確保數據加載過程不會阻塞主線程，提升用戶體驗。
///
/// - 使用場景:
///   1. 供 `DrinkSubCategoryViewController` 使用，用於加載特定分類的子類別及其飲品數據。
///   2. 作為數據中介，確保視圖層獲取的數據經過處理且適配 UI 需求。
///
/// - 設計原則:
///   - 單一職責原則（SRP）:
///     該類僅專注於飲品子類別及其相關數據的處理與轉換，避免包含其他邏輯。
///   - 依賴倒置原則（DIP）:
///     高層模組（如控制器）依賴於此抽象類別，而不是直接依賴資料層（如 `MenuController`）。
///
/// - 方法:
///   1. `fetchDrinkSubcategories(for:)`:
///      - 加載特定分類的子類別及其飲品數據。
///      - 將資料轉換為適配視圖層的展示模型 `DrinkSubCategoryViewModel`。
///
/// - 屬性:
///   - `menuController`: 用於與 Firestore 進行交互的資料層單例類。
class DrinkSubCategoryManager {
    
    /// 負責與 Firestore 進行交互。
    private let menuController = MenuController.shared
    
    
    // MARK: - Public Methods
    
    /// 加載特定類別的子類別及其飲品數據，並轉換為 `ViewModel`。
    ///
    /// - 說明:
    ///   - 該方法使用 `menuController` 從資料層加載特定類別的所有子類別及其對應的飲品數據。
    ///   - 將原始資料結構（`SubcategoryDrinks`）轉換為 `DrinkSubCategoryViewModel` 列表。
    ///
    /// - 參數:
    ///   - categoryId: 父分類的唯一識別碼，用於過濾對應的子類別及飲品數據。
    ///
    /// - 回傳值:
    ///   - `[DrinkSubCategoryViewModel]`: 對應分類的所有子類別及其飲品的展示模型列表。
    ///
    /// - 異常處理:
    ///   - 若資料加載失敗，將拋出錯誤供上層處理。
    ///
    /// - 使用場景:
    ///   - 供 `DrinkSubCategoryViewController` 使用，為 `UICollectionView` 提供子類別和飲品的展示數據。
    func fetchDrinkSubcategories(for categoryId: String) async throws -> [DrinkSubCategoryViewModel] {
        let subcategoriesWithDrinks = try await menuController.loadSubcategoriesWithDrinks(forCategoryId: categoryId)
        return subcategoriesWithDrinks.map { subcategoryDrinks in
            DrinkSubCategoryViewModel(subcategoryDrinks: subcategoryDrinks)
        }
    }
    
}
