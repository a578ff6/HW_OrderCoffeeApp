//
//  DrinkDetailFavoritesHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/20.
//

// MARK: - DrinkDetailFavoritesHandler 筆記
/**
 
 ## DrinkDetailFavoritesHandler 筆記

 `* What`

 - `DrinkDetailFavoritesHandler` 是一個專門處理飲品收藏邏輯的業務管理器，與 UI 完全解耦。

 - 負責以下功能：

 1.檢查收藏狀態：檢查指定飲品是否已被收藏。
 2.切換收藏狀態：根據當前收藏狀態執行新增或移除操作，並返回結果供控制器更新 UI。
 3.數據交互封裝：與 FavoriteManager 協作，將 Firebase 的數據操作集中處理。
 
 ---------------

` * Why`
 
 `1.分離關注點：`

 - 集中處理收藏邏輯，避免 `DrinkDetailViewController` 承擔過多責任。
 - 提升代碼的模組化程度，方便維護和擴展。
 
 `2.提升可讀性與重用性：`

 - 將收藏功能獨立為通用業務邏輯類別，可重用於其他功能或頁面。
 
` 3.降低耦合：`

 - 控制器只需負責調用方法並根據結果更新 UI，數據交互由 `FavoriteManager` 處理。
 
 `4.優化用戶體驗：`

 - 提供異步操作支持，確保收藏狀態即時更新，避免阻塞主線程。

 ---------------

 `* How`
 
 `1. 設置依賴：`
 
 - 通過 `FavoriteManager` 處理與 Firebase 的數據交互。
 - 提供控制器接口，如 `isFavorite(drinkId:) `和 `toggleFavorite(for:)`。

 `2. 核心方法：`
 
 - `isFavorite(drinkId:)：` 檢查指定飲品是否已收藏，供控制器更新 UI。
 - `toggleFavorite(for:)：` 根據當前收藏狀態執行新增或移除操作，並返回新的收藏狀態。
 
 `3. 內部封裝：`
 
 - `addFavorite(drink:)：` 新增收藏記錄。
 - `removeFavorite(drinkId:)：` 刪除收藏記錄。
 - `FavoriteManager 協作：` 負責與 Firebase 的交互，DrinkDetailFavoritesHandler 僅封裝業務邏輯。
 
 `4. 異步處理：`
 
    - 使用 `async/await` 保證收藏操作與狀態更新能在非阻塞的情況下完成。

 ---------------

 `* 實現架構圖`

 ```
 [DrinkDetailViewController]
           |
           v
 [DrinkDetailFavoritesHandler]
           |
      [FavoriteManager]
           |
  [Firebase Firestore]

 ```

 ---------------

 `* 注意事項`

 1`.責任分工：`

 - `DrinkDetailFavoritesHandler` 僅處理業務邏輯，不負責 UI 操作。
 - `FavoriteManager` 集中管理 `Firebase` 數據交互，保證數據一致性。
 
 `2.狀態更新與回饋：`

 - 收藏操作完成後，需由控制器根據結果更新 UI，例如更新收藏按鈕圖示。
 
 `3.模組化設計：`

 - 該管理器僅為詳情頁服務，其他頁面需建立對應的收藏邏輯處理器。
 */



// MARK: - 重構職責

import UIKit

/// `DrinkDetailFavoritesHandler`
///
/// ### 職責
/// `DrinkDetailFavoritesHandler` 負責處理飲品收藏（「我的最愛」）的相關業務邏輯，專注於數據處理和後端交互，與 UI 無關。
///
/// ### 功能說明
/// 1. 收藏狀態檢查：
///    - 檢查指定飲品是否已收藏，並返回結果以供控制器更新 UI。
/// 2. 切換收藏狀態：
///    - 根據當前收藏狀態執行「新增收藏」或「移除收藏」，並返回新的收藏狀態。
/// 3. 封裝與後端交互：
///    - 負責與 `FavoriteManager` 通信以執行具體的收藏操作（如新增、移除）。
///
/// ### 設計目標
/// - 清晰的職責分離：
///   - `DrinkDetailFavoritesHandler` 專注於業務邏輯處理，不直接處理 UI 更新，將這部分責任交由控制器。
///
/// ### 使用情境
/// - 由控制器（ `DrinkDetailViewController`）調用，用於檢查收藏狀態或切換收藏狀態，並根據返回結果更新 UI。
class DrinkDetailFavoritesHandler {
    
    // MARK: - Dependencies
    
    /// 處理與後端交互的管理器
    private let favoriteManager = FavoriteManager.shared
    
    // MARK: - Public Methods
    
    /// 檢查飲品是否已收藏
    ///
    /// 通過後端數據檢查指定飲品是否在「我的最愛」列表中。
    ///
    /// - Parameter drinkId: 飲品的唯一識別碼
    /// - Returns: 收藏狀態（`true` 表示已收藏）
    func isFavorite(drinkId: String) async -> Bool {
        guard let favorites = await favoriteManager.fetchFavorites() else { return false }
        return favorites.contains { $0.drinkId == drinkId }
    }
    
    /// 切換飲品的收藏狀態
    ///
    /// 根據當前收藏狀態執行新增或移除操作，並返回新的收藏狀態。
    ///
    /// - Parameter drink: 飲品數據模型
    /// - Returns: 新的收藏狀態（`true` 表示已收藏）
    func toggleFavorite(for drink: FavoriteDrink) async -> Bool {
        let isCurrentlyFavorite = await isFavorite(drinkId: drink.drinkId)
        if isCurrentlyFavorite {
            await removeFavorite(drinkId: drink.drinkId)
        } else {
            await addFavorite(drink: drink)
        }
        return !isCurrentlyFavorite
    }
    
    // MARK: - Private Methods
    
    /// 添加飲品至「我的最愛」
    ///
    /// 調用 `FavoriteManager` 添加指定飲品至 Firestore 的收藏列表。
    /// - Parameter drink: 飲品的數據模型
    private func addFavorite(drink: FavoriteDrink) async {
        await favoriteManager.addFavorite(favoriteDrink: drink)
    }
    
    /// 從「我的最愛」中移除指定飲品
    ///
    /// 調用 `FavoriteManager` 從 Firestore 中刪除指定飲品。
    /// - Parameter drinkId: 飲品的唯一識別碼
    private func removeFavorite(drinkId: String) async {
        guard let favorites = await favoriteManager.fetchFavorites(),
              let favorite = favorites.first(where: { $0.drinkId == drinkId }) else { return }
        await favoriteManager.removeFavorite(for: favorite)
    }
    
}
