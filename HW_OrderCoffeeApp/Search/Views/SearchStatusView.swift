//
//  SearchStatusView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/25.
//


// MARK: - SearchStatusView 筆記
/**
 
 ## SearchStatusView 筆記

 ---

 `* What`

 - `SearchStatusView` 是一個自訂的 `UIView`，專為顯示搜尋頁面的狀態提示而設計。

 - 主要功能
 
 1. 顯示簡單的狀態訊息，例如「請輸入搜尋關鍵字」或「沒有符合的結果」。
 2. 提供彈性樣式配置，支援自訂字體、文字顏色和文字對齊方式。
 3. 透過 Auto Layout 確保提示文字居中顯示，適配不同設備螢幕尺寸。

 - 使用場景
 
    - 作為搜尋頁面的空狀態提示，通常用於 `UITableView` 的 `backgroundView`，例如當搜尋無結果時提示使用者。

 ---------

 `* Why`
 
 - 設計原因
 
 1. 增強使用者體驗：
 
    - 提供清晰的視覺提示，幫助使用者快速了解當前搜尋狀態。
    - 避免空白畫面導致的使用者困惑。

 2. 符合單一責任原則：
 
    - `SearchStatusView` 專注於顯示搜尋狀態訊息，減少對其他元件的依賴。

 3. 提高程式碼的可重用性與可擴展性：
 
    - 支援透過初始化參數設置訊息內容與樣式，適用於不同的狀態提示需求。

 4. 為什麼使用自訂視圖而不是單純的 `UILabel`？
 
    - 結構清晰：透過封裝，將訊息顯示與佈局邏輯集中處理，避免重複程式碼。
    - 易於擴展：未來若需添加圖示、按鈕或更多元素，結構可輕鬆適應。

 5. 使用場景需求
 
    - 搜尋頁面需要根據不同的狀態（例如無結果）提供明確的提示。
    - 空狀態視圖是常見需求，統一設計能減少開發與維護成本。

 ---------

 `* How`

 1. 定義 UI 元件
 
    - 使用 `UILabel` 作為核心元素，負責顯示狀態訊息，支援多行文字、字體樣式與顏色自訂。

     ```swift
     private let messageLabel = UILabel()
     ```

 ---
 
 2. 初始化並配置視圖
 
    - 提供初始化方法，讓開發者在實例化時即可設置文字內容、字體樣式和顏色。

     ```swift
     init(message: String, font: UIFont = .systemFont(ofSize: 18, weight: .medium), textColor: UIColor = .gray) {
         super.init(frame: .zero)
         setupView(message: message, font: font, textColor: textColor)
         setupLayout()
     }
     ```

 ---

 3. 配置標籤的樣式
 
    - 設置文字內容、字體、顏色和對齊方式，確保視覺效果一致。

     ```swift
     private func setupView(message: String, font: UIFont, textColor: UIColor) {
         messageLabel.translatesAutoresizingMaskIntoConstraints = false
         messageLabel.text = message
         messageLabel.font = font
         messageLabel.textColor = textColor
         messageLabel.textAlignment = .center
         messageLabel.numberOfLines = 0
     }
     ```

 ---

 4. 使用 Auto Layout 配置佈局
 
    - 將 `messageLabel` 添加到視圖，並設置居中約束。

     ```swift
     private func setupLayout() {
         addSubview(messageLabel)
         NSLayoutConstraint.activate([
             messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
         ])
     }
     ```

 ---

 5. 在搜尋頁面中應用
 
    - 當搜尋無結果時，將 `SearchStatusView` 設為 `UITableView` 的 `backgroundView`：

     ```swift
     tableView.backgroundView = SearchStatusView(message: "No Results")
     ```

 ---------

 `* 總結`

 - What
 
    - `SearchStatusView` 是一個自訂的視圖，用於在搜尋頁面中顯示狀態提示。

 - Why
 
    1. 增強使用者體驗，提供清晰的搜尋狀態提示。
    2. 符合單一責任原則，專注處理狀態訊息顯示。
    3. 支援彈性配置，滿足多樣化需求。

 - How
 
    1. 定義 `UILabel` 作為核心元件，負責顯示訊息。
    2. 提供初始化參數，支援動態設置文字內容、字體與顏色。
    3. 使用 Auto Layout 配置標籤居中，適配多種螢幕尺寸。
    4. 在搜尋頁面中，作為 `UITableView` 的背景提示，增強使用者體驗。
 */




// MARK: - (v)

import UIKit

/// `SearchStatusView`
///
/// 一個自訂的 `UIView`，用於在搜尋頁面中顯示狀態提示，例如「請輸入搜尋關鍵字」或「沒有符合的結果」。
///
/// - 主要功能：
///   1. 顯示簡單的狀態描述，增強使用者體驗，讓使用者清楚了解搜尋結果的狀態。
///   2. 提供彈性的樣式配置，支援自訂字體、文字顏色和對齊方式。
///   3. 自動居中佈局，確保提示訊息在視圖內始終可見且美觀。
///
/// - 使用場景：
///   作為搜尋頁面的空狀態提示，通常用於 `UITableView` 的 `backgroundView`，當搜尋無結果或提示需要用戶操作時顯示。
///
/// - 特性：
///   1. 支援透過初始化參數設置文字內容、字體樣式與文字顏色。
///   2. 採用 Auto Layout 確保佈局適配不同設備與螢幕尺寸。
///   3. 可根據需求輕鬆擴展，例如添加圖示或更多自訂功能。
class SearchStatusView: UIView {
    
    // MARK: - UI Elements
    
    /// 顯示狀態訊息的標籤
    ///
    /// 用於呈現提示文字，支援多行顯示與自訂字體樣式。
    private let messageLabel = UILabel()
    
    // MARK: - Initializer
    
    /// 初始化 `SearchStatusView`
    ///
    /// - Parameters:
    ///   - message: 提示訊息內容，例如「No Results」或「Please enter search keywords」。
    ///   - font: 提示訊息的字體樣式，預設為系統字體。
    ///   - textColor: 提示訊息的文字顏色，預設為灰色。
    init(message: String, font: UIFont = .systemFont(ofSize: 18, weight: .medium), textColor: UIColor = .gray) {
        super.init(frame: .zero)
        setupView(message: message, font: font, textColor: textColor)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置標籤的樣式
    ///
    /// - Parameters:
    ///   - message: 提示文字內容。
    ///   - font: 提示文字的字體樣式。
    ///   - textColor: 提示文字的顏色。
    private func setupView(message: String, font: UIFont, textColor: UIColor) {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.font = font
        messageLabel.textColor = textColor
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
    }
    
    /// 配置標籤的佈局
    ///
    /// 使用 Auto Layout 確保標籤居中顯示於視圖內。
    private func setupLayout() {
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
