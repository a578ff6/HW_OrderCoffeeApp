//
//  OrderConfirmationCheckmarkCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

import UIKit

/// 用於顯示訂單提交成功後「打勾」圖示的 Cell
/// - 此 Cell 主要用於強調操作成功，通常在訂單確認畫面中顯示。
class OrderConfirmationCheckmarkCell: UICollectionViewCell {
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderConfirmationCheckmarkCell"
    
    // MARK: - UI Elements
    
    /// 「打勾」圖示，用於視覺化呈現成功提交訂單的狀態
    private let checkmarkImageView = OrderConfirmationIconImageView(image: UIImage(systemName: "checkmark.circle.fill"), tintColor: .deepGreen, size: 150, symbolWeight: .bold)
    
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
    
    /// 配置 Cell 的內容視圖及佈局
    private func setupView() {
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
}

