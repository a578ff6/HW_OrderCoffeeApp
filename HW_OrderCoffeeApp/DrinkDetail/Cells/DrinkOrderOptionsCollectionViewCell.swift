//
//  DrinkOrderOptionsCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/25.
//

// MARK: - DrinkOrderOptionsCollectionViewCell 補充
/**
 ## DrinkOrderOptionsCollectionViewCell：

    * 主要功能：
        - 用來顯示訂單選項，包括選擇杯數的 Stepper 和 Add to Cart（加入購物車）的按鈕。
        - 透過 Stepper 選擇杯數，按下 Add to Cart 按鈕後，將選擇的數量加入購物車。

    * 主要結構：
        - stepper: 用來選擇杯數，最小值為1，最大值為10。
        - quantityLabel: 顯示當前選擇杯數的 UILabel。
        - orderButton: Add to Cart 按鈕，當點擊後將杯數加入購物車。
 
    * 主要流程：
        - `stepper` 的值變更會觸發 `stepperValueChanged`，並更新 `quantityLabel`。
        - 點擊 `orderButton` 會觸發 `orderButtonTapped`，將當前選擇的杯數傳遞到 `addToCart` 閉包。
 */


// MARK: - 筆記 DrinkOrderOptionsCollectionViewCell
/**
 
 ## 筆記 DrinkOrderOptionsCollectionViewCell
 
 `* What`
 
 - `DrinkOrderOptionsCollectionViewCell` 是一個用於展示訂單選項的自訂 UICollectionViewCell。功能包括：

 1.顯示飲品訂購的杯數與數量。
 2.提供加入購物車的按鈕。
 
 -------------------
 
 `* Why`
 
 1.`清晰的功能區分`： 使用堆疊視圖組織 UI 結構，清楚分離數量調整區域與按鈕。
 2.`動態交互`： 通過閉包將數量資訊回傳。
 3.`現代化設計`： 採用 DrinkDetailOrderButton 及 DrinkDetailStepper 等可重複使用的自訂元件，降低重複代碼。
 
 `* How`
 
 `1.視圖組織：`

 - 使用多層堆疊視圖（StackView）組織按鈕與數量控制的布局。
 - 使用裝飾容器（`DrinkDetaiDecoratedContainerView`）提供圓角和樣式包裝。
 
 `2.功能實現：`

 - `quantityStepper` 和 `quantityLabel` 在初始化時即設置了預設值。
 - 這些值通常是固定的，無需從外部傳遞或再設置，因此不需要 configure 方法來傳遞初始數量。

 -------------------

 `* 優化後的設計優勢`
 
 `1.可讀性：`
 
 - 以 MARK 分類代碼，清楚區分各部分職責（Setup, Update, Actions）。
 
 `2.靈活性：`
 
 - 支援閉包方式回傳數量，便於外部控制互動行為。
 */


// MARK: - DrinkOrderOptionsCollectionViewCell` 和 `EditOrderItemOptionsCollectionViewCell 差異
/**

 ## DrinkOrderOptionsCollectionViewCell` 和 `EditOrderItemOptionsCollectionViewCell 差異
 
 - 由於`DrinkOrderOptionsCollectionViewCell`的`DrinkDetail`當初是有負責新增、編輯飲品訂單項目，因此在職責上會相對複雜。
 - 所以後續我才決定設置`EditOrderItem`負責編輯，`DrinkDetail`負責新增。`DrinkOrderOptionsCollectionViewCell`、`EditOrderItemOptionsCollectionViewCell`的職責也會有所改變。

 ------------------
 
 `* What`
 
 1. `DrinkOrderOptionsCollectionViewCell`
 
    - 用於新增飲品訂單項目，顯示數量選擇並讓用戶添加訂單。
    - 不需要設置 `configure` 方法來管理數量，因為數量是由 `DrinkDetail` 頁面控制的。

 2. `EditOrderItemOptionsCollectionViewCell`
 
    - 用於編輯現有的飲品訂單項目，允許用戶修改數量。
    - 需要設置 `configure` 方法來接收當前的數量並顯示在步進器和標籤中，讓用戶進行修改。

 -------------------

 `* Why`
 
 1. `DrinkOrderOptionsCollectionViewCell`
 
    - 因為此 cell 用於新增訂單項目，數量是由 `DrinkDetail` 頁面控制，並且數量通常會設置為一個固定的初始值，供用戶進行選擇。由 `DrinkDetail` 頁面處理數量設置，因此不需要額外的配置方法。
    - 用戶進行的是新增訂單，所以數量一般會有預設值（如 `1`），並且通過 `stepper` 調整。用戶的選擇在點擊「加入購物車」時才會提交，這樣的數量不需要外部傳遞，只需在初始化時設置好。

 
 2. `EditOrderItemOptionsCollectionViewCell`
    - 此 cell 用於編輯現有的訂單項目，數量需要從 `EditOrderItemModel` 中取得並顯示。用戶可以在此頁面修改數量，因此需要將當前數量顯示在 UI 元件中，並且使用 `configure` 方法來設置數量。
    - 在編輯訂單頁面中，數量應該反映當前的訂單狀態。此時，需要顯示已選擇的數量並允許用戶進行編輯。因此，數量需要來自外部模型（如 `EditOrderItemModel`），並通過 `configure` 方法設置初始值。

 -------------------

 * How
 
 1. `DrinkOrderOptionsCollectionViewCell`
 
    - 在 `DrinkDetail` 頁面中，直接設定 `quantityStepper` 和 `quantityLabel` 的值。數量不需要額外的 `configure` 方法來更新，因為它由頁面控制並由使用者在頁面中進行選擇。
    - 因為數量是根據預設的初始值（例如 `1`）來顯示的，用戶可以使用 `stepper` 控制數量的增減。這是用來處理「新增訂單」的情境，數量的初始化不需要外部數據支持。
    - 在此情況下，數量顯示和修改完全由內部控制。

 
 2. `EditOrderItemOptionsCollectionViewCell`
    - 在 `EditOrderItem` 頁面中，當編輯飲品訂單項目時，使用 `configure` 方法來設置當前的數量。
    - 這樣當 `EditOrderItemViewController` 加載時，它能夠將數量從模型 (`EditOrderItemModel`) 中讀取出來，並顯示在步進器和標籤中，允許用戶進行修改。
    - 因為它需要根據外部傳遞的數據來設置當前的數量。當用戶進入編輯頁面時，數量應該顯示當前訂單的數量，並且允許用戶進行編輯。
    - `configure` 方法會接受一個數量參數，將其設置到 `quantityStepper` 和 `quantityLabel` 中，以確保顯示的是正確的初始數量。
 
 -------------------

 `* Summary`
 
 - `DrinkOrderOptionsCollectionViewCell`: 主要用於新增訂單項目，不需要配置數量，數量由 `DrinkDetail` 頁面管理。
 - `EditOrderItemOptionsCollectionViewCell`: 用於編輯訂單項目，需要通過 `configure` 方法設置數量，並允許用戶進行數量修改。
 */



