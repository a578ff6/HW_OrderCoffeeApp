//
//  DrinkDetailLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/30.
//


/*
 ## DrinkDetailLayoutProvider：
 
    * 功能：DrinkDetailLayoutProvider 主要負責為 DrinkDetailViewController 中的各個 section 生成對應的佈局，讓每個 section 的顯示樣式與互動方式更具彈性。
 
    * 佈局生成：
        - 根據傳入的 section，使用 generateLayout(for:) 方法來動態生成對應的 NSCollectionLayoutSection。
        - 不同 section 包含不同的視覺佈局邏輯，如資訊區、尺寸選擇區、價格資訊區以及訂單選項區。

    * 佈局細節：
        - generateInfoLayout()： 為飲品資訊 section 設置垂直佈局，並預估高度 300。
        - generateSizeSelectionLayout()： 為尺寸選擇區設置橫向滾動的 group paging 佈局，並設置 1/3 寬的正方形元素。
        - generatePriceInfoLayout()： 為價格資訊區設置垂直佈局，並預估高度 100。
        - generateOrderOptionsLayout()： 為訂單選項區設置垂直佈局，並預估高度 50。
        - 每個 section 都可能包含底部的分隔線 footer，透過 createFooter() 生成。
 */


// MARK: - 已完善重構

import UIKit

/// `DrinkDetailLayoutProvider` 負責為 `DrinkDetailViewController` 中的各個 section 動態生成相對應的佈局。
class DrinkDetailLayoutProvider {
    
    /// 根據傳入的 section 生成對應的 `NSCollectionLayoutSection`
    /// - Parameter section: `DrinkDetailViewController.Section`，代表要顯示的 section 類型
    /// - Returns: 對應的 `NSCollectionLayoutSection` 佈局
    func generateLayout(for section: DrinkDetailViewController.Section) -> NSCollectionLayoutSection {
        switch section {
        case .image:
            return generateImageLayout()
        case .info:
            return generateInfoLayout()
        case .sizeSelection:
            return generateSizeSelectionLayout()
        case .priceInfo:
            return generatePriceInfoLayout()
        case .orderOptions:
            return generateOrderOptionsLayout()
        }
    }
    
    /// 生成飲品圖片section的佈局
    private func generateImageLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0)
        return section
    }
    
    /// 生成飲品資訊 (info) section 的佈局
    private func generateInfoLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0)
        return section
    }
    
    /// 生成尺寸選擇 (sizeSelection) section 的佈局
    private func generateSizeSelectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3), heightDimension: .fractionalWidth(1.0/3)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0/3)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.boundarySupplementaryItems = [createHeader(height: 1), createFooter(height: 1) ]
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        return section
    }
    
    /// 生成價格資訊 (priceInfo) section 的佈局
    private func generatePriceInfoLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 10, trailing: 0)
        return section
    }
    
    /// 生成訂單選項 (orderOptions) section 的佈局
    private func generateOrderOptionsLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        return section
    }
    
    /// 建立並配置 section 底部的分隔 footer
    private func createFooter(height: CGFloat) -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
    }
    
    /// 建立並配置 section 上方的分隔 header
    private func createHeader(height: CGFloat) -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }

}
