//
//  NoOrderItemViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/12.
//


import UIKit

/// `NoOrderItemViewCell`
/// 當訂單飲品項目為空時，使用此 `UICollectionViewCell` 顯示提示訊息。
///
/// 此元件包含：
/// - 文字訊息：顯示「訂單無項目」的訊息文字。
/// - 購物籃圖示：顯示與訂單相關的圖示，增強視覺效果。
/// - 水平排列的 StackView：整合文字與圖示，簡化佈局。
///
/// 使用情境：
/// 當訂單頁面無任何飲品項目時，顯示此元件以提示用戶。
class NoOrderItemViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "NoOrderItemViewCell"
    
    // MARK: - UI Elements
    
    /// 訂單無項目時顯示的訊息文字
    private let messageLabel = OrderItemLabel(text: "No items in your order", font: .systemFont(ofSize: 18, weight: .semibold), textColor: .lightGray, textAlignment: .center)
    
    /// 顯示購物籃圖示
    private let cartImageView = OrderItemIconImageView(image: UIImage(systemName: "basket"), tintColor: .lightGray, size: 24, symbolWeight: .regular)
    
    /// 整合訊息文字與購物籃圖示的水平 StackView
    private let noOrdersStackView = OrderItemStackView(axis: .horizontal, spacing: 8, alignment: .center, distribution: .fill)
    
    // MARK: - Initializer
    
    /// 初始化 `NoOrderItemViewCell`
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置並初始化視圖的佈局
    private func setupView() {
        
        // 添加訊息與圖示到 StackView
        noOrdersStackView.addArrangedSubview(messageLabel)
        noOrdersStackView.addArrangedSubview(cartImageView)
        
        contentView.addSubview(noOrdersStackView)
        NSLayoutConstraint.activate([
            noOrdersStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noOrdersStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            noOrdersStackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            noOrdersStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
}
