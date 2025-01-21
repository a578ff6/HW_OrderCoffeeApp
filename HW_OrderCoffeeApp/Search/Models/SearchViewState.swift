//
//  SearchViewState.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/21.
//

// MARK: - SearchViewState 筆記
/**
 
 ## SearchViewState 筆記


 `* What `

 - `SearchViewState` 是一個枚舉類型（`enum`），用於表示搜尋視圖 (`SearchView`) 的不同狀態。
 - 它幫助 `SearchView` 根據當前搜尋的進展或結果，切換顯示內容。

 - 狀態類型
 
 1. `initial`：
 
    - 初始狀態，顯示提示「請輸入搜尋關鍵字」（"Please enter search keywords"）。
    - 使用場景：搜尋尚未開始，提供使用者明確的操作指引。
    
 2. `noResults`：
 
    - 無結果狀態，顯示提示「沒有符合的搜尋結果」（"No Results"）。
    - 使用場景：搜尋完成，但沒有找到符合條件的結果。

 3. `results`：
 
    - 有結果狀態，顯示搜尋結果列表。
    - 使用場景：當搜尋有匹配的資料時，展示結果。

 ---------

 `* Why`

 - 設計原因
 
 1. 單一責任原則：
 
    - 每個狀態只負責描述一種明確的搜尋情境，簡化了 `SearchView` 的邏輯管理。
    - 分離視圖狀態與狀態管理邏輯，提升程式碼的可讀性與可維護性。

 2. 提高使用者體驗：
 
    - 透過清晰的視覺提示（初始狀態、無結果提示、結果顯示），讓使用者更容易理解當前系統的狀態。

 3. 模組化與可擴展性：
 
    - 狀態定義獨立且可擴展，未來若需新增新狀態（如「加載中」），可以輕鬆擴展而不影響現有邏輯。

 - 為什麼不用單純的 Bool 或 String？
 
    - 使用枚舉（`enum`）提供了更強的類型安全性，避免狀態管理中的潛在錯誤（如拼寫錯誤或無效值）。
    - `case` 描述語義明確，提升程式碼可讀性。

 ---------

 `* How`

 1. 定義與使用
 
 - 在 `SearchViewState` 中定義狀態，並在 `SearchView` 的 `updateView(for:)` 方法中根據狀態更新視圖。

 ##### **範例：定義 `SearchViewState`**
 ```swift
 enum SearchViewState {
     case initial       // 初始狀態
     case noResults     // 無結果狀態
     case results       // 有結果狀態
 }
 ```

 ##### **範例：在 `SearchView` 中應用**
 ```swift
 func updateView(for state: SearchViewState) {
     switch state {
     case .initial:
         searchTableView.backgroundView = SearchStatusView(text: "Please enter search keywords")
     case .noResults:
         searchTableView.backgroundView = SearchStatusView(text: "No Results")
     case .results:
         searchTableView.backgroundView = nil
     }
 }
 ```

 ---
 
 2. 在 `SearchViewController` 中管理狀態
 
 - 在不同的搜尋進展中，調用 `updateView(for:)` 方法切換視圖狀態。

 ##### **範例：搜尋結果更新時的狀態切換**
 ```swift
 private func updateViewStateBasedOnSearchResults() {
     if searchResults.isEmpty {
         updateView(for: .noResults)
     } else {
         updateView(for: .results)
     }
 }
 ```

 ##### **範例：初始化狀態**
 ```swift
 override func viewDidLoad() {
     super.viewDidLoad()
     updateView(for: .initial)  // 預設顯示初始狀態
 }
 ```

 ---------

 `* 總結`

 - What
 
    - `SearchViewState` 是用於表示搜尋頁面 (`SearchView`) 狀態的枚舉，定義了初始狀態、無結果狀態與有結果狀態。

 - Why
 
    - 單一責任原則：讓每個狀態明確表達不同的搜尋階段。
    - 提升使用者體驗：提供視覺提示，讓使用者了解當前情境。
    - 模組化與可擴展性：簡化狀態管理，便於未來擴展新功能。

 - How
 
    1. 定義枚舉 `SearchViewState`，表示搜尋的三種基本狀態。
     2. 在 `SearchView` 中實現 `updateView(for:)` 方法，根據狀態切換視圖內容。
     3. 在 `SearchViewController` 中管理狀態，根據搜尋進展進行切換。
     4. 若需擴展新狀態，僅需修改 `SearchViewState` 和相關邏輯，對現有功能無影響。

 */



// MARK: - (v)

import Foundation

/// `SearchViewState`
///
/// 用於表示 `SearchView` 中的搜尋狀態，幫助視圖根據不同的狀態顯示相應的內容。
///
/// - 狀態類型：
///   1. `initial` - 初始狀態，提示使用者輸入搜尋關鍵字。顯示 "Please enter search keywords"。
///   2. `noResults` - 無結果狀態，提示使用者沒有符合條件的搜尋結果。顯示 "No Results"。
///   3. `results` - 有結果狀態，顯示搜尋結果列表。
///
/// - 使用場景：
///   在 `SearchView` 中根據搜尋的不同階段切換顯示內容，例如初始提示、無結果提示或結果清單。
enum SearchViewState {
    
    /// 初始狀態，顯示 "Please enter search keywords"
    case initial
    
    /// 沒有搜尋結果，顯示 "No Results"
    case noResults
    
    /// 有搜尋結果，顯示搜尋結果列表
    case results
}
