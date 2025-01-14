//
//  OrderConfirmationView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//
// MARK: - 訂單確認頁面元件佈局設計筆記
/**
 ### 訂單確認頁面元件佈局設計筆記

` * What`
 
 - 設置 `OrderConfirmationView` 和 `OrderConfirmationLayoutProvider`，用於展示訂單確認頁面，包括提交成功的提示訊息、顧客資訊、訂單飲品項目詳情、訂單詳情、關閉按鈕。

 `* Why`
 
 `* 視圖與佈局邏輯分離：`
   - 設置 `OrderConfirmationView` 專注於視圖層次的構建，而 `OrderConfirmationLayoutProvider` 負責佈局設計。
 
 `* 靈活顯示訂單資訊：`
   - 使用 `UICollectionView` 來顯示多樣化的內容（成功提示、顧客資訊、訂單項目等），每個區域都可以有不同的顯示方式，能夠更好地組織和呈現訂單確認相關的資訊。

 `* How`
 
` * 使用 UICollectionView`
   - 利用 `UICollectionView` 顯示訂單確認頁面中的各種元素，設置多種類型的 `UICollectionViewCell` 來呈現不同的內容，例如：
    
    1. `OrderConfirmationCheckmarkCell`：顯示打勾圖示。
    2. `OrderConfirmationMessageCell`：顯示成功提交的提示訊息。
    3. `OrderConfirmationCustomerInfoCell`：顯示顧客的姓名、電話等資訊。
    4. `OrderrConfirmationItemDetailsCell`：顯示飲品項目詳情（如名稱、數量、價格等）。
    5. `OrderrConfirmationDetailsCell`：顯示訂單的基本資訊（如訂單編號、時間、總金額等）。
    6. `OrderrConfirmationCloseButtonCell`：包含 "關閉" 按鈕，讓用戶確認後返回。

 `* 佈局建議：UICollectionViewCompositionalLayout vs UICollectionViewFlowLayout`
 
   - `UICollectionViewCompositionalLayout`：
     - 提供更靈活的佈局，可以根據不同區域的需求進行定制，例如不同的 section 可能需要垂直或水平排列。
     - 適合訂單確認頁面中展示多樣化的資料，有助於提供更好的用戶體驗。
 
   - `UICollectionViewFlowLayout`：
     - 簡單易用，但對於複雜多樣的佈局需求，可能不夠靈活。

 `* 下一步`
 - 構建 `OrderConfirmationView` 的結構，並設計每個需要的 `UICollectionViewCell`，以展示提交成功後的各種訂單資訊。
 - 在 `OrderConfirmationLayoutProvider` 中設置各個 section 的佈局，選擇適合的佈局來呈現不同內容。
 */


import UIKit

/// `OrderConfirmationView` 用於顯示`訂單確認成功`相關的畫面，包括各種訂單資訊和操作按鈕。
class OrderConfirmationView: UIView {

    // MARK: - UI Elements
        
    /// 訂單確認t成功專用的 CollectionView，顯示畫面內容的主要元件。
    private(set) var orderConfirmationCollectionView = OrderConfirmationCollectionView()

    // MARK: - Initializer
    
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

    /// 註冊所需的 Cells 和 Header，確保 CollectionView 可以正確顯示內容。
    private func registerCells() {
        orderConfirmationCollectionView.register(OrderConfirmationCheckmarkCell.self, forCellWithReuseIdentifier: OrderConfirmationCheckmarkCell.reuseIdentifier)
        orderConfirmationCollectionView.register(OrderConfirmationMessageCell.self, forCellWithReuseIdentifier: OrderConfirmationMessageCell.reuseIdentifier)
        orderConfirmationCollectionView.register(OrderrConfirmationItemDetailsCell.self, forCellWithReuseIdentifier: OrderrConfirmationItemDetailsCell.reuseIdentifier)
        orderConfirmationCollectionView.register(OrderConfirmationCustomerInfoCell.self, forCellWithReuseIdentifier: OrderConfirmationCustomerInfoCell.reuseIdentifier)
        orderConfirmationCollectionView.register(OrderrConfirmationDetailsCell.self, forCellWithReuseIdentifier: OrderrConfirmationDetailsCell.reuseIdentifier)
        orderConfirmationCollectionView.register(OrderrConfirmationCloseButtonCell.self, forCellWithReuseIdentifier: OrderrConfirmationCloseButtonCell.reuseIdentifier)
        orderConfirmationCollectionView.register(OrderConfirmationSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OrderConfirmationSectionHeaderView.headerIdentifier)
    }
    
    /// 設置 CollectionView 的 AutoLayout
    private func setupLayout() {
        addSubview(orderConfirmationCollectionView)
        
        NSLayoutConstraint.activate([
            orderConfirmationCollectionView.topAnchor.constraint(equalTo: topAnchor),
            orderConfirmationCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            orderConfirmationCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            orderConfirmationCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
