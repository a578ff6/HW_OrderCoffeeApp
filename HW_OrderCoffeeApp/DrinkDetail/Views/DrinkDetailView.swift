//
//  DrinkDetailView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/8.
//

/*
 ## DrinkDetailView：
 
    * 功能： DrinkDetailView 是 DrinkDetailViewController 的主視圖，主要使用 UICollectionView 來顯示飲品詳細資訊、尺寸選擇、價格資訊及訂單選項。

    * 視圖設置：
        - 包含一個 UICollectionView，並透過 DrinkDetailLayoutProvider 來提供不同 section 的佈局。
        - 使用者透過此視圖選擇飲品尺寸、查看價格資訊及新增或更新訂單。

    * 註冊的自定義 Cell：
        - DrinkInfoCollectionViewCell： 顯示飲品的詳細資訊。
        - DrinkSizeSelectionCollectionViewCell： 顯示飲品的尺寸選擇。
        - DrinkPriceInfoCollectionViewCell： 顯示選中尺寸的價格資訊。
        - DrinkOrderOptionsCollectionViewCell： 顯示訂單的選項，如加入購物車按鈕。
        - DrinkDetailSeparatorView： 顯示在 section footer 內的分隔視圖。

 */

import UIKit

/// 定義並管理 DrinkDetailViewController 的主要是圖，使用 UICollectionView 來顯示飲品詳細資訊、尺寸選擇、價格和訂單選項的主要元素。
class DrinkDetailView: UIView {
    
    // MARK: - UI Elements

    /// `UICollectionView`，用於顯示飲品的相關資訊與互動選項
    let collectionView = DrinkDetailView.createCollectionView()
    
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
    
    /// 設置 `DrinkDetailView` 的主要視圖佈局，將 `collectionView` 加入到當前視圖內
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
        collectionView.register(DrinkImageCollectionViewCell.self, forCellWithReuseIdentifier: DrinkImageCollectionViewCell.reuseIdentifier)
        collectionView.register(DrinkInfoCollectionViewCell.self, forCellWithReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier)
        collectionView.register(DrinkSizeSelectionCollectionViewCell.self, forCellWithReuseIdentifier: DrinkSizeSelectionCollectionViewCell.reuseIdentifier)
        collectionView.register(DrinkPriceInfoCollectionViewCell.self, forCellWithReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier)
        collectionView.register(DrinkOrderOptionsCollectionViewCell.self, forCellWithReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier)
        
        collectionView.register(DrinkDetailSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier)
        collectionView.register(DrinkDetailSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier)
    }
    
    // MARK: - Factory Method
    
    /// 建立並配置 `UICollectionView`，同時使用 `DrinkDetailLayoutProvider` 來定義佈局
    /// - Returns: 已配置好的 UICollectionView
    private static func createCollectionView() -> UICollectionView {
        let layoutProvider = DrinkDetailLayoutProvider()
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = DrinkDetailViewController.Section(rawValue: sectionIndex) else {
                return nil
            }
            return layoutProvider.generateLayout(for: section)      // 根據 section 類型返回對應的佈局
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
}
