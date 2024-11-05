//
//  OrderConfirmationCustomerInfoCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

// MARK: - ### OrderConfirmationCustomerInfoCell 重點筆記

/**
 ## OrderConfirmationCustomerInfoCell 重點筆記

 `What:`
    
    - `OrderConfirmationCustomerInfoCell` 顯示顧客的基本資訊，包括姓名、電話、取件方式、外送地址或取件店名。

 `Why:`
 
 1.` StackView 使用的好處`：使用 StackView 可以輕鬆排列多個元素，並自動調整其佈局，簡化了約束設置。
 2. `隱藏不必要的 StackView`：依據取件方式顯示相應內容，以減少無用的資訊，提升用戶體驗。
 3. `避免重複邏輯`：利用 `updatePickupMethodDetails` 方法集中處理取件方式相關的顯示邏輯，減少配置和重複的顯示操作。

 `How:`
 
 1. 使用 `setupLayout()` 方法設置每個 StackView 的排列和約束。
 2. 在 `configure(with:)` 方法中設置顧客的姓名、電話和取件方式。
 3. 在 `updatePickupMethodDetails(for:storeName:address:)` 方法中根據取件方式控制地址和店名的顯示。
    - 當取件方式為「外送服務」時，只顯示地址 StackView。
    - 當取件方式為「到店取件」時，只顯示店名 StackView。
 */


import UIKit

/// 顯示顧客的姓名、電話等資訊的Cell
class OrderConfirmationCustomerInfoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderConfirmationCustomerInfoCell"
    
    // MARK: - UI Elements
    
    // Name StackView
    private let nameTitleLabel = createLabel(text: "Name:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let nameValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor: .gray, scaleFactor: 0.5)
    private let nameStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Phone StackView
    private let phoneTitleLabel = createLabel(text: "Phone:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let phoneValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor:  .gray, scaleFactor: 0.5)
    private let phoneStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // PickUpMethod StackView
    private let pickupMethodTitleLabel = createLabel(text: "Pickup Method:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let pickupMethodValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor: .gray)
    private let pickupMethodStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Store StackView
    private let storeTitleLabel = createLabel(text: "Store:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let storeValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor: .gray, scaleFactor: 0.5)
    private let storeStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Address StackView
    private let addressTitleLabel = createLabel(text: "Address:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let addressValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textAlignment: .right, textColor: .gray, scaleFactor: 0.5)
    private let addressStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Notes StackView (垂直排列)
    private let notesTitleLabel = createLabel(text: "Notes:", font: UIFont.systemFont(ofSize: 16, weight: .semibold))
    private let notesValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), numberOfLines: 0, textColor: .gray, scaleFactor: 0.5)
    private let notesStackView = createStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)
    
    // Main StackView
    private let mainStackView = createStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        styleCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 Cell 的布局
    private func setupLayout() {
        // 配置每個水平 StackView 的內容
        nameStackView.addArrangedSubview(nameTitleLabel)
        nameStackView.addArrangedSubview(nameValueLabel)
        
        phoneStackView.addArrangedSubview(phoneTitleLabel)
        phoneStackView.addArrangedSubview(phoneValueLabel)
        
        pickupMethodStackView.addArrangedSubview(pickupMethodTitleLabel)
        pickupMethodStackView.addArrangedSubview(pickupMethodValueLabel)
        
        storeStackView.addArrangedSubview(storeTitleLabel)
        storeStackView.addArrangedSubview(storeValueLabel)
        
        addressStackView.addArrangedSubview(addressTitleLabel)
        addressStackView.addArrangedSubview(addressValueLabel)
        
        notesStackView.addArrangedSubview(notesTitleLabel)
        notesStackView.addArrangedSubview(notesValueLabel)
        
        // 將所有子 StackView 添加到主 StackView
        mainStackView.addArrangedSubview(nameStackView)
        mainStackView.addArrangedSubview(OrderConfirmationCustomerInfoCell.createSeparatorView(height: 1))
        mainStackView.addArrangedSubview(phoneStackView)
        mainStackView.addArrangedSubview(OrderConfirmationCustomerInfoCell.createSeparatorView(height: 1))
        mainStackView.addArrangedSubview(pickupMethodStackView)
        mainStackView.addArrangedSubview(OrderConfirmationCustomerInfoCell.createSeparatorView(height: 1))
        mainStackView.addArrangedSubview(storeStackView)
        mainStackView.addArrangedSubview(addressStackView)
        mainStackView.addArrangedSubview(OrderConfirmationCustomerInfoCell.createSeparatorView(height: 1))
        mainStackView.addArrangedSubview(notesStackView)
        
        // 添加主 StackView 到 contentView
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    /// 配置 Cell 的樣式（圓角和背景色）
    private func styleCell() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = UIColor.lightWhiteGray.withAlphaComponent(0.3)
    }
    
    // MARK: - Factory Methods
    
    /// 建立並配置 UILabel
    private static func createLabel(text: String? = nil, font: UIFont, numberOfLines: Int = 1, textAlignment: NSTextAlignment = .left, textColor: UIColor = .black, scaleFactor: CGFloat = 1.0) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = font
        label.numberOfLines = numberOfLines 
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.minimumScaleFactor = scaleFactor
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    /// 建立並配置 UIStackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, isHidden: Bool = false) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = isHidden
        return stackView
    }
    
    /// 建立一個分隔視圖（Separator View）
    /// - Parameter height: 分隔視圖的高度
    /// - Returns: 設置好的 UIView
    private static func createSeparatorView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        view.backgroundColor = UIColor.lightWhiteGray
        return view
    }
    
    
    // MARK: - Configuration Method
    
    /// 設置顧客資訊
    /// - Parameter customerDetails: 顧客詳細資料
    func configure(with customerDetails: OrderConfirmationCustomerDetails) {
        nameValueLabel.text = customerDetails.fullName
        phoneValueLabel.text = customerDetails.phoneNumber
        pickupMethodValueLabel.text = customerDetails.pickupMethod.rawValue
        configurePickupMethod(for: customerDetails)
        configureNotes(with: customerDetails.notes)
    }
    
    /// 設置取件方式相關的顯示
    private func configurePickupMethod(for customerDetails: OrderConfirmationCustomerDetails) {
        // 每次配置時，重置 Store 和 Address StackView 的顯示狀態
        storeStackView.isHidden = true
        addressStackView.isHidden = true
        
        switch customerDetails.pickupMethod {
        case .homeDelivery:
            if let address = customerDetails.address, !address.isEmpty {
                addressValueLabel.text = address
                addressStackView.isHidden = false
            }
        case .inStore:
            if let storeName = customerDetails.storeName, !storeName.isEmpty {
                storeValueLabel.text = storeName
                storeStackView.isHidden = false
            }
        }
    }
    
    /// 設置備註欄位
    /// - Parameter notes: 顧客的備註
    private func configureNotes(with notes: String?) {
        if let notes = notes, !notes.isEmpty {
            notesValueLabel.text = notes
        } else {
            notesValueLabel.text = "None"
        }
    }
    
}
