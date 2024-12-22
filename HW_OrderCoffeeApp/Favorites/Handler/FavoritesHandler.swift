//
//  FavoritesHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//


// MARK: - 筆記：收藏清單分組與排序（重要）
/**
 
 ## 筆記：收藏清單分組與排序

 `* What`
 
 `1.收藏清單的分組與排序目標：`
 
   - 將使用者的收藏飲品清單根據 `subcategoryId` 進行分組。
   - 每個分組內的飲品根據 `timestamp`（添加時間）升序排序。
   - 確保分組結果的順序穩定，按照 `subcategoryId` 的字典順序排列。

 ---

 `* Why`
 
 `1. 分組需求：`
 
 - 目的：使用 `subcategoryId` 分類飲品，方便在 UI 層中清晰顯示。
 - 原因：每個分組（`subcategoryId`）代表一種飲品系列，分組顯示能提升用戶體驗和視覺清晰度。

 `2. 時間排序需求：`
 
 - 目的： 確保每個分組內的飲品按用戶收藏時間先後排列。
 - 原因： 使用 `timestamp` 升序排列能準確反映用戶收藏的先後順序。

 `3. 分組順序穩定需求：`
 
 - 目的： 確保分組本身有序，例如按照 `subcategoryId` 的字典順序排列分組。
 - 原因： Dictionary 的鍵值是無序的，因此需要在分組結果生成時明確進行排序，避免不穩定的鍵值順序影響用戶體驗。

 ---

 `* How`

 `- 測試案例`
 
    - `CocoaMacchiato：HotEspresso, 2024年12月14日 22:37`
    - `BrewedCoffee：Brewed Coffee, 2024年12月14日 22:40`
    - `Flat White：HotEspresso, 2024年12月14日 22:42`
 
 ------
 
 `1. 從 Firestore 獲取收藏清單（已按時間排序）：`
 
 - 在 `FavoritesRepository` 的 `getFavorites` 使用 `Firestore` 提供的查詢功能，按 `timestamp` 升序返回數據：
 
   ```swift
   let favoritesCollectionRef = Firestore.firestore()
       .collection("users")
       .document(userId)
       .collection("favorites")
       .order(by: "timestamp", descending: false) // 按添加時間升序排列
   ```
 
 - 結果：返回的數據按 `timestamp` 排序，確保順序正確。
 - 獲取的數據按照時間先後順序進入數組，打印的順序如下：
 
 ```
 CocoaMacchiato -> BrewedCoffee -> Flat White
```

 ---

 `2. 分組邏輯實現：`
 
 - 使用 `subcategoryId` 進行分組：
 
   ```swift
   var grouped: [String: [FavoriteDrink]] = [:]
   favorites.forEach { grouped[$0.subcategoryId, default: []].append($0) }
   ```

 - 確保每個分組內的飲品保持 Firestore 提供的時間順序（無需再次排序）。
 - 分組後的結果為 Dictionary，且分組內的數據順序仍保持時間排序：
 
 ```
 "DailySpecialsCoffeeSeries": [BrewedCoffee]
 "HotEspresso": [CocoaMacchiato, Flat White]
```

 ---

 `3. 對分組結果進行排序：`
 
 - 將分組結果（Dictionary）轉換為有序數組，按 `subcategoryId` 的字典順序排列：
 
   ```swift
   let groupedFavorites = grouped.sorted { $0.key < $1.key }
   ```

 - 排序後的分組結果:
 - `DailySpecialsCoffeeSeries` 排在前面，`HotEspresso` 排在後面，分組鍵值已按字典順序排序。
 - 每個分組內的飲品數據仍然保持了時間排序，符合預期。
 
 ```
 [(key: "DailySpecialsCoffeeSeries", value: [BrewedCoffee]),
  (key: "HotEspresso", value: [CocoaMacchiato, Flat White])]
 ```
 
 ---

` 4. 打印調試驗證分組與排序邏輯：`
 
 ```swift
 func updateSnapshot(with favorites: [FavoriteDrink]) {
     // 1. 分組邏輯
     var grouped: [String: [FavoriteDrink]] = [:]
     favorites.forEach { grouped[$0.subcategoryId, default: []].append($0) }

     // 2. 排序分組結果
     let groupedFavorites = grouped.sorted { $0.key < $1.key }

     // 3. 判斷是否空清單
     let isEmpty = groupedFavorites.allSatisfy { $0.value.isEmpty }
     updateBackgroundViewIfNeeded(isEmpty)

     // 4. 更新快照
     var snapshot = NSDiffableDataSourceSnapshot<Section, FavoriteDrink>()
     groupedFavorites.forEach { (subcategory, drinks) in
         snapshot.appendSections([.subcategory(subcategory)])
         snapshot.appendItems(drinks, toSection: .subcategory(subcategory))
     }
     dataSource.apply(snapshot, animatingDifferences: true)
 }
 ```

 ---

 `5. 關鍵確認點`
 
 1. Firestore 返回數據是否按時間排序？
    - 已通過 `.order(by: "timestamp", descending: false)` 確保。
 
 2. 分組邏輯是否正確保留了時間順序？
    - 分組時順序未變，確認鍵值穩定即可。
 
 3. 分組後的結果是否穩定排序？
    - 使用 `.sorted { $0.key < $1.key }` 排序。
 */


