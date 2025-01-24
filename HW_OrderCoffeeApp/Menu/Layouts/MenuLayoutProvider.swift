//
//  MenuLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/29.
//

// MARK: - MenuLayoutProvider 筆記
/**
 
 ## MenuLayoutProvider 筆記


 `* What`
 
 - `MenuLayoutProvider` 是一個專門為菜單頁面設計的佈局生成器，負責根據不同的區域（`MenuSection`）動態生成對應的 `UICollectionViewCompositionalLayout`。

 - 功能
 
 1. 佈局生成：
 
    - 根據傳入的 `MenuSection`，為每個區域生成對應的佈局。
    - 支援多種佈局形式，如橫向滾動的橫幅展示和網格形式的飲品分類。

 2. 標頭（Header）與分隔線（Footer）支持：
  
    - 自動為每個區域配置標頭（`header`），用於顯示區域標題。
    - 自動為每個區域配置底部分隔線（`footer`），用於區隔區域，並可設置額外間距提升視覺效果。

 3. 提升重用性：
 
    - 集中管理菜單頁面佈局邏輯，減少控制器中的重複程式碼。

 -----------

 `* Why`

 - 問題
 
 1. 佈局邏輯分散：
 
    - 如果在 `MenuViewController` 或 `MenuCollectionView` 中直接處理所有佈局邏輯，會導致責任過重，程式碼難以維護。

 2. 靈活性不足：
 
    - 直接硬編碼佈局會缺乏靈活性，無法輕鬆應對區域新增或佈局調整的需求。

 3. 重複性程式碼：
 
    - 多處定義佈局容易導致重複性程式碼，降低開發效率與可讀性。

 ---
 
 - 解決方式
 
 1. 集中佈局邏輯：
 
    - 將所有佈局生成邏輯集中到 `MenuLayoutProvider` 中，減少其他元件的責任。

 2. 提升靈活性：
 
    - 支援動態生成不同類型的佈局，方便新增區域或調整展示形式。

 3. 改善可維護性：
 
    - 集中管理的佈局邏輯能更清楚地反映整體設計意圖，提升程式碼的可讀性與擴展性。

 -----------

` * How`

 1. 初始化 `MenuLayoutProvider`
 
    - 在菜單頁面中，初始化 `MenuLayoutProvider` 並將其傳入 `MenuCollectionView` 或其他需要使用佈局的元件。

     ```swift
     let layoutProvider = MenuLayoutProvider()
     let menuCollectionView = MenuCollectionView(layoutProvider: layoutProvider)
     ```

 ---

 2. 使用動態佈局生成
 
    - `MenuLayoutProvider` 根據傳入的 `MenuSection` 動態生成佈局：

     ```swift
     let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
         guard let section = MenuSection(rawValue: sectionIndex) else { return nil }
         return layoutProvider.generateLayout(for: section)
     }
     ```

 ---

 3. 為不同區域配置佈局

 (1) 網站橫幅（`websiteBanner`）佈局
 
 - 特點：
    - 橫向分頁滾動。
    - 每個項目（`item`）佔滿整個組（`group`）。
    - 自動配置標頭（`header`）和底部分隔線（`footer`）。
    - 支援設置間距，提升區域的層次感。

     ```swift
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
         
         // Header
         let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
         let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
         header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)     // header 會向右移動 10 點，以補償 section 的 leading: -10
         
         // Footer
         let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(2)) // 設定 footer 高度為 2
         let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
         footer.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0) // 增加上下間隔
         
         section.boundarySupplementaryItems = [header, footer]
         return section
     }
     ```

 -----
 
 (2) 飲品分類（`drinkCategories`）佈局
 
    特點：
     - 兩列網格展示。
     - 每個項目高度根據內容自適應。
     - 適合展示多個分類項目。


     ```swift
     private func generateGridLayout() -> NSCollectionLayoutSection {
         let itemSize = NSCollectionLayoutSize(
             widthDimension: .fractionalWidth(0.5),
             heightDimension: .estimated(200)
         )
         let item = NSCollectionLayoutItem(layoutSize: itemSize)
         
         let groupSize = NSCollectionLayoutSize(
             widthDimension: .fractionalWidth(1.0),
             heightDimension: .estimated(200)
         )
         let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
         group.interItemSpacing = .fixed(10)
         
         let section = NSCollectionLayoutSection(group: group)
         section.interGroupSpacing = 10
         section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10)
         
         // 設置標頭
         let headerSize = NSCollectionLayoutSize(
             widthDimension: .fractionalWidth(1.0),
             heightDimension: .estimated(44)
         )
         let header = NSCollectionLayoutBoundarySupplementaryItem(
             layoutSize: headerSize,
             elementKind: UICollectionView.elementKindSectionHeader,
             alignment: .top
         )
         header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0)
         section.boundarySupplementaryItems = [header]
         return section
     }
     ```

 -----------

 `* 總結`

 - What：
 
    - `MenuLayoutProvider` 是一個為菜單頁面動態生成佈局的工具類，支援多種展示形式。
 
 - Why：
 
   - 集中管理佈局邏輯，提升可讀性與可維護性。
   - 提供靈活的佈局生成支持，適應未來需求變更。
 
 - How：
 
   - 初始化 `MenuLayoutProvider`，透過 `generateLayout(for:)` 動態生成對應區域的佈局。
   - 配置橫向滾動的橫幅展示和網格佈局的分類展示，滿足菜單頁面的多樣化需求。
 
 */



