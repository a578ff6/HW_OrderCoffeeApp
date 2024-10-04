//
//  OrderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/2.
//

import UIKit

/// `OrderView` 負責展示訂單的視圖，包含一個 `UICollectionView` 來展示訂單項目
class OrderView: UIView {
    
    // MARK: - UI Elements
    
    /// 用於展示訂單項目的 CollectionView
    let collectionView = OrderView.createCollectionView()
    
    // MARK: - Initializers
    
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
        collectionView.register(OrderItemCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier)
        collectionView.register(OrderSummaryCollectionViewCell.self, forCellWithReuseIdentifier: OrderSummaryCollectionViewCell.reuseIdentifier)
        collectionView.register(NoOrdersViewCell.self, forCellWithReuseIdentifier: NoOrdersViewCell.reuseIdentifier)
        collectionView.register(OrderSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OrderSectionHeaderView.headerIdentifier)
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
        let layout = OrderLayoutProvider.createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }
    
}
