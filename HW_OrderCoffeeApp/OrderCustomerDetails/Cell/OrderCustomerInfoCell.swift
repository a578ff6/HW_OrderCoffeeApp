//
//  OrderCustomerInfoCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/10.
//


// MARK; - OrderCustomerInfoCell 筆記
/**
 
 ## OrderCustomerInfoCell 筆記

 `* What`
 
 - `OrderCustomerInfoCell` 是一個自訂的 `UICollectionViewCell`，主要用於顯示和輸入訂單顧客的姓名與電話資訊。
 
 它包含：
 1. 顧客姓名與電話的圖標（`UIImageView`）與標籤（`UILabel`）。
 2. 姓名與電話的輸入框（`UITextField`），提供即時輸入驗證功能。
 3. 支援外部行為回調（Callback），用於監聽輸入框內容變更。

 -----------------

 `* Why`
 
 1. 顯示一致性： 將姓名與電話的顯示與輸入功能整合，提升界面的統一性。
 2. 即時驗證： 提供欄位驗證功能（如輸入框為空時顯示紅框），提醒使用者輸入必要資料。
 3. 擴展性： 支援外部 callback，便於資料同步與動態行為處理。
 4. 結構清晰： 採用分層的結構（Name Section、Phone Section、Main Stack View），使得視圖邏輯更易於維護與理解。

 -----------------

 `* How`
 
 1. 建立視圖結構：

 - `Name Section`: 包含顧客姓名的圖標、標籤和輸入框。
 - `Phone Section`: 包含顧客電話的圖標、標籤和輸入框。
 - `Main Stack View`: 將兩個部分堆疊排列，並設定統一的約束。
    
 `2. 輸入框行為與驗證：`
 
 - 每個輸入框（`OrderCustomerDetailsTextField`）都有 `validateContent` 方法，用於檢查內容是否為空並更新邊框顏色。
 - 使用 `addTarget` 方法監聽輸入框的編輯行為，當內容變更時觸發對應的回調（如 `onNameChange` 和 `onPhoneChange`）。

 `3. 資料配置與初始化：`
 
 - 透過 `configure(with:)` 方法將資料模型（`CustomerDetails`）傳入，初始化輸入框的內容並執行驗證。

 `4. 維護清晰結構：`
 
 - 將視圖的組裝與邏輯分開，分為 `setupNameSection`、`setupPhoneSection`、`setupCustomerInfoStackViewConstraints` 等方法，使每個方法單一責任明確，易於維護與擴展。

 -----------------
 
 `* Code Highlight`
 
 - `即時驗證與回調：`
 
    ```swift
    @objc private func nameTextFieldChanged() {
        nameTextField.validateContent()
        onNameChange?(nameTextField.text ?? "")
    }
    ```
    在輸入框內容變更時，更新邊框顏色並觸發回調。
    
 -----
 
 - `分離設置邏輯：`
 
    ```swift
    private func setupNameSection() {
        nameLabelAndIconStackView.addArrangedSubview(nameIconImageView)
        nameLabelAndIconStackView.addArrangedSubview(nameLabel)
        customerInfoStackView.addArrangedSubview(nameLabelAndIconStackView)
        customerInfoStackView.addArrangedSubview(nameTextField)
        customerInfoStackView.setCustomSpacing(20, after: nameTextField)
    }
    ```
    將每個部分的設置邏輯抽出，讓 `setupCustomerInfoStackView` 不再顯得過於肥大。

 -----
 
 - `清晰的堆疊與約束：`
 
    ```swift
    private func setupCustomerInfoStackViewConstraints() {
        contentView.addSubview(customerInfoStackView)
        NSLayoutConstraint.activate([
            customerInfoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            customerInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            customerInfoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            customerInfoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    ```

 -----------------
 
 `* 設計考量：`
     
 `1. 必填欄位提示`
        
 - `nameTextField` 和 `phoneTextField` 都設置了紅框判斷，以即時提示使用者這些欄位為必填。
- 即使姓名在 `UserDetails` 和 `CustomerDetails` 中都是必填的，紅框的設置有助於用戶在填寫過程中明確辨識必填欄位。
 
 `2. 統一邊框設置方法`

 - 使用 `validateContent()`方法來統一處理邊框的設置，避免重複代碼並提高可維護性。
    
 `3. 即時反饋`
    
 - 透過 `editingChanged` 的事件監聽，即時向使用者反饋哪些欄位為空，並對應設置紅色邊框，確保使用者能在輸入過程中得到即時提示。

 -----------------

 `* 未來改進空間：`
 
 1. 驗證格式：目前僅判斷是否為空，未對電話號碼進行格式驗證。可以增加電話號碼的格式檢查以提升輸入數據的質量。
 
 2. 可擴展性：如果未來需要添加更多顧客資料項目，可以進一步抽象和封裝重複的 UI 元素創建邏輯。
 */


import UIKit

