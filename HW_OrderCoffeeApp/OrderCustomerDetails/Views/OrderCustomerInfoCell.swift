//
//  OrderCustomerInfoCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/10.
//



/*
 
 ## OrderCustomerInfoCell 重點筆記：
 
    * 功能：
        - 用於顯示並處理顧客姓名和電話的輸入框。包含顧客的姓名、電話標籤及輸入框。

    * 組成部分：
 
        1. UI 元素
            - nameLabelStackView：顯示顧客姓名標籤和圖標。
            - nameTextField：輸入顧客姓名的 UITextField。
            - phoneLabelStackView：顯示顧客電話標籤和圖標。
            - phoneTextField：輸入顧客電話的 UITextField。
            - customerInfoStackView：包含所有的 UI 元素並垂直排列的 UIStackView。
            - separatorView：用於增加間隔的視圖，改善佈局的可視性。
 
        2. 回調 (Callback)
            - onNameChange：在用戶更改 nameTextField 的文本時觸發的回調。
            - onPhoneChange：在用戶更改 phoneTextField 的文本時觸發的回調。
 
        3. 初始化
            - setupCustomerInfoStackView()：設置 UI 結構，將所有元素添加到 contentView 中並應用自動佈局約束。
            - setupActions()：為 nameTextField 和 phoneTextField 添加編輯變更 (editingChanged) 事件的監聽。
    
        4. 動態邊框設置
            - 當輸入框 (nameTextField 或 phoneTextField) 的內容為空時，設置紅色邊框以提示使用者該欄位為必填。邊框的設定在兩個地方進行：
            - 初始化 (configure)：初次設置時根據初始資料來確定是否顯示紅框。
            - 用戶輸入過程 (editingChanged)：在用戶編輯過程中動態更新邊框顏色。
 
        5. 重要方法
            - configure(with:)：設置 nameTextField 和 phoneTextField 的初始值，並根據值是否為空來設置紅框。
            - nameTextFieldChanged() 和 phoneTextFieldChanged()：當用戶編輯對應的 UITextField 時，更新紅框顏色並呼叫相應的回調。
            - setTextFieldBorder(_:isEmpty:)：統一設置 UITextField 的邊框顏色，根據是否為空來決定顏色。
 
    * 設計考量：
        
        1. 必填欄位提示
            - nameTextField 和 phoneTextField 都設置了紅框判斷，以即時提示使用者這些欄位為必填。
            - 即使姓名在 UserDetails 和 CustomerDetails 中都是必填的，紅框的設置有助於用戶在填寫過程中明確辨識必填欄位。
 
        2. 統一邊框設置方法
            - 使用 setTextFieldBorder(_:, isEmpty:) 方法來統一處理邊框的設置，避免重複代碼並提高可維護性。
 
        3. 即時反饋
            - 透過 editingChanged 的事件監聽，即時向使用者反饋哪些欄位為空，並對應設置紅色邊框，確保使用者能在輸入過程中得到即時提示。
 
    * 未來改進空間：
    
        1. 驗證格式：目前僅判斷是否為空，未對電話號碼進行格式驗證。可以增加電話號碼的格式檢查以提升輸入數據的質量。
       
        2. 可擴展性：如果未來需要添加更多顧客資料項目，可以進一步抽象和封裝重複的 UI 元素創建邏輯。

 */


import UIKit

