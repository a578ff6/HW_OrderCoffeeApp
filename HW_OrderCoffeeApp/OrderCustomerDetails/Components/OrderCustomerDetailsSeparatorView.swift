//
//  OrderCustomerDetailsSeparatorView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/4.
//

import UIKit

/// 用於顯示分隔線的視圖，適用於訂單相關模組的佈局需求
class OrderCustomerDetailsSeparatorView: UIView {
    
    // MARK: - Initializer
    
    init(color: UIColor = .gray) {
        super.init(frame: .zero)
        setupView(color: color)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupView(color: UIColor) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = color
    }
    
}
