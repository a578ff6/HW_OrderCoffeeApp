//
//  MenuViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//


/*
 ## MenuViewController：
 
    * 功能： 顯示飲品分類和網站橫幅，允許使用者點擊進入飲品詳細頁面或打開網站連結。

    * 視圖設置： 透過 MenuView 設置主要視圖，並使用 MenuCollectionHandler 處理 UICollectionView 的資料顯示和用戶互動。

    * 資料加載：使用 TaskGroup 同步加載網站橫幅與飲品分類，資料完成後刷新界面，並使用 HUDManager 來管理加載狀態顯示。

    * 數據處理：
        - MenuCollectionHandler： 負責 UICollectionView 的 dataSource 和 delegate 方法，包括顯示網站橫幅、飲品分類，並處理點擊事件。
            1. 點擊網站橫幅： 使用者點擊後打開對應的網站連結。
            2. 點擊飲品分類： 將選中的分類資料傳遞給 DrinksCategoryViewController。


    * 主要流程：
 
        - 資料加載： 透過 TaskGroup 同步執行 loadWebsites() 和 loadCategories()，同時加載網站橫幅和飲品分類，完成後一併隱藏 HUDManager。
        - 資料顯示與刷新： 當資料加載成功後，使用 reloadData() 來更新 UICollectionView，確保網站橫幅和飲品分類同步顯示。
        - 導航： 點擊飲品分類後，透過 prepare(for segue:) 傳遞資料給 DrinksCategoryViewController。

    * 主要功能概述：
        - 資料並行加載：使用 TaskGroup 保證網站橫幅和飲品分類同時加載，提升效率並優化顯示順序。
        - 視圖管理：MenuView 和 MenuCollectionHandler 分別負責視圖顯示與資料處理，清楚劃分了業務邏輯與 UI 顯示。
        - 導航與互動：使用者點擊飲品分類或網站橫幅後，對應的操作（導航或打開連結）透過委派回調實現，簡化了控制器內的邏輯。
 
 -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 ## 非同步加載的順序問題與 TaskGroup 解決方案：
 
    & 問題描述：
        - 在進入 MenuViewController 時，發現兩個非同步資料加載操作（飲品分類和網站橫幅）是依次進行的，導致 飲品分類 先顯示，而 網站橫幅 較慢且突然出現。這是因為：
 
            * await loadCategories() 和 await loadWebsites() 按順序執行，第一個任務完成後，才開始執行第二個任務。（調整順序的話也會跟著順序變動去執行）
            * 由於兩個加載任務的響應時間不同，結果會讓一個內容（飲品分類）先顯示，另一個內容（網站橫幅）稍後出現，造成不一致的使用者體驗。

    & 解決方法：
        - 使用 TaskGroup，可以 「並行執行」 這兩個資料加載任務，而非「依次執行」。這樣，兩個加載操作會同時進行，不論哪個任務先完成，結果會一起顯示，避免「一個先出現，另一個突然出現」的情況。
 
    & TaskGroup 具體步驟：
        - 使用 withTaskGroup 創建並行任務群組。
        - 在群組中添加兩個並行的非同步資料加載操作：loadCategories() 和 loadWebsites()。
        - 當所有任務完成後，進行後續處理，如隱藏載入中的提示（HUD）。

    & 改善部分：
        - 並行加載：TaskGroup 能讓不同的資料加載操作同時進行，提升效率。
        - 資料顯示一致性：確保所有資料在同一時間加載完成，避免「突然出現」的情況。
        - 程式碼簡化：不需要「手動追蹤」每個資料是否加載完成，TaskGroup 自動處理並行執行後的邏輯。
 */

// MARK: - async/await 版本、TaskGroup
import UIKit

/// 負責顯示飲品分類頁面、網站橫幅的視圖控制器。
class MenuViewController: UIViewController {

    // MARK: - Properties
    
    private let menuView = MenuView()
    private let collectionHandler = MenuCollectionHandler()
    
    /// 定義 Menu 頁面的不同 section
    enum MenuSection: Int, CaseIterable {
        case websiteBanner // 顯示網站橫幅
        case drinkCategories // 顯示飲品分類
    }

    // MARK: - Lifecycle Methods

    override func loadView() {
        view = menuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        HUDManager.shared.showLoading(text: "Loading...")
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadCategories() }
                group.addTask { await self.loadWebsites()}
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Setup Methods
    
    /// 配置 UICollectionView 的 dataSource、delegate，並註冊自定義的單元格類別。
    private func configureCollectionView() {
        menuView.collectionView.dataSource = collectionHandler
        menuView.collectionView.delegate = collectionHandler
        collectionHandler.delegate = self        // 將 MenuViewController 設置為 delegate，以便處理導航
    }
    
    // MARK: - Data Loading (using async/await)

