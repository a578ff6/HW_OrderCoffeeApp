//
//  OrderCustomerDetailsSelectStoreButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/3.
//

import UIKit

/// 自訂的「選擇店家」按鈕，提供統一樣式與行為。
///
/// ### 功能特色
/// - 僅支援圖示顯示，適用於「選擇店家」的操作場景。
/// - 採用系統內建的圓角樣式（`cornerStyle`），提供更直觀的樣式控制。
/// - 支援 AutoLayout，無需額外設定尺寸或樣式。
class OrderCustomerDetailsSelectStoreButton: UIButton {
    
    // MARK: - Initializer
    
    /// 初始化按鈕
    /// - Parameters:
    ///   - iconName: 圖示名稱（SF Symbols），用於設定按鈕的圖標。
    ///   - cornerStyle: 圓角樣式，預設為 `.medium`，可根據需求選擇不同的樣式（例如 `.capsule`）。
    init(iconName: String, cornerStyle: UIButton.Configuration.CornerStyle = .medium) {
        super.init(frame: .zero)
        setupButton(iconName: iconName, cornerStyle: cornerStyle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置按鈕的樣式與屬性
    /// - Parameters:
    ///   - iconName: 圖示名稱（SF Symbols）。
    ///   - cornerStyle: 圓角樣式，控制按鈕的圓角形狀。
    ///
    /// 使用 `UIButton.Configuration.filled()` 進行樣式設置，確保按鈕的圖標與背景顏色一致，並提供統一的視覺效果。
    private func setupButton(iconName: String, cornerStyle: UIButton.Configuration.CornerStyle) {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: iconName)
        config.baseBackgroundColor = .deepGreen
        config.baseForegroundColor = .white
        config.cornerStyle = cornerStyle
        
        self.configuration = config
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
