//
//  SearchControllerManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/17.
//

// MARK: - SearchControllerManager 的設置和用途
/**
 ## SearchControllerManager 的設置和用途
 
 `1.職責劃分與分離關心點（Separation of Concerns）`
 
    - `SearchControllerManager` 專門負責 `UISearchController` 的設置、配置、以及處理使用者的交互行為。
    - 透過此管理器，可以將與搜尋控制器相關的邏輯與主要的視圖控制器 (`SearchViewController`) 分開，使主要視圖控制器保持簡潔，專注於資料處理和頁面展示。
 
 `2.使用委託進行交互通知`

    - `SearchControllerInteractionDelegate` 用於通知外部有關搜尋文字的變更和搜尋取消等操作。這樣設計的優勢是可以靈活地處理搜尋的交互事件，並保持代碼的解耦。
    - `didUpdateSearchText(_ searchText: String)`：當搜尋框中的文字更新時，委託可以獲得更新的搜尋關鍵字，用於過濾顯示結果。
    - `didCancelSearch()`：當使用者取消搜尋時，委託會接收到通知，以便清空搜尋結果或進行其他操作。
  
` 3.設置 UISearchController 的初始化`

    - `setupSearchController() `方法負責初始化 UISearchController 的屬性，例如設置搜尋框佔位符、背景透明度以及設置代理等。
    - `UISearchResultsUpdating` 用於實現搜尋結果的即時更新，根據搜尋字串及時地通知委託處理資料的過濾。
 
` 4.使用 Debounce 限制搜尋請求頻率`

    - 在 `updateSearchResults(for:) `方法中，新增了 `Debounce` 機制，以防止使用者在短時間內輸入大量字元時觸發多次搜尋請求。
    - 使用 `DispatchWorkItem` 實現 Debounce，每次使用者輸入時會延遲 0.5 秒進行搜尋，若使用者在延遲期間內繼續輸入，則會取消之前的計時器。
    -  `debounceSearch(with:)`負責管理計時器，而` handleSearchText(_:)`則專注於搜尋文字的處理（例如通知代理更新搜尋結果）。
 
 `5.在視圖控制器中使用`

    - `attach(to:) `方法用於將 `UISearchController` 附加到指定的視圖控制器。
    - 這樣可以靈活地使用 `SearchControllerManager` 在不同的控制器中，而不需要在每個控制器內重複設置 UISearchController 的相關邏輯。
 
 `6.新增 Getter 方法以提高安全性`

    - 新增了` getSearchText() `方法，提供外部訪問 `UISearchController` 搜尋框文字的安全方式，而不是直接訪問 `searchController`。
    - `getSearchText() `的主要目的是提供安全且簡單的方式來訪問當前的搜尋文字。
    - 例如在 `SearchViewController` 中重新加載飲品資料後，需要檢查是否有正在進行的搜尋，以決定是否應該繼續執行過濾操作 (`filterSearchData`)。
    - 這樣做的好處是保留了 searchController 的私有保護層級，防止外部修改其屬性，並提供一個簡單的接口來獲取搜尋文字。
 
 `7.使用想法`
 
    - 使用 `SearchControllerManager` 是為了避免讓視圖控制器變得臃腫，將 `UISearchController` 的設置和交互行為移至一個獨立的管理器中，提升代碼的可維護性。
    - 當需要在不同的視圖控制器中使用類似的搜尋功能時，可以重複利用這個管理器，而無需在每個視圖控制器中重新撰寫相關的 UISearchController 邏輯。
    - 若搜尋功能逐漸增多且越來越複雜，使用 SearchControllerManager 可以更容易地在不同情境下管理搜尋交互，例如動態過濾、取消搜尋、動態顯示不同結果頁等。
 */


