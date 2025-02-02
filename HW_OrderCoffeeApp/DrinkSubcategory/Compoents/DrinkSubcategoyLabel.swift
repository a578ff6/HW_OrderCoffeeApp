//
//  DrinkSubcategoyLabel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/24.
//


// MARK: - (v)

import UIKit

/// `DrinkSubcategoyLabel` 是一個自訂的 `UILabel`，
/// 專門用於 `DrinkSubcategoy` 中的標籤樣式設定。
///
/// 此類別支援以下功能：
/// - 自訂字體 (`font`) 與文字顏色 (`textColor`)。
/// - 設定行數限制 (`numberOfLines`) 及文字對齊方式 (`textAlignment`)。
/// - 自動縮放文字以適應視圖大小，並可透過 `scaleFactor` 設定最小縮放比例。
class DrinkSubcategoyLabel: UILabel {

    // MARK: - Initializer
    
    /// 初始化 `DrinkSubcategoyLabel`
    /// - Parameters:
    ///   - text: 標籤的初始文字內容，預設為 `nil`。
    ///   - font: 字體樣式，預設為 `UIFont.systemFont(ofSize: 14)`。
    ///   - textColor: 文字顏色，預設為 `.black`。
    ///   - numberOfLines: 行數限制，預設為 1。
    ///   - scaleFactor: 縮放因子，用於文字縮小時的最小比例，預設為 1.0。
    ///   - adjustsFontSize: 是否啟用自動縮放以適應視圖大小，預設為 `true`。
    ///   - textAlignment: 文字對齊方式，預設為 `.left`。
    init(
        text: String? = nil,
        font: UIFont = UIFont.systemFont(ofSize: 14),
        textColor: UIColor = .black,
        numberOfLines: Int = 1,
        scaleFactor: CGFloat = 1.0,
        adjustsFontSize: Bool = true,
        textAlignment: NSTextAlignment = .left
    ) {
        super.init(frame: .zero)
        setupLabel(text: text, font: font, textColor: textColor, numberOfLines: numberOfLines, scaleFactor: scaleFactor, adjustsFontSize: adjustsFontSize, textAlignment: textAlignment)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置標籤屬性
    /// - Parameters:
    ///   - text: 初始文字內容。
    ///   - font: 字體樣式。
    ///   - textColor: 文字顏色。
    ///   - numberOfLines: 行數限制。
    ///   - scaleFactor: 縮放因子，用於文字縮小時的最小比例。
    ///   - adjustsFontSize: 是否啟用自動縮放以適應視圖大小。
    ///   - textAlignment: 文字對齊方式。
    private func setupLabel(
        text: String?,
        font: UIFont,
        textColor: UIColor,
        numberOfLines: Int,
        scaleFactor: CGFloat,
        adjustsFontSize: Bool,
        textAlignment: NSTextAlignment
    ) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        self.font = font
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        self.adjustsFontSizeToFitWidth = adjustsFontSize
        self.minimumScaleFactor = scaleFactor
        self.textAlignment = textAlignment
    }

}
