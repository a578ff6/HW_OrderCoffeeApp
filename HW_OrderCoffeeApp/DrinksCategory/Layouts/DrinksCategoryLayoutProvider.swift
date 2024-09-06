//
//  DrinksCategoryLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/29.
//

/*
 ## generateWebsiteBannerLayout 和 generateGridLayout 的寫法差異：
 
 * DrinksCategoryLayoutProvider
    - 動態佈局： 這個佈局主要針對「飲品分類」頁面，允許用戶在網格佈局和列佈局之間進行動態切換。佈局會根據用戶的選擇來即時變化，展示方式更靈活。
    - generateGridLayout 和 generateColumnLayout： 為每個 section 設定不同的顯示方式。比如，網格佈局會在每個 section 中顯示兩列飲品，而列佈局則會每行顯示一個飲品。這樣的設計允許在同一個頁面中展示不同的佈局風格。
    - configureHeaderAndFooter： 為每個 section 添加 header 和 footer，並動態控制是否在最後一個 section 隱藏 footer，這樣可以避免在頁面的最後顯示不必要的分隔線。


 * MenuLayoutProvider
    - 固定佈局： 主要用於菜單頁面，包含「網站橫幅」和「飲品分類」這兩個區域。這些區域的佈局相對固定，不會隨用戶操作而改變。這樣的設計簡化了佈局的處理邏輯。
    - generateWebsiteBannerLayout： 專門為「網站橫幅」設計，允許橫向滾動。此佈局通常不需要隨用戶的動作切換，因此較為簡單且專注於網站橫幅的展示效果。
    - generateGridLayout：針對「飲品分類」區域設計的網格佈局，但與 DrinksCategoryLayoutProvider 的網格佈局不同，這裡是固定的，不會隨用戶動作動態變化。

 * 動態佈局 vs. 固定佈局：
    - DrinksCategoryLayoutProvider 需要考慮用戶動態切換佈局，因此使用 UICollectionViewCompositionalLayout 的閉包設計，讓每個 section 可以根據需要動態生成佈局。這使得它能夠更靈活地適應不同的佈局需求。
    - MenuLayoutProvider 則是針對固定的展示區域，沒有需要動態切換的需求，因此佈局設計較為簡單、直接。

 * 簡單比較：
    - DrinksCategoryLayoutProvider 主要針對動態佈局需求，為飲品分類頁面提供靈活的顯示方式，根據用戶選擇實時切換網格與列佈局。
    - MenuLayoutProvider 則專注於固定的佈局設計，針對菜單頁面的不同區域進行特定的展示，不需要用戶進行動態切換。

 --------------------------------------------------------------------------------------------------------------------------------
 
 ## DrinksCategoryLayoutProvider：
 
    - 根據用戶選擇的佈局模式（網格或列）來生成適當的佈局，用於顯示飲品的子類別及對應的飲品列表。
    - 使用 Compositional Layout 來簡化佈局的定義，特別是在處理 section header 和 footer 時非常方便。
    - 透過 NSCollectionLayoutSection 更容易定義每個 section 的外觀，並動態決定是否顯示 footer。
    - 根據選定的佈局模式，不同的區域有不同的佈局邏輯，例如網格佈局會顯示兩列飲品，而列佈局則會顯示單列飲品。
 
 * 佈局邏輯：
    - generateGridLayout：生成網格佈局，適合展示多個飲品。每個 section 包含兩列飲品，每個 item 占用一半的寬度。
    - generateColumnLayout：生成列佈局，適合垂直展示飲品。每個 section 只顯示單列，每行一個飲品。
    - configureHeaderAndFooter：為每個 section 添加 header，並根據 section 的位置動態決定是否添加 footer（避免最後一個 section 顯示 footer）。

 * 主要方法：
    - getLayout(for:totalSections:sectionIndex:)：根據當前的佈局模式（網格或列），選擇對應的佈局生成方法。透過 sectionIndex 動態控制每個 section 的佈局。
    - generateGridLayout(totalSections:sectionIndex:)：生成適合網格顯示的佈局，為每個 section 動態添加 header 和必要時的 footer。
    - generateColumnLayout(totalSections:sectionIndex:)：生成適合列顯示的佈局，垂直排列飲品，每個 section 同樣添加 header，並根據情況決定是否添加 footer。
    - configureHeaderAndFooter(for:totalSections:sectionIndex:)：負責設定每個 section 的 header 和 footer，header 用於顯示子類別標題，footer 只在必要時添加，作為分隔線，避免在最後一個 section 顯示 footer。
 
 * 使用上的特點：
    - NSCollectionLayoutSection 提供了便捷的方法來處理每個 section 的 header 和 footer，比傳統的 UICollectionViewLayout 更加直觀且可讀性高。
    - Compositional Layout 能夠輕鬆應對複雜的佈局需求，並支援動態配置，每個 section 都可以擁有自己的佈局風格。
    - 通過 sectionIndex 可以靈活地決定是否顯示 footer，特別是在避免最後一個 section 顯示分隔線的需求上很有幫助。
 
 --------------------------------------------------------------------------------------------------------------------------------

 ＃# UICollectionViewLayout 與 NSCollectionLayoutSection 的差異與特性 （與蘋果官方教材比較差異）

 * UICollectionViewLayout：
    - 用途： 是所有 UICollectionView 的佈局基礎類別，你可以自定義佈局來控制所有的 item 和 section 如何排列顯示。
    - 使用場景： 通常需要複雜的佈局控制，且開發者需要自己處理每個 section 和 item 的位置。它提供了靈活性，但相對複雜，因為需要自定義計算佈局邏輯。
    - 缺點： 如果需要處理像 section header/footer，或根據 section 動態調整佈局，開發者需要手動撰寫更多的程式碼來達成。

 * NSCollectionLayoutSection (iOS 13 引入的 Compositional Layout)
    - 用途： 專為簡化 UICollectionView 的佈局設計，讓開發者可以更直觀地描述每個 section 的佈局方式。
    - 使用場景： 當需要不同的 section 顯示方式（如 grid、list、橫向滑動等），或是需要自動處理 header/footer 時，Compositional Layout 提供了方便的方法。
    - 優點：
        1. 提供內建的配置選項，像是 section header/footer 或邊距設定，開發者不需要手動處理。
        2. 可以方便地針對不同的 section 設置不同的佈局。
        3. 避免最後一個 section 顯示 footer：可以直接在 `NSCollectionLayoutSection` 中，根據 section 索引來決定是否顯示 footer。
        4. 支援更複雜的佈局組合，像是網格佈局、列佈局、甚至橫向滑動的佈局，並且易於調整。

 * 總結
    - UICollectionViewLayout 提供了極大的自由度，但需要你自行處理所有佈局細節，適合高度自定義的需求。
    - NSCollectionLayoutSection 則更直觀易用，尤其在處理多個 section 時提供了很多便利功能，如自動處理 header/footer 和動態佈局設置，讓開發者更容易管理複雜佈局。

 */


