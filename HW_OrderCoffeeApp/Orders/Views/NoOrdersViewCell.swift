//
//  NoOrdersViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/12.
//

import UIKit

/// 在訂單飲品項目為空的時候，顯示使用NoOrdersViewCell。
class NoOrdersViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NoOrdersViewCell"
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "目前沒有商品在訂單中"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
}
