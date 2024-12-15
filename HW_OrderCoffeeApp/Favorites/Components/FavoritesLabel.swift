//
//  FavoritesLabel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/13.
//

// MARK: - (v)

import UIKit

/// 自訂義的 UILabel，用於「我的最愛」頁面的標題顯示
class FavoritesLabel: UILabel {
    
    // MARK: - Initializer
    
    /// 初始化方法，設置標籤樣式
    /// - Parameters:
    ///   - text: 預設顯示的文字，預設為 `nil`
    ///   - font: 字型樣式
    ///   - textColor: 文字顏色
    ///   - adjustsFontSizeToFitWidth: 是否自動調整字型大小以適應標籤寬度，預設為 `true`
    ///   - numberOfLines: 標籤的行數，預設為 `1`
    ///   - minimumScaleFactor: 字型縮放的最小比例，預設為 `0.7`
    ///   - alignment: 文字對齊方式，預設為 `.natural`
    init(text: String? = nil, font: UIFont, textColor: UIColor, adjustsFontSizeToFitWidth: Bool = true, numberOfLines: Int = 1, minimumScaleFactor: CGFloat = 0.7, alignment: NSTextAlignment = .natural) {
        super.init(frame: .zero)
        setupStyle(text: text, font: font, textColor: textColor, adjustsFontSizeToFitWidth: adjustsFontSizeToFitWidth, numberOfLines: numberOfLines, minimumScaleFactor: minimumScaleFactor, alignment: alignment)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置標籤的基本樣式
    /// - Parameters:
    ///   - text: 預設顯示的文字
    ///   - font: 字型樣式
    ///   - textColor: 文字顏色
    ///   - adjustsFontSizeToFitWidth: 是否自動調整字型大小以適應標籤寬度
    ///   - numberOfLines: 標籤的行數
    ///   - minimumScaleFactor: 字型縮放的最小比例
    ///   - alignment: 文字對齊方式
    private func setupStyle(text: String? = nil, font: UIFont, textColor: UIColor, adjustsFontSizeToFitWidth: Bool, numberOfLines: Int, minimumScaleFactor: CGFloat, alignment: NSTextAlignment) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.numberOfLines = numberOfLines
        self.minimumScaleFactor = minimumScaleFactor
        self.textAlignment = alignment // 設置文字對齊方式
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
