//
//  DrinkSubCategoryCollectionView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/24.
//



// MARK: - DrinkSubCategoryCollectionView 筆記
/**
 
 ## DrinkSubCategoryCollectionView 筆記


 `* What`
 
 - `DrinkSubCategoryCollectionView` 是一個自訂的 `UICollectionView`，專門用於顯示飲品子分類的內容。
 - 它封裝了視圖層的基本配置，提供一個統一的接口來初始化和設置 `UICollectionView` 的屬性。

 - 用途：
 
   - 顯示飲品子分類的項目，如飲品列表或網格樣式。
   - 配合外部的 `DrinkSubCategoryViewManager` 或其他佈局管理類切換佈局。
   - 保持視圖層的統一性和簡潔性。

 - 特點：
 
   1. 使用預設的 `UICollectionViewCompositionalLayout`。
   2. 簡化 `UICollectionView` 的初始化，統一配置背景色、滾動條顯示等常見屬性。
   3. 易於擴展，支持佈局和數據源的靈活配置。

 ---

 `* Why`
 
 - 職責清晰：
 
   - `DrinkSubCategoryCollectionView` 僅負責與視圖相關的邏輯，如佈局設置、基本屬性初始化，與數據邏輯完全解耦。
   - 這樣的設計符合單一職責原則 (Single Responsibility Principle, SRP)。

 - 易於測試和重用：
 
   - 通過封裝視圖配置，可以避免每個控制器重複進行視圖設置。
   - 提高代碼的可讀性和可維護性，適合在不同場景中重用。

 - 提高模組化程度：
 
   - 集中管理視圖相關的配置，減少 `ViewController` 的代碼負擔，控制器僅需關注業務邏輯。

 ---

 `* How`

 1. 初始化設置：
 
    - 使用 `UICollectionViewCompositionalLayout` 作為預設佈局，並允許外部通過 `DrinkSubCategoryViewManager` 動態更新。
    - 禁用自動尺寸調整，設置背景色為系統背景色，開啟垂直滾動條。

 2. 方法與屬性：
 
    - `configureCollectionView()`：統一設置 `UICollectionView` 的外觀和行為。

 3. 整合與使用：
 
    - 配合外部的佈局生成類（如 `DrinkSubCategoryLayoutProvider`）動態生成佈局。
    - 在 `DrinkSubCategoryView` 中作為子視圖，統一管理。

 ---


 `* 總結`

 1. 與 `DrinkSubCategoryViewManager` 配合使用：
 
    - `DrinkSubCategoryCollectionView` 不直接處理佈局生成，僅作為視圖容器，動態佈局由 `DrinkSubCategoryViewManager` 管理。

 2.與 `DrinkSubCategoryView` 集成：
 
    - 在 `DrinkSubCategoryView` 中作為子視圖，統一管理註冊的 `cell` 和 `supplementary views`。

 3. 外部初始化與配置：
 
    - 由 `DrinkSubCategoryViewController` 動態更新數據源和代理方法，確保職責清晰。
 
 */


// MARK: - (v)

import UIKit

/// 自訂的 `UICollectionView`，專門用於飲品子分類展示。
///
/// 此類的設計目的是封裝與飲品子分類相關的 `UICollectionView` 配置，提供更高的重用性和一致性。
///
/// - 特點:
///   1. 預設使用 `UICollectionViewCompositionalLayout`，支持動態佈局切換。
///   2. 簡化外部初始化，只需提供需要的佈局物件即可。
///   3. 提供統一的配置方法，設置常見的 `UICollectionView` 屬性。
///
/// - 使用場景:
///   適用於顯示多個子分類飲品的場景，如列表或網格展示，通過佈局切換提供不同的視圖樣式。
///
/// - 設計原則:
///   1. 單一職責原則 (SRP):
///      - 僅負責封裝 `UICollectionView` 的配置和初始化，不處理數據源或業務邏輯。
///   2. 高內聚低耦合:
///      - 與 `DrinkSubCategoryViewManager` 配合使用，將佈局生成和數據處理委託給外部類別。
class DrinkSubCategoryCollectionView: UICollectionView {
    
    
    // MARK: - Initializer
    
    /// 初始化 `DrinkSubCategoryCollectionView`，使用預設的空佈局。
    ///
    /// 預設的 `UICollectionViewCompositionalLayout` 返回 `nil`，可由外部通過 `ViewManager` 更新佈局。
    init() {
        let initialLayout = UICollectionViewCompositionalLayout { _, _ in return nil }
        super.init(frame: .zero, collectionViewLayout: initialLayout)
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 配置 `UICollectionView` 的基本屬性。
    ///
    /// - 設置項目:
    ///   1. 關閉自動尺寸調整 (禁用 `translatesAutoresizingMaskIntoConstraints`)。
    ///   2. 背景顏色設為 `systemBackground`。
    ///   3. 開啟垂直滾動條。
    ///
    /// - 設計目的:
    ///   提供統一的配置方法，確保視圖的外觀和行為一致。
    private func configureCollectionView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
        self.showsVerticalScrollIndicator = true
    }
    
}
