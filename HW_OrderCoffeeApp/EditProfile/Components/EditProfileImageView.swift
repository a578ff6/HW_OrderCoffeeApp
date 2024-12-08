//
//  EditProfileImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/6.
//

import UIKit

/// 自訂的編輯個人資料的圖片視圖，用於顯示使用者的大頭照
class EditProfileImageView: UIImageView {
    
    // MARK: - Initializer
    
    /// 初始化方法
    /// - Parameters:
    ///   - sfSymbolName: SF Symbol 圖片名稱
    ///   - contentMode: 顯示模式，默認為 .scaleAspectFill
    ///   - backgroundColor: 背景顏色
    ///   - cornerRadius: 圓角半徑
    ///   - borderWidth: 邊框寬度
    ///   - borderColor: 邊框顏色
    init(sfSymbolName: String, contentMode: UIView.ContentMode, backgroundColor: UIColor, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        super.init(frame: .zero)
        setupImageView(sfSymbolName: sfSymbolName, contentMode: contentMode)
        setupAppearance(backgroundColor: backgroundColor, cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置圖片視圖的圖片和顯示模式
    /// - Parameters:
    ///   - sfSymbolName: SF Symbol 圖片名稱
    ///   - contentMode: 顯示模式
    private func setupImageView(sfSymbolName: String, contentMode: UIView.ContentMode) {
        self.image = UIImage(systemName: sfSymbolName)
        self.contentMode = contentMode
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// 設置圖片視圖的外觀
    /// - Parameters:
    ///   - backgroundColor: 背景顏色
    ///   - cornerRadius: 圓角半徑
    ///   - borderWidth: 邊框寬度
    ///   - borderColor: 邊框顏色
    private func setupAppearance(backgroundColor: UIColor, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
}




