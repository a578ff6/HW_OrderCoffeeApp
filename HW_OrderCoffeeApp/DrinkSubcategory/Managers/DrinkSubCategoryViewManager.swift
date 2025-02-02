//
//  DrinkSubCategoryViewManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/27.
//

// MARK: - DrinkSubCategoryViewManager 筆記
/**
 
 ### DrinkSubCategoryViewManager 筆記

 
 `* What`
 
 - `DrinkSubCategoryViewManager` 是一個負責管理 `DrinkSubCategoryCollectionView` 的視圖和佈局邏輯的類別，主要用於將佈局更新操作與控制器分離。

 - 職責：
 
   1. 管理 `UICollectionView` 的佈局更新。
   2. 使用 `DrinkSubCategoryLayoutProvider` 根據佈局類型生成對應的佈局。
   3. 將新的佈局應用到 `UICollectionView` 並刷新視圖。

 - 關鍵方法：
 
   - `updateCollectionViewLayout(to:totalSections:)`：根據佈局類型和 section 數量更新 `UICollectionView` 的佈局。

 ---------

 `* Why`
 
 1. 分離視圖邏輯：
 
    - 佈局相關的邏輯單獨放在 `DrinkSubCategoryViewManager` 中，避免控制器過於臃腫。
    - 符合單一職責原則 (Single Responsibility Principle, SRP)，提高代碼的可維護性。

 2. 提升重用性：
 
    - 將佈局生成的邏輯抽象為獨立的方法，便於重用和測試。

 3. 讓視圖層專注於視圖職責：
 
    - `DrinkSubCategoryViewManager` 確保了 `DrinkSubCategoryView` 和 `DrinkSubCategoryCollectionView` 專注於顯示和佈局相關操作，不涉及數據加載或其他業務邏輯。
    - 避免視圖層與業務邏輯的耦合，符合高內聚低耦合設計原則。

 4. 簡化控制器：
 
    - 控制器專注於業務邏輯，例如數據加載、用戶交互等，視圖管理器則專注於視圖相關操作。

 5. 易於擴展：
 
    - 如果需要新增其他佈局邏輯，只需擴展 `DrinkSubCategoryLayoutProvider` 或新增方法，不影響控制器的業務邏輯。

 ---------

 `* How`

 1. 初始化：
 
    - 在控制器中實例化 `DrinkSubCategoryViewManager`，並傳入 `DrinkSubCategoryCollectionView` 和 `DrinkSubCategoryLayoutProvider`。
 
    ```swift
    private func setupDrinkSubCategoryViewManager() {
        drinkSubCategoryViewManager = DrinkSubCategoryViewManager(
            drinkSubCategoryCollectionView: drinkSubCategoryView.drinkSubCategoryCollectionView,
            drinkSubCategoryLayoutProvider: drinkSubCategoryLayoutProvider
        )
    }
    ```

 ---
 
 2. 切換佈局：
 
    - 當用戶在網格和列表佈局間切換時，調用 `updateCollectionViewLayout` 方法，傳入新的佈局類型和 section 數量：
 
    ```swift
     func didTapSwitchLayoutButton() {
         layoutType = (layoutType == .grid) ? .column : .grid
         drinkSubCategoryViewManager?.updateCollectionViewLayout(to: layoutType, totalSections: drinkSubcategoryViewModels.count)
         
         // 更新導航欄按鈕
         drinkSubCategoryNavigationBarManager?.updateSwitchLayoutButton(isGridLayout: layoutType == .grid)
     }
    ```
 
 ---
 
 3. 數據加載後更新佈局：
 
    - 數據加載完成後，根據新的 section 數量和當前佈局類型重新配置佈局：
 
    ```swift
     drinkSubcategoryViewModels = try await drinkSubCategoryManager.fetchDrinkSubcategories(for: categoryId)
     drinkSubCategoryViewManager?.updateCollectionViewLayout(to: layoutType, totalSections: drinkSubcategoryViewModels.count)
    ```

 ---------

 `* 架構圖示`
 
     ```plaintext
     DrinkSubCategoryViewController
        ├── DrinkSubCategoryView
        ├── DrinkSubCategoryCollectionView
        └── DrinkSubCategoryViewManager
             ├── DrinkSubCategoryLayoutProvider
             └── UICollectionView Layout Handling
     ```
 
 ---------

 `* 筆記摘要`
 
 1. 目的：
 
    - 解耦控制器中的視圖邏輯，專注於管理 `UICollectionView` 的佈局更新。
    - 避免視圖層涉及業務邏輯，專注於顯示和佈局管理。
    - 清晰地將視圖層和業務邏輯分開，符合 **Clean Architecture** 的設計原則。
    - 確保視圖層只處理視圖的顯示和行為邏輯，不處理數據加載或邏輯計算，提升代碼的模組化和易測試性。
 
 2. 優勢：
 
    - 提高代碼可讀性、可重用性，並減少控制器臃腫。
    - 遵循單一職責原則，提升模組化設計。

 3. 實現方式：
 
    - 初始化 `DrinkSubCategoryViewManager`，使用 `updateCollectionViewLayout` 進行佈局切換和更新。
 
 4. 適用場景：
 
    - 用戶切換佈局樣式。
    - 數據加載後需要動態更新佈局。
 */


