//
//  FavoritesCollectionView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/13.
//

// MARK: - 筆記：FavoritesCollectionView 的設計架構
/**
 
 ## 筆記：FavoritesCollectionView 的設計架構
 
 `* What`
 
 - `FavoritesCollectionView` 是專門為「我的最愛」頁面設計的自訂義 `UICollectionView` 類別，負責顯示飲品列表。此類別的主要功能包括：

 1.使用外部注入的 UICollectionViewLayout 進行初始化。
 2.自行設置基本屬性，例如背景色、捲動條狀態等。
 
 ---------------------
 
 `* Why`
 
 `1.單一責任原則`

 - 此類別僅專注於 UICollectionView 的初始化和基礎屬性設置，與數據、邏輯完全解耦，確保責任劃分清晰。
 
 `2.靈活性與重用性`

 - 將佈局邏輯交由外部注入，提升靈活性，讓 `FavoritesCollectionView` 可以在不同的頁面或場景中重用，而不限制於特定的佈局形式。
 
 `3.便於測試與擴展`

 - 使用注入的方式可以輕鬆替換或模擬不同的 `layout`，方便測試不同佈局情境。
 
 ---------------------

 `* How`
 
 `1.佈局注入`

 - 在 init(layout:) 中傳入外部生成的 UICollectionViewLayout，確保佈局責任由外部負責。
 
` 2.基本屬性設置`

 - setupCollectionViewProperties 方法集中管理以下屬性：
 
    - translatesAutoresizingMaskIntoConstraints = false：確保支援 Auto Layout。
    - backgroundColor = .systemBackground：設定背景色，保持與系統主題一致。
    - showsVerticalScrollIndicator = true：顯示垂直捲動條，方便用戶在列表中定位。
    - showsHorizontalScrollIndicator = false：隱藏水平捲動條，避免干擾 UI 的整潔。
 */


// MARK: - (v)

import UIKit

/// 自訂義的 UICollectionView，專門用於「我的最愛」頁面顯示飲品列表。
/// - 說明：此類別透過注入佈局（layout）來初始化，並進行基本屬性設定，確保 UICollectionView 在頁面上的正確顯示與行為。
class FavoritesCollectionView: UICollectionView {
    
    // MARK: - Initializer

    /// 初始化 FavoritesCollectionView
    /// - Parameter layout: 傳入的 UICollectionViewLayout，用於配置 UICollectionView 的佈局
    init(layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollectionViewProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Method
    
    /// 設定 CollectionView 的基本屬性
    /// - 說明：包含設定自動調整約束、背景色、捲動條顯示狀態等。
    private func setupCollectionViewProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = false
    }
    
}