// MARK: - updateSnapshot` 筆記（重要）
/**
 
 ## `updateSnapshot` 筆記

 `* What`
 
 - `updateSnapshot` 是用來更新 `FavoritesHandler` 的 `UICollectionView` 資料顯示的方法。
 - 透過 `Diffable DataSource` 技術管理資料來源，並根據收藏飲品清單自動生成分組和動畫效果。
 - 此方法的主要目的是：
   1. 按飲品的 `subcategoryId` 分組。
   2. 更新資料快照 (Snapshot) 並應用到 `UICollectionView`。

 --------------------

 `* Why`

 `1. 提高效能：`
 
 - Diffable DataSource 提供了更高效的資料更新方式：
   - 自動計算新增、刪除、修改的差異。
   - 減少不必要的整體重繪，僅更新需要變動的部分。
   - 內建動畫效果，提升用戶體驗。

 `2. 確保資料的組織性：`
 
 - 將收藏的飲品按 `subcategoryId` 分組，能清楚展現飲品分類結構。
 - 用戶能快速定位特定分類下的飲品。

 `3. 符合 MVC 架構：`
 
 - 集中處理資料更新邏輯，讓 `FavoritesHandler` 專注於管理 UI 和交互。
 - 減少 `FavoritesViewController` 的責任分散，實現清晰的職責分工。

 --------------------

 `* How`

 `1. 分組資料：
 `
 - 使用 `subcategoryId` 將 `FavoriteDrink` 飲品清單分組。
 - 透過字典將屬於相同 `subcategoryId` 的飲品收集起來。

 ```swift
 var grouped: [String: [FavoriteDrink]] = [:]
 favorites.forEach { grouped[$0.subcategoryId, default: []].append($0) }
 ```

 `2. 排序分組：`
 
 - 根據 `subcategoryId` 進行排序，確保分組展示順序一致。

 ```swift
 let groupedFavorites = grouped.sorted { $0.key < $1.key }
 ```

 `3. 構建資料快照：`
 
 - 將分組結果轉換為 `DiffableDataSource` 的 `NSDiffableDataSourceSnapshot` 結構，並依序新增分區和項目。

 ```swift
 var snapshot = NSDiffableDataSourceSnapshot<Section, FavoriteDrink>()
 groupedFavorites.forEach { (subcategory, drinks) in
     snapshot.appendSections([.subcategory(subcategory)])
     snapshot.appendItems(drinks, toSection: .subcategory(subcategory))
 }
 ```

 `4. 應用快照：`
 
 - 將生成的快照應用到 `UICollectionView`，完成資料更新。

 ```swift
 dataSource.apply(snapshot, animatingDifferences: true)
 ```

 --------------------

 `* 設計理念`

 `1. 動態性與效率並存：`
 
 - `分組邏輯`是動態生成的，無需額外的靜態配置。
 - 使用 `Diffable DataSource` 簡化資料變更處理，避免手動執行 `reloadData()`。

 `2. 符合分層原則：`
 
 - `updateSnapshot` 負責資料層處理，與 UI 層互相分離，讓 `UICollectionView` 只專注於顯示。

 --------------------

` * 完整流程概述`

 `1. 接收新資料：`
    - 方法被調用時，傳入一個包含所有收藏飲品的陣列 `favorites`。

 `2. 資料分組：`
    - 按 `subcategoryId` 分類並生成分組結果。

 `3. 生成快照：`
    - 以分組結果建立 `Snapshot`，每個分區對應一個 `subcategoryId`，每個項目對應 `FavoriteDrink`。

 `4. 應用快照：`
    - 將快照應用到 `UICollectionView`，完成資料更新和 UI 刷新。

 --------------------

 `* 適用場景`
 
 - 收藏飲品的數量或分類可能動態變化時。
 - 用戶需要即時刪除、修改或新增收藏飲品，並更新到 UI。
 - 需要顯示按分類分組的飲品清單，並保持高效的更新性能和視覺效果。
 */


