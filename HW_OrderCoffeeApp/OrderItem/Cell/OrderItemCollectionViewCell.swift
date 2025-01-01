//
//  OrderItemCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/4.
//

// MARK: - 固定 sizeLabel 寬度
/**
 ## 固定 sizeLabel 寬度：
 
 - 固定 sizeLabel 寬度，確保無論內容多長，quantityLabel 都能保持固定位置。
 - 設置 sizeLabel 的 numberOfLines ，並設置 adjustsFontSizeToFitWidth 和 minimumScaleFactor，以確保文字能縮小以適應固定寬度。
 - 確保 sizeLabel 和 quantityLabel 之間的間距固定，並且 quantityLabel 的位置不會受到 sizeLabel 內容長度的影響。
 
 */


// MARK: - OrderItemCollectionViewCell 筆記
/**
 
 ## OrderItemCollectionViewCell 筆記

 `* What`
 
 `OrderItemCollectionViewCell` 是一個自訂的 `UICollectionViewCell`，專為展示訂單中的飲品項目設計。它包含以下主要功能：
 - 顯示飲品圖片 (`drinkImageView`)。
 - 顯示飲品標題、副標題、尺寸與數量等資訊。
 - 提供刪除按鈕讓使用者可移除項目。
 - 使用自訂的 UI 元件（例如 `OrderItemLabel`、`OrderItemDeleteButton`）以統一樣式和提升可讀性。

 -------------

 `* Why`
 
 `1. 視覺一致性與重複利用`
 
    透過自訂元件（如 `OrderItemLabel`、`OrderItemDeleteButton`）實現樣式統一，同時減少程式碼重複性，方便後續修改與擴展。
    
 `2. 邏輯清晰化`
 
    將視圖的配置、約束設置與優先級等邏輯分開，讓程式碼更具可讀性與可維護性。

 `3. 提升擴展性`
 
    透過分層與模組化設計（例如 `StackView`），讓介面元件更易於變動或新增功能。
 
 -------------

 `* How`
 
` 1. 設計架構`
 
 - 使用分層的方式，將 `setupViews`、`setupConstraints`、`setupSizes`、`setupContentPriorities` 等方法拆分處理。
 - 將堆疊視圖（`StackView`）細分為特定用途的元件，例如 `titleAndSubtitleStackView` 和 `sizeAndQuantityStackView`。

 `2. 使用自訂元件`
 
 - 例如 `OrderItemLabel`、`OrderItemDeleteButton`，統一樣式並簡化元件的初始化與配置邏輯。

 `3. 定義常數`
 
 - 透過 `Layout` 列舉定義尺寸相關常數，避免數字硬編碼，讓程式碼更具彈性與可讀性。

 `4. 設置動作與行為`
 
 - 使用 `deleteAction` 作為刪除按鈕的閉包回呼，方便外部控制刪除行為。

 -------------
 
` * 程式碼結構摘要`
 
 - `setupViews()`：加入視圖到層級結構。
 - `setupConstraints()`：配置各視圖的位置約束。
 - `setupSizes()`：單獨處理與尺寸相關的約束，方便調整。
 - `setupContentPriorities()`：明確設定 `UILabel` 的擠壓與擴展優先級。
 - `configure(with:)`：配置 Cell 的內容，接收 `OrderItem` 模型。

 -------------

` * 使用情境舉例`
 
 - 清單展示頁面：用於展示使用者訂單中每個飲品項目。
 - 移除項目功能：刪除按鈕的行為透過閉包實現，允許高度自訂。

 */


import UIKit

