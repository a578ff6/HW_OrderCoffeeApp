//
//  OrderHistoryView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - OrderHistoryView 重點筆記

/**
 `* 概述：`
 
 - `OrderHistoryView` 是一個自定義視圖，包含用於顯示歷史訂單的 `UITableView`，並處理當訂單列表為空時的視覺效果。
 - 提供了動態行高的支持，以便根據訂單資料自動調整行高。
 
` * 重點設計：`

 `1. 自動行高：`
    - `ableView.rowHeight = UITableView.automaticDimension`：設置行高為自動計算，允許根據內容動態調整。
    - `tableView.estimatedRowHeight = 60`：設置行高的預估值，幫助表格視圖提前優化佈局和提高滾動性能。
 
 `2. 統一配置：`
     - `createTableView()` 為表格視圖的創建和配置提供了一個統一的方法，確保每次初始化表格視圖時的設置是一致的。
     - `createLabel()` 用於創建標籤 (例如用於「無歷史訂單」的顯示)，確保所有標籤的配置和樣式保持一致。
  
` 3. 佈局和約束管理：`
     - 使用 Auto Layout 約束 (`NSLayoutConstraint.activate`) 來確保 `tableView` 填滿整個 `OrderHistoryView`，使得視圖可以在不同設備和尺寸下自適應。
 
 `4. 空狀態管理：`
     - `emptyLabel`：當訂單列表為空時，用於顯示「無訂單項目」的標籤。
     - `updateEmptyState(isEmpty:)`：根據訂單列表是否為空來設置 `tableView` 的背景視圖。如果訂單列表為空，顯示 `emptyLabel`；否則，隱藏該標籤。
 */


// MARK: - 關於設置 rowHeight 和 estimatedRowHeight：
/**
 ## 關於設置 rowHeight 和 estimatedRowHeight：
 
 `1. rowHeight 設置為 UITableView.automaticDimension：`
 
    - 表示表格視圖的行高是自動計算的，基於內容和布局約束來確定每一行的高度。這通常用於支持動態高度的 Cell，尤其是當 Cell 的內容（如文本）長度不固定時。

 `2. estimatedRowHeight 設置為一個預估的值：`
 
    - `estimatedRowHeight` 為 UITableView 提供一個估算的行高，幫助它提前計算和優化捲動的性能。如果不設置，UITableView 可能會花較多的時間來計算整個表格的佈局。
    - 通常來說，設置一個大致的預估高度，比如 60，能夠幫助 UITableView 更流暢地加載和捲動。
 */

// MARK: - 關於「可以不要用 translatesAutoresizingMaskIntoConstraints = false」的重點筆記
/**
 ## 關於「可以不要用 translatesAutoresizingMaskIntoConstraints = false」的重點筆記
 
 `* 情境描述：`
    - 當想要在 `UITableView` 的背景中顯示一個簡單的訊息（例如「無訂單項目」）時，可以使用 UILabel 作為背景視圖。
 
 `* 不設置 translatesAutoresizingMaskIntoConstraints 的原因：`
    - 在這個情境下，不設置 `translatesAutoresizingMaskIntoConstraints = false` 代表 UIKit 會自動使用 `AutoresizingMask` 來管理這個 UILabel 的佈局。這使得 UILabel 能自動居中於背景中，符合預期的需求。
 
 `* 適用的情境：`
    - 當不需要自訂的佈局約束、且只需簡單顯示訊息時，保持 `translatesAutoresizingMaskIntoConstraints` 為 true 可以簡化佈局程式碼並達到自動置中的效果。
 
 `* 重點：`
    - 若想讓 UILabel 的位置和大小由自動調整的遮罩決定並置於 UITableView 背景中，則可以保持默認行為（不設置 translatesAutoresizingMaskIntoConstraints）。
    - 但是，若有自定義佈局需求（如特定位置、距離等），則需要將 translatesAutoresizingMaskIntoConstraints 設為 false 並手動添加約束。
 */

