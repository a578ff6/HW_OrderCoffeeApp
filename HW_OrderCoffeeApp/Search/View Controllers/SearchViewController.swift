//
//  SearchViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//

// https://reurl.cc/6jVkrb

// MARK: - 初步構想_搜尋視圖控制器設計與導航流程的概念筆記
/**
 ## 初步構想_搜尋視圖控制器設計與導航流程的概念筆記
 
 `1. 搜尋視圖控制器導航流程`
 
 - 在搜尋結果中，點擊項目進入 `DrinkDetailViewController` 的設計。這樣用戶可以快速找到所需飲品並查看詳細資訊，符合一般搜尋流程的用戶體驗需求。
 - 導航適合度：這樣的設計符合主導航結構 (`MainTabBarController`)，能夠保持整體流程的簡單與清晰。
 
` 2. 使用 UISearchController 搭配 UITableView 的搜尋功能`
 
 - `UISearchController` 搜尋控制器，特別適合用於列表型的頁面中（例如 `UITableView`），它能即時提供過濾功能。
 
 - `優點`：
    - `UISearchController` 提供搜尋框的顯示與隱藏動畫，以及輸入文字後的即時過濾，能提升搜尋效率。
    - 搭配 `UITableView` 來展示搜尋結果是很適合的選擇，因為 UITableView 支援可重用的單元格顯示多筆資料，且操作簡單效能高。
 
` 3. 是否建議設置搜尋視圖控制器的 Model`
 
 - 建議設置「搜尋視圖控制器的 Model」，這可以讓搜尋邏輯更清晰且便於維護。
 
 - `設置 Model 的優點`：
    - `資料分離`：透過設置 `SearchModel`，可以將資料處理和搜尋邏輯從視圖控制器中抽離，符合單一職責原則（SRP）。
    - `資料管理`：將搜尋過程中的資料管理集中在 Model，能更方便進行單元測試與驗證。
    - `擴展性`：未來如果增加例如「熱門搜尋」或「搜尋建議」等功能，Model 的設計會讓擴展更加方便。

 `4.初步程式碼的建議`
 
 - `現有設置包括`：SearchViewController、SearchCell、SearchView、SearchHandler、SearchManager、SearchResultsDelegate。
 
 - `SearchViewController`：負責顯示搜尋頁面，整合 UISearchController。
 - `SearchCell`：自定義單元格來顯示搜尋結果，可以展示飲品名稱、圖片等資訊。
 - `SearchView`：用於設計搜尋頁面的靜態視圖元素，例如標題或背景。
 - `SearchHandler`：作為 UITableView 的數據源和委託，負責處理搜尋過程中的資料管理和用戶操作。
 - `SearchManager`：負責從 Firestore 加載資料，以及處理與後端的交互。
 - `SearchResultsDelegate`：用於搜尋完成後，將選定的飲品資訊傳遞到其他視圖控制器，例如 DrinkDetailViewController。

 `5.小結`
 
 - `導航流程`：從搜尋結果進入 `DrinkDetailViewController` 。
 - `使用 UISearchController 和 UITableView`：適合用於搜尋功能的動態過濾與結果展示。
 - `設置搜尋視圖控制器的 Model`：符合單一職責原則，讓資料邏輯和視圖分離，並提升代碼的可維護性與擴展性。
 */


// MARK: - SearchHandler 的設置情境重點筆記
/**
 ## SearchHandler 的設置情境重點筆記

 `1. searchHandler 的設置為可選類型 (?) 或非可選類型的選擇`
    - 若 `SearchHandler` 能在 `viewDidLoad()` 中即刻進行初始化，則推薦使用`非可選類型`，這樣可以保證 `searchHandler` 一定存在，更為安全和清晰。
    - 若 `SearchHandler` 需要根據特定條件延遲初始化，或者在某些情況下不需要存在，則使用`可選類型` (`private var searchHandler: SearchHandler?`) 會更合適。例如：
      - 需要等待某些數據加載完成之後才能初始化 `SearchHandler`。
      - `SearchHandler` 的存在依賴於某些外部條件。

 `2. 參考其他視圖控制器中的設置`
    - 在 `OrderHistoryViewController` 中使用 `private var orderHistoryHandler: OrderHistoryHandler?`，是因為該 handler 的初始化依賴於訂單數據的加載。
    - 對比 `SearchViewController`，若 `searchHandler` 的初始化也需要依賴其他條件，例如需要在初始數據加載後或特定操作後才進行初始化，那麼設置為`可選類型`更合適。
    - 若初始化不涉及異步或特定條件的延遲，則應考慮使用非可選類型，減少額外的可選值處理，讓代碼更簡潔。

 `3. 延遲初始化的優缺點`
    - `優點`：可以在數據準備就緒後才初始化，避免不必要的初始化操作，減少內存消耗。
    - `缺點`：需要在每次使用前進行判斷是否為 `nil`，增加了代碼的複雜性。

 `4. 實際想法`
    - 若 `searchHandler` 的初始化不依賴外部條件，可以直接在 `viewDidLoad()` 中初始化，並使用非可選類型 (`let`) 來保持代碼的簡單性和安全性。
    - 若需延遲初始化，則設置為可選類型 (`var`) 並在需要時初始化，這樣設計會更靈活，並符合延遲需求的情境。
 */

