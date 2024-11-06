//
//  OrderConfirmationLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

// MARK: - UICollectionView Section Header Alignment Issue & Solution
/**
 ## UICollectionView Section Header Alignment Issue & Solution
 
 - 在 `OrderConfirmationLayoutProvider` 中設計 `UICollectionViewCompositionalLayout` 的過程中，遇到了 `Section Header `與 `Section Cell` 不對齊的問題。
 - 具體來說，`createCustomerInfoSection` 的 `Section Header `沒有與 `OrderConfirmationCustomerInfoCell` 的內容部分保持對齊，導致顯示效果不理想。
 
 `問題描述`

 `* Section Header 與 Section Cell 不對齊：`
    - `createCustomerInfoSection` 設置了` section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)`，導致 Cell 內容左右有內縮。
    - 但 Section Header 同樣受此影響，沒有與整體對齊，顯得不協調。
 
 `解決方案`

    - 通過設置` Section Header` 本身的 `contentInsets`，確保 `Header` 不受 `Section` 的內縮設置影響，從而保持與整體對齊。
 */

import UIKit

/// `OrderConfirmationLayoutProvider` 負責為 `OrderConfirmationHandler` 提供佈局
class OrderConfirmationLayoutProvider {
    
    // MARK: - Layout Creation
    
    /// 提供 `UICollectionViewCompositionalLayout` 的佈局方法
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionType = OrderConfirmationHandler.Section(rawValue: sectionIndex) else { return nil }
            switch sectionType {
            case .checkMark:
                return createCheckMarkSection()
            case .message:
                return createMessageSection()
            case .itemDetails:
                return createItemDetailsSection()
            case .customerInfo:
                return createCustomerInfoSection()
            case .details:
                return createDetailsSection()
            case .closeButton:
                return createCloseButtonSection()
            }
        }
    }
    
    // MARK: - Checkmark Section
    
    /// 顯示打勾圖示
    private static func createCheckMarkSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200)))    // 寬高相同
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    // MARK: - Message Section
    
    /// 顯示成功提交的提示訊息
    private static func createMessageSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        return section
    }
    
    // MARK: - ItemDetails Section
    
    /// 顯示飲品項目詳情（如名稱、數量、價格等）
    private static func createItemDetailsSection() -> NSCollectionLayoutSection {
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
    private static func createCustomerInfoSection() -> NSCollectionLayoutSection {
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
    private static func createDetailsSection() -> NSCollectionLayoutSection {
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
    
    // MARK: - CloseButton Section
    
    /// 包含 "關閉" 按鈕，讓用戶確認後返回。
    private static func createCloseButtonSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
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