// MARK: - (v)


import UIKit

/// 負責根據不同的區域（section）生成對應的 `UICollectionView` 佈局。
///
/// 此類的設計目的是將菜單頁面的佈局邏輯集中管理，透過動態生成對應的佈局，
/// 適配不同的內容展示需求，例如「網站橫幅」與「飲品分類」區域。
///
/// - 功能:
///   1. 根據 `MenuSection` 提供對應的佈局生成邏輯，支援橫向滾動與網格布局。
///   2. 為每個區域配置標頭（header）以展示區域標題。
///   3. 為每個區域配置底部分隔線（footer）以區隔不同的區域。
///   4. 簡化 `UICollectionView` 的佈局設定，提高程式碼可維護性與擴展性。
///
/// - 使用場景:
///   適用於需根據區域類型（section）生成不同佈局的菜單頁面，例如展示網站橫幅（橫向滾動）
///   或飲品分類（網格布局）的內容。
class MenuLayoutProvider {
    
    // MARK: - Public Methods
    
    /// 根據傳入的區域（section）生成對應的 `NSCollectionLayoutSection`。
    ///
    /// - Parameter section: 代表菜單頁面中不同的區域類型，如「網站橫幅」或「飲品分類」。
    /// - Returns: 對應區域類型的 `NSCollectionLayoutSection`，用於設定 `UICollectionView` 的佈局。
    func generateLayout(for section: MenuSection) -> NSCollectionLayoutSection {
        switch section {
        case .websiteBanner:
            return generateWebsiteBannerLayout()
        case .drinkCategories:
            return generateGridLayout()
        }
    }
    
    // MARK: - Private Methods (Website Banner Layout)
    
    /// 為「網站橫幅」區域生成橫向滾動的佈局。
    ///
    /// 此佈局設計的特點包括：
    /// 1. 橫向分頁滾動，每個項目（item）佔滿整個組（group），適合展示全屏橫幅。
    /// 2. 添加標頭（header），用於展示區域標題，並調整內邊距提升視覺效果。
    /// 3. 添加底部分隔線（footer），用於區隔 section，並可設定額外的上下間距。
    ///
    /// - Returns: 用於網站橫幅區域的 `NSCollectionLayoutSection`。
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
        
        // Header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)     // header 會向右移動 10 點，以補償 section 的 leading: -10
        
        // Footer
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(2)) // 設定 footer 高度為 2
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        footer.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0) // 增加上下間隔
        
        section.boundarySupplementaryItems = [header, footer]
        return section
    }
    
    
    // MARK: - Private Methods (Drink Categories Layout)
    
    /// 為「飲品分類」區域生成網格佈局。
    ///
    /// 此佈局設計的特點包括：
    /// 1. 兩列網格展示，每個項目（item）的高度根據內容自適應。
    /// 2. 添加標頭（header），用於展示區域標題，並調整內邊距提升視覺效果。
    ///
    /// - Returns: 用於飲品分類區域的 `NSCollectionLayoutSection`。
    private func generateGridLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        // 設置列間距
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 20, trailing: 10)
        
        // Header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0)    // // header 會向右移動 10 點，以補償 section 的 leading: 10
        
        section.boundarySupplementaryItems = [header]
        return section
    }
    
}
