//
//  OrderHistoryDetailCollectionView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/13.
//

import UIKit

/// `OrderHistoryDetailCollectionView`
///
/// 專為 `OrderHistoryDetailView` 設計的自訂 `UICollectionView`。
///
/// - 功能：
///   1. 提供彈性垂直滾動效果，適合顯示多樣化訂單細節內容。
///   2. 配置背景色為系統預設背景，確保與整體介面一致。
///   3. 使用 `OrderHistoryDetailLayoutProvider` 提供的模組化 Compositional Layout，簡化布局管理。
///
/// - 使用場景：
///   用於展示歷史訂單的詳細資訊，包括顧客資訊、飲品細節和訂單摘要等。
class OrderHistoryDetailCollectionView: UICollectionView {
    
    // MARK: - Initializer
    
    /// 初始化 `OrderHistoryDetailCollectionView`
    ///
    /// - 說明：
    ///   使用 `OrderHistoryDetailLayoutProvider.createLayout()` 設置 Compositional Layout，
    ///   並配置相關視圖屬性。
    init() {
        let layout = OrderHistoryDetailLayoutProvider.createLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設定 `OrderHistoryDetailCollectionView` 的相關屬性。
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
