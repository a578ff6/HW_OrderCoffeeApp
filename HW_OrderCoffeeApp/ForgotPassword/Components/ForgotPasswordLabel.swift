//
//  ForgotPasswordLabel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/2.
//

import UIKit

/// 自訂的 UILabel，用於 ForgotPasswordView 頁面中的標準文字樣式
class ForgotPasswordLabel: UILabel {
    
    // MARK: - Initializers
    
    /// 使用特定屬性初始化 ForgotPasswordLabel
    /// - Parameters:
    ///   - text: 標籤顯示的文字
    ///   - fontSize: 文字大小
    ///   - weight: 文字的字重
    ///   - textColor: 文字顏色，默認為黑色
    ///   - textAlignment: 文字對齊方式，默認為自然對齊
    ///   - numberOfLines: 文字的顯示行數，默認為 1
    init(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor = .black, textAlignment: NSTextAlignment = .natural, numberOfLines: Int = 1) {
        super.init(frame: .zero)
        setupLabel(text: text, fontSize: fontSize, weight: weight, textColor: textColor, textAlignment: textAlignment, numberOfLines: numberOfLines)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置標籤的基本屬性
    /// - Parameters:
    ///   - text: 標籤顯示的文字
    ///   - fontSize: 文字大小
    ///   - weight: 文字的字重
    ///   - textColor: 文字顏色
    ///   - textAlignment: 文字對齊方式
    ///   - numberOfLines: 文字的顯示行數
    private func setupLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, textAlignment: NSTextAlignment, numberOfLines: Int) {
        self.text = text
        self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
