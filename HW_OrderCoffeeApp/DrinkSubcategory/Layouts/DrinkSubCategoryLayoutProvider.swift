//
//  DrinkSubCategoryLayoutProvider.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/29.
//


// MARK: - generateWebsiteBannerLayout 和 generateGridLayout 的寫法
/**
 
 ## generateWebsiteBannerLayout 和 generateGridLayout 的寫法差異：
 
 `* DrinkSubCategoryLayoutProvider`
 
 - 動態佈局：
 
    - 這個佈局主要針對「飲品分類」頁面，允許用戶在網格佈局和列佈局之間進行動態切換。佈局會根據用戶的選擇來即時變化，展示方式更靈活。
 
 - generateGridLayout 和 generateColumnLayout：
 
    - 為每個 section 設定不同的顯示方式。比如，網格佈局會在每個 section 中顯示兩列飲品，而列佈局則會每行顯示一個飲品。
    - 這樣的設計允許在同一個頁面中展示不同的佈局風格。
 
 - configureHeader、configureFooter：
 
    - 為每個 section 添加 header 和 footer，並動態控制是否在最後一個 section 隱藏 footer，這樣可以避免在頁面的最後顯示不必要的分隔線。

------
 
 `* MenuLayoutProvider`
 
 - 固定佈局：
 
    - 主要用於菜單頁面，包含「網站橫幅」和「飲品分類」這兩個區域。這些區域的佈局相對固定，不會隨用戶操作而改變。這樣的設計簡化了佈局的處理邏輯。
 
 - generateWebsiteBannerLayout：
 
    - 專門為「網站橫幅」設計，允許橫向滾動。此佈局通常不需要隨用戶的動作切換，因此較為簡單且專注於網站橫幅的展示效果。
 
 - generateGridLayout：
 
    - 針對「飲品分類」區域設計的網格佈局，但與 `DrinkSubCategoryLayoutProvider` 的網格佈局不同，這裡是固定的，不會隨用戶動作動態變化。

 ------

` * 動態佈局 vs. 固定佈局：`
 
    - `DrinkSubCategoryLayoutProvider` 需要考慮用戶動態切換佈局，因此使用 UICollectionViewCompositionalLayout 的閉包設計，讓每個 section 可以根據需要動態生成佈局。
    - `MenuLayoutProvider` 則是針對固定的展示區域，沒有需要動態切換的需求，因此佈局設計較為簡單、直接。

 ------

 * 簡單比較：
 
    - `DrinkSubCategoryLayoutProvider` 主要針對動態佈局需求，為飲品分類頁面提供靈活的顯示方式，根據用戶選擇實時切換網格與列佈局。
    - `MenuLayoutProvider` 則專注於固定的佈局設計，針對菜單頁面的不同區域進行特定的展示，不需要用戶進行動態切換。
 */


// MARK: - UICollectionViewLayout 與 NSCollectionLayoutSection 的差異與特性 （與蘋果官方教材比較差異）
/**
 
 ＃# UICollectionViewLayout 與 NSCollectionLayoutSection 的差異與特性 （與蘋果官方教材比較差異）

 `* UICollectionViewLayout：`
 
 - 用途：
 
    - 是所有 UICollectionView 的佈局基礎類別，你可以自定義佈局來控制所有的 item 和 section 如何排列顯示。
 
 - 使用場景：
 
    - 通常需要複雜的佈局控制，且開發者需要自己處理每個 section 和 item 的位置。它提供了靈活性，但相對複雜，因為需要自定義計算佈局邏輯。
 
 - 缺點：
 
    - 如果需要處理像 section header/footer，或根據 section 動態調整佈局，開發者需要手動撰寫更多的程式碼來達成。

 ----
 
 `* NSCollectionLayoutSection (iOS 13 引入的 Compositional Layout)`
 
 - 用途：
 
    - 專為簡化 UICollectionView 的佈局設計，讓開發者可以更直觀地描述每個 section 的佈局方式。
 
 - 使用場景：
 
    - 當需要不同的 section 顯示方式（如 grid、list、橫向滑動等），或是需要自動處理 header/footer 時，Compositional Layout 提供了方便的方法。

 - 優點：
 
    1. 提供內建的配置選項，像是 section header/footer 或邊距設定，開發者不需要手動處理。
    2. 可以方便地針對不同的 section 設置不同的佈局。
    3. 避免最後一個 section 顯示 footer：可以直接在 `NSCollectionLayoutSection` 中，根據 section 索引來決定是否顯示 footer。
    4. 支援更複雜的佈局組合，像是網格佈局、列佈局、甚至橫向滑動的佈局，並且易於調整。

 ----
 
 `* 總結`
 
    - `UICollectionViewLayout` 提供了極大的自由度，但需要你自行處理所有佈局細節，適合高度自定義的需求。
    - `NSCollectionLayoutSection` 則更直觀易用，尤其在處理多個 section 時提供了很多便利功能，如自動處理 header/footer 和動態佈局設置，讓開發者更容易管理複雜佈局。

 */