// MARK: - 搜尋視圖控制器的 SearchHandler 初始化方式（補充）
/**
 ## 搜尋視圖控制器的 SearchHandler 初始化方式
 
    - 搜尋視圖控制器中的 SearchHandler 更適合延遲初始化，因為它的初始化取決於視圖控制器的生命周期及其需要與 `SearchResultsDelegate` 的協同工作。

 `1.立即初始化 (let searchHandler = SearchHandler())`

 `* 優點：`
 - 簡單且代碼清晰，無需在其他地方進行額外的初始化處理。
 - SearchHandler 立即可用，適合在頁面顯示後立即需要的情境。

 `* 缺點：`
 - 無法在初始化時設置 delegate，導致使用前需要額外設置，並可能出現未準備好的情況。
 
 `2.延遲初始化 (private var searchHandler: SearchHandler?)`

 `* 優點：`
 - 可以靈活地在適當的時機設置 delegate，例如在 viewDidLoad() 中。
 - 只在需要的時候初始化，可以更好地節省內存，尤其是當某些功能僅在特定條件下使用時。

 `* 缺點：`
 - 需要處理可選值的情況，每次使用前需確保已經初始化，增加了些許代碼複雜性。
 
 `3.搜尋視圖控制器中的適用性`

 `* 延遲初始化更合適`：
 - 在 `SearchViewController` 中，SearchHandler 負責搜尋結果顯示，而它的初始化需要 delegate 為視圖控制器本身，因此更適合延遲初始化。

 `* 需要根據條件設置：`
 - `SearchHandler` 的初始化需要依賴於 delegate 已經完全準備好，因此在適當時機進行初始化比立即初始化更符合需求。
 
 `4 想法選擇`
 
 - `延遲初始化 SearchHandler`：
    - 在 `SearchViewController` 中，使用 var searchHandler: SearchHandler?，並在 viewDidLoad() 中進行初始化，以確保 delegate 可以被適當設置。

 - `立即初始化的情境`：
    - 如果 SearchHandler 不需要依賴外部條件或 delegate，則可以考慮使用非可選類型 (let) 來保持代碼的簡單性和安全性。
 */


