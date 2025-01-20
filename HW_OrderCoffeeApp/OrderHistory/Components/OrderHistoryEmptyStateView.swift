//
//  OrderHistoryEmptyStateView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/15.
//

// MARK: - OrderHistoryEmptyStateView 筆記
/**
 
 ## OrderHistoryEmptyStateView 筆記

 - 原本是單純只採用UILabel，後來發現靈活性不太好，就調整成了UIView的方式。

` * What`
 
 - `OrderHistoryEmptyStateView` 是一個專門用於顯示「無訂單」狀態的自訂視圖，設計用於提示用戶當前無訂單內容可顯示。

 - 功能特色：
 
   1. 顯示提示訊息，例如「無訂單紀錄」。
   2. 支援自訂文字樣式，包括字體、顏色及對齊方式。
   3. 自動居中顯示訊息，確保在任何情況下訊息都能被清晰呈現。
   4. 可作為 `UITableView` 的 `backgroundView`，提升介面整體一致性。

 - 使用場景：
 
   當訂單列表為空時，透過該視圖向用戶提供清楚的訊息，避免空白頁面帶來的混淆。

 --------

 `* Why`
 
 1. 提升用戶體驗：
 
    - 在訂單列表為空的情況下，提示用戶當前狀態，避免界面看起來像是錯誤或未加載完成。
    - 提供清楚的上下文訊息，幫助用戶理解系統狀態。

 2. 易於擴展與重用：
 
    - 將空狀態的視圖獨立成模組，未來可以輕鬆應用於其他需要顯示空狀態的場景，例如搜尋結果為空、網路錯誤等。

 3. 符合 iOS 的設計原則：
 
    - 使用自訂的 `UIView` 封裝空狀態視圖邏輯，符合單一責任原則，讓主視圖（如 `OrderHistoryView`）專注於佈局與控制邏輯。

 --------

 `* How`

` 1.初始化空狀態視圖`
 
 - 初始化時，傳入提示訊息內容以及相關樣式設定（字體和顏色），便於快速定制符合需求的提示視圖。

 ```swift
 let emptyStateView = OrderHistoryEmptyStateView(
     message: "No Order History",
     font: .systemFont(ofSize: 18, weight: .medium),
     textColor: .gray
 )
 ```

 ---

 `2.將視圖設為背景`
 
 - 將 `OrderHistoryEmptyStateView` 設為 `UITableView` 的 `backgroundView`，當訂單列表為空時自動顯示：

 ```swift
 func updateEmptyState(isEmpty: Bool) {
     orderHistoryTableView.backgroundView = isEmpty ? emptyStateView : nil
 }
 ```

 ---

 `3.擴展與調整`
 
 - 若未來需要擴展該視圖，例如加入圖片或按鈕，可在 `OrderHistoryEmptyStateView` 中新增子視圖並調整布局。例如，加入一個重試按鈕：

 ```swift
 let retryButton = UIButton(type: .system)
 retryButton.setTitle("Retry", for: .normal)
 retryButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
 addSubview(retryButton)

 NSLayoutConstraint.activate([
     retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
     retryButton.centerXAnchor.constraint(equalTo: centerXAnchor)
 ])
 ```

 --------

 `* 結論`
 
 - `OrderHistoryEmptyStateView` 是一個易於維護和擴展的空狀態視圖。它提供：
 
 1. 明確的提示訊息，提升用戶體驗。
 2. 符合 iOS 設計原則的結構，讓程式碼更具可讀性和可擴展性。
 3. 簡單的初始化和使用方式，快速整合到現有的 UI 中。
 */



import UIKit

/// `OrderHistoryEmptyStateView`
///
/// 用於顯示「無訂單」狀態的自訂視圖。
///
/// - 功能特色：
///   1. 顯示用戶提示訊息，例如「無訂單紀錄」。
///   2. 文字樣式支援自訂字體、顏色與對齊方式。
///   3. 自動居中佈局，確保提示訊息在視圖內始終處於可視範圍。
///
/// - 使用場景：
///   當訂單列表為空時，此視圖可作為 `UITableView` 的 `backgroundView`，用於提示用戶目前沒有可顯示的內容。
class OrderHistoryEmptyStateView: UIView {
    
    // MARK: - UI Elements
    
    /// 顯示提示訊息的標籤
    private let messageLabel = UILabel()
    
    
    // MARK: - Initializer
    
    /// 初始化 `OrderHistoryEmptyStateView`
    /// - Parameters:
    ///   - message: 提示訊息內容，例如「No Order History」。
    ///   - font: 提示訊息的字體樣式。
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
    
    /// 配置視圖與訊息標籤
    /// - Parameters:
    ///   - message: 提示訊息內容。
    ///   - font: 提示訊息的字體樣式。
    ///   - textColor: 提示訊息的文字顏色。
    private func setupView(message: String, font: UIFont, textColor: UIColor) {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.font = font
        messageLabel.textColor = textColor
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
    }
    
    /// 配置訊息標籤的佈局
    private func setupLayout() {
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
