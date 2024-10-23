//
//  OrderCustomerDetailsLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/10.
//

import UIKit

/// `OrderCustomerDetailsLayoutProvider` 負責為 `OrderCustomerDetailsHandler` 提供佈局
class OrderCustomerDetailsLayoutProvider {
    
    // MARK: - Layout Creation

    /// 提供 `UICollectionViewCompositionalLayout` 的佈局方法
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionType = OrderCustomerDetailsHandler.Section(rawValue: sectionIndex) else { return nil }
            switch sectionType {
            case .orderTerm:
                return createOrderTermsMessageSection()
            case .customerInfo:
                return createCustomerInfoSection()
            case .pickupMethod:
                return createPickupMethodSection()
            case .notes:
                return createNotesSection()
            case .submitAction:
                return createSubmitActionSection()
            }
        }
    }
    
    // MARK: - OrderTerm Section

    /// 創建`訂單規範訊息`的佈局
    private static func createOrderTermsMessageSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0)
        return section
    }
    
    // MARK: - CustomerInfoSection
    
    /// 創建訂單`姓名、電話`佈局
    private static func createCustomerInfoSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0)

        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    // MARK: - PickupMethodSection

    /// 創建`取件方式`的佈局
    private static func createPickupMethodSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)), subitems: [item])
        let secion = NSCollectionLayoutSection(group: group)
        secion.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        
        secion.boundarySupplementaryItems = [createSectionHeader()]
        return secion
    }
    
    // MARK: - NoteSection
    
    /// 創建`備註`的佈局
    private static func createNotesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(280)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(280)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    // MARK: - SubmitActionSection
    
    /// 創建`提交訂單按鈕`的佈局
    private static func createSubmitActionSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(85)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(85)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        return section
    }

    // MARK: - Section Header

    /// 建立 Section 的`標題`視圖
    private static func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return header
    }
    
}
