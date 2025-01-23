//
//  MenuSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/3.
//


// MARK: - MenuSectionHeaderView 筆記
/**
 
 ## MenuSectionHeaderView 筆記


 `* What`

 - `MenuSectionHeaderView` 是一個自訂的 `UICollectionReusableView`，專為 `MenuViewController` 的 `UICollectionView` 設計，負責展示每個區域（section）的標題。
 
 主要功能包括：
 
 1. 在各區域的頂部顯示標題文字。
 2. 提供統一的樣式與間距設定。
 3. 支援使用 `configure(with:)` 方法動態設置標題。

 ---

 `* Why`

 1. 分離責任：
 
    - 將 header 的 UI 與邏輯從主要控制器中分離，提升可維護性。
    - 讓 `UICollectionView` 的每個 section 都有專屬的標題顯示，強調區域內容。

 2. 統一樣式：
 
    - 標題的字體、顏色、間距等樣式統一管理，減少重複設置，提升視覺一致性。

 3. 靈活配置：
 
    - 提供簡單的 API（`configure(with:)`），使控制器能輕鬆設置標題文字，增加靈活性。

 4. 增強用戶體驗：
 
    - 清晰的標題能讓用戶快速理解每個區域的內容，提升整體易用性。

 ---

 `* How`

 1. 定義 UI 元件：
 
    - 使用 `MenuLabel` 來顯示標題，統一字體與顏色設定（`font: .systemFont(ofSize: 25, weight: .heavy)`，`textColor: .darkGray`）。

 2. 設置方法：
 
    - 在 `setupViews` 方法中：
      - 將 `headerTitleLabel` 添加到視圖。
      - 使用 Auto Layout 設置標題的間距（如 `leading: 16`，`top: 8` 等）。

 3. 提供配置方法：
 
    - `configure(with:)`：
      - 接收標題文字作為參數，設置到 `headerTitleLabel.text`，實現標題的動態配置。

 4. 使用方式：
 
    - 在 `MenuCollectionHandler` 的 `viewForSupplementaryElementOfKind` 中，為每個 section header 配置標題文字：
 
      ```swift
      headerView.configure(with: section.title)
      ```

 ---

 `* 優勢`

 - 模組化設計：`MenuSectionHeaderView` 是一個專門負責 header 的模組，與其他 UI 元件低耦合，便於維護與測試。
 - 清晰結構：統一的設計風格與配置 API，提升代碼可讀性與可復用性。
 - 增強用戶體驗：清晰的標題展示讓用戶更容易區分區域內容。

 ---

 `* 使用場景`

 - 菜單頁面（MenuViewController）：
 
    - 作為 `UICollectionView` 的 section header，用於顯示「網站橫幅」、「飲品分類」等區域的標題。
    - 配合 `MenuSection`，動態設置標題文字，實現與區域內容的一致性。

 */



// MARK: - (v)

import UIKit

/// 自訂的 section header view，用於展示 MenuViewController 中每個區域的標題。
///
/// 此類專為 `UICollectionView` 的 section header 設計，
/// 提供標題的顯示功能，並應用統一的樣式與間距。
///
/// - 功能特色:
///   1. 支援標題顯示，適用於不同區域的 header 標題展示。
///   2. 提供統一的 `configure(with:)` 方法，便於設置標題文字。
///   3. 標題樣式（字體、顏色）統一管理，提升整體視覺效果。
///
/// - 使用場景:
///   適用於 `MenuViewController` 的 `UICollectionView`，
///   作為各 section 的 header，用於顯示對應區域的標題。
class MenuSectionHeaderView: UICollectionReusableView {
    
    /// header view 的重用識別符。
    static let headerIdentifier = "MenuSectionHeaderView"
    
    // MARK: - UI Elements
    
    /// 用於顯示 section 標題的標籤。
    private let headerTitleLabel = MenuLabel(font: .systemFont(ofSize: 25, weight: .heavy), textColor: .darkGray)
    
    
    // MARK: - Initialization
    
    /// 初始化 header view。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 header view 的子視圖與佈局。
    ///
    /// - 將 `headerTitleLabel` 添加到視圖中。
    /// - 設置約束，確保標題文字具有適當的間距與對齊。
    private func setupViews() {
        addSubview(headerTitleLabel)
        
        NSLayoutConstraint.activate([
            headerTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            headerTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configuration
    
    /// 設置 section header 的標題文字。
    ///
    /// - Parameter title: 要顯示的標題文字。
    func configure(with title: String) {
        headerTitleLabel.text = title
    }
    
}
