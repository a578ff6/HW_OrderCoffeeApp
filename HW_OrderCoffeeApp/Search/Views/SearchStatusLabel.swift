//
//  SearchStatusLabel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/25.
//

// MARK: - SearchStatusLabel 重點筆記
/**

 ## `SearchStatusLabel` 重點筆記

` * 功能概述`
 
 - `SearchStatusLabel` 是一個自定義的 `UIView`，主要用於顯示搜尋頁面上的狀態訊息，例如「請輸入搜尋關鍵字」或「沒有符合的結果」。
 - 透過提供簡潔的狀態描述，增強使用者的體驗，讓使用者在不同的搜尋狀態下能即時得到提示。

 `* 重點功能`

 `1. 顯示狀態訊息的標籤 (UILabel)`
    - 內部的標籤 (`label`) 用於顯示當前的搜尋狀態，無論是提醒使用者輸入關鍵字，還是告知沒有符合的結果。
    - 設定字體大小為 18，顯示為灰色文字，對齊方式為置中，並允許多行顯示，以便適應各種訊息內容。

 `2. 初始化方法`
    - **`init(text:)`**：透過此初始化方法可直接在創建 `SearchStatusLabel` 時傳入要顯示的狀態文字，簡化操作。
    - **`required init?(coder:)`**：這個方法是針對 Interface Builder 或 Storyboard 初始化時使用，確保能正確建立視圖。

 `3. 佈局設定 (`setupView()`)`
    - 將標籤 (`label`) 添加到 `SearchStatusLabel` 中，並透過約束 (`constraints`) 設定標籤填滿整個視圖，確保顯示內容可以完全置中。

 `4. 更新狀態文字 (`updateText()`)`
    - **`updateText(_:)`**：這個方法用於動態更新顯示文字，例如在使用者執行新的搜尋操作時，可以更改顯示內容。

 `* 使用場景`
 
 - 在搜尋頁面中，`SearchStatusLabel` 被用來顯示當前的搜尋狀態。
 - 例如，當頁面首次載入或使用者尚未輸入任何關鍵字時，可以顯示「請輸入搜尋關鍵字」的提示；而當沒有找到符合結果時，則顯示「沒有符合的結果」。
 - 這樣的設計使得搜尋頁面更為直觀，能夠明確告知使用者當前狀態，提升整體使用體驗。
 */


// MARK: - `SearchStatusLabel` 初始化方法重點筆記（補充）
/**

 ## `SearchStatusLabel` 初始化方法重點筆記

` 1. init(text: String?) 初始化方法`
 
 `* 用途：`
   - 這個方法用於在建立 `SearchStatusLabel` 時即傳入初始的顯示文字。
   - 讓呼叫者可以在初始化的同時設定狀態標籤的內容，適用於需要在創建視圖的第一時間即顯示特定狀態的場景，例如搜尋頁面的初始提示。

 `* 設計理念：`
   - 更具語意性：透過 `init(text:)` 方法，可以立即對狀態標籤賦予特定的語意。例如，當頁面進入初始狀態時，可以傳入「請輸入搜尋關鍵字」等提示，讓初始化更符合當前場景。
   - 簡化操作：提供這樣的初始化方法，可以避免在初始化後再額外呼叫 `updateText()` 來設定文字，使代碼更簡潔易讀。

 `2. override init(frame: CGRect) 初始化方法`
 
 `* 用途：`
   - 這個方法是 UIKit 中視圖的標準初始化方法，用於在程式碼中直接創建視圖時設置其位置和大小。
   - 通常在需要手動配置視圖位置或框架時使用。

 `* 與 `init(text:)` 的比較：`
   - `應用場景不同`：`init(frame:)` 更加通用，適用於任意場景，而 `init(text:)` 更具體化，專門針對需要設定初始狀態標籤內容的需求。
   - `靈活性`：`init(frame:)` 允許手動設置視圖的大小和位置，適合更靈活的佈局需求，而 `init(text:)` 則側重於提供簡單易用的初始文字設定。

 `3. 使用 required init?(coder:)`
 
 `* 用途：`
   - `Storyboard 或 XIB 初始化`：這個方法通常是從 Interface Builder (Storyboard 或 XIB) 中初始化視圖時所必須實現的，以確保視圖能夠正確被系統反序列化和顯示。
   
 `* 為何需要這個方法：`
   - 在 Swift 中，當你自定義了一個構造器，並且希望支援 Interface Builder 的初始化方式，就必須實作 `required init?(coder:)`。
   - `setupView()` 被呼叫以確保在從 Interface Builder 初始化時，視圖仍然會配置所需的 UI 元素和佈局。

 `4. 總結`
 - `init(text:)` 提供了一個更方便的方法來在初始化時設置狀態文字，非常適合快速建立並顯示特定狀態標籤。
 - `override init(frame:)` 是一般性的初始化方法，適用於直接在程式碼中創建和控制視圖佈局。
 - `required init?(coder:)` 則是為了支援 Interface Builder 方式的初始化，確保視圖無論以哪種方式初始化，都能被正確設置和顯示。
 */


import UIKit

/// `SearchStatusLabel` 是一個自定義的 `UIView`，用於顯示搜尋頁面的狀態標籤。
/// - 主要用途：提供簡單的狀態描述，例如「請輸入搜尋關鍵字」或「沒有符合的結果」。
/// - 用於增強使用者體驗，在不同的搜尋狀態下給予使用者視覺上的提示。
class SearchStatusLabel: UIView {

    // MARK: - UI Elements
    
    /// 標籤，用於顯示狀態訊息（例如「請輸入搜尋關鍵字」或「沒有符合的結果」）
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializer
    
    /// 使用指定的文字初始化 `SearchStatusLabel`
    /// - Parameter text: 初始顯示的狀態文字
    init(text: String?) {
        super.init(frame: .zero)
        setupView()
        statusLabel.text = text
    }
    
    /// 從 Interface Builder 或 Storyboard 初始化 `SearchStatusLabel` 時的初始化方法
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup Methods
    
    /// 配置視圖的佈局和約束
    private func setupView() {
        addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Update Method
    
    /// 更新狀態標籤的顯示文字
    /// - Parameter text: 要更新的文字內容
    func updateText(_ text: String) {
        statusLabel.text = text
    }
}
