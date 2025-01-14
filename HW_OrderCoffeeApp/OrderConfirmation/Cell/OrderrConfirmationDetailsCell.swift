//
//  OrderrConfirmationDetailsCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/3.
//

// MARK: - OrderrConfirmationDetailsCell 筆記
/**

 ## OrderrConfirmationDetailsCell 筆記

 `* What`

 1. 功能概述
 
 - `OrderrConfirmationDetailsCell` 是一個用於顯示訂單基本資訊的自訂 `UICollectionViewCell`，包括：
    - 訂單編號（Order ID）
    - 時間戳（Timestamp）
    - 總準備時間（Preparation Time）
    - 總金額（Total Amount）

 2. 結構設計
 
    - 使用多個水平堆疊視圖（`StackView`）組織標題與值。
    - 以主垂直堆疊視圖將子堆疊視圖進行整合。
    - 提供分隔線（`OrderrConfirmationBottomLineView`）以強化視覺區分。

 3. 視覺樣式
 
    - 圓角背景，適配卡片式 UI 設計。
    - 統一的字體樣式與配色，保證清晰度和一致性。

 ----------

 `* Why`

 1. 結構清晰，易於維護
 
    - 使用堆疊視圖統一管理佈局，減少手動約束的複雜度，提升可讀性。
    - 將格式化日期的邏輯抽取到 `DateUtility`，讓格式化邏輯集中管理，避免代碼重複。

 2. 靈活性與擴展性
 
    - 通過設計 `configure` 方法，支持接收訂單資料模型（`OrderConfirmation`）來進行動態顯示。
    - 可輕鬆添加更多資訊（如額外的費用或備註）至堆疊視圖，滿足不同需求。

 3. 一致的視覺設計
 
    - 使用統一的分隔線和背景設計，確保列表項目的樣式一致。
    - 使用壓縮與擠壓優先級，讓標題與值的展示更穩定，不因內容長短而錯位。

 4. 適合多個場景
 
    - 用於訂單確認頁面中的訂單摘要。
    - 適合擴展至歷史訂單或訂單詳情頁面。

 ----------

 `* How`

 1. 子堆疊視圖的組織
 
    - 每一個子堆疊視圖負責顯示一個資訊單元（例如：`Order ID`）。
    - 子堆疊視圖內，標題與值按照固定的對齊方式排列（`equalSpacing`）。

    ```swift
    orderIdStackView.addArrangedSubview(orderIdTitleLabel)
    orderIdStackView.addArrangedSubview(orderIdValueLabel)
    ```

 ---

 2. 主堆疊視圖的整合
 
    - 將所有子堆疊視圖與分隔線添加到主堆疊視圖，保證上下結構清晰。
    - 使用自訂分隔線（`OrderrConfirmationBottomLineView`）提升視覺層次感。

    ```swift
    mainStackView.addArrangedSubview(orderIdStackView)
    mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
    ```

 ---

 3. 樣式配置
 
    - 設置 `contentView` 的圓角和背景色，確保統一的卡片樣式。

    ```swift
    contentView.layer.cornerRadius = 10
    contentView.backgroundColor = UIColor.lightWhiteGray.withAlphaComponent(0.3)
    ```
 
 ---

 4. 日期格式化
 
    - 使用 `DateUtility.formatDate` 進行統一格式化，簡化日期顯示邏輯。

    ```swift
    timestampValueLabel.text = DateUtility.formatDate(order.timestamp)
    ```

 ---

 5. Auto Layout 配置
 
    - 通過設置約束確保主堆疊視圖的邊距和對齊。
    - 壓縮與擠壓優先級的設置，保證標題和值的長度分配合理。

    ```swift
    NSLayoutConstraint.activate([
        mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
        mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
    ])
    ```

 ---
 
 6. 使用方式
 
    - 調用 `configure(with:)` 方法，將訂單模型數據綁定到 Cell。

    ```swift
    func configure(with order: OrderConfirmation) {
        orderIdValueLabel.text = order.id
        timestampValueLabel.text = DateUtility.formatDate(order.timestamp)
        totalPrepTimeValueLabel.text = "\(order.totalPrepTime) 分鐘"
        totalAmountValueLabel.text = "\(order.totalAmount) 元"
    }
    ```
 */


