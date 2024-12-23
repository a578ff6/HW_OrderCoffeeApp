//
//  DrinkDetailManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/17.
//

// MARK: - 筆記：DrinkDetailManager 的設計
/**
 
 ## 筆記：DrinkDetailManager 的設計

 `* What：DrinkDetailManager 是什麼`
 
 `DrinkDetailManager` 是一個專門用來處理「飲品詳細頁面」資料邏輯的 `Manager` 類別。
 
 - 用途：負責從 `MenuController` 取得基礎資料 `Drink`，並轉換成適合 UI 使用的 展示模型 `DrinkDetailModel`。
 - 職責：解耦資料請求邏輯與展示邏輯，讓視圖層只需專注於顯示轉換後的資料。

 --------------

 `* Why：為什麼需要 DrinkDetailManager`

 `1. 單一職責原則：`
 
    - `MenuController` 專注於請求基礎資料（從 Firebase 請求 `Drink` 資料）。
    - `DrinkDetailManager` 專注於轉換展示資料，將 `Drink` 基礎模型轉換為 `DrinkDetailModel`。
    - 這樣的設計讓每個類別都有清楚的職責，降低耦合度，方便維護與擴展。

 `2. 解耦視圖與請求邏輯：`
 
    - 視圖層不需要關心資料的請求與轉換邏輯，只需透過 `DrinkDetailManager` 取得處理好的展示模型。
    - 這讓 `DrinkDetailViewController` 更加乾淨，專注於 UI 顯示。

 `3. 維護性高：`
 
    - 如果後端資料結構變更，只需修改 `DrinkDetailManager` 或展示模型邏輯，不會影響視圖層。
    - 便於後續擴展，例如增加新需求或資料處理邏輯時，只需更新 `DrinkDetailManager`。

 --------------

 `* How：DrinkDetailManager 的設計方式`

 `1. 使用 MenuController 提供基礎資料`
 
 `DrinkDetailManager` 透過 `MenuController` 提供的 `loadDrinkById` 方法，獲取基礎模型 `Drink`：
 
 - `MenuController`：負責與 Firebase 溝通，回傳標準化的 `Drink` 基礎資料。
 - `DrinkDetailManager`：接收 `Drink`，並轉換為視圖層需要的 `DrinkDetailModel`。

 `2. 轉換成展示模型 (DrinkDetailModel)`
 
 - `DrinkDetailModel` 是針對「飲品詳細頁面」設計的展示模型，方便視圖直接使用。
 - 在 `fetchDrinkDetail` 方法中，將獲取的 `Drink` 資料轉換為 `DrinkDetailModel`。

 ---

` * 範例使用`

 ```swift
 let manager = DrinkDetailManager()

 Task {
     do {
         let detailModel = try await manager.fetchDrinkDetail(categoryId: "Coffee", subcategoryId: "Specials", drinkId: "BrewedCoffee")
         print("飲品名稱：\(detailModel.name)")
         print("尺寸選項：\(detailModel.sortedSizes)")
     } catch {
         print("發生錯誤：\(error.localizedDescription)")
     }
 }
 ```

 --------------

 `* 設計重點`

 `1. 單一責任：`
 
    - `MenuController`：提供 基礎模型，專注於資料請求。
    - `DrinkDetailManager`：轉換 展示模型，專注於邏輯處理。

 `2. 解耦視圖邏輯：`
 
    - 視圖層（如 `DrinkDetailViewController`）不需要處理請求邏輯或資料轉換邏輯，只需呼叫 `DrinkDetailManager` 提供展示模型。

 `3. 易維護與擴展：`
 
    - 當視圖需求變更或後端資料結構更新時，只需調整 `DrinkDetailManager` 或 `DrinkDetailModel`，不影響其他功能。

 --------------

 `* 結論`
 
 `DrinkDetailManager` 是負責「飲品詳細頁面」的邏輯處理類別，將資料請求與轉換邏輯集中處理，符單一責任原則，並與 `MenuController` 職責清晰分離。
 */


import UIKit

/// `DrinkDetailManager` 負責處理「飲品詳細頁面」的資料邏輯，
/// 包括請求基礎資料並轉換成展示模型 `DrinkDetailModel`，提供給視圖層使用。
class DrinkDetailManager {
    
    /// 透過單例模式取得 `MenuController`，用於請求基礎資料
    private let menuController = MenuController.shared
    
    // MARK: - Public Methods
    
    /// 非同步方法：從 `MenuController` 請求飲品詳細資料並轉換為展示模型
    ///
    /// - Parameters:
    ///   - categoryId: 飲品所屬的類別 ID
    ///   - subcategoryId: 飲品所屬的子類別 ID
    ///   - drinkId: 飲品的唯一 ID
    ///
    /// - Returns: `DrinkDetailModel` 展示模型，適合視圖層使用
    /// - Throws: 當資料請求失敗時，拋出錯誤
    ///
    /// - 轉換邏輯：
    ///   1. 透過 `MenuController` 的 `loadDrinkById` 方法請求 `Drink` 資料。
    ///   2. 將 `Drink` 基礎模型轉換為展示模型 `DrinkDetailModel`。
    func fetchDrinkDetail(categoryId: String, subcategoryId: String, drinkId: String) async throws -> DrinkDetailModel {
        
        // 請求基礎模型資料
        let drink = try await menuController.loadDrinkById(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
        
        // 轉換成展示模型
        return DrinkDetailModel(drink: drink)
    }
    
}
