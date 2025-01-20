//
//  OrderHistoryCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//


// MARK: - OrderHistoryCell 筆記
/**
 
 ## OrderHistoryCell 筆記


` * What`
 
 - `OrderHistoryCell` 是一個自訂的 `UITableViewCell`，用於在歷史訂單列表中顯示每筆訂單的核心資訊。

 - 顯示內容：
 
   1. 顧客姓名
   2. 訂單成立日期
   3. 取件方式（包含圖標與描述）
   4. 訂單編號
   5. 訂單金額

 - 設計特性：
 
   1. 採用動態佈局：行高根據內容自動調整。
   2. 使用 StackView：簡化內部多層級的視圖排列。
   3. 支援重用：透過 `prepareForReuse` 方法，避免資料混淆。

 ----------

 `* Why`

 1. 提升可讀性與維護性：
 
    - 將資訊拆分為獨立的 `UILabel` 和 `StackView`，保持結構清晰、層級分明，方便後續的擴展與修改。

 2. 確保 UI 的一致性與自適應性：
 
    - 採用動態行高（`UITableView.automaticDimension`）和約束管理，適應不同內容長度，避免資訊截斷或排版混亂。
    - 使用 StackView，自動處理子視圖的排列與間距，減少手動佈局錯誤。

 3. 提高重用性：
 
    - 通過重用 Cell，減少記憶體佔用。
    - 使用 `prepareForReuse` 確保每次 Cell 重用時顯示正確的資料。

 4. 便於擴展：
 
    - 如果未來需要增加更多訂單資訊或改變現有樣式，清晰的結構和方法分工能更輕鬆地支持修改。

 ----------

 *` How`

 1. 核心結構：
 
    - 使用多個 `UILabel` 和 `UIImageView` 顯示訂單資訊。
 
    - 採用三個 StackView：
 
      - `nameAndDateStackView`：水平排列顧客姓名與訂單日期。
      - `pickupStackView`：水平排列取件方式的圖標與文字。
      - `textStackView`：垂直排列所有資訊。

 2. 配置流程：
 
    - 在 `setupView` 方法中，依次配置 StackView 的內容（名稱、取件方式、訂單資訊）。
    - 配置約束，將主 StackView 固定在 Cell 的內容視圖內，保持統一間距。

 3. 動態內容設置：
 
    - 使用 `configure(with order:)` 方法根據 `OrderHistory` 資料動態設置每個視圖的內容。
    - 使用 `configurePickupMethod(_:)` 單獨處理取件方式的邏輯，支持未來的擴展。

 4. 重用處理：
 
    - 在 `prepareForReuse` 中，將所有的文字與圖標重置為初始狀態，避免舊資料干擾。

 ----------

 `* 總結`

 - `OrderHistoryCell` 是一個高度結構化的 `UITableViewCell`，旨在展示歷史訂單的核心資訊。
 - 透過動態佈局與清晰的視圖層次結構，該設計確保了內容的正確顯示和 UI 的一致性。
 - 對取件方式等邏輯進行拆分與封裝，既提高了程式碼的可讀性，又為未來的擴展提供了便利。

 */



import UIKit

/// `OrderHistoryCell`
///
/// 用於顯示歷史訂單資訊的自訂 UITableViewCell。
///
/// - 功能特色：
///   1. 顯示訂單的詳細資訊，包括顧客姓名、訂單日期、取件方式、訂單編號及金額。
///   2. 支援動態佈局，行高根據內容自動調整，確保顯示效果最佳化。
///   3. 提供清晰的層級結構，使用 StackView 簡化內部佈局管理。
///   4. 支援 Cell 重用，通過 `prepareForReuse` 確保資料不混淆。
///
/// - 使用場景：
///   此 Cell 適用於歷史訂單列表，展示每筆訂單的核心資訊。
class OrderHistoryCell: UITableViewCell {
    
    // MARK: - Reuse Identifier
    
    static let reuseIdentifier = "OrderHistoryCell"
    
    // MARK: - UI Elements
    
    /// 顯示顧客姓名。
    private let nameLabel = OrderHistoryLabel(font: .systemFont(ofSize: 18, weight: .medium), scaleFactor: 0.7, textAlignment: .left)
    
    /// 顯示訂單成立日期。
    private let dateLabel = OrderHistoryLabel(font: .systemFont(ofSize: 14, weight: .light), textColor: .lightGray, textAlignment: .right)
    
