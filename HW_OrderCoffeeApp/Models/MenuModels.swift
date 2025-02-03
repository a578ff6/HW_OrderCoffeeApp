//
//  MenuModels.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

// MARK: - MenuModels.swift 基本模型的角色與設計思維
/**
 
 ### MenuModels.swift 基本模型的角色與設計思維

 - 原本直接使用 `MenuModels.swift` 來處理 `UI`呈現，結果隨著不同的視圖功能擴展，再加上飲品是屬於鉗套結構，導致我在修改其中的視圖時都要顧慮到其他的視圖功能。
 - 再加上不同視圖都使用`MenuModels.swift`，導致職責層級混亂，因此決定採用專屬的`ViewModel`的方式，達到單一原則。

 `* What：`
 
 - `MenuModels.swift` **並不直接用於 UI 展示**，而是作為 **基礎數據模型**，負責**對應 Firestore JSON 結構**，並提供結構化的數據存取方式。
 
 - 這些模型的主要功能是：
 
    1. 映射 Firestore 資料：使用 `Codable` 解析 Firebase JSON，確保 Swift 物件可以順利與後端資料同步。
 
    2. 結構化飲品分類數據：將 Firebase 層級結構對應到 Swift 結構，如 `Category`、`Subcategory`、`Drink`、`SizeInfo`。
 
    3. 作為展示模型的數據來源：這些模型不直接用於 UI，而是被 **展示模型（ViewModel）** 轉換成 UI 友善的格式，例如：
 
       - `MenuDrinkCategoryViewModel`（對應 `Category`）
       - `DrinkSubCategoryViewModel`（對應 `SubcategoryDrinks`）
       - `DrinkViewModel`（對應 `Drink`）
       - `DrinkDetailModel`（對應 `Drink`，但專門為 `DrinkDetailViewController` 設計）

 -------

 `* Why：`
 
 - 使用 `MenuModels.swift` 作為基礎模型，而非直接將其作為 UI 層的資料來源，主要是基於幾個關鍵考量：

 1. Firestore JSON 結構複雜，模型需要符合資料存取方式。
 
    - Firestore 資料結構為 **巢狀結構**（Nested JSON），例如：
 
     ```json
     {
       "name": "可可瑪奇朵",
       "sizes": {
         "Medium": {
           "price": 140,
           "calories": 300
         }
       }
     }
     ```
 
 - 這樣的結構 **不適合直接在 UI 層使用**，因此需要定義 ** 結構（Struct）** 來匹配 Firestore 資料格式，如 `Drink`、`SizeInfo`。

 ---

 2.減少 Firebase 依賴，提升可維護性
 
 - 如果直接在 **UI 層**（例如 `DrinkDetailViewController`）存取 Firestore 資料：
 
    - 會使 UI **強烈依賴 Firebase API**，降低模組化設計的靈活性。
    - 如果 Firestore 結構變更，所有相關 UI 可能都需要修改。

 - 因此，透過 **基礎模型 + 展示模型** 的方式：
 
    - 基礎模型（`MenuModels.swift`）：與 Firebase 直接對應，確保數據結構正確
    - 展示模型（`DrinkDetailModel` 等）：簡化數據結構，提供 UI 所需資訊，**與 Firestore 解耦**。

 ---

 3. 提高 UI 性能，避免不必要的數據處理
 
 - 例如 `Drink` 內 `sizes` 屬性是 **字典結構 (`[String: SizeInfo]`)**，但 UI 可能需要**排序後的尺寸列表**。
 
    - 透過 `DrinkDetailModel`，我們可以**在初始化時先排序**，減少 UI 層的計算：
 
     ```swift
     self.sortedSizes = drink.sizes.keys.sorted()
     ```
 
    - 這樣 UI 層只需要讀取 `sortedSizes`，無需額外排序，提高效能。
 
 -------

 `* How：`
 

 1.轉換成 UI 友善的 **展示模型**
 
 - 基礎模型通常包含較多 Firebase 的資訊，直接在 UI 層使用會顯得複雜。因此，需要將其轉換為 **更適合 UI 處理的結構**。

    - 例子：將 `Category` 轉換為 `MenuDrinkCategoryViewModel`**

     ```swift
     struct MenuDrinkCategoryViewModel {
         let id: String
         let title: String
         let imageUrl: URL
         let subtitle: String
         
         init(category: Category) {
             self.id = category.id ?? ""
             self.title = category.title
             self.imageUrl = category.imageUrl
             self.subtitle = category.subtitle
         }
     }
     ```
 
    - 這樣 UI 只需讀取 `MenuDrinkCategoryViewModel`，不需要處理 Firestore 的 `DocumentID` 或其他 Firebase 相關細節。

 ---

 3. 在 UI 層只使用展示模型
 
 - 展示模型提供 **簡單清晰的數據**，供 UI 層直接使用：
 
     ```swift
     let categoryViewModel = MenuDrinkCategoryViewModel(category: category)
     titleLabel.text = categoryViewModel.title
     imageView.loadImage(from: categoryViewModel.imageUrl)
     ```
 
 - 這樣的設計能確保：
 
 1. Firebase 變更不影響 UI
 2. UI 不需要關心 Firebase 結構
 3. 提高模組化設計與可維護性

 -------

 `* 總結`
 
 這樣的設計確保：
 
 - Firebase 變更時 UI 仍然穩定
 - Firebase 操作與 UI 顯示完全分離
 - 提高代碼可讀性與維護性

 */