// MARK: - 設計 `DrinkSubCategoryView` 和 `DrinkSubCategoryCollectionView` 的責任分離與架構調整
/**
 
 ## 設計 `DrinkSubCategoryView` 和 `DrinkSubCategoryCollectionView` 的責任分離與架構調整


 `* What`
 
 - 調整 `DrinkSubCategoryView` 和 `DrinkSubCategoryCollectionView` 的設計，使其更專注於視圖顯示，將動態佈局的邏輯轉移到 `DrinkSubCategoryViewManager` 中。

 主要調整：
 
    1. 簡化 `DrinkSubCategoryView` 和 `DrinkSubCategoryCollectionView` 的初始化參數，移除與業務邏輯相關的 `layoutProvider`、`layoutType`、`totalSections`。
    2. 集中佈局管理至 `DrinkSubCategoryViewManager`，`DrinkSubCategoryView` 僅負責顯示和約束設置。
    3. `DrinkSubCategoryCollectionView` 作為自訂 `UICollectionView`，專注於視圖層配置，如背景顏色和滾動條顯示。

 ---

 `* Why`
 
 1. 責任分離與單一職責原則 (SRP)：
 
    - 視圖層 (`DrinkSubCategoryView` 和 `DrinkSubCategoryCollectionView`) 僅專注於視圖顯示和配置，避免參與業務邏輯或動態佈局的細節。
    - 動態佈局相關邏輯由 `DrinkSubCategoryViewManager` 完全負責，減少重複設置並提高可測試性。
    
 2. 高內聚低耦合：
 
    - 將佈局切換邏輯從控制器和視圖層中抽離，集中於 `DrinkSubCategoryViewManager`，使控制器專注於業務流程管理，視圖專注於顯示，降低模塊間耦合。

 3. 靈活性與可維護性：
 
    - 集中管理佈局切換的邏輯，便於未來拓展，例如支持更多佈局類型或調整顯示樣式（如底線樣式切換）。

 ---

 `* How`

 1. 簡化 `DrinkSubCategoryView` 和 `DrinkSubCategoryCollectionView`

     ```swift
     import UIKit

     /// 定義飲品子分類頁面的主視圖
     class DrinkSubCategoryView: UIView {
         private(set) var drinkSubCategoryCollectionView: DrinkSubCategoryCollectionView

         init() {
             self.drinkSubCategoryCollectionView = DrinkSubCategoryCollectionView()
             super.init(frame: .zero)
             setupView()
             registerCells()
         }

         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
            
        ....
     }

     /// 自訂的 `UICollectionView`，專門用於飲品子分類頁面
     class DrinkSubCategoryCollectionView: UICollectionView {
         init() {
             let initialLayout = UICollectionViewCompositionalLayout { _, _ in return nil }
             super.init(frame: .zero, collectionViewLayout: initialLayout)
             configureCollectionView()
         }

         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }

         private func configureCollectionView() {
             self.translatesAutoresizingMaskIntoConstraints = false
             self.backgroundColor = .systemBackground
             self.showsVerticalScrollIndicator = true
         }
     }
     ```

 ---
 
 2. `DrinkSubCategoryViewManager` 負責動態佈局管理

     ```swift
     import UIKit

     /// 管理 `DrinkSubCategoryCollectionView` 的佈局邏輯
     class DrinkSubCategoryViewManager {
         private let drinkSubCategoryCollectionView: DrinkSubCategoryCollectionView
         private let layoutProvider: DrinkSubCategoryLayoutProvider

         init(drinkSubCategoryCollectionView: DrinkSubCategoryCollectionView, layoutProvider: DrinkSubCategoryLayoutProvider) {
             self.drinkSubCategoryCollectionView = drinkSubCategoryCollectionView
             self.layoutProvider = layoutProvider
         }

         func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
             let newLayout = layoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
             drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: false)
             drinkSubCategoryCollectionView.reloadData()
         }
     }
     ```

 ---
 
 3. 簡化 `DrinkSubCategoryViewController`，專注於業務邏輯
 
    - 佈局切換通過 `DrinkSubCategoryViewManager` 實現，控制器僅調用相關方法。

     ```swift
     import UIKit

     class DrinkSubCategoryViewController: UIViewController {
         private var layoutType: DrinkSubCategoryLayoutType = .column
         private lazy var drinkSubCategoryView = DrinkSubCategoryView()
         private let drinkSubCategoryHandler = DrinkSubCategoryHandler()
         private var drinkSubCategoryViewManager: DrinkSubCategoryViewManager!
         private let layoutProvider = DrinkSubCategoryLayoutProvider()
         private var drinkSubcategoryViewModels: [DrinkSubCategoryViewModel] = []

         override func loadView() {
             view = drinkSubCategoryView
         }

         override func viewDidLoad() {
             super.viewDidLoad()
             setupViewManager()
             configureCollectionView()
             loadDrinkSubcategories()
         }

         private func configureCollectionView() {
             let collectionView = drinkSubCategoryView.drinkSubCategoryCollectionView
             collectionView.dataSource = drinkSubCategoryHandler
             collectionView.delegate = drinkSubCategoryHandler
             drinkSubCategoryHandler.drinkSubCategoryHandlerDelegate = self
         }

         private func setupViewManager() {
             drinkSubCategoryViewManager = DrinkSubCategoryViewManager(
                 drinkSubCategoryCollectionView: drinkSubCategoryView.drinkSubCategoryCollectionView,
                 layoutProvider: layoutProvider
             )
         }

         private func loadDrinkSubcategories() {
             // 略過數據加載邏輯
         }
     }
     ```

 ---

 `* 結論`
 
 - 此設計通過將視圖顯示與邏輯分離，提高了代碼的清晰度與可維護性。
 - `DrinkSubCategoryView` 和 `DrinkSubCategoryCollectionView` 被簡化為純視圖層，不參與動態邏輯。
 - 佈局切換邏輯集中於 `DrinkSubCategoryViewManager`，符合責任分離原則，便於未來擴展和測試。
 */


