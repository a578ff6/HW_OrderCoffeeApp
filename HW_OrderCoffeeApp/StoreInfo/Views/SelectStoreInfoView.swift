//
//  SelectStoreInfoView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//


// MARK: - SelectStoreInfoView 筆記
/**
 
 ## SelectStoreInfoView 筆記

 ---

 `* What`
 
 - `SelectStoreInfoView` 是一個自定義視圖，專門用於顯示門市的詳細資訊，包含：
 
 1. 門市名稱（`name`）
 2. 地址（`address`）
 3. 距離（`distance`）
 4. 電話號碼（`phoneNumber`）
 5. 今日營業時間（`todayHours`）
 6. 操作按鈕：
    - 撥打電話（`Call Phone`）
    - 選擇門市（`Select Store`）

 ---

` * Why`

 1. 模組化設計：
 
    - 將門市的視圖邏輯集中於 `SelectStoreInfoView`，使得其他視圖控制器如 `StoreInfoViewController` 的代碼更簡潔。
    - 支持復用，任何需要顯示門市資訊的地方都可以直接使用此視圖。

 2.操作解耦：
 
    - 使用回調（`onCallPhoneTapped` 和 `onSelectStoreTapped`）處理按鈕點擊事件，實現視圖與業務邏輯的分離。
    - 提升靈活性，不同的控制器可以根據需要提供不同的操作。

 3. 優化用戶體驗：
 
    - 支持多行顯示（如地址和營業時間），確保長文本的可讀性。
    - 提供直觀的操作按鈕，便於用戶快速進行交互（如撥打電話或選擇門市）。

 ---

 `* How`

 1. UI 組織：
 
    - 使用多層 `UIStackView` 將門市的各個屬性（名稱、地址、距離、電話、營業時間）和操作按鈕分區顯示。
    - 設置多行支持的 `UILabel`（如 `addressValueLabel` 和 `openingHoursValueLabel`），確保視圖的可擴展性。

 2. 回調設置：
 
    - 提供兩個回調變數：
      - `onCallPhoneTapped`：點擊撥打電話按鈕的行為。
      - `onSelectStoreTapped`：點擊選擇門市按鈕的行為。
 
    - 使用者可通過回調將具體業務邏輯（如撥打電話或更新選擇結果）注入到視圖外部。

 3. 配置方法：
 
    - 提供 `configure(with:)` 方法，接受 `StoreInfoViewModel` 作為參數。
    - 使用 `ViewModel` 簡化數據處理，避免視圖直接處理原始數據（如格式化電話號碼或營業時間）。

 4. 動畫效果：
    - 通過 `addSpringAnimation`，在按鈕點擊時提供縮放效果，提升用戶操作的回饋感。

 ---

 `* 使用範例`

 - 在 `StoreInfoViewController` 中使用 `SelectStoreInfoView`

 ```swift
 let storeInfoView = SelectStoreInfoView()

 // 配置視圖
 let viewModel = StoreInfoViewModel(store: selectedStore, userLocation: currentLocation)
 storeInfoView.configure(with: viewModel)

 // 設置回調
 storeInfoView.onCallPhoneTapped = {
     // 執行撥打電話邏輯
     print("撥打電話至 \(viewModel.formattedPhoneNumber)")
 }

 storeInfoView.onSelectStoreTapped = {
     // 更新選擇結果
     print("選擇的門市為 \(viewModel.name)")
 }
 ```
 
 */

// MARK: - (v)

import UIKit
import CoreLocation

/// 用於顯示門市詳細資訊的視圖
///
/// - 功能說明：
///   - `SelectStoreInfoView` 提供門市詳細資訊的顯示，包括名稱、地址、距離、電話號碼，以及營業時間等。
///   - 支援兩個主要操作：
///     1. 撥打電話按鈕（`Call Phone`）
///     2. 選擇門市按鈕（`Select Store`）
///   - 使用多層 `UIStackView` 組織佈局，確保結構清晰，易於擴展與維護。
///
/// - 使用場景：
///   - 該視圖通常嵌入其他控制器（如 `StoreInfoViewController` 或浮動面板）中，用於顯示使用者選取的門市資訊。
///
/// - 設計特性：
///   - 提供外部回調（`onCallPhoneTapped` 和 `onSelectStoreTapped`）以實現操作行為的解耦。
///   - 適配多行顯示的元件（如地址與營業時間），以提升使用者體驗。
class SelectStoreInfoView: UIView {
    
