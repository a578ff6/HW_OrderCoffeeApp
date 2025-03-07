//
//  OrderItemLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/4.
//

// MARK: - OrderItemLayoutProvider 筆記
/**
 
 ## OrderItemLayoutProvider 筆記：
 
 `* 概述：`
 
    - OrderItemLayoutProvider 負責為 OrderItemViewController 提供 UICollectionViewCompositionalLayout 佈局，將訂單的顯示內容劃分為不同區段，分別呈現訂單項目及訂單總結。
    - 透過 UICollectionViewCompositionalLayout 的使用，定義每個區段的佈局，並提供標題（header）來分隔區域。
 
 `* 佈局邏輯：`
 
    - createOrderItemsSection： 負責設置訂單項目的佈局，每個區塊會展示單個訂單項目，並配置上下的內容間距。
    - createSummarySection： 展示訂單總結的區域，通常用於顯示訂單的總金額和準備時間，該區域的高度是可估算的，並可以根據內容動態調整。
    - createOrderActionButtonsSection： 新增的操作按鈕區域，用於顯示「繼續」和「清空訂單」按鈕，為使用者提供操作選項。區域高度根據按鈕大小動態調整。
    - createSectionHeader： 設置每個區段的標題區域（header），用於顯示對應區段的標題，如 "訂單飲品項目" 或 "訂單詳情"。

 `* 主要方法：`
 
    - createLayout()： 根據不同的 sectionIndex，返回對應的佈局。該方法是 UICollectionViewCompositionalLayout 的核心入口，負責在不同的區段之間進行佈局切換。
    - createOrderItemsSection()： 為訂單項目區域設置橫向佈局，每個訂單項目在一行展示，並設定每個區段的內邊距（contentInsets）來保持適當的間距。
    - createSummarySection()： 為訂單總結區域設置佈局，內容垂直排列，並根據總結內容的長度動態調整高度。
    - createOrderActionButtonsSection()： 新增操作按鈕區域的佈局，垂直排列兩個按鈕（「繼續」和「清空訂單」），設置適當的上下邊距，方便使用者操作。
    - createSectionHeader()： 生成區段的標題部分，根據區域不同顯示對應的標題，如 "訂單飲品項目" 或 "訂單詳情"。
 
 `* 特點：`
 
    - 使用 UICollectionViewCompositionalLayout，靈活應對複雜的佈局需求，尤其在處理不同區段時，可以輕鬆自訂區域的外觀和佈局邏輯。
    - NSCollectionLayoutSection 和 NSCollectionLayoutGroup 提供了便捷的工具來定義每個區段的顯示方式，讓佈局的定義更加直觀。
    - 使用 createSectionHeader()，可以在每個區段添加標題，增強 UI 的可讀性與結構化。
    - 新增的 createOrderActionButtonsSection() 提供了方便的用戶操作界面，按鈕位於單獨的區段中，為使用者提供更清晰的操作引導，使整體佈局更加易於理解和操作。
 */


import UIKit

/// `OrderItemLayoutProvider` 負責為 `OrderItemHandler` 提供 `UICollectionViewCompositionalLayout` 佈局
class OrderItemLayoutProvider {

    // MARK: - Layout Creation

    /// 提供 `UICollectionViewCompositionalLayout` 的佈局方法
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionType = OrderItemHandler.Section(rawValue: sectionIndex) else { return nil }
            switch sectionType {
            case .orderItems:
                return createOrderItemsSection()
            case .summary:
                return createSummarySection()
            case .actionButtons:
                return createOrderActionButtonsSection()
            }
        }
    }
    
    // MARK: - Order Items Layout

    /// 建立`訂單項目`佈局
    private static func createOrderItemsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    // MARK: - Order Summary Layout

    /// 創建`訂單總結`佈局
    private static func createSummarySection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    // MARK: - Order Action Buttons Layout

    /// 創建`按鈕`佈局
    private static func createOrderActionButtonsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130)), subitems: [item])
        let secion = NSCollectionLayoutSection(group: group)
        secion.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 40, trailing: 0)
        return secion
    }
    
    // MARK: - Section Header

    /// 建立 Section 的`標題`視圖
    private static func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return header
    }
    
}
