//
//  EditProfileButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/6.
//


import UIKit

/// 用於編輯個人資料的自訂按鈕，提供統一的樣式
class EditProfileButton: UIButton {

    // MARK: - Initializer
    
    /// 初始化方法
    /// - Parameters:
    ///   - imageName: 按鈕的圖片名稱
    ///   - tintColor: 按鈕的圖片顏色
    ///   - backgroundColor: 按鈕的背景顏色
    init(imageName: String, tintColor: UIColor, backgroundColor: UIColor) {
        super.init(frame: .zero)
        setupButton(imageName: imageName, tintColor: tintColor, backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置按鈕的屬性
    /// - Parameters:
    ///   - imageName: 按鈕的圖片名稱
    ///   - tintColor: 按鈕的圖片顏色
    ///   - backgroundColor: 按鈕的背景顏色
    private func setupButton(imageName: String, tintColor: UIColor, backgroundColor: UIColor) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: imageName, withConfiguration: configuration)
        
        self.setImage(image, for: .normal)
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
