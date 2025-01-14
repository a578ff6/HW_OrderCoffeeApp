//
//  OrderrHistoryDetailCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//


import UIKit

/// 顯示歷史訂單詳細資料的基本資訊（如訂單編號、時間、總金額、總準備時間等）
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
///   用於歷史訂單頁面中，顯示訂單編號、時間、總金額等資訊的列表項目。
class OrderrHistoryDetailCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderrConfirmationDetailsCell"
    
    // MARK: - UI Elements
    
    // Order ID StackView
    private let orderIdTitleLabel = OrderHistoryDetailLabel(text: "Order ID：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let orderIdValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let orderIdStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Timestamp StackView
    private let timestampTitleLabel = OrderHistoryDetailLabel(text: "Timestamp：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let timestampValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let timestampStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Total PrepTime StackView
    private let totalPrepTimeTitleLabel = OrderHistoryDetailLabel(text: "Preparation Time：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let totalPrepTimeValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let totalPrepTimeStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Total Amount StackView
    private let totalAmountTitleLabel = OrderHistoryDetailLabel(text: "Total Amount：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let totalAmountValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let totalAmountStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Main StackView
    private let mainStackView = OrderHistoryDetailStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
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
        mainStackView.addArrangedSubview(OrderHistoryDetailBottomLineView())
        mainStackView.addArrangedSubview(timestampStackView)
        mainStackView.addArrangedSubview(OrderHistoryDetailBottomLineView())
        mainStackView.addArrangedSubview(totalPrepTimeStackView)
        mainStackView.addArrangedSubview(OrderHistoryDetailBottomLineView())
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
    /// - Parameter order: 訂單資料
    func configure(with order: OrderHistoryDetail) {
        orderIdValueLabel.text = order.id
        timestampValueLabel.text = DateUtility.formatDate(order.timestamp)
        totalPrepTimeValueLabel.text = "\(order.totalPrepTime) 分鐘"
        totalAmountValueLabel.text = "\(order.totalAmount) 元"
    }
    
}
