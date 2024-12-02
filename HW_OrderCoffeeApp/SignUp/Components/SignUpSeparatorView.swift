//
//  SignUpSeparatorView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/30.
//

import UIKit

/// 自訂的分隔線視圖，包含兩條橫線和中間的一個標籤，用於登入頁面中以視覺方式分隔不同部分
class SignUpSeparatorView: UIView {

    // MARK: - Initializers
    
    /// 初始化 SignUpSeparatorView
    /// - Parameters:
    ///   - text: 分隔線中間顯示的文字
    ///   - textColor: 標籤文字的顏色，默認為淺灰色
    ///   - lineColor: 分隔線的顏色，默認為淺灰色
    init(text: String, textColor: UIColor = .lightGray, lineColor: UIColor = .lightGray) {
        super.init(frame: .zero)
        setupSeparatorView(text: text, textColor: textColor, lineColor: lineColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
        
    /// 設置分隔線視圖的基本屬性
    /// - Parameters:
    ///   - text: 分隔線中間顯示的文字
    ///   - textColor: 標籤文字的顏色
    ///   - lineColor: 分隔線的顏色
    private func setupSeparatorView(text: String, textColor: UIColor, lineColor: UIColor) {
        translatesAutoresizingMaskIntoConstraints = false
        
        // 創建分隔符專用的 StackView
        let separatorStackView = createStackView(axis: .horizontal, spacing: 3, alignment: .center, distribution: .fill)
        
        // 創建兩條分隔線和中間的標籤
        let line1 = createLineView(color: lineColor)
        let line2 = createLineView(color: lineColor)
        let textLabel = createLabel(text: text, fontSize: 14, weight: .regular, textColor: textColor, textAlignment: .center)
        
        // 添加子視圖到 StackView 中
        separatorStackView.addArrangedSubview(line1)
        separatorStackView.addArrangedSubview(textLabel)
        separatorStackView.addArrangedSubview(line2)
        
        // 添加 StackView 到主視圖
        addSubview(separatorStackView)
        
        // 設置 StackView 的約束
        NSLayoutConstraint.activate([
            separatorStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Private Factory Methods

    /// 創建一個 StackView
    /// - Parameters:
    ///   - axis: 排列方向（水平或垂直）
    ///   - spacing: 元素之間的間距
    ///   - alignment: 元素的對齊方式
    ///   - distribution: 元素的分佈方式
    /// - Returns: 配置好的 UIStackView
    private func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// 創建一條分隔線
    /// - Parameter color: 分隔線的顏色
    /// - Returns: 配置好的 UIView，表示一條分隔線
    private func createLineView(color: UIColor) -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: 95).isActive = true
        return lineView
    }
    
    /// 創建一個標籤
    /// - Parameters:
    ///   - text: 標籤顯示的文字
    ///   - fontSize: 文字大小
    ///   - weight: 文字的字重
    ///   - textColor: 文字顏色
    ///   - textAlignment: 文字對齊方式
    /// - Returns: 配置好的 UILabel
    private func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

}
