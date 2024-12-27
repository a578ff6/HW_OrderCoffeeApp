//
//  EditOrderItemView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// 定義並管理 `EditOrderItemViewController` 的主要視圖，包含 `UICollectionView`。
///
/// 此視圖負責組合 UI 元件，透過注入 `EditOrderItemLayoutProvider` 來設定 `EditOrderItemCollectionView`。
/// - 責任分離：`EditOrderItemView` 專注於 UI 設定，將 UICollectionView 的生成與佈局邏輯委派給 `EditOrderItemCollectionView`。
class EditOrderItemView: UIView {

    // MARK: - UI Elements

    /// 自訂的 `UICollectionView`，用於顯示飲品相關資訊與選項。
    private(set) var editOrderItemCollectionView: EditOrderItemCollectionView
    
    // MARK: - Initializer

    init(layoutProvider: EditOrderItemLayoutProvider = EditOrderItemLayoutProvider()) {
        self.editOrderItemCollectionView = EditOrderItemCollectionView(layoutProvider: layoutProvider)
        super.init(frame: .zero)
        setupView()
        registerCells()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 設置 `EditOrderItemView` 的主要視圖佈局。
    private func setupView() {
        addSubview(editOrderItemCollectionView)
        NSLayoutConstraint.activate([
            editOrderItemCollectionView.topAnchor.constraint(equalTo: topAnchor),
            editOrderItemCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            editOrderItemCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            editOrderItemCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊所有自定義的 `cell` 和 `supplementary views`。
    ///
    /// 確保 `EditOrderItemCollectionView` 能正確顯示各種元件。
    private func registerCells() {
        editOrderItemCollectionView.register(EditOrderItemImageCollectionViewCell.self, forCellWithReuseIdentifier: EditOrderItemImageCollectionViewCell.reuseIdentifier)
        editOrderItemCollectionView.register(EditOrderItemInfoCollectionViewCell.self, forCellWithReuseIdentifier: EditOrderItemInfoCollectionViewCell.reuseIdentifier)
        editOrderItemCollectionView.register(EditOrderItemSizeSelectionCollectionViewCell.self, forCellWithReuseIdentifier: EditOrderItemSizeSelectionCollectionViewCell.reuseIdentifier)
        editOrderItemCollectionView.register(EditOrderItemPriceInfoCollectionViewCell.self, forCellWithReuseIdentifier: EditOrderItemPriceInfoCollectionViewCell.reuseIdentifier)
        editOrderItemCollectionView.register(EditOrderItemOptionsCollectionViewCell.self, forCellWithReuseIdentifier: EditOrderItemOptionsCollectionViewCell.reuseIdentifier)
        
        editOrderItemCollectionView.register(EditOrderItemSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EditOrderItemSeparatorView.reuseIdentifier)
        editOrderItemCollectionView.register(EditOrderItemSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: EditOrderItemSeparatorView.reuseIdentifier)
    }
    
}
