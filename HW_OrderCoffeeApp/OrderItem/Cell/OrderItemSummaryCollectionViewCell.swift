//
//  OrderItemSummaryCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/12.
//


// MARK: - OrderItemSummaryCollectionViewCell 筆記
/**
 
 ## OrderItemSummaryCollectionViewCell 筆記
 
 `* What`
 
 - `OrderItemSummaryCollectionViewCell` 是一個自訂的 `UICollectionViewCell`，用於展示訂單的總金額和準備時間資訊。

 - `UI元素`：
 
   - `totalAmountIcon`：顯示金額的圖示。
   - `totalAmountLabel`：顯示金額標籤。
   - `totalAmountValueLabel`：顯示金額的數值。
   - `totalPrepTimeIcon`：顯示準備時間的圖示。
   - `totalPrepTimeLabel`：顯示準備時間標籤。
   - `totalPrepTimeValueLabel`：顯示準備時間的數值。
 
 - `佈局結構`：
 
   - 使用多層次的 `StackView` 組合，分為：
     1. 子 `StackView`：分別包含圖示和文字標籤。
     2. 主 `StackView`：包含金額和準備時間的 `StackView`，呈垂直排列。
 
 - `功能`：
 
   - 提供 `configure` 方法設置金額和準備時間數值。
   - 支援重複使用時清空資料的邏輯。

 ------------

` * Why`
 
 1. 可讀性：
 
    - 透過明確的子 `StackView` 和主 `StackView` 劃分結構，使代碼層次分明，易於閱讀和維護。
 
 2. 重用性：
 
    - 設置通用的 `OrderItemIconImageView` 和 `OrderItemLabel`，減少重複代碼。
 
 3. 模組化：
 
    - 使用多個小型 `setup` 方法分開初始化和配置每個部分，確保易於擴展和調試。

 ------------

 `* How`
 
 1. 設置子 `StackView`：
 
    - 使用 `setupTotalAmountStackView` 和 `setupTotalPrepTimeStackView` 方法配置金額和準備時間的子視圖。
    - 將圖示與標籤組合成水平排列的 `StackView`。
 
 2. 設置主 `StackView`：
 
    - 在 `setupMainOrderSummaryStackView` 方法中，將金額和準備時間的 `StackView` 組合成垂直排列的主 `StackView`。
 
 3. 添加到 `contentView` 並設置約束：
 
    - 在 `setupConstraints` 方法中，將主 `StackView` 添加到 `contentView`，並設置四邊約束。
 
 4. 重用邏輯：
 
    - 在 `prepareForReuse` 方法中重置金額和準備時間的數值，避免重複使用時顯示錯誤數據。

 ------------

 `* 範例工作流程`
 
 1. 在初始化時執行 `setupView`：
 
    - 配置所有子視圖並建立其 `StackView` 結構。
 
 2. 在使用 `configure` 方法時：
 
    - 傳入總金額和準備時間的數值，更新 `totalAmountValueLabel` 和 `totalPrepTimeValueLabel` 的顯示內容。
 
 3. 當 Cell 被重複使用時：
 
    - `prepareForReuse` 方法重置數值標籤為默認值，避免顯示上一次的數據。
 */


import UIKit