    // MARK: - Button Callbacks
    
    /// 撥打電話按鈕的行為回調
    var onCallPhoneTapped: (() -> Void)?
    
    /// 選擇門市按鈕的行為回調
    var onSelectStoreTapped: (() -> Void)?
    
    // MARK: - UI Elements
    
    /// 門市名稱標籤
    private let nameLabel = StoreInfoLabel(font: .systemFont(ofSize: 24, weight: .bold), textColor: .black)
    
    /// 分隔線
    private let separatorView1 = StoreInfoSeparatorView(height: 1, color: .lightWhiteGray)
    private let separatorView2 = StoreInfoSeparatorView(height: 1, color: .lightWhiteGray)
    
    // MARK: - 地址區塊
    
    private let addressSymbolImageView = StoreInfoIconImageView(image: UIImage(systemName: "mappin.and.ellipse"), tintColor: .deepGreen, size: 18, symbolWeight: .regular)
    private let addressValueLabel = StoreInfoLabel(font: .systemFont(ofSize: 16, weight: .medium), textColor: .gray, numberOfLines: 0)
    private let addressStackView = StoreInfoStackView(axis: .horizontal, spacing: 15, alignment: .center, distribution: .fill)
    
    // MARK: - 距離區塊
    
    private let distanceSymbolImageView = StoreInfoIconImageView(image: UIImage(systemName: "figure.walk.diamond"), tintColor: .deepGreen, size: 18, symbolWeight: .regular)
    private let distanceValueLabel = StoreInfoLabel(font: .systemFont(ofSize: 16), textColor: .lightGray)
    private let distanceStackView = StoreInfoStackView(axis: .horizontal, spacing: 15, alignment: .center, distribution: .fill)
    
    // MARK: - 電話號碼區塊
    
    private let phoneSymbolImageView = StoreInfoIconImageView(image: UIImage(systemName: "phone.connection"), tintColor: .deepGreen, size: 18, symbolWeight: .regular)
    private let phoneNumberValueLabel = StoreInfoLabel(font: .systemFont(ofSize: 16), textColor: .gray)
    private let phoneNumberStackView = StoreInfoStackView(axis: .horizontal, spacing: 15, alignment: .center, distribution: .fill)
    
    // MARK: - 營業時間區塊
    
    private let openingHoursSymbolImageView = StoreInfoIconImageView(image: UIImage(systemName: "clock"), tintColor: .deepGreen, size: 18, symbolWeight: .regular)
    private let openingHoursValueLabel = StoreInfoLabel(font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 0)
    private let openingHoursStackView = StoreInfoStackView(axis: .horizontal, spacing: 15, alignment: .center, distribution: .fill)
    
    // MARK: - 操作按鈕
        
    private let callButton = StoreInfoActionButton(title: "Call Phone", font: .systemFont(ofSize: 18, weight: .semibold), backgroundColor: .lightWhiteGray, titleColor: .lightGray, iconName: "phone.fill", cornerStyle: .medium)
    
    private let selectStoreButton = StoreInfoActionButton(title: "Select Store", font: .systemFont(ofSize: 18, weight: .semibold), backgroundColor: .deepGreen, titleColor: .white, iconName: "storefront.fill", cornerStyle: .medium)
    
    // MARK: - StackView
    
    /// 主堆疊視圖
    private let contentStackView = StoreInfoStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
    
    /// 按鈕堆疊視圖
    private let buttonStackView = StoreInfoStackView(axis: .horizontal, spacing: 12, alignment: .leading, distribution: .fill)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置地址區塊
    private func setupAddressStackView() {
        addressStackView.addArrangedSubview(addressSymbolImageView)
        addressStackView.addArrangedSubview(addressValueLabel)
    }
    
