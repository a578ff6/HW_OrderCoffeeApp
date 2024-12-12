//
//  UserProfileImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/9.
//

import UIKit

/// 通用的用戶大頭照視圖
class UserProfileImageView: UIImageView {
    
    // MARK: - Initializer
    
    /// 初始化用戶頭像視圖
    /// - Parameters:
    ///   - defaultImage: 預設圖片（支持 SF Symbol 或普通圖片）
    ///   - cornerRadius: 圓角半徑，默認為 0
    ///   - backgroundColor: 背景顏色，默認為 .clear
    ///   - contentMode: 顯示模式，默認為 .scaleAspectFill
    init(defaultImage: UIImage? = nil, cornerRadius: CGFloat = 0, backgroundColor: UIColor = .clear, contentMode: UIView.ContentMode = .scaleAspectFill) {
        super.init(frame: .zero)
        configureAppearance(defaultImage: defaultImage, cornerRadius: cornerRadius, backgroundColor: backgroundColor, contentMode: contentMode)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Setup Method
    
    /// 設置基本屬性
    /// - Parameters:
    ///   - defaultImage: 預設圖片
    ///   - cornerRadius: 圓角半徑
    ///   - backgroundColor: 背景顏色
    ///   - contentMode: 顯示模式
    private func configureAppearance(defaultImage: UIImage?, cornerRadius: CGFloat, backgroundColor: UIColor, contentMode: UIView.ContentMode) {
        translatesAutoresizingMaskIntoConstraints = false
        self.image = defaultImage
        self.contentMode = contentMode
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.backgroundColor = backgroundColor
    }
}
