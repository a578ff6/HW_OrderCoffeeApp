//
//  OrderCustomerDetailsIconImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/2.
//


import UIKit

/// `OrderCustomerDetailsIconImageView` 是一個通用的自訂 `UIImageView`。
///
/// ### 功能說明
/// - 支援 SF Symbols，並可依需求自訂圖示大小與顏色。
/// - 適用於多種元件，提供靈活的樣式配置。
/// - 預設支援 AutoLayout，無需額外手動設定尺寸或約束。
class OrderCustomerDetailsIconImageView: UIImageView {
    
    // MARK: - Initializer
    
    /// 初始化圖示視圖
    /// - Parameters:
    ///   - image: 圖片，預設為 `nil`，通常使用 SF Symbols。
    ///   - tintColor: 圖示顏色，用於設定 SF Symbols 或自訂圖片的色調。
    ///   - size: 圖標的大小（點數），影響圖示的渲染尺寸。
    ///   - symbolWeight: 圖標字重，僅適用於 SF Symbols（例如 `.regular`, `.medium`, `.bold`）。
    init(image: UIImage? = nil, tintColor: UIColor, size: CGFloat, symbolWeight: UIImage.SymbolWeight) {
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
    private func setupImageView(image: UIImage?, tintColor: UIColor, size: CGFloat, symbolWeight: UIImage.SymbolWeight) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: size, weight: symbolWeight)
        self.image = image?.withConfiguration(symbolConfiguration)
        self.tintColor = tintColor
        self.contentMode = .scaleAspectFit
        
        // 設置寬高約束，確保圖示大小固定
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: size),
            self.heightAnchor.constraint(equalToConstant: size)
        ])
    }
    
}
