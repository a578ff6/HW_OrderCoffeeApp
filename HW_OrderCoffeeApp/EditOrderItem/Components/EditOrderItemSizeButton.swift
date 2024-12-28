//
//  EditOrderItemSizeButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/25.
//

import UIKit

/// 自訂的飲品尺寸按鈕，用於飲品尺寸選擇功能
///
/// 此按鈕具有：
/// - 圓角設計
/// - 動態填充背景顏色
/// - 根據選中狀態變更外觀樣式
class EditOrderItemSizeButton: UIButton {
    
    // MARK: - Initializer
    
    /// 初始化按鈕樣式
    /// - Parameters:
    ///   - cornerStyle: 圓角樣式，預設為 `.small`
    ///   - baseBackgroundColor: 按鈕背景顏色，預設為淺灰色
    ///   - baseForegroundColor: 按鈕文字/圖標顏色，預設為黑色
    init(cornerStyle: UIButton.Configuration.CornerStyle = .small, baseBackgroundColor: UIColor = .lightWhiteGray, baseForegroundColor: UIColor = .black) {
        super.init(frame: .zero)
        setupStyle(cornerStyle: cornerStyle, baseBackgroundColor: baseBackgroundColor, baseForegroundColor: baseForegroundColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置按鈕的初始樣式
    /// - Parameters:
    ///   - cornerStyle: 圓角樣式
    ///   - baseBackgroundColor: 初始背景顏色
    ///   - baseForegroundColor: 初始文字或圖標顏色
    private func setupStyle(cornerStyle: UIButton.Configuration.CornerStyle, baseBackgroundColor: UIColor, baseForegroundColor: UIColor) {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = cornerStyle
        configuration.baseBackgroundColor = baseBackgroundColor
        configuration.baseForegroundColor = baseForegroundColor
        self.configuration = configuration
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - State Management
    
    /// 更新按鈕外觀，根據是否被選中
    /// - Parameter isSelected: 傳入 `true` 設為選中狀態，`false` 設為未選中狀態
    func updateAppearance(isSelected: Bool) {
        self.configuration?.baseBackgroundColor = isSelected ? .deepGreen.withAlphaComponent(0.8) : .lightWhiteGray
        self.configuration?.baseForegroundColor = isSelected ? .white : .black
    }
    
}
