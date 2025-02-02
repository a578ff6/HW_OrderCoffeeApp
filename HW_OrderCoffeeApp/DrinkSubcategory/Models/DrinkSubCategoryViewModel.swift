//
//  DrinkSubCategoryViewModel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/25.
//


// MARK: - DrinkSubCategoryViewModel、DrinkViewModel 筆記
/**
 
 ## DrinkSubCategoryViewModel、DrinkViewModel 筆記


 `* What:`
 
 - `DrinkSubCategoryViewModel` 和 `DrinkViewModel` 是展示模型（ViewModel），主要負責將資料層的原始數據轉換為視圖層可以直接使用的輕量結構。

 1. `DrinkSubCategoryViewModel`:
 
    - 表示飲品子類別，包含子類別標題、唯一識別碼及其下的飲品列表。
    - 將複雜的資料層結構 `SubcategoryDrinks` 簡化為視圖層專用的格式。
    
 2. `DrinkViewModel`:
 
    - 表示單個飲品，包含飲品名稱、子標題、圖片 URL 和唯一識別碼。
    - 將資料層的 `Drink` 模型轉換為輕量級結構。

 --------

 `* Why`
 
 - 這些 ViewModel 的設計目的與優勢：

 1. 資料結構輕量化:
 
    - 避免在視圖層直接處理複雜的資料模型，提升處理效率。
    
 2. 單一職責原則（SRP）:
 
    - 視圖層只負責顯示數據，資料層邏輯與視圖邏輯分離。
    - 增強代碼可讀性與維護性。

 3. 減少耦合:
 
    - 隔離資料層與視圖層，避免直接依賴資料層的實現細節。

 4. 適配 UI 需求:
 
    - 提供 UI 所需的關鍵字段（例如名稱、圖片），不攜帶多餘的資料。

 --------

 `* How:`

 1. `DrinkSubCategoryViewModel` 實現步驟:
 
    - 定義屬性：
 
      - `subcategoryId`: 子類別的唯一識別碼。
      - `subcategoryTitle`: 子類別的標題，供 UI 顯示。
      - `drinks`: 包含該子類別下的飲品列表，使用 `DrinkViewModel` 表示。
 
    - 初始化方法：
 
      - 從資料層模型 `SubcategoryDrinks` 中提取必要數據。
      - 將子類別標題和飲品列表進行映射轉換。
 
    - 使用場景：
 
      - 提供給 `DrinkSubCategoryViewController`，用於配置 `UICollectionView` 的資料源。

    ```swift
    struct DrinkSubCategoryViewModel {
        let subcategoryId: String
        let subcategoryTitle: String
        let drinks: [DrinkViewModel]
        
        init(subcategoryDrinks: SubcategoryDrinks) {
            self.subcategoryId = subcategoryDrinks.subcategory.id ?? ""
            self.subcategoryTitle = subcategoryDrinks.subcategory.title
            self.drinks = subcategoryDrinks.drinks.map { DrinkViewModel(drink: $0) }
        }
    }
    ```

 ---
 
 2. `DrinkViewModel` 實現步驟:
 
    - 定義屬性：
 
      - `id`: 飲品的唯一識別碼。
      - `name`: 飲品的名稱。
      - `subName`: 飲品的次標題。
      - `imageUrl`: 飲品的圖片 URL。
 
    - 初始化方法：
 
      - 從資料層模型 `Drink` 中提取 ID、名稱、圖片等關鍵字段。
 
    - 使用場景：
 
      - 提供給 `UICollectionView` 的 Cell 配置，顯示飲品的名稱與圖片。

    ```swift
    struct DrinkViewModel {
        let id: String
        let name: String
        let subName: String
        let imageUrl: URL
        
        init(drink: Drink) {
            self.id = drink.id ?? ""
            self.name = drink.name
            self.subName = drink.subName
            self.imageUrl = drink.imageUrl
        }
    }
    ```
 
---
 
 3. 應用方式:
 
    - 在 `DrinkSubCategoryViewController` 中，調用 `DrinkSubCategoryManager` 提取資料，並將結果轉換為 `DrinkSubCategoryViewModel`。
    - 使用 `DrinkSubCategoryViewModel` 提供的資料來配置 `UICollectionView`。

 --------

` * 總結:`
 
    - 這些 ViewModel 將資料層與視圖層解耦，提供了輕量、可讀、可重用的數據結構，滿足 UI 顯示需求的同時保持了代碼清晰與結構化。
 */





