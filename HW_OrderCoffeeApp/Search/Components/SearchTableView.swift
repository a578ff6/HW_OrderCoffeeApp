//
//  SearchTableView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/21.
//

// MARK: - 使用 `.zero` 與 `frame` 的比較差異
/**
 
 ## 使用 `.zero` 與 `frame` 的比較差異


 * What

 - 使用 `.zero`
 
    - `.zero` 是指在初始化視圖時，將其框架設置為 `(x: 0, y: 0, width: 0, height: 0)`。
    - 位置與大小由 **Auto Layout** 決定，而非在初始化時立即設置。

 - 使用 `frame`
 
    - `frame` 是指在初始化視圖時，直接提供一個明確的矩形框架 `(CGRect)`，包含位置與尺寸。
    - 視圖的佈局完全依賴手動設定的 `frame`。

 ---------

 * Why

 - 使用 `.zero` 的理由
 
 1. 符合 Auto Layout 設計哲學：
    - 現代 iOS 開發中，視圖佈局大多依賴 Auto Layout，`frame` 只在初始化階段作為占位，實際大小由約束決定。
    -  Auto Layout 是現代 iOS 應用的標準佈局方式，`.zero` 初始化可將大小與位置交由約束系統管理。
    - 避免因外部傳入不合適的 `frame` 導致顯示錯誤。
    - 符合設計哲學：子視圖專注於其功能，佈局交由父視圖處理。

 2. 減少耦合：
 
    - 視圖大小與位置由外層的約束系統控制，`SearchTableView` 不需要知道自己的最終尺寸，達到責任分離。

 3. 避免潛在的初始化問題：
 
    - 外部提供的 `frame` 如果不合理，可能導致視圖初始化後位置錯誤，而 `.zero` 保持初始狀態簡潔。

 ---
 
 - 使用 `frame` 的理由
 
 1. 靈活性：
 
    - 在某些情況下，例如未使用 Auto Layout 時，可以直接用 `frame` 控制視圖的初始大小與位置。

 2. 初始化即定位：
 
    - 如果場景需要在初始化階段就確定視圖的位置與尺寸，使用 `frame` 是更高效的方式，避免多次配置。

 3. 向下相容性：
 
    - 如果專案中部分視圖仍使用手動 `frame` 布局，`frame` 方式更適合整體架構的一致性。

 --------

 * How

 - 何時使用 `.zero`
 
 - 場景：
 
    當使用 **Auto Layout** 配置視圖佈局時，應該使用 `.zero` 來初始化框架，後續完全依賴約束來設定位置與大小。
 
 - 做法：
 
   1. 初始化時設置 `frame: .zero`。
   2. 確保 `translatesAutoresizingMaskIntoConstraints = false`。
   3. 使用 `NSLayoutConstraint.activate` 或其他約束方式配置視圖大小與位置。

 ---
 
 - 何時使用 `frame`
 
 - 場景：
 
    當需要手動設置視圖的框架（例如不使用 Auto Layout），或初始化時就必須確定視圖的位置與大小。
 
 - 做法*：
 
   1. 初始化時直接提供具體的 `frame` 值。
   2. 確保外部傳入的 `frame` 合理，避免初始化階段錯誤。
   3. 如果後續仍需調整大小，可手動更新 `frame` 屬性。

 --------

`* 範例`

 - 使用 `.zero` 配合 Auto Layout
 
 ```swift
 class SearchTableView: UITableView {
     override init(frame: CGRect, style: UITableView.Style) {
         super.init(frame: .zero, style: style) // 設定為 .zero，使用 Auto Layout 配置大小
         setupTableView()
     }

     private func setupTableView() {
         translatesAutoresizingMaskIntoConstraints = false
         backgroundColor = .white
         // 其他設定
     }
 }
 ```

 ---

 - 使用 `frame` 手動設置大小
 
 ```swift
 class SearchTableView: UITableView {
     override init(frame: CGRect, style: UITableView.Style) {
         super.init(frame: frame, style: style) // 使用外部提供的 frame 值
         setupTableView()
     }

     private func setupTableView() {
         backgroundColor = .white
         // 其他設定
     }
 }
 ```

 --------

 `* 總結`
 
 - 使用 `.zero`：適合現代開發，Auto Layout 控制佈局，簡潔且符合責任分離原則。
 - 使用 `frame`：適合需要手動控制視圖位置與大小的場景，更靈活但需注意初始化階段的正確性。
 - 選擇依據：根據專案架構與佈局需求來決定，Auto Layout 為主時優先選擇 `.zero`。
 */



// MARK: - (v)

import UIKit


/// `SearchTableView`
///
/// 專為 `SearchView` 設計的自訂 `UITableView`。
///
/// - 功能：
///   1. 提供彈性垂直捲動效果，適合展示搜尋結果列表。
///   2. 隱藏垂直捲動條，讓介面更簡潔。
///   3. 自動調整行高，確保多樣化內容能完整顯示。
///   4. 設置行高的預估值，優化大數據佈局效能。
///
/// - 使用場景：
///   用於展示搜尋結果，例如飲品列表、商品項目等，提供使用者直觀且流暢的檢視體驗。
class SearchTableView: UITableView {
    
    // MARK: - Initializers
    
    /// 初始化 `SearchTableView`
    ///
    /// - 參數：
    ///   - frame: 設置表格的初始框架，但實際上設定為 `.zero` 以符合 Auto Layout 的使用。
    ///   - style: 表格的樣式，支援 `UITableView.Style` 的 `.plain` 或 `.grouped`。
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: style)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Method
    
    /// 初始化 `SearchTableView` 的相關設定。
    ///
    /// 包括：
    /// - 關閉自動轉換 Auto Layout 約束。
    /// - 設置背景顏色為白色，確保視覺清晰。
    /// - 啟用垂直彈性捲動效果，提升使用者體驗。
    /// - 隱藏垂直捲動條，讓使用介面更簡潔。
    /// - 自動調整行高，適應不同搜尋結果的內容長度。
    /// - 設置行高的預估值為 120，優化大數據的佈局效能。
    private func setupTableView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 120
    }
    
}
