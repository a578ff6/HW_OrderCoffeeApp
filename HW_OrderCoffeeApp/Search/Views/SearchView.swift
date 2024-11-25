//
//  SearchView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//

// MARK: -  重點筆記：SearchView

/**
 ## 重點筆記：SearchView
 
 `1. 功能概述`
 
` * SearchView 是一個自定義的 UIView，主要用於定義搜尋頁面的佈局，包括：`
    - 搜尋結果列表的 UITableView。
    -  根據搜尋狀態 (SearchViewState) 更新視圖的背景，為使用者提供即時的狀態提示，例如「請輸入搜尋關鍵字」或「沒有符合的結果」。

 `2. UI 元素`

 `* tableView：`
    - 用於顯示搜尋結果的表格視圖。
    - 根據不同的搜尋狀態（初始、無結果、有結果）來設置相應的背景視圖。
 
 `3. createTableView`
 
 - 背景顏色：設定為白色，保持界面整潔。
 - 允許垂直捲動 (alwaysBounceVertical = true)：確保即使搜尋結果少，也能有良好的滾動體驗。
 - 隱藏垂直捲動條 (showsVerticalScrollIndicator = false)：增強界面的簡潔性。
 - 行高自動調整 (rowHeight = UITableView.automaticDimension)：適應不同長度的內容。
 
 `4. 註冊客製化 Cell (registerCells())`
 
 - 設置 registerCells() 方法來註冊 SearchCell：
 - 使用 forCellReuseIdentifier: SearchCell.reuseIdentifier 註冊，這樣可以確保 tableView 能夠正確地重用這些 cell，並且提供更好的記憶體管理。
 
 `5. 自定義 Cell 的註冊與使用`
 
 `* 註冊 Cell：`
    - 使用 register(_:forCellReuseIdentifier:) 來註冊自定義的 `SearchCell`，可以確保在 tableView 的 dequeueReusableCell(withIdentifier:) 時能正確地返回相應的 cell 類型。
 
 `6. Auto Layout 設置`
    - 使用 setupUI() 方法來設定 UITableView 的佈局：
    - 通過添加約束，確保 tableView 始終填滿整個視圖，但也要考慮安全區域，避免與其他 UI 元素重疊。
 
` 7. SearchViewState 狀態管理`

  `* SearchViewState 枚舉：`
    - initial：初始狀態，顯示「Please enter search keywords」的提示。`（一開始進入到搜尋視圖、將文字欄清空、點擊cancel）`
    - noResults：沒有搜尋結果時，顯示「No Results」的提示。
    - results：有搜尋結果時，顯示搜尋結果列表。

  `* updateView(for:) `
    - 根據 SearchViewState 更新 tableView 的背景視圖，確保在不同的搜尋階段提供適當的使用者介面提示。
    -  由 SearchStatusLabel  來處理，這樣可以提高代碼的可讀性和可維護性，同時也使得狀態提示更加集中與一致。
 
 `8.重點整理`
    - SearchView 中的主要組件是 tableView，這個表格視圖用來顯示搜尋到的飲品結果。
    - 使用 registerCells() 方法來註冊自定義的 SearchCell，這樣可以確保 tableView 正確使用你設計的客製化 cell，避免錯誤。
    - 使用 setupUI() 設置 Auto Layout 約束，確保 tableView 正確顯示且滿足不同螢幕大小的需求。
    - 使用 SearchViewState 管理搜尋狀態，讓 SearchView 能夠根據不同的搜尋狀態提供不同的 UI 提示和顯示效果，提升使用者體驗。
    -  狀態顯示現在由 SearchStatusLabel 處理，讓不同的搜尋狀態下，顯示的提示更加清晰、簡潔。

 `9.未來想法：`（已完成）
 - 可以使用 UISearchController，考慮將 UISearchController 的相關邏輯整合到 SearchViewController 中，進一步完善搜尋功能。
 - 目前的設計已經解決了搜尋結果顯示的基本需求。如果有更多樣式或行為上的變化需求，可以在 SearchView 中進行擴展，例如添加`空狀態`的視圖，當`搜尋無結果時顯示特定`的消息等。
 */


