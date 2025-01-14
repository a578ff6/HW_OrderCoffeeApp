//
//  OrderHistoryDetailCustomerInfoCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//

import UIKit

/// `OrderHistoryDetailCustomerInfoCell`
///
/// 此 Cell 用於顯示歷史訂單的顧客相關資訊，內容包括姓名、電話、取件方式、門市或地址，以及備註等。
///
/// - 設計目標:
///   1. 結構化布局:
///      - 使用多個 StackView 組織顯示內容，保持界面整潔且易於擴展。
///   2. 動態顯示:
///      - 根據顧客的取件方式（宅配或門市）動態隱藏不相關的字段，確保界面簡潔。
///
/// - 主要功能:
///   - 顯示顧客的基本資料：姓名和電話。
///   - 動態顯示取件方式相關資訊（門市或地址）。
///   - 顯示顧客的備註，若無備註則顯示預設值 "None"。
class OrderHistoryDetailCustomerInfoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderHistoryDetailCustomerInfoCell"
    
    // MARK: - UI Elements
    
    // Name StackView
    private let nameTitleLabel = OrderHistoryDetailLabel(text: "Name：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let nameValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let nameStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Phone StackView
    private let phoneTitleLabel = OrderHistoryDetailLabel(text: "Phone：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let phoneValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let phoneStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // PickUpMethod StackView
    private let pickupMethodTitleLabel = OrderHistoryDetailLabel(text: "Pickup Method：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let pickupMethodValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    private let pickupMethodStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Store StackView
    private let storeTitleLabel = OrderHistoryDetailLabel(text: "Store：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let storeValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let storeStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Address StackView
    private let addressTitleLabel = OrderHistoryDetailLabel(text: "Address：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let addressValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let addressStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Notes StackView (垂直排列)
    private let notesTitleLabel = OrderHistoryDetailLabel(text: "Notes：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let notesValueLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 0, scaleFactor: 0.5)
    private let notesStackView = OrderHistoryDetailStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)
    
    // Main StackView
    private let mainStackView = OrderHistoryDetailStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
    
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
        setupStackViewContent()
        setupMainStackView()
        setupMainStackViewConstraints()
    }
    
    /// 配置各個子 StackView 的內容
    /// - 將每個標題與內容的組合添加到對應的 StackView
    private func setupStackViewContent() {
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
    }
    
    /// 將所有子 StackView 添加到主 StackView，並插入分隔線
    private func setupMainStackView() {
        mainStackView.addArrangedSubview(nameStackView)
        mainStackView.addArrangedSubview(OrderHistoryDetailBottomLineView())
        mainStackView.addArrangedSubview(phoneStackView)
        mainStackView.addArrangedSubview(OrderHistoryDetailBottomLineView())
        mainStackView.addArrangedSubview(pickupMethodStackView)
        mainStackView.addArrangedSubview(OrderHistoryDetailBottomLineView())
        mainStackView.addArrangedSubview(storeStackView)
        mainStackView.addArrangedSubview(addressStackView)
        mainStackView.addArrangedSubview(OrderHistoryDetailBottomLineView())
        mainStackView.addArrangedSubview(notesStackView)
        
        contentView.addSubview(mainStackView)
    }
    
    /// 配置主 StackView 的 Auto Layout
    private func setupMainStackViewConstraints() {
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
    
    // MARK: - Configuration Method
    
    /// 設置顧客資訊
    ///
    /// - Parameter customerDetails: 顧客詳細資料
    func configure(with customerDetails: OrderHistoryDetailCustomerInfo) {
        nameValueLabel.text = customerDetails.fullName
        phoneValueLabel.text = customerDetails.phoneNumber
        pickupMethodValueLabel.text = customerDetails.pickupMethod.rawValue
        configurePickupMethod(for: customerDetails)
        configureNotes(with: customerDetails.notes)
    }
    
    /// 配置取件方式相關的顯示
    ///
    /// - 根據取件方式顯示門市或地址資訊
    private func configurePickupMethod(for customerDetails: OrderHistoryDetailCustomerInfo) {
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
    
    /// 配置備註欄位的顯示
    ///
    /// - Parameter notes: 顧客的備註，若為空則顯示預設值 "None"
    private func configureNotes(with notes: String?) {
        if let notes = notes, !notes.isEmpty {
            notesValueLabel.text = notes
        } else {
            notesValueLabel.text = "None"
        }
    }
    
}