// MARK: - setCollectionViewLayout()` 與 `reloadData()` 在 `UICollectionView` 內的處理
/**
 
 ## setCollectionViewLayout()` 與 `reloadData()` 在 `UICollectionView` 內的處理

 - 因為在 `DrinkSubCategoryViewController` 的 `loadDrinkSubcategories` 設置 `initializeCollectionViewLayout(setCollectionViewLayout)`，並且 `loadDrinkSubcategories` 還設置了 `reloadData()`。
 - 導致進入畫面時，會出現不必要的多次重新整理。
 
 -------

`* What`
 
 - `setCollectionViewLayout(_:, animated:)` 是 `UICollectionView` 提供的方法，用於切換 `UICollectionViewLayout`，如從列表模式切換到網格模式。
 - 此方法會自動觸發 `UICollectionView` 的重新整理，而無需手動呼叫 `reloadData()`。

 -------
 
` * Why`
 
 - 當 `setCollectionViewLayout()` 被執行時，`UICollectionView` 會進行以下動作：
 
 1. 移除舊的 `UICollectionViewLayout`，並套用新的佈局。
 2. 重新計算 `sections` 和 `items` 的數量，確保與新的佈局匹配。
 3. 觸發 `UICollectionViewDataSource` 的方法（如 `numberOfSections`、`cellForItemAt`）。
 4. 自動重新整理 UI，所以不需要手動 `reloadData()`。

 -------

 `* How：`
 
 1. 在 `initializeCollectionViewLayout()` 內
 
    - 不需要 `reloadData()`，因為 `setCollectionViewLayout()` 會自動刷新 UI。
 
    ```swift
    func initializeCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
        let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
        drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: false)
    }
    ```

 ---
 
 2. 在 `updateCollectionViewLayout()`（當用戶切換佈局時）
 
    - 可手動 `reloadData()` 來確保 UI 更新
 
    ```swift
     func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
         let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
         
         // 直接切換佈局，不帶動畫，確保變更立即生效
         drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: false)
         
         // 立即刷新數據，確保 UI 正確顯示
         drinkSubCategoryCollectionView.reloadData()
     }
    ```

 -------

 `* 結論`
 
 1. `setCollectionViewLayout()` 會讓 `UICollectionView` 自動刷新 UI，所以在 `initializeCollectionViewLayout()` 不需要 `reloadData()`。
 2. 僅在 UI 未正確更新或資料發生變化時，才手動 `reloadData()`，以避免不必要的 `cellForItemAt` 重複調用。
 3. 當用戶切換佈局時，可在 `updateCollectionViewLayout()` 內使用 `reloadData()` 來確保 UI 正確更新。


 */