// MARK: - OrderHistoryView 顯示「無訂單項目」的設計選擇（重要）
/**
## OrderHistoryView 顯示「無訂單項目」的設計選擇

 `* 概述：`

 - 當顯示歷史訂單列表時，如果沒有任何訂單，會提供一個提示用戶「無訂單項目」的狀態訊息。
 - 在 `OrderHistoryView` 中，我選擇直接使用` tableView.backgroundView` 來顯示空狀態提示，而非使用獨立的 `UIView`。

 `* 原始設計選擇：`
 
 `1. 獨立的 NoOrderHistoryView：`
 
 - 我曾經設計了一個名為 `NoOrderHistoryView` 的獨立視圖，用於顯示「無訂單項目」的提示。
 - 該視圖包含一個 `UILabel`，手動設定其約束以顯示在父視圖中間。
 - `問題：`
    - 當進入或離開 `OrderHistoryViewController` 時，視圖的過渡和佈局出現了不一致的行為，例如視覺跳動或不流暢的過渡動畫。

 `2. 改善方案：`
 
 `* 使用 tableView.backgroundView：`
    - 我將提示訊息直接作為 `tableView.backgroundView`，而不是獨立的 `UIView`。
    - 使用一個簡單的 UILabel 作為背景視圖 (backgroundView)，這個屬性可以自動居中顯示，無需額外的佈局處理。
    - `效果：`
        - 過渡體驗變得更為平滑，沒有出現之前遇到的跳動或佈局錯誤問題。
 
 `3. 背景視圖的優勢：`
 
 `* 簡單和直接：`
    - `UITableView` 的 `backgroundView` 是專門為解決表格內容為空的狀況而設計的。
    - 它允許在不增加額外子視圖和佈局管理的情況下，直接提供一個提示信息。
 
 `* 減少佈局的複雜性：`
    - 使用獨立的 `UIView` 需要手動添加到父視圖並配置約束，這些額外的操作帶來潛在的佈局錯誤，尤其是在視圖層次結構比較複雜時。
    - `backgroundView` 自動處理佈局和顯示問題，簡化了整體設計。
 
 `* 專門設計的屬性：`
    - `backgroundView` 本身就是為了解決當 `UITableView` 為空時如何提示的問題。
    - 系統自帶的 `backgroundView` 設置可以確保內容為空的情況下，視圖能夠自然居中顯示，且過渡動畫處理流暢一致。
 
 `4. 設計總結：`
 
 - 當需要顯示空狀態提示時，直接利用 `UITableView` 的 `backgroundView` 是更好的選擇。
 - 它提供了更簡單的佈局和更佳的用戶體驗，避免了手動處理約束可能帶來的潛在錯誤。
 - 遵循「簡單即最佳」的原則，減少多餘的視圖層級和佈局邏輯，確保應用在進入和退出場景時的過渡效果一致且流暢。
 */


