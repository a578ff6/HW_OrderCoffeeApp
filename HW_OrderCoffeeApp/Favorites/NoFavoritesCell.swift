//
//  NoFavoritesCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/24.
//

import UIKit

/// `NoFavoritesCell` 用來顯示當前沒有收藏飲品時的提示訊息
class NoFavoritesCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NoFavoritesCell"
    
    // MARK: - UI Elements
    
    /// 顯示「目前沒有我的最愛」的提示訊息
    let messageLabel = createLabel(text: "目前沒有我的最愛", fontSize: 18, weight: .bold, textColor: .lightWhiteGray, alignment: .center)
    
    // MARK: - Initializers

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
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Factory Methods

    private static func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: - Lifecycle Methods
    
    /// 當 Cell 被重用時清除內容
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = "目前沒有我的最愛"  // 文字保持預設值
    }
    
}

