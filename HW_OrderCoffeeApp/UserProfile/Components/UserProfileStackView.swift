//
//  UserProfileStackView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/9.
//

import UIKit

/// 自訂的 `UserProfileStackView` 類別，用於建立畫面中使用的 StackView，統一配置
class UserProfileStackView: UIStackView {
    
    /// 初始化 UserProfileStackView，設置 StackView 的屬性
    /// - Parameters:
    ///   - axis: 堆疊的方向（水平或垂直）
    ///   - spacing: 元件間的間距
    ///   - alignment: 元件在 StackView 中的對齊方式
    ///   - distribution: 元件的分佈方式
    init(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) {
        super.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