/// 用於設定訂單顧客資訊的 Cell，包含姓名和電話的輸入欄位。
///
/// ### 功能說明
/// - 提供顧客姓名與電話的輸入欄位，並顯示對應的圖標與標籤。
/// - 內建資料驗證功能，會在欄位為空時顯示紅色邊框以提示使用者。
/// - 支援客製化行為，例如透過 callback 通知資料變更。
class OrderCustomerInfoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderCustomerInfoCell"
    
    // MARK: - Name Section

    /// 顯示 "Name" 標籤的 Label
    private let nameLabel = OrderCustomerDetailsLabel(text: "Name", font: .systemFont(ofSize: 16, weight: .medium), textColor: .lightGray)
    
    /// 顯示 "Name" 圖示的 ImageView
    private let nameIconImageView = OrderCustomerDetailsIconImageView(image: UIImage(systemName: "person.fill"), tintColor: .darkGray, size: 22, symbolWeight: .medium)
    
    /// "Name" 標籤與圖示的水平堆疊視圖
    private let nameLabelAndIconStackView = OrderCustomerDetailsStackView(axis: .horizontal, spacing: 6, alignment: .fill, distribution: .fill)
    
    /// 用於輸入姓名的 TextField
    private let nameTextField = OrderCustomerDetailsTextField(placeholder: "Enter name", keyboardType: .namePhonePad, textContentType: .name)
    
    // MARK: - Phone Section
    
    /// 顯示 "Phone" 標籤的 Label
    private let phoneLabel = OrderCustomerDetailsLabel(text: "Phone", font: .systemFont(ofSize: 16, weight: .medium), textColor: .lightGray)
    
    /// 顯示 "Phone" 圖示的 ImageView
    private let phoneIconImageView = OrderCustomerDetailsIconImageView(image: UIImage(systemName: "phone.fill"), tintColor: .darkGray, size: 22, symbolWeight: .medium)
    
    /// "Phone" 標籤與圖示的水平堆疊視圖
    private let phoneLabelAndIconStackView = OrderCustomerDetailsStackView(axis: .horizontal, spacing: 6, alignment: .fill, distribution: .fill)
    
    /// 用於輸入電話的 TextField
    private let phoneTextField = OrderCustomerDetailsTextField(placeholder: "Enter phone number", keyboardType: .phonePad, textContentType: .telephoneNumber)
    
    // MARK: - Main Stack View

    /// 用於排列所有子視圖的主垂直堆疊視圖
    private let customerInfoStackView = OrderCustomerDetailsStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
    // MARK: - Callbacks
    
    /// 姓名輸入變更的回調
    var onNameChange: ((String) -> Void)?
    
    /// 電話輸入變更的回調
    var onPhoneChange: ((String) -> Void)?
    
    // MARK: - Initializer
    
    /// 初始化 Cell 並設置視圖層次結構與行為
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNameSection()
        setupPhoneSection()
        setupCustomerInfoStackViewConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置姓名部分的堆疊與元件
    private func setupNameSection() {
        nameLabelAndIconStackView.addArrangedSubview(nameIconImageView)
        nameLabelAndIconStackView.addArrangedSubview(nameLabel)
        customerInfoStackView.addArrangedSubview(nameLabelAndIconStackView)
        customerInfoStackView.addArrangedSubview(nameTextField)
        customerInfoStackView.setCustomSpacing(20, after: nameTextField)
    }
    
    /// 設置電話部分的堆疊與元件
    private func setupPhoneSection() {
        phoneLabelAndIconStackView.addArrangedSubview(phoneIconImageView)
        phoneLabelAndIconStackView.addArrangedSubview(phoneLabel)
        customerInfoStackView.addArrangedSubview(phoneLabelAndIconStackView)
        customerInfoStackView.addArrangedSubview(phoneTextField)
    }
    
    /// 設置主堆疊視圖的約束
    private func setupCustomerInfoStackViewConstraints() {
        contentView.addSubview(customerInfoStackView)
        NSLayoutConstraint.activate([
            customerInfoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            customerInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            customerInfoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            customerInfoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    /// 設置 TextField 的行為
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(phoneTextFieldChanged), for: .editingChanged)
    }
    
    // MARK: - Action Handlers
    
    /// `nameTextFieldChanged` 方法負責在使用者編輯姓名欄位時即時更新邊框顏色
    @objc private func nameTextFieldChanged() {
        nameTextField.validateContent()
        onNameChange?(nameTextField.text ?? "")
    }
    
    /// `phoneTextFieldChanged` 方法負責在使用者編輯電話欄位時即時更新邊框顏色
    @objc private func phoneTextFieldChanged() {
        phoneTextField.validateContent()
        onPhoneChange?(phoneTextField.text ?? "")
    }
    
    // MARK: - Configure Method
    
    /// 配置 Cell 的資料
    /// - Parameter customerDetails: 包含姓名與電話的資料模型。
    ///
    /// 此方法執行以下操作：
    /// 1. 設置姓名與電話的初始值。
    /// 2. 檢查姓名與電話欄位是否為空，並根據檢查結果決定是否設置紅框。
    ///    - 在 `UserDetails` 中，`phone` 為選填，但在 `customerDetails` 中為必填。
    ///    - 雖然 `name` 在 `UserDetails` 和 `customerDetails` 中皆為必填，仍需檢查保持與 `phone` 檢查邏輯一致。
    func configure(with customerDetails: CustomerDetails) {
        nameTextField.text = customerDetails.fullName
        phoneTextField.text = customerDetails.phoneNumber
        nameTextField.validateContent()
        phoneTextField.validateContent()
    }
    
}