import UIKit

/// 顯示訂單的基本資訊（如訂單編號、時間、總金額、總準備時間等）
///
/// - 此 Cell 主要由多個水平堆疊視圖（StackView）組成，
///   用於以統一的樣式顯示訂單相關的文字資訊。
///
/// - 功能特點：
///   1. 支援格式化日期，顯示可讀性強的時間資訊。
///   2. 各屬性標題與值分開顯示，符合直觀的排版結構。
///   3. 支援多行堆疊，便於擴展其他資訊。
///
/// - 使用場景：
///   用於訂單確認頁面中，顯示訂單編號、時間、總金額等資訊的列表項目。
class OrderrConfirmationDetailsCell: UICollectionViewCell {
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderrConfirmationDetailsCell"
    
    // MARK: - UI Elements
    
    // Order ID StackView
    private let orderIdTitleLabel = OrderConfirmationLabel(text: "Order ID：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let orderIdValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let orderIdStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Timestamp StackView
    private let timestampTitleLabel = OrderConfirmationLabel(text: "Timestamp：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let timestampValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let timestampStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Total PrepTime StackView
    private let totalPrepTimeTitleLabel = OrderConfirmationLabel(text: "Preparation Time：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let totalPrepTimeValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let totalPrepTimeStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Total Amount StackView
    private let totalAmountTitleLabel = OrderConfirmationLabel(text: "Total Amount：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let totalAmountValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let totalAmountStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Main StackView
    private let mainStackView = OrderConfirmationStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        styleCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 配置 Cell 的布局，包括子堆疊視圖內容、主堆疊視圖、約束與優先級。
    private func setupLayout() {
        setupStackViewContent()
        setupMainStackView()
        setupMainStackViewConstraints()
        setupContentPriorities()
    }
    
    /// 配置各子堆疊視圖的內容（標題與值）
    private func setupStackViewContent() {
        orderIdStackView.addArrangedSubview(orderIdTitleLabel)
        orderIdStackView.addArrangedSubview(orderIdValueLabel)
        
        timestampStackView.addArrangedSubview(timestampTitleLabel)
        timestampStackView.addArrangedSubview(timestampValueLabel)
        
        totalPrepTimeStackView.addArrangedSubview(totalPrepTimeTitleLabel)
        totalPrepTimeStackView.addArrangedSubview(totalPrepTimeValueLabel)
        
        totalAmountStackView.addArrangedSubview(totalAmountTitleLabel)
        totalAmountStackView.addArrangedSubview(totalAmountValueLabel)
    }
    
    /// 配置主堆疊視圖的內容（包含子堆疊視圖與分隔線）
    private func setupMainStackView() {
        mainStackView.addArrangedSubview(orderIdStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
        mainStackView.addArrangedSubview(timestampStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
        mainStackView.addArrangedSubview(totalPrepTimeStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
        mainStackView.addArrangedSubview(totalAmountStackView)
        
        contentView.addSubview(mainStackView)
    }
    
    /// 配置主堆疊視圖的 Auto Layout
    private func setupMainStackViewConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    /// 設置壓縮與擠壓優先級，確保內容顯示的穩定性
    private func setupContentPriorities() {
        orderIdTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        orderIdValueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        orderIdTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        orderIdValueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    /// 配置 Cell 的樣式（圓角和背景色）
    private func styleCell() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.lightWhiteGray.withAlphaComponent(0.3)
    }
    
    // MARK: - Configuration Method
    
    /// 設置訂單的基本資訊
    ///
    /// - Parameter order: 訂單資料
    func configure(with order: OrderConfirmation) {
        orderIdValueLabel.text = order.id
        timestampValueLabel.text = DateUtility.formatDate(order.timestamp)
        totalPrepTimeValueLabel.text = "\(order.totalPrepTime) 分鐘"
        totalAmountValueLabel.text = "\(order.totalAmount) 元"
    }
    
}
