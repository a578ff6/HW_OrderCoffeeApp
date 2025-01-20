//
//  OrderHistoryTableView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/14.
//

// MARK: - 關於設置 rowHeight 和 estimatedRowHeight：
/**
 
 ## 關於設置 rowHeight 和 estimatedRowHeight：
 
 `1. rowHeight 設置為 UITableView.automaticDimension：`
 
    - 表示表格視圖的行高是自動計算的，基於內容和布局約束來確定每一行的高度。這通常用於支持動態高度的 Cell，尤其是當 Cell 的內容（如文本）長度不固定時。

 -----
 
 `2. estimatedRowHeight 設置為一個預估的值：`
 
    - `estimatedRowHeight` 為 UITableView 提供一個估算的行高，幫助它提前計算和優化捲動的性能。如果不設置，UITableView 可能會花較多的時間來計算整個表格的佈局。
    - 通常來說，設置一個大致的預估高度，比如 60，能夠幫助 UITableView 更流暢地加載和捲動。
 */


// MARK: - OrderHistoryTableView 筆記
/**
 
 ## OrderHistoryTableView 筆記


` * What`
 
 - `OrderHistoryTableView` 是專為 `OrderHistoryView` 設計的自訂 `UITableView`，用於顯示歷史訂單的主要內容。

 - 功能特色：
 
   1. 支援垂直彈性捲動，提供流暢的捲動體驗。
   2. 隱藏垂直捲動條，保持視覺介面的簡潔。
   3. 支援編輯模式下的多選功能，方便用戶進行批次操作。
   4. 自動調整行高，適應不同內容的長度，確保最佳化顯示效果。
   5. 設置行高的預估值，提升表格的佈局效能。

 - 使用場景：
 
   該表格主要用於展示歷史訂單的清單內容，例如訂單名稱、時間及金額等資訊。

 ----------

 `* Why`

` - 為什麼需要 OrderHistoryTableView？`
 
 1. 專屬設計，提升可讀性與可維護性：
 
    - 通過獨立的類別實現，讓表格的配置邏輯與通用的 `UITableView` 分離，避免主視圖或控制器中出現多餘的配置邏輯。

 2. 簡化重複設定：
 
    - 預設行為（如隱藏捲動條、自動調整行高等）在類別中統一實現，減少開發者的重複工作。

 3. 強化用戶體驗：
 
    - 支援彈性捲動和多選編輯功能，讓用戶可以更高效地操作訂單列表。

 ---

 `- 為什麼設置 rowHeight = UITableView.automaticDimension？`
 
 1. 自動調整行高：
 
    - 表格的每個 `Cell` 行高根據內容的大小自動調整，避免內容被裁切或顯示空白。
    - 特別適合訂單清單中內容長度不固定的情境，例如訂單名稱可能較短，但備註資訊可能較長。

 2. 減少硬編碼：
 
    - 不需要手動為每個 `Cell` 設定固定的行高，讓設計更加靈活且未來易於維護。

 ---

 `- 為什麼設置 estimatedRowHeight？`
 
 1. 提升佈局效能：
 
    - `UITableView` 在加載大量數據時，透過設定預估行高（如 60），可以快速計算內容的總高度，優化佈局的渲染效能。
    - 避免每次重繪時都進行完整的行高計算，特別是在長列表的情況下。

 2. 減少加載延遲：
 
    - 預估行高讓表格在初次加載時更加流暢，用戶可以快速開始操作。

 ----------

 `* How`

 1. 初始化表格
 
    - 使用自訂的 `OrderHistoryTableView` 來取代通用的 `UITableView`，並在初始化時完成基礎配置：
 
    ```swift
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: style)
        setupTableView()
    }
    ```

 ---

 2. 配置表格屬性
 
    - 在 `setupTableView` 方法中設置表格的相關屬性：
      - **垂直彈性捲動**：`alwaysBounceVertical = true`
      - **隱藏捲動條**：`showsVerticalScrollIndicator = false`
      - **支援多選編輯模式**：`allowsMultipleSelectionDuringEditing = true`
      - **自動行高**：`rowHeight = UITableView.automaticDimension`
      - **行高預估值**：`estimatedRowHeight = 60`
 
    ```swift
    private func setupTableView() {
        translatesAutoresizingMaskIntoConstraints = false
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        allowsMultipleSelectionDuringEditing = true
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 60
    }
    ```
 
 ---

 3. 整合至主視圖
 
    - 將 `OrderHistoryTableView` 整合至 `OrderHistoryView`，作為主要的訂單列表顯示元件。
    - 透過 `UITableView` 的自動行高功能，確保列表顯示效果最佳化。

 ----------

 `* 設計總結`

 1. 優勢：
 
    - 提升程式碼結構的清晰度與模組化，讓表格配置更專注且便於維護。
    - 自動行高和行高預估值的設置，提供優化的顯示與加載效能。
    - 支援用戶友好的功能（如多選編輯和垂直彈性捲動），提升操作體驗。

 2. 適用場景：
 
    - 需要顯示動態列表內容的情境，特別是內容長度不固定、可能包含大量數據的訂單清單。

 3. 改進方向：
 
    - 若未來需要支援更多功能（如分段顯示或自訂行樣式），可以進一步擴展 `OrderHistoryTableView`，提供更高的靈活性。
 */



import UIKit

/// `OrderHistoryTableView`
///
/// 專為 `OrderHistoryView` 設計的自訂 `UITableView`。
///
/// - 功能：
///   1. 提供彈性垂直捲動效果，適合顯示多筆訂單資料。
///   2. 隱藏垂直捲動條，提升視覺簡潔性。
///   3. 支援編輯模式下的多選功能，方便使用者一次操作多筆資料。
///   4. 自動調整行高，確保內容顯示最佳化。
///   5. 設置行高預估值以優化佈局效能。
///
/// - 使用場景：
///   用於展示歷史訂單的主要表格內容，例如訂單名稱、時間及金額等資訊。
class OrderHistoryTableView: UITableView {
    
    // MARK: - Initializers
    
    /// 初始化 `OrderHistoryTableView`
    ///
    /// - 參數：
    ///   - frame: 設置表格的初始框架，預設為 `.zero`。
    ///   - style: 表格的樣式，預設為 `UITableView.Style`。
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: style)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Method
    
    /// 設定 `OrderHistoryTableView` 的相關屬性。
    ///
    /// 包括：
    /// - 關閉自動轉換 Auto Layout 約束。
    /// - 啟用垂直彈性捲動效果，提升使用者體驗。
    /// - 隱藏垂直捲動條，讓介面更簡潔。
    /// - 支援編輯模式下的多選操作，方便批次處理。
    /// - 自動調整行高，適應不同內容的長度。
    /// - 設置行高的預估值為 80，優化佈局效能。
    private func setupTableView() {
        translatesAutoresizingMaskIntoConstraints = false
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        allowsMultipleSelectionDuringEditing = true
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 80
    }
    
}
