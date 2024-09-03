//
//  MenuLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/29.
//

/*
 
 ## MenuLayoutProvider:
 
    - MenuLayoutProvider 負責根據不同的 section 生成對應的 UICollectionView 佈局。
    - 根據 MenuViewController.MenuSection 的值，生成不同的佈局來展示網站橫幅或飲品分類。
 
    * 主要方法：
        - generateLayout(for section:)： 根據 section 的類型，選擇合適的佈局生成方法。
        - generateWebsiteBannerLayout()： 為網站橫幅生成橫向滾動的佈局，允許用戶左右滑動來查看不同的橫幅。
        - generateGridLayout()： 為飲品分類生成網格佈局，展示多個分類項目。
 */


// MARK: - 已完善
import UIKit

/// 負責根據不同的 section 生成對應的 UICollectionView 佈局。
///
/// 根據 MenuViewController.MenuSection 的值，生成不同的佈局來展示網站橫幅或飲品分類。
class MenuLayoutProvider {

    /// 根據傳入的 section 生成對應的 `NSCollectionLayoutSection`。
    /// - Parameter section: 代表菜單頁面中不同的區域，如「網站橫幅」或「飲品分類」。
    /// - Returns: 根據 section 類型生成的 `NSCollectionLayoutSection`。
    func generateLayout(for section: MenuViewController.MenuSection) -> NSCollectionLayoutSection {
        switch section {
        case .websiteBanner:
            return generateWebsiteBannerLayout()
        case .drinkCategories:
            return generateGridLayout()
        }
    }
    
    /// 為「網站橫幅」區域生成橫向滾動的佈局。
    private func generateWebsiteBannerLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 將 group 的寬度設置為稍小於螢幕寬度，這樣組之間會有間距
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalWidth(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: -10, bottom: 15, trailing: 0)   // leading -10 提示有下一個banner
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)     // header 會向右移動 10 點，以補償 section 的 leading: -10
        section.boundarySupplementaryItems = [header]
        return section
    }

    /// 為「飲品分類」區域生成網格佈局。
    private func generateGridLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        // 設置列間距
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0)    // // header 會向右移動 10 點，以補償 section 的 leading: 10
        section.boundarySupplementaryItems = [header]
        return section
    }
    
}


