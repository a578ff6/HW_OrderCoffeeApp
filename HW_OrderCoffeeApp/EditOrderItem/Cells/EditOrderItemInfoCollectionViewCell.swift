//
//  EditOrderItemInfoCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// `EditOrderItemInfoCollectionViewCell`
///
/// 用於展示飲品名稱、副標題及描述的自訂 `UICollectionViewCell`。
/// - 此 Cell 使用垂直堆疊視圖（`EditOrderItemStackView`）排列多個標籤，確保資訊清晰展示。
class EditOrderItemInfoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Reuse Identifier

    /// Cell 的重用識別碼
    static let reuseIdentifier = "EditOrderItemInfoCollectionViewCell"

    // MARK: - UI Elements

    /// 飲品名稱
    private let nameLabel = EditOrderItemLabel(font: .boldSystemFont(ofSize: 24))
    
    /// 飲品副標題
    private let subNameLabel = EditOrderItemLabel(font: .systemFont(ofSize: 18), textColor: .gray)
    
    /// 飲品描述
    private let descriptionLabel = EditOrderItemLabel(font: .systemFont(ofSize: 16), numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    /// 垂直堆疊視圖，用於排列標籤
    private let labelStackView = EditOrderItemStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)
    
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
    /// - Parameter editOrderItemModel: 包含飲品名稱、副標題及描述的 `EditOrderItemModel` 物件
    func configure(with editOrderItemModel: EditOrderItemModel) {
        nameLabel.text = editOrderItemModel.drinkName
        subNameLabel.text = editOrderItemModel.drinkSubName
        descriptionLabel.text = editOrderItemModel.description
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
