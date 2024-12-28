//
//  EditOrderItemCollectionView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// 自訂的 UICollectionView，專門用於 `編輯飲品項目`頁面。
///
/// 此類別負責初始化並配置 `UICollectionView`，透過 `EditOrderItemLayoutProvider` 提供動態生成的 `Compositional Layout`，
/// 適合顯示多個 Section 具有不同佈局的複雜資訊，例如飲品圖片、尺寸選擇、價格資訊等。
class EditOrderItemCollectionView: UICollectionView {
    
    // MARK: - Initializer
    
    /// 初始化自訂的 UICollectionView
    /// - Parameter layoutProvider: 提供 Layout 的類別，根據 Section 動態生成 Compositional Layout
    init(layoutProvider: EditOrderItemLayoutProvider) {
        
        // 使用 Compositional Layout 根據 Section 提供對應的佈局
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = EditOrderItemSection(rawValue: sectionIndex) else { return nil }
            return layoutProvider.generateLayout(for: section)
        }
        super.init(frame: .zero, collectionViewLayout: layout)
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 UICollectionView 的基本屬性
    ///
    /// 包括背景顏色、是否顯示垂直滾動條等，確保介面符合頁面設計需求。
    private func configureCollectionView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
        self.showsVerticalScrollIndicator = true
    }
    
}
