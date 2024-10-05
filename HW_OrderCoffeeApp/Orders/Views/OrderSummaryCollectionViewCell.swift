//
//  OrderSummaryCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/12.
//

/*
 ## OrderSummaryCollectionViewCell 重點筆記
 
    * 功能概述：
        - 顯示訂單的總金額 (Total Amount) 和準備時間 (Preparation Time)。
        - 包含標題、數值顯示，搭配圖標增強可視性。
 
    * 視圖設置：
        - createLabel()： 建立標題與數值顯示的標籤。
        - createStackView()： 建立垂直或水平的堆疊視圖以組織 UI 元件。
        - createIconImageView()： 建立顯示圖標的 UIImageView，用於標題旁邊。
        - 使用 UIStackView 將標題、圖標及數值整合成不同的組合，便於視覺呈現和布局調整。
 */

import UIKit

/// 展示訂單的總金額、準備時間
class OrderSummaryCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderSummaryCollectionViewCell"
    
    // MARK: - UI Elements

    // 顯示總金額、總金額數值
    let totalAmountLabel = createLabel(text: "Total Amount", font: .systemFont(ofSize: 16, weight: .bold), textColor: .lightGray)
    let totalAmountValueLabel = createLabel(text: "$ 0", font: .systemFont(ofSize: 16, weight: .medium), textColor: .lightGray)
    
    // 顯示準備時間、準備時間數值
    let totalPrepTimeLabel = createLabel(text: "Preparation Time", font: .systemFont(ofSize: 16, weight: .bold), textColor: .lightGray)
    let totalPrepTimeValueLabel = createLabel(text: "0 min", font: .systemFont(ofSize: 16, weight: .medium), textColor: .lightGray)
    
    // 包含所有訂單資訊
    let orderSummaryStackView = createStackView(axis: .vertical, spacing: 10, distribution: .fillEqually, alignment: .fill)
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    private func setupView() {
        let totalAmountStackView = createLabelStackView(titleLabel: totalAmountLabel, valueLabel: totalAmountValueLabel, icon: UIImage(systemName: "dollarsign.circle"))
        let totalPrepTimeStackView = createLabelStackView(titleLabel: totalPrepTimeLabel, valueLabel: totalPrepTimeValueLabel, icon: UIImage(systemName: "clock"))
        
        orderSummaryStackView.addArrangedSubview(totalAmountStackView)
        orderSummaryStackView.addArrangedSubview(totalPrepTimeStackView)
        
        contentView.addSubview(orderSummaryStackView)
        NSLayoutConstraint.activate([
            orderSummaryStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            orderSummaryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            orderSummaryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            orderSummaryStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Factory Methods
    
    /// 建立 Label
    private static func createLabel(text: String, font: UIFont, textColor: UIColor, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 建立堆疊視圖
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, distribution: UIStackView.Distribution, alignment: UIStackView.Alignment = .fill) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// 建立`標題`與`圖標`的堆疊視圖
    private func createLabelStackView(titleLabel: UILabel, valueLabel: UILabel, icon: UIImage?) -> UIStackView {
    
        let iconImageView = OrderSummaryCollectionViewCell.createIconImageView(icon: icon)
        let titleStackView = OrderSummaryCollectionViewCell.createTitleStackView(iconImageView: iconImageView, titleLabel: titleLabel)
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        return OrderSummaryCollectionViewCell.createMainStackView(titleStackView: titleStackView, valueLabel: valueLabel)
    }
    
    /// 建立圖標視圖
    private static func createIconImageView(icon: UIImage?) -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(weight: .medium)
        let mediumIcon = icon?.withConfiguration(configuration)
        let iconImageView = UIImageView(image: mediumIcon)
        iconImageView.tintColor = .gray
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return iconImageView
    }
    
    /// 建立包含圖標與標題的堆疊視圖
    private static func createTitleStackView(iconImageView: UIImageView, titleLabel: UILabel) -> UIStackView {
        let titleStackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 4
        titleStackView.alignment = .center
        return titleStackView
    }
    
    /// 建立主要的堆疊視圖，包含標題與值
    private static func createMainStackView(titleStackView: UIStackView, valueLabel: UILabel) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, valueLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }
    
    // MARK: - Configure Method
    
    /// 配置`總金額`與`準備時間`的值
    func configure(totalAmount: Int, totalPrepTime: Int) {
        totalAmountValueLabel.text = "$ \(totalAmount)"
        totalPrepTimeValueLabel.text = "\(totalPrepTime) min"
    }
    
    // MARK: - Lifecycle Methods

    override func prepareForReuse() {
        super.prepareForReuse()
        totalAmountValueLabel.text = "$ 0"
        totalPrepTimeValueLabel.text = "0 min"
    }

}
