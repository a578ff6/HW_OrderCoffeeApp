//
//  OrderrConfirmationItemDetailsCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/3.
//

import UIKit

/// 顯示飲品項目詳情（如名稱、數量、價格等）
class OrderrConfirmationItemDetailsCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderrConfirmationItemDetailsCell"
    
    // MARK: - UI Elements
    
    // Drink ImageView
    private let drinkImageView = createDrinkImageView(height: 80, weight: 80)

    // Drink Name
    private let titleLabel = createLabel(font: UIFont.systemFont(ofSize: 17), numberOfLines: 1, scaleFactor: 0.7)
    private let subtitleNameLabel = createLabel(font: UIFont.systemFont(ofSize: 13), numberOfLines: 2, textColor: .gray, scaleFactor: 0.5)
    private let titleAndSubtitleStackView = createStackView(axis: .vertical, spacing: 2, alignment: .leading, distribution: .fillProportionally)

    // Size and Quantity Labels
    private let sizeLabel = createLabel(font: UIFont.systemFont(ofSize: 14), textColor: .deepGreen, scaleFactor: 0.5)
    private let separatorLabel = createSeparatorLabel()
    private let quantityImageView = createQuantityImageView(height: 20, weight: 20)

    private let quantityLabel = createLabel(font: UIFont.systemFont(ofSize: 14))
    private let sizeAndQuantityStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .leading, distribution: .equalSpacing)

    // PriceLabel
    private let priceLabel = createLabel(font: UIFont.systemFont(ofSize: 15), textAlignment: .right)
    
    // BottomLineView
    private let bottomLineView = createBottomLineView(height: 1)
    
    // Main StackView
    private let mainStackView = createStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    private func setupViews() {
        // 配置 titleAndSubtitleStackView 的內容
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleNameLabel)
        
        // 配置 sizeAndQuantityStackView 的內容
        sizeAndQuantityStackView.addArrangedSubview(sizeLabel)
        sizeAndQuantityStackView.addArrangedSubview(separatorLabel)
        sizeAndQuantityStackView.addArrangedSubview(quantityImageView)
        sizeAndQuantityStackView.addArrangedSubview(quantityLabel)
        
        // 設置 sizeLabel 的固定寬度（尺寸的文字長度不同，它的寬度也不會變動）
        sizeLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        // 在 titleAndSubtitleStackView 下方添加 sizeAndQuantityStackView
        let titleAndDetailsStackView = OrderrConfirmationItemDetailsCell.createStackView(axis: .vertical, spacing: 8, alignment: .leading, distribution: .fill)
        titleAndDetailsStackView.addArrangedSubview(titleAndSubtitleStackView)
        titleAndDetailsStackView.addArrangedSubview(sizeAndQuantityStackView)
        
        // 配置 mainStackView 的內容
        mainStackView.addArrangedSubview(drinkImageView)
        mainStackView.addArrangedSubview(titleAndDetailsStackView)
        mainStackView.addArrangedSubview(priceLabel)
        
        // 將 mainStackView、bottomLineView 添加到 contentView
        contentView.addSubview(mainStackView)
        contentView.addSubview(bottomLineView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            
            bottomLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    // MARK: - Factory Methods

    /// 建立飲品圖片視圖
    private static func createDrinkImageView(height: CGFloat, weight: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.deepBrown.cgColor
        imageView.layer.cornerRadius = 15
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: weight).isActive = true
        imageView.clipsToBounds = true
        return imageView
    }
    
    /// 建立數量圖片視圖
    private static func createQuantityImageView(height: CGFloat, weight: CGFloat) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "mug.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .deepGreen
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: weight).isActive = true
        return imageView
    }
    
    /// 建立並配置 UILabel
    private static func createLabel(text: String? = nil, font: UIFont, numberOfLines: Int = 1, textColor: UIColor = .black, scaleFactor: CGFloat = 1.0, textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = font
        label.numberOfLines = numberOfLines
        label.textColor = textColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = scaleFactor
        label.textAlignment = textAlignment
        return label
    }
    
    /// 建立分隔符號標籤
    private static func createSeparatorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "|"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }
    
    /// 建立並配置 UIStackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// 建立底部分隔線視圖
    private static func createBottomLineView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightWhiteGray
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    // MARK: - Configuration Method

    /// 設置飲品項目詳情
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
