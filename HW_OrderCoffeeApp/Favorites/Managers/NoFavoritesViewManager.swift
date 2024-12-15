//
//  NoFavoritesViewManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/15.
//

// MARK: - NoFavoritesViewManager 筆記
/**

 ## NoFavoritesViewManager 筆記

 `* What`
 
 - `功能`：
 
   - `NoFavoritesViewManager` 負責管理 `UICollectionView` 的背景視圖，當收藏清單為空時顯示 `NoFavoritesView`，提供視覺提示。
   - 使用 `updateBackgroundView(isEmpty:)` 方法更新 `NoFavoritesView` 的顯示狀態。

 --------------
 
 `* Why`
 
 - `設計目的`：
 
   - `提高使用者體驗`：當收藏清單為空時，讓使用者清楚知道目前無內容展示。
   - `分離職責`：透過專門的 Manager 處理背景視圖邏輯，避免將背景視圖邏輯與資料處理或 UI 行為耦合。
   - `維護性高`：當未來需要修改背景提示視圖或邏輯時，只需調整此 Manager 的程式碼，減少對其他類別的影響。

 --------------

 `* How`
 
 `1. 初始化：`
 
    - 在需要顯示「沒有收藏」提示的 ViewController 中，將 `UICollectionView` 傳入 `NoFavoritesViewManager` 的初始化器。
    - 例如：
 
      ```swift
      noFavoritesViewManager = NoFavoritesViewManager(collectionView: favoritesCollectionView)
      ```

 ----
 
 `2. 更新背景視圖狀態：`
 
    - 使用 `updateBackgroundView(isEmpty:)` 方法，根據收藏清單的狀態顯示或隱藏背景提示視圖。
    - 範例：
 
      - 如果清單為空：
        ```swift
        noFavoritesViewManager?.updateBackgroundView(isEmpty: true)
        ```
      - 如果有清單內容：
        ```swift
        noFavoritesViewManager?.updateBackgroundView(isEmpty: false)
        ```
 
 ----

 `3. 顯示背景提示視圖的行為：`
 
    - 當 `isEmpty` 為 `true` 時：
      - 創建一個 `NoFavoritesView`。
      - 將其設為 `UICollectionView` 的 `backgroundView`。
      - 禁用 `UICollectionView` 的滑動功能 (`isScrollEnabled = false`)。
 
    - 當 `isEmpty` 為 `false` 時：
      - 清除 `backgroundView`。
      - 恢復 `UICollectionView` 的滑動功能 (`isScrollEnabled = true`)。

 --------------

` * 應用場景`
 
 - 在收藏頁面 (`FavoritesViewController`) 加載收藏資料後，根據資料內容更新背景提示：
 
   ```swift
 private func loadFavorites() {
     Task {
         let favorites = await favoriteManager.fetchFavorites() ?? []
         noFavoritesViewManager?.updateBackgroundView(isEmpty: favorites.isEmpty)
         handler?.updateSnapshot(with: favorites)
     }
 }
   ```

 --------------

 `* 總結`
 
 - 使用 `NoFavoritesViewManager`是高內聚、低耦合的設計，將背景視圖邏輯獨立出來，提高程式碼的可讀性與可維護性。
 - 透過 `updateBackgroundView` 方法簡化背景狀態管理，讓 `FavoritesViewController` 和 `FavoritesHandler` 的職責更加專注。
 */


// MARK: - (v)

import UIKit

/// `NoFavoritesViewManager`
///
/// 專門負責管理 UICollectionView 的「沒有收藏」提示視圖 (`NoFavoritesView`) 的顯示與隱藏。
///
/// - 當收藏清單為空時，顯示背景提示視圖，讓使用者了解目前沒有資料可供展示。
/// - 當有收藏清單時，移除背景提示視圖並恢復正常的 CollectionView 滑動行為。
class NoFavoritesViewManager {
    
    // MARK: - Properties
    
    /// 被管理的 UICollectionView，`NoFavoritesView` 將設置為它的 backgroundView。
    private weak var collectionView: UICollectionView?
    
    // MARK: - Initializer
    
    /// 初始化
    /// - Parameter collectionView: 需要顯示或隱藏背景視圖的 UICollectionView。
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    // MARK: - Methods
    
    /// 根據清單是否為空來顯示或隱藏背景提示視圖
    ///
    /// - Parameter isEmpty: Boolean 值，表示收藏清單是否為空。
    ///   - 若為 `true`，顯示背景提示視圖並禁用滑動。
    ///   - 若為 `false`，隱藏背景提示視圖並啟用滑動。
    func updateBackgroundView(isEmpty: Bool) {
        guard let collectionView = collectionView else { return }
        
        if isEmpty {
            let noFavoritesView = NoFavoritesView()
            noFavoritesView.frame = collectionView.bounds
            collectionView.backgroundView = noFavoritesView
            collectionView.isScrollEnabled = false
        } else {
            collectionView.backgroundView = nil
            collectionView.isScrollEnabled = true
        }
    }
    
}
