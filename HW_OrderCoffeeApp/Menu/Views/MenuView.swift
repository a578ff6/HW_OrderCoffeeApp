//
//  MenuView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//

// MARK: - MenuView 筆記
/**
 
 ## MenuView 筆記


 `* What`
 
 - `MenuView` 是菜單頁面的主要視圖，負責定義菜單頁面的核心 UI 結構，包括 `UICollectionView`（`MenuCollectionView`）的配置與初始化。

 #### 功能
 
 1. 視圖結構管理：
 
    - 將菜單頁面的主要顯示邏輯封裝到 `MenuCollectionView` 中，分離 UI 與控制器邏輯。
    
 2. 動態佈局支持：
 
    - 使用 `MenuLayoutProvider` 為 `MenuCollectionView` 提供動態佈局支持，適配不同區域（如網站橫幅與飲品分類）。

 3. 元件註冊與配置：
 
    - 集中管理 `UICollectionViewCell` 和 `UICollectionReusableView` 的註冊，確保顯示所需的元件已正確配置。

 ---

 `* Why`

 - 問題
 
 1. 控制器責任過多：
 
    - 如果在控制器中同時處理資料邏輯、導航與視圖管理，會導致責任模糊，降低可讀性與可維護性。

 2. 視圖邏輯分散：
 
    - 若視圖配置（如 `UICollectionView` 的佈局與元件註冊）分散於多處，會增加程式碼冗餘，難以擴展。

 ----
 
 - 解決方式
 
 1. 責任分離：
 
    - 將菜單頁面的 UI 結構集中於 `MenuView`，控制器只需專注於資料處理與導航邏輯。

 2. 提升可維護性：
 
    - 集中配置 `UICollectionView` 的初始化、佈局與元件註冊，減少程式碼重複。

 3. 支持靈活擴展：
 
    - 透過依賴注入（如 `MenuLayoutProvider`）動態配置佈局，能輕鬆適配不同的頁面需求。

 ---

 `* How`

 1. 初始化與配置
 
    - `MenuView` 初始化時，會自動生成 `MenuCollectionView` 並配置其佈局。

     ```swift
     let menuLayoutProvider = MenuLayoutProvider()
     let menuView = MenuView(layoutProvider: menuLayoutProvider)
     ```

 ---

 2. 添加到控制器的視圖層級
 
    - 將 `MenuView` 設定為控制器的主要視圖：

     ```swift
     class MenuViewController: UIViewController {
         override func loadView() {
             self.view = MenuView()
         }
     }
     ```

 ---

 3. 配置與註冊元件
 
    - `MenuView` 內部會自動註冊所需的 `UICollectionViewCell` 與 `UICollectionReusableView`，無需額外手動註冊：

     ```swift
     private func registerCells() {
         menuCollectionView.register(MenuWebsiteBannerImageCell.self, forCellWithReuseIdentifier: MenuWebsiteBannerImageCell.reuseIdentifier)
         menuCollectionView.register(MenuDrinkCategoryCell.self, forCellWithReuseIdentifier: MenuDrinkCategoryCell.reuseIdentifier)
         menuCollectionView.register(MenuSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MenuSectionHeaderView.headerIdentifier)
         menuCollectionView.register(MenuSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: MenuSectionFooterView.footerIdentifier)
     }
     ```

 ---

 4. 自訂佈局擴展
 
    - 如果需要新增其他區域，只需在 `MenuLayoutProvider` 添加對應的佈局邏輯，無需修改 `MenuView`：

     ```swift
     enum MenuSection: Int, CaseIterable {
         case websiteBanner
         case drinkCategories
         case recommendedDrinks // 新增推薦飲品區
     }

     func generateLayout(for section: MenuSection) -> NSCollectionLayoutSection {
         switch section {
         case .websiteBanner:
             return generateWebsiteBannerLayout()
         case .drinkCategories:
             return generateGridLayout()
         case .recommendedDrinks:
             return generateRecommendedLayout() // 新增佈局生成方法
         }
     }
     ```

 ---

 `* 設計優勢`

 1. 視圖與邏輯分離：
 
    - 控制器專注於資料處理，視圖管理交由 `MenuView`，提高程式的模組化程度。

 2. 降低耦合度：
 
    - `MenuView` 通過依賴 `MenuLayoutProvider` 動態配置佈局，減少與特定頁面的耦合。

 3. 易於擴展與測試：
 
    - 透過集中管理元件註冊與佈局生成邏輯，能輕鬆應對需求變更，並提升單元測試的覆蓋範圍。

 ---

 `* 總結`

 - What：
 
    - `MenuView` 是菜單頁面的主要視圖，負責管理 UI 結構並配置 `MenuCollectionView`。
 
 - Why：
 
   - 將視圖邏輯與控制器分離，減少責任重疊，提高程式的可讀性與可維護性。
   - 動態配置佈局與元件註冊，支持靈活擴展。
 
 - How：
 
   - 初始化時注入 `MenuLayoutProvider`，動態生成佈局。
   - 作為控制器的主視圖，集中管理視圖配置與元件註冊，減少重複程式碼並提升效能。
 */