// MARK: - 筆記：利用 Debounce 優化搜尋行為及其與資料加載方式的關聯
/**
 
 ## 筆記：利用 Debounce 優化搜尋行為及其與資料加載方式的關聯
 
` * 背景說明：搜尋效能的優化需求`
 
 - 因為在 App 的搜尋功能中，當使用者輸入內容時，如果每次輸入都觸發即時搜尋，導致短時間內多次觸發搜尋操作，這會產生重複且無效的搜尋。
 - 為了提升使用者體驗及應用效能，選擇在搜尋過程中引入「debounce」技術，讓搜尋操作僅在使用者停止輸入後的一段時間再進行。
 
 `* Debounce 的使用場景與優點`
 
` 1.避免重複觸發過濾操作`：

 - 當使用者輸入搜尋字元時，通常每個字元都會觸發一次搜尋過濾。如果使用者快速輸入，例如「咖啡」，可能會在「咖」、「咖啡」等字元輸入時，重複過濾多次，浪費計算資源。
 - 引入「debounce」後，設定延遲，例如 0.5 秒，當使用者停止輸入 0.5 秒後才進行過濾，這樣可以大幅減少不必要的過濾次數。
 
` 2.提升搜尋體驗：`
 
 - 搜尋行為僅在使用者停止輸入後執行，可以有效避免頻繁過濾導致的畫面更新和卡頓，給使用者更加流暢的體驗。
 
 `* App 啟動時加載資料與 Debounce 的關聯`
 
 `1.在 App 啟動時加載資料：`
 
 - 雖然我目前已經選擇`在 App 啟動時進行飲品資料的加載`，確保在使用者進行搜尋之前，所有資料已經快取在本地，減少搜尋過程中的網路延遲。
 - 由於所有資料都已在本地，因此過濾操作完全是本地的資料操作，這樣搜尋過程非常快，不需要每次都向 Firebase 發送請求。
 
 `2.Debounce 與資料加載：`
 
 - `Debounce 與 App 啟動時資料加載是兩個不同層次的優化措施`：
    - App 啟動時資料加載是為了確保資料在搜尋前就已準備好，避免初次搜尋時等待資料載入。
    - Debounce 則是為了減少輸入過程中的重複搜尋，優化搜尋輸入時的效能和用戶體驗。
 
 - 因此，引入 debounce 是為了在已有本地資料的基礎上，進一步優化搜尋的行為，避免短時間內多次重複的過濾操作。
 - 主要是因為我要用print觀察過程，如果不引入 debounce，print的呈現會很亂。
 
 `* Debounce 的具體實現`
 
 - 使用 DispatchQueue 來實現「debounce」機制。
 - 當使用者輸入新字元時，先取消之前的計時器，重新計時，僅當使用者停止輸入後的一段時間（例如 0.5 秒）才執行搜尋操作。
 
 `* 總結`
 
 - Debounce 的引入主要是為了限制輸入過程中短時間內的多次重複搜尋。
 - 在 App 啟動時進行資料加載，可以確保搜尋的資料已經在本地，這樣搜尋的過濾操作可以非常快地進行，而不需要每次都請求遠端。
 - Debounce 和 App 啟動時資料加載的結合，可以達到優化搜尋效能和使用者體驗的效果：
 - 在本地快取資料的基礎上，透過 debounce 減少搜尋的過濾次數，提升輸入流暢度。
 */


// MARK: - 三種 debounce 方法的重點整理筆記以及每種方式的比較（ https://reurl.cc/nqV4v6 ）
/**
 
 ## 三種 debounce 方法的重點整理筆記以及每種方式的比較
 
 `1. NSObject.cancelPreviousPerformRequests 方法`
 
 * 描述：
 - 使用 `NSObject` 的方法來取消之前對象的調用請求，然後使用` perform(#selector(), with:afterDelay:) `方法延遲執行某個 `selector`。
 
 * 優點：
    - 實現簡單，代碼較短。
    - 不需要計時器或額外的異步處理。
 
 `* 缺點：`
    - 依賴 Objective-C runtime 中的 selector，在純 Swift 環境下顯得有些違和。
    - 不如其他方法靈活，且使用了較老的 Objective-C 語法。
 
 `2. Timer 來實現 Debounce`
 
 * 描述：
    - 每次輸入新字元時，取消（invalidate）之前的計時器，然後建立新的計時器進行延遲操作。
 
 * 優點：
    - 使用計時器的方式較為直觀，能夠理解為「等到一定時間後再執行」。
    - 對計時器有更好的控制（例如 invalidate）。
 
 * 缺點：
    - 需要手動管理計時器，稍微增加代碼複雜度。
    - 需要小心使用計時器，以防止循環引用（需要使用 [weak self]）。
 
 `3. DispatchWorkItem 來實現 Debounce`
 
 * 描述：
    - 使用 DispatchWorkItem，取消先前的工作項目，然後建立新的項目並延遲執行。
 
 * 優點：
    - 純 Swift，語法現代化且適合當前 Swift 開發。
    - 不需要手動管理計時器，代碼更簡潔。
    - 更加靈活，可以取消和管理異步任務，適合進行更複雜的異步操作。
 
 * 缺點：
    - 與 Timer 相比可能稍微不如計時器直觀，但在代碼風格上更為符合 Swift 標準。
 
` ## 哪一種寫法比較新？`
 
 - `DispatchWorkItem` 的寫法是比較新的。它利用了` GCD（Grand Central Dispatch）`來管理異步任務和延遲操作，是符合現代 Swift 編碼風格的做法。它相對於使用 NSObject 或 Timer 更加簡潔且靈活。
 - 使用 `Timer` 的方式也很常見，但它的管理需要更多手動處理（例如取消和防止循環引用）。`DispatchWorkItem` 讓這些操作更自動化和現代化。
 
` ## 總結`
 
 - 如果想要採用最新、最現代的實現方式，並且希望代碼風格保持純 Swift，建議使用 DispatchWorkItem。
 - 如果習慣於更直觀的時間控制，並且不介意管理計時器，可以使用 Timer。
 - 而 NSObject.cancelPreviousPerformRequests 的方式屬於 較老的語法，依賴 Objective-C 的特性，除非特定需求，否則不推薦在現代 Swift 開發中使用。
 */




