//
//  OrderCustomerDetailsView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/10.
//

import UIKit

/// `OrderCustomerDetailsView` 是用於展示訂單客戶詳情頁面的主要視圖，包含一個 `UICollectionView`
///
/// ### 功能說明
/// - 使用自訂的 `OrderCustomerDetailsCollectionView` 作為核心元件，用於展示各種訂單相關資訊。
/// - 提供統一的 `UICollectionView` 配置，包括註冊所需的 Cells 和 Section Header。
/// - 透過 AutoLayout 設定 `UICollectionView` 的佈局，確保視圖自適應。
///
/// ### 使用場景
/// - 用於 `OrderCustomerDetailsViewController` 的主要顯示視圖，整合訂單的各種資料，例如：
///   - 訂單條款訊息
///   - 客戶資訊（姓名、電話）
///   - 取件方式
///   - 訂單備註
///   - 提交訂單按鈕
///
/// ### 注意事項
/// - Cells 和 Section Header 的註冊在初始化時自動完成，確保視圖加載時可以直接使用。
/// - `orderCustomerDetailsCollectionView` 是 `UICollectionView` 的自訂子類別，負責統一配置佈局與樣式，減少重複代碼。
class OrderCustomerDetailsView: UIView {
    
    // MARK: - UI Elements
    
    /// 主要的 `UICollectionView`，用於展示訂單客戶詳情的所有資訊
    private(set) var orderCustomerDetailsCollectionView = OrderCustomerDetailsCollectionView()
    
    // MARK: - Initializer
    
    /// 初始化訂單詳情視圖
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
    
    /// 註冊所需的 Cells 和 Section Header
    ///
    /// - 此方法負責將所有自訂的 Cell 和 Header 註冊到 `orderCustomerDetailsCollectionView`。
    private func registerCells() {
        orderCustomerDetailsCollectionView.register(OrderTermsMessageCell.self, forCellWithReuseIdentifier: OrderTermsMessageCell.reuseIdentifier)
        orderCustomerDetailsCollectionView.register(OrderCustomerInfoCell.self, forCellWithReuseIdentifier: OrderCustomerInfoCell.reuseIdentifier)
        orderCustomerDetailsCollectionView.register(OrderPickupMethodCell.self, forCellWithReuseIdentifier: OrderPickupMethodCell.reuseIdentifier)
        orderCustomerDetailsCollectionView.register(OrderCustomerNoteCell.self, forCellWithReuseIdentifier: OrderCustomerNoteCell.reuseIdentifier)
        orderCustomerDetailsCollectionView.register(OrderCustomerSubmitCell.self, forCellWithReuseIdentifier: OrderCustomerSubmitCell.reuseIdentifier)
        
        orderCustomerDetailsCollectionView.register(OrderCustomerDetailsSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OrderCustomerDetailsSectionHeaderView.headerIdentifier)
    }
    
    /// 設定 `UICollectionView` 的 AutoLayout
    private func setupLayout() {
        addSubview(orderCustomerDetailsCollectionView)
        
        NSLayoutConstraint.activate([
            orderCustomerDetailsCollectionView.topAnchor.constraint(equalTo: topAnchor),
            orderCustomerDetailsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            orderCustomerDetailsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            orderCustomerDetailsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
