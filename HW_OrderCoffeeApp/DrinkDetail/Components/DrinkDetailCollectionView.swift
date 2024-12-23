//
//  DrinkDetailCollectionView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/17.
//

// MARK: - 筆記：iOS 複雜佈局設計模式
/**
 
 ## 筆記：iOS 複雜佈局設計模式
 
 `1. 使用 Compositional Layout（方法一）`
 
 `特點：`

 - 使用 UICollectionViewCompositionalLayout 和 sectionProvider，根據 Section 動態生成不同 Layout。
 - 支援多樣化與複雜佈局，提升可讀性與擴展性。
 
 `優勢：`

 - 符合 iOS 13+ Apple 官方建議，是現代化的解決方案。
 - 適合多 Section、動態變化的頁面，例如商店頁面、詳情頁面、儀表板等。
 - 邏輯分離：各 Section 的 Layout 設計與 UI 分離，符合 單一責任原則 (SRP) 和 組件化設計。
 
 `適用場景：`

 - 畫面包含多個 Section，每個 Section 的佈局不同。
 - 需要高度自定義與複雜的排列邏輯。
 
 ------------------------
 
` 2. 使用 Flow Layout + 自訂 Layout（傳統方式）`
 
 `特點：`

 - 使用 UICollectionViewFlowLayout 或自訂繼承 UICollectionViewLayout，手動計算 Item 與 Section 位置。
 
 `優勢：`

 - 彈性高：完全自定義佈局邏輯。
 - 兼容 iOS 12 以下系統，適合向後兼容需求。
 
 `缺點：`

 - 維護成本高：需手動計算尺寸與位置，佈局邏輯容易變得複雜。
 - 不易擴展或重構。
 
 `適用場景：`

 - 需要高度自定義佈局且 Compositional Layout 無法滿足需求時。
 - 專案需要支援 iOS 12 或更低版本。
 
 ------------------------

 `3. 使用 Diffable Data Source 搭配 Compositional Layout`
 
 `特點：`

 - UICollectionViewDiffableDataSource 管理資料更新，UICollectionViewCompositionalLayout 處理複雜佈局。
 
 `優勢：`

 - DiffableDataSource 提供高效、一致的資料管理邏輯。
 - 簡化 Section 和 Item 的動態更新操作。
 
 `適用場景：`

 - 資料和 UI 頻繁變動，例如動態增刪項目或重新排序。
 - 需要複雜佈局且同時有高效的資料管理。
 
 ------------------------

 `4. 將 Layout 和 UI 邏輯抽離成專屬類別（模組化設計）`
 
 `特點：`

 - 將 Layout 邏輯獨立封裝成 LayoutProvider 類別，配合自訂 UICollectionView 子類別使用。
 
 `優勢：`

 - 依賴注入 和 模組化設計，提高程式碼的可讀性與可測試性。
 - 簡化 ViewController，使其專注於業務邏輯而非佈局細節。
 - 易於維護與擴展，符合 單一責任原則 (SRP)。
 
 `適用場景：`

 - 當專案包含複雜的佈局邏輯時，透過模組化設計降低耦合度。
 - 多個頁面共享相同的 LayoutProvider 或佈局邏輯。
 
 ------------------------

 `5. 使用 SwiftUI`
 
 `特點：`

 - 提供聲明式語法，快速構建 UI。
 - 使用 LazyVGrid、LazyHGrid 等組件支援自定義佈局。
 
 `優勢：`

 - 簡潔語法：大幅減少程式碼量，提高開發效率。
 - 符合現代 iOS 設計趨勢，逐步取代 UIKit。
 
 `適用場景：`

 - 開發全新專案，支援 iOS 14 以上版本。
 - 需要快速開發與靈活調整的複雜佈局。
 
 ------------------------
 
 `* 結論：面向 iOS 的設計模式選擇`
 
 1.現代化解決方案：

 - 使用 Compositional Layout 是最佳選擇，提供高度彈性、易維護且符合 Apple 推薦的設計模式。
 
 2.向後兼容需求：

 - 若專案需支援 iOS 12 以下，使用 Flow Layout 或自訂 UICollectionViewLayout 是更合適的方案。
 
 3.模組化設計：

 - 將 Layout 和 UI 邏輯 抽離至獨立類別，配合 LayoutProvider 和 UICollectionView 子類別，降低耦合度並提高可測試性。
 
 4.未來趨勢：

 - 如果專案支援 SwiftUI，考慮使用 SwiftUI 來簡化複雜佈局並快速開發，符合 Apple 長遠技術走向。
 
 ------------------------

 `* 建議`
 
 - 複雜佈局 + 現代化設計：使用 Compositional Layout + LayoutProvider 是最推薦且易於維護的選擇。
 - 兼容性考量：Flow Layout 仍適用於支援舊版 iOS 的專案。
 - 未來趨勢：新專案逐步導入 SwiftUI，適應聲明式語法和未來技術方向。
 */



