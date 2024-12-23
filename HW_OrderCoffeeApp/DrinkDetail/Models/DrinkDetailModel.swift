//
//  DrinkDetailModel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/17.
//


// MARK: - 筆記：DrinkDetailModel 的設計
/**
 
 ## 筆記：DrinkDetailModel 的設計

 `* What：DrinkDetailModel 是什麼`
 
 `DrinkDetailModel` 是一個專為「飲品詳細頁面」設計的 展示模型（View Model）。
 
 - 用途：將 `Drink` 基礎模型中的資料轉換為適合 UI 顯示的格式，提供給 `DrinkDetailViewController` 使用。
 - 結構：包含飲品的基本資訊、圖片、準備時間，以及已排序的飲品尺寸和尺寸詳細資訊。

 -----------------------------

 `* Why：為什麼需要 DrinkDetailModel`
 
 在「飲品詳細頁面」中，直接使用 Firebase 回傳的 `Drink` 基礎模型會帶來以下問題：

 `1. 資料過於複雜：`
 
    - 基礎模型 `Drink` 是從 Firebase 取得的原始資料，包含所有欄位。
    - 視圖不需要使用全部欄位，直接使用會增加視圖的負擔。

 `2. 視圖邏輯分散：`
 
    - 如果視圖直接處理資料排序、轉換邏輯，代碼會變得複雜且難以維護。

 `3. 單一責任原則：`
 
    - `DrinkDetailModel` 專注於轉換和封裝資料，將資料邏輯與視圖邏輯分離，讓 `DrinkDetailViewController` 只需專注於 UI 展示。

 -----------------------------

` * How：DrinkDetailModel 的設計方式`

` 1. Properties（屬性）`
 
 - `name`：飲品名稱。
 - `subName`: 副標題名稱
 - `description`：飲品描述，簡要說明飲品特性。
 - `imageUrl`：飲品圖片的網址，用於顯示飲品圖像。
 - `prepTime`：準備時間（`Int`），單位為分鐘，提供給後端或其他邏輯計算。
 - `sortedSizes`：已排序的飲品尺寸（例如 Small、Medium、Large），方便在 UI 上顯示尺寸選項。
 - `sizeDetails`：飲品各尺寸的詳細資訊，包括價格、熱量、咖啡因和糖分，方便提供給 UI 使用。

 -----------------------------

 `2. sizeInfo(for size: String) 方法`
 
 - 功能：根據指定尺寸名稱（如 "Medium"）快速檢索該尺寸對應的詳細資訊 SizeInfo。
 - 設計理由：封裝尺寸檢索邏輯，避免視圖層直接訪問 sizeDetails，保證數據的準確性與一致性。
 
 -----------------------------
 
 `3. Initializer（初始化邏輯）`
 
 `init(drink: Drink)`：
 - 輸入：`Drink` 基礎模型，該模型直接對應 Firebase 的資料結構。
 - 邏輯：
    - `name`、`description` 和 `imageUrl`：直接從 `Drink` 中取值。
    - `prepTime`：保留原始準備時間（數值型態 `Int`）。
    - `sortedSizes`：透過 `keys.sorted()` 將尺寸的 key（如 Small、Medium）排序，方便 UI 顯示。
    - `sizeDetails`：直接保留 `sizes` 的詳細資訊。

 ```swift
 init(drink: Drink) {
     self.name = drink.name
     self.description = drink.description
     self.imageUrl = drink.imageUrl
     self.prepTime = drink.prepTime
     self.sortedSizes = drink.sizes.keys.sorted()
     self.sizeDetails = drink.sizes
 }
 ```

 -----------------------------

 `* 範例`
 
  `Drink` 基礎模型如下：
 ```json
 {
   "name": "每日精選咖啡",
   "subName": "Brewed Coffee"
   "description": "精心挑選來自不同產區的咖啡",
   "imageUrl": "https://example.com/coffee.jpg",
   "prepTime": 3,
   "sizes": {
     "Small": { "price": 75, "caffeine": 252, "calories": 14, "sugar": 0.2 },
     "Medium": { "price": 85, "caffeine": 375, "calories": 23, "sugar": 0.2 }
   }
 }
 ```

 透過 `DrinkDetailModel` 轉換後：
 ```swift
 let drinkDetailModel = DrinkDetailModel(drink: drink)

 print(drinkDetailModel.name) // "每日精選咖啡"
 print(drinkDetailModel.subName)
 print(drinkDetailModel.sortedSizes) // ["Medium", "Small"]
 print(drinkDetailModel.sizeDetails) // 包含尺寸的詳細資料
 ```

 -----------------------------

` * 結論`
 
 `DrinkDetailModel` 的設計遵循 **單一責任原則**，解決了視圖層直接使用基礎模型的問題。
 
 - What：專門針對「飲品詳細頁面」的展示模型。
 - Why：解耦資料邏輯與視圖邏輯，降低視圖負擔並提高可維護性。
 - How：透過轉換 `Drink` 基礎模型，提供經過排序和封裝的資料，讓視圖更容易使用。

 */


