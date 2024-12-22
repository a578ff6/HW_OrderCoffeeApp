//
//  FavoritesViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//

// MARK: - 想法
/**
 
 -  透過 FavoritesViewController 練習 UICollectionViewDiffableDataSource，即使資料變動較少，藉此可以熟悉 DiffableDataSource 的運作方式。

 1.使用 UICollectionViewDiffableDataSource 可以有效地處理資料的新增和刪除。
 2.因為 DiffableDataSource 會自動處理資料變動的動畫效果。這種方法對於將來處理更複雜的資料結構或需要進行批量更新的情況也很有幫助。
 3.所以利用這個機會來熟悉 DiffableDataSource，即便需求相對簡單。這將提升對於 UICollectionView 和資料更新的掌握度。
 */


// MARK: - `loadFavorites` 筆記(v)
/**
 
 ## `loadFavorites` 筆記

 `* What`

 `loadFavorites` 是一個負責非同步加載使用者收藏清單的核心方法，執行以下功能：
 
 1. 從 `favoriteManager` 獲取收藏清單資料。
 2. 根據清單是否為空，動態更新背景提示視圖（顯示「沒有收藏」提示或隱藏背景）。
 3. 使用 `FavoritesHandler` 更新 `UICollectionView` 的內容，確保清單顯示最新資料。

 --------------------

 `* Why``

 `1. 非同步資料更新：`
 
    - 收藏清單是從遠端（ `Firebase`）獲取的，資料可能發生變動，因此需要動態更新顯示內容。
    - 確保使用者看到的清單是最新的收藏狀態。

 `2. 提升使用者體驗：`
 
    - 當收藏清單為空時，顯示「沒有收藏」的背景提示，避免讓使用者看到空白畫面。
    - 當有資料時，移除提示背景，並顯示收藏清單的內容。

 `3. 單一職責、易於維護：`
 
    - 使用 `NoFavoritesViewManager` 處理背景提示顯示邏輯，專注於背景的狀態管理。
    - 使用 `FavoritesHandler` 負責 `UICollectionView` 的資料管理和顯示邏輯，確保資料與 UI 分離。

 --------------------

 `* How `

 `1. 非同步獲取收藏清單：`
 
    ```swift
    let favorites = await favoriteManager.fetchFavorites() ?? []
    ```
 
    - 呼叫 `favoriteManager.fetchFavorites` 從後端獲取資料。
    - 使用 `?? []`，當獲取失敗時，將 `favorites` 指派為空陣列，避免程式崩潰。

 ----
 
` 2. 更新背景提示視圖：`
 
    ```swift
    noFavoritesViewManager?.updateBackgroundView(isEmpty: favorites.isEmpty)
    ```
 
    - 判斷 `favorites.isEmpty`：
      - `true`：收藏清單為空，顯示「沒有收藏」提示，禁用滑動。
      - `false`：收藏清單有內容，移除背景提示，啟用滑動。

 ----

 `3. 更新 UICollectionView 的內容*`
 
    ```swift
    favoritesHandler?.updateSnapshot(with: favorites)
    ```
 
    - 呼叫 `FavoritesHandler` 的 `updateSnapshot` 方法：
      - 將 `favorites` 資料分組和排序。
      - 更新 `UICollectionView` 的快照，刷新顯示內容。

 --------------------

 `* 處理邏輯的完整步驟`

 `1. 初始化 favorites：`
 
    - 從遠端獲取資料，如果失敗則設為空陣列。

 `2. 更新背景提示視圖：`
 
    - 如果清單為空，顯示背景提示；否則移除提示背景。

 `3. 更新清單內容：`
 
    - 傳遞資料給 `FavoritesHandler`，更新 `UICollectionView` 的顯示內容。

 --------------------

 `* 處理邏輯的重點設計`

 `1. 容錯性：`
 
    - 使用 `?? []`，即使資料獲取失敗，也能穩定運行。

 `2. UI 與資料同步：`
 
    - 動態調整背景提示和清單內容，確保顯示與資料狀態一致。

 `3. 模組化設計：`
 
    - `NoFavoritesViewManager` 專注處理背景提示。
    - `FavoritesHandler` 專注管理清單資料和顯示。

 --------------------

 `* 範例程式碼整合`

 ```swift
 private func loadFavorites() {
     Task {
         // 1. 獲取收藏清單資料
         let favorites = await favoriteManager.fetchFavorites() ?? []
         
         // 2. 更新背景提示視圖
         noFavoritesViewManager?.updateBackgroundView(isEmpty: favorites.isEmpty)
         
         // 3. 更新清單內容
         favoritesHandler?.updateSnapshot(with: favorites)
     }
 }
 ```
 */


