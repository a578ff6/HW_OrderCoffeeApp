//
//  OrderItemImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/29.
//

import UIKit

/// `OrderItemImageView` 是一個自訂的 `UIImageView`，專門用於展示飲品圖片。
///
/// 包含靈活的圓角、邊框、內容模式設定，並支援安全的圖片重設邏輯。
class OrderItemImageView: UIImageView {
    
    // MARK: - Initializer
    
    /// 初始化自訂的圖片視圖
    /// - Parameters:
    ///   - contentMode: 圖片的顯示模式，預設為 `.scaleAspectFit`
    ///   - borderWidth: 邊框寬度，預設為 `2.0`
    ///   - borderColor: 邊框顏色，預設為深棕色
    ///   - cornerRadius: 圓角半徑，預設為 `15.0`
    init(contentMode: UIView.ContentMode = .scaleAspectFit,
         borderWidth: CGFloat = 2.0,
         borderColor: UIColor = .deepBrown,
         cornerRadius: CGFloat = 15.0
    ) {
        super.init(frame: .zero)
        setupImageView(
            contentMode: contentMode,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置圖片視圖的外觀屬性
    private func setupImageView(
        contentMode: UIView.ContentMode = .scaleAspectFit,
        borderWidth: CGFloat = 2.0,
        borderColor: UIColor = .deepBrown,
        cornerRadius: CGFloat = 15.0
    ) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = contentMode
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
}
