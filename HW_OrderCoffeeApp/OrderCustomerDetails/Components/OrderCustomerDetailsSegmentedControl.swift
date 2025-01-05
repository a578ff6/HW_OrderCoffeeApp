//
//  OrderCustomerDetailsSegmentedControl.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/3.
//

import UIKit

/// 自訂的 Segmented Control，提供統一樣式與行為。
///
/// ### 功能特色
/// - 預設樣式：設定初始選擇索引與背景樣式。
/// - 適配 AutoLayout，無需手動調整尺寸。
class OrderCustomerDetailsSegmentedControl: UISegmentedControl {
    
    // MARK: - Initializer
    
    /// 初始化 Segmented Control
    /// - Parameters:
    ///   - items: Segmented Control 的選項文字陣列。
    ///   - defaultIndex: 預設選中的索引，預設為 `0`。
    init(items: [String], defaultIndex: Int = 0) {
        super.init(items: items)
        setupSegmentedControl(defaultIndex: defaultIndex)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 Segmented Control 的樣式與屬性
    /// - Parameter defaultIndex: 預設選中的索引。
    private func setupSegmentedControl(defaultIndex: Int) {
        self.selectedSegmentIndex = defaultIndex
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
        self.tintColor = .black
    }
    
}
