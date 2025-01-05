//
//  OrderCustomerDetailsSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/11.
//


import UIKit

/// `OrderCustomerDetailsSectionHeaderView` 用於訂單詳情頁面的 Section Header，提供標題與分隔線，適合多段資料的分隔與展示。
///
/// ### 功能特色
/// - 標題展示：提供一個標題標籤，用於顯示每個段落的標題，字體樣式為粗體。
/// - 分隔視圖：在標題下方加入分隔線，增強視覺區分效果。
/// - 垂直堆疊佈局：透過 `OrderCustomerDetailsStackView` 將標題與分隔線組合成一個整體，提升佈局一致性與可讀性。
///
/// ### 使用場景
/// 適用於需要展示清晰分段標題的場景，例如：
/// - 訂單詳情頁面的客戶資訊、取件方式或備註區。
/// - 節點內容的分隔與標題展示。
///
/// ### 使用方式
/// 1. 在 `UICollectionView` 中註冊此 Header View，並於對應的 `dataSource` 方法中返回。
/// 2. 使用 `configure(with:)` 方法設置標題文字。
/// 3. 本類別自動處理佈局與內容清理，確保重用時無殘留內容。
///
/// ### 注意事項
/// - 當重用 Header View 時，`prepareForReuse` 會清空標題文字，需於重設資料時再次調用 `configure(with:)` 設置標題。
/// - 分隔線的顏色可通過 `OrderCustomerDetailsSeparatorView` 的初始化參數調整。
class OrderCustomerDetailsSectionHeaderView: UICollectionReusableView {
        
    /// Header View 的重複使用識別碼
    static let headerIdentifier = "OrderCustomerDetailsSectionHeaderView"
    
    // MARK: - UI Elements
    
    /// 標題標籤
    /// - 用於展示每個 Section 的標題內容，字體樣式為粗體，顏色為黑色。
    private let titleLabel = OrderCustomerDetailsLabel(font: .systemFont(ofSize: 22, weight: .bold), textColor: .black)
    
    /// 分隔線視圖
    /// - 用於在標題下方顯示一條分隔線，顏色為淺灰色，固定高度為 2 點。
    private let separatorView = OrderCustomerDetailsSeparatorView(color: .lightGray)
    
    /// 包含標題和分隔線的垂直堆疊視圖
    private let titleAndSeparatorStackView = OrderCustomerDetailsStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer

    /// 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 配置 Section Header 的布局
    private func configureLayout() {
        titleAndSeparatorStackView.addArrangedSubview(titleLabel)
        titleAndSeparatorStackView.addArrangedSubview(separatorView)
        addSubview(titleAndSeparatorStackView)
        
        NSLayoutConstraint.activate([
            titleAndSeparatorStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleAndSeparatorStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            titleAndSeparatorStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleAndSeparatorStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    // MARK: - Configure Method

    /// 設定 Section Header 的標題
    /// - Parameter title: 要顯示的標題文字
    /// - 本方法將文字內容設定至 `titleLabel`，用於更新 Header 顯示。
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重用時清空內容
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

}
