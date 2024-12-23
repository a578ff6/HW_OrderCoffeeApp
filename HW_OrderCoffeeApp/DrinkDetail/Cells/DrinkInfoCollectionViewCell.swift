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



// MARK: -  筆記 DrinkInfoCollectionViewCell
/**
 
 ## 筆記 DrinkInfoCollectionViewCell
 
 `* What`
 
 - `DrinkInfoCollectionViewCell` 是一個用於顯示飲品資訊的 `UICollectionViewCell`，包括：

 1.飲品名稱
 2.飲品副標題
 3.飲品描述文字
 
 --------------------
 
 `* Why`
 
 1.`資訊展示`： 提供清楚的飲品資訊，讓使用者快速理解產品特點。
 2.`視覺統一`： 使用 DrinkDetailStackView 和自訂標籤 DrinkDetailLabel，保持 UI 元件一致性。
 3.`重用性`： 實現 prepareForReuse 方法，避免重用時出現內容混亂。
 
 --------------------

 `* How`
 
 `1.視圖組織：`

 - 使用 `DrinkDetailStackView` 作為主要容器，將名稱、副標題和描述以垂直排列，清楚顯示資訊。
 - 使用 Auto Layout 設定堆疊視圖，確保其佔據 Cell 的安全區域。
 
 `2.功能實現：`

 - 提供` configure(with:) `方法，根據傳入的 Drink 物件設置標籤的文字內容。
 - 在 `prepareForReuse` 方法中重置標籤內容，確保 Cell 被重用時不會出現舊內容。

 */


// MARK: - (v)

import UIKit
import Kingfisher

/// `DrinkInfoCollectionViewCell`
///
/// 用於展示飲品名稱、副標題及描述的自訂 `UICollectionViewCell`。
/// - 此 Cell 使用垂直堆疊視圖（`DrinkDetailStackView`）排列多個標籤，確保資訊清晰展示。
class DrinkInfoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Reuse Identifier

    /// Cell 的重用識別碼
    static let reuseIdentifier = "DrinkInfoCollectionViewCell"
    
    // MARK: - UI Elements
    
    /// 飲品名稱
    private let nameLabel = DrinkDetailLabel(font: .boldSystemFont(ofSize: 24))
    
    /// 飲品副標題
    private let subNameLabel = DrinkDetailLabel(font: .systemFont(ofSize: 18), textColor: .gray)
    
    /// 飲品描述
    private let descriptionLabel = DrinkDetailLabel(font: .systemFont(ofSize: 16), numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    /// 垂直堆疊視圖，用於排列標籤
    private let labelStackView = DrinkDetailStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)

    // MARK: - Initializers

    /// 初始化 Cell，配置視圖與約束
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 配置視圖，將標籤添加至堆疊視圖
    private func setupViews() {
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(subNameLabel)
        labelStackView.addArrangedSubview(descriptionLabel)
        
        contentView.addSubview(labelStackView)
        
        // 設置 StackView 的約束，讓其佔據整個 cell
        NSLayoutConstraint.activate([
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure Method

    /// 配置 Cell 的內容
    /// - Parameter drinkDetailModel: 包含飲品名稱、副標題及描述的 `DrinkDetailModel` 物件
    func configure(with drinkDetailModel: DrinkDetailModel) {
        nameLabel.text = drinkDetailModel.name
        subNameLabel.text = drinkDetailModel.subName
        descriptionLabel.text = drinkDetailModel.description
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
