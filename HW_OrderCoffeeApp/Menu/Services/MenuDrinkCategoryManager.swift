//
//  MenuDrinkCategoryManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/22.
//

// MARK: - MenuDrinkCategoryManager 筆記
/**
 ## MenuDrinkCategoryManager 筆記

 ---

 `* What `
 
 - `MenuDrinkCategoryManager` 是一個負責菜單相關業務邏輯的管理類別，設計目的是在視圖層（如 `MenuViewController`）與資料層（如 `MenuController`）之間作為中介，執行數據轉換和邏輯處理。

 - 功能：
 
   - 從 `MenuController` 加載原始數據。
   - 轉換數據模型（ `Category`）為適合展示層使用的輕量化結構 `MenuDrinkCategoryViewModel`。
   - 將業務邏輯集中處理，減輕視圖層的負擔。

 - 使用場景：
 
   - 在 `MenuViewController` 中需要顯示飲品分類時，`MenuDrinkCategoryManager` 負責處理數據的加載與轉換，簡化視圖層的邏輯。

 ---

 `* Why`

 1. 隔離視圖層與資料層：
 
    - 透過 `MenuDrinkCategoryManager`，使`MenuViewController` 不需要直接處理資料層的細節，提升模組間的解耦性與可維護性。

 2. 專注於單一責任：
 
    - 視圖層專注於 UI 顯示與用戶互動，而業務邏輯（如數據轉換）集中在 `MenuDrinkCategoryManager`，符合單一職責原則（SRP）。

 3. 提供適合展示的數據結構：
 
    - 資料層返回的模型可能過於龐大或不適合 UI 層使用，通過 `MenuDrinkCategoryViewModel` 提供精簡且專注的數據結構，減少多餘的數據處理。

 4. 提升可測試性：
 
    - `MenuDrinkCategoryManager` 作為單獨的業務邏輯層，易於進行單元測試，確保數據處理的正確性。

 ---

 `* How `

 1. 方法設計：
 
    - 定義 `fetchMenuDrinkCategories` 方法，非同步從 `MenuController` 加載分類數據，並轉換為 `MenuDrinkCategoryViewModel`。

 2. 數據處理邏輯：
 
    - 通過 `map` 方法將資料層的模型（`Category`）轉換為 `MenuDrinkCategoryViewModel`。
    - 在轉換過程中處理可能的數據異常，例如 `id` 的缺失（使用空字串作為預設值）。

 3. 遵循設計原則：
 
    - 單一職責原則（SRP）：`MenuDrinkCategoryManager` 只專注於業務邏輯。
    - 依賴倒置原則（DIP）：視圖層依賴於 `MenuDrinkCategoryManager` 提供的抽象，而非直接依賴資料層。

 ---

 `* 筆記範例`
 
 - What：
 
   `MenuDrinkCategoryManager` 是處理菜單業務邏輯的管理類別，負責從資料層加載分類數據並轉換為展示模型，專注於業務邏輯的封裝。

 - Why：
 
   - 解耦視圖層與資料層，讓視圖層更專注於 UI 顯示。
   - 提供輕量化數據結構，減少 UI 層處理數據的負擔。
   - 符合單一職責與依賴倒置原則，提升程式碼的可讀性與可測試性。

 - How：
 
   - 使用非同步方法 `fetchMenuDrinkCategories` 從資料層加載數據，轉換為 `MenuDrinkCategoryViewModel`。
   - 通過數據處理邏輯（`map`）確保數據符合展示需求，例如處理缺失的 `id`。
 
 */




// MARK: - (v)

import Foundation


/// MenuDrinkCategoryManager 負責處理與菜單相關的業務邏輯。
///
/// - 職責:
///   1. 作為 MenuViewController 與資料層 MenuController 之間的中介，
///      負責轉換資料模型為展示模型，提供更適合 UI 層使用的數據結構。
///   2. 確保菜單分類資料的加載、轉換與處理簡化，專注於展示層所需的核心數據。
///
/// - 功能:
///   1. 從 `MenuController` 加載分類數據，並轉換為 `MenuDrinkCategoryViewModel`。
///   2. 隔離視圖層與資料層，減少直接對資料層的依賴。
///
/// - 使用場景:
///   適用於 Menu 頁面中需要處理飲品分類的業務邏輯，例如:
///   - 加載菜單分類。
///   - 提供展示層使用的數據結構。
///
/// - 設計原則:
///   1. 遵循單一職責原則 (SRP)：專注於菜單業務邏輯處理。
///   2. 符合依賴倒置原則 (DIP)：高層模組（UI 層）依賴於抽象（MenuDrinkCategoryManager），而非資料層（MenuController）。
class MenuDrinkCategoryManager {
    
    /// 負責與 Firestore 進行交互。
    private let menuController = MenuController.shared
    
    // MARK: - Public Methods
    
    /// 負責處理菜單飲品分類相關業務邏輯的管理類別。
    ///
    /// - 功能:
    ///   1. 加載飲品分類數據，並轉換為展示模型 `MenuDrinkCategoryViewModel`。
    ///   2. 作為 UI 層與資料層（`MenuController`）之間的中介，隔離具體資料層實現。
    ///
    /// - 使用場景:
    ///   適用於菜單頁面需要顯示飲品分類的場景。
    ///
    /// - 設計原則:
    ///   1. 遵循單一職責原則 (SRP)：專注於飲品分類業務邏輯處理。
    ///   2. 符合依賴倒置原則 (DIP)：高層模組依賴於此管理類別，而非具體的資料層。
    func fetchMenuDrinkCategories() async throws -> [MenuDrinkCategoryViewModel] {
        let categories = try await menuController.loadCategories()
        return categories.map {
            MenuDrinkCategoryViewModel(
                id: $0.id ?? "",
                title: $0.title,
                imageUrl: $0.imageUrl,
                subtitle: $0.subtitle
            )
        }
    }
    
}
