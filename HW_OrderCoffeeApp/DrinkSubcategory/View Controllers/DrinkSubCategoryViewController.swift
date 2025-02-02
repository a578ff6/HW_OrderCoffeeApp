//
//  DrinkSubCategoryViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/4.
//


// MARK: - reloadData 與 reloadItems(at:) 差異（重要）
/**
 
 ## reloadData 與 reloadItems(at:) 差異

 `* reloadData 方法：`
 
    - 整體刷新： `reloadData` 會刷新 UICollectionView 中的所有數據，不論當前可見的還是不可見的項目。
    - 性能影響： 如果數據量大，`reloadData` 的開銷會比較高，因為它會重新計算和重新繪製所有的 cell，即使這些 cell 可能在當前螢幕畫面上不可見。
    - 動畫丟失： 通常使用 `reloadData` 會丟失當前的過渡動畫，因為它會立即重繪所有項目，不考慮動畫效果。因此，我原先使用 reloadData 來切換佈局時，切換過程中的動畫效果沒有很平滑。
    - 體驗不連貫： 對於像切換佈局這樣的過渡操作，reloadData 會導致用戶感覺頁面突然全部更新，無法平滑過渡。

 ----
 
`* reloadItems(at:) 方法：`
 
    - 局部刷新： `reloadItems(at:)` 只會刷新當前可見的 cell 和指定的 index paths，不會影響不可見的部分。
    - 性能更高： 由於只刷新了可見的項目，對性能的影響較小，能夠有效減少內存和計算資源的消耗，特別是當處理大量數據時。
    - 動畫保留： 使用 `reloadItems(at:) `可以保持過渡動畫，尤其是當切換佈局時，可以讓切換過程變得更加平滑和自然。
    - 更好的用戶體驗： 因為只是局部刷新，過渡更平順，不會讓用戶感到頁面突然閃動或重新加載所有數據。

 ----

 `* 總結：`
 
    - `reloadData`： 適合在數據完全變更的情況下使用，比如需要重新加載完全不同的數據集，或者界面需要完全重繪。缺點是會刷新所有項目，對於較大量數據來說效率較低，動畫效果也不理想。
    - `reloadItems(at:)`： 適合局部更新，比如佈局切換或者某些項目更新的情況。這種方式能夠保留動畫效果，提升用戶體驗，並且對性能影響更小。
 */


