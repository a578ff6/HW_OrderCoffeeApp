//
//  OrderrConfirmationItemDetailsCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/3.
//

// MARK: - OrderrConfirmationItemDetailsCell 筆記
/**
 
 ## OrderrConfirmationItemDetailsCell 筆記

 ---

 `* What`
 
 - `OrderrConfirmationItemDetailsCell` 是一個 `UICollectionViewCell`，用於顯示訂單中的單一飲品項目的詳細資訊。該 Cell 包括以下視覺元素：
 
 - 飲品圖片：展示飲品外觀。
 - 飲品名稱與副標題：顯示飲品的名稱與描述。
 - 尺寸與數量：顯示飲品的大小（如大杯、中杯）和訂購數量。
 - 價格：顯示每杯飲品的價格。
 - 底線：用於視覺分隔不同飲品項目。

 此 Cell 的核心目的是在訂單確認頁面中直觀地展示單個飲品項目的詳細資訊。

 ---

 `* Why`
 
 1. 增強使用者體驗：
 
    - 在訂單確認頁面中，使用者需要檢視訂單中每項飲品的詳細資訊，例如名稱、尺寸、數量和價格。
    - 提供直觀的界面，幫助使用者快速確認訂單內容是否正確。

 2. 結構化的視圖管理：
 
    - 將飲品項目的各種資訊模組化，保持代碼的可讀性與可擴展性。
    - 利用 `StackView` 將標題、副標題、尺寸與數量分組，實現視圖層次的清晰組織。

 3. 適應性與重複使用：
 
    - 使用 `UICollectionViewCell` 的可重複使用性，支持高效渲染多個飲品項目，降低記憶體佔用。
    - 靈活設計，可以根據需求輕鬆擴展，如添加促銷標籤或更多細節。

 ---

 `* How`
 
 1. 視圖組成與佈局：
 
    - 利用 `UIImageView` 顯示飲品圖片。
    - 使用自定義的 `UILabel`（如 `OrderConfirmationLabel`）顯示名稱、副標題、尺寸與數量等文字資訊。
    - 將相關的 UI 元素組合為 `StackView`（如 `titleAndSubtitleStackView` 和 `sizeAndQuantityStackView`），簡化視圖的排列與佈局。
    - 透過 Auto Layout 定義每個元素的約束，確保它們在不同螢幕尺寸下都能正確顯示。

 2. 優化的視覺設計：
 
    - 為圖片與文字添加邊框、分隔線與對齊設定，提升視覺效果。
    - 設定內容的壓縮與擴展優先級，確保價格標籤與文字資訊不會因佔位不足而被裁切。

 3. 代碼模組化：
 
    - 使用方法 `setupViews()`、`setupConstraints()` 等分開處理視圖初始化、佈局約束與內容配置。
    - 提供 `configure(with:)` 方法，便於設置每個飲品項目的資料。

 4. 重複使用與初始化管理：
 
    - 通過 `prepareForReuse()` 方法清空舊資料，確保 Cell 在重複使用時不會殘留先前的內容。
 */


import UIKit

/// 用於顯示訂單中的飲品項目詳情，包括名稱、數量、尺寸、價格等資訊的 Cell。
/// - 此 Cell 主要包含飲品圖片、標題、副標題、尺寸、數量及價格等視覺化元素。
class OrderrConfirmationItemDetailsCell: UICollectionViewCell {
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderrConfirmationItemDetailsCell"
    
    // MARK: - UI Elements
    
    /// 飲品圖片，用於展示飲品的外觀
    private let drinkImageView = OrderrConfirmationImageView(borderWidth: 2, borderColor: .deepBrown, cornerRadius: 15)
    
    /// 飲品項目標題
    private let titleLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 17), textColor: .black, numberOfLines: 1, scaleFactor: 0.7)
    
    /// 飲品項目副標題
    private let subtitleNameLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 13), textColor: .gray, numberOfLines: 2, scaleFactor: 0.5)
    
    /// 飲品項目尺寸
    private let sizeLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 14), textColor: .deepGreen, scaleFactor: 0.5)
    
    /// 飲品項目數量
    private let quantityLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 14))

    /// 飲品項目價格
    private let priceLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 15), textAlignment: .right)
    
    /// 飲品的杯子圖片 (`mug.fill`)
    private let quantityImageView = OrderConfirmationIconImageView(image: UIImage(systemName: "mug.fill"), tintColor: .deepGreen, size: 18, symbolWeight: .regular)

    /// 分隔尺寸與數量的分隔線
    private let separatorLabel = OrderrConfirmationSeparatorLabel()

    /// 飲品項目底線，用於視覺上分隔不同項目
    private let bottomLineView = OrderrConfirmationBottomLineView(backgroundColor: .lightWhiteGray, height: 1.0)

    
    // MARK: - StackView
    
    /// 包含標題、副標題及尺寸與數量的垂直堆疊視圖
    private let titleAndSubtitleStackView = OrderConfirmationStackView(axis: .vertical, spacing: 2, alignment: .leading, distribution: .fillProportionally)
    
    /// 包含尺寸與數量的水平堆疊視圖
    private let sizeAndQuantityStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .leading, distribution: .fill)

    /// 包含數量圖示與數量標籤的水平堆疊視圖
    private let quantityLabelAndImageStackView = OrderItemStackView(axis: .horizontal, spacing: 4, alignment: .fill, distribution: .fill)

    
    // MARK: - Layout Constants

    /// 尺寸常數
    private enum Layout {
        /// 飲品圖片的尺寸
        static let drinkImageSize: CGFloat = 80
        /// 尺寸標籤的固定寬度
        static let sizeLabelWidth: CGFloat = 80
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupSizes()
        setupContentPriorities()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置標題與副標題的垂直堆疊視圖
    /// - 包括 `titleLabel`、`subtitleNameLabel` 和 `sizeAndQuantityStackView`
    private func setupTitleAndSubtitleStack() {
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleNameLabel)
        titleAndSubtitleStackView.addArrangedSubview(sizeAndQuantityStackView)
    }
    
    /// 配置尺寸與數量的水平堆疊視圖
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
    
    /// 設置視圖約束
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
    
    /// 配置固定寬高相關的約束
    private func setupSizes() {
        NSLayoutConstraint.activate([
            drinkImageView.widthAnchor.constraint(equalToConstant: Layout.drinkImageSize),
            drinkImageView.heightAnchor.constraint(equalTo: drinkImageView.widthAnchor),
            sizeLabel.widthAnchor.constraint(equalToConstant: Layout.sizeLabelWidth),
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
    func configure(with orderItem: OrderConfirmationItem) {
        // 使用內嵌的 `drink` 屬性來設置飲品資料
        drinkImageView.kf.setImage(with: orderItem.drink.imageUrl, placeholder: UIImage.starbucksLogo)
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
