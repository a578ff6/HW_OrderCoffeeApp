//
//  OrderrHistoryDetailItemCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//

import UIKit

/// `OrderrHistoryDetailItemCell`
///
/// 此類別是一個自訂的 `UICollectionViewCell`，專為展示訂單歷史細項的飲品項目而設計。
/// 提供顯示飲品圖片、名稱、尺寸、數量及價格的功能。
///
/// - 特點:
///   1. 使用自訂的子類元件 (`OrderHistoryDetailImageView`, `OrderHistoryDetailLabel`) 提高可讀性與重用性。
///   2. 透過 `StackView` 模組化布局，簡化排列邏輯。
///   3. 提供自適應內容大小的優先級設置，確保元件間的布局穩定性。
class OrderrHistoryDetailItemCell: UICollectionViewCell {
    
    /// Cell 的重用標識符，用於註冊和重用
    static let reuseIdentifier = "OrderrHistoryDetailItemCell"
    
    // MARK: - UI Elements
    
    /// 飲品圖片，用於展示飲品的外觀
    private let drinkImageView = OrderHistoryDetailImageView(borderWidth: 2, borderColor: .deepBrown, cornerRadius: 15, size: 80)
    
    /// 飲品名稱標籤，用於顯示飲品名稱。
    private let titleLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 17), textColor: .black, numberOfLines: 1, scaleFactor: 0.7)
    
    /// 飲品副標題標籤，用於顯示飲品的額外資訊。
    private let subtitleNameLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 13), textColor: .gray, numberOfLines: 2, scaleFactor: 0.5)
    
    /// 尺寸標籤，用於顯示飲品的尺寸。
    /// - 固定寬度為 80，以確保布局的一致性。能夠保持距離。
    private let sizeLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 14), textColor: .deepGreen, scaleFactor: 0.5, width: 80)
    
    /// 飲品數量標籤，用於顯示飲品的訂購數量。
    private let quantityLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 14))
    
    /// 飲品價格標籤，用於顯示飲品的單價。
    private let priceLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 15), textAlignment: .right)
    
    /// 飲品的杯子圖片 (`mug.fill`)
    private let quantityImageView = OrderHistoryDetailIconImageView(image: UIImage(systemName: "mug.fill"), tintColor: .deepGreen, size: 18, symbolWeight: .regular)
    
    /// 分隔尺寸與數量的分隔線。
    private let separatorLabel = OrderHistoryDetailSeparatorLabel()
    
    /// 飲品項目底線，用於視覺上分隔不同項目
    private let bottomLineView = OrderHistoryDetailBottomLineView(backgroundColor: .lightWhiteGray, height: 1)
    
    
    // MARK: - StackView
    
    /// 包含標題、副標題及尺寸與數量的垂直堆疊視圖
    private let titleAndSubtitleStackView = OrderHistoryDetailStackView(axis: .vertical, spacing: 2, alignment: .leading, distribution: .fillProportionally)
    
    /// 包含尺寸與數量的水平堆疊視圖
    private let sizeAndQuantityStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .leading, distribution: .equalSpacing)
    
    /// 包含數量圖示與數量標籤的水平堆疊視圖
    private let quantityLabelAndImageStackView = OrderItemStackView(axis: .horizontal, spacing: 4, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupContentPriorities()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置標題與副標題的垂直堆疊視圖
    ///
    /// - 包括 `titleLabel`、`subtitleNameLabel` 和 `sizeAndQuantityStackView`
    private func setupTitleAndSubtitleStack() {
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleNameLabel)
        titleAndSubtitleStackView.addArrangedSubview(sizeAndQuantityStackView)
    }
    
    /// 配置尺寸與數量的水平堆疊視圖
    ///
    /// - 包括 `sizeLabel`、分隔線與數量視圖
    private func setupSizeAndQuantityStack() {
        quantityLabelAndImageStackView.addArrangedSubview(quantityImageView)
        quantityLabelAndImageStackView.addArrangedSubview(quantityLabel)
        
        sizeAndQuantityStackView.addArrangedSubview(sizeLabel)
        sizeAndQuantityStackView.addArrangedSubview(separatorLabel)
        sizeAndQuantityStackView.addArrangedSubview(quantityLabelAndImageStackView)
    }
    
    /// 配置所有視圖
    private func setupViews() {
        setupTitleAndSubtitleStack()
        setupSizeAndQuantityStack()
        
        contentView.addSubview(drinkImageView)
        contentView.addSubview(titleAndSubtitleStackView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(bottomLineView)
    }
    
    /// 配置所有視圖的約束。
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // 飲品圖片
            drinkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            drinkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            // 標題與副標題的堆疊視圖
            titleAndSubtitleStackView.topAnchor.constraint(equalTo: drinkImageView.topAnchor),
            titleAndSubtitleStackView.leadingAnchor.constraint(equalTo: drinkImageView.trailingAnchor, constant: 15),
            titleAndSubtitleStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -15),
            titleAndSubtitleStackView.bottomAnchor.constraint(equalTo: drinkImageView.bottomAnchor),
            
            // 價格標籤
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            
            // 底線
            bottomLineView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
    
    // MARK: - Configuration Method
    
    /// 設置飲品項目詳情
    ///
    /// - Parameter orderItem: 訂單項目資料
    func configure(with orderItem: OrderHistoryItemDetail) {
        // 使用內嵌的 `drink` 屬性來設置飲品資料
        drinkImageView.kf.setImage(with: orderItem.drink.imageUrl, placeholder: UIImage.starbucksLogo)
        titleLabel.text = orderItem.drink.name
        subtitleNameLabel.text = orderItem.drink.subName
        sizeLabel.text = "\(orderItem.size)"
        quantityLabel.text = "\(orderItem.quantity)"
        priceLabel.text = "\(orderItem.price) 元/杯"
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重設 Cell 的內容。
    ///
    /// - 清除所有顯示的數據，準備 Cell 進行重用。
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
