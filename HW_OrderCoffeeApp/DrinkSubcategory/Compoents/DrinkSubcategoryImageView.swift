//
//  DrinkSubcategoryImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/24.
//


// MARK: - (v)

import UIKit

/// 自訂的圖片視圖，專為`飲品子分類頁面`設計，提供統一的圖片顯示樣式與屬性。
///
/// 此類旨在簡化並統一管理`飲品子分類頁面`中常見的圖片顯示邏輯，
/// 如設定圖片的內容模式（`contentMode`）與圓角（`cornerRadius`）等屬性。
///
/// - 功能特色:
///   1. 預設圖片內容模式為 `.scaleAspectFill`，確保圖片完整顯示且不會變形。
///   2. 預設支援圖片圓角設置，提升視覺效果。
///   3. 適用於`飲品子分類`模組的多個場景，例如網格、列表圖片等。
class DrinkSubcategoryImageView: UIImageView {
    
    // MARK: - Initializer
    
    /// 初始化自訂圖片視圖。
    ///
    /// 提供預設屬性配置，並支持靈活設置圖片的內容模式與圓角半徑。
    ///
    /// - Parameters:
    ///   - contentMode: 圖片的內容模式，默認為 `.scaleAspectFill`。
    ///   - cornerRadius: 圖片的圓角半徑，默認為 10。
    init(contentMode: UIView.ContentMode = .scaleAspectFill, cornerRadius: CGFloat = 10) {
        super.init(frame: .zero)
        setupImageView(contentMode: contentMode, cornerRadius: cornerRadius)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置圖片視圖的外觀與屬性。
    ///
    /// 此方法集中設置 `UIImageView` 的基本屬性，如內容模式、圓角等，確保圖片樣式一致性。
    ///
    /// - Parameters:
    ///   - contentMode: 圖片的內容模式。
    ///   - cornerRadius: 圖片的圓角半徑。
    private func setupImageView(contentMode: UIView.ContentMode, cornerRadius: CGFloat) {
        self.contentMode = contentMode
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