    /// 配置距離區塊
    private func setupDistanceStackView() {
        distanceStackView.addArrangedSubview(distanceSymbolImageView)
        distanceStackView.addArrangedSubview(distanceValueLabel)
    }
    
    /// 配置電話號碼區塊
    private func setupPhoneNumberStackView() {
        phoneNumberStackView.addArrangedSubview(phoneSymbolImageView)
        phoneNumberStackView.addArrangedSubview(phoneNumberValueLabel)
    }
    
    /// 配置營業時間區塊
    private func setupOpeningHoursStackView() {
        openingHoursStackView.addArrangedSubview(openingHoursSymbolImageView)
        openingHoursStackView.addArrangedSubview(openingHoursValueLabel)
    }
    
    /// 配置按鈕區塊
    private func setupButtonStackView() {
        buttonStackView.addArrangedSubview(callButton)
        buttonStackView.addArrangedSubview(selectStoreButton)
    }
    
    /// 配置主內容堆疊視圖
    private func setupContentStackView() {
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(separatorView1)
        contentStackView.addArrangedSubview(addressStackView)
        contentStackView.addArrangedSubview(distanceStackView)
        contentStackView.addArrangedSubview(separatorView2)
        contentStackView.addArrangedSubview(phoneNumberStackView)
        contentStackView.addArrangedSubview(openingHoursStackView)
        contentStackView.addArrangedSubview(buttonStackView)
        addSubview(contentStackView)
    }
    
    /// 配置視圖的佈局約束
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            callButton.heightAnchor.constraint(equalToConstant: 55),
            selectStoreButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    /// 設置所有子視圖與佈局
    private func setupViews() {
        setupAddressStackView()
        setupDistanceStackView()
        setupPhoneNumberStackView()
        setupOpeningHoursStackView()
        setupButtonStackView()
        setupContentStackView()
        setupConstraints()
    }
    
    // MARK: - Setup Actions
    
    /// 設置按鈕的目標行為
    private func setupActions() {
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        selectStoreButton.addTarget(self, action: #selector(selectStoreButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    
    @objc private func callButtonTapped() {
        callButton.addSpringAnimation(scale: 1.05) { _ in
            self.onCallPhoneTapped?()
        }
    }
    
    @objc private func selectStoreButtonTapped() {
        selectStoreButton.addSpringAnimation(scale: 1.05) { _ in
            self.onSelectStoreTapped?()
        }
    }
    
    // MARK: - Configure Method
    
    /// 配置 `SelectStoreInfoView` 顯示門市詳細資訊
    ///
    /// ### 功能說明：
    /// - 將門市相關資訊（名稱、地址、距離、電話號碼、營業時間）從 `StoreInfoViewModel` 填充到對應的 UI 元件。
    /// - 支援多行文字（例如地址與營業時間），確保資訊完整顯示。
    ///
    /// ### 使用場景：
    /// - 當需要展示特定門市的詳細資訊時，呼叫此方法，並傳入包含相關資訊的 `StoreInfoViewModel`。
    ///
    /// ### 邏輯：
    /// 1. 名稱：填充 `nameLabel`。
    /// 2. 地址：填充 `addressValueLabel`，支持多行顯示。
    /// 3. 距離：填充 `distanceValueLabel`，顯示格式化後的距離（例如 "1.23 km"）。
    /// 4. 電話號碼：填充 `phoneNumberValueLabel`，顯示格式化後的電話號碼。
    /// 5. 今日營業時間：填充 `openingHoursValueLabel`，顯示今日的營業時間資訊。
    ///
    /// - Parameter viewModel: 包含門市資訊的 `StoreInfoViewModel`。
    func configure(with viewModel: StoreInfoViewModel) {
        nameLabel.text = viewModel.name
        addressValueLabel.text = viewModel.address
        distanceValueLabel.text = viewModel.formattedDistance
        phoneNumberValueLabel.text = viewModel.formattedPhoneNumber
        openingHoursValueLabel.text = viewModel.formattedTodayHours
    }
    
}