// MARK: - `updateCollectionViewLayout`：最佳動畫與刷新策略（重要）
/**
 
 
 ## `updateCollectionViewLayout`：最佳動畫與刷新策略
 
 - 參考 https://reurl.cc/qvVA1y

 `* What`

 - `updateCollectionViewLayout` 是 `DrinkSubCategoryViewManager` 中負責更新 `UICollectionView` 佈局的方法。
 - 該方法可用於切換 `UICollectionView` 在列表模式與網格模式之間的顯示方式。

 目前有兩種不同的 `reload` 策略：
 
 1. 方法一：使用 `reloadData()`（會導致整體重建，動畫過渡不自然）
 2. 方法二：使用 `reloadItems(at:)`（只刷新可見 `cell`，動畫過渡更流暢）

 --------

 `* Why`

 方法一 (`reloadData()`) 的問題
 
 ```swift
 func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
     let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
     drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: true) { _ in
         self.drinkSubCategoryCollectionView.reloadData()
     }
 }
 ```

 - `reloadData()`*會強制 `UICollectionView` 重建所有 `cell`，導致閃爍與不流暢的動畫效果。
 - `setCollectionViewLayout(animated: true)` 會立即改變佈局，但 `reloadData()` 會導致 `cell` 消失再重新出現，視覺上不連貫。
 - `結果`：切換佈局時，動畫看起來「突兀」、「卡頓」，甚至可能短暫出現空白。

 ---

 方法二 (`reloadItems(at:)`) 的優勢
 
 ```swift
 func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
     let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)

     // 先刷新可見 cell，確保 UI 與數據同步
     drinkSubCategoryCollectionView.reloadItems(at: drinkSubCategoryCollectionView.indexPathsForVisibleItems)
     
     // 再應用新的佈局，並啟用動畫
     drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: true)
 }
 ```

 - `reloadItems(at:)` 只會更新當前可見的 `cell`，不會影響未出現在畫面上的 `cell`。
 - 這樣可以確保 `cell` 內容先更新，再執行 `setCollectionViewLayout` 的動畫，讓視覺上的過渡更自然。
 - `結果`：切換佈局時，`cell` 保持平滑動畫，視覺效果更佳。

 --------

 `* How`

 1.為什麼 `reloadItems(at:)` 應該在 `setCollectionViewLayout` 之前？
 
    - 如果 `reloadItems(at:)` 在 `setCollectionViewLayout` 內的閉包內，動畫效果會較差。
    - 這是因為 `UICollectionView` 會**先完成佈局變更，再刷新 `cell`**，導致切換時畫面有空白感。
    - 最佳方案：先刷新 `cell`，再執行 `setCollectionViewLayout`，確保動畫同步執行。

 --------

 `* 方法比較`
 

 方法 1：使用 `reloadData()`
 
    - 動畫效果：不流暢
    - 視覺影響：`cell` 會被完全重建，導致切換時閃爍、卡頓
    - 建議使用：不建議，因為 `reloadData()` 會強制重建所有 `cell`，導致視覺上的卡頓感。

 ---
 
 方法 2：`reloadItems(at:)`（放在 `setCollectionViewLayout` 的閉包內）
 
    - 動畫效果：動畫延遲
    - 視覺影響：`cell` 在佈局切換後才刷新，導致動畫不同步
    - 建議使用：不建議，雖然 `reloadItems(at:)` 只會刷新可見的 `cell`，但如果放在 `setCollectionViewLayout` 的閉包內，會讓動畫延遲，影響視覺體驗。

 ---

 方法 3：`reloadItems(at:)`（放在 `setCollectionViewLayout` 之前）
 
    - 動畫效果：最流暢
    - 視覺影響：`cell` 先更新，然後執行動畫，避免閃爍
    - 建議使用：最佳方案，因為 `reloadItems(at:)` 只會更新可見的 `cell`，避免 `reloadData()` 的過度重建問題，而且放在 `setCollectionViewLayout` 之前，動畫順暢不會產生不同步問題。

 --------

 `* 最終最佳實作方案`
 
     ```swift
     func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
         let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)

         // 先刷新可見 cell，確保 UI 與數據同步
         drinkSubCategoryCollectionView.reloadItems(at: drinkSubCategoryCollectionView.indexPathsForVisibleItems)
         
         // 再應用新的佈局，並啟用動畫
         drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: true)
     }
     ```

 --------

 `* 總結`
 
 1.選擇 `reloadItems(at:)` 而非 `reloadData()`，可確保動畫順暢，不影響 `UICollectionView` 整體佈局。
 2.確保 `reloadItems(at:)` 在 `setCollectionViewLayout` 之前執行，使動畫過渡最自然。
 3.避免將 `reloadItems(at:)` 放在 `setCollectionViewLayout` 閉包內，以防動畫不同步問題。
 
 */


