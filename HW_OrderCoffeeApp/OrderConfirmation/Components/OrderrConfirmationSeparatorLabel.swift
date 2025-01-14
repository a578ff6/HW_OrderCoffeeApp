//
//  OrderrConfirmationSeparatorLabel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/10.
//

import UIKit

/// `OrderrConfirmationSeparatorLabel` 是一個專門用於`OrderrConfirmation`顯示分隔符號的 `UILabel`。
///
/// 預設樣式為灰色的 `|` 符號。
class OrderrConfirmationSeparatorLabel: UILabel {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSeparator()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置分隔符號樣式
    private func setupSeparator() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = "|"
        self.font = UIFont.systemFont(ofSize: 14)
        self.textColor = .gray
    }
    
}
