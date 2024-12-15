//
//  FavoritesHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//

/*
 ## 「收藏功能」與「刪除邏輯」總結
 
 1. FavoritesViewController 與 Drink 的使用（ 對於在FavoritesViewController刪除位於清單中的最愛飲品 ）：
 
    * 顯示 Cell 的方式：
        - FavoritesViewController 中使用 Drink 來顯示每個 Cell，是因為從 FavoriteDrink 中提取的基本 ID 資訊（categoryId、subcategoryId、drinkId）僅用於查找對應的完整 Drink 資料。
        - 使用 fetchDrinks(for:) 根據這些 ID 加載飲品資料後，UI 能夠直接顯示 Drink 的名稱、圖片和描述等資訊。

    * 刪除邏輯的處理：
        - 當用戶刪除收藏的飲品時，UI 層使用 Drink，但實際上刪除的是 Firebase 中的 FavoriteDrink。
 
 2. 刪除功能的詳細步驟：

    * FavoritesHandler 中的刪除邏輯：
        - 在 collectionView(_:contextMenuConfigurationForItemAt:point:) 中設置 context menu，當選擇「刪除」時觸發刪除邏輯。
        - handleDelete(drink:at:) 負責將選中的 Drink 從畫面中移除，並通過 FavoriteManager.shared.removeFavorite(for:) 刪除 Firebase 中的收藏記錄。

    * FavoriteManager 的移除邏輯：
        - removeFavorite(for:) 方法負責從 Firebase 刪除指定的 Drink，並同步更新 favorites 列表和 Firebase 中的資料。
        - refreshUserDetails() 會更新最新的使用者資料，確保資料同步到 UI，避免不一致的情況。
 
 3. NoFavoritesView 的新增與使用：

    * NoFavoritesView 的背景顯示邏輯：
        - 當收藏飲品清單為空時，FavoritesHandler 中會將 NoFavoritesView 設為 collectionView.backgroundView，顯示「目前沒有我的最愛」的提示訊息。
        - 當有收藏飲品時，背景視圖會被移除，直接顯示飲品的 Cell。

    * NoFavoritesView 不需要註冊或重用：
        - NoFavoritesView 是一個靜態背景視圖，並不屬於 UICollectionView 的 Cell，因此不需要註冊到 FavoritesView。
        - 由於它不會像 UICollectionViewCell 那樣被重複使用，所以也不需要實作 prepareForReuse。
 
 4. 背景顯示邏輯的重點解釋：
 
    * 將 updateBackgroundViewIfNeeded 放在 updateSnapshot
        - 負責處理視圖的背景更新，與 snapshot 的資料更新是獨立的。
        - 可以在快照更新前進行背景的處理，不影響後續的資料更新操作。
        - 背景視圖的顯示或移除不會依賴 snapshot 的更新，所以即使將背景處理放在一開始，仍然可以正常運作。

 5. 關鍵因素
 
    * UICollectionViewDiffableDataSource：
        - 使用 DiffableDataSource 管理資料，使得刪除操作能夠即時更新快照，並簡化資料源的處理流程。清單資料變化時會同步反映到 UI，包括顯示和隱藏 NoFavoritesView。

    * Firebase 同步與 UI 更新：
        - FavoriteManager 的同步邏輯確保刪除操作在 Firebase 中即時反映，並通過 async/await 保持資料操作流暢，確保 UI 與後端資料一致。

 6. 整體架構的因素
    
    * 清楚分離了資料層與顯示層。FavoriteDrink 僅儲存必要的 ID 資訊，而 Drink 提供完整的顯示資料，這樣避免了冗餘的數據存儲。
    * 使用 loadDrinkById 方法動態加載詳細的 Drink 資料，避免每次都保存完整的飲品資料，提高了效能與靈活性。
    * 刪除邏輯設計合理，FavoritesHandler 和 FavoriteManager 的合作確保了操作的流暢性與一致性。
 
 ------------------------------------------------------------------------------------------------
 
 ## 添加飲品資料到「我的最愛」時，可以根據 subcategory 來設置 section 並做區分 & 依照添加的順序展示（ feature/favorites-page-V7 ）：
 
    * 處理 section header 顯示子類別的名稱：
        - FavoritesHandler 中的 configureSectionHeaders，透過 supplementaryViewProvider 設置 section header。
        - 每個 section 會根據從「子類別名稱」來進行設置，並顯示於畫面的上方。
        - 讓每個子類別的飲品都有各自的 header 進行區分，讓使用者可以根據子類別快速找到飲品。
 
    * 按照收藏的順序更新 UICollectionView
        - 在 updateSnapshot 中，會根據 FavoritesViewController 傳入的有序資料 (String, [Drink]) 來更新 UICollectionView 的顯示內容。
        - 使用者的收藏順序會被保留，且子類別與對應的飲品會按順序加入
 
 */

