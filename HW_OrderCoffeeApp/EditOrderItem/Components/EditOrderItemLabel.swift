//
//  EditOrderItemLabel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// 自訂義的 UILabel，用於展示飲品相關資訊
class EditOrderItemLabel: UILabel {
    
    // MARK: - Initializer
    
    init(text: String? = nil, font: UIFont, textColor: UIColor = .black, textAlignment: NSTextAlignment = .natural, numberOfLines: Int = 1, adjustsFontSizeToFitWidth: Bool = true, minimumScaleFactor: CGFloat = 0.7, lineBreakMode: NSLineBreakMode = .byTruncatingTail) {
        super.init(frame: .zero)
        setupStyle(text: text, font: font, textColor: textColor, textAlignment: textAlignment, numberOfLines: numberOfLines, adjustsFontSizeToFitWidth: adjustsFontSizeToFitWidth, minimumScaleFactor: minimumScaleFactor, lineBreakMode: lineBreakMode)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置基本樣式
    /// - Parameters:
    ///   - text: 文字內容
    ///   - font: 字型樣式
    ///   - textColor: 文字顏色
    ///   - textAlignment: 文字對齊
    ///   - numberOfLines: 行數
    ///   - adjustsFontSizeToFitWidth: 是否自動調整字型大小
    ///   - minimumScaleFactor: 字型縮放的最小比例
    ///   - lineBreakMode: 行中斷模式
    private func setupStyle(text: String?, font: UIFont, textColor: UIColor, textAlignment: NSTextAlignment, numberOfLines: Int, adjustsFontSizeToFitWidth: Bool, minimumScaleFactor: CGFloat, lineBreakMode: NSLineBreakMode) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.minimumScaleFactor = minimumScaleFactor
        self.lineBreakMode = lineBreakMode
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
