//
//  DrinkDetailView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/8.
//

// MARK: - 各個cell補充
/**
 
 ## DrinkDetailView：
 
    * 功能： DrinkDetailView 是 DrinkDetailViewController 的主視圖，主要使用 UICollectionView 來顯示飲品詳細資訊、尺寸選擇、價格資訊及訂單選項。

    * 視圖設置：
        - 包含一個 UICollectionView，並透過 DrinkDetailLayoutProvider 來提供不同 section 的佈局。
        - 使用者透過此視圖選擇飲品尺寸、查看價格資訊及新增或更新訂單。

    * 註冊的自定義 Cell：
        - DrinkInfoCollectionViewCell： 顯示飲品的詳細資訊。
        - DrinkSizeSelectionCollectionViewCell： 顯示飲品的尺寸選擇。
        - DrinkPriceInfoCollectionViewCell： 顯示選中尺寸的價格資訊。
        - DrinkOrderOptionsCollectionViewCell： 顯示訂單的選項，如加入購物車按鈕。
        - DrinkDetailSeparatorView： 顯示在 section footer 內的分隔視圖。
 */

// MARK: - 筆記：DrinkDetailView 的設計概念
/**
 
 ## 筆記：DrinkDetailView 的設計概念
 
 `* What`
 
 - `DrinkDetailView` 是 UIView 的子類別，負責整合 UICollectionView，並完成視圖的初始化與設定。

 1.內含一個自訂的 `DrinkDetailCollectionView`，使用 `DrinkDetailLayoutProvider` 生成 `Compositional Layout`。
 2.註冊所有自定義的 `UICollectionViewCell` 與 `Supplementary Views`。
 
 ----------------------
 
 `* Why`
 
 `1.責任分離`

 - 將視圖的組合邏輯與佈局邏輯拆分，`DrinkDetailView` 專注於組合 UI 元件，而佈局由 `DrinkDetailLayoutProvider` 處理。
 - 這樣的設計符合 單一責任原則 (SRP)，提高程式碼的可維護性和可讀性。
 
 `2.重用性`

 - `DrinkDetailCollectionView` 可獨立使用，適用於不同頁面需要類似 `UICollectionView` 的情境。
 - `LayoutProvider` 專門負責生成各 `Section` 的佈局，達到模組化設計，易於擴展。
 
 `3.降低耦合度`

 - 視圖組件與業務邏輯分離，`ViewController` 不需直接管理視圖初始化，提升邏輯清晰度。
 
 ----------------------

 `* How`
 
 `1.初始化與注入佈局邏輯`

 - 在 `DrinkDetailView` 的初始化階段，透過注入 `DrinkDetailLayoutProvider`，生成 `DrinkDetailCollectionView`。
 - 將 `UICollectionView` 的初始化邏輯封裝於 DrinkDetailCollectionView 類別中。
 
 `2.註冊自定義元件`

 - 使用 `registerCells` 方法集中註冊所有 `UICollectionViewCell` 和 `Supplementary Views`。
 
 `3.設置約束`

 - 使用 `NSLayoutConstraint` 設定 `DrinkDetailCollectionView` 的佈局，使其充滿整個 `DrinkDetailView`。
 
 ----------------------

 `* 結論`
 
 - `DrinkDetailView` 採用 組件化設計，遵循 單一責任原則 和 依賴注入 原則，將佈局邏輯與視圖生成邏輯分離：

 1.`視圖組合邏輯`：由 DrinkDetailView 處理。
 2.`UICollectionView`：透過 DrinkDetailCollectionView 初始化。
 3.`佈局邏輯`：由 DrinkDetailLayoutProvider 提供。
 */



// MARK: - (v)

import UIKit

/// 定義並管理 `DrinkDetailViewController` 的主要視圖，包含 `UICollectionView`。
///
/// 此視圖負責組合 UI 元件，透過注入 `DrinkDetailLayoutProvider` 來設定 `DrinkDetailCollectionView`。
/// - 責任分離：`DrinkDetailView` 專注於 UI 設定，將 UICollectionView 的生成與佈局邏輯委派給 `DrinkDetailCollectionView`。
class DrinkDetailView: UIView {
    
    // MARK: - UI Elements
    
    /// 自訂的 `UICollectionView`，用於顯示飲品相關資訊與選項。
    private(set) var drinkDetailCollectionView: DrinkDetailCollectionView
    
    // MARK: - Initializer
    
    /// 初始化 `DrinkDetailView`，並注入 `DrinkDetailLayoutProvider` 來提供佈局。
    /// - Parameter layoutProvider: 提供佈局的類別，預設為 `DrinkDetailLayoutProvider`。
    init(layoutProvider: DrinkDetailLayoutProvider = DrinkDetailLayoutProvider()) {
        self.drinkDetailCollectionView = DrinkDetailCollectionView(layoutProvider: layoutProvider)
        super.init(frame: .zero)
        setupView()
        registerCells()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置 `DrinkDetailView` 的主要視圖佈局。
    private func setupView() {
        addSubview(drinkDetailCollectionView)
        NSLayoutConstraint.activate([
            drinkDetailCollectionView.topAnchor.constraint(equalTo: topAnchor),
            drinkDetailCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            drinkDetailCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            drinkDetailCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊所有自定義的 `cell` 和 `supplementary views`。
    ///
    /// 確保 `DrinkDetailCollectionView` 能正確顯示各種元件。
    private func registerCells() {
        drinkDetailCollectionView.register(DrinkImageCollectionViewCell.self, forCellWithReuseIdentifier: DrinkImageCollectionViewCell.reuseIdentifier)
        drinkDetailCollectionView.register(DrinkInfoCollectionViewCell.self, forCellWithReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier)
        drinkDetailCollectionView.register(DrinkSizeSelectionCollectionViewCell.self, forCellWithReuseIdentifier: DrinkSizeSelectionCollectionViewCell.reuseIdentifier)
        drinkDetailCollectionView.register(DrinkPriceInfoCollectionViewCell.self, forCellWithReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier)
        drinkDetailCollectionView.register(DrinkOrderOptionsCollectionViewCell.self, forCellWithReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier)
        
        drinkDetailCollectionView.register(DrinkDetailSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier)
        drinkDetailCollectionView.register(DrinkDetailSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier)
    }
    
}