// MARK: - (v)

import Foundation


// MARK: - DrinkSubCategoryViewModel

/// 用於表示飲品子類別的展示模型（ViewModel）。
///
/// 此模型主要用於將資料層的結構轉換為視圖層可以直接使用的數據，
/// 包括子類別的標題、ID，以及該子類別下的所有飲品資訊。
///
/// - 設計目的:
///   1. 將資料模型（`SubcategoryDrinks`）輕量化，僅保留與 UI 相關的必要資訊。
///   2. 簡化資料操作，避免在視圖層直接處理複雜的資料結構。
///   3. 提高代碼可讀性，實現單一職責的設計原則（SRP）。
///
/// - 使用場景:
///   1. 提供給 `DrinkSubCategoryViewController` 顯示子類別資訊。
///   2. 作為資料來源供 `UICollectionView` 配置每個子類別的標題和飲品列表。
///
/// - 屬性說明:
///   - subcategoryId: 子類別的唯一識別碼。
///   - subcategoryTitle: 子類別的標題，用於顯示在子類別的 Header 上。
///   - drinks: 包含子類別下所有飲品的 ViewModel 列表。
struct DrinkSubCategoryViewModel {
    let subcategoryId: String
    let subcategoryTitle: String
    let drinks: [DrinkViewModel]
    
    /// 初始化方法
    ///
    /// - 將資料層模型 `SubcategoryDrinks` 轉換為展示模型。
    /// - 使用子類別的 ID、標題，以及飲品列表進行初始化。
    ///
    /// - 參數:
    ///   - subcategoryDrinks: 包含子類別及其飲品的原始數據。
    init(subcategoryDrinks: SubcategoryDrinks) {
        self.subcategoryId = subcategoryDrinks.subcategory.id ?? ""
        self.subcategoryTitle = subcategoryDrinks.subcategory.title
        self.drinks = subcategoryDrinks.drinks.map { DrinkViewModel(drink: $0) }
    }
    
}


// MARK: - DrinkViewModel

/// 用於表示單個飲品的展示模型（ViewModel）。
///
/// 此模型負責將資料層的飲品數據（`Drink`）轉換為視圖層的簡化結構，
/// 包含與 UI 顯示相關的核心資訊，如飲品名稱、圖片 URL、子標題等。
///
/// - 設計目的:
///   1. 提供輕量化的數據結構給視圖層使用，避免在 UI 處理繁瑣的資料邏輯。
///   2. 將資料層邏輯與視圖層邏輯分離，遵循單一職責原則（SRP）。
///
/// - 使用場景:
///   1. 作為 `DrinkSubCategoryViewModel` 的一部分，提供飲品列表的顯示數據。
///   2. 用於 `UICollectionView` 的 Cell 配置，顯示飲品圖片與基本資訊。
///
/// - 屬性說明:
///   - id: 飲品的唯一識別碼，用於後續的導航或資料操作。
///   - name: 飲品的主要名稱，顯示於 UI 的標題位置。
///   - subName: 飲品的次要名稱，通常顯示於副標題或描述。
///   - imageUrl: 飲品的圖片 URL，供視圖層下載並顯示對應圖片。
struct DrinkViewModel {
    let id: String
    let name: String
    let subName: String
    let imageUrl: URL
    
    /// 初始化方法
    ///
    /// - 將資料層模型 `Drink` 轉換為展示模型。
    /// - 提取飲品的核心資訊（ID、名稱、圖片等）。
    ///
    /// - 參數:
    ///   - drink: 原始的飲品數據模型。
    init(drink: Drink) {
        self.id = drink.id ?? ""
        self.name = drink.name
        self.subName = drink.subName
        self.imageUrl = drink.imageUrl
    }
    
}