// MARK: - DrinkSubCategoryLayoutProvider 筆記
/**
 
 ## DrinkSubCategoryLayoutProvider 筆記

 ----------

 `* What`

 - `DrinkSubCategoryLayoutProvider` 是一個負責生成 `UICollectionView` 不同佈局的工具類別，主要應用於提供飲品子類別頁面中的列表（column）或網格（grid）顯示模式。
 - 它透過動態生成 `UICollectionViewCompositionalLayout`，根據需求設置 header、footer 和各種 cell 的佈局。

 ----------

 `* Why`

 1. 解耦佈局邏輯：
 
    將佈局生成從主控制器或視圖層中分離，使佈局邏輯獨立且更加模組化，便於測試和維護。

 2. 支援多樣佈局：
 
    滿足頁面展示需求的靈活性，讓頁面可在列表與網格之間切換，提供更好的用戶體驗。

 3. 簡化重複代碼：
 
    集中處理佈局生成，避免不同地方重複實現相似的邏輯，增強可重用性。

 4. 動態設置：
 
    支援依據 section 數量調整佈局配置，例如控制是否需要 footer，讓佈局更智能。

 ----------

 `* How`

 1. 設計架構：
 
    - 提供 `generateLayout(for:type:totalSections:)` 方法，根據傳入的佈局類型（`DrinkSubCategoryLayoutType`）和 section 總數，生成對應的 `UICollectionViewLayout`。
    - 提供私有方法 `generateColumnLayout` 和 `generateGridLayout`，分別處理列表和網格的佈局細節。
    - 動態配置每個 `NSCollectionLayoutSection` 的 header 和 footer。

 2. 使用情境：
 
    - 用於 `DrinkSubCategoryViewManager`，讓控制器根據用戶需求切換佈局。
    - 在初始化或切換佈局時，調用 `generateLayout(for:type:totalSections:)` 並應用到 `UICollectionView`。

 3. 關鍵方法與步驟：
 
    - 步驟 1：初始化佈局
 
      通過 `generateLayout` 根據初始佈局類型生成 `UICollectionViewLayout` 並應用。
 
    - 步驟 2：動態調整
 
      在切換佈局時，調用 `generateLayout` 並透過 `setCollectionViewLayout` 更新到視圖層。
 
    - 步驟 3：配置區域細節
      使用 `configureHeader` 和 `configureFooter`，確保每個 `section` 有適當的 header 和 footer。

 ----------

 `* 結論`

 - `DrinkSubCategoryLayoutProvider` 是一個遵循 單一責任原則 的設計，它專注於佈局生成，讓業務邏輯與視圖邏輯解耦。
 - 在項目中，它提高了代碼的可重用性與可測試性，對於未來添加新佈局需求時，能以最小的代價進行擴展。

 */




// MARK: - (v)

import UIKit