// MARK: - 導航標題設置為 `Drink CategoryTitle`
/**
 
 ## 導航標題設置為 `Drink CategoryTitle`

 ---

 `* What`
 
- 在 `DrinkSubCategoryViewController` 中，導航欄標題應設置為 `Drink CategoryTitle`（父分類的標題），而非 `Drink SubcategoryTitle`（子分類的標題）。
- 子分類的標題由 `sectionHeader` 處理。

 ----------

 `* Why`

 1. JSON 資料結構
 
    - `Category` 是主要分類（如 "CoffeeBeverages"），`Subcategory` 是細分的分類（如 "HotEspresso"）。
    - 將父分類作為導航標題，能更好地展示當前分類的背景資訊。

 2. 用戶體驗
 
    - 顯示父分類標題有助於用戶定位當前瀏覽的主要分類範疇，並與導航層級保持一致。
    - 子分類標題已在 `sectionHeader` 中處理，導航欄應該專注於顯示更高層級的資訊。

 3. 設計一致性
 
    - 導航欄：提供場景的背景資訊，負責顯示父分類標題。
    - SectionHeader：提供細化內容，顯示子分類的標題。
    - 遵循單一責任原則，讓每個 UI 元件負責專屬的職責。

 4. 默認值處理
 
    - 若父分類標題無法獲取，可以設置一個默認標題（如 `"Drink Category"`）以防 UI 出現空白。

 ----------

` * How`

 1. 設置導航標題
 
    - 在 `setupNavigationBar` 方法中，使用 `parentCategoryTitle` 作為導航欄標題，若無法取得該值，設置為默認值：
 
    ```swift
     private func setupNavigationBar() {
         let navigationManager = DrinkSubCategoryNavigationBarManager(navigationItem: navigationItem)
         navigationManager.drinkSubCategoryNavigationBarDelegate = self
         drinkSubCategoryNavigationBarManager = navigationManager
         
         // 設置父分類標題作為導航標題
         let title = parentCategoryTitle ?? "Drink Category"
         navigationManager.configureNavigationBarTitle(
             title: title,
             prefersLargeTitles: true
         )
         
         navigationManager.configureSwitchLayoutButton(isGridLayout: layoutType == .grid)
     }
    ```

 ----
 
 2. 子分類標題交由 `sectionHeader` 處理
 
    - `viewForSupplementaryElementOfKind` 方法負責為每個 section 的 `headerView` 配置子分類的標題：
    
    ```swift
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DrinkSubCategorySectionHeaderView.headerIdentifier,
                for: indexPath
            ) as? DrinkSubCategorySectionHeaderView else {
                fatalError("Cannot create header view")
            }
            guard let subcategoryTitle = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section].subcategoryTitle else {
                fatalError("Missing subcategory title for section \(indexPath.section)")
            }
            headerView.configure(with: subcategoryTitle)
            return headerView
        }
        return UICollectionReusableView()
    }
    ```

 ----

 3. 確保父分類數據傳遞
 
    - 在導航至 `DrinkSubCategoryViewController` 時，通過初始化 傳遞 `parentCategoryTitle`：
 
    ```swift
     func navigateToSubCategory(selectedCategory: MenuDrinkCategoryViewModel) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         guard let subCategoryVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.drinkSubCategoryViewController) as? DrinkSubCategoryViewController else {
             print("[MenuViewController]: Failed to instantiate DrinkSubCategoryViewController with identifier: \(Constants.Storyboard.drinkSubCategoryViewController)")
             return
         }
         
         // 將展示模型中的必要數據傳遞給子分類頁面
         subCategoryVC.parentCategoryId = selectedCategory.id
         subCategoryVC.parentCategoryTitle = selectedCategory.title
         self.navigationController?.pushViewController(subCategoryVC, animated: true)
     }
    ```

 ----------

 `* 總結`
 
 - 導航標題應該是 `Drink CategoryTitle`，用於顯示當前主要分類的背景資訊。
 - 子分類標題交由 `sectionHeader` 負責，以細化展示分類內容。
 - 確保數據傳遞的完整性，並設置默認標題處理異常情況。
 - 這樣的設計遵循單一責任原則，使 UI 邏輯清晰、層次分明。
 */


