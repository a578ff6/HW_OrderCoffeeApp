//
//  OrderHistoryDetailLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//

import UIKit

/// `OrderHistoryDetailLayoutProvider` 負責為 `OrderHistoryDetailHandler` 提供佈局
class OrderHistoryDetailLayoutProvider {
    
    // MARK: - Layout Creation
    
    /// 提供 `UICollectionViewCompositionalLayout` 的佈局方法
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionType = OrderHistoryDetailHandler.Section(rawValue: sectionIndex) else { return nil }
            switch sectionType {
            case .itemDetails:
                return createOrderHistoryItemDetailsSection()
            case .customerInfo:
                return createOrderHistoryCustomerInfoSection()
            case .details:
                return createOrderHistoryDetailsSection()
            }
        }
    }
    
    // MARK: - ItemDetails Section
    
    /// 顯示飲品項目詳情（如名稱、數量、價格等）
    private static func createOrderHistoryItemDetailsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // MARK: - CustomerInfo Section
    
    /// 顯示顧客的姓名、電話等資訊
    private static func createOrderHistoryCustomerInfoSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let header = createSectionHeader()
        // 抵消 Section 的 contentInsets，讓 Header 寬度與整個 Collection View 對齊
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10)
        section.boundarySupplementaryItems = [header]
  
        return section
    }
    
    // MARK: - Details Section
    
    /// 顯示訂單的基本資訊（如訂單編號、時間、總金額等）
    private static func createOrderHistoryDetailsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 40, trailing: 10)

        let header = createSectionHeader()
        // 抵消 Section 的 contentInsets，讓 Header 寬度與整個 Collection View 對齊
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // MARK: - Section Header
    
    /// 建立 Section 的`標題`視圖
    private static func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        // 設置 header 的 contentInsets，確保 header 不受 Section contentInsets 的影響
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return header
    }
}
