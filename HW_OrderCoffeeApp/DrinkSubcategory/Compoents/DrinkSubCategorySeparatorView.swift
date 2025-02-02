//
//  DrinkSubCategorySeparatorView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/25.
//

import UIKit

/// `DrinkSubCategorySeparatorView` 是一個自訂的分隔線視圖，
///
/// 用於提供統一的分隔線樣式，適用於 DrinkSubCategory 頁面需要分隔線的視圖。
class DrinkSubCategorySeparatorView: UIView {

    // MARK: - Initializer

    /// 初始化分隔線視圖
    /// - Parameters:
    ///   - backgroundColor: 分隔線的背景顏色，預設為 `.lightWhiteGray`。
    ///   - height: 分隔線的高度，預設為 `1.0`。
    init(backgroundColor: UIColor = .lightWhiteGray, height: CGFloat = 1.0) {
        super.init(frame: .zero)
        setupView(backgroundColor: backgroundColor, height: height)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
 
    /// 配置分隔線的外觀與高度
    /// - Parameters:
    ///   - backgroundColor: 分隔線的背景顏色。
    ///   - height: 分隔線的高度。
    private func setupView(backgroundColor: UIColor, height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

}