    /// 根據取件方式顯示不同的 SF Symbol 圖標。
    private let pickupIconImageView = OrderHistoryIconImageView(tintColor: .lightGray, size: 24, symbolWeight: .medium)
    
    /// 顯示取件方式，例如「到店取件」或「送貨到府」。
    private let pickupMethodLabel = OrderHistoryLabel(font: .systemFont(ofSize: 15, weight: .semibold), textColor: .lightGray)
    
    /// 顯示訂單編號，例如「Order ID: 12345」。
    private let orderIdLabel = OrderHistoryLabel(font: .systemFont(ofSize: 14, weight: .medium), textColor: .darkGray, scaleFactor: 0.5)

    /// 顯示訂單金額，例如「NT$ 500」。
    private let totalAmountLabel = OrderHistoryLabel(font: .systemFont(ofSize: 16, weight: .bold), textColor: .deepGreen)
    
    
    // MARK: - StackView
    
    /// 名稱與日期的水平排列 StackView。
    private let nameAndDateStackView = OrderHistoryStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .fill)
    
    /// 取件方式的水平排列 StackView。
    private let pickupStackView = OrderHistoryStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .fill)
    
    /// 垂直排列的主 StackView，包含所有資訊（名稱、日期、取件方式、編號、金額）。
    private let textStackView = OrderHistoryStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    
    // MARK: - Initializer
    
    /// 初始化 `OrderHistoryCell`。
    /// - Parameters:
    ///   - style: Cell 的樣式，默認為 `.default`。
    ///   - reuseIdentifier: Cell 的重用標識符。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設定 Cell 的佈局，包含建立 UI 元件並將其添加到內容視圖。
    private func setupView() {
        setupNameAndDateStackView()
        setupPickupStackView()
        setupTextStackView()
        setupConstraints()
    }
    
    /// 配置名稱與日期的 StackView
    private func setupNameAndDateStackView() {
        nameAndDateStackView.addArrangedSubview(nameLabel)
        nameAndDateStackView.addArrangedSubview(dateLabel)
    }
    
    /// 配置取件方式的 StackView
    private func setupPickupStackView() {
        pickupStackView.addArrangedSubview(pickupIconImageView)
        pickupStackView.addArrangedSubview(pickupMethodLabel)
    }
    
    /// 配置主 StackView，將名稱、日期、取件方式、訂單編號及金額加入主視圖。
    private func setupTextStackView() {
        textStackView.addArrangedSubview(nameAndDateStackView)
        textStackView.addArrangedSubview(pickupStackView)
        textStackView.addArrangedSubview(orderIdLabel)
        textStackView.addArrangedSubview(totalAmountLabel)
        contentView.addSubview(textStackView)
    }
    
    /// 配置 StackView 的佈局約束
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configure Method
    
    /// 根據 OrderHistory 配置 Cell 的內容
    ///
    /// - Parameter order: 歷史訂單物件，用於顯示 Cell 的相關資訊
    func configure(with order: OrderHistory) {
        nameLabel.text = order.customerDetails.fullName
        dateLabel.text = DateFormatter.localizedString(from: order.timestamp, dateStyle: .medium, timeStyle: .short)
        orderIdLabel.text = "OrderID: \(order.id)"
        totalAmountLabel.text = "NT$ \(order.totalAmount)"
        
        configurePickupMethod(order.customerDetails.pickupMethod)
    }
    
    /// 配置取件方式的圖標和文字
    ///
    /// - Parameter pickupMethod: 訂單的取件方式
    private func configurePickupMethod(_ pickupMethod: OrderHistoryPickupMethod) {
        switch pickupMethod {
        case .homeDelivery:
            pickupMethodLabel.text = "Home Delivery"
            pickupIconImageView.image = UIImage(systemName: "bicycle")
        case .inStore:
            pickupMethodLabel.text = "In Store"
            pickupIconImageView.image = UIImage(systemName: "storefront")
        }
    }
    
    // MARK: - UITableViewCell Reuse
    
    // 重設顯示內容，避免重複使用的 cell 中出現上一次顯示的資料
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        dateLabel.text = nil
        orderIdLabel.text = nil
        totalAmountLabel.text = nil
        pickupMethodLabel.text = nil
        pickupIconImageView.image = nil
    }
    
}
