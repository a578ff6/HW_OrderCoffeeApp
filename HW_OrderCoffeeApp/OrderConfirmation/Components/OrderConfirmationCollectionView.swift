//
//  OrderConfirmationCollectionView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/10.
//

import UIKit

/// `OrderConfirmationCollectionView` 是專為 `OrderConfirmationView` 設計的自訂 CollectionView，包含初始化與樣式配置。
///
/// 此類別透過 `OrderConfirmationLayoutProvider` 提供的 Compositional Layout，
/// 專注於以模組化的方式呈現`顧客訂單成功`及`相關資訊`。
/// 預設包含彈性垂直滾動、背景色設定以及簡化的初始化流程。
class OrderConfirmationCollectionView: UICollectionView {
    
    // MARK: - Initializer
    
    /// 使用指定的 Compositional Layout 初始化 `OrderConfirmationCollectionView`。
    init() {
        let layout = OrderConfirmationLayoutProvider.createLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設定 `OrderConfirmationCollectionView` 的相關屬性。
    ///
    /// 包括：
    /// - 關閉自動轉換 Auto Layout 約束
    /// - 設定背景色為系統預設背景
    /// - 啟用垂直彈性滾動效果
    /// - 隱藏垂直滾動條
    private func setupCollectionView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
        self.alwaysBounceVertical = true
        self.showsHorizontalScrollIndicator = false
    }
    
}