/// `OrderItemCollectionViewCell` 是自訂的 `UICollectionViewCell`
/// 用於展示訂單中的飲品項目，包括圖片、標題、副標題、尺寸、數量、價格，以及刪除按鈕。
class OrderItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderItemCollectionViewCell"
    
    // MARK: - UI Elements
    
    /// 飲品項目圖片
    private let drinkImageView = OrderItemImageView()
    
    /// 飲品項目標題
    private let titleLabel = OrderItemLabel(font: .systemFont(ofSize: 17), numberOfLines: 1, scaleFactor: 0.7)
    
    /// 飲品項目副標題
    private let subtitleNameLabel = OrderItemLabel(font: .systemFont(ofSize: 13), textColor: .gray, numberOfLines: 2, scaleFactor: 0.5)
    
    /// 飲品項目尺寸
    private let sizeLabel = OrderItemLabel(font: .systemFont(ofSize: 14), textColor: .deepGreen, scaleFactor: 0.5)
    
    /// 飲品項目數量
    private let quantityLabel = OrderItemLabel(font: .systemFont(ofSize: 14))
    
    /// 飲品項目價格
    private let priceLabel = OrderItemLabel(font: .systemFont(ofSize: 15), textAlignment: .right)
    
    /// 飲品的杯子圖片 (`mug.fill`)
    private let quantityImageView = OrderItemIconImageView(image: UIImage(systemName: "mug.fill"), tintColor: .deepGreen, size: 18, symbolWeight: .regular)
    
    /// 用來區隔尺寸與數量的分隔線
    private let separatorLabel = OrderItemSeparatorLabel()
    
    /// 飲品項目底線
    private let bottomLineView = OrderItemBottomLineView()
    
    /// 飲品項目刪除按鈕
    private let deleteButton = OrderItemDeleteButton(iconSize: 22, iconColor: .darkGray)
    
    // MARK: - StackView
    
    /// 標題與副標題的垂直堆疊
    private let titleAndSubtitleStackView = OrderItemStackView(axis: .vertical, spacing: 2, alignment: .leading, distribution: .fillProportionally)
    
    /// 尺寸與數量的水平堆疊
    private let sizeAndQuantityStackView = OrderItemStackView(axis: .horizontal, spacing: 8, alignment: .leading, distribution: .fill)
    
    /// 數量圖片與標籤的水平堆疊
    private let quantityLabelAndImageStackView = OrderItemStackView(axis: .horizontal, spacing: 4, alignment: .fill, distribution: .fill)
    
    /// 價格與刪除按鈕的垂直堆疊
    private let priceAndDeleteStackView = OrderItemStackView(axis: .vertical, spacing: 2, alignment: .center, distribution: .fillProportionally)
    
    
    // MARK: - Actions
    
    /// 刪除按鈕點擊動作
    var deleteAction: (() -> Void)?
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let drinkImageSize: CGFloat = 80
        static let deleteButtonSize: CGFloat = 44
        static let priceAndDeleteSize: CGFloat = 88
        static let bottomLineHeight: CGFloat = 1
        static let sizeLabelWidth: CGFloat = 80
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupSizes()
        setupContentPriorities()
        setActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置標題與副標題的 StackView
    private func setupTitleAndSubtitleStack() {
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleNameLabel)
        titleAndSubtitleStackView.addArrangedSubview(sizeAndQuantityStackView)
    }
    
    /// 設置尺寸與數量的 StackView
    private func setupSizeAndQuantityStack() {
        quantityLabelAndImageStackView.addArrangedSubview(quantityImageView)
        quantityLabelAndImageStackView.addArrangedSubview(quantityLabel)
        
        sizeAndQuantityStackView.addArrangedSubview(sizeLabel)
        sizeAndQuantityStackView.addArrangedSubview(separatorLabel)
        sizeAndQuantityStackView.addArrangedSubview(quantityLabelAndImageStackView)
    }
    
    /// 設置價格與刪除按鈕的 StackView
    private func setupPriceAndDeleteStack() {
        priceAndDeleteStackView.addArrangedSubview(priceLabel)
        priceAndDeleteStackView.addArrangedSubview(deleteButton)
    }
    
    /// 初始化並設置所有視圖
    private func setupViews() {
        setupTitleAndSubtitleStack()
        setupSizeAndQuantityStack()
        setupPriceAndDeleteStack()
        
        contentView.addSubview(drinkImageView)
        contentView.addSubview(titleAndSubtitleStackView)
        contentView.addSubview(priceAndDeleteStackView)
        contentView.addSubview(bottomLineView)
    }
    
    /// 配置位置相關的約束
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            drinkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            drinkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            titleAndSubtitleStackView.topAnchor.constraint(equalTo: drinkImageView.topAnchor),
            titleAndSubtitleStackView.leadingAnchor.constraint(equalTo: drinkImageView.trailingAnchor, constant: 15),
            titleAndSubtitleStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceAndDeleteStackView.leadingAnchor, constant: -15),
            titleAndSubtitleStackView.bottomAnchor.constraint(equalTo: drinkImageView.bottomAnchor),
            
            sizeAndQuantityStackView.leadingAnchor.constraint(equalTo: titleAndSubtitleStackView.leadingAnchor),
            sizeAndQuantityStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceAndDeleteStackView.leadingAnchor, constant: -15),
            
            priceAndDeleteStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceAndDeleteStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            bottomLineView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    /// 配置寬高相關的約束
    private func setupSizes() {
        NSLayoutConstraint.activate([
            
            drinkImageView.widthAnchor.constraint(equalToConstant: Layout.drinkImageSize),
            drinkImageView.heightAnchor.constraint(equalTo: drinkImageView.widthAnchor),
            
            sizeLabel.widthAnchor.constraint(equalToConstant: Layout.sizeLabelWidth),
            
            priceAndDeleteStackView.widthAnchor.constraint(equalToConstant: Layout.priceAndDeleteSize),
            
            deleteButton.widthAnchor.constraint(equalToConstant: Layout.deleteButtonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: Layout.deleteButtonSize),
            
            bottomLineView.heightAnchor.constraint(equalToConstant: Layout.bottomLineHeight)
        ])
    }
    
    /// 配置內容優先級
    private func setupContentPriorities() {
        // 設置標題與副標題的優先級
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subtitleNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // 設置價格標籤的優先級
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    /// 設置動作行為
    private func setActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Action
    
    /// 刪除按鈕觸發事件
    @objc private func deleteButtonTapped() {
        deleteAction?()
    }
    
    // MARK: - Configure Method
    
    /// 設置 Cell 的內容
    /// - Parameter orderItem: 包含訂單飲品的詳細資訊
    func configure(with orderItem: OrderItem) {
        drinkImageView.kf.setImage(with: orderItem.drink.imageUrl)
        titleLabel.text = orderItem.drink.name
        subtitleNameLabel.text = orderItem.drink.subName
        sizeLabel.text = "\(orderItem.size)"
        quantityLabel.text = "\(orderItem.quantity)"
        priceLabel.text = "\(orderItem.price) 元/杯"
    }
    
    // MARK: - Lifecycle Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        drinkImageView.image = nil
        titleLabel.text = nil
        subtitleNameLabel.text = nil
        sizeLabel.text = nil
        quantityLabel.text = nil
        priceLabel.text = nil
    }
    
}
