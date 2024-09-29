//
//  FavoritesView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//

import UIKit

/// 定義並管理我的最愛頁面的主要視圖，使用 UICollectionView 來顯示我的最愛飲品。
class FavoritesView: UIView {

    // MARK: - UI Elements

    let collectionView = FavoritesView.createCollectionView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        registerCells()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    private func setupView() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊所有`自訂義的 cell`
    private func registerCells() {
        collectionView.register(FavoriteDrinkCell.self, forCellWithReuseIdentifier: FavoriteDrinkCell.reuseIdentifier)
        collectionView.register(FavoritesDrinkHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FavoritesDrinkHeaderView.reuseIdentifier)
    }
    
    // MARK: - Factory Method

    /// 創建並設置 UICollectionView
    private static func createCollectionView() -> UICollectionView {
        let layout = FavoritesLayoutProvider.createLayout()             // 使用 Compositional Layout
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
}
