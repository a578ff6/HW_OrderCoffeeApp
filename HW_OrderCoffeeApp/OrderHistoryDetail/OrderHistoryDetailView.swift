//
//  OrderHistoryDetailView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

import UIKit

/// 設置 `OrderHistoryDetailView` 和 `OrderHistoryDetailLayoutProvider`，用於展示歷史訂單細項頁面，包括顧客資訊、訂單飲品項目詳情、訂單詳情。
class OrderHistoryDetailView: UIView {

    // MARK: - UI Elements

    let collectionView = OrderHistoryDetailView.createCollectionView()

    // MARK: - Initializer
    
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
    
    /// 註冊  Cells
    private func registerCells() {
        collectionView.register(OrderrHistoryDetailItemCell.self, forCellWithReuseIdentifier: OrderrHistoryDetailItemCell.reuseIdentifier)
        collectionView.register(OrderHistoryDetailCustomerInfoCell.self, forCellWithReuseIdentifier: OrderHistoryDetailCustomerInfoCell.reuseIdentifier)
        collectionView.register(OrderrHistoryDetailCell.self, forCellWithReuseIdentifier: OrderrHistoryDetailCell.reuseIdentifier)
        collectionView.register(OrderHistoryDetailSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OrderHistoryDetailSectionHeaderView.headerIdentifier)
    }
    
    /// 設置 CollectionView 的 AutoLayout
    private func setupLayout() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Factory Method
    
    /// 創建並配置 CollectionView
    private static func createCollectionView() -> UICollectionView {
        let layout = OrderHistoryDetailLayoutProvider.createLayout()        // 設置OrderHistoryDetailLayoutProvider
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }
}
