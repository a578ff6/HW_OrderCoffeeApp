//
//  OrderItemIconImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/29.
//


import UIKit

/// `OrderItemIconImageView` 是一個通用的自訂 `UIImageView`，
/// 用於展示訂單中的圖示（如數量圖示或其他圖標）。
///
/// 此類別支援以下功能：
/// - 預設支援 SF Symbols，並可自定義圖示大小與顏色。
/// - 提供靈活的樣式設置，適用於多個元件中。
/// - 預設適配 AutoLayout，無需額外設定。
class OrderItemIconImageView: UIImageView {

    // MARK: - Initializer

    /// 初始化通用圖示視圖
    /// - Parameters:
    ///   - image: 圖片，預設為 `nil`
    ///   - tintColor: 圖片顏色
    ///   - size: 圖標大小
    ///   - symbolWeight: 圖標字重，僅適用於 SF Symbols。
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

    /// 配置圖片視圖的外觀
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
    }
}