// MARK: - SearchViewController 筆記
/**
 
 ## SearchViewController 筆記
  
` 1.設計目的`

 - `SearchViewController` 是搜尋頁面的核心，負責顯示搜尋結果，並管理與使用者的交互。
 - 在設計過程中，將搜尋的顯示、控制器的設置、導航欄設置，以及數據加載等職責分開來處理，以減少耦合度並提升代碼的可讀性和可維護性。

 `2.屬性與責任分配`

 - `searchView`：自定義的主視圖，包含了展示搜尋結果的 UITableView。在 loadView 階段設定，確保在視圖加載前即設置好正確的視圖。
 - `searchHandler`：處理搜尋結果的顯示和用戶操作，使用延遲初始化以便在需要時才進行設置，確保其他初始化已完成。
 - `searchManager`：負責從 Firebase 獲取搜尋數據。提供了搜尋資料的加載和過濾功能，是數據層的核心。
 - `searchControllerManager`：管理 UISearchController 的設置和交互，使用委託來通知 SearchViewController 關於搜尋行為的變化。
 - `searchNavigationBarManager`：負責設置導航欄標題和相關的按鈕，將與導航欄相關的邏輯集中管理，以保持 SearchViewController 的簡潔。

 `3.分離關心點的實踐`

 - UI 部分 (`SearchView`) 與資料部分（如 `SearchManager` 和 `SearchHandler`）分離，避免一個類過多的職責，使代碼更容易管理。
 - `SearchControllerManager`：專門處理與 UISearchController 相關的邏輯，例如搜尋欄文字更新和取消搜尋的回應。這樣可以避免 SearchViewController 因為搜尋交互邏輯而過於臃腫。
 - `SearchNavigationBarManager`：專門處理與導航欄相關的配置，例如標題設置和按鈕配置，避免將導航欄邏輯直接寫入 SearchViewController，以保持代碼模組化。

 `4.使用委託的設計`

 - `使用 SearchResultsDelegate 和 SearchControllerInteractionDelegate 兩個委託`：
    - `SearchResultsDelegate`：主要負責管理搜尋結果數據和與 SearchHandler 的交互，例如返回目前的搜尋結果和處理用戶選擇。
    - `SearchControllerInteractionDelegate`：負責 UISearchController 的交互行為，例如當使用者輸入搜尋字串或取消搜尋時的回應。
    - 通過這些委託， SearchViewController 可以有效地將資料層和交互層分開，減少代碼的耦合性，提升可維護性。
 
 `5.處理搜尋控制器的設置`
 
 - 在 `setupSearchController() `中，利用 `SearchControllerManager` 來管理 UISearchController 的設置，避免將這些配置邏輯直接寫在 SearchViewController 中，保持控制器的簡潔。
 - `SearchControllerManager` 的設計讓搜尋行為的管理與頁面控制器分開，使得代碼更具模組化和可重用性。
 - 在 `setupNavigationBar() `中，利用 `SearchNavigationBarManager` 來設置導航欄的標題和大標題顯示模式，讓與導航欄相關的邏輯更具模組化和可重用性。
 
 `6.didUpdateSearchText` 和 `didCancelSearch`和 `didSelectSearchResult` 的處理

 - `didUpdateSearchText(_:)`：當搜尋文字更新時，調用此方法過濾目前的搜尋結果，這使得搜尋功能對用戶的操作反應更即時。
 - `didCancelSearch()`：當取消搜尋時，調用此方法以立即清空搜尋結果，並且更新提示文字。
 - `didSelectSearchResult(_:)`：當使用者選擇某個搜尋結果時，會導航至 `DrinkDetailViewController` 顯示飲品的詳細資訊。

 `7.總結`
 
 - 職責分離 是本設計的核心，將視圖、資料處理和交互管理劃分開來，利用各種管理器（如 `SearchHandler` 和 `SearchControllerManager`）來降低耦合，讓每個部分只專注於自身的職責。
 - 使用 委託模式 來處理搜尋過程中的數據變化和用戶交互，這樣可以確保 `SearchViewController` 專注於頁面邏輯，並將其他操作交由專門的模組處理。
 - SearchControllerManager 的引入使得 UISearchController 的相關邏輯能夠集中管理，避免過多地污染主要控制器的代碼，提升可維護性。
 */


// MARK: - 搜尋狀態設計與提示訊息顯示（重要）
/**
 
 ## 搜尋狀態設計與提示訊息顯示

 `* 在設計搜尋頁面的提示訊息顯示時，有兩種主要的考量方式：`

` 1. 初始進入搜尋頁面時顯示提示訊息：`
    - 當使用者剛進入搜尋頁面時，顯示「Please enter search keywords」這樣的提示訊息，可以引導使用者進行下一步操作。

 `2. 根據與 UISearchController 的互動來顯示提示訊息：`
    - 當使用者與搜尋框有互動（如點擊、輸入或取消）時，根據不同狀態顯示不同的提示。例如：
        - 使用者點擊搜尋框但未輸入文字時，顯示「Please enter search keywords」。
        - 當使用者開始輸入但無符合結果時，顯示「No Results」。
        - 當使用者按下取消按鈕 (`cancel`) 結束搜尋時，回到初始狀態，再次顯示「Please enter search keywords」。

 
 `* 設計方式`

 - 基於以上考量，較直觀的做法是根據`使用者是否進行搜尋操作`來顯示對應的提示訊息，具體邏輯如下：

 `1. 初始進入頁面`：顯示「Please enter search keywords」引導使用者。
 
 `2. 使用者點擊搜尋框`：保持顯示「Please enter search keywords」，直到使用者開始輸入文字。
 
 `3. 使用者開始輸入`：
    - 如果搜尋結果為空，顯示「No Results」。
    - 如果有符合結果，顯示搜尋結果。
 
 `4. 使用者按下取消`：清空搜尋結果，再次顯示「Please enter search keywords」。

 
 `* 這樣設計的好處在於：`
 - 每個狀態的提示訊息都是基於使用者操作，符合一般使用者的直覺，能更好地引導使用者完成搜尋。
 - 初始狀態與取消搜尋的狀態保持一致，顯示「Please enter search keywords」，使介面顯得簡潔且容易理解。
 */