// MARK: - FavoritesHandler 筆記（重要）
/**
 
 ## FavoritesHandler 筆記

 `* What`

 - `FavoritesHandler` 是一個專門處理 `FavoritesViewController` 中 `UICollectionView` 的類別。
 - 負責以下功能：
 
   `1. 資料來源 (DataSource)：`
       - 使用 `UICollectionViewDiffableDataSource` 動態更新清單資料。
       - 按飲品的 **`subcategoryId`** 分組並展示收藏清單。
 
   `2. 用戶互動 (Delegate)：`
       - 支援點選項目和刪除收藏的交互邏輯。
 
   `3. 分區標題：`
       - 根據收藏飲品的分類，顯示不同的分區標題。

 ---

 `* Why`

 `1. 責任分離：`
 
    - 將 `UICollectionView` 的邏輯從 `FavoritesViewController` 分離，確保 ViewController 專注於業務邏輯，而非處理細節。
    
 `2. 清晰的分區顯示：`
 
    - 使用 `分區 (Section)` 將收藏飲品按子類別分類，提升用戶在大規模收藏清單中的瀏覽體驗。

 `3. 更好的性能與體驗：`
 
    - 使用 `UICollectionViewDiffableDataSource`，確保在更新收藏資料時具備動畫過渡效果，提供更流暢的用戶體驗。

 `4. 可擴展性：`
 
    - 結構設計支持未來添加更多交互功能，例如拖動排序或多選刪除。

 ---

 `* How`

 `1. 資料來源 (DataSource) 配置：`
 
    - 使用 `UICollectionViewDiffableDataSource`，按 `Section` 和 `FavoriteDrink` 定義資料模型。
    - 提供 Cell 配置邏輯 (`FavoriteDrinkCell`)，根據收藏飲品資料顯示內容。

 `2. 分區標題 (Section Headers)：`
 
    - 配置分區標題的 `supplementaryViewProvider`，顯示每個子類別名稱作為標題。

 `3. 資料快照更新 (Snapshot Updates)：`
 
    - 將收藏飲品按 `subcategoryId` 分組。
    - 使用快照更新，確保資料更新具備平滑過渡動畫。

 `4. 用戶互動邏輯：`
 
    - `點選項目 (didSelectItemAt)：`
      - 點選收藏飲品時觸發縮放動畫並通知 `FavoritesViewController`。
 
    - `右鍵選單 (Context Menu)：`
      - 提供刪除功能，刪除後通知 `FavoritesViewController` 更新收藏清單。

 `5. 擴展性設計：`
    - 通過委託模式 (`FavoritesHandlerDelegate`) 將交互事件回傳給 `FavoritesViewController`，確保主控制器保持靈活性。

 ---

 `* 設計理念`

 `1. 分層結構：`
 
    - `FavoritesHandler` 集中處理 `UICollectionView` 的邏輯，避免 `FavoritesViewController` 過於臃腫，符合單一責任原則。

 `2. 動態數據處理：`
    - 使用 `UICollectionViewDiffableDataSource` 和快照管理，確保資料更新流暢且高效。

 `3. 客製化與靈活性：`
    - 將事件（如刪除、選取）通過 `委託模式` 回傳，支持主控制器根據需求執行不同操作。

 `4. 簡單易擴展：`
    - 配置分區標題與 Cell 的邏輯獨立，支持未來添加更多樣式或功能（如自定義分區外觀）。
 */


// MARK: -  (v)

import UIKit

/// `FavoritesHandler`
///
/// 此類負責管理 `FavoritesViewController` 中的 `UICollectionView`，處理以下功能：
///
/// - 管理收藏清單的資料來源 (`dataSource`) 和用戶互動 (`delegate`)。
/// - 將收藏的飲品按子類別 (`subcategory`) 分組並顯示在不同的區域 (`section`) 中。
/// - 提供選擇飲品、刪除收藏等交互功能。
/// - 使用 `UICollectionViewDiffableDataSource` 確保資料更新具有平滑的動畫效果。
///
/// - 使用情境：
///   - 需要根據飲品分類分組展示收藏清單。
///   - 用戶可以刪除收藏飲品或點選查看飲品詳細資訊。
class FavoritesHandler: NSObject {
    
    // MARK: - Properties
    
    /// 被管理的 `UICollectionView`
    var collectionView: UICollectionView
    