// MARK: - FavoritesViewController 筆記(v)
/**
 
 ## FavoritesViewController 筆記

 - https://reurl.cc/6dGbxk （  iOS 14 的 Diffable Data Source　讓你輕鬆建立和更新大量資料 ）
 
 `* What `
 
 - `FavoritesViewController` 是用來管理「我的最愛」頁面的主要控制器，負責以下功能：
 
 1.  從 Firebase Firestore 加載使用者的收藏飲品清單。
 2.  動態更新收藏飲品列表，並按分類顯示在 `UICollectionView` 中。
 3. 支持用戶`刪除收藏`及`點選進入飲品詳細頁`。
 4. 當沒有收藏飲品時，顯示「沒有收藏」的提示背景。
 5. 初次進入頁面時顯示 HUD 提示加載進度。

 ------------------

 `* Why`

` 1. 為什麼需要 FavoritesViewController？`
 
 - 集中處理「我的最愛」頁面的邏輯與展示，實現 單一責任原則，讓其他頁面能專注於自身的功能。
 - 提供收藏功能的完整體驗，包括：
   - 收藏飲品的顯示與管理。
   - 快速進入飲品詳細頁查看資訊。
   - 當沒有收藏飲品時，顯示友好的提示訊息。
 
 `2. 為什麼要設計「沒有收藏」提示？`
 
 - 當收藏清單為空時，避免使用者看到空白頁，提供更好的視覺回饋。
 - 讓使用者了解目前沒有資料可展示，並誘導他們探索飲品。

 `3. 為什麼要使用 UICollectionView 顯示收藏清單？`
 
 - `UICollectionView` 支持動態資料的分區（`Section`）展示，適合按照飲品分類顯示收藏。
 - 支援拖曳重排、刪除等互動操作，提升使用體驗。（`只處理刪除`）

 `4. 為什麼使用 categoryId、subcategoryId 和 drinkId？`
 
 - `categoryId` 和 `subcategoryId` 提供飲品的分類與次分類，幫助快速定位飲品在 Firestore 的位置。
 - `drinkId` 作為每個飲品的唯一標識，方便直接查詢與操作。
 
 `5. 為什麼需要 HUD 加載提示？`
 
 - 當用戶首次進入頁面時，HUD 明確告知數據正在加載，提升用戶體驗。
 - 與 `loadFavorites` 方法結合，確保加載完成後自動隱藏 HUD，避免干擾操作。

 ------------------

 `* How`

 `1. 結構與屬性設計`
 
 - `主要視圖（favoritesView）`：
 
   - 使用自定義的 `FavoritesView`，其中包含 `UICollectionView`，作為「我的最愛」頁面的主要 UI。

 - `資料處理器（favoritesHandler）`：
 
   - 使用 `FavoritesHandler` 管理 `UICollectionView` 的資料來源（`dataSource`）與互動邏輯（`delegate`）。
   - 負責處理飲品的顯示、分類，以及收藏的刪除與點選行為。

 - `提示視圖管理器（noFavoritesViewManager）`：
 
   - 使用 `NoFavoritesViewManager` 負責當收藏清單為空時顯示背景提示，否則隱藏提示。
   - 提升程式的模組化與可讀性，避免將提示視圖的邏輯直接寫在控制器內。

 - `資料管理器（favoriteManager）`：
 
   - `FavoriteManager` 負責與 Firestore 交互，從後端加載收藏飲品資料，並提供刪除收藏的功能。

 2`. 方法設計`
 
 - `收藏清單加載（loadFavorites）`
 
   - 使用 `Task` 從 Firestore 非同步獲取使用者的收藏飲品。
   - 如果清單為空，調用 `noFavoritesViewManager?.updateBackgroundView(isEmpty: true)` 顯示「沒有收藏」提示。
   - 否則更新 `UICollectionView` 的資料來源，並隱藏背景提示。

 - `viewWillAppear`

    -  每次頁面顯示時刷新數據，確保收藏清單與後端狀態同步。
 
 - `導航至飲品詳細頁（navigateToDrinkDetail）`
 
   - 根據使用者點選的收藏飲品，傳遞 `categoryId`、`subcategoryId` 和 `drinkId` 到 `DrinkDetailViewController`，以加載對應的飲品詳細資訊。

 - `刪除收藏（didDeleteFavoriteDrink）`
   - 使用 `favoriteManager.removeFavorite` 從 Firestore 刪除指定飲品的收藏狀態，刪除完成後重新加載收藏清單。

 `3. UI 行為設計`
 
 - `當清單為空時：`
 
   - 顯示「沒有收藏」的背景提示，並禁用 `UICollectionView` 的滾動。

 - `當有收藏飲品時：`
 
   - 動態加載資料，並以分類為基礎呈現在 `UICollectionView` 中。

 ------------------

 `* 設計理念`

 `1. 單一責任原則`
 
 - `FavoritesViewController` 只專注於控制頁面邏輯，將細節邏輯（如資料處理與背景提示管理）分配給 `FavoritesHandler` 和 `NoFavoritesViewManager` 等模組。

 `2. 高內聚低耦合`
 
 - 將背景提示視圖邏輯封裝在 `NoFavoritesViewManager`，減少控制器的臃腫。
 - 使用 `FavoritesHandler` 專注於 `UICollectionView` 的資料管理，避免控制器直接處理資料更新細節。

 ` 3. 使用者友好設計`
 
 - 提供「沒有收藏」提示視圖，避免空白頁。
 - 點選收藏後導航至詳細頁，提升使用者探索飲品的體驗。

 ------------------

 `* 未來擴展（可能）`

 `1. 加入排序功能`
    - 支持按照收藏時間或飲品名稱排序清單。

 `2. 加入搜尋功能`
    - 支持在收藏飲品中進行快速搜尋。

 `3. 多樣化的分類展示`
    - 支持更多飲品分類層級，或自定義分類邏輯（如按熱銷排序）。
 */

