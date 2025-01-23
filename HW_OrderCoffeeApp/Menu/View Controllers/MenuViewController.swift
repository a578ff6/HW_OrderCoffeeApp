//
//  MenuViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//

// MARK: - 非同步加載的順序問題與 TaskGroup 解決方
/**
 
 ## 非同步加載的順序問題與 TaskGroup 解決方


 `* What`

 - `MenuViewController` 使用了 `withTaskGroup` 來並行執行兩個非同步加載任務：
 
   1. 飲品分類數據加載 (`loadMenuDrinkCategories`)
   2. 網站橫幅數據加載 (`loadWebsites`)
   
 - 任務完成後，更新界面並隱藏載入提示（HUD）。

 - 核心示例：
 
 ```swift
 private func loadData() {
     HUDManager.shared.showLoading(text: "Loading...")
     Task {
         await withTaskGroup(of: Void.self) { group in
             group.addTask { await self.loadMenuDrinkCategories() }
             group.addTask { await self.loadWebsites() }
         }
         HUDManager.shared.dismiss()
     }
 }
 ```

 ---------

 `* Why`

 - 問題描述：
 
 - 在進入 `MenuViewController` 時，發現兩個非同步資料加載操作（飲品分類和網站橫幅）是依次進行的，導致`飲品分類` 先顯示，而`網站橫幅`較慢且突然出現。
   - 如果不使用 `withTaskGroup` 並按照順序執行加載任務，會導致以下問題：
 
     1. 執行效率低：
 
        - `loadMenuDrinkCategories()` 和 `loadWebsites()` 按順序執行，第一個任務完成後才開始第二個任務，增加總的執行時間。
 
     2. 使用者體驗不一致：
        - 因為兩個任務的加載時間不同，會導致「飲品分類」比「網站橫幅」先顯示，後者稍後突然出現，造成不自然的視覺跳動。

 ---
 
 - 解決方案的優勢：
 
    -   - 使用 TaskGroup，可以 「並行執行」 這兩個資料加載任務，而非「依次執行」。
    - 這樣，兩個加載操作會同時進行，不論哪個任務先完成，結果會一起顯示，避免「一個先出現，另一個突然出現」的情況。
 
   1. 效能提升：
 
      - `withTaskGroup` 允許並行執行多個非同步任務，減少總執行時間。
 
   2. 顯示一致性：
 
      - 確保所有數據在所有任務完成後一次性顯示，避免「部分內容突然出現」的情況。
 
   3. 邏輯集中化：
 
      - 通過 `withTaskGroup` 集中管理多個任務的執行和完成狀態，減少手動管理的代碼複雜度。

 ---------

 `* How`

 - 步驟與實現：
 
   1. 創建任務群組：
 
      - 使用 `withTaskGroup` 創建一個並行任務群組。
 
   2. 添加任務到群組中：
 
      - 在群組內添加 `loadMenuDrinkCategories` 和 `loadWebsites` 兩個任務。
 
   3. 等待所有任務完成：
 
      - 當群組中所有任務完成後，更新視圖並隱藏載入提示（HUD）。
 
   4. 處理錯誤：
 
      - 在各任務內添加錯誤處理邏輯，並提供適當的用戶提示。

 ---
 
 - 程式碼示例：
 
     ```swift
     private func loadData() {
         HUDManager.shared.showLoading(text: "Loading...")
         Task {
             await withTaskGroup(of: Void.self) { group in
                 group.addTask { await self.loadMenuDrinkCategories() }
                 group.addTask { await self.loadWebsites() }
             }
             HUDManager.shared.dismiss()
         }
     }
     ```

 ---

 - 與單獨使用 `Task` 的比較：
 
   1. 單獨使用 `Task`：
 
      - 需要在每個任務內分別處理完成狀態，並逐個更新界面。
      - 容易導致視圖更新不同步，使用者體驗不一致。
 
   2. 使用 `TaskGroup`：
 
      - 集中管理所有任務的執行和完成狀態，確保結果一致性。

 ---------

 `* 結論`

 - 使用 `withTaskGroup` 是合適的解決方案，因為它：
 
   1. 提升效能：任務並行執行，減少總的執行時間。
   2. 改善體驗：確保所有數據同時更新，避免內容跳動。
   3. 提升可維護性：邏輯集中化，減少手動管理多個任務完成狀態的代碼複雜度。
   4. 擴展性強：未來新增更多的加載任務，只需添加到群組中即可，無需調整整體結構。
 */