    /// `UICollectionView` 的資料來源，使用 `Section` 和 FavoriteDrink 處理不同的資料
    var dataSource: UICollectionViewDiffableDataSource<Section, FavoriteDrink>!
    
    /// 委託對象，處理`刪除`或`選取收藏飲品`的回調
    weak var favoritesHandlerDelegate: FavoritesHandlerDelegate?
    
    // MARK: - Section
    
    /// 定義收藏清單的分區，根據子類別 (`subcategory`) 分組
    ///
    /// - 使用 `subcategory` 的名稱作為 `Section` 的 key，便於將同一子類別的飲品顯示在同一區塊。
    enum Section: Hashable {
        case subcategory(String)
    }
    
    // MARK: - Initializer
    
    /// 初始化
    ///
    /// - Parameters:
    ///   - collectionView: 被管理的 `UICollectionView`。
    ///   - favoritesHandlerDelegate: 處理刪除和選取回調的委託對象。
    init(collectionView: UICollectionView, favoritesHandlerDelegate: FavoritesHandlerDelegate) {
        self.collectionView = collectionView
        self.favoritesHandlerDelegate = favoritesHandlerDelegate
        super.init()
        configureDataSource()
        configureSectionHeaders()
    }
    
    // MARK: - DataSource Setup
    
    /// 配置 `UICollectionView` 的資料來源
    ///
    /// - 說明：
    ///   - 使用 `UICollectionViewDiffableDataSource` 提供靈活且平滑的資料更新效果。
    ///   - 根據每個 `Section` 和 `FavoriteDrink` 顯示對應的 Cell。
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, FavoriteDrink>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, favoriteDrink: FavoriteDrink) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteDrinkCell.reuseIdentifier, for: indexPath) as? FavoriteDrinkCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: favoriteDrink)  // 配置 Cell 顯示的飲品資料
            return cell
        }
    }
    /// 配置 `UICollectionView` 的分區 `Header`
    ///
    /// - 說明：
    ///   - 使用 `UICollectionViewDiffableDataSource` 的 `supplementaryViewProvider` 配置分區標題。
    ///   - 分區標題顯示每個子類別的名稱。
    private func configureSectionHeaders() {
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FavoritesDrinkHeaderView.reuseIdentifier, for: indexPath) as? FavoritesDrinkHeaderView else {
                return nil
            }
            
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            if case let .subcategory(subcategoryTitle) = section {
                headerView.configure(with: subcategoryTitle)
            }
            
            return headerView
        }
    }
    
    // MARK: - Snapshot Updates
    
    /// 更新收藏清單的資料快照
    ///
    /// - Parameters:
    ///   - favorites: 收藏的飲品清單
    /// - 說明：
    ///   - 將飲品按子類別分組，並生成對應的分區與項目快照。
    ///   - 使用 `UICollectionViewDiffableDataSource` 平滑更新資料。
    func updateSnapshot(with favorites: [FavoriteDrink]) {
        
        // 1. 分組邏輯
        var grouped: [String: [FavoriteDrink]] = [:]
        favorites.forEach { grouped[$0.subcategoryId, default: []].append($0) }
        
        print("分組前的數據: \(favorites)")
        print("分組後的數據: \(grouped)")
        
        // 2. 排序 subcategoryId 分組結果
        let groupedFavorites = grouped.sorted { $0.key < $1.key }
        print("排序後的分組結果: \(groupedFavorites)")
        
        // 3. 更新快照
        var snapshot = NSDiffableDataSourceSnapshot<Section, FavoriteDrink>()
        groupedFavorites.forEach { (subcategory, drinks) in
            snapshot.appendSections([.subcategory(subcategory)])
            snapshot.appendItems(drinks, toSection: .subcategory(subcategory))
        }
        // 4. 應用快照
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - UICollectionViewDelegate
extension FavoritesHandler: UICollectionViewDelegate {
    
    /// 配置每個項目的 Context Menu（右鍵選單）
    ///
    /// - 提供刪除功能
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let favoriteDrink = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "刪除", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.favoritesHandlerDelegate?.didDeleteFavoriteDrink(favoriteDrink)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
    
    /// 當使用者選取某項收藏飲品時觸發
    ///
    /// - Parameters:
    ///   - collectionView: 當前的 UICollectionView
    ///   - indexPath: 被選取項目的索引路徑
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let favoriteDrink = dataSource.itemIdentifier(for: indexPath),
              let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        // 添加縮放動畫，點擊後通知委託對象
        cell.addScaleAnimation(duration: 0.15, scale: 0.85) {
            self.favoritesHandlerDelegate?.didSelectFavoriteDrink(favoriteDrink)
        }
    }
    
}