// MARK: - 使用 `UISearchController` 與 `UISearchBar` 的差異及選擇
/**
 
 ## 筆記主題：使用 `UISearchController` 與 `UISearchBar` 的差異及選擇

 `* What：`
 
 1.`UISearchBar`：
 
    - 是一個基本的搜尋欄位，允許用戶輸入關鍵字來執行搜尋。它通常是 `UIView` 的一部分，可以直接嵌入界面上，用於簡單的搜尋功能。
 
 2.`UISearchController`：
 
    - 是一個更高級的搜尋管理組件，它內建了一個 `UISearchBar`，並且能與 `UITableView` 或 `UICollectionView` 無縫集成。
    - `UISearchController` 會自動管理搜尋欄的行為（如顯示、隱藏），以及控制搜尋結果的顯示。

 *` Why：`
 
 `1. 一致的用戶體驗`
 
    - `UISearchController` 更適合整合到應用的導航欄中，能將搜尋欄顯示在 `UINavigationItem` 的標題區域，為用戶提供一個熟悉且一致的搜尋體驗。
    - 搜尋過程的過渡效果（如搜尋時背景變暗等）也可以由 `UISearchController` 自動處理，使搜尋更流暢。

 `2. 更靈活的控制`
 
    - `UISearchController` 允許在搜尋時實時顯示過濾的搜尋結果，這對於需要根據輸入的文字進行即時過濾的應用場景非常合適。
    - 它還提供了一些額外的選項，例如是否在搜尋過程中遮蓋背景、是否保持原來的列表顯示等。

 `* How：`
 
 `1.若使用 UISearchController`
 
   - 可以將 `UISearchController` 直接嵌入到 `UIViewController` 的 `navigationItem` 中，這樣搜尋欄會顯示在導航欄的位置。
   - 不需要在自定義的 `SearchView` 裡面再加一個 `UISearchBar`。

 `2.實作想法`
 
   - `刪除 SearchView 中的 UISearchBar`
      - 如果決定使用 `UISearchController`，`SearchView` 只需要包含用來顯示搜尋結果的 `UITableView`，不再需要額外的 `UISearchBar`。
 
   - `在 SearchViewController 中設置 UISearchController`
      - 在 `SearchViewController` 中初始化 `UISearchController`，並將它設置為 `navigationItem.searchController`，方便使用者在搜尋時進行即時的結果過濾。
   
   - `即時更新搜尋結果`
      - 利用 `UISearchController` 的 `searchResultsUpdater` 屬性來即時更新搜尋結果。這樣可以讓使用者在輸入關鍵字時，動態地看到符合條件的搜尋結果。

 `3.實作重點`
 
 - 使用 `UISearchController` 可避免在 `SearchView` 中重複設置 `UISearchBar`，使程式碼結構更加簡潔。
 - 在 `SearchViewController` 中添加 `UISearchController`，可使搜尋欄與 `UITableView` 的整合更自然，搜尋過程也更加順暢和一致。
 
 - 例如：
   ```swift
   searchController = UISearchController(searchResultsController: nil)
   searchController.searchResultsUpdater = self
   searchController.obscuresBackgroundDuringPresentation = false
   searchController.searchBar.placeholder = "請輸入飲品名稱"
   navigationItem.searchController = searchController
   navigationItem.hidesSearchBarWhenScrolling = false
   ```

 `4.結論`
 
 - 若使用 `UISearchController`，就不需要再在 `SearchView` 中加入 `UISearchBar`。
 - `UISearchController` 更適合用於包含大量動態過濾需求的場景，它自帶的功能可使搜尋過程更加優化，對於導航條的顯示位置也更為合適。
 */

import UIKit

/// `SearchView` 是一個自定義 UIView，用於定義搜尋頁面的佈局和顯示狀態。
/// - 包含搜尋結果列表的 UI 元素。
/// - 根據 `SearchViewState` 顯示不同的視圖狀態，例如`初始狀態`、`無結果狀態`和`有結果狀態`。
class SearchView: UIView {
    
    // MARK: - UI Elements
    
    /// 搜尋結果列表，用於顯示搜尋到的飲品結果
    let tableView = SearchView.createTableView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCells()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置 UI 元素，包括 `tableView`，並設置其約束
    private func setupUI() {
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊表格視圖使用的 Cell 類型
    private func registerCells() {
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseIdentifier)
    }
    
    // MARK: - Factory Methods
    
    /// 建立並配置表格視圖
    private static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.alwaysBounceVertical = true                       // 總是允許垂直捲動
        tableView.showsVerticalScrollIndicator = false              // 隱藏垂直捲動條
        tableView.rowHeight = UITableView.automaticDimension        // 行高自動調整
        tableView.estimatedRowHeight = 120                          // 行高的預估值，幫助優化佈局
        return tableView
    }
    
    // MARK: - No Result State Management
        
    /// 根據搜尋的狀態更新表格視圖的背景視圖
    /// - Parameter state: `SearchViewState` 用於決定顯示的內容，例如初始提示、無結果提示或結果列表。
    /// - 根據提供的 `state` 參數，更新 `tableView` 的背景視圖，確保符合當前的搜尋狀態。
    func updateView(for state: SearchViewState) {
        switch state {
        case .initial:
            tableView.backgroundView = SearchStatusLabel(text: "Please enter search keywords")
        case .noResults:
            tableView.backgroundView = SearchStatusLabel(text: "No Results")
        case .results:
            tableView.backgroundView = nil
        }
    }
}

// MARK: - SearchViewState

/// `SearchViewState` 用於表示搜尋視圖的狀態
/// - 在 `SearchView` 中，根據不同的搜尋狀態顯示相應的內容。
enum SearchViewState {
    case initial        // 初始狀態，顯示 "Please enter search keywords"
    case noResults      // 沒有搜尋結果，顯示 "No Results"
    case results        // 有搜尋結果，顯示搜尋結果列表
}