// MARK: - MenuViewController 筆記
/**
 
 ### MenuViewController 筆記


 `* What`
 
 - `MenuViewController` 是一個負責顯示飲品分類和網站橫幅的主要頁面控制器，核心功能包括：
 
 1. UI 配置與佈局：
 
    - 使用 `MenuView` 管理頁面主要視圖，減少控制器內的 UI 邏輯。
    - 配置 `UICollectionView` 以顯示網站橫幅和飲品分類。
 
 2. 數據加載：
 
    - 從 Firestore 加載飲品分類和網站橫幅數據。
    - 使用異步並行任務提升數據加載效率。
 
 3. 導航邏輯：
 
    - 通過 `MenuHandlerDelegate` 處理用戶點擊事件，導航到具體的飲品分類頁面或外部網站。
 
 4. 導航欄管理：
 
    - 使用 `MenuNavigationBarManager` 配置標題和樣式，支持大標題模式。

 --------

 `* Why`
 
 1. 職責分離：
 
    - 控制器專注於數據加載和用戶交互，視圖佈局由 `MenuView` 處理，數據管理由 `MenuDrinkCategoryManager` 和 `MenuWebsiteManager` 負責，符合單一職責原則 (SRP)。
    - 減少控制器的耦合，讓邏輯更清晰且模組化。
 
 2. 可擴展性與可維護性：
 
    - 將導航邏輯抽象到 `MenuHandlerDelegate` 中，方便未來擴展其他導航需求。
    - 使用管理類（如 `MenuNavigationBarManager`）集中處理導航欄邏輯，避免樣式相關代碼與業務邏輯混雜。
 
 3. 提升用戶體驗：
 
    - 異步並行加載數據提高頁面加載速度。
    - 使用 HUD 指示加載狀態，避免用戶不確定操作進度。

 --------

 `* How`
 
 1. UI 配置：
 
    - 初始化時將 `MenuView` 作為主視圖，並通過 `configureCollectionView` 將 `MenuCollectionHandler` 配置為 `UICollectionView` 的數據源和委託。
    - 使用 `MenuNavigationBarManager` 配置導航欄標題和樣式，簡化導航欄相關代碼。

 2. 數據加載：
 
    - 利用 `Task` 和 `withTaskGroup` 並行調用 `loadMenuDrinkCategories` 和 `loadWebsites` 方法，分別從 `MenuDrinkCategoryManager` 和 `MenuWebsiteManager` 加載數據。
    - 加載完成後將數據傳遞給 `MenuCollectionHandler` 並刷新視圖。

 3. 導航邏輯：
 
    - 點擊網站橫幅時，通過 `openWebsite(url:)` 方法使用 `UIApplication.shared.open` 打開外部網站。
    - 點擊飲品分類時，通過 `navigateToCategory(category:)` 方法實例化並導航至 `DrinksCategoryViewController`，傳遞分類的 `id` 和 `title`。

 4. 錯誤處理：
 
    - 數據加載失敗時，使用 `AlertService` 顯示錯誤提示，提升用戶體驗。

 --------

 `* 示例架構總結：`
 
 - `MenuViewController` 的設計實現以下目標：
 
 1. 高內聚低耦合：
 
    - 控制器專注於業務邏輯，導航邏輯抽象到 `MenuHandlerDelegate`，數據層通過管理類隔離。
 
 2. 用戶體驗：
 
    - 直觀的導航邏輯，異步加載數據提升性能，HUD 提示進度避免用戶等待時的不確定性。

 --------

 `* 設計擴展想法`
 
 - 加入本地緩存：未來可在 `MenuDrinkCategoryManager` 和 `MenuWebsiteManager` 中加入本地緩存支持，進一步優化加載速度。
 - 錯誤重試機制：加入按鈕讓用戶手動重試數據加載，避免加載失敗時用戶陷入無法操作的狀態。
 - 可配置化導航欄：讓 `MenuNavigationBarManager` 支持更多樣式的導航欄定制需求，例如按頁面設置不同背景色或按鈕樣式。
 */



// MARK: - (v)


import UIKit

