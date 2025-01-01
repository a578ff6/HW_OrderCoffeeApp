//
//  OrderItemSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/14.
//


// MARK: - OrderItemSectionHeaderView 筆記
/**
 
 ## OrderItemSectionHeaderView 筆記
 
 `* What`
 
 `OrderItemSectionHeaderView` 是一個用於 `OrderItemViewController` 的區段標頭視圖，提供以下功能：
 
 1. 顯示區段標題文字（透過 `titleLabel`）。
 2. 在標題下方顯示分隔線（透過 `separatorView`）。
 3. 使用垂直堆疊視圖（`headerStackView`）簡化佈局與管理，提升可讀性與維護性。

 -------------

 `* Why`
 
 1. 清晰的區段結構：在訂單視圖中，每個區段需要一個標頭來提示其內容。`titleLabel` 用於顯示區段標題，讓使用者快速辨識。
 2. 視覺分隔效果：分隔線（`separatorView`）提供視覺上的分區效果，使內容顯得更有層次感。
 3. 統一的佈局管理：使用 `headerStackView` 統一管理 `titleLabel` 和 `separatorView`，可減少冗長的約束設置，提升可維護性與未來擴展性。

 -------------

 `* How`
 
 1. 使用元件：
 
    - `titleLabel`：顯示區段的標題文字。
    - `separatorView`：分隔標題與下方內容，採用自訂的 `OrderItemBottomLineView`，提供統一的分隔樣式。
    - `headerStackView`：透過垂直堆疊的方式整合 `titleLabel` 和 `separatorView`，簡化佈局邏輯。
    
 2. 設置方式：
 
    - 將 `titleLabel` 和 `separatorView` 添加到 `headerStackView`。
    - 將 `headerStackView` 添加到 `contentView`，並設置頂部、兩側與底部的約束，確保其在區段內完整呈現。
    - 為 `separatorView` 設置固定的高度（2pt），以確保分隔線樣式一致。

 3. 配置方法：
 
    - 使用 `configure(with:)` 方法設置標題文字。
    - 在 `prepareForReuse` 中清除標題文字，確保重複使用的安全性。
 */


import UIKit

/// 用於 `OrderItemViewController` 的 Section Header，提供標題與分隔線視圖。
///
/// 此類別支援以下功能：
/// - 顯示區段標題文字（`titleLabel`）
/// - 在標題下方顯示分隔線（`separatorView`）
/// - 使用垂直堆疊視圖（`headerStackView`）簡化佈局與管理
class OrderItemSectionHeaderView: UICollectionReusableView {
    
    // MARK: - Static Properties

    /// Section Header 的重複使用識別碼
    static let headerIdentifier = "OrderItemSectionHeaderView"
    
    // MARK: - UI Elements
    
    /// 顯示區段標題的標籤
    private let titleLabel = OrderItemLabel(font: .systemFont(ofSize: 22, weight: .bold), textColor: .black)
    
    /// 底部分隔線
    private let separatorView = OrderItemBottomLineView(backgroundColor: .gray)
    
    /// 包含標題與分隔線的垂直堆疊視圖
    private let headerStackView = OrderItemStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer
    
    /// 初始化 Section Header
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 Section Header 的佈局
    ///
    /// 包括：
    /// - 將 `titleLabel` 和 `separatorView` 添加到 `headerStackView` 中
    /// - 將 `headerStackView` 添加到 `contentView` 並設置約束
    private func configureLayout() {
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(separatorView)
        
        addSubview(headerStackView)
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            headerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 分隔線高度
            separatorView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    // MARK: - Configure Method
    
    /// 設置標題
    /// - Parameter title: 要顯示的標題文字
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置 Header 狀態
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
}