/// 展示訂單的總金額與準備時間的 `UICollectionViewCell`。
///
/// 此類別透過多層次的 StackView 組合，整合以下內容：
/// - 金額圖示與金額標籤
/// - 準備時間圖示與準備時間標籤
/// - 主 StackView 包含金額與準備時間的 StackView
class OrderItemSummaryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderItemSummaryCollectionViewCell"
        
    // MARK: - 顯示金額圖示、總金額、總金額數值
    
    /// 顯示金額圖示
    private let totalAmountIcon = OrderItemIconImageView(image: UIImage(systemName: "dollarsign.circle"), tintColor: .gray, size: 24, symbolWeight: .medium)
    /// 顯示金額標籤
    private let totalAmountLabel = OrderItemLabel(text: "Total Amount", font: .systemFont(ofSize: 16, weight: .bold), textColor: .lightGray)
    /// 顯示金額數值
    private let totalAmountValueLabel = OrderItemLabel(text: "$ 0", font: .systemFont(ofSize: 16, weight: .medium), textColor: .darkGray)
    
    // MARK: - 顯示時鐘圖示、準備時間、準備時間數值
    
    /// 顯示準備時間圖示
    private let totalPrepTimeIcon = OrderItemIconImageView(image: UIImage(systemName: "clock"), tintColor: .gray, size: 24, symbolWeight: .medium)
    /// 顯示準備時間標籤
    private let totalPrepTimeLabel = OrderItemLabel(text: "Preparation Time", font: .systemFont(ofSize: 16, weight: .bold), textColor: .lightGray)
    /// 顯示準備時間數值
    private let totalPrepTimeValueLabel = OrderItemLabel(text: "0 min", font: .systemFont(ofSize: 16, weight: .medium), textColor: .darkGray)
    
    // MARK: - 子 StackView
    
    /// 金額的圖示與標籤的 StackView
    private let totalAmountIconAndLabelStackView = OrderItemStackView(axis: .horizontal, spacing: 4, alignment: .center, distribution: .fill)
    /// 準備時間的圖示與標籤的 StackView
    private let totalPrepTimeIconAndLabelStackView = OrderItemStackView(axis: .horizontal, spacing: 4, alignment: .center, distribution: .fill)
    
    // MARK: - 主 StackView
    
    /// 包含金額圖示、標籤與數值的 StackView
    private let totalAmountStackView = OrderItemStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .equalSpacing)
    /// 包含準備時間圖示、標籤與數值的 StackView
    private let totalPrepTimeStackView = OrderItemStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .equalSpacing)
    /// 主 StackView，包含金額與準備時間的 StackView
    private let mainOrderSummaryStackView = OrderItemStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fillEqually)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置所有視圖
    private func setupView() {
        setupTotalAmountStackView()
        setupTotalPrepTimeStackView()
        setupMainOrderSummaryStackView()
        setupConstraints()
    }
    
    /// 配置金額的 StackView
    private func setupTotalAmountStackView() {
        totalAmountIconAndLabelStackView.addArrangedSubview(totalAmountIcon)
        totalAmountIconAndLabelStackView.addArrangedSubview(totalAmountLabel)
        
        totalAmountStackView.addArrangedSubview(totalAmountIconAndLabelStackView)
        totalAmountStackView.addArrangedSubview(totalAmountValueLabel)
    }
    
    /// 配置準備時間的 StackView
    private func setupTotalPrepTimeStackView() {
        totalPrepTimeIconAndLabelStackView.addArrangedSubview(totalPrepTimeIcon)
        totalPrepTimeIconAndLabelStackView.addArrangedSubview(totalPrepTimeLabel)
        
        totalPrepTimeStackView.addArrangedSubview(totalPrepTimeIconAndLabelStackView)
        totalPrepTimeStackView.addArrangedSubview(totalPrepTimeValueLabel)
    }
    
    /// 配置主 StackView
    private func setupMainOrderSummaryStackView() {
        mainOrderSummaryStackView.addArrangedSubview(totalAmountStackView)
        mainOrderSummaryStackView.addArrangedSubview(totalPrepTimeStackView)
    }
    
    /// 將主 StackView 添加到 `contentView` 並設置約束
    private func setupConstraints() {
        contentView.addSubview(mainOrderSummaryStackView)
        
        NSLayoutConstraint.activate([
            mainOrderSummaryStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainOrderSummaryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            mainOrderSummaryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            mainOrderSummaryStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configure Method
    
    /// 配置總金額與準備時間的數值
    /// - Parameters:
    ///   - totalAmount: 總金額
    ///   - totalPrepTime: 準備時間
    func configure(totalAmount: Int, totalPrepTime: Int) {
        totalAmountValueLabel.text = "$ \(totalAmount)"
        totalPrepTimeValueLabel.text = "\(totalPrepTime) min"
    }
    
    // MARK: - Lifecycle Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        totalAmountValueLabel.text = "$ 0"
        totalPrepTimeValueLabel.text = "0 min"
    }
    
}