// MARK: - 在 `DrinkDetailModel` 中設置 `sizeInfo(for size: String)` 方法
/**
 
 ## 在 `DrinkDetailModel` 中設置 `sizeInfo(for size: String)` 方法

 ---

 `* What：`

 - 在 `DrinkDetailModel` 中添加 `sizeInfo(for:)` 是因為 `DrinkDetailModel` 的主要責任是提供整理後的飲品數據供視圖層使用，包括尺寸與價格的詳細資訊。
 - 目前程式設計中，`sizeInfo(for:)` 被放置於 `DrinkDetailModel` 並直接提供非可選型別的 `SizeInfo`，能確保業務邏輯的完整性和資料的一致性。

 --------------------

 `* Why：`

` 1. 責任分層清晰`
 
 `DrinkDetailModel` 是用於展示的模型，應包含與飲品相關的完整資訊，並提供一個清晰的接口供上層訪問：
 
 - 模型的責任：處理數據並保證數據的完整性。
 - 視圖的責任：專注於 UI 的呈現和用戶交互。

 通過在 `DrinkDetailModel` 中處理 `sizeInfo(for:)`，避免將模型的細節暴露給視圖層或處理邏輯層，從而確保責任劃分明確。

 `2. 減少重複的防禦性檢查`
 
 如果將 `sizeInfo(for:)` 的處理邏輯分散到其他位置，例如 `DrinkDetailHandler` 或 `DrinkDetailViewController`，會導致以下問題：
 - 每次需要訪問尺寸資訊時，都需檢查該尺寸是否存在於 `sizeDetails`。
 - 增加不必要的重複代碼，影響可讀性與維護性。

 將檢查邏輯集中於 `DrinkDetailModel`，可以減少這些重複檢查。

 `3. 強化業務邏輯的穩定性`
 
 使用 `fatalError` 處理無法找到尺寸資訊的情況是合理的設計，因為這是一個應該在開發或測試階段暴露的問題。任何資料錯誤都應在資料初始化或加載階段解決，而不是在 UI 或邏輯層處理。

 --------------------

 `* How：`

 `1. 方法實現（DrinkDetailModel 中的 sizeInfo）`
 
 ```swift
 struct DrinkDetailModel {
     // 已省略其他屬性與方法...

     /// 獲取指定尺寸的詳細資訊
     /// - Parameter size: 尺寸名稱（如 "Medium", "Large"）
     /// - Returns: 該尺寸對應的 `SizeInfo`
     func sizeInfo(for size: String) -> SizeInfo {
         guard let sizeInfo = sizeDetails[size] else {
             fatalError("無法找到對應尺寸的資訊：\(size)")
         }
         return sizeInfo
     }
 }
 ```

` 2. 在 DrinkDetailHandler 使用`
 
 - 更新 `cellForItemAt` 方法中的 `priceInfo` 配置：

 ```swift
 case .priceInfo:
     guard let cell = collectionView.dequeueReusableCell(
         withReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier,
         for: indexPath
     ) as? DrinkPriceInfoCollectionViewCell else {
         fatalError("Cannot dequeue DrinkPriceInfoCollectionViewCell")
     }

     // 使用 DrinkDetailModel 提供的 sizeInfo(for:) 方法
     let sizeInfo = drinkDetailModel.sizeInfo(for: selectedSize)
     cell.configure(with: sizeInfo)
     return cell
 ```

 --------------------

 `* 結論`

 1. 集中邏輯：
 
    - 在模型層集中處理尺寸資訊的檢索邏輯，讓模型以外的部分（例如 `UICollectionView`）專注於其自身責任。

 2. 減少重複：
 
    - 使用集中式檢查避免多處冗餘的防禦性代碼。

 3. 數據保障：
 
    - 保證所有傳遞到視圖層的數據都經過校驗，避免 UI 顯示潛在的錯誤或崩潰。

 4. 易於維護：
 
    - 如果未來需要更新尺寸處理邏輯，只需修改 `DrinkDetailModel` 的 `sizeInfo(for:)` 方法即可，減少影響範圍。

 */



