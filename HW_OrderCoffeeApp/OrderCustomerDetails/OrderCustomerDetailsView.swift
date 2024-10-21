//
//  OrderCustomerDetailsView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/10.
//

import UIKit

/// `OrderCustomerDetailsView` 負責展示OrderCustomerDetailsViewController，包含一個 `UICollectionView` 來展示
class OrderCustomerDetailsView: UIView {

    // MARK: - UI Elements

    let collectionView = OrderCustomerDetailsView.createCollectionView()
    
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
        collectionView.register(OrderTermsMessageCell.self, forCellWithReuseIdentifier: OrderTermsMessageCell.reuseIdentifier)
        collectionView.register(OrderCustomerInfoCell.self, forCellWithReuseIdentifier: OrderCustomerInfoCell.reuseIdentifier)
        collectionView.register(OrderPickupMethodCell.self, forCellWithReuseIdentifier: OrderPickupMethodCell.reuseIdentifier)
        collectionView.register(OrderCustomerNoteCell.self, forCellWithReuseIdentifier: OrderCustomerNoteCell.reuseIdentifier)
        collectionView.register(OrderCustomerSubmitCell.self, forCellWithReuseIdentifier: OrderCustomerSubmitCell.reuseIdentifier)
        
        collectionView.register(OrderCustomerDetailsSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OrderCustomerDetailsSectionHeaderView.headerIdentifier)
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
        let layout = OrderCustomerDetailsLayoutProvider.createLayout()    
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }
    
}
