//
//  FavoritesLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/21.
//

/*
 https://reurl.cc/dypEky

 ## Compositional Layout
    - 它相對於之前的 `UICollectionViewFlowLayout` 具有更強的靈活性和可配置性，尤其適用於複雜的多樣佈局。

 &.主要特點：

    1. 高度靈活：
        - 可以非常細緻地控制每個 `item`、`group` 和 `section` 的大小和排列，從而實現各種複雜的佈局。
        - 不同的 section 可以有不同的佈局樣式，讓 UI 顯得更豐富。

    2. 動態配置：
        - Compositional Layout 支持基於環境條件的佈局變化，比如螢幕大小或方向改變時，可以自動調整佈局。

    3. 結構化：
        - 它使用 `item`、`group` 和 `section` 這樣的分層結構來定義佈局，讓開發者更容易理解和設計出複雜的頁面。

    4. 性能優化：
        - Compositional Layout 是針對效能優化過的，能夠有效處理大型的資料集和複雜的佈局。

 &. 典型應用場景：
    * 動態內容展示：
        - 例如同時展示不同大小的圖片、標題、卡片等（類似 Instagram、Pinterest 等應用）。
    * 多樣化的佈局需求：
        - 比如網格佈局和列表佈局混合顯示的場景，不同 section 之間的顯示風格各異。
    * 多列佈局：
        - 在 iPad 或大螢幕設備上，可以根據屏幕的寬度動態改變列數。

 &. Compositional Layout 相較於 Flow Layout 的優勢：
    * 更多控制權：
        - 開發者可以自定義每個 item、group 和 section 的佈局方式，而不是只依賴於簡單的垂直或水平排列。
 
    * 簡化複雜佈局的開發：
        - 以前在 `Flow Layout` 中需要大量的計算和自訂邏輯，而現在可以用 `Compositional Layout` 直接通過配置來完成。

 &.總結：
    - Compositional Layout 提供了強大的靈活性和可擴展性。如果你的應用需要展示複雜的佈局樣式，Compositional Layout 會是很好的選擇。
    - 在簡單的佈局場景下，仍可以選擇使用 `Flow Layout`。
 */


import UIKit

/// 提供`我的最愛頁面`的佈局設置
class FavoritesLayoutProvider {
    
    /// 建立 `NSCollectionLayoutSection` 作為 UICollectionView 的佈局
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            return createFavoritesLayoutSection()
        }
    }
    
    /// 定義`我的最愛頁面`的佈局
    private static func createFavoritesLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        // 添加 section header
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    /// 創建 section header
    private static func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return header
    }
    
}