import Foundation

/// `DrinkDetailModel` 是一個展示模型，專門用於「飲品詳細頁面」的資料顯示。
///
/// ### 設計目標
/// - 將基礎模型 `Drink` 轉換為便於 UI 顯示的結構化資料模型。
/// - 提供尺寸排序與詳細資訊的便捷訪問方法，減少視圖層的業務邏輯負擔。
///
/// ### 功能說明
/// - 整合飲品名稱、描述、圖片、尺寸資訊與營養細節。
/// - 提供快速檢索尺寸詳細資訊的接口 `sizeInfo(for:)`，保證數據的準確性與一致性。
///
/// ### 使用情境
/// - 此模型專為 `DrinkDetailViewController` 的顯示需求設計，與基礎模型解耦，方便擴展與維護。
struct DrinkDetailModel {
    
    // MARK: - Properties
    
    /// 飲品名稱，例如「每日精選咖啡」
    let name: String
    
    /// 飲品副標題，例如「Brewed Coffee」
    let subName: String
    
    /// 飲品描述，說明該飲品的特色或風味
    let description: String
    
    /// 飲品圖片的 URL，供視圖顯示圖片
    let imageUrl: URL
    
    /// 飲品的準備時間，單位為分鐘
    let prepTime: Int
    
    /// 已排序的飲品尺寸，例如 ["Small", "Medium", "Large"]
    ///
    /// ### 排序說明
    /// - 此屬性通過 `sizes` 的 keys 排序生成，確保 UI 顯示一致性。
    let sortedSizes: [String]
    
    /// 飲品各尺寸的詳細資訊，包含價格、熱量、咖啡因和糖分等資料
    let sizeDetails: [String: SizeInfo]
    
    // MARK: - Initializer
    
    /// 初始化 `DrinkDetailModel`，將基礎模型 `Drink` 轉換為展示模型
    ///
    /// - Parameter drink: 基礎模型 `Drink`，直接對應 Firebase 資料結構
    ///
    /// - 轉換邏輯：
    ///   - `name`、`subName`、`description`、`imageUrl` 和 `prepTime` 直接取自 `Drink`
    ///   - `sortedSizes`：將 `sizes` 的 keys 進行排序，方便 UI 顯示
    ///   - `sizeDetails`：保留 `sizes` 的所有詳細資訊
    init(drink: Drink) {
        self.name = drink.name
        self.subName = drink.subName
        self.description = drink.description
        self.imageUrl = drink.imageUrl
        self.prepTime = drink.prepTime
        self.sortedSizes = drink.sizes.keys.sorted()
        self.sizeDetails = drink.sizes
    }
    
    /// 獲取指定尺寸的詳細資訊
    ///
    /// ### 功能描述
    /// - 根據尺寸名稱檢索其對應的詳細資訊 `SizeInfo`。
    /// - 若指定尺寸不存在，則觸發程式錯誤，表明資料異常。
    ///
    /// - Parameter size: 尺寸名稱（如 "Medium", "Large"）
    /// - Returns: 該尺寸對應的 `SizeInfo`
    func sizeInfo(for size: String) -> SizeInfo {
        guard let sizeInfo = sizeDetails[size] else {
            fatalError("無法找到對應尺寸的資訊：\(size)")
        }
        return sizeInfo
    }
    
}
