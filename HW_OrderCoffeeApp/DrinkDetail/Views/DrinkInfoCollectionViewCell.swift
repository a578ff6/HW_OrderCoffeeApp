//
//  DrinkInfoCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/12.
//

/*
 1. 佈局的更改：
        - 先前將imageView、nameLabel、subNameLabel、descriptionLabel放在同一個StakcView中，導致約束衝突。
 
 2. 防止重覆利用的 cell 顯示之前的照片：
        - https://reurl.cc/qvvlR3
 
 --------------------------------------------------------------------------------------------------------------
 
 ## DrinkInfoCollectionViewCell：
 
    * 功能： DrinkInfoCollectionViewCell 用來顯示飲品的圖片、名稱、副標題以及簡介，透過 Kingfisher 來處理圖片載入。
 
    * UI 設計：
        - 使用 UILabel 來顯示飲品名稱、副標題和描述，且文字自動縮放和換行。
        - 使用 UIStackView 組織標籤的佈局。
 
    * 使用的自定義方法：
        - createLabel()： 用來生成標籤元件，能指定字體大小、顏色、是否加粗等屬性。
        - createStackView()： 用來生成垂直排列的 StackView，方便管理多個標籤的佈局。
    
    * 配置方法：
        - configure(with:)： 用來設置 cell 顯示的內容，包括名稱、副標題及描述。
        - prepareForReuse()： 在 cell 重用時，重置內容以避免顯示錯誤的資料。
 */


import UIKit
import Kingfisher

/// 展示飲品名稱、副標題以及描述的 CollectionView Cell
class DrinkInfoCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DrinkInfoCollectionViewCell"
    
    // MARK: - UI Elements
    
    let nameLabel = createLabel(fontSize: 24, isBold: true)
    let subNameLabel = createLabel(fontSize: 18, textColor: .gray)
    let descriptionLabel = createLabel(fontSize: 16, numberOfLines: 0)
    let labelStackView = createStackView(axis: .vertical, spacing: 8)

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

    private func setupViews() {
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(subNameLabel)
        labelStackView.addArrangedSubview(descriptionLabel)
        
        contentView.addSubview(labelStackView)
    }
    
    private func setupConstraints() {
        // 設置 StackView 的約束，讓其佔據整個 cell
        NSLayoutConstraint.activate([
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Factory Methods

    /// 設置 Label
    private static func createLabel(fontSize: CGFloat, textColor: UIColor = .black, isBold: Bool = false, numberOfLines: Int = 1) -> UILabel {
        let label = UILabel()
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.setContentHuggingPriority(.required, for: .vertical)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// 設置 StackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Configure Method

    /// 配置 cell 顯示的內容
    /// - Parameter drink: 要顯示的 `Drink` 物件
    func configure(with drink: Drink) {
        nameLabel.text = drink.name
        subNameLabel.text = drink.subName
        descriptionLabel.text = drink.description
    }
    
    // MARK: - Lifecycle Methods

    /// 當 cell 被重用時，重置內容
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        subNameLabel.text = nil
        descriptionLabel.text = nil
    }
    
}
