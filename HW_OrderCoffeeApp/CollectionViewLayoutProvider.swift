//
//  CollectionViewLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/20.
//

import UIKit

/// 用於配置 UICollectionView 的不同佈局。
class CollectionViewLayoutProvider {
    
    /// 列狀佈局。
    /// - Returns: 返回 UICollectionViewLayout，適用於顯示列狀排列的項目。
    static func generateColumnLayout() -> UICollectionViewLayout {
        
        // 元素間的間距
        let padding: CGFloat = 10
        
        // 創建布局項目，設置尺寸
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        // 創建水平布局群組，包含一個項目
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(120)
            ),
            subitem: item,
            count: 1
        )
        
        // 設置群組間距和內邊距
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding )
        
        // 創建佈局區段，包括群組和間距
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0)
        
        // 添加 section header
        section.boundarySupplementaryItems = [generateHeader()]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    /// 生成網格佈局。
    /// - Parameter includeHeader: 是否包括 section header
    /// - Returns: 返回一個 UICollectionViewLayout，適用於顯示網格排列的項目。
    static func generateGridLayout(includeHeader: Bool = false) -> UICollectionViewLayout {
        
        /// 設定元素間的間距
        let padding: CGFloat = 20
        
        // 創建布局項目，設置尺寸
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        // 創建水平布局群組，包含兩個項目
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1/4)
            ),
            subitem: item,
            count: 2
        )
        
        // 設置群組間距和內邊距
        group.interItemSpacing = .fixed(padding)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding)
        
        // 創建佈局區段，包括群組和間距
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0)
        
        // 如果需要，添加 section header
        if includeHeader {
            section.boundarySupplementaryItems = [generateHeader()]
        }
        
        return UICollectionViewCompositionalLayout(section: section)
     }
    
    
    /// section header 佈局。
    /// - Returns: 返回一個配置好的 section header 佈局。
    static func generateHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
    
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        return header
     }
    
}