// MARK: - 使用 push 調整 validateAndLoadUserDetails & 設置 viewWillAppear & 設置通知 & 處理 DrinkDetailViwController
// 使用 NoFavoritesView，並且當在 FavoritesHandler 直接刪除掉最愛飲品項目之後，會立即更新顯示 NoFavoritesView
// 讓每個子類別的飲品都有各自的 header 進行區分，讓使用者可以根據子類別快速找到飲品。
// 收藏順序會被保留，且子類別與對應的飲品會按順序加入
/*
import UIKit

/// `FavoritesHandler` 負責管理 `FavoritesViewController` 中的 UICollectionView 的資料來源 (dataSource) 及使用者互動 (delegate)。
/// 根據收藏的飲品來顯示不同的 Cell，當沒有收藏飲品時會顯示提示訊息。
class FavoritesHandler: NSObject {
    
    // MARK: - Properties
    
    var collectionView: UICollectionView
    
    /// UICollectionView 的資料來源，使用 `Section` 和 `Drink` 來處理不同的資料
    var dataSource: UICollectionViewDiffableDataSource<Section, Drink>!
    
    /// 閉包來處理飲品點擊事件
    var didSelectDrinkHandler: ((Drink) -> Void)?
    
    // MARK: - Section
    
    /// 使用 Section 來對應 UICollectionView 的區域 (section)。
    enum Section: Hashable {
        /// 使用 `subcategory` 的名稱作為 Section 的 key，便於將同一子類別的飲品顯示在同一區塊。
        case subcategory(String)
    }
    
    // MARK: - Initializer
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        configureDataSource()
    }
    
    // MARK: - DataSource Setup
    
    /// 配置 UICollectionView 的 dataSource，根據每個 `Section` 和 `Drink` 顯示對應的 Cell。
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Drink>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, drink: Drink) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteDrinkCell.reuseIdentifier, for: indexPath) as? FavoriteDrinkCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: drink)      // 配置飲品資料
            return cell
        }
        
        configureSectionHeaders()
        applyInitialSnapshot()
    }
    
    /// 設置 `section header` 的 `supplementaryViewProvider`
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
    
    /// 設置初始快照
    ///
    /// 在資料未加載前，避免界面出現意外的空白或錯誤。
    private func applyInitialSnapshot() {
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Drink>()
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Snapshot Updates
    
    /// 根據有序的 `飲品的子類別`進行分類並更新 UICollectionView 的資料快照。
    /// 如果清單為空，顯示 "目前沒有我的最愛" 的背景視圖；
    /// 否則，移除背景視圖並顯示收藏的飲品。
    ///
    /// - Parameter orderedDrinksBySubcategory: 包含 `子類別名稱` 及其對應 `飲品陣列` 的有序資料。
    func updateSnapshot(with orderedDrinksBySubcategory: [(String, [Drink])]) {

        let isEmpty = orderedDrinksBySubcategory.allSatisfy { $0.1.isEmpty }
        updateBackgroundViewIfNeeded(isEmpty)

        var snapshot = NSDiffableDataSourceSnapshot<Section, Drink>()

        // 按照有序陣列順序更新 section 和 drink
        for (subcategory, drinks) in orderedDrinksBySubcategory {
            snapshot.appendSections([.subcategory(subcategory)])                   // 添加 section
            snapshot.appendItems(drinks, toSection: .subcategory(subcategory))     // 為每個 section 添加飲品
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }

}

// MARK: - UICollectionViewDelegate
extension FavoritesHandler: UICollectionViewDelegate {
    
    // MARK: - contextMenuConfigurationForItemAt
    
    /// 負責設置每個項目的 context menu 並提供`「刪除」`選項。
    /// - Parameters:
    ///   - collectionView: 當前的 UICollectionView
    ///   - indexPath: 當前選中的項目的位置
    ///   - point: 使用者長按的具體位置
    /// - Returns: 回傳一個 UIContextMenuConfiguration 來配置選單，或返回 nil 表示沒有選單
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        /// 取得當前項目的飲品資料 (Drink)
        guard let drink = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        // 配置 context menu 並設定「刪除」選項
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let deleteAction = UIAction(title: "刪除", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.handleDelete(drink: drink, at: indexPath)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
        return configuration
    }
    
    /// 處理「刪除」項目的邏輯，當使用者選擇「刪除」時，會從 Firebase 和當前畫面中同步移除該飲品。
    /// - Parameters:
    ///   - drink: 要刪除的飲品物件
    ///   - indexPath: 要刪除的項目的位置
    private func handleDelete(drink: Drink, at indexPath: IndexPath) {
        Task {
            self.removeDrinkFromSnapshot(drink: drink)                       // 更新畫面上的收藏飲品清單
            await FavoriteManager.shared.removeFavorite(for: drink)          // 使用 FavoriteManager 刪除 Firebase 中的收藏
            checkAndShowNoFavoritesView()                                    // 檢查是否顯示「目前沒有我的最愛」
        }
    }
    
    /// 從快照中移除`指定的飲品`並`更新畫面`
    /// - Parameter drink: 要從快照中移除的飲品物件
    private func removeDrinkFromSnapshot(drink: Drink) {
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteItems([drink])
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    // MARK: - No Favorites Handling
    
    /// 檢查並更新是否需要顯示 NoFavoritesView
    private func checkAndShowNoFavoritesView() {
        let snapshot = dataSource.snapshot()
        updateBackgroundViewIfNeeded(snapshot.itemIdentifiers.isEmpty)
    }
    
    /// 根據清單狀態顯示或隱藏 NoFavoritesView
    /// - Parameter isEmpty: 飲品清單是否為空
    private func updateBackgroundViewIfNeeded(_ isEmpty: Bool) {
        DispatchQueue.main.async {
            if isEmpty {
                let noFavoritesView = NoFavoritesView()
                noFavoritesView.frame = self.collectionView.bounds
                self.collectionView.backgroundView = noFavoritesView
                self.collectionView.isScrollEnabled = false
            } else {
                self.collectionView.backgroundView = nil
                self.collectionView.isScrollEnabled = true
            }
        }
    }
    
    // MARK: - didSelectItemAt
    
    /// 當使用者選擇收藏清單中的某個飲品時觸發
    ///
    /// - Parameters:
    ///   - collectionView: 當前的 UICollectionView
    ///   - indexPath: 被選取項目的索引路徑
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let drink = dataSource.itemIdentifier(for: indexPath),
              let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        cell.addScaleAnimation(duration: 0.15, scale: 0.85) {
            // 呼叫閉包將選中的飲品傳遞給 FavoritesViewController，以進行導航
            self.didSelectDrinkHandler?(drink)
        }
    }
    
}
*/

























// MARK: - 暫時

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

 - `FavoritesHandler` 是一個專門處理 **`FavoritesViewController`** 中 **`UICollectionView`** 的類別。
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


// MARK: - 無favorite拆解 (v)

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
