//
//  EditOrderItemImageCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// `EditOrderItemImageCollectionViewCell`
///
/// ### 功能說明
/// - 此類為顯示飲品圖片的自訂 `UICollectionViewCell`。
/// - 內部包含一個 `EditOrderItemImageView`，用於展示飲品的圖片，並支援圖片的動態加載。
///
/// ### 設計目標
/// 1. 簡化圖片展示邏輯：
///    - 提供方法配置圖片 URL，並使用圖片加載框架（例如 `Kingfisher`）來加載圖片。
/// 2. 提升視圖一致性：
///    - 採用 `contentMode` 設置，確保圖片以固定比例顯示，不會失真。
///
/// ### 使用建議
/// - 此 Cell 適用於展示靜態飲品圖片，適合用於飲品詳細資訊或清單畫面。
/// - 若需自訂比例或樣式，可修改內部 `DrinkDetailImageView` 的屬性。
class EditOrderItemImageCollectionViewCell: UICollectionViewCell {
    
    /// Cell 的重用識別碼
    static let reuseIdentifier = "EditOrderItemImageCollectionViewCell"
    
    // MARK: - UI Elements
    
    /// 用於顯示飲品圖片的 `UIImageView`
    private let drinkImageView = EditOrderItemImageView(contentMode: .scaleAspectFit)
    
    // MARK: - Initializers
    
    /// 初始化方法
    /// - Parameter frame: Cell 的初始框架
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置視圖
    private func setupViews() {
        contentView.addSubview(drinkImageView)
        
        NSLayoutConstraint.activate([
            drinkImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            drinkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            drinkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            drinkImageView.heightAnchor.constraint(equalTo: drinkImageView.widthAnchor, multiplier: 1.0)
        ])
    }
    
    // MARK: - Configure Method
    
    /// 配置 Cell 顯示的內容
    /// - Parameter imageUrl: 要顯示的圖片 URL
    /// - 此方法會使用圖片加載框架（如 `Kingfisher`）加載並顯示圖片。
    func configure(with imageUrl: URL) {
        drinkImageView.kf.setImage(with: imageUrl)
    }
    
    // MARK: - Lifecycle Methods
    
    /// 在 Cell 被重用前重置內容
    override func prepareForReuse() {
        super.prepareForReuse()
        drinkImageView.image = nil
    }
    
}
