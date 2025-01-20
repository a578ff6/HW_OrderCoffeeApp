//
//  OrderHistoryIconImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/15.
//

import UIKit

/// `OrderHistoryIconImageView` 是一個通用的自訂 `UIImageView`，
/// 用於展示歷史訂單頁面中的圖示（如數量圖示或其他圖標）。
///
/// 此類別支援以下功能：
/// - 預設支援 SF Symbols，並可自定義圖示大小與顏色。
/// - 提供靈活的樣式設置，適用於多個元件中。
/// - 預設適配 AutoLayout，無需額外設定。
class OrderHistoryIconImageView: UIImageView {
    
    // MARK: - Initializer
    
    /// 初始化圖示視圖
    /// - Parameters:
    ///   - image: 圖片，預設為 `nil`，通常使用 SF Symbols。
    ///   - tintColor: 圖示顏色，用於設定 SF Symbols 或自訂圖片的色調。
    ///   - size: 圖標的大小（點數），影響圖示的渲染尺寸。
    ///   - symbolWeight: 圖標字重，僅適用於 SF Symbols（例如 `.regular`, `.medium`, `.bold`）。
    init(
        image: UIImage? = nil,
        tintColor: UIColor,
        size: CGFloat,
        symbolWeight: UIImage.SymbolWeight
    ) {
        super.init(frame: .zero)
        setupImageView(image: image, tintColor: tintColor, size: size, symbolWeight: symbolWeight)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置圖示視圖的外觀與佈局
    /// - Parameters:
    ///   - image: 圖片，通常為 SF Symbols。
    ///   - tintColor: 圖示顏色，用於調整顯示效果。
    ///   - size: 圖標大小（點數），影響圖示顯示的比例。
    ///   - symbolWeight: 圖標字重，控制 SF Symbols 的粗細程度。
    private func setupImageView(
        image: UIImage?,
        tintColor: UIColor,
        size: CGFloat,
        symbolWeight: UIImage.SymbolWeight
    ) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: size, weight: symbolWeight)
        self.image = image?.withConfiguration(symbolConfiguration)
        self.tintColor = tintColor
        self.contentMode = .scaleAspectFit
        
        // 設置寬高約束，確保圖示大小固定
        self.widthAnchor.constraint(equalToConstant: size).isActive = true
        self.heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
}
