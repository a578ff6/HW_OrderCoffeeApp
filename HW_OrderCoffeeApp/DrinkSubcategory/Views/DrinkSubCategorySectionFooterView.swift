//
//  DrinkSubCategorySectionFooterView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/5.
//


// MARK: - (v)

import UIKit

/// 自訂的 Footer View，用於區隔 `DrinkSubCategoryViewController` 的 section 底部。
///
/// 此類專為 `DrinkSubCategoryViewController` 的 `UICollectionView` 設計，
/// 主要用於在每個 section 的底部添加一條分隔線，
/// 提升視覺區隔效果，增強界面結構的清晰度。
///
/// - 功能特色:
///   1. 提供統一的分隔線樣式，增強 section 間的視覺分離效果。
///   2. 使用自訂的 `DrinkSubCategorySeparatorView`，配置分隔線的顏色與高度。
///   3. 支援動態布局，通過 Auto Layout 設置間距與位置。
///
/// - 使用場景:
///   適用於 `DrinkSubCategoryViewController` 的 `UICollectionView`，
///   作為每個 section 的 footer，區隔不同區域的內容。
class DrinkSubCategorySectionFooterView: UICollectionReusableView {
    
    /// footer view 的重用識別符。
    static let footerIdentifier = "DrinkSubCategorySectionFooterView"
    
    // MARK: - UI Elements
    
    private let separatorView = DrinkSubCategorySeparatorView(backgroundColor: .lightWhiteGray, height: 1.0)
    
    // MARK: - Initialization
    
    /// 初始化 footer view。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFooterView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 footer view 的子視圖與佈局。
    ///
    /// - 將 `separatorView` 添加到視圖中。
    /// - 設置約束，確保分隔線具有適當的間距與對齊。
    private func setupFooterView() {
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
}
