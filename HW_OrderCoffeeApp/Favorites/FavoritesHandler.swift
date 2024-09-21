//
//  FavoritesHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//

import UIKit

/// `FavoritesHandler` 負責管理 `FavoritesViewController` 中的 UICollectionView 的資料來源 (dataSource) 及使用者互動 (delegate)。
class FavoritesHandler: NSObject {
    
    // MARK: - Properties
    
    var collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, Drink>!
    
    /// 使用 Sections 作為 dataSource 的 section 類型
    enum Section {
        case main
    }
    
    // MARK: - Initializer

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        configureDataSource()
    }
    
    // MARK: - DataSource 設定

    /// DataSource 設定
    private func configureDataSource() {
        // 配置 dataSource
        dataSource = UICollectionViewDiffableDataSource<Section, Drink>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, drink: Drink) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteDrinkCell.reuseIdentifier, for: indexPath) as? FavoriteDrinkCell else {
                return UICollectionViewCell()
            }
            // 配置 cell 的顯示
            cell.configure(with: drink)
            return cell
        }
        
        // 設定初始快照
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Drink>()
        initialSnapshot.appendSections([.main])
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }
    
    // MARK: - 更新快照資料

    /// 更新快照資料
    func updateSnapshot(with drinks: [Drink]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Drink>()
        snapshot.appendSections([.main])
        snapshot.appendItems(drinks)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - UICollectionViewDelegate
extension FavoritesHandler: UICollectionViewDelegate {
    
}


