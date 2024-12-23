//
//  DrinkPriceInfoCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/16.
//

// MARK: - 筆記：DrinkPriceInfoCollectionViewCell
/**
 
 ## 筆記：DrinkPriceInfoCollectionViewCell
 
 `* What`
 
 - `DrinkPriceInfoCollectionViewCell` 是一個自訂的 UICollectionViewCell，用於在飲品詳細頁展示飲品的價格與營養資訊。其特性包括：

 1.`多屬性展示`：支援顯示價格、咖啡因含量、卡路里與糖分。
 2.`視覺結構化`：透過垂直堆疊視圖（DrinkDetailStackView）與橫向堆疊視圖（`DrinkDetailTitleAndValueStackView`）進行屬性排列。
 
 -----------------------
 
 `* Why`
 
 - 設計此 Cell 的目的是：

 `1.結構化展示資訊：`

 - 每個屬性（如價格、卡路里）均包含標題與數值，並使用自訂的堆疊視圖進行排列。
 - 增強視覺層次感，方便用戶快速識別重要資訊。
 
 `2.高可維護性：`

 - 將每組標題與數值封裝為 `DrinkDetailTitleAndValueStackView`，降低重複代碼。
 - 主堆疊視圖使用 `DrinkDetailStackView` 管理所有屬性，確保結構清晰且易於調整。
 
 `3.靈活性與重用性：`

 - 元件化設計（如 `DrinkDetailLabel` 和 `DrinkDetailTitleAndValueStackView`），便於擴展與修改。
 
 -----------------------

 `* How`

 `1.初始化與配置：`

 - 初始化時通過 setupViews 添加屬性堆疊至主堆疊視圖，並設置約束確保內容居中排列。
 - 使用` configure(with:) `方法設置具體屬性值，更新顯示內容。
 
 `2.重用管理：`

 - 在 prepareForReuse 方法中重置所有標籤的文本，避免數據殘留影響下一次展示。
 
 `3.組件化：`

 - 使用 `DrinkDetailTitleAndValueStackView` 簡化每組屬性（標題與數值）的視圖配置。
 - 將常用的標籤樣式封裝為 `DrinkDetailLabel`，提升代碼可重用性。
 
 -----------------------

 `* 總結`
 
 `1.封裝性：`

 - 確保 `DrinkPriceInfoCollectionViewCell` 的子視圖與配置邏輯對外透明，只需通過` configure(with:) `提供數據即可。
 
 `2.可擴展性：`

 - 如需增加新屬性（例如脂肪含量），只需在主堆疊視圖中添加一個新的 `DrinkDetailTitleAndValueStackView` 即可。
 
 `3.視覺一致性：`

 - 確保所有屬性的標題與數值使用一致的字體樣式與對齊方式，避免用戶對界面風格的混淆。
 */



// MARK: - (v)


import UIKit

/// `DrinkPriceInfoCollectionViewCell`
///
/// 用於展示飲品詳細頁中的價格與營養資訊的自訂 `UICollectionViewCell`。
/// - 結構化顯示多種飲品屬性（價格、咖啡因、卡路里、糖含量）。
/// - 透過堆疊視圖與自訂元件（如 `DrinkDetailTitleAndValueStackView`）實現資訊排列，增強視覺可讀性與邏輯結構化。
class DrinkPriceInfoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Reuse Identifier

    /// Cell 的重用識別碼
    static let reuseIdentifier = "DrinkPriceInfoCollectionViewCell"
    
    // MARK: - UI Elements
    
    /// 價格的標籤與數值
    private let priceLabel = DrinkDetailLabel(font: .systemFont(ofSize: 16))
    private let priceValueLabel = DrinkDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    
    /// 咖啡因的標籤與數值
    private let caffeineLabel = DrinkDetailLabel(font: UIFont.systemFont(ofSize: 16))
    private let caffeineValueLabel = DrinkDetailLabel(font: UIFont.systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    
    /// 卡路里的標籤與數值
    private let caloriesLabel = DrinkDetailLabel(font: UIFont.systemFont(ofSize: 16))
    private let caloriesValueLabel = DrinkDetailLabel(font: UIFont.systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    
    /// 糖含量的標籤與數值
    private let sugarLabel = DrinkDetailLabel(font: UIFont.systemFont(ofSize: 16))
    private let sugarValueLabel = DrinkDetailLabel(font: UIFont.systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    
    /// 主堆疊視圖，用於排列多個屬性
    private let mainStackView = DrinkDetailStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fillEqually)
    
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
        mainStackView.addArrangedSubview(DrinkDetailTitleAndValueStackView(titleLabel: priceLabel, valueLabel: priceValueLabel))
        mainStackView.addArrangedSubview(DrinkDetailTitleAndValueStackView(titleLabel: caffeineLabel, valueLabel: caffeineValueLabel))
        mainStackView.addArrangedSubview(DrinkDetailTitleAndValueStackView(titleLabel: caloriesLabel, valueLabel: caloriesValueLabel))
        mainStackView.addArrangedSubview(DrinkDetailTitleAndValueStackView(titleLabel: sugarLabel, valueLabel: sugarValueLabel))
        
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


