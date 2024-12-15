//
//  FavoriteDrinkCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//


// MARK: -  筆記：FavoriteDrinkCell 的設計分析
/**
 
 ## 筆記：FavoriteDrinkCell 的設計分析
 
` * What`
 
 - FavoriteDrinkCell 是一個自訂義的 UICollectionViewCell，專門用於「我的最愛」頁面，顯示單一飲品的相關資訊，包括圖片、名稱和副標題。

 ----------------
 
 `* Why`
 
 `1.單一責任原則`

 - 每個 UICollectionViewCell 負責顯示單一的資料項（飲品），設計清晰，職責明確。
 
 `2.模組化與可重用性`

 - 使用 `FavoritesImageView`、`FavoritesLabel` 和 `FavoritesStackView` 統一配置視圖樣式，減少重複代碼，提升模組化。
 
` 3.支持重用與性能優化`

 - 配置 prepareForReuse 方法清除舊數據，避免重用時出現內容錯誤。
 
 ----------------

 `* How`
 
 `1.外觀設置`

 - 通過 `setupCellAppearance` 方法集中管理 `cornerRadius` 和背景色，統一樣式設置。
 
 `2.視圖佈局`

 - 使用 Auto Layout 定義圖片視圖和名稱堆疊視圖的位置與大小，確保在各種螢幕尺寸下顯示一致。
 
 `3.數據配置`

 - 提供` configure(with:) `方法動態設置飲品數據，與業務邏輯解耦，保持靈活性。
 
 `4.重用邏輯`

 - 在 prepareForReuse 中清除圖片和文字，確保重用時顯示正確內容。
 
 ----------------

 `* 總結`
 
 `1.適合的使用場景`

 - 適用於展示單一物件的 `UICollectionViewCell`，特別是需要重複顯示並支持動態數據的情境。
 
 `2.改進空間`

 - 若需要更複雜的交互（例如長按菜單），可透過 `UICollectionViewDelegate` 方法進一步擴展。
 */


import UIKit

/// `FavoriteDrinkCell` 是一個自訂義的 `UICollectionViewCell`，用於顯示「我的最愛」頁面中的飲品資訊。
/// - 功能：
///   1. 顯示飲品的圖片、名稱、副標題。
///   2. 支援動態配置飲品資訊，並在重用時自動清除先前的數據。
/// - 組件：
///   - `drinkImageView`: 飲品圖片視圖。
///   - `nameLabel`: 飲品名稱標籤。
///   - `subNameLabel`: 飲品副標題標籤。
///   - `nameAndsubNameStackView`: 用於垂直堆疊名稱和副標題的 `UIStackView`。
class FavoriteDrinkCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FavoriteDrinkCell"
    
    // MARK: - UI Elements
    
    /// 飲品圖片視圖，顯示飲品的圖片
    private let drinkImageView = FavoritesImageView(contentMode: .scaleAspectFill, cornerRadius: 15)
    
    /// 飲品名稱標籤，顯示飲品的主標題
    private let nameLabel = FavoritesLabel(font: .systemFont(ofSize: 16, weight: .bold), textColor: .deepBrown, adjustsFontSizeToFitWidth: true, numberOfLines: 1, minimumScaleFactor: 0.7)
    
    /// 飲品副標題標籤，顯示飲品的副標題
    private let subNameLabel = FavoritesLabel(font: .systemFont(ofSize: 14), textColor: .gray, adjustsFontSizeToFitWidth: true, numberOfLines: 0, minimumScaleFactor: 0.7)
    
    /// 名稱與副名稱的垂直堆疊視圖，統一管理標籤的布局
    private let nameAndsubNameStackView = FavoritesStackView(axis: .vertical, spacing: 4, alignment: .leading, distribution: .fill)
    
    // MARK: - Initializers

    /// 初始化方法，配置 Cell 的基本樣式和布局
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置 Cell 外觀，包括圓角和背景色
    private func setupCellAppearance() {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.contentView.backgroundColor = .lightWhiteGray
    }

    /// 配置 Cell 的視圖佈局，包括圖片和名稱的排列
    private func setupViews() {

        // 將標籤加入堆疊視圖
        nameAndsubNameStackView.addArrangedSubview(nameLabel)
        nameAndsubNameStackView.addArrangedSubview(subNameLabel)
        
        // 加入主要視圖
        contentView.addSubview(drinkImageView)
        contentView.addSubview(nameAndsubNameStackView)
        
        NSLayoutConstraint.activate([
            // 圖片視圖的約束
            drinkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            drinkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            drinkImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 70),
            drinkImageView.heightAnchor.constraint(equalTo: drinkImageView.widthAnchor),

            // 堆疊視圖的約束
            nameAndsubNameStackView.centerYAnchor.constraint(equalTo: drinkImageView.centerYAnchor),
            nameAndsubNameStackView.leadingAnchor.constraint(equalTo: drinkImageView.trailingAnchor, constant: 20),
            nameAndsubNameStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            nameAndsubNameStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configure Method

    /// 配置 Cell 的內容，包括飲品的圖片、名稱與副標題
    /// - Parameter drink: 包含飲品資訊的模型
    func configure(with favoriteDrink: FavoriteDrink) {
        drinkImageView.kf.setImage(with: favoriteDrink.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        nameLabel.text = favoriteDrink.name
        subNameLabel.text = favoriteDrink.subName
    }
    
    // MARK: - Lifecycle Methods

    // 清空圖像與文字
    override func prepareForReuse() {
        super.prepareForReuse()
        drinkImageView.image = nil
        nameLabel.text = nil
        subNameLabel.text = nil
    }
    
}
