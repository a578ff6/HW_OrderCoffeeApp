//
//  DrinksCategoryLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/29.
//


import UIKit

/// DrinksCategoryCollectionViewController 佈局使用
class DrinksCategoryLayoutProvider {
    
    func getLayout(for layoutType: DrinksCategoryCollectionViewController.Layout, subcategoryDrinksCount: Int) -> UICollectionViewLayout {
        switch layoutType {
        case .grid:
            return generateGridLayout(subcategoryDrinksCount: subcategoryDrinksCount)
        case .column:
            return generateColumnLayout(subcategoryDrinksCount: subcategoryDrinksCount)
        }
    }
    
    /// 網格佈局
    func generateGridLayout(subcategoryDrinksCount: Int) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(260)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(260)), subitems: [item, item])
            group.interItemSpacing = .fixed(15)             // 設置列間距
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20              // 設置行間距
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionHeaderSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]
            
            if sectionIndex < subcategoryDrinksCount - 1 {
                let separatorSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.0), heightDimension: .absolute(2))
                let separator = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: separatorSize,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                section.boundarySupplementaryItems.append(separator)
            }
            
            return section
        }
    }
    
    /// 列佈局
    func generateColumnLayout(subcategoryDrinksCount: Int) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionHeaderSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [sectionHeader]

            // 如果不是最後一個 section，添加分隔線
            if sectionIndex < subcategoryDrinksCount - 1 {
                let separatorSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(2))
                let separator = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: separatorSize,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                section.boundarySupplementaryItems.append(separator)
            }
            
            return section
        }
    }
   
}