// MARK: - 移除編輯模式判斷(v)

import UIKit

/// 飲品訂單選項的 CollectionViewCell
///
/// ### 功能說明
/// 此元件負責展示飲品訂單選項，包含：
/// 1. 杯數選擇的步進器（Stepper）
/// 2. 杯數顯示標籤（包括數量與單位）
/// 3. 「加入購物車」按鈕
///
/// ### 設計目標
///   - 使用堆疊視圖（StackView）結構化排列 UI 元件，提升可讀性與易於維護性。
///   - 將按鈕與步進器的操作邏輯封裝為獨立事件。
///
/// ### 使用建議
///   - 適用於飲品詳細資訊頁面，作為購物選項的 UI 部分。
///   - 可透過 `addToCart` 閉包傳遞選擇的數量給外部進行處理。
class DrinkOrderOptionsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    /// Cell 的重用識別碼
    static let reuseIdentifier = "DrinkOrderOptionsCollectionViewCell"
    
    // MARK: - UI Elements
    
    /// 數量調整的Stepper
    private let quantityStepper = DrinkDetailStepper(minValue: 1, maxValue: 10, defaultValue: 1)
    
    /// 數量顯示的標籤
    private let quantityLabel = DrinkDetailLabel(text: "1", font: .systemFont(ofSize: 16), textColor: .black, textAlignment: .center, numberOfLines: 1, adjustsFontSizeToFitWidth: true, minimumScaleFactor: 0.8)
    
    /// 杯數的單位標籤
    private let cupLabel = DrinkDetailLabel(text: "杯", font: .systemFont(ofSize: 16), textColor: .black, textAlignment: .center, numberOfLines: 1, adjustsFontSizeToFitWidth: true, minimumScaleFactor: 0.8)
    
    /// 訂單按鈕
    private let orderButton = DrinkDetailOrderButton()
    
    // MARK: - StackViews
    
    /// 主堆疊視圖，包含`數量容器`和`按鈕`
    private let mainStackView = DrinkDetailStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .fillEqually)
    
    /// 顯示`數量`和`單位`的堆疊視圖
    private let quantityAndCupStackView = DrinkDetailStackView(axis: .horizontal, spacing: 2, alignment: .center, distribution: .equalSpacing)
    
    /// `數量`與`步進器`的堆疊視圖
    private let quantityAndStepperControlStackView = DrinkDetailStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    
    /// `數量`與`步進器`的`容器視圖`
    private let quantityContainerView = DrinkDetaiDecoratedContainerView(cornerRadius: 10, borderWidth: 2, borderColor: .lightGray)
    
    // MARK: - Closure
    
    /// 點擊 `Add to Cart` 按鈕時觸發的閉包，將選擇的數量傳遞給外部
    var addToCart: ((Int) -> Void)?
    
    // MARK: - Initializers
    
    /// 初始化
    /// - 默認按鈕設置為非編輯狀態
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
        mainStackView.addArrangedSubview(orderButton)
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
        orderButton.addTarget(self, action: #selector(orderButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    /// 當步進器數量改變時觸發
    /// - 更新數量標籤的顯示內容
    @objc func stepperValueChanged() {
        quantityLabel.text = "\(Int(quantityStepper.value))"
    }
    
    /// 點擊「加入購物車」按鈕時觸發
    /// - 傳遞當前數量至外部邏輯
    /// - 增加按鈕的彈簧動畫效果
    @objc func orderButtonTapped() {
        let quantity = Int(quantityStepper.value)
        addToCart?(quantity)
        orderButton.addSpringAnimation()
    }
    
}