// MARK: - UICollectionView 佈局切換（無動畫 vs. 有動畫）
/**
 
 
 ## UICollectionView 佈局切換（無動畫 vs. 有動畫）

`* What：`
 
 （如何正確切換 UICollectionView 佈局，並決定是否需要動畫效果？）
 
 - 在 `DrinkSubCategoryViewManager` 中，`updateCollectionViewLayout` 方法負責更新 `UICollectionView` 的佈局，主要有兩種方式：
 
    1. 無動畫效果：直接變更佈局並完整 `reloadData()`。
    2. 有動畫效果：切換佈局後，僅刷新可見的 `cells` (`reloadItems(at:)`)。

 ------
 
 `* Why`
 
 根據需求不同，選擇不同的實現方式：
 
    - 如果不需要動畫效果，希望`佈局立即變更且數據完全刷新`，應該使用 `reloadData()` 方式。
    - 如果希望有流暢的動畫過渡，應該使用 `reloadItems(at:)`，這樣 `UICollectionView` 只會更新可見的 `cells`，確保動畫平滑。

 ------

 `* How`

 `- 無動畫效果（最佳選擇）`
 
 ```swift
 func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
     let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
     
     // 直接變更佈局，無動畫，確保立即應用新佈局
     drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: false)
     
     // 完整刷新 UICollectionView
     drinkSubCategoryCollectionView.reloadData()
 }
 ```
 
 - 適用場景：
 
    - 佈局完全變更（從 `grid` 變 `list`，或 `list` 變 `grid`）。
    - 希望確保所有數據都正確刷新。
    - 不需要切換時的視覺過渡動畫。

 ------

 `- 有動畫效果（較平滑的過渡方式）`
 
     ```swift
     func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
         let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
         
         // 使用動畫切換佈局
         drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: true)
         
         // 只刷新當前可見的 cells，減少卡頓
         drinkSubCategoryCollectionView.reloadItems(at: drinkSubCategoryCollectionView.indexPathsForVisibleItems)
     }
     ```
 
 - 適用場景：
 
    - 希望切換佈局時有視覺上的過渡動畫。
    - 不希望刷新整個 `UICollectionView`，以減少重新載入的延遲。
    - 當 `cell` 結構沒有大變動，僅佈局改變時。

 */



// MARK: - (v)


import UIKit