// MARK: - 已完善

import UIKit

/// DrinksCategoryCollectionViewController 佈局使用
class DrinksCategoryLayoutProvider {
    
    /// 根據當前布局樣式生成對應的佈局。
    func getLayout(for layoutType: DrinksCategoryViewController.Layout, totalSections: Int, sectionIndex: Int) -> NSCollectionLayoutSection? {
        switch layoutType {
        case .grid:
            return generateGridLayout(totalSections: totalSections, sectionIndex: sectionIndex)
        case .column:
            return generateColumnLayout(totalSections: totalSections, sectionIndex: sectionIndex)
        }
    }
    
    /// 網格佈局
    private func generateGridLayout(totalSections: Int, sectionIndex: Int) -> NSCollectionLayoutSection {
        let padding: CGFloat = 10
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(260)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(260)), subitems: [item, item])
        
        group.interItemSpacing = .fixed(padding)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        
        // 傳入 totalSections 和 sectionIndex 來決定是否顯示 footer
        configureHeaderAndFooter(for: section, totalSections: totalSections, sectionIndex: sectionIndex)
        
        return section
    }
    
    /// 列佈局
    private func generateColumnLayout(totalSections: Int, sectionIndex: Int) -> NSCollectionLayoutSection {
        let padding: CGFloat = 10
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
        group.interItemSpacing = .fixed(padding)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        
        // 傳入 totalSections 和 sectionIndex 來決定是否顯示 footer
        configureHeaderAndFooter(for: section, totalSections: totalSections, sectionIndex: sectionIndex)
        
        return section
    }
    
    /// 負責為每個 section 添加 header 和 footer，header 用於顯示子類別標題，footer 僅在必要時添加，作為分隔線。
    func configureHeaderAndFooter(for section: NSCollectionLayoutSection, totalSections: Int, sectionIndex: Int) {
        // 配置 section header
        let headerSize =  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        // 只有在非最後一個 section 時才添加 footer
        if sectionIndex < totalSections - 1 {
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
            section.boundarySupplementaryItems.append(footer)
        }
    }
}