// MARK: - 層級、用途、設計目的
/**
 
 ### 層級、用途、設計目的

`1. MenuModels.swift（數據層 / 基礎模型）`
 
 - 用途：
 
   - 負責映射 Firestore JSON 結構，使 Swift 物件能夠與 Firestore 數據對應。
   - 提供標準化的 Swift 結構，以便後續轉換為 UI 友善的數據格式。
 
 - 設計目的：
 
   - 確保數據結構一致性：讓應用程式可以準確解析 Firestore 的巢狀 JSON 結構。
   - 避免 Firebase API 直接暴露給 UI 層，提升系統模組化程度。

 ---

 `2. 展示模型（ViewModel）（UI 層）`
 
 - 用途：
 
   - 負責將 `MenuModels.swift` 的基礎數據轉換為 UI 友善的結構，方便 UI 直接使用。
   - 減少 UI 層對 Firebase API 的依賴，使 UI 只關心顯示邏輯。
 
 - 設計目的：
 
   - 簡化 UI 層數據處理：預先整理數據，避免在 UI 進行不必要的轉換。
   - 提高可維護性：當 Firebase 結構變更時，只需調整 `ViewModel`，無需修改 UI 邏輯。

 ---

 `3. ViewController（UI 控制器）`
 
 - 用途：
 
   - 只負責 UI 顯示與使用者交互，不直接處理 Firebase 相關邏輯。
   - 透過 `ViewModel` 取得數據，確保 UI 層專注於視覺與互動。
 
 - 設計目的：
 
   - 分離關心點（Separation of Concerns）：讓 UI 只處理 UI，而非業務邏輯或 Firebase 存取。
   - 提高可讀性與可測試性：減少 Controller 的職責，使測試更容易。

 ---

 `* 總結`
 
 - 透過這種分層設計，確保：
 
 1. Firebase API 變更時，不影響 UI（只需修改 `ViewModel`）
 2. UI 層的可維護性與可測試性更高（不直接處理 Firebase JSON）
 3. 提高數據的可用性、靈活性與高效性
 */



// MARK: - (v)

import Foundation
import FirebaseFirestoreSwift


// MARK: - Category

/// `Category` 用於表示飲品的最頂層分類（如「咖啡飲品」、「茶類飲品」）。
///
/// - 使用場景
///   - `MenuViewController`：用於展示不同的飲品類別（主分類）。
///   - `MenuDrinkCategoryViewModel`：作為視圖模型的數據來源。
///
/// - 屬性說明
///   - `id`：分類的唯一識別符（來自 Firebase `DocumentID`）。
///   - `title`：分類名稱（如「咖啡飲品」）。
///   - `imageUrl`：分類對應的圖片 URL，供 UI 顯示。
///   - `subtitle`：分類的英文名稱。
struct Category: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var imageUrl: URL
    var subtitle: String
}


// MARK: - Subcategory

/// `Subcategory` 用於表示某個 `Category` 下的子分類。
///
/// - 使用場景
///   - `DrinkSubCategoryViewController`：用於顯示某個飲品分類下的子分類資訊。
///
/// - 屬性說明
///   - `id`：子分類的唯一識別符（來自 Firebase `DocumentID`）。
///   - `title`：子分類的名稱（如「熱濃縮咖啡」）。
struct Subcategory: Codable, Identifiable {
    @DocumentID var id: String?      
    var title: String
}


// MARK: - SubcategoryDrinks

/// `SubcategoryDrinks` 用於表示特定子類別及其對應的飲品列表。
///
/// - 使用場景
///   - `DrinkSubCategoryViewController`：用於展示某個子類別的所有飲品。
///
/// - 屬性說明
///   - `subcategory`：子類別資訊（`Subcategory`）。
///   - `drinks`：該子類別下所有的飲品清單（`Drink`）。
struct SubcategoryDrinks {
    var subcategory: Subcategory
    var drinks: [Drink]
}


// MARK: - Drink

/// `Drink` 用於表示具體的飲品（如「可可瑪奇朵」）。
///
/// - 使用場景
///   - `DrinkSubCategoryViewController`：用於展示某個子類別下的飲品清單。
///   - `DrinkDetailViewController`：用於顯示單個飲品的詳細資訊。
///
/// - 屬性說明
///   - `id`：飲品的唯一識別符（來自 Firebase `DocumentID`）。
///   - `name`：飲品名稱（如「可可瑪奇朵」）。
///   - `subName`：飲品的英文名稱（如「Cocoa Macchiato」）。
///   - `description`：飲品的詳細描述。
///   - `imageUrl`：飲品的圖片 URL，供 UI 顯示。
///   - `sizes`：飲品不同尺寸的詳細資訊（字典結構）。
///   - `prepTime`：準備時間（單位：分鐘）。
struct Drink: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var subName: String
    var description: String
    var imageUrl: URL
    var sizes: [String: SizeInfo]
    var prepTime: Int
}


// MARK: - SizeInfo

/// `SizeInfo` 用於表示飲品的不同尺寸（如「Medium」、「Large」）。
///
/// - 使用場景
///   - `DrinkDetailViewController`：用於顯示不同尺寸的價格、熱量等資訊。
///
/// - 屬性說明
///   - `price`：價格（單位：元）。
///   - `caffeine`：咖啡因含量（單位：毫克）。
///   - `calories`：熱量（單位：大卡）。
///   - `sugar`：糖分含量（單位：克）。
struct SizeInfo: Codable, Hashable {
    var price: Int
    var caffeine: Int
    var calories: Int
    var sugar: Double
}