// MARK: - 處理分類邏輯。(v)


import UIKit

// `FavoritesViewController`
///
/// 此控制器負責顯示使用者收藏的飲品清單，並管理相關的交互邏輯與數據更新。
///
/// ### 功能：
/// 1. 顯示收藏飲品清單，支持按分類呈現。
/// 2. 當收藏清單為空時，顯示提示背景視圖。
/// 3. 支持用戶刪除收藏和點選查看飲品詳細資訊。
/// 4. 實時同步收藏狀態，確保跨頁面狀態更新。
/// 5. 通過 Firebase 從 Firestore 獲取收藏數據，並動態更新 UI。
///
/// ### 設計目標：
/// - 分離關注點：將數據加載、UI 更新、與交互邏輯分離到各自的模塊中，提升代碼可讀性與維護性。
/// - 提升用戶體驗：通過 `HUDManager` 提供加載指示，並避免重複顯示或隱藏 HUD。
/// - 優化性能：在 `viewWillAppear` 中進行數據刷新，確保 UI 與數據同步。
class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 用於從 Firestore 獲取使用者收藏清單的資料管理器。
    private let favoriteManager = FavoriteManager.shared
    
    /// 自定義的主要視圖，包含 `UICollectionView`。
    private let favoritesView = FavoritesView()
    
    /// 負責管理 `UICollectionView` 資料來源與互動邏輯的處理器。
    private var favoritesHandler: FavoritesHandler?
    
    /// 負責顯示或隱藏「沒有收藏」提示背景視圖的管理器。
    private var noFavoritesViewManager: NoFavoritesViewManager?
    
    /// 負責管理導航欄樣式與按鈕的管理器。
    private var navigationBarManager: FavoritesNavigationBarManager?
    
    
    // MARK: - Lifecycle Methods
    
    /// 加載自定義的主視圖。
    override func loadView() {
        view = favoritesView
    }
    
    /// 設置頁面功能，包括導航欄、收藏清單及背景提示視圖。
    ///
    /// 初次進入頁面時顯示加載指示 (HUD)，並設置相關 UI 元件與數據管理器。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupCollectionView()
        setupNoFavoritesViewManager()
        HUDManager.shared.showLoading(text: "Loading Favorites...")     // 初次進入時顯示 HUD
    }
    
    /// 當頁面即將顯示時觸發，負責刷新收藏數據並更新 UI。
    ///
    /// 使用 `viewWillAppear` 確保每次頁面切換回來時，數據都保持同步。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    // MARK: - Setup Methods
    
    /// 設置導航欄樣式與標題。
    private func configureNavigationBar() {
        navigationBarManager = FavoritesNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        navigationBarManager?.configureNavigationBarTitle(title: "My Favorite", prefersLargeTitles: true)
    }
    
    /// 配置 `UICollectionView` 及其處理器。
    ///
    /// 通過 `FavoritesHandler` 處理收藏清單的資料與交互邏輯。
    private func setupCollectionView() {
        favoritesHandler = FavoritesHandler(collectionView: favoritesView.favoritesCollectionView, favoritesHandlerDelegate: self)
        favoritesView.favoritesCollectionView.delegate = favoritesHandler
    }
    
    /// 初始化 `NoFavoritesViewManager`，負責管理「沒有收藏」提示背景。
    private func setupNoFavoritesViewManager() {
        noFavoritesViewManager = NoFavoritesViewManager(collectionView: favoritesView.favoritesCollectionView)
    }
    
    // MARK: - Data Loading
    
    /// 從 Firestore 加載收藏飲品，並動態更新 UI。
    ///
    /// 功能：
    /// 1. 加載收藏數據，並更新至 UI。
    /// 2. 當清單為空時，顯示提示背景；否則更新清單。
    /// 3. 控制 HUD 的顯示與隱藏。
    private func loadFavorites() {
        Task {
            let favorites = await favoriteManager.fetchFavorites() ?? []
            noFavoritesViewManager?.updateBackgroundView(isEmpty: favorites.isEmpty)
            favoritesHandler?.updateSnapshot(with: favorites)
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Navigator
    
    /// 導航至 `DrinkDetailViewController`，顯示飲品的詳細資訊。
    ///
    /// - Parameter favoriteDrink: 選中的收藏飲品。
    private func navigateToDrinkDetail(with favoriteDrink: FavoriteDrink) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let drinkDetailVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController else {
            print("Error: 無法找到 DrinkDetailViewController")
            return
        }
        
        drinkDetailVC.categoryId = favoriteDrink.categoryId
        drinkDetailVC.subcategoryId = favoriteDrink.subcategoryId
        drinkDetailVC.drinkId = favoriteDrink.drinkId
        
        navigationController?.pushViewController(drinkDetailVC, animated: true)
    }
}

// MARK: - FavoritesHandlerDelegate
extension FavoritesViewController: FavoritesHandlerDelegate {
    
    /// 當使用者刪除收藏時觸發。
    ///
    /// - Parameter favoriteDrink: 被刪除的收藏飲品。
    func didDeleteFavoriteDrink(_ favoriteDrink: FavoriteDrink) {
        Task {
            await favoriteManager.removeFavorite(for: favoriteDrink)
            loadFavorites()
        }
    }
    
    /// 當使用者選擇某個收藏飲品時觸發，導航至飲品詳細頁面。
    ///
    /// - Parameter favoriteDrink: 被選中的收藏飲品。
    func didSelectFavoriteDrink(_ favoriteDrink: FavoriteDrink) {
        navigateToDrinkDetail(with: favoriteDrink)
    }
    
}
