//
//  FavoriteManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/13.
//

// MARK: - FavoriteManager 筆記

/**
 ## FavoriteManager 筆記

 `* What`

 - `FavoriteManager` 是業務邏輯層，用於處理「我的最愛」的功能邏輯。
 - 它與資料層 `FavoritesRepository` 交互，提供高層次的 API 供 UI 層使用，例如獲取、添加與刪除收藏飲品。

 ------------------------
 
 `* Why`

 `1. 分離關注點`
    - 將業務邏輯從 UI 層分離，減少 UI 層的代碼複雜度。
    - 通過依賴資料層，實現清晰的邏輯分層，提高代碼的可維護性。
 
 `2. 簡化操作`
    - 為 UI 提供簡單的方法，如 `fetchFavorites`、`addFavorite` 和 `removeFavorite`，隱藏 Firestore 的具體實現。
 
 `3. 集中管理依賴`
    - 使用單例模式保證全局只有一個 `FavoriteManager` 實例，方便統一管理「我的最愛」功能。
 
 `4. 可擴展性`
    - 如果需要新增功能（例如檢查某飲品是否被收藏），可以輕鬆擴展而不影響現有代碼。

 ------------------------

 `* How`

 `1. 單例模式`
    - 使用 `static let shared` 實現單例，保證唯一實例。
 
 `2. 高層 API`
    - 提供 `fetchFavorites`、`addFavorite` 和 `removeFavorite` 等簡單方法供 UI 層使用。
 
 `3. 依賴注入`
    - 通過 `FavoritesRepository` 處理與 Firebase 的交互，將資料存取的責任下放至資料層，業務層只需關注邏輯處理。

 ------------------------

 `* 使用情境`

 - `addFavorite`:
   - 在 `DrinkDetailFavoritesHandler` 中被使用，用於添加收藏邏輯。
   - 通過 `toggleFavorite` 方法調用，根據當前狀態執行添加收藏操作。
 
 - `removeFavorite`:
   - 同樣在 `DrinkDetailFavoritesHandler` 中被使用，通過 `toggleFavorite` 方法切換收藏狀態。
   - 直接從 Firebase 刪除收藏數據。
 
 - `fetchFavorites`:
   - 用於初始化收藏狀態檢查，或更新按鈕狀態時使用。

 ------------------------

 `* 不同場景的使用`

 - `DrinkDetail`
   - 通過 `DrinkDetailFavoritesHandler` 間接調用 `addFavorite` 和 `removeFavorite`。
   - 用於用戶在飲品詳情頁添加或移除收藏的功能。
 
 - `Favorites`
   - 用於管理收藏清單的顯示和刪除。
   - 通過獨立的功能模塊調用 `removeFavorite` 處理刪除操作。
 */


// MARK: - (v)

import UIKit
import Firebase

/// 管理使用者的「我的最愛」業務邏輯
/// - 負責與 `FavoritesRepository` 交互，處理與 Firestore 的數據操作。
/// - 提供獲取、添加與刪除「我的最愛」功能，並對接 UI 層的需求。
///
/// ### 功能清單：
/// 1. 獲取我的最愛清單：
///    - 從 Firebase Firestore 獲取使用者的收藏資料。
///    - 支援異步操作，並自動處理數據錯誤。
/// 2. 新增收藏：
///    - 新增飲品至 Firestore 的收藏集合中，並記錄時間戳。
/// 3. 移除收藏：
///    - 從 Firestore 的收藏集合中移除指定飲品資料。
///
/// 注意事項:
/// - 依賴 `FavoritesRepository` 作為資料層，所有的 Firestore 操作集中在資料層處理。
/// - 包裝高層邏輯，提供簡單易用的方法給 UI 層使用。
class FavoriteManager {
    
    // MARK: - Singleton Instance
    
    /// 提供單例實例，保證全局只有一個 `FavoriteManager`
    static let shared = FavoriteManager()
    
    private init() {}
    
    // MARK: - Dependencies
    
    /// 注入資料層依賴，處理 Firestore 的數據交互
    private let repository = FavoritesRepository()
    
    // MARK: - Public Methods
    
    /// 獲取使用者的「我的最愛」清單
    /// - Returns: 包含使用者「我的最愛」飲品的陣列，如果獲取失敗返回 nil。
    func fetchFavorites() async -> [FavoriteDrink]? {
        guard let userId = getCurrentUserId() else { return nil }
        
        do {
            let favorites = try await repository.getFavorites(for: userId)
            return favorites
        } catch {
            print("獲取最愛清單失敗：\(error)")
            return nil
        }
    }
    
    /// 移除飲品的「我的最愛」狀態
    /// - Parameter favoriteDrink: 要移除的飲品數據。
    func removeFavorite(for favoriteDrink: FavoriteDrink) async {
        guard let userId = getCurrentUserId() else { return }
        
        let favoriteDocRef = Firestore.firestore().collection("users").document(userId).collection("favorites").document(favoriteDrink.drinkId)
        
        do {
            print("正在刪除收藏: \(favoriteDrink.drinkId)")
            try await favoriteDocRef.delete()
            print("成功移除收藏: \(favoriteDrink.name)")
        } catch {
            print("移除收藏失敗: \(error.localizedDescription)")
        }
    }
    
    /// 新增飲品至「我的最愛」
    /// - Parameter favoriteDrink: 欲收藏的飲品數據。
    /// - 注意：使用 Firestore 的 `setData` 方法，支援自動覆蓋資料。
    func addFavorite(favoriteDrink: FavoriteDrink) async {
        guard let userId = getCurrentUserId() else { return }
        
        let favoriteDocRef = Firestore.firestore().collection("users").document(userId).collection("favorites").document(favoriteDrink.drinkId)
        
        do {
            try await favoriteDocRef.setData([
                "categoryId": favoriteDrink.categoryId,
                "subcategoryId": favoriteDrink.subcategoryId,
                "drinkId": favoriteDrink.drinkId,
                "name": favoriteDrink.name,
                "subName": favoriteDrink.subName,
                "imageUrlString": favoriteDrink.imageUrlString,
                "timestamp": Timestamp(date: favoriteDrink.timestamp)
            ])
            print("成功添加到我的最愛: \(favoriteDrink.name)")
        } catch {
            print("添加到我的最愛失敗: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// 獲取當前使用者 ID
    /// - Returns: 當前登入使用者的 ID，如果未登入返回 nil。
    private func getCurrentUserId() -> String? {
        guard let user = Auth.auth().currentUser else {
            print("Error: 未登入使用者")
            return nil
        }
        return user.uid
    }
    
}