/// 設置訂單顧客姓名、電話的 TextField、Label 等
class OrderCustomerInfoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderCustomerInfoCell"
    
    // MARK: - UI Elements
    
    // 添加圖標的元素
    private let nameLabelStackView = createLabelStackView(titleText: "Customer Name", icon: UIImage(systemName: "person.circle"))
    private let nameTextField = createTextField(withPlaceholder: "Enter name")
    
    private let phoneLabelStackView = createLabelStackView(titleText: "Customer Phone", icon: UIImage(systemName: "phone.circle"))
    private let phoneTextField = createTextField(withPlaceholder: "Enter phone number")
    
    private let customerInfoStackView = createStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fill)
    
    private let separatorView = createSeparatorView(height: 2)  // 用於增加間隔的視圖
    
    // MARK: - Callbacks
    
    var onNameChange: ((String) -> Void)?
    var onPhoneChange: ((String) -> Void)?
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustomerInfoStackView()
        setupActions()
        setupTextFieldConfigurations()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置包含所有 UI 元素的 customerInfoStackView
    private func setupCustomerInfoStackView() {
        customerInfoStackView.addArrangedSubview(nameLabelStackView)
        customerInfoStackView.addArrangedSubview(nameTextField)
        customerInfoStackView.addArrangedSubview(separatorView) // 插入分隔視圖來增加間隔
        customerInfoStackView.addArrangedSubview(phoneLabelStackView)
        customerInfoStackView.addArrangedSubview(phoneTextField)
        
        contentView.addSubview(customerInfoStackView)
        
        NSLayoutConstraint.activate([
            customerInfoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            customerInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            customerInfoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            customerInfoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    /// 設置 TextField 的 action
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(phoneTextFieldChanged), for: .editingChanged)
    }
    
    /// 設置 TextField 的鍵盤樣式和其他屬性
    private func setupTextFieldConfigurations() {
        phoneTextField.keyboardType = .phonePad
    }
    
    // MARK: - Factory Method
    
    /// 建立 `Label` 和 `圖標` 的堆疊視圖
    private static func createLabelStackView(titleText: String, icon: UIImage?) -> UIStackView {
        let iconImageView = createIconImageView(icon: icon)
        let label = createLabel(withText: titleText, font: UIFont.systemFont(ofSize: 16, weight: .bold), textColor: .lightGray)
        let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    /// 建立圖標視圖
    private static func createIconImageView(icon: UIImage?) -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(weight: .medium)
        let mediumIcon = icon?.withConfiguration(configuration)
        let iconImageView = UIImageView(image: mediumIcon)
        iconImageView.tintColor = .gray
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return iconImageView
    }

    /// 建立 Label
    private static func createLabel(withText text: String, font: UIFont, textColor: UIColor, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 建立 TextField
    private static func createTextField(withPlaceholder placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    /// 建立一個 StackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// 建立一個分隔視圖（Separator View）
    /// - Parameter height: 分隔視圖的高度
    /// - Returns: 設置好的 UIView
    private static func createSeparatorView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    // MARK: - Action Handlers
    
    /// nameTextFieldChanged 方法負責在使用者編輯姓名欄位時即時更新邊框顏色，確保只要欄位是空的，就顯示紅框。
    @objc private func nameTextFieldChanged() {
        let text = nameTextField.text ?? ""
        onNameChange?(text)
        
        // 檢查 nameTextField 是否為空，如果為空則設置紅框
        setTextFieldBorder(nameTextField, isEmpty: text.isEmpty)
    }
    
    /// phoneTextFieldChanged 方法負責在使用者編輯電話欄位時即時更新邊框顏色，確保只要欄位是空的，就顯示紅框。
    @objc private func phoneTextFieldChanged() {
        let text = phoneTextField.text ?? ""
        onPhoneChange?(text)
        
        // 檢查 phoneTextField 是否為空，如果為空則設置紅框
        setTextFieldBorder(phoneTextField, isEmpty: text.isEmpty)
    }
    
    /// 設置 TextField 邊框顏色
    private func setTextFieldBorder(_ textField: UITextField, isEmpty: Bool) {
        textField.layer.borderColor = isEmpty ? UIColor.red.cgColor : UIColor.clear.cgColor
        textField.layer.borderWidth = isEmpty ? 1.0 : 0.0
    }

    // MARK: - Configure Method
        
    /// 配置 cell 的資料
    ///
    /// configure 方法負責在初始設置時檢查 phoneTextField 是否有內容，來決定是否需要紅框。
    func configure(with customerDetails: CustomerDetails) {
        nameTextField.text = customerDetails.fullName
        phoneTextField.text = customerDetails.phoneNumber
        
        // 檢查姓名和電話是否為空，決定是否設置紅框
        // 因為在 UserDetails 中 phone 為選填，在 customerDetails 中為必填。
        // 雖然名字在 UserDetails 為必填，在 customerDetails 中也為必填，但這邊還是設置一下。
        setTextFieldBorder(nameTextField, isEmpty: customerDetails.fullName.isEmpty)
        setTextFieldBorder(phoneTextField, isEmpty: customerDetails.phoneNumber.isEmpty)
    }
    
}
