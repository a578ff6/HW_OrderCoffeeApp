//
//  ForgotPasswordFilledButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/2.
//

import UIKit

/// 自訂的帶填充色的按鈕，適用於忘記密碼頁面中具有主要行為（例如「重置密碼」）的按鈕
class ForgotPasswordFilledButton: UIButton {

    // MARK: - Initializers
    
    /// 初始化 ForgotPasswordFilledButton
    /// - Parameters:
    ///   - title: 按鈕的標題文字
    ///   - textFont: 標題文字的字體
    ///   - textColor: 標題文字的顏色
    ///   - backgroundColor: 按鈕的背景顏色
    ///   - symbolName: SF Symbol 的名稱，可選
    init(title: String, textFont: UIFont, textColor: UIColor, backgroundColor: UIColor, symbolName: String? = nil) {
        super.init(frame: .zero)
        setupButton(title: title, textFont: textFont, textColor: textColor, backgroundColor: backgroundColor, symbolName: symbolName)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置按鈕的外觀和屬性
    /// - Parameters:
    ///   - title: 按鈕的標題文字
    ///   - textFont: 標題文字的字體
    ///   - textColor: 標題文字的顏色
    ///   - backgroundColor: 按鈕的背景顏色
    ///   - symbolName: SF Symbol 的名稱，可選
    private func setupButton(title: String, textFont: UIFont, textColor: UIColor, backgroundColor: UIColor, symbolName: String?) {
        configureBaseAppearance(title: title, textFont: textFont, textColor: textColor, backgroundColor: backgroundColor)
        
        if let symbolName = symbolName, let symbolImage = UIImage(systemName: symbolName) {
            configureSymbolImage(image: symbolImage)
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 配置按鈕的基本外觀
    private func configureBaseAppearance(title: String, textFont: UIFont, textColor: UIColor, backgroundColor: UIColor) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = textColor
        config.baseBackgroundColor = backgroundColor
        config.cornerStyle = .medium
        
        // 設置標題字體
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var updated = incoming
            updated.font = textFont
            return updated
        }
        
        self.configuration = config
    }
    
    /// 配置按鈕的 SF Symbol 圖標
    private func configureSymbolImage(image: UIImage) {
        self.configuration?.image = image
        self.configuration?.imagePlacement = .leading
        self.configuration?.imagePadding = 8.0
    }
   
}