// MARK: - 搜尋視圖的返回狀態處理想法（補充想法）
/**
 
 ## 搜尋視圖的返回狀態處理想法

 `1. What: 搜尋視圖返回的狀態處理`
 
 - 主要是在操作像是Podcast、ig等搜尋功能時所觀察到的部分。
 - 當用戶從搜尋視圖導航至其他頁面（飲品詳細頁面）並返回時，需要決定搜尋視圖應保持原有的狀態還是重置為初始狀態。
 - 這包括搜尋框中的文字、搜尋結果列表的顯示狀態，以及 UI 的其他相關元素。

 `2. Why: 保持狀態與重置狀態的考量`
 
 `* 保持狀態的理由`
    - `提升用戶體驗`：保持搜尋視圖的狀態能提升用戶體驗，因為用戶可能希望繼續查看之前的搜尋結果，或者選擇其他結果。
    - `減少操作重複性`：如果用戶多次來回切換，保持狀態可以避免用戶重新輸入搜尋文字並再次查找。
    - `一致性`：保持狀態與許多應用程序的行為一致，例如使用搜尋功能後返回列表，大多數應用都會保持搜尋框的內容和結果。
 
 `* 重置狀態的理由`
    - `清爽的界面`：在某些應用場景下，用戶可能希望在返回搜尋頁面時看到一個乾淨的界面，避免被之前的搜尋干擾。
    - `頁面刷新考慮`：有時候，搜尋結果可能因數據變更而過時，重置狀態可以確保用戶看到最新的內容。
    - `特定場景需求`：在特定場景下，重置狀態可能符合業務邏輯需求，例如用戶每次返回應看到最新的推薦內容。
 
 `3. How: 如何實現搜尋視圖的返回狀態管理`
 
 `* 保持狀態的方式`
    - 狀態保存：在用戶離開搜尋視圖時，將搜尋框的文字和結果保存在一個變數或模型中。當用戶返回時，根據保存的狀態重新配置視圖（例如恢復搜尋文字和結果列表）。
    - 頁面暫留：如果視圖控制器並未被釋放（例如使用 navigationController 推入下一個控制器），則其狀態會自然保留，用戶返回時可直接看到先前的狀態。
 
 `* 重置狀態的方式`
    - 清空狀態：在 viewWillAppear 或 viewDidAppear 中，重置搜尋框的文字、清空結果列表，將界面恢復到初始狀態。
    - 條件重置：可以根據具體情境來決定是否重置，例如檢查用戶返回的時間間隔，如果間隔過長則進行重置。
 
 `4. 想法`
 
 - 保持狀態：
    - 大多數情況下，建議保持搜尋視圖的狀態，這樣可以提高用戶體驗，讓用戶方便地返回並繼續操作，尤其是當搜尋結果涉及多個步驟或者用戶可能需要查看多個結果時。
 
 - 重置狀態：
    - 在一些特定情境下（例如應用性能受影響，或用戶習慣需要更清爽的界面），可以考慮重置狀態。可以根據用戶反饋或業務需求來決定具體的策略。
 */



// MARK: - 啟動 App 時加載搜尋資料

import UIKit