/// `MenuViewController` 負責展示飲品分類與網站橫幅的主要頁面。
///
/// - 主要功能:
///   1. 管理菜單頁面的 UI 佈局，通過 `MenuView` 顯示內容。
///   2. 使用 `MenuCollectionHandler` 處理 `UICollectionView` 的數據源和委託邏輯。
///   3. 使用 `MenuDrinkCategoryManager` 和 `MenuWebsiteManager` 加載飲品分類和網站橫幅數據。
///   4. 配置導航欄樣式，提供標題和大標題支持。
///
/// - 設計原則:
///   1. 單一職責原則 (SRP):
///      - 負責菜單頁面顯示與用戶交互邏輯，不直接處理數據加載和導航邏輯。
///   2. 依賴倒置原則 (DIP):
///      - 依賴於抽象管理類（如 `MenuDrinkCategoryManager` 和 `MenuWebsiteManager`），而非具體的數據層。
///   3. 高內聚低耦合:
///      - 控制器與數據層和視圖層的耦合最小化，邏輯模組化以便於維護。
///
/// - 使用場景:
///   1. 在應用的菜單頁面中顯示飲品分類和網站橫幅內容。
///   2. 支持用戶點擊分類後導航到具體的飲品列表頁面。
///   3. 支持用戶點擊網站橫幅後打開外部網站連結。
class MenuViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 菜單主視圖，負責顯示網站橫幅與飲品分類。
    private let menuView = MenuView()
    
    /// 管理 `UICollectionView` 的數據源與委託邏輯。
    private let menuCollectionHandler = MenuCollectionHandler()
    
    /// 管理飲品分類數據的業務邏輯。
    private let menuDrinkCategoryManager = MenuDrinkCategoryManager()
    
    /// 管理導航欄標題與樣式的類別。
    private var menuNavigationBarManager: MenuNavigationBarManager?
    
    // MARK: - Lifecycle Methods
    
    /// 設置主視圖。
    override func loadView() {
        view = menuView
    }
    
    /// 配置導航欄、`UICollectionView` 並加載數據。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        loadData()
    }
    
    // MARK: - Setup Methods
    
    /// 配置導航欄樣式與標題。
    ///
    /// 此方法使用 `MenuNavigationBarManager` 集中管理導航欄的配置。
    private func configureNavigationBar() {
        menuNavigationBarManager = MenuNavigationBarManager(
            navigationItem: self.navigationItem,
            navigationController: self.navigationController
        )
        menuNavigationBarManager?.configureNavigationBarTitle(title: "Starbucks", prefersLargeTitles: true)
    }
    
    /// 配置 `UICollectionView` 的數據源與委託。
    ///
    /// - 配置內容:
    ///   1. 將 `menuCollectionHandler` 設為數據源和委託。
    ///   2. 為 `menuCollectionHandler` 設置 `MenuHandlerDelegate`，用於處理導航邏輯。
    private func configureCollectionView() {
        menuView.menuCollectionView.dataSource = menuCollectionHandler
        menuView.menuCollectionView.delegate = menuCollectionHandler
        menuCollectionHandler.menuHandlerDelegate = self
    }
    
    // MARK: - Data Loading
    
    /// 加載菜單頁面的數據，包括飲品分類和網站橫幅。
    ///
    /// 使用異步任務組並行加載數據，確保高效性，並在加載完成後隱藏 HUD。
    private func loadData() {
        HUDManager.shared.showLoading(text: "Loading...")
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadMenuDrinkCategories() }
                group.addTask { await self.loadWebsites() }
            }
            HUDManager.shared.dismiss()
        }
    }
    
    /// 加載網站橫幅數據。
    ///
    /// - 說明:
    ///   1. 調用 `MenuWebsiteManager` 獲取網站橫幅數據。
    ///   2. 將數據傳遞給 `menuCollectionHandler` 並刷新視圖。
    /// - 錯誤處理:
    ///   若加載失敗，會彈出錯誤提示框。
    private func loadWebsites() async {
        do {
            let websites = try await MenuWebsiteManager.shared.loadWebsites()
            self.menuCollectionHandler.websites = websites
            self.menuView.menuCollectionView.reloadData()
        } catch {
            print("[MenuViewController]: Error loading websites: \(error)")
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
    }
    
    /// 加載飲品分類數據。
    ///
    /// - 說明:
    ///   1. 調用 `MenuDrinkCategoryManager` 獲取分類數據。
    ///   2. 將數據轉換為展示模型並傳遞給 `menuCollectionHandler`。
    ///   3. 刷新 `UICollectionView`。
    /// - 錯誤處理:
    ///   若加載失敗，會彈出錯誤提示框。
    private func loadMenuDrinkCategories() async {
        do {
            let menuCategories = try await menuDrinkCategoryManager.fetchMenuDrinkCategories()
            // 更新展示模型到 collectionHandler
            self.menuCollectionHandler.drinkCategories = menuCategories
            self.menuView.menuCollectionView.reloadData()
        } catch {
            print("[MenuViewController]: Error loading menu categories: \(error)")
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
    }
    
}


// MARK: - MenuHandlerDelegate
extension MenuViewController: MenuHandlerDelegate {
    
    /// 打開網站連結。
    ///
    /// - Parameter url: 要打開的網站 URL。
    func openWebsite(url: URL) {
        AlertService.showAlert(
            withTitle: "打開連結",
            message: "確定要打開這個連結嗎？",
            inViewController: self,
            showCancelButton: true
        ) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    /// 導航至飲品分類頁面。
    ///
    /// - Parameter category: 飲品分類的展示模型。
    func navigateToCategory(category: MenuDrinkCategoryViewModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let drinksCategoryVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.drinksCategoryViewController) as? DrinksCategoryViewController else {
            print("[MenuViewController]: Failed to instantiate DrinksCategoryViewController with identifier: \(Constants.Storyboard.drinksCategoryViewController)")
            return
        }
        
        drinksCategoryVC.categoryId = category.id
        drinksCategoryVC.categoryTitle = category.title
        self.navigationController?.pushViewController(drinksCategoryVC, animated: true)
    }
    
}