// MARK: - 筆記 DrinkDetailCollectionView
/**
 
 ## 筆記：DrinkDetailCollectionView
 
 `* What`
 
 - `DrinkDetailCollectionView` 是一個自訂的 `UICollectionView`，用於飲品詳細資訊頁面。

 1.它使用 `Compositional Layout` 動態產生每個 Section 的佈局。
 2.藉由注入 `DrinkDetailLayoutProvider`，可以根據 Section 類型提供對應的佈局邏輯。
 
 --------------
 
 `* Why`

 1.`現代化設計`：Compositional Layout 專門處理複雜佈局。
 
 2.`責任分離`：透過 `DrinkDetailLayoutProvider` 將佈局邏輯與 `UICollectionView` 的基本配置分離，符合單一職責原則 (SRP)。
 
 3.`高度擴展性`：當需要新增 `Section` 或變更 `Section` 佈局時，只需修改 LayoutProvider，不影響 UICollectionView 本身。
 
 4.`重複使用性`：這個設計模式可以將 `DrinkDetailCollectionView` 輕鬆套用至其他類似的多 Section 頁面。
 
 --------------

 `* How`

` 1.使用 Compositional Layout 提供動態佈局`
 
 - 使用 `UICollectionViewCompositionalLayout`，透過 `sectionProvider` 動態生成每個 Section 的佈局。
 - 在 init 方法中，注入 `DrinkDetailLayoutProvider` 來定義不同 Section 的排列邏輯。
 
 `2.封裝基本屬性配置`
 
 - 設定 `UICollectionView` 的背景顏色、滾動條屬性等基本配置，確保符合設計需求。
 
 `3.使用外部 LayoutProvider`
 
 - 透過 `DrinkDetailLayoutProvider` 生成對應的 `Layout`：
 
 ```swift
 let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
     guard let section = DrinkDetailViewController.Section(rawValue: sectionIndex) else { return nil }
     return layoutProvider.generateLayout(for: section)
 }
 ```

 - `DrinkDetailCollectionView` 負責初始化與設定 UICollectionView。
 - `DrinkDetailLayoutProvider` 負責根據 Section 回傳對應的佈局。
 - 動態顯示多個 `Section`：例如圖片、尺寸選擇、價格資訊等。
 
 --------------

 `* 結論：面向 iOS 設計模式`
 
 1.使用 `Compositional Layout` 結合 `LayoutProvider` 是符合 現代 iOS 開發 的設計模式。
 
 2.遵循 `責任分離` 和 `單一職責原則`，使程式碼更易於擴展與維護。
 
 3.`DrinkDetailCollectionView` 設計簡潔，對外提供可注入的 `LayoutProvider`，達到高度的重複使用性與彈性。
 
 4.在處理複雜佈局時，這樣的設計是最佳實踐，適合需要多個不同 Section 的頁面。
 */


// MARK: - (v)

import UIKit

/// 自訂的 UICollectionView，專門用於飲品詳細資訊頁面。
///
/// 此類別負責初始化並配置 `UICollectionView`，透過 `DrinkDetailLayoutProvider` 提供動態生成的 `Compositional Layout`，
/// 適合顯示多個 Section 具有不同佈局的複雜資訊，例如飲品圖片、尺寸選擇、價格資訊等。
class DrinkDetailCollectionView: UICollectionView {
    
    // MARK: - Initializer
    
    /// 初始化自訂的 UICollectionView
    /// - Parameter layoutProvider: 提供 Layout 的類別，根據 Section 動態生成 Compositional Layout
    init(layoutProvider: DrinkDetailLayoutProvider) {
        
        // 使用 Compositional Layout 根據 Section 提供對應的佈局
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = DrinkDetailSection(rawValue: sectionIndex) else { return nil }
            return layoutProvider.generateLayout(for: section)
        }
        super.init(frame: .zero, collectionViewLayout: layout)
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 UICollectionView 的基本屬性
    ///
    /// 包括背景顏色、是否顯示垂直滾動條等，確保介面符合頁面設計需求。
    private func configureCollectionView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
        self.showsVerticalScrollIndicator = true
    }
    
}
