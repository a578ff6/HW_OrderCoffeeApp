//
//  DrinkPriceInfoCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/16.
//

/*
 1. DottedLineView：
        - 自定義 DottedLineView 繪製一條虛線。
 
 2. 建立LabelStackView：
        - createLabelStackView 方法
            - 建立一個水平 UIStackView，其中包含資訊Label、虛線視圖、數值Label。
            - 資訊Label與數值Label設置了 ContentHuggingPriority，確保他們根據內容自動調整寬度，
            - 而中間的 DottedLineView 繪製動調整以填充剩下的空間。
 
 3. 配置單元格：
        - configure 方法
            - 將尺寸資訊傳遞給相對應的Label
 
 4. 將 titleLabel、dottedLineView 和 valueLabel 直接添加到同一個 UIStackView 中，並通過 spacing 設置他們之間的間距。避免衝突
 */


import UIKit

/// 展示飲品價格、營養資訊的 CollectionViewCell
class DrinkPriceInfoCollectionViewCell: UICollectionViewCell {
 
    static let reuseIdentifier = "DrinkPriceInfoCollectionViewCell"
    
    let priceLabel = UILabel()
    let priceValueLabel = UILabel()
    let caffeineLabel = UILabel()
    let caffeineValueLabel = UILabel()
    let caloriesLabel = UILabel()
    let caloriesValueLabel = UILabel()
    let sugarLabel = UILabel()
    let sugarValueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 配置cell顯示的內容
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
    
    /// 設置視圖
    private func setupViews() {
        let priceStackView = createLabelStackView(titleLabel: priceLabel, valueLabel: priceValueLabel)
        let caffeineStackView = createLabelStackView(titleLabel: caffeineLabel, valueLabel: caffeineValueLabel)
        let caloriesStackView = createLabelStackView(titleLabel: caloriesLabel, valueLabel: caloriesValueLabel)
        let sugarStackView = createLabelStackView(titleLabel: sugarLabel, valueLabel: sugarValueLabel)
        
        let stackView = UIStackView(arrangedSubviews: [priceStackView, caffeineStackView, caloriesStackView, sugarStackView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// 設置約束
    private func setupConstraints() {
        guard let stackView = contentView.subviews.first as? UIStackView else { return }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    /// 創建 Label StackView
    private func createLabelStackView(titleLabel: UILabel, valueLabel: UILabel) -> UIStackView {
        let dottedLineView = DottedLineView()
        dottedLineView.translatesAutoresizingMaskIntoConstraints = false
        dottedLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dottedLineView, valueLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 6
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        return stackView
    }
    
}


