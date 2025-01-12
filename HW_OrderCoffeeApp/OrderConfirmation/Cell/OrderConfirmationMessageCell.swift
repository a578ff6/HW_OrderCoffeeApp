//
//  OrderConfirmationMessageCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

import UIKit

/// 用於顯示訂單成功提交提示訊息的 Cell
/// - 此 Cell 主要用於提供文字回饋，告知使用者訂單已成功處理。
class OrderConfirmationMessageCell: UICollectionViewCell {
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderConfirmationMessageCell"
    
    // MARK: - UI Elements
    
    /// 標題標籤，用於顯示主要訊息
    private let titleLabel = OrderConfirmationLabel(text: "Success", font: .systemFont(ofSize: 28, weight: .black), textColor: .black, textAlignment: .center)
    
    /// 副標題標籤，用於顯示補充文字
    private let subtitleLabel = OrderConfirmationLabel(text: "Your order has been successfully submitted", font: .systemFont(ofSize: 16, weight: .medium), textColor: .lightGray, numberOfLines: 0, textAlignment: .center)
    
    /// 包含標題與副標題的垂直排列 StackView
    private let titleAndSubtitleStackView = OrderConfirmationStackView(axis: .vertical, spacing: 15, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置標籤與佈局
    private func setupView() {
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleLabel)
        
        contentView.addSubview(titleAndSubtitleStackView)
        
        NSLayoutConstraint.activate([
            titleAndSubtitleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleAndSubtitleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleAndSubtitleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleAndSubtitleStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
}
