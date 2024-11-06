//
//  OrderrConfirmationDetailsCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/3.
//

import UIKit

/// 顯示訂單的基本資訊（如訂單編號、時間、總金額、總準備時間等）
class OrderrConfirmationDetailsCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderrConfirmationDetailsCell"

    // MARK: - UI Elements
    
    // Order ID StackView
    private let orderIdTitleLabel = createLabel(text: "Order ID:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let orderIdValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor: .gray, scaleFactor: 0.5)
    private let orderIdStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Timestamp StackView
    private let timestampTitleLabel = createLabel(text: "Timestamp:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let timestampValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor: .gray, scaleFactor: 0.5)
    private let timestampStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Total PrepTime StackView
    private let totalPrepTimeTitleLabel = createLabel(text: "Preparation Time:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let totalPrepTimeValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor: .gray, scaleFactor: 0.5)
    private let totalPrepTimeStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Total Amount StackView
    private let totalAmountTitleLabel = createLabel(text: "Total Amount:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let totalAmountValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor: .gray, scaleFactor: 0.5)
    private let totalAmountStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Main StackView
    private let mainStackView = createStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
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
    
    private func setupLayout() {
        // 配置每個水平 StackView 的內容
        orderIdStackView.addArrangedSubview(orderIdTitleLabel)
        orderIdStackView.addArrangedSubview(orderIdValueLabel)
        
        timestampStackView.addArrangedSubview(timestampTitleLabel)
        timestampStackView.addArrangedSubview(timestampValueLabel)
        
        totalPrepTimeStackView.addArrangedSubview(totalPrepTimeTitleLabel)
        totalPrepTimeStackView.addArrangedSubview(totalPrepTimeValueLabel)
        
        totalAmountStackView.addArrangedSubview(totalAmountTitleLabel)
        totalAmountStackView.addArrangedSubview(totalAmountValueLabel)
        
        // 將所有子 StackView 添加到主 StackView
        mainStackView.addArrangedSubview(orderIdStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationDetailsCell.createSeparatorView(height: 1))
        mainStackView.addArrangedSubview(timestampStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationDetailsCell.createSeparatorView(height: 1))
        mainStackView.addArrangedSubview(totalPrepTimeStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationDetailsCell.createSeparatorView(height: 1))
        mainStackView.addArrangedSubview(totalAmountStackView)
        
        // 添加主 StackView 到 contentView
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
        
        // 確保 orderId 標籤之間的擠壓和拉伸優先級設置適當
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
    
    // MARK: - Factory Methods
    
    /// 建立並配置 UILabel
    private static func createLabel(text: String? = nil, font: UIFont, numberOfLines: Int = 1, textAlignment: NSTextAlignment = .left, textColor: UIColor = .black, scaleFactor: CGFloat = 1.0) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = font
        label.numberOfLines = numberOfLines
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.minimumScaleFactor = scaleFactor
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    /// 建立並配置 UIStackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// 建立一個分隔視圖（Separator View）
    /// - Parameter height: 分隔視圖的高度
    /// - Returns: 設置好的 UIView
    private static func createSeparatorView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        view.backgroundColor = UIColor.lightWhiteGray
        return view
    }
    
    // MARK: - Helper Method
    
    /// 格式化日期顯示
    /// - Parameter date: 要格式化的日期
    /// - Returns: 格式化後的日期字串
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Configuration Method
    
    /// 設置訂單的基本資訊
    /// - Parameter order: 訂單資料
    func configure(with order: OrderConfirmation) {
        orderIdValueLabel.text = order.id
        timestampValueLabel.text = formatDate(order.timestamp)
        totalPrepTimeValueLabel.text = "\(order.totalPrepTime) 分鐘"
        totalAmountValueLabel.text = "\(order.totalAmount) 元"
    }
    
}
