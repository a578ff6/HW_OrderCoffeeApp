//
//  OrderItemDeleteButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/30.
//

import UIKit

/// `OrderItemDeleteButton` 是一個自訂的刪除按鈕，
/// 用於統一樣式配置，專注於視覺外觀。
class OrderItemDeleteButton: UIButton {

    // MARK: - Initializer

    /// 初始化刪除按鈕
    /// - Parameters:
    ///   - iconSize: 圖標大小，預設為 22
    ///   - iconColor: 圖標顏色，預設為 darkGray
    init(iconSize: CGFloat = 22, iconColor: UIColor = .darkGray) {
        super.init(frame: .zero)
        configureButton(iconSize: iconSize, iconColor: iconColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置刪除按鈕的樣式
    /// - Parameters:
    ///   - iconSize: 圖標大小
    ///   - iconColor: 圖標顏色
    private func configureButton(iconSize: CGFloat, iconColor: UIColor) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "trash.circle.fill")?.withTintColor(iconColor, renderingMode: .alwaysOriginal)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize)
        config.preferredSymbolConfigurationForImage = symbolConfig // 圖標配置
        self.configuration = config
    }
    
}