// MARK: - (v)

import UIKit

/// 定義並管理菜單頁面的主要視圖，負責展示菜單頁面的核心 UI 結構。
///
/// 此視圖的設計目的是將菜單頁面的佈局與顯示邏輯分離，提供一個整合的介面，
/// 以便控制器（如 `MenuViewController`）能專注於資料處理與使用者互動。
///
/// - 特點:
///   1. 封裝 `MenuCollectionView` 作為主顯示元件，用於顯示「網站橫幅」與「飲品分類」等內容。
///   2. 提供內建的初始化方法，透過 `MenuLayoutProvider` 動態生成佈局。
///   3. 包含基礎的視圖配置與 `UICollectionView` 元件註冊邏輯，提升可維護性與可讀性。
///   4. 支援標頭（`MenuSectionHeaderView`）和底部分隔線（`MenuSectionFooterView`）的註冊，
///      提供區域標題與視覺分隔效果。
///
/// - 使用場景:
///   適用於菜單頁面的主要顯示需求，與 `MenuViewController` 配合使用，
///   將控制器的責任集中於資料處理，減少與 UI 的耦合。
class MenuView: UIView {
    
    // MARK: - UI Elements
    
    /// 自訂的 `UICollectionView`，專門用於顯示網站橫幅與飲品分類。
    ///
    /// 使用 `MenuCollectionView` 封裝展示邏輯，透過 `MenuLayoutProvider` 提供動態佈局支持。
    private(set) var menuCollectionView: MenuCollectionView
    
    
    // MARK: - Initializer
    
    /// 初始化菜單頁面的主要視圖。
    ///
    /// - Parameter layoutProvider: 用於生成菜單頁面佈局的實例，預設為 `MenuLayoutProvider`。
    init(layoutProvider: MenuLayoutProvider = MenuLayoutProvider()) {
        self.menuCollectionView = MenuCollectionView(layoutProvider: layoutProvider)
        super.init(frame: .zero)
        setupView()
        registerCells()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置主視圖，將 `MenuCollectionView` 添加到視圖並設置其約束。
    ///
    /// 此方法確保 `MenuCollectionView` 在視圖中佔據全螢幕大小，並正確地與父視圖對齊。
    private func setupView() {
        addSubview(menuCollectionView)
        
        NSLayoutConstraint.activate([
            menuCollectionView.topAnchor.constraint(equalTo: topAnchor),
            menuCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            menuCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            menuCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊所有需要使用的 `UICollectionViewCell` 與 `UICollectionReusableView`。
    ///
    /// 此方法確保 `MenuCollectionView` 能正確顯示對應的內容，如網站橫幅、飲品分類、區域標頭和底部分隔線。
    ///
    /// - 註冊內容：
    ///
    ///   1. Cell 註冊：
    ///      - `MenuWebsiteBannerImageCell`：用於顯示網站橫幅內容。
    ///      - `MenuDrinkCategoryCell`：用於顯示飲品分類。
    ///
    ///   2. Supplementary View 註冊：
    ///      - `MenuSectionHeaderView`：作為每個區域的標頭，展示區域標題。
    ///      - `MenuSectionFooterView`：作為每個區域的底部分隔線，提供視覺分隔效果。
    private func registerCells() {
        menuCollectionView.register(MenuWebsiteBannerImageCell.self, forCellWithReuseIdentifier: MenuWebsiteBannerImageCell.reuseIdentifier)
        menuCollectionView.register(MenuDrinkCategoryCell.self, forCellWithReuseIdentifier: MenuDrinkCategoryCell.reuseIdentifier)
        menuCollectionView.register(MenuSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MenuSectionHeaderView.headerIdentifier)
        menuCollectionView.register(MenuSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: MenuSectionFooterView.footerIdentifier)
    }
    
}
