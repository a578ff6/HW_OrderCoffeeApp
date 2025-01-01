//
//  OrderItemView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/2.
//


// MARK: - OrderItemView 筆記
/**
 
 ## OrderItemView 筆記

 * What

 - `OrderItemView` 是專門用於展示飲品訂單相關內容的自訂視圖，具備以下核心功能與結構：

` 1. 核心元件：`
 
    - `OrderItemCollectionView`：用於顯示訂單清單，支持 `Compositional Layout`，展示內容包括商品列表、摘要資訊與操作按鈕。

 `2. 功能結構：`
 
    - 視圖的主要元件為 `OrderItemCollectionView`，負責顯示訂單的所有視覺化內容。
    - 提供 `registerCells` 方法註冊必要的 `CollectionView Cells` 和 `Supplementary Views`。

 `3. 佈局設定：`
 
    - `setupLayout` 方法通過 AutoLayout 將 `OrderItemCollectionView` 填滿整個視圖，確保內容在各種裝置中完整顯示。

 -----------

 `* Why`

 1. 視圖專注單一責任：
 
    - `OrderItemView` 僅專注於處理訂單相關視圖的呈現，與邏輯處理層（例如 `ViewController` 或 `Handler`）解耦，提升了模組化與可維護性。

 2. 靈活性與可擴展性：
 
    - 透過註冊 `CollectionView Cells`，支援多種視圖內容的展示，例如商品、摘要、操作按鈕。

 3. 統一佈局管理：
 
    - 使用 `AutoLayout` 保證視圖在不同螢幕尺寸下的自適應性，減少額外的佈局邏輯。
 
 -----------

 `* How`

 1. 初始化 `OrderItemView`：
 
    - 在 `init` 方法中完成視圖的初始化，包含註冊所需的 `CollectionView` 元件與設定佈局。

 2. 註冊 Cells 與 Supplementary Views：
 
    - 使用 `registerCells` 方法集中處理所有 `CollectionView` 所需的元件註冊：
      - 商品項目：`OrderItemCollectionViewCell`
      - 訂單摘要：`OrderItemSummaryCollectionViewCell`
      - 空訂單提示：`NoOrderItemViewCell`
      - 操作按鈕：`OrderItemActionButtonsCell`
      - Section 標題：`OrderItemSectionHeaderView`

 3. 佈局設定：
 
    - 在 `setupLayout` 中將 `OrderItemCollectionView` 添加到視圖，並通過約束讓其完全填滿父視圖。

 4. 應用場景：
 
    - 在 `OrderItemViewController` 中作為主要視圖使用。
    - 提供統一的訂單清單展示，包含商品、總金額、準備時間與操作按鈕。

 -----------

 `* 適用場景`

 1. 訂單清單展示：
 
    - 使用 `OrderItemView` 集中管理訂單的視覺化展示內容，適用於展示訂單的商品與相關操作。

 2. 提高視圖模組化：
 
    - 在專案中統一處理與訂單相關的 UI 元件，讓其他邏輯處理模組（如 `Handler`）不需直接介入視圖細節。

 3. 提升可維護性：
 
    - 若需要調整訂單清單的視覺呈現（例如新增 Section 或調整樣式），可以集中在此視圖進行修改，降低對其他模組的影響。

 4. 多元化內容呈現：
 
    - 支援多種類型的 Cell，適合在訂單中展示多元內容，例如促銷標籤、運送資訊等。
 */


import UIKit

/// `OrderItemView` 是一個專門負責展示飲品訂單項目相關內容的自訂視圖。
///
/// 此類別的主要功能是將 `OrderItemCollectionView` 作為核心元件，
/// 用於顯示訂單項目清單（如商品、摘要、操作按鈕等），
/// 並負責設定相關的佈局與元件註冊邏輯。
class OrderItemView: UIView {
    
    // MARK: - UI Elements
    
    /// 用於展示訂單項目的自訂 CollectionView。
    ///
    /// `OrderItemCollectionView` 提供訂單相關的 Compositional Layout 和滾動屬性設定，
    private(set) var orderItemCollectionView = OrderItemCollectionView()
    
    // MARK: - Initializers
    
    /// 初始化方法，用於設置視圖佈局與註冊元件。
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCells()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 註冊必要的 CollectionView Cells 與 Supplementary Views。
    ///
    /// 註冊項目包括：
    /// - `OrderItemCollectionViewCell`：用於展示訂單項目的主要 Cell。
    /// - `OrderItemSummaryCollectionViewCell`：用於展示訂單摘要資訊的 Cell。
    /// - `NoOrderItemViewCell`：用於顯示空訂單提示的 Cell。
    /// - `OrderItemActionButtonsCell`：用於展示操作按鈕的 Cell。
    /// - `OrderItemSectionHeaderView`：用於展示 Section 標題的 Supplementary View。
    private func registerCells() {
        orderItemCollectionView.register(OrderItemCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier)
        orderItemCollectionView.register(OrderItemSummaryCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemSummaryCollectionViewCell.reuseIdentifier)
        orderItemCollectionView.register(NoOrderItemViewCell.self, forCellWithReuseIdentifier: NoOrderItemViewCell.reuseIdentifier)
        orderItemCollectionView.register(OrderItemActionButtonsCell.self, forCellWithReuseIdentifier: OrderItemActionButtonsCell.reuseIdentifier)
        orderItemCollectionView.register(OrderItemSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OrderItemSectionHeaderView.headerIdentifier)
    }
    
    /// 設置 `OrderItemCollectionView` 的 AutoLayout。
    ///
    /// 透過約束讓 `OrderItemCollectionView` 填滿整個視圖，確保內容在畫面中完整呈現。
    private func setupLayout() {
        addSubview(orderItemCollectionView)
        
        NSLayoutConstraint.activate([
            orderItemCollectionView.topAnchor.constraint(equalTo: topAnchor),
            orderItemCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            orderItemCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            orderItemCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
