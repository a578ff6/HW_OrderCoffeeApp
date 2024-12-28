//
//  EditOrderItemPriceInfoCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/25.
//

import UIKit

/// `EditOrderItemPriceInfoCollectionViewCell`
///
/// 用於展示`編輯訂單飲品頁面`中的價格與營養資訊的自訂 `UICollectionViewCell`。
/// - 結構化顯示多種飲品屬性（價格、咖啡因、卡路里、糖含量）。
/// - 透過堆疊視圖與自訂元件（如 `EditOrderItemTitleAndValueStackView`）實現資訊排列，增強視覺可讀性與邏輯結構化。
class EditOrderItemPriceInfoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Reuse Identifier
    
    /// Cell 的重用識別碼
    static let reuseIdentifier = "EditOrderItemPriceInfoCollectionViewCell"
    
    // MARK: - UI Elements
    
    /// 價格的標籤與數值
    private let priceLabel = EditOrderItemLabel(font: .systemFont(ofSize: 16))
    private let priceValueLabel = EditOrderItemLabel(font: .systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    
    /// 咖啡因的標籤與數值
    private let caffeineLabel = EditOrderItemLabel(font: .systemFont(ofSize: 16))
    private let caffeineValueLabel = EditOrderItemLabel(font: .systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    
    /// 卡路里的標籤與數值
    private let caloriesLabel = EditOrderItemLabel(font: UIFont.systemFont(ofSize: 16))
    private let caloriesValueLabel = EditOrderItemLabel(font: UIFont.systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    
    /// 糖含量的標籤與數值
    private let sugarLabel = EditOrderItemLabel(font: UIFont.systemFont(ofSize: 16))
    private let sugarValueLabel = EditOrderItemLabel(font: UIFont.systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    
    /// 主堆疊視圖，用於排列多個屬性
    private let mainStackView = EditOrderItemStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fillEqually)
    
    // MARK: - Initializers
    
    /// 使用程式碼初始化 Cell，配置視圖與約束
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置主視圖
    ///
    /// - 將標籤與數值通過 `DrinkDetailTitleAndValueStackView` 封裝為橫向堆疊，並加入主堆疊視圖中。
    private func setupViews() {
        mainStackView.addArrangedSubview(EditOrderItemTitleAndValueStackView(titleLabel: priceLabel, valueLabel: priceValueLabel))
        mainStackView.addArrangedSubview(EditOrderItemTitleAndValueStackView(titleLabel: caffeineLabel, valueLabel: caffeineValueLabel))
        mainStackView.addArrangedSubview(EditOrderItemTitleAndValueStackView(titleLabel: caloriesLabel, valueLabel: caloriesValueLabel))
        mainStackView.addArrangedSubview(EditOrderItemTitleAndValueStackView(titleLabel: sugarLabel, valueLabel: sugarValueLabel))
        
        contentView.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure Method
    
    /// 配置 Cell 的顯示內容
    ///
    /// - 透過傳入的 `SizeInfo` 設置標籤內容，顯示價格、咖啡因、卡路里、糖分等屬性資訊。
    /// - Parameters:
    ///   - sizeInfo: 包含飲品屬性資訊的結構體。
    func configure(with sizeInfo: SizeInfo) {
        priceLabel.text = "價格（Price）"
        priceValueLabel.text = "\(sizeInfo.price) ($)"
        
        caffeineLabel.text = "咖啡因（Caffeine）"
        caffeineValueLabel.text = "\(sizeInfo.caffeine) (mg)"
        
        caloriesLabel.text = "卡路里（Calories)"
        caloriesValueLabel.text = "\(sizeInfo.calories) (Cal)"
        
        sugarLabel.text = "糖（Sugar）"
        sugarValueLabel.text = "\(sizeInfo.sugar) (g)"
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重用前重置內容，防止數據殘留
    override func prepareForReuse() {
        super.prepareForReuse()
        priceLabel.text = nil
        priceValueLabel.text = nil
        caffeineLabel.text = nil
        caffeineValueLabel.text = nil
        caloriesLabel.text = nil
        caloriesValueLabel.text = nil
        sugarLabel.text = nil
        sugarValueLabel.text = nil
    }
    
}