    /// 加載網站橫幅資料，並將資料傳遞給 collectionHandler 來顯示於 UICollectionView 中。
    private func loadWebsites() async {
        do {
            let websites = try await WebsiteManager.shared.loadWebsites()
            self.collectionHandler.websites = websites
            self.menuView.collectionView.reloadData()
        } catch {
            print("Error loading websites: \(error)")
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
    }
    
    /// 加載飲品分類資料，並將資料傳遞給 collectionHandler 來顯示於 UICollectionView 中。
    private func loadCategories() async {
        do {
            let categories = try await MenuController.shared.loadCategories()
            self.collectionHandler.categories = categories
            self.menuView.collectionView.reloadData()
        } catch {
            print("Error loading categories: \(error)")
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
    }
    
    // MARK: - Navigation
    
    /// 當用戶點擊某個分類時，將選中的分類資料傳遞給 DrinksCategoryCollectionViewController。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.categoryToDrinksSegue,
           let destinationVC = segue.destination as? DrinksCategoryViewController,

           let selectedCategory = sender as? Category {
            destinationVC.categoryId = selectedCategory.id
            destinationVC.categoryTitle = selectedCategory.title
        }
    }
    
    /// 打開指定的網站 URL。
    func openWebsite(url: URL) {
        AlertService.showAlert(withTitle: "打開連結", message: "確定要打開這個連結嗎？", inViewController: self, showCancelButton: true) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}




// MARK: - 已完善（DispatchQune版本）
/*
import UIKit

/// 負責顯示飲品分類頁面、網站橫幅的視圖控制器。
class MenuViewController: UIViewController {

    // MARK: - Properties
    
    private let menuView = MenuView()
    private let collectionHandler = MenuCollectionHandler()
    
    /// 定義 Menu 頁面的不同 section
    enum MenuSection: Int, CaseIterable {
        case websiteBanner // 顯示網站橫幅
        case drinkCategories // 顯示飲品分類
    }
    
    // 用來追踪網站和分類資料是否加載完成。
    private var isWebsiteLoaded = false
    private var isCategoriesLoaded = false

    // MARK: - Lifecycle Methods

    override func loadView() {
        view = menuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        HUDManager.shared.showLoading(in: self.view, text: "Loading...")
        loadWebsites()
        loadCategories()
    }

    
    // MARK: - Setup Methods
    
    /// 配置 UICollectionView 的 dataSource、delegate，並註冊自定義的單元格類別。
    private func setupCollectionView() {
        menuView.collectionView.dataSource = collectionHandler
        menuView.collectionView.delegate = collectionHandler
        menuView.collectionView.register(WebsiteImageCell.self, forCellWithReuseIdentifier: WebsiteImageCell.reuseIdentifier)
        menuView.collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        menuView.collectionView.register(MenuSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MenuSectionHeaderView.headerIdentifier)
        collectionHandler.delegate = self        // 將 MenuViewController 設置為 delegate，以便處理導航
    }

    
    // MARK: - Data Loading
 
    /// 加載網站橫幅資料，並將資料傳遞給 collectionHandler 來顯示於 UICollectionView 中。
    private func loadWebsites() {
        WebsiteManager.shared.loadWebsites { [weak self] result in
            switch result {
            case .success(let websites):
                self?.collectionHandler.websites = websites
                self?.isWebsiteLoaded = true
                self?.checkIfAllDataLoaded()
                self?.menuView.collectionView.reloadData()
            case .failure(let error):
                print("Error loading websites: \(error)")
                self?.isWebsiteLoaded = true
                self?.checkIfAllDataLoaded()
            }
        }
    }
    
    /// 加載飲品分類資料，並將資料傳遞給 collectionHandler 來顯示於 UICollectionView 中。
    private func loadCategories() {
        MenuController.shared.loadCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.collectionHandler.categories = categories
                    self?.isCategoriesLoaded = true
                    self?.checkIfAllDataLoaded()
                    self?.menuView.collectionView.reloadData()
                case .failure(let error):
                    print("Error loading categories: \(error)")
                    AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self!)
                    self?.isCategoriesLoaded = true
                    self?.checkIfAllDataLoaded()
                }
            }
        }
    }
    
    /// 每次加載任務完成後都會來檢查所有數據是否都已加載，並在所有數據加載完成後隱藏 HUD。
    private func checkIfAllDataLoaded() {
        if isWebsiteLoaded && isCategoriesLoaded {
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Navigation
    
    /// 當用戶點擊某個分類時，將選中的分類資料傳遞給 DrinksCategoryCollectionViewController。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.categoryToDrinksSegue,
           let destinationVC = segue.destination as? DrinksCategoryViewController,

           let selectedCategory = sender as? Category {
            destinationVC.categoryId = selectedCategory.id
            destinationVC.categoryTitle = selectedCategory.title
        }
    }
    
    /// 打開指定的網站 URL。
    func openWebsite(url: URL) {
        AlertService.showAlert(withTitle: "打開連結", message: "確定要打開這個連結嗎？", inViewController: self, showCancelButton: true) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
*/
