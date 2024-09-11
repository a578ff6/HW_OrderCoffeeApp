//
//  DrinkOrderOptionsCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/25.
//

/*
 ## DrinkOrderOptionsCollectionViewCell：

    * 主要功能：
        - 用來顯示訂單選項，包括選擇杯數的 Stepper 和 Add to Cart（加入購物車）的按鈕。
        - 透過 Stepper 選擇杯數，按下 Add to Cart 按鈕後，將選擇的數量加入購物車。

    * 主要結構：
        - stepper: 用來選擇杯數，最小值為1，最大值為10。
        - quantityLabel: 顯示當前選擇杯數的 UILabel。
        - orderButton: Add to Cart 按鈕，當點擊後將杯數加入購物車。
 
    * 主要流程：
        - stepper 的值變更會觸發 stepperValueChanged，並更新 quantityLabel。
        - 點擊 orderButton 會觸發 orderButtonTapped，將當前選擇的杯數傳遞到 addToCart 閉包。
        - updateOrderButtonTitle 根據是否處於編輯模式動態更新按鈕的文字內容。
 

 ---------------------------------------------------------------------------------------------------------------------------------------

 1. quantityContainerView 的部分：
    - 為 UIView，UIView 本身沒有「內容」，像 UILabel 或 UIButton 這類的子類有內容。
    - 當使用 Auto Layout 設定 UIView 的約束時，如果沒有提供足夠的資訊來確定其大小或位置，會看到錯誤或警告。
    - 通過設置 quantityContainerView 高度約束的優先級為 .defaultHigh ，確保在大多數情況下保持為55，允許在必要時調整高度以避免衝突。
 
 2. 關於區分「添加新飲品」和「修改訂單」：
    - 在 DrinkDetailViewController 中，當用戶進行修改訂單飲品項目時，改變按鈕的文字以區分「添加新飲品」和「修改訂單」。
    - 通過檢查當前是否處於編輯模式來實現。
    - 讓用戶更清楚當前操作是添加新的飲品還是修改訂單中的飲品。

 */



// MARK: - 重構

import UIKit

/// 顯示訂單選項，包括杯數選擇和加入訂單按鈕
class DrinkOrderOptionsCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DrinkOrderOptionsCollectionViewCell"
    
    private let stepper: UIStepper = createStepper()
    private let quantityLabel = createLabel(withText: "1")
    private let orderButton: UIButton = createOrderButton()
    
    /// 點擊 `Add to Cart` 按鈕時觸發的閉包，傳遞選擇的數量。
    var addToCart: ((Int) -> Void)?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        updateOrderButtonTitle(isEditing: false)   // 默認設置為非編輯狀態
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置視圖元件
    private func setupViews() {
        let quantityStackView = createQuantityStackView()
        let quantityContainerView = createQuantityContainerView(with: quantityStackView)
        
        // 將 quantityContainerView、orderButton 設置在同一個 StackView。藉此設置兩個水平且有間距的設計。
        let mainStackView = UIStackView(arrangedSubviews: [quantityContainerView, orderButton])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 10
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        
        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        orderButton.addTarget(self, action: #selector(orderButtonTapped), for: .touchUpInside)
    }
    
    /// 設置約束
    private func setupConstraints() {
        guard let mainStackView = contentView.subviews.first as? UIStackView else { return }
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        if let quantityContainerView = mainStackView.arrangedSubviews.first {
            let heightConstraint = quantityContainerView.heightAnchor.constraint(equalToConstant: 55)
            heightConstraint.priority = .defaultHigh
            heightConstraint.isActive = true
            orderButton.heightAnchor.constraint(equalTo: quantityContainerView.heightAnchor).isActive = true
        }
    }
    
    // MARK: - Factory Methods
    
    /// 創建 `stepper` 元件
    private static func createStepper() -> UIStepper {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 10
        return stepper
    }
    
    /// 創建`訂單按鈕`
    private static func createOrderButton() -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.backgroundColor = .deepGreen
        button.layer.borderColor = UIColor.deepBrown.cgColor
        return button
    }
    
    /// 創建 Label
    private static func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        return label
    }
    
    /// 創建`數量選擇的`StackView（`包含 數量Label、杯Label、stepper`）
    private func createQuantityStackView() -> UIStackView {
        let quantityStackView = UIStackView(arrangedSubviews: [quantityLabel, UILabel(text: "杯"), stepper])
        quantityStackView.axis = .horizontal
        quantityStackView.spacing = 8
        quantityStackView.alignment = .center
        quantityStackView.translatesAutoresizingMaskIntoConstraints = false
        return quantityStackView
    }
    
    /// 設置包含邊框的 `數量` 選擇容器： 用來當` quantityStackView` 的背景，藉此設計出一個`外邊框`
    private func createQuantityContainerView(with stackView: UIStackView) -> UIView {
        let quantityContainerView = UIView()
        quantityContainerView.layer.cornerRadius = 10
        quantityContainerView.layer.borderWidth = 2
        quantityContainerView.layer.borderColor = UIColor.lightGray.cgColor
        quantityContainerView.addSubview(stackView)
        quantityContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 設置 quantityStackView 在 quantityContainerView 中的位置
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: quantityContainerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: quantityContainerView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: quantityContainerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: quantityContainerView.trailingAnchor, constant: -8)
        ])
        return quantityContainerView
    }
    
    // MARK: - Action Methods
    
    /// 當 Stepper 的數值變更時，更新`數量標籤`
    @objc func stepperValueChanged(_ sender: UIStepper) {
        quantityLabel.text = "\(Int(sender.value))"
    }

    /// 點擊訂單按鈕的處理方法
    @objc func orderButtonTapped() {
        let quantity = Int(stepper.value)  // 確保傳遞當前的步進器數值
        addToCart?(quantity)               // 傳遞數量到購物車
        orderButton.addSpringAnimation()
    }
    
    // MARK: - Update Methods
    
    /// 動態更新按鈕文字：根據是否處於編輯模式來動態更新按鈕的文字。
    func updateOrderButtonTitle(isEditing: Bool) {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        configuration.baseForegroundColor = .white
        
        configuration.title = isEditing ? "Update Order" : "Add to Cart"
        configuration.image = UIImage(systemName: isEditing ? "pencil.circle.fill" : "cart.fill")

        orderButton.configuration = configuration
    }
    
    // MARK: - Configure Method
    
    /// 設置初始數量
    func configure(with quantity: Int) {
        stepper.value = Double(quantity)
        quantityLabel.text = "\(quantity)"
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置 stepper、quantityLabel、訂單按鈕的狀態
    override func prepareForReuse() {
        super.prepareForReuse()
        stepper.value = 1
        quantityLabel.text = "1"
        updateOrderButtonTitle(isEditing: false)
    }
    
}

// MARK: - Extension UILabel

/// 用來快速生成帶有文字的 Label
private extension UILabel {
    convenience init(text: String) {
        self.init()
        self.text = text
    }
}
