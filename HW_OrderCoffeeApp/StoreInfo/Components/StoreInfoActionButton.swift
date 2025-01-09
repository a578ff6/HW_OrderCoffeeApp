//
//  StoreInfoActionButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/8.
//

import UIKit

/// `StoreInfoActionButton` 是一個自訂的按鈕類別，用於展示標題、圖示及自訂樣式的按鈕。
///
/// 此按鈕支援以下功能：
/// - 使用 `UIButton.Configuration` 配置按鈕樣式。
/// - 提供圖示、文字、背景色及文字顏色的自訂化選項。
/// - 支援設定系統內建的圓角樣式 (`cornerStyle`)，以提升一致性。
///
/// ### 適用情境
/// - 訂單動作按鈕，例如「提交」等操作。
class StoreInfoActionButton: UIButton {

    // MARK: - Initializer

    /// 初始化 `StoreInfoActionButton`
    /// - Parameters:
    ///   - title: 按鈕的文字內容。
    ///   - font: 按鈕文字的字體樣式。
    ///   - backgroundColor: 按鈕的背景色。
    ///   - titleColor: 按鈕文字的顏色。
    ///   - iconName: 圖示名稱，支援 SF Symbols。
    ///   - cornerStyle: 圓角樣式，預設為 `.medium`。
    init(title: String,
         font: UIFont,
         backgroundColor: UIColor,
         titleColor: UIColor,
         iconName: String,
         cornerStyle: UIButton.Configuration.CornerStyle = .medium
    ) {
        super.init(frame: .zero)
        setupButton(title: title, font: font, backgroundColor: backgroundColor, titleColor: titleColor, iconName: iconName, cornerStyle: cornerStyle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置按鈕的外觀與屬性
    /// - Parameters:
    ///   - title: 按鈕的文字內容。
    ///   - font: 按鈕文字的字體樣式。
    ///   - backgroundColor: 按鈕的背景色。
    ///   - titleColor: 按鈕文字的顏色。
    ///   - iconName: 圖示名稱，支援 SF Symbols。
    ///   - cornerStyle: 圓角樣式。
    private func setupButton(
        title: String,
        font: UIFont,
        backgroundColor: UIColor,
        titleColor: UIColor,
        iconName: String,
        cornerStyle: UIButton.Configuration.CornerStyle
    ) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = titleColor
        config.baseBackgroundColor = backgroundColor
        config.image = UIImage(systemName: iconName)
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.cornerStyle = cornerStyle

        var titleAttr = AttributedString(title)
        titleAttr.font = font
        config.attributedTitle = titleAttr
        
        self.configuration = config
    }
    
}
