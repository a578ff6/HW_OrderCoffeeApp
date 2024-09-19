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
 
 ---------------------------------------------------------------------------------------------------------------------------------------

 ## DrinkOrderOptionsCollectionViewCell 補充：
 
 1. 視圖初始化與配置的最佳實踐：
    
    * 將 createQuantityAndCupStackView、createQuantityContainerView 這類方法放在函數內部實例化，而非外部，這是為了讓 UI 元件的初始化與配置更具可讀性與可維護性。
 
        - 延遲初始化： 某些元件只有在特定情況下才會被使用，將它們的創建邏輯放在內部方法中可以避免過早初始化，減少資源浪費。
        - 單一責任原則： 將元件的創建與配置封裝在單一方法內，可以讓每個方法的職責更清晰，避免在一個方法中同時處理多個元件的創建，從而減少代碼的複雜度。
        - 提升可讀性： 這樣的做法可以讓主視圖組件的初始化流程更清楚，因為具體的子元件的創建與配置都被封裝到了各自的方法中，主函數內只需簡單調用即可。
 
 2. quantityContainerView 的部分：

    * quantityContainerView 是一個 UIView，本身不具備內容，但作為容器來包含其他子視圖（例如 quantityLabel 和 cupLabel）。
        
        - 在設定 quantityContainerView 的 Auto Layout 約束時，如果沒有明確指定其高度或寬度，會出現自動佈局錯誤。
        - 因此，設置高度約束為 55 並將其優先級設為 .defaultHigh，可以確保在大多數情況下保持這個高度，並允許在必要時進行調整，避免衝突。
 
 3. 元件是在函數內實例化：

    * 提高模組化：每個方法專注於生成特定的元件（例如 createQuantityAndCupStackView 只生成數量與單位的排列）。這樣的結構可以提高代碼的可讀性，也使得不同元件之間的邏輯更易於管理。
    * 避免視圖初始化過早或過多的實例化：將視圖的初始化放到需要使用的地方，避免了在類的初始階段創建不必要的視圖，這在性能上更有效率。
 
 4. 一般 UI 結構設計的建議
    - 保持分離：簡單的視圖可以在外部初始化，而複雜的組合視圖應該封裝到方法中進行初始化。
    - 模式：按照職責劃分視圖的生成邏輯，讓每個方法只負責生成特定的視圖或視圖組合。
    - 按需生成：盡可能只在需要時生成視圖，減少內存佔用。
    - 延遲初始化：視圖的實例化應該盡可能晚，而不是一開始就初始化所有視圖。

 */


// MARK: - 重構
import UIKit

/// 顯示訂單選項，包括杯數選擇和加入訂單按鈕的 CollectionViewCell
class DrinkOrderOptionsCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DrinkOrderOptionsCollectionViewCell"
    
    private let quantityStepper = createStepper()
    private let quantityLabel = createLabel(withText: "1")
    private let cupLabel = createLabel(withText: "杯")
    private let orderButton = createOrderButton()
    
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
        let mainStackView = createMainStackView()
        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        /// 設置 `UIStepper` 和 `UIButton` 的 addTarget
        quantityStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        orderButton.addTarget(self, action: #selector(orderButtonTapped), for: .touchUpInside)
    }
    
    /// 設置約束
    private func setupConstraints() {
        guard let mainStackView = contentView.subviews.first as? UIStackView else { return }
        setMainStackViewConstraints(mainStackView: mainStackView)
    }
    
    /// 設置 `mainStackView` 的約束
    private func setMainStackViewConstraints(mainStackView: UIStackView) {
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

    // MARK: - StackView Methods

    /// 建立主堆疊視圖 `MainStackView`
    private func createMainStackView() -> UIStackView {
        let quantityContainerView = createQuantityContainerView()
        let mainStackView = UIStackView(arrangedSubviews: [quantityContainerView, orderButton])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 10
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        return mainStackView
    }
    
    /// 建立`數量杯數`與 `Stepper` 的堆疊視圖 `QuantityAndSteppersStackView`
    private func createQuantityAndStepperControlStackView() -> UIStackView {
        let quantityAndCupStackView = createQuantityAndCupStackView()
        let quantityControlStackView = UIStackView(arrangedSubviews: [quantityAndCupStackView, quantityStepper])
        quantityControlStackView.axis = .horizontal
        quantityControlStackView.spacing = 10
        quantityControlStackView.alignment = .center
        quantityControlStackView.distribution = .fill
        quantityControlStackView.translatesAutoresizingMaskIntoConstraints = false
        return quantityControlStackView
    }
    
    /// 建立`數量`及`杯數`的堆疊視圖 `QuantityAndCupStackView`
    private func createQuantityAndCupStackView() -> UIStackView {
        let quantityStackView = UIStackView(arrangedSubviews: [quantityLabel, cupLabel])
        quantityStackView.axis = .horizontal
        quantityStackView.spacing = 2
        quantityStackView.alignment = .center
        quantityStackView.distribution = .equalSpacing
        quantityStackView.translatesAutoresizingMaskIntoConstraints = false
        return quantityStackView
    }

    // MARK: - UIView Methods

    /// 設置包含`邊框`的`數量選擇`容器 `QuantityContainerView`，藉此設計出一個`外邊框`
    private func createQuantityContainerView() -> UIView {
        let containerView = createContainerView()
        let quantityControlStackView = createQuantityAndStepperControlStackView()
        containerView.addSubview(quantityControlStackView)
        
        // 設置 quantityControlStackView 在 containerView 中的位置
        NSLayoutConstraint.activate([
            quantityControlStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            quantityControlStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            quantityControlStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            quantityControlStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ])
        return containerView
    }
    
    /// 建立一個帶邊框的容器視圖 `ContainerView`
    private func createContainerView() -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
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
        label.adjustsFontSizeToFitWidth = true  // 自動調整字體大小
        label.minimumScaleFactor = 0.8 // 最小縮放比例
        label.numberOfLines = 1
        return label
    }
    
    // MARK: - Action Methods
    
    /// 當 Stepper 的數值變更時，更新`數量標籤`
    @objc func stepperValueChanged(_ sender: UIStepper) {
        quantityLabel.text = "\(Int(sender.value))"
    }

    /// 點擊訂單按鈕的處理方法
    @objc func orderButtonTapped() {
        let quantity = Int(quantityStepper.value)  // 確保傳遞當前的步進器數值
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
        quantityStepper.value = Double(quantity)
        quantityLabel.text = "\(quantity)"
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置 stepper、quantityLabel、訂單按鈕的狀態
    override func prepareForReuse() {
        super.prepareForReuse()
        quantityStepper.value = 1
        quantityLabel.text = "1"
        updateOrderButtonTitle(isEditing: false)
    }
    
}