/// `SearchViewController` 負責管理搜尋頁面，包括顯示搜尋結果和處理用戶交互
class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 自定義的 `SearchView`，包含搜尋結果列表的 UI 元素
    private let searchView = SearchView()
    
    /// `SearchHandler` 處理搜尋結果的顯示及用戶操作，設置為可選類型以便延遲初始化
    private var searchHandler: SearchHandler?
    
    /// 使用單例模式的 `SearchManager` 來管理加載飲品資料
    private let searchManager = SearchManager.shared
    
    /// `SearchControllerManager` 負責管理 `UISearchController` 的設置和交互
    private var searchControllerManager: SearchControllerManager?
    
    /// `SearchNavigationBarManager` 導航欄管理器，用於設置導航欄按鈕和標題
    private var searchNavigationBarManager: SearchNavigationBarManager?
    
    /// 搜尋結果資料
    /// - 當搜尋結果資料變更時，自動更新表格視圖以顯示最新的搜尋結果
    private var searchResults: [SearchResult] = [] {
        didSet {
            searchView.tableView.reloadData()
            updateSearchViewState()
        }
    }
    
    // MARK: - Lifecycle Methods
    
    /// 設置主視圖為自定義的 `SearchView`
    override func loadView() {
        view = searchView
    }
    
    /// 視圖加載完成後，設置處理器和搜尋控制器
    /// - 初始化 `SearchHandler`、`SearchControllerManager` 以及 `SearchNavigationBarManager`，以便管理搜尋行為、顯示結果和設置導航欄
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandler()
        setupSearchController()
        setupNavigationBar()
        searchView.updateView(for: .initial)
    }
    
    // MARK: - Setup Methods
    
    /// 初始化 `SearchHandler` 並設置表格的數據源與委託，以便處理搜尋結果的顯示和用戶操作
    private func setupHandler() {
        searchHandler = SearchHandler(delegate: self)
        if let searchHandler = searchHandler {
            searchView.tableView.dataSource = searchHandler
            searchView.tableView.delegate = searchHandler
        }
    }
    
    /// 初始化 `SearchControllerManager` 並將搜尋控制器附加到視圖控制器上
    private func setupSearchController() {
        searchControllerManager = SearchControllerManager(delegate: self)
        searchControllerManager?.attach(to: self)
    }
    
    /// 設置導航欄
    /// - 使用 `SearchNavigationBarManager` 來設置導航欄標題及大標題顯示模式
    private func setupNavigationBar() {
        searchNavigationBarManager = SearchNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        searchNavigationBarManager?.configureNavigationBarTitle(title: "Search Drinks", prefersLargeTitles: true)
    }
    
    // MARK: - Data Fetching
    
    /// 根據關鍵字過濾本地飲品資料
    /// - Parameter keyword: 搜尋的關鍵字
    /// - 使用 `SearchManager` 中的快取資料來進行本地過濾，以提升搜尋的速度
    private func filterSearchData(with keyword: String) {
        Task {
            do {
                let drinks = try await searchManager.searchDrinks(with: keyword)
                searchResults = drinks
                print("根據關鍵字 '\(keyword)' 過濾得到 \(drinks.count) 筆結果")
            } catch {
                print("Failed to load search data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - View State Updates
    
    /// 更新搜尋視圖的狀態，根據搜尋結果數量來顯示適當的內容
    /// - 當沒有搜尋結果時，顯示「無搜尋結果」的提示
    /// - 當有搜尋結果時，顯示搜尋結果列表
    private func updateSearchViewState() {
        if searchResults.isEmpty {
            searchView.updateView(for: .noResults)
        } else {
            searchView.updateView(for: .results)
        }
    }
    
}

// MARK: - SearchResultsDelegate
extension SearchViewController: SearchResultsDelegate {
    
    /// 返回目前的搜尋結果
    /// - `SearchHandler` 使用此方法來獲取顯示資料
    func getSearchResults() -> [SearchResult] {
        return searchResults
    }
    
    /// 當使用者選擇某個搜尋結果時觸發
    /// - Parameter result: 被選中的 `SearchResult`
    /// - 說明：導航至 `DrinkDetailViewController`，顯示飲品的詳細資訊
    func didSelectSearchResult(_ result: SearchResult) {
        print("Selected: \(result.name)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let drinkDetailVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController else {
            return
        }
        // 將選中的 `SearchResult` 資料傳遞給 `DrinkDetailViewController`
        drinkDetailVC.categoryId = result.categoryId
        drinkDetailVC.subcategoryId = result.subcategoryId
        drinkDetailVC.drinkId = result.drinkId
        navigationController?.pushViewController(drinkDetailVC, animated: true)
    }
    
}

// MARK: - SearchControllerInteractionDelegate
extension SearchViewController: SearchControllerInteractionDelegate {
    
    /// 當使用者在搜尋框中更新文字時觸發
    /// - Parameter searchText: 使用者輸入的搜尋文字
    /// - 說明：只有當搜尋文字不為空時才會進行資料過濾
    func didUpdateSearchText(_ searchText: String) {
        if !searchText.isEmpty {
            print("正在過濾搜尋資料，關鍵字為：'\(searchText)'")
            filterSearchData(with: searchText)
        } else {
            print("搜尋文字被清空，恢復初始狀態")
            searchResults = []
            searchView.updateView(for: .initial)
        }
    }
    
    /// 當使用者取消搜尋時觸發，清空搜尋結果
    func didCancelSearch() {
        searchResults = []
        print("使用者取消了搜尋，恢復初始狀態")
        searchView.updateView(for: .initial)
    }
    
}
