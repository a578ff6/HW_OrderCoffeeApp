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
