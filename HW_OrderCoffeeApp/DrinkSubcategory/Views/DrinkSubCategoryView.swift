//
//  DrinkSubCategoryView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/4.
//


// MARK: - DrinkSubCategoryView 筆記
/**
 
 ## DrinkSubCategoryView 筆記


 `* What`
 
 - `DrinkSubCategoryView` 是飲品子分類頁面的主要視圖，專注於處理與視圖相關的邏輯。其核心功能如下：
 
 1. 包含 `DrinkSubCategoryCollectionView`，用於顯示飲品子分類項目（支持列視圖與網格視圖）。
 2. 提供統一的視圖初始化與配置接口，包括自動佈局設定與必需的 `Cell` 和 `Supplementary Views` 註冊。
 3. 通過模組化設計解耦視圖層邏輯，提升可維護性與可重用性。

 ---

` * Why`
 
 - 設計 `DrinkSubCategoryView` 的原因：
 
 1. 單一職責原則 (SRP)
 
    - 將視圖層邏輯從控制器中分離，讓控制器專注於處理業務邏輯，而視圖層專注於視圖初始化與佈局。
 
 2. 高內聚低耦合
 
    - 通過將視圖配置集中於一個類中，減少外部干預，降低對控制器的依賴，確保內部細節不洩漏。
 
 3. 提升重用性
 
    - `DrinkSubCategoryView` 的設計可以適配其他需要類似結構的頁面，僅需更改 `UICollectionView` 的數據來源即可。
 
 4. 減少冗餘
 
    - 將視圖相關的配置和註冊邏輯集中處理，避免在控制器中重複編寫視圖初始化代碼。

 ---

 `* How`
 
 - `DrinkSubCategoryView` 的設計與實現細節：
 
 1. 視圖組成
 
    - 包含一個自訂的 `DrinkSubCategoryCollectionView`，該集合視圖使用動態佈局（列或網格）。
    - 使用 Auto Layout 將 `CollectionView` 填滿整個主視圖。
 
 2. 視圖初始化
 
    - 在 `init()` 方法中初始化 `DrinkSubCategoryCollectionView` 並調用 `setupView()` 方法設置佈局約束。
    - 使用 `registerCells()` 方法統一註冊所有需要的 `Cell` 和 `Supplementary Views`，確保視圖可以正確顯示內容。
 
 3. 視圖配置
 
    - `setupView()` 確保 `DrinkSubCategoryCollectionView` 在父視圖中全屏展示。
    - `registerCells()` 註冊與子分類頁面相關的所有 `Cell` 和 `Header/Footer Views`，包括：
      - 列視圖 Cell: `DrinkSubcategoryColumnItemCell`。
      - 網格視圖 Cell: `DrinkSubcategoryGridItemCell`。
      - Section Header: `DrinkSubCategorySectionHeaderView`。
      - Section Footer: `DrinkSubCategorySectionFooterView`。
 
 4. 與控制器的交互
 
    - `DrinkSubCategoryViewController` 通過 `drinkSubCategoryView.drinkSubCategoryCollectionView` 訪問集合視圖，配置數據源和代理。

 ---

 * 結論
 
 - `DrinkSubCategoryView` 是一個專注於視圖層的模組化設計，通過清晰的結構與單一職責確保代碼可維護性與重用性。
 - 在實際使用中，它與 `DrinkSubCategoryViewController` 搭配使用，將視圖配置與業務邏輯分離，提升了應用的架構設計水準。
 
 */




// MARK: - (v)

import UIKit

/// 飲品子分類頁面的主要視圖。
///
/// 此類負責封裝與飲品子分類頁面相關的視圖層邏輯，包括:
/// 1. 管理主要的 `UICollectionView` (`DrinkSubCategoryCollectionView`)。
/// 2. 提供統一的接口來初始化視圖並進行相關設置。
/// 3. 確保 `UICollectionView` 能夠正確註冊所有需要的 `Cell` 和 `Supplementary Views`。
///
/// - 設計目標:
///   1. 單一職責原則 (SRP):
///      - 此類僅負責視圖的初始化與佈局配置，與業務邏輯解耦。
///   2. 高內聚低耦合:
///      - 提供視圖層的統一接口，避免外部過多干預。
///
/// - 使用場景:
///   此視圖作為 `DrinkSubCategoryViewController` 的主視圖，
///   用於顯示飲品的分類（如網格或列表），並支持不同的佈局樣式切換。
class DrinkSubCategoryView: UIView {
    
    // MARK: - UI Elements
    
    /// 自訂的 `UICollectionView`，用於顯示飲品子分類。
    ///
    /// - 特性:
    ///   1. 透過 `DrinkSubCategoryCollectionView` 封裝 `UICollectionView` 的初始化邏輯。
    ///   2. 支持動態佈局切換，易於與 `DrinkSubCategoryViewManager` 集成。
    private(set) var drinkSubCategoryCollectionView: DrinkSubCategoryCollectionView
    
    
    // MARK: - Initializer
    
    /// 初始化 `DrinkSubCategoryView`。
    ///
    /// - 說明:
    ///   初始化時會自動配置內部的 `UICollectionView`，並完成基礎視圖的設置。
    init() {
        self.drinkSubCategoryCollectionView = DrinkSubCategoryCollectionView()
        super.init(frame: .zero)
        setupView()
        registerCells()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置視圖的佈局與約束。
    private func setupView() {
        addSubview(drinkSubCategoryCollectionView)
        
        NSLayoutConstraint.activate([
            drinkSubCategoryCollectionView.topAnchor.constraint(equalTo: topAnchor),
            drinkSubCategoryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            drinkSubCategoryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            drinkSubCategoryCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊所有需要的 `Cell` 與 `Supplementary Views`。
    ///
    /// - 說明:
    ///   透過此方法，為 `UICollectionView` 註冊所有需要的元素類型，確保其能夠正確顯示。
    ///   包括:
    ///   1. 列樣式的子分類項目 Cell (`DrinkSubcategoryColumnItemCell`)。
    ///   2. 網格樣式的子分類項目 Cell (`DrinkSubcategoryGridItemCell`)。
    ///   3. Section 的 Header (`DrinkSubCategorySectionHeaderView`)。
    ///   4. Section 的 Footer (`DrinkSubCategorySectionFooterView`)。
    private func registerCells() {
        drinkSubCategoryCollectionView.register(DrinkSubcategoryColumnItemCell.self, forCellWithReuseIdentifier: DrinkSubcategoryColumnItemCell.reuseIdentifier)
        drinkSubCategoryCollectionView.register(DrinkSubcategoryGridItemCell.self, forCellWithReuseIdentifier: DrinkSubcategoryGridItemCell.reuseIdentifier)
        
        drinkSubCategoryCollectionView.register(DrinkSubCategorySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DrinkSubCategorySectionHeaderView.headerIdentifier)
        drinkSubCategoryCollectionView.register(DrinkSubCategorySectionFooterView.self.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DrinkSubCategorySectionFooterView.footerIdentifier)
    }
    
}
