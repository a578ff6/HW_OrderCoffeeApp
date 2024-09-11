//
//  DrinksCategoryView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/4.
//


import UIKit

/// 定義並管理飲品類別頁面的主要視圖，使用 UICollectionView 來顯示飲品的分類。
class DrinksCategoryView: UIView {

    // MARK: - UI Elements
    
    let collectionView = DrinksCategoryView.createCollectionView()
    
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
    
    /// 註冊所有`自訂義的 cell` 與 `supplementary views`，確保 `UICollectionView` 具備顯示這些元素的能力
    private func registerCells() {
        collectionView.register(ColumnItemCell.self, forCellWithReuseIdentifier: ColumnItemCell.reuseIdentifier)
        collectionView.register(GridItemCell.self, forCellWithReuseIdentifier: GridItemCell.reuseIdentifier)
        
        //  註冊 section header、footer
        collectionView.register(DrinksCategorySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DrinksCategorySectionHeaderView.headerIdentifier)
        collectionView.register(DrinksCategorySectionFooterView.self.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DrinksCategorySectionFooterView.footerIdentifier)
    }
    
    // MARK: - Factory Method

    /// 創建並設置 UICollectionView
    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }

}
