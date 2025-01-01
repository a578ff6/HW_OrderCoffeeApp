//
//  OrderItemBottomLineView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/29.
//

import UIKit

/// `OrderItemBottomLineView` 是一個自訂的底部分隔線視圖，
/// 用於統一管理 `OrderItemCollectionViewCell` 或其他視圖中的底部分隔樣式。
class OrderItemBottomLineView: UIView {

    // MARK: - Initializer

    /// 初始化底部分隔線
    /// - Parameter backgroundColor: 分隔線的背景顏色，預設為 `.lightWhiteGray`
    init(backgroundColor: UIColor = .lightWhiteGray) {
        super.init(frame: .zero)
        setupView(backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 配置底部分隔線的屬性
    /// - Parameter backgroundColor: 背景顏色
    private func setupView(backgroundColor: UIColor) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor
    }
}