// MARK: - DrinkSubCategoryViewController 筆記
/**
 
 ## DrinkSubCategoryViewController 筆記


 `* What`
 
 - `DrinkSubCategoryViewController` 是一個負責顯示特定飲品類別下的 **子分類** 及其 **飲品列表** 的視圖控制器。
 - 允許用戶在 **列表（column）** 和 **網格（grid）** 兩種佈局模式間切換。

 - 功能
 
    - 顯示飲品子分類與對應飲品列表：
 
       - 透過 `UICollectionView` 呈現子分類及其飲品，支援 `Header` 顯示子分類標題，`Footer` 作為區隔線。
 
    - 支援佈局切換：
 
       - 透過導航欄按鈕，讓用戶可選擇以 **網格** 或 **列表** 模式查看飲品。
 
    - 處理飲品點擊事件：
 
       - 當用戶選擇某個飲品時，會導向飲品詳細頁面。
 
    - 管理 `UICollectionView` 資料與行為：
 
       - 使用 `DrinkSubCategoryHandler` 負責 `UICollectionView` 的 `dataSource` 和 `delegate`，確保控制器不直接處理細節。

 ----------

 `* Why`
 
 - 設計目標
 
 1. 降低 `ViewController` 的複雜度
 
    - 透過 **管理類別**（Manager & Handler）拆分職責，避免 `ViewController` 過於臃腫：
 
      - `DrinkSubCategoryHandler`：負責 `UICollectionView` 的數據處理與行為。
      - `DrinkSubCategoryViewManager`：負責 `UICollectionView` 的佈局變更。
      - `DrinkSubCategoryNavigationBarManager`：負責導航欄按鈕與標題管理。
      - `DrinkSubCategoryManager`：負責從 Firestore 加載飲品子分類數據。

 2. 支援靈活的顯示方式
 
    - `DrinkSubCategoryViewController` 允許用戶在 **網格模式** 和 **列表模式** 之間切換，以符合不同用戶的使用習慣。

 3. 提高可測試性
 
    - 透過 **Delegate 設計** 讓 `DrinkSubCategoryHandler` 負責 `UICollectionView` 的邏輯，使 `ViewController` 可專注於控制行為，提升測試可行性。

 ----------

` * How`
 
 (1) 初始化
 
 - 在 `viewDidLoad` 中：
 
   1. 初始化 `DrinkSubCategoryViewManager`（管理 `UICollectionView` 的佈局）
   2. 配置 `UICollectionView`（指定 `dataSource` 和 `delegate`）
   3. 設定導航欄（標題與切換佈局按鈕）
   4. 加載子分類數據

     ```swift
     override func viewDidLoad() {
         super.viewDidLoad()
         
         setupDrinkSubCategoryViewManager()
         configureCollectionView()
         setupNavigationBar()
         loadDrinkSubcategories()
     }
     ```

 ---

 (2) 設定 `UICollectionView`
 
 - `DrinkSubCategoryHandler` 負責 `UICollectionView` 的數據來源與行為處理：
 
     ```swift
     private func configureCollectionView() {
         let collectionView = drinkSubCategoryView.drinkSubCategoryCollectionView
         collectionView.dataSource = drinkSubCategoryHandler
         collectionView.delegate = drinkSubCategoryHandler
         drinkSubCategoryHandler.drinkSubCategoryHandlerDelegate = self
     }
     ```

 ---

 (3) 設定導航欄
 
 - 透過 `DrinkSubCategoryNavigationBarManager` 設定 **標題** 與 **切換佈局按鈕**：
 
     ```swift
     private func setupNavigationBar() {
         let navigationManager = DrinkSubCategoryNavigationBarManager(navigationItem: navigationItem)
         navigationManager.drinkSubCategoryNavigationBarDelegate = self
         drinkSubCategoryNavigationBarManager = navigationManager
         
         let title = parentCategoryTitle ?? "Drink Category"
         navigationManager.configureNavigationBarTitle(title: title, prefersLargeTitles: true)
         navigationManager.configureSwitchLayoutButton(isGridLayout: layoutType == .grid)
     }
     ```

 ---

 (4) 加載數據
 
 - 使用 `DrinkSubCategoryManager` 透過 **非同步方法** 從 Firestore 獲取飲品子分類資料：
 
     ```swift
     private func loadDrinkSubcategories() {
         guard let categoryId = parentCategoryId else { return }
         HUDManager.shared.showLoading(text: "Loading Drinks...")
         
         Task {
             do {
                 drinkSubcategoryViewModels = try await drinkSubCategoryManager.fetchDrinkSubcategories(for: categoryId)
                 print("[Load Data]: Loaded \(drinkSubcategoryViewModels.count) subcategories")
                 
                 drinkSubCategoryViewManager?.updateCollectionViewLayout(to: layoutType, totalSections: drinkSubcategoryViewModels.count)
             } catch {
                 AlertService.showAlert(
                     withTitle: "Error",
                     message: error.localizedDescription,
                     inViewController: self
                 )
             }
             HUDManager.shared.dismiss()
         }
     }
     ```

 ---

 (5) 切換佈局模式
 
    - **按鈕事件觸發**：`DrinkSubCategoryNavigationBarManager` 負責處理 **切換佈局按鈕**，並透過 `DrinkSubCategoryNavigationBarDelegate` 回傳：
     
     ```swift
     func didTapSwitchLayoutButton() {
         layoutType = (layoutType == .grid) ? .column : .grid
         print("[Switch Layout]: Switching to \(layoutType)")
         
         drinkSubCategoryViewManager?.updateCollectionViewLayout(to: layoutType, totalSections: drinkSubcategoryViewModels.count)
         drinkSubCategoryNavigationBarManager?.updateSwitchLayoutButton(isGridLayout: layoutType == .grid)
     }
     ```

 ---

 (6) 用戶點擊飲品
 
 - 透過 `DrinkSubCategoryHandlerDelegate`，當用戶點擊某個飲品時，會導航至詳細頁面：
 
     ```swift
     func didSelectDrink(categoryId: String, subcategoryViewModel: DrinkSubCategoryViewModel, drinkViewModel: DrinkViewModel) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         guard let drinkDetailVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController else {
             print("[DrinkSubCategoryViewController]: Failed to instantiate DrinkDetailViewController")
             return
         }
         
         drinkDetailVC.categoryId = categoryId
         drinkDetailVC.subcategoryId = subcategoryViewModel.subcategoryId
         drinkDetailVC.drinkId = drinkViewModel.id
         navigationController?.pushViewController(drinkDetailVC, animated: true)
     }
     ```

 ----------

 `* 架構關係`
 
     ```plaintext
     DrinkSubCategoryViewController
      ├── DrinkSubCategoryView (主視圖)
      ├── DrinkSubCategoryHandler (負責 UICollectionView 的 dataSource 和 delegate)
      ├── DrinkSubCategoryViewManager (負責更新佈局)
      ├── DrinkSubCategoryNavigationBarManager (管理導航欄行為)
      ├── DrinkSubCategoryManager (負責數據加載)
     ```

 ----------

 `* 筆記摘要`
 
 1.主要功能：
 
    - 顯示飲品子分類、支援佈局切換、處理點擊導航至詳細頁面
 
 
 2.為什麼需要它：
 
    - 降低 `ViewController` 負擔、支援靈活顯示模式、提升可測試性與 UI/UX
 
 3.如何實現：
 
    - 透過 `Manager & Handler` 拆分職責，非同步加載數據，透過 `Delegate` 進行交互
 
 4.關鍵組件：
 
    - `DrinkSubCategoryViewManager`、`DrinkSubCategoryHandler`、`DrinkSubCategoryNavigationBarManager`
*/



