//
//  FavoritesView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//

// MARK: - 筆記：FavoritesView 的設計架構
/**
 
 ## 筆記：FavoritesView 的設計架構
 
 `* What`
 
 1.FavoritesView 是「我的最愛」頁面的主要視圖，負責組裝 UI 元件並顯示收藏的飲品清單。它的主要功能包括：

 - 生成自訂義的 FavoritesCollectionView。
 - 設置 FavoritesCollectionView 的布局，確保填滿整個頁面。
 - 註冊所需的自訂義 Cell 和 Header，為顯示飲品資料做準備。
 
 `* Why`
 
` 1.單一責任原則（Single Responsibility Principle）`

 - `FavoritesView` 專注於組裝 UI，與資料處理、邏輯運算完全分離，確保程式結構清晰。
 
 `2.提高模組化和可重用性`

 - 將 UI 和邏輯分離，使得 `FavoritesView` 可以單獨使用或測試，不依賴其他模組。
 
 `3.增強靈活性`

 - 使用外部提供的 layout，可以根據需求輕鬆替換佈局，適配不同的顯示需求。
 
 `* How`
 
 `1.生成自訂義的 FavoritesCollectionView`

 - 使用 `FavoritesLayoutProvider.createLayout() `提供佈局，並注入到 `FavoritesCollectionView` 的初始化中。
 
 `2.設置約束`

 - 透過 Auto Layout 確保 `FavoritesCollectionView` 填滿整個頁面，提供一致的使用者體驗。
 
 `3.註冊自訂義元件`

 - 使用 register 方法為 `FavoritesCollectionView` 註冊 Cell 和 Header，準備顯示資料。
 */



// MARK: - 重構(v)

import UIKit

/// 「我的最愛」頁面的主要視圖
/// - 說明：此視圖負責組裝「我的最愛」頁面的 UI 元件，使用自訂義的 `FavoritesCollectionView` 顯示收藏的飲品清單。
/// - 功能：
///   1. 透過 `FavoritesLayoutProvider` 提供的佈局生成 `FavoritesCollectionView`。
///   2. 設置 CollectionView 的約束，確保其填滿整個畫面。
///   3. 註冊自訂義的 Cell 和 Header，準備顯示飲品資料。
class FavoritesView: UIView {
    
    // MARK: - UI Elements
    
    /// 自訂義的 UICollectionView，專門用於顯示「我的最愛」飲品
    private(set) var favoritesCollectionView: FavoritesCollectionView
    
    // MARK: - Initializer
    
    /// 初始化
    /// 使用 `FavoritesLayoutProvider` 提供的 `layout`
    override init(frame: CGRect) {
        let layout = FavoritesLayoutProvider.createLayout()
        self.favoritesCollectionView = FavoritesCollectionView(layout: layout)
        super.init(frame: frame)
        setupView()
        registerCells()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 將 CollectionView 加入視圖並設置 Auto Layout
    private func setupView() {
        addSubview(favoritesCollectionView)
        
        NSLayoutConstraint.activate([
            favoritesCollectionView.topAnchor.constraint(equalTo: topAnchor),
            favoritesCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            favoritesCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            favoritesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊自訂義的 Cell 和 Header
    /// - 說明：準備顯示飲品資料所需的 Cell 和 Header。
    private func registerCells() {
        favoritesCollectionView.register(FavoriteDrinkCell.self, forCellWithReuseIdentifier: FavoriteDrinkCell.reuseIdentifier)
        favoritesCollectionView.register(FavoritesDrinkHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FavoritesDrinkHeaderView.reuseIdentifier)
    }
    
}
