//
//  ForgotPasswordTextField.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/2.
//

import UIKit

/// 自訂的 `ForgotPasswordTextField`，繼承自 `BottomLineTextField`
/// - 提供忘記密碼頁面中特定需求的輸入框，當初註冊的信箱欄位。
class ForgotPasswordTextField: BottomLineTextField {

    // MARK: - Initializers
    
    /// 使用自訂的初始化方法來配置 `ForgotPasswordTextField`
    /// - Parameters:
    ///   - placeholder: 文字輸入框的佔位符
    ///   - rightIconName: 右側圖標的名稱，可選
    ///   - isPasswordField: 是否為密碼輸入框（如果是，會配置密碼顯示切換功能）
    ///   - fieldType: 欄位類型，用於設置自動填充功能
    init(placeholder: String, rightIconName: String? = nil, isPasswordField: Bool = false, fieldType: FieldType? = nil) {
        super.init(frame: .zero)
        setupTextField(placeholder: placeholder, rightIconName: rightIconName, isPasswordField: isPasswordField, fieldType: fieldType)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 配置 `ForgotPasswordTextField` 的基本屬性
    /// - Parameters:
    ///   - placeholder: 文字輸入框的佔位符
    ///   - rightIconName: 右側圖標的名稱，可選
    ///   - isPasswordField: 是否為密碼輸入框
    ///   - fieldType: 欄位類型
    private func setupTextField(placeholder: String, rightIconName: String?, isPasswordField: Bool, fieldType: FieldType?) {
        
        self.placeholder = placeholder
        // 如果提供了右側圖標名稱，根據是否為密碼框來設置交互行為
        if let iconName = rightIconName {
            configureRightButton(iconName: iconName, isPasswordToggle: isPasswordField, fieldType: fieldType)
        }
        translatesAutoresizingMaskIntoConstraints = false
    }

}
