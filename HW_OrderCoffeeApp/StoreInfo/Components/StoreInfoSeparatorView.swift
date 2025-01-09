//
//  StoreInfoSeparatorView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/7.
//

import UIKit

/// 用於展示分隔線的視圖
///
/// 此視圖用於提供視覺上的分隔效果，適合在列表、區塊間或其他需要分隔的 UI 元素中使用。
///
/// - 支援以下功能:
///   - 自定義分隔線的高度與顏色。
///   - 預設高度為 1，顏色為 `.lightWhiteGray`。
class StoreInfoSeparatorView: UIView {
    
    // MARK: - Initializer
    
    /// 初始化分隔線視圖
    ///
    /// - Parameters:
    ///   - height: 分隔線的高度，默認為 1。
    ///   - color: 分隔線的顏色，默認為 `lightWhiteGray`。
    init(height: CGFloat = 1, color: UIColor = .lightWhiteGray) {
        super.init(frame: .zero)
        setupView(height: height, color: color)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置分隔線的外觀
    ///
    /// - Parameters:
    ///   - height: 分隔線的高度
    ///   - color: 分隔線的顏色
    private func setupView(height: CGFloat, color: UIColor) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = color
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
}
