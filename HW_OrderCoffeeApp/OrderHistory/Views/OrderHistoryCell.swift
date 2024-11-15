//
//  OrderHistoryCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

import UIKit

/// 顯示歷史訂單的 UITableViewCell，包含顧客姓名、訂單日期、取件方式、訂單編號及訂單金額等資訊。
class OrderHistoryCell: UITableViewCell {

    static let reuseIdentifier = "OrderHistoryCell"

    // MARK: - UI Elements
    
    /// 顯示顧客姓名。
    private let nameLabel = createLabel(font: UIFont.systemFont(ofSize: 18, weight: .medium), textAlignment: .left)
    /// 顯示訂單成立日期。
    private let dateLabel = createLabel(font: UIFont.systemFont(ofSize: 14, weight: .light), textColor: .lightGray, textAlignment: .right)
    
    /// 根據取件方式顯示不同的 SF Symbol 圖標
    private let pickupIconImageView = createImageView(height: 24, weight: 24)
    /// 顯示取件方式。
    private let pickupMethodLabel = createLabel(font: UIFont.systemFont(ofSize: 15, weight: .semibold), textColor: .gray)
    
    /// 顯示訂單編號。
    private let orderIdLabel = createLabel(font: UIFont.systemFont(ofSize: 16, weight: .medium), textColor: .darkGray, scaleFactor: 0.5)
   
    /// 顯示訂單金額。
    private let totalAmountLabel = createLabel(font: UIFont.systemFont(ofSize: 16, weight: .bold), textColor: .deepGreen)
    
    
    // MARK: - StackView
    
    /// 名字與日期
    private let nameAndDateStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .fill)
    /// 取件方式
    private let pickupStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .fill)
    // 創建垂直排列的 StackView，包含名稱、日期、取件方式、訂單編號和總金額
    private let textStackView = createStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 設定 Cell 的布局，包含建立 UI 元件並將其添加到內容視圖
    private func setupView() {
        
        // Name & Date
        nameAndDateStackView.addArrangedSubview(nameLabel)
        nameAndDateStackView.addArrangedSubview(dateLabel)
        
        // Pickup
        pickupStackView.addArrangedSubview(pickupIconImageView)
        pickupStackView.addArrangedSubview(pickupMethodLabel)
        
        // textStackView
        textStackView.addArrangedSubview(nameAndDateStackView)
        textStackView.addArrangedSubview(pickupStackView)
        textStackView.addArrangedSubview(orderIdLabel)
        textStackView.addArrangedSubview(totalAmountLabel)
        
        contentView.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
    }
    
    // MARK: - Factory Methods
    
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
    
    /// 建立並配置 UIImageView
    private static func createImageView(height: CGFloat, weight: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: weight).isActive = true
        return imageView
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
    
    // MARK: - Configure Method

    /// 根據 OrderHistory 配置 Cell 的內容
    /// - Parameter order: 歷史訂單物件，用於顯示 Cell 的相關資訊
    func configure(with order: OrderHistory) {
        nameLabel.text = order.customerDetails.fullName
        dateLabel.text = DateFormatter.localizedString(from: order.timestamp, dateStyle: .medium, timeStyle: .short)
        orderIdLabel.text = "Order ID: \(order.id)"
        totalAmountLabel.text = "NT$ \(order.totalAmount)"

        
        // 根據取件方式設定圖標和取件方式的文字
        switch order.customerDetails.pickupMethod {
        case .homeDelivery:
            pickupMethodLabel.text = "Home Delivery"
            pickupIconImageView.image = UIImage(systemName: "bicycle")
        case .inStore:
            pickupMethodLabel.text = "In Store"
            pickupIconImageView.image = UIImage(systemName: "storefront")
        }
    }
    
    // MARK: - UITableViewCell Reuse
    
    // 重設顯示內容，避免重複使用的 cell 中出現上一次顯示的資料
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        dateLabel.text = nil
        orderIdLabel.text = nil
        totalAmountLabel.text = nil
        pickupMethodLabel.text = nil
        pickupIconImageView.image = nil
    }
    
}
