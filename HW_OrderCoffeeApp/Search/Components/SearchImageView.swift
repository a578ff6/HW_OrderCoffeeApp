//
//  SearchImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/21.
//

import UIKit

/// 自訂的圖片視圖
///
/// `SearchImageView` 是一個擴展的 `UIImageView`，提供預設的樣式配置，
/// 包括邊框、圓角以及圖片顯示模式，適合在訂單確認頁面中使用。
class SearchImageView: UIImageView {

    
    // MARK: - Initializer
    
    /// 初始化自訂的圖片視圖
    /// - Parameters:
    ///   - contentMode: 圖片的顯示模式，預設為 `.scaleAspectFit`
    ///   - borderWidth: 邊框寬度，預設為 `2.0`
    ///   - borderColor: 邊框顏色，預設為深棕色
    ///   - cornerRadius: 圓角半徑，預設為 `15.0`
    ///   - size: 視圖的寬高
    init(
        contentMode: UIView.ContentMode = .scaleAspectFit,
        borderWidth: CGFloat = 2.0,
        borderColor: UIColor = .deepBrown,
        cornerRadius: CGFloat = 15.0,
        size: CGFloat
    ) {
        super.init(frame: .zero)
        setupImageView(
            contentMode: contentMode,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            size: size
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置圖片視圖的外觀屬性
    private func setupImageView(
        contentMode: UIView.ContentMode,
        borderWidth: CGFloat,
        borderColor: UIColor,
        cornerRadius: CGFloat,
        size: CGFloat
    ) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = contentMode
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        
        // 設置寬高約束
        self.widthAnchor.constraint(equalToConstant: size).isActive = true
        self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }

}
