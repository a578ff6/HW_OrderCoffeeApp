//
//  UserProfileLabel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/9.
//

import UIKit

/// 通用的用戶標籤
class UserProfileLabel: UILabel {
    
    // MARK: - Initializer
    
    /// 初始化方法
    /// - Parameters:
    ///   - font: 字體
    ///   - textColor: 字體顏色
    ///   - numberOfLines: 行數，默認為 1
    ///   - adjustsFontSizeToFitWidth: 是否調整字體大小以適應寬度，默認為 true
    ///   - minimumScaleFactor: 字體縮放的最小比例，默認為 0.5
    ///   - lineBreakMode: 行尾截斷方式，默認為 `.byTruncatingTail`
    ///   - textAlignment: 文字對齊方式，默認為 `.natural`
    ///   - text: 默認顯示的文字，例如 "Loading..."
    init(font: UIFont, textColor: UIColor, numberOfLines: Int = 1, adjustsFontSizeToFitWidth: Bool = true, minimumScaleFactor: CGFloat = 0.5, lineBreakMode: NSLineBreakMode = .byTruncatingTail, textAlignment: NSTextAlignment = .natural, text: String? = nil) {
        super.init(frame: .zero)
        setupLabel(font: font, textColor: textColor, numberOfLines: numberOfLines, adjustsFontSizeToFitWidth: adjustsFontSizeToFitWidth, minimumScaleFactor: minimumScaleFactor, lineBreakMode: lineBreakMode, textAlignment: textAlignment, text: text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Setup Method
    
    /// 設置標籤的屬性
    /// - Parameters:
    ///   - font: 字體
    ///   - textColor: 字體顏色
    ///   - numberOfLines: 行數
    ///   - adjustsFontSizeToFitWidth: 是否調整字體大小以適應寬度
    ///   - minimumScaleFactor: 字體縮放的最小比例
    ///   - lineBreakMode: 行尾截斷方式
    ///   - textAlignment: 文字對齊方式
    ///   - text: 默認顯示的文字
    private func setupLabel(font: UIFont, textColor: UIColor, numberOfLines: Int, adjustsFontSizeToFitWidth: Bool, minimumScaleFactor: CGFloat, lineBreakMode: NSLineBreakMode,                            textAlignment: NSTextAlignment, text: String?) {
        self.font = font
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.minimumScaleFactor = minimumScaleFactor
        self.lineBreakMode = lineBreakMode
        self.textAlignment = textAlignment
        self.text = text
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
