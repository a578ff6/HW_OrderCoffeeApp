//
//  MenuCollectionView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/21.
//


// MARK: - MenuCollectionView 筆記
/**
 
 ## MenuCollectionView 筆記


 `* Wha`
 
 - `MenuCollectionView` 是一個自訂的 `UICollectionView`，專門為菜單頁面設計，負責展示不同的區域內容，例如網站橫幅和飲品分類。

 - 功能
 
 1. 封裝佈局邏輯：
 
    - 使用 `MenuLayoutProvider` 動態生成 `UICollectionViewCompositionalLayout`，根據區域類型（`MenuSection`）提供對應的佈局。
    
 2. 簡化屬性配置：
 
    - 預設背景顏色為系統背景色（`systemBackground`）。
    - 開啟垂直滾動條顯示（`showsVerticalScrollIndicator`）。

 3. 可重用設計：
 
    - 提供統一的初始化接口，只需傳入 `MenuLayoutProvider` 即可應用於不同的場景。

 --------------

 `* Why`

 - 問題
 
 1. 佈局邏輯分散：
 
    - 如果在控制器中直接設定 `UICollectionView` 的佈局，會增加控制器的責任，導致難以維護和測試。

 2. 多處重複配置：
 
    - 各類 `UICollectionView` 初始化和屬性設置（如背景色、滾動條）可能重複，增加程式碼冗餘。

 3. 難以重用與擴展：
 
    - 若需要在其他頁面重用類似的 `UICollectionView`，未封裝的設計將導致重複實現。

 ---
 
 - 解決方式
 
 1. 責任分離：
 
    - 將 `UICollectionView` 的佈局生成與初始化邏輯從控制器抽離，讓控制器專注於資料處理與導航邏輯。

 2. 提高可讀性與維護性：
 
    - 統一配置方法，例如背景色與滾動條行為，使程式碼更具一致性與可讀性。

 3. 支援重用與擴展：
 
    - 提供動態佈局生成的能力，能輕鬆適配不同的頁面需求。

 --------------

 `* How`

 1. 初始化與配置
 
    - 使用時，只需傳入 `MenuLayoutProvider` 實例來生成對應的佈局。

     ```swift
     let layoutProvider = MenuLayoutProvider()
     let menuCollectionView = MenuCollectionView(layoutProvider: layoutProvider)
     ```

 ----
 
 2. 動態生成佈局
 
    - `MenuCollectionView` 使用 `MenuLayoutProvider` 為每個區域（`MenuSection`）生成適合的佈局。

     ```swift
     let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
         guard let section = MenuSection(rawValue: sectionIndex) else { return nil }
         return layoutProvider.generateLayout(for: section)
     }
     ```

 ----

 3. 添加到主視圖
 
    - `MenuCollectionView` 通常作為 `MenuView` 的子視圖，通過 Auto Layout 設置其位置與大小。

     ```swift
     private func setupView() {
         addSubview(menuCollectionView)
         NSLayoutConstraint.activate([
             menuCollectionView.topAnchor.constraint(equalTo: topAnchor),
             menuCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
             menuCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
             menuCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
         ])
     }
     ```

 ---

 `* 總結`

 - What：
 
    - `MenuCollectionView` 是專為菜單頁面設計的自訂 `UICollectionView`，封裝了動態佈局生成與屬性配置邏輯。
 
 - Why：
 
   - 解耦佈局邏輯與控制器，提升程式碼的維護性與重用性。
   - 簡化常見屬性的配置，減少程式碼冗餘。
 
 - How：
 
   - 初始化時傳入 `MenuLayoutProvider`，透過動態生成佈局展示不同的區域內容。
   - 作為 `MenuView` 的子視圖，使用 Auto Layout 設定其位置與大小。
 */



// MARK: - (v)

import UIKit

/// 自訂的 `UICollectionView`，專門用於菜單頁面。
///
/// 此類的設計目的為解耦菜單頁面的 `UICollectionView` 邏輯，
///
/// - 特點:
///   1. 使用 `MenuLayoutProvider` 根據不同的 section 動態生成對應的佈局。
///   2. 預設背景顏色與滾動條顯示行為。
///   3. 提供統一的初始化接口，讓外部只需提供 `MenuLayoutProvider` 即可。
///
/// - 使用場景:
///   適用於展示菜單頁面的內容，例如「網站橫幅」與「飲品分類」，
///   每個區域可通過 `MenuSection` 管理其顯示邏輯與佈局。
class MenuCollectionView: UICollectionView {
    
    
    // MARK: - Initializer
    
    /// 初始化 `MenuCollectionView`
    ///
    /// - Parameter layoutProvider: 負責生成不同 section 對應的佈局物件。
    ///   預期傳入實例為 `MenuLayoutProvider`，可根據需求擴展為其他佈局提供者。
    init(layoutProvider: MenuLayoutProvider) {
        
        // 使用 `MenuLayoutProvider` 動態生成 Compositional Layout
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = MenuSection(rawValue: sectionIndex) else { return nil }
            return layoutProvider.generateLayout(for: section)
        }
        
        // 初始化 UICollectionView 並設定佈局
        super.init(frame: .zero, collectionViewLayout: layout)
        configureCollectionView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 UICollectionView 的基本屬性
    ///
    /// 此方法設置 `UICollectionView` 的預設外觀與行為：
    /// - 背景顏色為 `systemBackground`。
    /// - 開啟垂直滾動條顯示。
    /// - 關閉 Auto Layout 的自動尺寸調整。
    private func configureCollectionView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
        self.showsVerticalScrollIndicator = true
    }
    
}