// MARK: - ok


import UIKit

/// `DrinkSubCategoryViewController`
///
/// ### 功能概述
/// `DrinkSubCategoryViewController` 負責顯示特定飲品類別下的所有子分類，並允許用戶在網格與列表視圖之間切換顯示模式。
///
/// ### 設計目標
/// - 單一職責 (SRP)：此類專注於子分類的顯示與導航，數據加載、佈局管理等邏輯被拆分到獨立的管理類別中。
/// - 高內聚低耦合：
///   - `DrinkSubCategoryHandler` 負責 `UICollectionView` 的 `dataSource` 與 `delegate`。
///   - `DrinkSubCategoryViewManager` 負責管理 `UICollectionView` 的佈局更新。
///   - `DrinkSubCategoryNavigationBarManager` 負責管理導航欄行為。
///   - `DrinkSubCategoryManager` 負責加載數據並轉換為視圖模型。
///
/// ### 職責
/// - 負責初始化並管理 `UICollectionView`，處理子分類數據的展示。
/// - 提供佈局切換功能，支援網格與列表模式。
/// - 處理用戶與 `UICollectionView` 的交互，例如點擊某個飲品時導航至詳細頁面。
///
/// ### 使用場景
/// - 用於顯示某個特定飲品類別下的子分類與其對應的飲品清單。
/// - 用戶可以透過切換佈局模式改變 `UICollectionView` 的顯示方式。
class DrinkSubCategoryViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 頁面的主要視圖，內部包含 `UICollectionView` 來顯示子分類與飲品列表。
    private let drinkSubCategoryView = DrinkSubCategoryView()
    
    
    // MARK: - Layout & View Management
    
    /// 當前的佈局類型，預設為 `.column` (列表模式)。
    private var layoutType: DrinkSubCategoryLayoutType = .column
    
    /// 提供佈局生成功能的物件。
    private let drinkSubCategoryLayoutProvider = DrinkSubCategoryLayoutProvider()
    
    /// 管理 `UICollectionView` 的佈局更新。
    private var drinkSubCategoryViewManager: DrinkSubCategoryViewManager?
    
    
    // MARK: - CollectionView Handling
    
    /// 負責管理 `UICollectionView` 的 `dataSource` 和 `delegate`。
    private let drinkSubCategoryHandler = DrinkSubCategoryHandler()
    
    
    // MARK: - Navigation Management
    
    /// 管理導航欄的行為，例如標題設置與佈局切換按鈕。
    private var drinkSubCategoryNavigationBarManager: DrinkSubCategoryNavigationBarManager?
    
    
    // MARK: - Data Management
    
    /// 負責處理飲品子分類數據的管理器。
    private let drinkSubCategoryManager = DrinkSubCategoryManager()
    
    /// 加載完成的子分類數據，供 `UICollectionView` 使用。
    private var drinkSubcategoryViewModels: [DrinkSubCategoryViewModel] = []
    
    
    // MARK: - Data Source (Parent Category Info)
    
    /// 當前所屬的父類別 ID，用於加載對應的子分類資料。
    var parentCategoryId: String?
    
    /// 父類別的標題，作為導航欄標題顯示。
    var parentCategoryTitle: String?
    
    
    // MARK: - Lifecycle Methods
    
    /// 設置主要視圖為 `DrinkSubCategoryView`，確保視圖層統一管理。
    override func loadView() {
        view = drinkSubCategoryView
    }
    
    /// 頁面加載完成時
    ///
    ///  1. 初始化 `DrinkSubCategoryViewManager`（管理 `UICollectionView` 的佈局）
    ///  2. 配置 `UICollectionView`（指定 `dataSource` 和 `delegate`）
    ///  3. 設定導航欄（標題與切換佈局按鈕）
    ///  4. 加載子分類數據
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDrinkSubCategoryViewManager()
        configureCollectionView()
        setupNavigationBar()
        loadDrinkSubcategories()
    }
    
    // MARK: - Setup Methods
    
    /// 初始化 `DrinkSubCategoryViewManager`
    ///
    /// - 此管理器負責 `UICollectionView` 佈局切換
    /// - 使用 `DrinkSubCategoryLayoutProvider` 生成不同的佈局
    private func setupDrinkSubCategoryViewManager() {
        drinkSubCategoryViewManager = DrinkSubCategoryViewManager(
            drinkSubCategoryCollectionView: drinkSubCategoryView.drinkSubCategoryCollectionView,
            drinkSubCategoryLayoutProvider: drinkSubCategoryLayoutProvider
        )
    }
    
    /// 設置 `UICollectionView` 的 `dataSource` 和 `delegate`，並關聯 `DrinkSubCategoryHandler`。
    private func configureCollectionView() {
        let collectionView = drinkSubCategoryView.drinkSubCategoryCollectionView
        collectionView.dataSource = drinkSubCategoryHandler
        collectionView.delegate = drinkSubCategoryHandler
        drinkSubCategoryHandler.drinkSubCategoryHandlerDelegate = self
    }
    
    /// 配置導航欄標題與佈局切換按鈕。
    ///
    /// - 設置父分類標題作為導航標題
    /// - 配置切換佈局按鈕
    private func setupNavigationBar() {
        let navigationManager = DrinkSubCategoryNavigationBarManager(navigationItem: navigationItem)
        navigationManager.drinkSubCategoryNavigationBarDelegate = self
        drinkSubCategoryNavigationBarManager = navigationManager
        
        let title = parentCategoryTitle ?? "Drink Category"
        navigationManager.configureNavigationBarTitle(
            title: title,
            prefersLargeTitles: true
        )
        navigationManager.configureSwitchLayoutButton(isGridLayout: layoutType == .grid)
    }
    
    
    // MARK: - Data Loading
    
    /// 從 `DrinkSubCategoryManager` 獲取飲品子分類數據
    ///
    /// ### 目的
    /// - 向 `DrinkSubCategoryManager` 請求並加載子分類數據
    /// - 更新 `drinkSubcategoryViewModels`，作為 `UICollectionView` 的數據來源
    /// - 通知 `DrinkSubCategoryViewManager` 調整佈局（由視圖管理器負責 UI 調整）
    ///
    /// ### 注意事項
    /// - 此方法 **不直接負責 UI 更新**，僅處理數據層邏輯
    /// - UI 變更應交由 `DrinkSubCategoryViewManager` 透過 `initializeCollectionViewLayout` 或 `updateCollectionViewLayout` 處理
    private func loadDrinkSubcategories() {
        guard let categoryId = parentCategoryId else { return }
        HUDManager.shared.showLoading(text: "Loading Drinks...")
        Task {
            do {
                drinkSubcategoryViewModels = try await drinkSubCategoryManager.fetchDrinkSubcategories(for: categoryId)
                print("[DrinkSubCategoryViewController]: Loaded \(drinkSubcategoryViewModels.count) subcategories")
                drinkSubCategoryViewManager?.initializeCollectionViewLayout(to: layoutType, totalSections: drinkSubcategoryViewModels.count)
            } catch {
                AlertService.showAlert(
                    withTitle: "Error",
                    message: error.localizedDescription,
                    inViewController: self
                )
            }
            HUDManager.shared.dismiss()
        }
    }
    
}


