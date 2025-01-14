//
//  OrderConfirmationCustomerInfoCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

// MARK: - OrderConfirmationCustomerInfoCell 筆記
/**
 
 ## OrderConfirmationCustomerInfoCell 筆記

 `* What`
 
 - `OrderConfirmationCustomerInfoCell` 是一個自訂的 `UICollectionViewCell`，專門用於顯示顧客相關的詳細資訊，包括：
 
 - 姓名 (Name)
 - 電話 (Phone)
 - 取件方式 (Pickup Method)
 - 門市名稱或地址 (Store or Address)
 - 備註 (Notes)

 此 Cell 使用多個水平方向和垂直方向的 StackView 來排列資訊，並包含分隔線來區分各資訊區塊。

 -----------

 `* Why`
 
 1. 結構化資訊顯示
 
    - 顧客的姓名、電話、取件方式等屬於多層次資訊，使用 StackView 讓資訊排列更有條理，提升可讀性。
    - 使用分隔線來分區域顯示，強化視覺層次感。

 2. 可重複使用
 
    - Cell 的結構化設計便於在訂單確認頁面或其他需要顯示顧客資訊的場景中多次重複使用，減少重複代碼。

 3. 動態配置顯示內容
 
    - 支援動態顯示門市或地址，根據顧客選擇的取件方式調整內容，增加靈活性。
    - 當備註為空時，提供預設值 "None"，避免空白顯示影響使用者體驗。

 -----------

 `* How`

 1. 布局設計
 
    - 使用多個 `StackView` 來組織資訊，包含：
      - 水平方向的 StackView 顯示標題與內容（例如 `Name：John Doe`）。
      - 垂直方向的主 StackView 負責排列所有資訊區塊。
    - 引入 `OrderrConfirmationBottomLineView` 作為分隔線，統一分隔樣式，提升代碼一致性與可維護性。

 2. 動態顯示內容
 
    - 根據顧客選擇的取件方式：
      - 若是宅配（Home Delivery），則顯示地址欄位並隱藏門市欄位。
      - 若是門市取件（In Store），則顯示門市欄位並隱藏地址欄位。

 3. 樣式與佈局
 
    - 設置圓角與背景色，提升 UI 的一致性與美觀性。
    - 使用 Auto Layout 約束主 StackView，確保內容在各種尺寸的 Cell 中均能正確排列。

 -----------

` * Code Snippets`

 `- 主要方法解析`

 1. StackView 配置
 
    ```swift
    private func setupStackViewContent() {
        nameStackView.addArrangedSubview(nameTitleLabel)
        nameStackView.addArrangedSubview(nameValueLabel)
        // 依序配置其他 StackView 的內容...
    }
    ```
 
---
 
 2. 分隔線與主 StackView 配置
 
    ```swift
    private func setupMainStackView() {
        mainStackView.addArrangedSubview(nameStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
        mainStackView.addArrangedSubview(phoneStackView)
        // 依序添加其他 StackView 和分隔線...
        contentView.addSubview(mainStackView)
    }
    ```

 ---

 3. 動態顯示取件方式內容
 
    ```swift
    private func configurePickupMethod(for customerDetails: OrderConfirmationCustomerDetails) {
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
    ```
 */



import UIKit


/// 顯示顧客的姓名、電話、取件方式等詳細資訊的 Cell
/// - 此 Cell 包含多個 StackView，用於垂直排列顧客相關的資訊欄位。
class OrderConfirmationCustomerInfoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderConfirmationCustomerInfoCell"
    
    // MARK: - UI Elements
    
    // Name StackView
    private let nameTitleLabel = OrderConfirmationLabel(text: "Name：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let nameValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let nameStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Phone StackView
    private let phoneTitleLabel = OrderConfirmationLabel(text: "Phone：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let phoneValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let phoneStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // PickUpMethod StackView
    private let pickupMethodTitleLabel = OrderConfirmationLabel(text: "Pickup Method：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let pickupMethodValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, textAlignment: .right)
    private let pickupMethodStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Store StackView
    private let storeTitleLabel = OrderConfirmationLabel(text: "Store：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let storeValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let storeStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Address StackView
    private let addressTitleLabel = OrderConfirmationLabel(text: "Address：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let addressValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, scaleFactor: 0.5, textAlignment: .right)
    private let addressStackView = OrderConfirmationStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .equalSpacing)
    
    // Notes StackView (垂直排列)
    private let notesTitleLabel = OrderConfirmationLabel(text: "Notes：", font: .systemFont(ofSize: 16, weight: .semibold))
    private let notesValueLabel = OrderConfirmationLabel(font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 0, scaleFactor: 0.5)
    private let notesStackView = OrderConfirmationStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)
    
    // Main StackView
    private let mainStackView = OrderConfirmationStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
    
    // MARK: - Initializer
    
    /// 初始化 Cell，設置布局與樣式
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
    
    /// 設置 Cell 的整體布局
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
        mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
        mainStackView.addArrangedSubview(phoneStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
        mainStackView.addArrangedSubview(pickupMethodStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
        mainStackView.addArrangedSubview(storeStackView)
        mainStackView.addArrangedSubview(addressStackView)
        mainStackView.addArrangedSubview(OrderrConfirmationBottomLineView())
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
    
    /// 設置 Cell 的樣式
    ///
    /// - 包括圓角與背景顏色
    private func styleCell() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = UIColor.lightWhiteGray.withAlphaComponent(0.3)
    }
    
    // MARK: - Configuration Method
    
    /// 設置顧客資訊
    ///
    /// - Parameter customerDetails: 顧客詳細資料
    func configure(with customerDetails: OrderConfirmationCustomerDetails) {
        nameValueLabel.text = customerDetails.fullName
        phoneValueLabel.text = customerDetails.phoneNumber
        pickupMethodValueLabel.text = customerDetails.pickupMethod.rawValue
        configurePickupMethod(for: customerDetails)
        configureNotes(with: customerDetails.notes)
    }
    
    /// 配置取件方式相關的顯示
    ///
    /// - 根據取件方式顯示門市或地址資訊
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
