//
//  FavoritesDrinkHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/28.
//


// MARK: - 筆記：FavoritesDrinkHeaderView 的設計架構
/**
 
 ## 筆記：FavoritesDrinkHeaderView 的設計架構
 
 `* What`
 
 - `FavoritesDrinkHeaderView` 是一個自訂義的 `UICollectionReusableView`，用於「我的最愛」頁面中作為每個子分類的 Header，顯示對應的子分類標題。

 `* Why`
 
 `1.明確的分工與職責`

 - `FavoritesDrinkHeaderView` 專注於子分類標題的顯示，讓 UICollectionView 的每個 Section 都能清楚呈現其內容分類。
 
 `2.模組化與重用性`

 - 提供獨立的 `Header` 元件，便於多次重用。
 - 透過 reuseIdentifier 支持 UICollectionReusableView 的重用機制，提升效能。
 
` 3.靈活性與可配置性`

 - 標題顯示由 `configure(with:) `方法設置，支持不同子分類動態配置標題文字。
 
 `* How`
 
 `1.自訂義 titleLabel`

 - 使用 `FavoritesLabel` 作為標題標籤，封裝樣式邏輯（例如字體、顏色），提高模組化與樣式統一性。
 
 `2.設置 Auto Layout`

 - 通過 NSLayoutConstraint 設置標籤的位置與間距，確保在不同螢幕尺寸下都能正確對齊。
 
 `3.配置方法`

 提供 `configure(with:) `方法，方便從外部設置標題文字，保持設計的靈活性與簡潔性。
 */


// MARK: - (v)
import UIKit

/// 用於顯示「我的最愛」頁面的子分類標題。
/// - 說明：此元件是 `UICollectionReusableView` 的子類別，作為每個 Section 的 Header，顯示對應的子分類標題。
/// - 功能：
///   1. 提供標籤 (`titleLabel`) 用於顯示標題文字。
///   2. 支援文字配置，根據不同的子分類設定對應的標題。
class FavoritesDrinkHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "FavoritesDrinkHeaderView"
    
    // MARK: - UI Element
    
    /// 標題標籤，顯示子分類的名稱。
    private let titleLabel = FavoritesLabel(font: .boldSystemFont(ofSize: 25), textColor: .black)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置標籤的 Auto Layout 與基本樣式
    private func setupView() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    
    /// 配置標題文字
    /// - Parameter title: 子分類 (`subcategory`) 的標題文字
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
