//
//  EditOrderItemUpdateButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/25.
//

import UIKit

/// 自訂的`編輯訂單按鈕`，專為 `EditOrderItemOptionsCollectionViewCell` 設計
///
/// 此按鈕採用 `UIButton.Configuration` 來簡化樣式設置，支持背景色、圓角、文字與圖標的動態設定。
/// 適合使用於具有統一樣式需求的按鈕。
class EditOrderItemUpdateButton: UIButton {

    // MARK: - Initializer

    /// 初始化按鈕
    /// - Parameters:
    ///   - title: 按鈕的顯示文字，預設為 "Update Order"
    ///   - image: 按鈕的圖示，預設為編輯圖示
    ///   - cornerRadius: 按鈕的圓角樣式，預設為 `.medium`
    ///   - backgroundColor: 按鈕的背景顏色，預設為深綠色
    init(
        title: String = "Update Order",
        image: UIImage? = UIImage(systemName: "pencil.line"),
        cornerRadius: UIButton.Configuration.CornerStyle = .medium,
        backgroundColor: UIColor = .deepGreen
    ) {
        super.init(frame: .zero)
        setupStyle(title: title, image: image, cornerRadius: cornerRadius, backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 配置按鈕的樣式
    /// - Parameters:
    ///   - title: 按鈕的顯示文字
    ///   - image: 按鈕的圖示
    ///   - cornerRadius: 按鈕的圓角樣式（使用 `UIButton.Configuration.CornerStyle`）
    ///   - backgroundColor: 按鈕的背景顏色
    ///
    /// 此方法透過 `UIButton.Configuration` 配置按鈕的樣式，
    /// 讓按鈕具備圓角與填充顏色，並預設文字或圖標的顏色為白色。
    private func setupStyle(
        title: String,
        image: UIImage?,
        cornerRadius: UIButton.Configuration.CornerStyle,
        backgroundColor: UIColor
    ) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.image = image
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        configuration.cornerStyle = cornerRadius
        configuration.baseBackgroundColor = backgroundColor
        configuration.baseForegroundColor = .white // 文字或圖標的顏色
        self.configuration = configuration
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
