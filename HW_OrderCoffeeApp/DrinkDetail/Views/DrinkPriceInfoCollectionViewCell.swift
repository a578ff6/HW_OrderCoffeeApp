//
//  DrinkPriceInfoCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/16.
//

/*
 DrinkPriceInfoCollectionViewCell：
 
    - 用途： 這個 cell 用於展示飲品的價格和營養資訊，並且透過 UIStackView 來排列標題和對應的數值，達到清晰的呈現效果。

    * 主要結構：
        - priceLabel、priceValueLabel、caffeineLabel 等： 這些 UILabel 分別用來顯示價格、咖啡因含量、卡路里與糖分，並且透過 createLabel 建立。
        - createMainStackView 和 createLabelStackView： 負責排列所有的 label，並且自動設定佈局，透過 UIStackView 簡化視圖的排列。
 
    * 主要流程：
        - 透過 configure(with:) 方法設定每個 cell 的內容，將 SizeInfo 中的價格、營養資訊對應到各個 UILabel 上。
        - 視圖初始化後，會依序呼叫 setupViews() 添加 UIStackView，並在 setupConstraints() 中設置約束條件來確保視圖的佈局正確。
 */



import UIKit

/// 展示飲品價格、營養資訊的 CollectionViewCell
class DrinkPriceInfoCollectionViewCell: UICollectionViewCell {
 
    static let reuseIdentifier = "DrinkPriceInfoCollectionViewCell"
    
    // MARK: - UI Elements

    let priceLabel = createLabel()
    let priceValueLabel = createLabel(textAlignment: .right)
    let caffeineLabel = createLabel()
    let caffeineValueLabel = createLabel(textAlignment: .right)
    let caloriesLabel = createLabel()
    let caloriesValueLabel = createLabel(textAlignment: .right)
    let sugarLabel = createLabel()
    let sugarValueLabel = createLabel(textAlignment: .right)
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 設置主視圖，將各個營養資訊以 StackView 方式排列
    private func setupViews() {
        let stackView = createMainStackView(with: [
            createLabelStackView(titleLabel: priceLabel, valueLabel: priceValueLabel),
            createLabelStackView(titleLabel: caffeineLabel, valueLabel: caffeineValueLabel),
            createLabelStackView(titleLabel: caloriesLabel, valueLabel: caloriesValueLabel),
            createLabelStackView(titleLabel: sugarLabel, valueLabel: sugarValueLabel)
        ])
        contentView.addSubview(stackView)
    }
    
    /// 設置約束條件，確保 StackView 在 cell 內正確排列
    private func setupConstraints() {
        guard let stackView = contentView.subviews.first as? UIStackView else { return }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Factory Methods
    
    /// 創建主 StackView，用於包含所有營養資訊的 StackView
    private func createMainStackView(with arrangedSubviews: [UIStackView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    /// 創建每個資訊的橫向 StackView，包含標題和對應的數值
    private func createLabelStackView(titleLabel: UILabel, valueLabel: UILabel) -> UIStackView {
        let dottedLineView = DottedLineView()                    // 分隔標題和數值的虛線
        dottedLineView.translatesAutoresizingMaskIntoConstraints = false
        dottedLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dottedLineView, valueLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        return stackView
    }

    /// 創建通用 Label，用於顯示價格、咖啡因、卡路里、糖等資訊
    private static func createLabel(textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = textAlignment
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }
    
    // MARK: - Configure Method

    /// 配置 cell 的顯示內容，包括價格、咖啡因、卡路里與糖分
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

    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置所有顯示的文本，防止數據混亂
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
