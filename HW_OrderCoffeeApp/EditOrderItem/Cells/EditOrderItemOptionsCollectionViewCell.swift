//
//  EditOrderItemOptionsCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/25.
//

import UIKit

/// 飲品訂單選項的 CollectionViewCell
///
/// ### 功能說明
/// 此元件負責展示飲品訂單選項，包含：
/// 1. 杯數選擇的步進器（Stepper）
/// 2. 杯數顯示標籤（包括數量與單位）
/// 3. 「編輯更新項目按鈕」按鈕
///
/// ### 設計目標
///   - 使用堆疊視圖（StackView）結構化排列 UI 元件，提升可讀性與易於維護性。
///   - 將按鈕與步進器的操作邏輯封裝為獨立事件。
///
/// ### 使用建議
///   - 適用於`編輯訂單飲品頁面`，作為購物選項的 UI 部分。
///   - 可透過 `editOrderItem` 閉包傳遞選擇的數量給外部進行處理。
class EditOrderItemOptionsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    /// Cell 的重用識別碼
    static let reuseIdentifier = "EditOrderItemOptionsCollectionViewCell"
    
    // MARK: - UI Elements
    
    /// 數量調整的Stepper
    private let quantityStepper = EditOrderItemStepper(minValue: 1, maxValue: 10, defaultValue: 1)
    
    /// 數量顯示的標籤
    private let quantityLabel = EditOrderItemLabel(text: "1", font: .systemFont(ofSize: 16), textColor: .black, textAlignment: .center, numberOfLines: 1, adjustsFontSizeToFitWidth: true, minimumScaleFactor: 0.8)
    
    /// 杯數的單位標籤
    private let cupLabel = EditOrderItemLabel(text: "杯", font: .systemFont(ofSize: 16), textColor: .black, textAlignment: .center, numberOfLines: 1, adjustsFontSizeToFitWidth: true, minimumScaleFactor: 0.8)
    
    /// 編輯更新項目按鈕
    private let editOrderItemUpdateButton = EditOrderItemUpdateButton()
    
    // MARK: - StackViews
    
    /// 主堆疊視圖，包含`數量容器`和`按鈕`
    private let mainStackView = EditOrderItemStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .fillEqually)
    
    /// 顯示`數量`和`單位`的堆疊視圖
    private let quantityAndCupStackView = EditOrderItemStackView(axis: .horizontal, spacing: 2, alignment: .center, distribution: .equalSpacing)
    
    /// `數量`與`步進器`的堆疊視圖
    private let quantityAndStepperControlStackView = EditOrderItemStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    
    /// `數量`與`步進器`的`容器視圖`
    private let quantityContainerView = EditOrderItemDecoratedContainerView(cornerRadius: 10, borderWidth: 2, borderColor: .lightGray)
    
    // MARK: - Closure
    
    /// 點擊 `editOrderItemUpdateButton` 按鈕時觸發的閉包，將選擇的數量傳遞給外部
    var editOrderItem: ((Int) -> Void)?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureTargets()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 `quantityAndCupStackView` 的內容
    ///  - `數量`與`單位`的堆疊視圖
    private func setupQuantityAndCupStackView() {
        quantityAndCupStackView.addArrangedSubview(quantityLabel)
        quantityAndCupStackView.addArrangedSubview(cupLabel)
    }
    
    /// 配置 `quantityAndStepperControlStackView` 的內容
    ///  - `數量`與`步進器`的堆疊視圖
    private func setupQuantityAndStepperControlStackView() {
        quantityAndStepperControlStackView.addArrangedSubview(quantityAndCupStackView)
        quantityAndStepperControlStackView.addArrangedSubview(quantityStepper)
    }
    
    /// 配置 `mainStackView` 的內容
    ///  - `容器視圖`與`按鈕`
    private func setupMainStackView() {
        quantityContainerView.addContentView(quantityAndStepperControlStackView)
        mainStackView.addArrangedSubview(quantityContainerView)
        mainStackView.addArrangedSubview(editOrderItemUpdateButton)
    }
    
    /// 配置所有視圖
    private func setupViews() {
        setupQuantityAndCupStackView()
        setupQuantityAndStepperControlStackView()
        setupMainStackView()
        
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    /// 配置`按鈕`與`步進器`的目標事件
    private func configureTargets() {
        quantityStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        editOrderItemUpdateButton.addTarget(self, action: #selector(editOrderItemUpdateButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    /// 當步進器數量改變時觸發
    /// - 更新數量標籤的顯示內容
    @objc func stepperValueChanged() {
        quantityLabel.text = "\(Int(quantityStepper.value))"
    }
    
    /// 點擊「編輯更新項目按鈕」時觸發
    /// - 傳遞當前數量至外部邏輯
    /// - 增加按鈕的彈簧動畫效果
    @objc func editOrderItemUpdateButtonTapped() {
        let quantity = Int(quantityStepper.value)
        editOrderItem?(quantity)
//        editOrderItemUpdateButton.addSpringAnimation()    // 因為點擊按鈕後會直接dismiss畫面，彈簧效果暫時不需要
    }
    
    // MARK: - Configure Method
    
    /// 設置初始數量
    /// - Parameter quantity: 初始數量
    func configure(with quantity: Int) {
        quantityStepper.value = Double(quantity)
        quantityLabel.text = "\(quantity)"
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重用前重置內容，防止數據殘留
    override func prepareForReuse() {
        super.prepareForReuse()
        quantityStepper.value = 1
        quantityLabel.text = "1"
    }
    
}
