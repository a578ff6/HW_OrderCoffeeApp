//
//  FavoriteDrink.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/20.
//

// MARK: - FavoriteDrink 筆記
/**
 
 ## FavoriteDrink 筆記
 
 `* What`
 
 - `FavoriteDrink` 是用於描述使用者收藏的飲品數據模型。
 - 它包含飲品的分類、名稱、圖片 URL 及其他相關資訊。
 - 並遵循 `Codable` 和 `Hashable` 協議，支持 `Firebase` 的數據存取和 Swift 集合操作。
 
--------------
 
 `* Why`
 
 `1.Codable 支援：`

 - Firestore 提供了基於 Codable 的自動編解碼功能，讓數據模型與 Firestore 文檔可以直接映射，避免手動解析的繁瑣和錯誤。
 
 `2.動態計算屬性：`

 - `imageUrlString` 是存儲於 Firestore 的屬性，imageUrl 則是動態計算的屬性。
 
 - 此設計遵循「分層處理」原則：
    - 模型層負責數據轉換。
    - UI 層專注於圖片加載，不需要處理字串到 URL 的轉換。
 
 `3.支援集合操作：`

 - 實現 `Hashable`，允許用作集合（如 Set）或字典鍵值，提高數據操作靈活性，適用於數據去重或快速查找。

 `4.屬性設計清晰：`

 - `分類和唯一標識`：
    - `categoryId` 和 `subcategoryId` 提供清晰的分層分類邏輯。
    - `drinkId` 作為唯一標識符，確保每個飲品在 `Firestore` 和本地都有唯一標記，方便操作。
 
 - `時間戳設置`：
    - `timestamp` 屬性提供飲品添加時間的記錄，便於在 UI 層按時間排序，實現「`按添加順序顯示`」等功能。

 --------------

 `* How`
 
 `1.定義結構：`

 - 使用 `Codable` 協議與 `Firestore` 的數據結構匹配，並設計必要的屬性。
 - 添加計算屬性 `imageUrl` 以簡化圖片加載邏輯。
 - `timestamp` 屬性，用於映射 `Firebase` 的 `Timestamp` 到 `Date`，並確保數據排序功能的實現。
 
 `2.與 Firebase 集成：`

 - 使用 `Firestore` 提供的` getDocument(as:)` 和 `setData(from:)` 方法進行數據交互，確保與 Firestore 格式兼容。
 - 在 `Firestore` 中，`timestamp` 屬性需使用 `Firebase` 的 `FieldValue.serverTimestamp() `自動生成或手動設置，並在模型層自動解析為 `Swift` 的 `Date`。
 
 `3.在 UI 層使用：`
 
 - 使用 `timestamp` 屬性按時間升序或降序排列飲品列表，保持用戶收藏的顯示順序。
 - 使用 `FavoriteDrink` 的 `imageUrl` 屬性簡化圖片加載邏輯，避免 UI 層處理 URL 轉換。
 
 --------------

` * 設計理念`
 
 - `timestamp` 的作用與設計目的：
 
` 1.實現排序功能：`

 - 按時間戳排序可確保飲品在列表中按照添加順序或最近更新順序顯示。
 
 `2.確保數據一致性：`

 - `timestamp` 屬性與 `Firebase` 的內置 `Timestamp` 類型無縫對接，避免本地與後端數據不一致。

 */


