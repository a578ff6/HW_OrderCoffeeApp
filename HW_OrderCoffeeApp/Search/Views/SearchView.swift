//
//  SearchView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//


// MARK: - 使用 `UISearchController` 與 `UISearchBar` 的差異及選擇
/**
 
 ## 筆記主題：使用 `UISearchController` 與 `UISearchBar` 的差異及選擇

 
 `* What：`
 
 1.`UISearchBar`：
 
    - 是一個基本的搜尋欄位，允許用戶輸入關鍵字來執行搜尋。它通常是 `UIView` 的一部分，可以直接嵌入界面上，用於簡單的搜尋功能。
 
 2.`UISearchController`：
 
    - 是一個更高級的搜尋管理組件，它內建了一個 `UISearchBar`，並且能與 `UITableView` 或 `UICollectionView` 無縫集成。
    - `UISearchController` 會自動管理搜尋欄的行為（如顯示、隱藏），以及控制搜尋結果的顯示。

 ---------
 
 *` Why：`
 
 `1. 一致的用戶體驗`
 
    - `UISearchController` 更適合整合到應用的導航欄中，能將搜尋欄顯示在 `UINavigationItem` 的標題區域，為用戶提供一個熟悉且一致的搜尋體驗。
    - 搜尋過程的過渡效果（如搜尋時背景變暗等）也可以由 `UISearchController` 自動處理，使搜尋更流暢。

 `2. 更靈活的控制`
 
    - `UISearchController` 允許在搜尋時實時顯示過濾的搜尋結果，這對於需要根據輸入的文字進行即時過濾的應用場景非常合適。
    - 它還提供了一些額外的選項，例如是否在搜尋過程中遮蓋背景、是否保持原來的列表顯示等。

 ---------

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

 ---------

 `* 結論`
 
    - 若使用 `UISearchController`，就不需要再在 `SearchView` 中加入 `UISearchBar`。
    - `UISearchController` 更適合用於包含大量動態過濾需求的場景，它自帶的功能可使搜尋過程更加優化，對於導航條的顯示位置也更為合適。
 */


// MARK: - SearchView 筆記
/**
 
 ## SearchView 筆記


 `* What `

 - `SearchView` 是一個自定義的 `UIView`，專門用於定義搜尋頁面的佈局與顯示狀態。

 - 主要功能
 
 1. 搜尋結果顯示：
 
    - 包含核心 UI 元素 `SearchTableView`，用於展示搜尋結果。
 
 2. 狀態管理：
 
    - 根據 `SearchViewState` 切換顯示內容，包括初始提示、無結果提示或搜尋結果列表。
 
 3. 擴展性：
 
    - 支援通過 `updateView(for:)` 方法動態更新背景提示，適應多種搜尋情境。

 ----------

 `* Why`

 1. 解決的問題
 
 - 清晰的狀態管理：
 
   - 搜尋頁面通常需要顯示不同的狀態（例如初始、無結果、有結果），`SearchView` 提供了集中管理這些狀態的能力。
 
 - 提高可讀性與維護性：
 
   - 將狀態邏輯與顯示邏輯分離，避免在控制器中處理過多的 UI 邏輯。

 2. 設計原則
 
 - 單一責任原則：
 
   - `SearchView` 專注於處理搜尋頁面的佈局和狀態顯示，減少控制器的負擔。
 
 3. 為什麼使用 `SearchViewState`？
 
 - 確保狀態管理語義清晰，避免使用不安全的文字或布林值來表示狀態。
 - 提高程式碼的類型安全性和可擴展性。

 ----------

 `* How`

 1. 定義搜尋狀態
 
 - 使用 `SearchViewState` 枚舉表示搜尋頁面的三種狀態：`initial`、`noResults` 和 `results`。

 ```swift
 enum SearchViewState {
     case initial   // 初始狀態
     case noResults // 無結果狀態
     case results   // 有結果狀態
 }
 ```
 
---
 
 2. 配置 UI
 
 - 在 `SearchView` 中添加 `searchTableView`，透過 Auto Layout 將其填滿父視圖。

 ```swift
 private func setupLayout() {
     addSubview(searchTableView)
     NSLayoutConstraint.activate([
         searchTableView.topAnchor.constraint(equalTo: topAnchor),
         searchTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
         searchTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
         searchTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
     ])
 }
 ```

 ---

 3. 動態更新狀態
 
 - 根據 `SearchViewState` 切換背景視圖，提供對應的狀態提示。

 ```swift
 func updateView(for state: SearchViewState) {
     switch state {
     case .initial:
         searchTableView.backgroundView = SearchStatusView(message: "Please enter search keywords")
     case .noResults:
         searchTableView.backgroundView = SearchStatusView(message: "No Results")
     case .results:
         searchTableView.backgroundView = nil
     }
 }
 ```

 ---

 4. 在控制器中使用 `SearchView`
 
 - 根據搜尋結果動態更新狀態。

 ```swift
 class SearchViewController: UIViewController {
     private let searchView = SearchView()

     override func loadView() {
         view = searchView
     }

     private func updateSearchState() {
         if searchResults.isEmpty {
             searchView.updateView(for: .noResults)
         } else {
             searchView.updateView(for: .results)
         }
     }
 }
 ```

 ----------

`* 結論`

 - What
 
    - `SearchView` 是搜尋頁面的核心視圖，負責搜尋結果的顯示與狀態管理。

 - Why
 
    - 符合單一責任原則，將狀態管理與佈局邏輯集中在視圖層，減少控制器負擔。
    - 使用 `SearchViewState` 提供語義清晰的狀態切換，提升可維護性與擴展性。

 - How
 
    1. 使用 `SearchViewState` 定義搜尋的三種狀態。
    2. 配置 `SearchTableView` 作為搜尋結果列表。
    3. 通過 `updateView(for:)` 方法動態切換視圖內容。
    4. 在控制器中根據搜尋進展調用 `updateView(for:)`，更新頁面顯示。
 
 ----------

 `* 未來想法：（已完成）`

    - 可以使用 UISearchController，考慮將 UISearchController 的相關邏輯整合到 SearchViewController 中，進一步完善搜尋功能。
    - 目前的設計已經解決了搜尋結果顯示的基本需求。如果有更多樣式或行為上的變化需求，可以在 SearchView 中進行擴展，例如添加`空狀態`的視圖，當`搜尋無結果時顯示特定`的消息等。
 */





