//
//  SearchHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//

// MARK: -  SearchHandler 與 SearchResultsDelegate 設計重點筆記
/**
 ## SearchHandler 與 SearchResultsDelegate 設計重點筆記

 `1. SearchHandler 的角色和責任`
 
 - `負責搜尋結果的顯示與用戶操作`：
    - `SearchHandler` 是 `SearchViewController` 的處理器，負責處理表格視圖的數據源 (UITableViewDataSource) 及委託 (UITableViewDelegate) 邏輯。

 - `減少視圖控制器責任`：
    - 透過 `SearchHandler` 將表格相關邏輯抽取出來，減輕 `SearchViewController` 的責任，使其只專注於資料的管理和用戶行為。

 `2. SearchResultsDelegate 的應用`

 - `委託模式的目的`：
    - SearchResultsDelegate 用於 SearchHandler 和 SearchViewController 之間的溝通。
    - 通過委託模式，SearchHandler 能夠從 SearchViewController 獲取資料，並通知視圖控制器用戶選擇的操作。

 - `高內聚，低耦合`：
    - 這種模式使 SearchHandler 不直接持有資料來源，而是通過 delegate 進行資料訪問，從而減少相互依賴，達成更高的內聚和更低的耦合性。

 `3. SearchHandler 的設計細節`

 - `delegate 的使用`：
    - SearchHandler 中的 delegate 被設置為 weak，以避免強引用循環造成的內存泄漏。

 - `延遲初始化與安全性`：
    - SearchHandler 的初始化在 setupHandler() 中進行，並且設置為可選類型 (private var searchHandler: SearchHandler?)。

 - `原因`：
    - SearchHandler 的初始化依賴於視圖控制器完成設置，且有可能根據特定條件進行初始化，延遲初始化使得代碼更具靈活性。

 `4. UITableView 的處理`

 - `數據源 (UITableViewDataSource)`：
    - `SearchHandler` 遵循 `UITableViewDataSource` 協議，負責管理表格中的行數與單元格配置。
    - `numberOfRowsInSection` 通過委託從 `SearchViewController` 獲取搜尋結果的數量。
    - `cellForRowAt` 配置每個單元格，並調用 `SearchCell` 的 `configure(with:) `方法來顯示正確的搜尋結果。

 - `用戶交互 (UITableViewDelegate)`：
    - SearchHandler 遵循 UITableViewDelegate 協議，用於處理用戶的行選擇行為。
    - 當用戶選擇某行時，didSelectRowAt 通知委託 (SearchViewController) 進行進一步的操作（例如導航至詳細頁面）。

 `5. 使用委託的好處`

 - `可維護性`：透過使用委託，`SearchHandler` 和 `SearchViewController` 之間的責任劃分更加明確，便於單元測試和功能擴展。
 - `靈活性`：如果未來有其他的視圖控制器需要類似的搜尋結果處理器，SearchHandler 可以被重用而不需要修改太多代碼。

 `6. 何時應該延遲初始化 SearchHandler`

 - `延遲初始化 (private var searchHandler: SearchHandler?) 的場景`：
    - 當 `SearchHandler` 的初始化需要依賴某些數據的加載完成，或根據特定條件（例如某些操作完成後）才進行初始化時。

 - 例如，當搜尋功能僅在某些情況下被使用，可以先不初始化 SearchHandler，待需要時才進行。
 
 -  在 SearchViewController 中，目前的設置是使用延遲初始化，以確保靈活性，特別是在需要根據視圖顯示後或特定條件來決定是否初始化時。

 - `立即初始化 (let searchHandler = SearchHandler()) 的適用性`：
    - 若 SearchHandler 是核心功能且需要在視圖顯示後立即使用，那麼立即初始化 (let) 會讓代碼更簡潔且避免不必要的 nil 判斷。

 `7.想法`
 
 - 將 `SearchHandler` 設為可選類型並延遲初始化的目的是為了提高靈活性，但如果不涉及依賴數據的問題，可以考慮立即初始化，減少可選值的處理複雜性。
 - 確保委託 (delegate) 使用 weak 來避免循環引用，特別是在涉及視圖控制器和處理器之間的雙向關係時。
 */



import UIKit

/// `SearchHandler` 負責管理 `SearchViewController` 的處理器，包含搜尋結果的顯示及用戶操作。
/// 它遵循 `UITableViewDataSource` 和 `UITableViewDelegate` 協議，用於處理表格視圖的數據源及用戶交互。
class SearchHandler: NSObject {
    
    // MARK: - Properties
    
    /// 用於與 `SearchViewController` 溝通的委託。這使得 `SearchHandler` 能從控制器獲取資料並通知操作。
    weak var delegate: SearchResultsDelegate?
    
    // MARK: - Initialization

    /// 初始化方法，用於設置委託
    /// - Parameter delegate: 一個符合 `SearchResultsDelegate` 協議的對象，用於提供資料和處理操作
    init(delegate: SearchResultsDelegate?) {
        self.delegate = delegate
    }
    
}

// MARK: - UITableViewDataSource
extension SearchHandler: UITableViewDataSource {
    
    /// 返回指定部分中的行數
    ///
    /// - 通過委託獲取目前的搜尋結果數量，若為 `nil` 則返回 0
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getSearchResults().count ?? 0
    }
    
    /// 返回指定位置的 `UITableViewCell`
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 從委託獲取搜尋結果，如果為 `nil`，返回空的 UITableViewCell
        guard let searchResults = delegate?.getSearchResults() else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reuseIdentifier, for: indexPath) as? SearchCell else {
            fatalError("Unable to dequeue SearchCell")
        }
        
        // 配置 Cell，根據搜尋結果
        let result = searchResults[indexPath.row]
        cell.configure(with: result)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension SearchHandler: UITableViewDelegate {
    
    /// 當用戶選擇某行時調用
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let searchResults = delegate?.getSearchResults() else { return }          // 通過委託獲取搜尋結果，如果為 `nil`，直接返回
        let selectedResult = searchResults[indexPath.row]                               // 獲取被選中的搜尋結果
        delegate?.didSelectSearchResult(selectedResult)                                 // 通知委託對應的搜尋結果被選擇
        tableView.deselectRow(at: indexPath, animated: true)                            // 取消選中的高亮狀態
    }
    
}