/// 提供飲品子類別的佈局生成功能
///
/// ### 設計目的
/// `DrinkSubCategoryLayoutProvider` 是專門處理 `UICollectionView` 佈局邏輯的工具類，
/// 負責根據不同的顯示需求（如網格佈局或列表佈局）生成對應的 `UICollectionViewLayout`。
/// 此類的目的是將佈局邏輯與業務邏輯解耦，使佈局生成的邏輯更加模組化和可測試。
///
/// ### 使用情境
/// - 當需要為 `UICollectionView` 提供不同類型的佈局（例如切換網格或列表）時使用。
/// - 與 `DrinkSubCategoryViewManager` 或其他視圖管理類結合，提供可重用的佈局生成邏輯。
///
/// ### 關鍵功能
/// - 根據指定的佈局類型生成對應的 `UICollectionViewLayout`。
/// - 提供針對每個 `section` 的動態配置，例如 header 和 footer 的設置。
class DrinkSubCategoryLayoutProvider {
    
    
    /// 生成指定類型的佈局
    ///
    /// ### 功能
    /// 根據指定的佈局類型（如網格或列表）和 `section` 數量，生成對應的 `UICollectionViewLayout`。
    ///
    /// ### 使用情境
    /// - 當 `UICollectionView` 的顯示需求需要切換佈局時，例如用戶從列表切換到網格顯示。
    /// - 配合 `UICollectionView` 的 `setCollectionViewLayout(_:animated:)` 方法，應用新的佈局。
    ///
    /// ### 參數
    /// - `type`: 佈局類型，表示為網格（grid）或列表（column）。
    /// - `totalSections`: section 的總數，用於動態設置每個 section 的配置（例如是否顯示 footer）。
    ///
    /// ### 回傳
    /// - `UICollectionViewLayout`: 根據指定類型和 section 數量生成的佈局。
    func generateLayout(for type: DrinkSubCategoryLayoutType, totalSections: Int) -> UICollectionViewLayout {
        print("[DrinkSubCategoryLayoutProvider]: Generating layout for type: \(type), Total Sections: \(totalSections)")
        
        switch type {
        case .column:
            return UICollectionViewCompositionalLayout { sectionIndex, _ in
                let isLastSection = sectionIndex == totalSections - 1
                return self.generateColumnLayout(isLastSection: isLastSection)
            }
        case .grid:
            return UICollectionViewCompositionalLayout { sectionIndex, _ in
                let isLastSection = sectionIndex == totalSections - 1
                return self.generateGridLayout(isLastSection: isLastSection)
            }
        }
    }
    
    
    // MARK: - Private Methods
    
    /// 生成列表佈局
    ///
    /// ### 功能
    /// 為列表型佈局生成 `NSCollectionLayoutSection`，適合顯示單列垂直列表的情境。
    ///
    /// ### 使用情境
    /// - 當用戶選擇列表顯示模式時，生成對應的 section 配置。
    ///
    /// ### 參數
    /// - `isLastSection`: 是否為最後一個 section，影響 footer 的顯示。
    ///
    /// ### 回傳
    /// - `NSCollectionLayoutSection`: 列表佈局的 section。
    private func generateColumnLayout(isLastSection: Bool) -> NSCollectionLayoutSection {
        let padding: CGFloat = 10
        let cellHeight: CGFloat = 100
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(cellHeight)
        ))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cellHeight)
            ),
            subitems: [item]
        )
        group.interItemSpacing = .fixed(padding)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: 20, trailing: padding)
        
        configureHeader(for: section)
        configureFooter(for: section, show: !isLastSection)
        return section
    }
    
    
    /// 生成網格佈局
    ///
    /// ### 功能
    /// 為網格型佈局生成 `NSCollectionLayoutSection`，適合顯示多列網格的情境。
    ///
    /// ### 使用情境
    /// - 當用戶選擇網格顯示模式時，生成對應的 section 配置。
    ///
    /// ### 參數
    /// - `isLastSection`: 是否為最後一個 section，影響 footer 的顯示。
    ///
    /// ### 回傳
    /// - `NSCollectionLayoutSection`: 網格佈局的 section。
    private func generateGridLayout(isLastSection: Bool) -> NSCollectionLayoutSection {
        let padding: CGFloat = 10
        let cellHeight: CGFloat = 260
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(cellHeight)
        ))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cellHeight)
            ),
            subitems: [item, item]
        )
        group.interItemSpacing = .fixed(padding)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: 20, trailing: padding)
        
        configureHeader(for: section)
        configureFooter(for: section, show: !isLastSection)
        return section
    }
    
    /// 配置 section header
    ///
    /// ### 功能
    /// 為 `NSCollectionLayoutSection` 添加 header 配置。
    ///
    /// ### 使用情境
    /// - 當需要為每個 section 添加標題時使用。
    ///
    /// ### 參數
    /// - `section`: 要配置 header 的 `NSCollectionLayoutSection`。
    private func configureHeader(for section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems.append(header)
    }
    
    /// 配置 section footer
    ///
    /// ### 功能
    /// 為 `NSCollectionLayoutSection` 添加 footer 配置。
    ///
    /// ### 使用情境
    /// - 當需要為每個 section 添加分隔線或其他底部標識時使用。
    ///
    /// ### 參數
    /// - `section`: 要配置 footer 的 `NSCollectionLayoutSection`。
    /// - `show`: 是否顯示 footer。
    private func configureFooter(for section: NSCollectionLayoutSection, show: Bool) {
        guard show else { return }
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(1)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        section.boundarySupplementaryItems.append(footer)
    }
    
}