/// 負責管理 `DrinkSubCategoryCollectionView` 的視圖和佈局邏輯
///
/// ### 設計目的
/// `DrinkSubCategoryViewManager` 的設計目的是將 `UICollectionView` 的佈局更新和管理邏輯與控制器解耦，
/// 讓控制器專注於業務邏輯，而視圖管理器專注於視圖相關的操作。
///
/// ### 職責
/// - 管理 `DrinkSubCategoryCollectionView` 的佈局更新。
/// - 使用 `DrinkSubCategoryLayoutProvider` 生成對應的佈局。
/// - 簡化控制器對佈局更新的操作，避免冗長代碼出現在控制器中。
///
/// ### 使用情境
/// - 當用戶切換佈局類型（例如從列表切換到網格）時，負責生成新的佈局並應用到 `UICollectionView`。
/// - 當加載數據後需要根據 section 數量重新配置佈局時，提供更新方法。
class DrinkSubCategoryViewManager {
    
    
    // MARK: - Properties
    
    /// 被管理的 `UICollectionView`，用於顯示飲品子分類。
    private let drinkSubCategoryCollectionView: DrinkSubCategoryCollectionView
    
    /// 提供佈局生成的工具類，負責生成所需的佈局物件。
    private let drinkSubCategoryLayoutProvider: DrinkSubCategoryLayoutProvider
    
    
    // MARK: - Initializer
    
    /// 初始化 `DrinkSubCategoryViewManager`
    ///
    /// - Parameters:
    ///   - drinkSubCategoryCollectionView: 被管理的 `UICollectionView`。
    ///   - drinkSubCategoryLayoutProvider: 用於生成佈局的工具類。
    init(
        drinkSubCategoryCollectionView: DrinkSubCategoryCollectionView,
        drinkSubCategoryLayoutProvider: DrinkSubCategoryLayoutProvider
    ) {
        self.drinkSubCategoryCollectionView = drinkSubCategoryCollectionView
        self.drinkSubCategoryLayoutProvider = drinkSubCategoryLayoutProvider
    }
    
    // MARK: - Public Methods
    
    /// 初始化 `UICollectionViewLayout`
    ///
    /// ### 目的
    /// - 在第一次載入數據後，確保 `UICollectionViewLayout` 的 section 配置正確
    /// - 此方法不會觸發 `reloadData()`，僅負責更新 `UICollectionView` 的 `layout`
    /// - 與 `updateCollectionViewLayout` 的區別：
    ///   - `initializeCollectionViewLayout` 僅在初始設置時使用
    ///   - `updateCollectionViewLayout` 則用於後續的動態更新（例如切換佈局）
    ///
    /// ### 參數
    /// - `layoutType`: 當前的佈局模式（網格/列表）。
    /// - `totalSections`: `UICollectionView` 的總 `section` 數量，用於正確配置佈局。
    func initializeCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
        let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
        drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: true)
    }
    
    
    /// 更新 `UICollectionView` 的佈局
    ///
    /// ### 功能
    /// - 切換佈局時使用，根據指定的佈局類型與 section 數量，更新 `UICollectionViewLayout`，並刷新可見項目。
    /// - 使用 `reloadItems(at:)` 而非 `reloadData()`，確保切換佈局時的動畫過渡更平滑，避免畫面閃爍。
    ///
    /// ### 參數
    /// - `layoutType`: 當前的佈局模式（網格 / 列表）。
    /// - `totalSections`: `UICollectionView` 的總 section 數量。
    ///
    /// ### 設計考量
    /// - `reloadItems(at:)` 只更新可見 cell，減少不必要的重載，提高性能。
    /// - `animated: true` 允許更流暢的 UI 過渡，如不需要動畫可設為 `false`。
    func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
        let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
        drinkSubCategoryCollectionView.reloadItems(at: drinkSubCategoryCollectionView.indexPathsForVisibleItems)
        drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: true)
    }
    
}




// MARK: - reloadData

/// 如果不想要動畫效果，使用 `setCollectionViewLayout(newLayout, animated: false)` 搭配 `reloadData`，目前測試下來也不錯。
/*
 func updateCollectionViewLayout(to layoutType: DrinkSubCategoryLayoutType, totalSections: Int) {
     let newLayout = drinkSubCategoryLayoutProvider.generateLayout(for: layoutType, totalSections: totalSections)
     
     // 直接切換佈局，不帶動畫，確保變更立即生效
     drinkSubCategoryCollectionView.setCollectionViewLayout(newLayout, animated: false)
     
     // 立即刷新數據，確保 UI 正確顯示
     drinkSubCategoryCollectionView.reloadData()
 }
*/