// MARK: - (v)

import UIKit

/// `SearchView`
///
/// 一個自定義的 `UIView`，用於定義搜尋頁面的佈局與顯示狀態。
///
/// - 功能：
///   1. 包含搜尋結果列表的核心 UI 元素 `SearchTableView`。
///   2. 根據 `SearchViewState` 切換視圖的背景提示內容。
///   3. 提供簡單的狀態管理方法 `updateView(for:)`，根據搜尋狀態更新視覺提示。
///
/// - 使用場景：
///   作為搜尋頁面的主要視圖容器，負責呈現搜尋結果列表，並提供相應的狀態提示，例如`初始提示`、`無結果提示`或`結果清單`。
///
/// - 關鍵特性：
///   1. 採用 Auto Layout 為內部的 `searchTableView` 設置約束。
///   2. 支援根據不同狀態 (`SearchViewState`) 自動切換背景提示。
///   3. 可輕鬆擴展以適應新的搜尋狀態或自定義顯示內容。
class SearchView: UIView {
    
    // MARK: - UI Elements
    
    /// 搜尋結果列表
    ///
    /// - 用於顯示搜尋結果的主要表格視圖
    private(set) var searchTableView = SearchTableView()
    
    // MARK: - Initializer
    
    /// 初始化 `SearchView`
    ///
    /// - 使用指定的框架大小初始化視圖，並執行 UI 配置與 Cell 註冊。
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCells()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 UI 元素
    /// - 添加 `searchTableView` 並透過 Auto Layout 設置約束，使其填滿父視圖。
    private func setupLayout() {
        addSubview(searchTableView)
        
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊表格視圖使用的 Cell 類型
    ///
    /// - 預設為 `SearchCell`，可根據需要擴展支援其他 Cell 類型。
    private func registerCells() {
        searchTableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseIdentifier)
    }
    
    // MARK: - No Result State Management
    
    
    /// 更新視圖的顯示狀態
    ///
    /// 根據提供的搜尋狀態 (`SearchViewState`)，更新 `searchTableView` 的背景視圖。
    ///
    /// - Parameter state: 當前的搜尋狀態，包含以下類型：
    ///   - `.initial`：顯示初始提示，指引使用者輸入關鍵字。
    ///   - `.noResults`：顯示無結果提示，告知使用者搜尋結果為空。
    ///   - `.results`：清空背景提示，顯示搜尋結果列表。
    func updateView(for state: SearchViewState) {
        switch state {
        case .initial:
            searchTableView.backgroundView = SearchStatusView(message: "Please enter search keywords")
        case .noResults:
            searchTableView.backgroundView = SearchStatusView(message: "No Results")
        case .results:
            searchTableView.backgroundView = nil
        }
    }
    
}