// MARK: - DrinkSubCategoryHandlerDelegate
extension DrinkSubCategoryViewController: DrinkSubCategoryHandlerDelegate {
    
    /// 提供 `UICollectionView` 使用的子分類視圖模型數據。
    var subcategoryViewModels: [DrinkSubCategoryViewModel] {
        return drinkSubcategoryViewModels
    }
    
    /// 提供當前 `UICollectionView` 的佈局類型，用於 `cell` 配置。
    var currentLayoutType: DrinkSubCategoryLayoutType {
        return layoutType
    }
    
    /// 提供當前選定的父類別 ID。
    var categoryId: String? {
        return parentCategoryId
    }
    
    /// 當用戶選擇某個飲品時，導航至飲品詳細頁面。
    func didSelectDrink(categoryId: String, subcategoryViewModel: DrinkSubCategoryViewModel, drinkViewModel: DrinkViewModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let drinkDetailVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController else {
            print("[DrinkSubCategoryViewController]: Failed to instantiate DrinkDetailViewController")
            return
        }
        
        // 傳遞數據
        drinkDetailVC.categoryId = categoryId
        drinkDetailVC.subcategoryId = subcategoryViewModel.subcategoryId
        drinkDetailVC.drinkId = drinkViewModel.id
        navigationController?.pushViewController(drinkDetailVC, animated: true)
    }
    
}


// MARK: - DrinkSubCategoryNavigationBarDelegate
extension DrinkSubCategoryViewController: DrinkSubCategoryNavigationBarDelegate {
    
    /// 處理用戶點擊切換佈局按鈕的事件
    ///
    /// - 切換 `layoutType` 為 `.grid` 或 `.column`
    /// - 更新 `DrinkSubCategoryViewManager`，刷新 `UICollectionView`
    /// - `UICollectionView` 會立即刷新以適應新的佈局
    func didTapSwitchLayoutButton() {
        layoutType = (layoutType == .grid) ? .column : .grid
        print("[DrinkSubCategoryViewController]: Switch Layout Switching to \(layoutType)")
        
        drinkSubCategoryViewManager?.updateCollectionViewLayout(to: layoutType, totalSections: drinkSubcategoryViewModels.count)
        drinkSubCategoryNavigationBarManager?.updateSwitchLayoutButton(isGridLayout: layoutType == .grid)
    }
    
}
