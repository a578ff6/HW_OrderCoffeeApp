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
 2.切換收藏狀態：根據當前收藏狀態執行新增或移除操作，並返回結果供其他模組（如 FavoriteStateCoordinator）進一步處理。
 3.數據交互封裝：與 FavoriteManager 協作，將 Firebase 的數據操作集中處理。
 
 ---------------

` * Why`
 
 `1.分離關注點：`

 - 將後端交互邏輯與 UI 狀態更新分離，`DrinkDetailFavoritesHandler` 僅關注後端收藏狀態的操作，避免與控制器或其他模組直接耦合。
 
 `2.提升模組化程度：`

 - 作為 `FavoriteStateCoordinator` 的依賴，專注處理與收藏數據有關的業務邏輯，並通過明確的接口與其他模組通信。

` 3.降低耦合：`

 - 數據交互由 `FavoriteManager` 處理。
 - `控制器`和 `FavoriteStateCoordinator` 僅調用 `DrinkDetailFavoritesHandler` 提供的方法，無需直接操作 Firebase 的邏輯。
 
 `4.增強可測試性與可維護性：`

 - 由於該模組僅專注於業務邏輯，可單獨測試 Firebase 相關的操作，方便維護和擴展。

 ---------------

 `* How`
 
 `1. 設置依賴：`
 
 - `DrinkDetailFavoritesHandler` 依賴 `FavoriteManager` 進行 `Firebase` 數據交互。
 - 作為 `FavoriteStateCoordinator` 的後端邏輯層，為其提供簡單的接口如 `isFavorite(drinkId:) `和 `toggleFavorite(for:)。`

 `2. 核心方法：`
 
 - `isFavorite(drinkId:)：` 檢查指定飲品是否在收藏列表中，供上層模組進一步處理。
 - `toggleFavorite(for:)：` 根據當前收藏狀態執行新增或移除操作，並返回更新後的狀態。
 
 `3. 內部封裝：`
 
 - `addFavorite(drink:)：` 新增收藏記錄。
 - `removeFavorite(drinkId:)：` 刪除收藏記錄。
 - `FavoriteManager 協作：` 負責與 Firebase 的交互，DrinkDetailFavoritesHandler 僅封裝業務邏輯。
 
 `4. 與 FavoriteStateCoordinator 的協作`
 
 - `FavoriteStateCoordinator` 通過調用 `DrinkDetailFavoritesHandler`，處理收藏狀態的檢查和切換，並負責 UI 更新。
 
 `5. 異步處理：`
 
 - 使用 `async/await` 保證收藏操作與狀態更新能在非阻塞的情況下完成。

 ---------------

 `* 實現架構圖`

 ```
 [DrinkDetailViewController]
        |
        v
 [FavoriteStateCoordinator]
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

 - `DrinkDetailFavoritesHandler` 專注於後端邏輯，UI 狀態的更新完全交由 `FavoriteStateCoordinator` 或控制器處理。
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