import UIKit

/// `SearchControllerManager` 負責管理 `UISearchController` 的設置和交互
/// - 通過此管理器，`UISearchController` 可以更簡潔地與視圖控制器進行整合，並將搜尋相關的事件委託給外部處理。
class SearchControllerManager: NSObject {

    // MARK: - Properties

    /// 用於處理 `UISearchController` 交互的委託
    /// - 透過 `SearchControllerInteractionDelegate`，`SearchControllerManager` 將搜尋文字的更新和取消操作通知外部。
    weak var delegate: SearchControllerInteractionDelegate?
    
    /// `UISearchController` 的實例，用於管理搜尋行為
    private let searchController: UISearchController
    
    /// Debounce 計時器，用於限制輸入操作過於頻繁的情況
    private var debounceTimer: DispatchWorkItem?
    
    // MARK: - Initialization

    /// 初始化 `SearchControllerManager` 並設置委託和搜尋控制器
    /// - Parameter delegate: 遵循 `SearchControllerInteractionDelegate` 的對象，用於接收搜尋相關的交互
    init(delegate: SearchControllerInteractionDelegate?) {
        self.delegate = delegate
        self.searchController = UISearchController(searchResultsController: nil)
        super.init()
        setupSearchController()
    }
    
    // MARK: - Setup Methods

    /// 設置 `UISearchController` 的屬性和代理
    private func setupSearchController() {
        searchController.searchResultsUpdater = self                            // 設置搜尋結果更新的代理
        searchController.obscuresBackgroundDuringPresentation = false           // 避免在展示搜尋結果時背景變暗
        searchController.searchBar.placeholder = "Search drinks..."             // 設置搜尋框的佔位符
        searchController.searchBar.delegate = self                              // 設置 `searchBar` 的代理以處理取消事件
    }
    
    // MARK: - Public Methods

    /// 將 `UISearchController` 附加到指定的視圖控制器
    /// - Parameter viewController: 要將搜尋控制器添加到其導航項的視圖控制器
    func attach(to viewController: UIViewController) {
        viewController.navigationItem.searchController = searchController
        viewController.definesPresentationContext = true                         // 確保搜尋行為只限於當前視圖控制器
    }
    
    /// 提供 `searchBar` 的搜尋文字
    /// - Returns: 返回 `searchBar` 中當前輸入的文字
    /// - 說明：提供一個安全的接口來獲取 `searchBar.text`，而不直接暴露 `searchController`，從而保護內部狀態
    func getSearchText() -> String? {
        return searchController.searchBar.text
    }
 
}

// MARK: - UISearchResultsUpdating
extension SearchControllerManager: UISearchResultsUpdating {

    /// 當搜尋框中的文字改變時調用
    /// - Parameter searchController: 發生變化的 `UISearchController`
    /// - 通知委託更新搜尋文本
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        debounceSearch(with: searchText)
    }
    
    /// 使用 debounce 機制來限制搜尋請求的頻率
    /// - Parameter searchText: 使用者輸入的搜尋文字
    private func debounceSearch(with searchText: String) {
        // 如果已有計時器，取消先前的操作，確保只執行最新的搜尋請求
        debounceTimer?.cancel()
        
        // 使用 debounce 機制來限制多次重複的輸入
        let task = DispatchWorkItem { [weak self] in
            self?.handleSearchText(searchText)
        }
        
        // 延遲 0.5 秒執行，以實現 debounce 效果，避免頻繁的搜尋
        debounceTimer = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
    
    /// 根據搜尋文字進行處理
    /// - Parameter searchText: 經過 debounce 處理後的搜尋文字
    private func handleSearchText(_ searchText: String) {
        print("Debounced search text: '\(searchText)'")
        if !searchText.isEmpty {
            delegate?.didUpdateSearchText(searchText)  // 通知代理搜尋文字更新
        } else {
            print("搜尋文字為空，應該進行初始狀態恢復")
            delegate?.didUpdateSearchText(searchText)  // 這裡應該會執行初始狀態更新
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension SearchControllerManager: UISearchBarDelegate {
    
    /// 當使用者點選取消按鈕時調用
    /// - Parameter searchBar: 發生操作的 `UISearchBar`
    /// - 通知委託取消搜尋操作
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.didCancelSearch()
    }
    
}


