//
//  SignUpCheckBoxButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/30.
//

import UIKit

/// 自訂的 CheckBox 按鈕，使用方形圖標來表示選擇或取消選擇狀態
/// - 用於註冊頁面中的「我同意該條款」等選擇功能，提供直觀的可選中圖標和文字
class SignUpCheckBoxButton: UIButton {

    // MARK: - Initializers
    
    /// 初始化 SignUpCheckBoxButton，設置按鈕標題及外觀
    /// - Parameter title: 按鈕的標題文字，用於描述 CheckBox 的選擇項
    init(title: String) {
        super.init(frame: .zero)
        setupButton(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置按鈕的外觀及屬性
    /// - Parameter title: 按鈕的標題文字
    private func setupButton(title: String) {
        // 設定按鈕在不同狀態下的圖標
        setImage(UIImage(systemName: "square"), for: .normal)
        setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        
        // 設定按鈕的標題文字及其樣式
        setTitle(title, for: .normal)
        setTitleColor(.gray, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        // 設置按鈕的圖標和標題位置
        tintColor = .gray
        contentHorizontalAlignment = .leading
        translatesAutoresizingMaskIntoConstraints = false
    }

}