// MARK: - UITableView 與 UICollectionView 空狀態處理的重點筆記（重要）
/**
 ## UITableView 與 UICollectionView 空狀態處理的重點筆記

 - 主要是先前在 「`我的最愛UICollectionView`」是採用獨立的視圖來處理「空狀態」，就想說「UITableView」也是相同處理方式，結果就產生視圖佈局跟畫面過度的錯亂問題。
 
 
 `* 概述：`
    - 在 UI 開發中，當 UITableView 或 UICollectionView 沒有內容時，通常會顯示「無項目」的提示訊息。
    - `UITableView` 和 `UICollectionView` 在處理空狀態的顯示方式上有所不同，這與它們各自的設計特點和靈活性有關。
 
` 1. UITableView 的空狀態處理`

 `* backgroundView 屬性：`
    - UITableView 提供了一個 backgroundView 屬性，專門用於處理當表格內容為空的情況。
    - 當 tableView 中沒有任何 cell 需要顯示時，可以將自定義的 `UIView`（例如 UILabel）設置為 `backgroundView`，此視圖會自動顯示在表格中央。
    - 使用 backgroundView 不僅減少額外的佈局處理，而且能確保提示信息在表格為空時自動顯示。
 
 `2. UICollectionView 的空狀態處理`

 `* 沒有 backgroundView 屬性：`
    - 與 UITableView 不同，UICollectionView 並不直接提供一個 backgroundView 屬性來顯示空狀態。
    - 當 `collectionView` 沒有任何 cell 時，通常需要自行設置一個「空狀態」的提示視圖 (`emptyStateView`)，並手動管理其顯示和隱藏。

 `* 常見處理方式：`
    - 可以在 UICollectionView 的父視圖中添加一個「空狀態」提示視圖，並根據 collectionView 的數據源來顯示或隱藏它。
    - 這種方法需要手動控制提示視圖和 collectionView 的顯示與隱藏狀態。
 
 `3. 為什麼設計不同？`

 `* 用戶界面模式差異：`
    - `UITableView` 通常是一個垂直滾動的單列表格，當內容為空時顯示提示信息非常常見。因此，Apple 提供了 backgroundView 來簡化空狀態的處理。
    - `UICollectionView` 則更加靈活，可以支持多種佈局（如網格、水平滾動等）。這種靈活性使得開發者在處理空狀態時有更多的自定義需求，因此沒有提供一個預設的 backgroundView 屬性。

 `* 靈活性與自定義需求：`
    - `UICollectionView` 的設計更強調靈活性，開發者可以根據需求來設計空狀態的顯示方式，例如特定的動畫效果或自定義佈局。
    - `UITableView` 則相對簡單，適合使用一個固定的空狀態提示視圖來滿足大多數應用場景。

 `4. 總結`
    - 對於 UITableView，可以使用 backgroundView 來方便地顯示空狀態，並且系統自動處理視覺效果。
    - 對於 UICollectionView，開發者需要自行創建和管理「空狀態視圖」，這雖然增加了一些額外工作，但也提供了更高的自由度來設計出符合應用需求的視覺效果。
 */


import UIKit

/// 自定義視圖，包含用於顯示歷史訂單的 `UITableView` 及「無訂單項目」的狀態視圖。
class OrderHistoryView: UIView {

    // MARK: - UI Elements
    
    /// 用於顯示歷史訂單的 UITableView
    let tableView = OrderHistoryView.createTableView()
    /// 用於顯示「無訂單項目」
    let emptyLabel = OrderHistoryView.createLabel(text: "No Order History")
    
    // MARK: - Initializers

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
    
    /// 設置表格的佈局，使表格填滿整個視圖
    private func setupLayout() {
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊表格視圖使用的 Cell 類型
    private func registerCells() {
        tableView.register(OrderHistoryCell.self, forCellReuseIdentifier: OrderHistoryCell.reuseIdentifier)
    }

    // MARK: - Factory Methods

    /// 建立並配置表格視圖
    private static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.alwaysBounceVertical = true                       // 總是允許垂直捲動
        tableView.showsVerticalScrollIndicator = false              // 隱藏垂直捲動條
        tableView.allowsMultipleSelectionDuringEditing = true       // 允許編輯模式下多選
        tableView.rowHeight = UITableView.automaticDimension        // 行高自動調整
        tableView.estimatedRowHeight = 60                           // 行高的預估值，幫助優化佈局
        return tableView
    }
    
    /// 建立並配置 UILabel
    private static func createLabel(text: String? = nil, font: UIFont = UIFont.systemFont(ofSize: 18, weight: .medium), textAlignment: NSTextAlignment = .center, textColor: UIColor = .gray) -> UILabel {
        let label = UILabel()
        // `translatesAutoresizingMaskIntoConstraints` 在此情境中保持默認 `true`，使背景視圖能自動居中
        label.text = text
        label.font = font
        label.textAlignment = textAlignment
        label.textColor = textColor
        return label
    }
    
    // MARK: - Empty State Management

    /// 更新表格視圖的空狀態
    /// - Parameter isEmpty: 如果訂單列表為空，設置 `tableView` 的 `backgroundView` 為 `emptyLabel`；否則為 `nil`。
    func updateEmptyState(isEmpty: Bool) {
        tableView.backgroundView = isEmpty ? emptyLabel : nil
    }
    
}
