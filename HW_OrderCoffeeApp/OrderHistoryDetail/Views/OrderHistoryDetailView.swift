//
//  OrderHistoryDetailView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

import UIKit

/// `OrderHistoryDetailView`
///
/// 負責顯示歷史訂單的細節頁面，主要包含以下部分：
/// - 顧客資訊：如姓名、聯絡方式等。
/// - 訂單飲品項目詳情：展示訂單中每個飲品的詳細資訊。
/// - 訂單概要：如訂單編號、總金額等。
///
/// 此視圖的主要功能：
/// 1. 提供 `UICollectionView` 來呈現歷史訂單的細節資料。
/// 2. 自動管理 Cell 和 Header 的註冊。
/// 3. 配置 AutoLayout，確保在不同螢幕尺寸上正確顯示。
class OrderHistoryDetailView: UIView {
    
    // MARK: - UI Elements
    
    /// 用於展示訂單詳細資訊的自訂 CollectionView。
    ///
    /// - 說明：此 CollectionView 的布局由 `OrderHistoryDetailLayoutProvider` 提供，專為展示訂單細節設計。
    private(set) var orderHistoryDetailCollectionView = OrderHistoryDetailCollectionView()
    
    // MARK: - Initializer
    
    /// 初始化方法
    ///
    /// - 作用：完成 Cell 的註冊及 CollectionView 的布局設置。
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCells()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 註冊 CollectionView 中使用的 Cells 和 Supplementary Views。
    ///
    /// - 說明：註冊包含訂單飲品詳情、顧客資訊、訂單摘要的相關 Cell，以及區段 Header。
    private func registerCells() {
        orderHistoryDetailCollectionView.register(OrderrHistoryDetailItemCell.self, forCellWithReuseIdentifier: OrderrHistoryDetailItemCell.reuseIdentifier)
        orderHistoryDetailCollectionView.register(OrderHistoryDetailCustomerInfoCell.self, forCellWithReuseIdentifier: OrderHistoryDetailCustomerInfoCell.reuseIdentifier)
        orderHistoryDetailCollectionView.register(OrderrHistoryDetailCell.self, forCellWithReuseIdentifier: OrderrHistoryDetailCell.reuseIdentifier)
        orderHistoryDetailCollectionView.register(OrderHistoryDetailSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OrderHistoryDetailSectionHeaderView.headerIdentifier)
    }
    
    /// 設置 CollectionView 的 AutoLayout
    private func setupLayout() {
        addSubview(orderHistoryDetailCollectionView)
        
        NSLayoutConstraint.activate([
            orderHistoryDetailCollectionView.topAnchor.constraint(equalTo: topAnchor),
            orderHistoryDetailCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            orderHistoryDetailCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            orderHistoryDetailCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
