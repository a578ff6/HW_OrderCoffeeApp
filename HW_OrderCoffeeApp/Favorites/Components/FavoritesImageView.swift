//
//  FavoritesImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/13.
//

// MARK: - (v)

import UIKit

/// 自訂義的 UIImageView，用於「我的最愛」頁面
class FavoritesImageView: UIImageView {

    // MARK: - Initializer

    /// 初始化方法，設置圖片視圖的樣式
    /// - Parameters:
    ///   - contentMode: 圖片顯示模式
    ///   - cornerRadius: 圓角大小
    init(contentMode: UIView.ContentMode, cornerRadius: CGFloat) {
        super.init(frame: .zero)
        setupStyle(contentMode: contentMode, cornerRadius: cornerRadius)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置圖片視圖的基本樣式
    /// - Parameters:
    ///   - contentMode: 圖片顯示模式
    ///   - cornerRadius: 圓角大小
    private func setupStyle(contentMode: UIView.ContentMode, cornerRadius: CGFloat) {
        self.contentMode = contentMode
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