// MARK: - categoryId、subcategoryId 和 drinkId 的設計目的
/**
 
 ## categoryId、subcategoryId 和 drinkId 的設計目的

 `* What`

 - `categoryId`：表示飲品所屬的主要分類，例如 Frappuccino。
 - `subcategoryId`：表示飲品的次分類，例如 CoffeeFrappuccinoSeries。
 - `drinkId`：飲品的唯一標識符，用於快速查找和操作。
 - 這三個屬性共同組成了 `FavoriteDrink` 資料模型中飲品的完整識別信息，與 Firestore 資料結構直接對應。

 --------------

 `* Why`

 `1. 提升查詢效率：`
 
    - 在 Firestore 中，飲品資料通常位於多層次結構中（如 `categories > subcategories > drinks`）。
    - 如果只存 `drinkId`，每次查詢時需遍歷所有類別和子類別，增加查詢的複雜度與耗時。
    - 保存 `categoryId` 和 `subcategoryId` 能直接定位到具體層級，大幅提高查詢效率。

 `2. 清晰的數據結構：`
 
    - 將資料分為主要分類（`categoryId`）和次分類（`subcategoryId`），能反映飲品的實際分類層級，讓資料邏輯更直觀。

 `3. 支援擴展性：`
 
    - 在應用功能擴展（如新增分類、篩選等）時，這種結構更容易適配新的需求。
    - 使用多層 ID 組合，能更靈活應對後端結構變更。

 `4. 與現有方法兼容：`
 
    - `loadDrinkById` 已支持通過 `categoryId`、`subcategoryId` 和 `drinkId` 進行查詢，保持資料一致性和兼容性。

 --------------

` * How`

 `1. 定義結構：`
 
    - 在 `FavoriteDrink` 中新增 `categoryId` 和 `subcategoryId` 屬性，並與 `drinkId` 一起作為飲品的唯一標識符。

    ```swift
    struct FavoriteDrink: Codable, Hashable {
        var categoryId: String       // 飲品的主要分類
        var subcategoryId: String    // 飲品的次分類
        var drinkId: String          // 飲品的唯一標識符
        var name: String             // 飲品名稱
        var subName: String          // 飲品副標題
        var imageUrlString: String   // 飲品圖片 URL 的字串
        var timestamp: Date          // 飲品的添加時間
    }
    ```

 -----
 
 `2. 查詢資料：`
 
    - 使用 `MenuController` 的 `loadDrinkById` 方法，通過三個屬性組合快速定位飲品資料。

    ```swift
    let loadedDrink = try await MenuController.shared.loadDrinkById(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        drinkId: drinkId
    )
    ```

 -----

 `3. 更新清單顯示：`
    - 當使用者收藏飲品時，保存完整的分類和 ID 信息，確保後續查詢和顯示正確。

 -----

 `4. 與 UI 整合：`
 
    - 在 `DrinkDetailViewController` 中，通過 `categoryId`、`subcategoryId` 和 `drinkId` 加載詳細資料，並確保每個飲品的顯示與後端數據一致。

 --------------

 `* 設計理念`

 `1. 查詢效率與維護成本的平衡：`
 
    - 將查詢時的複雜邏輯移至保存時處理，通過保存多層 ID 簡化查詢邏輯。

 `2. 數據結構的清晰性：`
 
    - 將分類與標識符分層存儲，讓資料結構與應用需求保持一致。

` 3. 擴展性與兼容性：`
 
    - 支援未來功能擴展（如篩選、分組等），並與現有查詢方法無縫對接。

 --------------

 `* 筆記總結`

 - `categoryId` 和 `subcategoryId` 補充了 `drinkId`，形成完整的資料識別體系。
 - 提升了 Firestore 資料查詢的效率，同時保持資料結構的清晰性與擴展性。
 - 符合邏輯分層設計原則，實現更快、更準確的資料查詢和顯示。

 --------------

 `* 範例程式碼應用`

 `1. 收藏飲品時保存完整分類信息：`

    ```swift
    let favoriteDrink = FavoriteDrink(
        categoryId: "frappuccino",
        subcategoryId: "coffeeFrappuccinoSeries",
        drinkId: "caramelFrappuccino",
        name: "Caramel Frappuccino",
        subName: "Blended Beverage",
        imageUrlString: "https://example.com/caramel-frappuccino.jpg",
        timestamp: Date()
    )
    ```
 -----

 `2. 查詢飲品詳細資料：`

    ```swift
    guard let categoryId = favoriteDrink.categoryId,
          let subcategoryId = favoriteDrink.subcategoryId,
          let drinkId = favoriteDrink.drinkId else { return }

    let drink = try await MenuController.shared.loadDrinkById(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        drinkId: drinkId
    )
    ```
 */


// MARK: - 職責單一 (v)

import UIKit

/// `FavoriteDrink` 是用於表示使用者收藏的飲品數據結構。
///
/// - 支援 Firebase 的 `Codable` 協議，用於與 Firestore 進行數據交互，實現存儲與讀取操作。
/// - 支援 `Hashable`，使其可用於集合（如 `Set`）或作為 `Dictionary` 的鍵值。
/// - 屬性解釋：
///   - `categoryId`: 飲品所屬的主要分類（如 Frappuccino）。
///   - `subcategoryId`: 飲品所屬的次分類（如 CoffeeFrappuccinoSeries）。
///   - `drinkId`: 飲品的唯一標識符，用於快速查找和更新收藏。
///   - `name`: 飲品的名稱（如 焦糖星冰樂）。
///   - `subName`: 飲品的副標題（如 Caramel Frappuccino Blended Beverage）。
///   - `imageUrlString`: 飲品圖片的 URL 字串，存儲於 Firestore，並通過計算屬性 `imageUrl` 動態轉換為 `URL`。
///   - `timestamp`: 飲品的添加時間，作為 Firebase 的 `Timestamp` 映射到 Swift 的 `Date`。
/// - 設計理念：
///   - 使用 `imageUrlString` 存儲數據，保留 Firebase 的編解碼效率。
///   - 提供 `imageUrl` 作為動態計算屬性，簡化 UI 層的圖片加載邏輯。
///   - 添加 `timestamp` 屬性，用於排序和記錄飲品添加的時間。
struct FavoriteDrink: Codable, Hashable {
    var categoryId: String
    var subcategoryId: String
    var drinkId: String
    var name: String
    var subName: String
    var imageUrlString: String
    var timestamp: Date

    var imageUrl: URL? {
        URL(string: imageUrlString)
    }
}
