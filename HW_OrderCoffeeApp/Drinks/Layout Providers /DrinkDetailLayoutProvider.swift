//
//  DrinkDetailLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/30.
//

import UIKit

/// DrinkDetailViewControler 佈局使用
class DrinkDetailLayoutProvider {
    
    /// 創建 collectionView 的布局
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionType = DrinkDetailViewController.Section.allCases[sectionIndex]
            var sectionLayout: NSCollectionLayoutSection
            
            switch sectionType {
            case .info:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300)), subitems: [item])
                sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0)
                
            case .sizeSelection:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3), heightDimension: .fractionalWidth(1.0/3)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0/3)), subitems: [item])
                sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .groupPagingCentered
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

            case .priceInfo:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
                sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 10, trailing: 0)
                
            case .orderOptions:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)), subitems: [item])
                sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
            }
            
            /// 只為 info 和 sizeSelection 添加分隔線
            if sectionType != .priceInfo && sectionType != .orderOptions {
                let separatorSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1))
                let separatorItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: separatorSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                sectionLayout.boundarySupplementaryItems = [separatorItem]
            }
            
            return sectionLayout
        }
        
        return layout
    }
}
