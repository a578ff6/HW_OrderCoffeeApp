//
//  FavoritesHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/14.
//

// MARK: - FavoritesHandlerDelegate 筆記
/**
 
 ## FavoritesHandlerDelegate 筆記

 `* What`

 - `FavoritesHandlerDelegate` 是一個用於定義 `FavoritesHandler`與其委託對象之間通信的` 協議 (Protocol)`。
 - 負責處理 `收藏清單 (Favorites) `中的用戶互動事件回調，包括：
 
   1. `選取收藏飲品` (用於導航到詳細頁)。
   2. `刪除收藏飲品` (用於更新收藏清單數據)。

 --------------

 `* Why`

 `1. 責任分離：`
    - 將 `FavoritesHandler` 的邏輯與用戶交互回調分離，確保 `FavoritesHandler` 專注於管理 `UICollectionView` 的行為，回調邏輯交由其他對象處理。

 `2. 提高靈活性：`
    - 允許 `FavoritesHandler` 的委託對象（如 `FavoritesViewController`）根據具體需求自定義處理方式。

 `3. 便於擴展：`
    - 當新增功能（例如：多選刪除或編輯收藏飲品）時，可以通過拓展協議方法來實現，而不影響現有結構。

 --------------

 `* How`

 `1. 定義協議：`
 
    - 使用 `protocol` 關鍵字定義 `FavoritesHandlerDelegate`。
    - 包含兩個必須實現的方法：
      - `didSelectFavoriteDrink`：當用戶點擊某收藏飲品時觸發，傳遞飲品資料以供後續導航。
      - `didDeleteFavoriteDrink`：當用戶選擇刪除某收藏飲品時觸發，傳遞飲品資料以供後續數據處理。

 `2. 設置弱引用：`
 
    - 在 `FavoritesHandler` 中，使用 `weak var favoritesHandlerDelegate` 設置委託對象，避免強引用循環。

 `3. 回調處理：`
 
    - 當 `UICollectionView` 觸發對應事件時，通過調用委託方法將操作結果傳遞給主控制器進行處理。

 --------------

 `* 範例`

` 1.在 FavoritesHandler 中使用：`

 ```swift
 weak var favoritesHandlerDelegate: FavoritesHandlerDelegate?

 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     guard let favoriteDrink = dataSource.itemIdentifier(for: indexPath) else { return }
     favoritesHandlerDelegate?.didSelectFavoriteDrink(favoriteDrink)
 }

 func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
     guard let favoriteDrink = dataSource.itemIdentifier(for: indexPath) else { return nil }
     return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
         let deleteAction = UIAction(title: "刪除", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
             self.favoritesHandlerDelegate?.didDeleteFavoriteDrink(favoriteDrink)
         }
         return UIMenu(title: "", children: [deleteAction])
     }
 }
 ```

` 2. 在 FavoritesViewController 中實現協議：`

 ```swift
 extension FavoritesViewController: FavoritesHandlerDelegate {
     func didSelectFavoriteDrink(_ favoriteDrink: FavoriteDrink) {
         navigateToDrinkDetail(with: favoriteDrink)
     }
     
     func didDeleteFavoriteDrink(_ favoriteDrink: FavoriteDrink) {
         Task {
             await favoriteManager.removeFavorite(for: favoriteDrink)
             loadFavorites()
         }
     }
 }
 ```

 --------------

 `* 設計理念`

 `1. 單一責任原則：`
    - `FavoritesHandler` 處理 `UICollectionView` 的行為，而具體交互邏輯通過委託交給控制器（或其他類）完成。

 `2. 低耦合高內聚：`
    - `FavoritesHandler` 與 `FavoritesViewController` 通過協議通信，降低兩者的耦合度，提升結構的靈活性和可測試性。

 `3. 擴展性：`
    - 透過協議方法的添加，未來可以輕鬆引入新的用戶交互行為而不改變原有邏輯。
 */


// MARK: - (v)

import Foundation

/// `FavoritesHandlerDelegate` 定義 `FavoritesHandler` 中的事件回調接口
protocol FavoritesHandlerDelegate: AnyObject {
    
    /// 當用戶選擇某個收藏飲品時觸發
    /// - Parameter favoriteDrink: 選中的收藏飲品
    func didSelectFavoriteDrink(_ favoriteDrink: FavoriteDrink)
    
    /// 當用戶刪除某個收藏飲品時觸發
    /// - Parameter favoriteDrink: 要刪除的收藏飲品
    func didDeleteFavoriteDrink(_ favoriteDrink: FavoriteDrink)
}
