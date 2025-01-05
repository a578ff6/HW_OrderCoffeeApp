//
//  OrderCustomerSubmitCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/16.
//

// MARK: - OrderCustomerSubmitCell 筆記
/**
 
 ## OrderCustomerSubmitCell 筆記

` * What`
 
 - `OrderCustomerSubmitCell` 是一個自訂的 `UICollectionViewCell`，包含以下功能：
 
 - 提交按鈕：提供一個可自訂樣式的按鈕，用於提交訂單。
 - 按鈕狀態控制：透過 `configureSubmitButton(isEnabled:)` 動態控制按鈕的啟用狀態。
 - 點擊回調：支援按鈕點擊事件回調，外部可接收並執行相應的業務邏輯。

 ----------------

` * Why`
 
 `1. 需求背景：`
 
 - `OrderCustomerSubmitCell` 將這個功能封裝為一個可重用的組件，簡化業務邏輯的實現。
    
 `2. 核心需求：`
 
 - 用戶交互：需要一個直觀的提交按鈕來引導用戶完成訂單提交。
 - 狀態控制：根據資料驗證結果動態啟用或禁用按鈕，避免用戶提交不完整的訂單信息。
 - 彈性設計：提供回調支持，方便外部處理點擊事件。

 `3. 設計理由：`
 
 - 提升模組化程度：將提交按鈕封裝在 Cell 中，保持視圖與業務邏輯分離。
 - 增強一致性：按鈕的樣式與行為統一由 `OrderCustomerDetailsActionButton` 處理，減少重複代碼。

 ----------------

 `* How`
 
 `1. 初始化與配置：`

 - 在 `UICollectionView` 中註冊並使用 `OrderCustomerSubmitCell`。
 - 使用 `configureSubmitButton(isEnabled:)` 控制按鈕狀態，確保用戶僅在資料完整時能提交訂單。

 `2. 按鈕狀態控制：`
 
 - 透過 `configureSubmitButton` 設定按鈕的啟用或禁用，並自動調整樣式（例如禁用時降低按鈕透明度）。
 - 使用 `OrderCustomerDetailsActionButton` 的 `updateState` 方法實現樣式更新。

 `3. 監聽點擊事件：`
   
 - 設置 `onSubmitTapped` 回調處理按鈕的點擊行為。
 - 點擊按鈕時觸發彈跳動畫，然後執行回調通知外部。

 `4. 按鈕的樣式與行為：`
 
 - 按鈕由 `OrderCustomerDetailsActionButton` 提供，支援標題、圖示、背景色及圓角樣式的自訂。
 - 按鈕禁用時自動調整樣式，例如降低透明度，保持視覺一致性。

 ----------------

 `* 範例代碼`

 ```swift
 // 在 UICollectionView 中註冊和配置
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     guard let cell = collectionView.dequeueReusableCell(
         withReuseIdentifier: OrderCustomerSubmitCell.reuseIdentifier,
         for: indexPath
     ) as? OrderCustomerSubmitCell else {
         return UICollectionViewCell()
     }
     
     // 設置回調
     cell.onSubmitTapped = {
         print("提交訂單按鈕被點擊")
         // 執行訂單提交邏輯
     }
     
     // 配置按鈕狀態
     cell.configureSubmitButton(isEnabled: isFormValid) // 根據資料驗證結果設置

     return cell
 }
 ```

 ----------------

 `* 注意事項`
 
 `1. 資料驗證依賴：`
 
 - `configureSubmitButton(isEnabled:)` 方法需與資料驗證邏輯結合，確保用戶僅能在資料完整時提交訂單。
    
 `2. 彈跳動畫：`
 
 - 按鈕點擊時的彈跳動畫 (`addSpringAnimation`) 是交互體驗的提升，需根據設計需求適配。

 `3. 樣式一致性：`
 
 - `OrderCustomerDetailsActionButton` 統一處理按鈕樣式，確保視覺與交互的一致性。
 */



import UIKit

/// `OrderCustomerSubmitCell` 是一個自訂的 UICollectionViewCell，主要用於顯示提交訂單的按鈕，並提供回調功能以處理按鈕的點擊事件。
///
/// ### 功能特色
/// - 提交按鈕：包含一個 `OrderCustomerDetailsActionButton`，支援自訂樣式及點擊動作。
/// - 按鈕狀態控制：透過 `configureSubmitButton(isEnabled:)` 方法動態啟用或禁用按鈕，並自動調整按鈕樣式。
/// - 點擊回調：按下按鈕後觸發 `onSubmitTapped` 回調，外部可接收點擊事件並執行後續操作。
///
/// ### 使用場景
/// 適用於需要提交訂單或執行重要操作的場景，例如：
/// - 確認訂單並提交到後端伺服器。
/// - 執行資料驗證後觸發後續流程。
///
/// ### 使用方式
/// 1. 初始化 Cell：在 `UICollectionView` 中註冊並使用此 Cell。
/// 2. 配置按鈕狀態：透過 `configureSubmitButton(isEnabled:)` 動態控制按鈕啟用狀態。
/// 3. 監聽點擊事件：設定 `onSubmitTapped` 回調以處理按鈕點擊行為。
///
/// ### 注意事項
/// - `configureSubmitButton(isEnabled:)` 方法需搭配資料驗證邏輯，確保按鈕僅在資料完整時啟用。
/// - 按鈕的樣式和行為統一由 `OrderCustomerDetailsActionButton` 處理，保證視覺和交互一致性。
class OrderCustomerSubmitCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderCustomerSubmitCell"
    
    // MARK: - UI Elements
    
    /// 提交訂單的按鈕
    private let submitButton = OrderItemActionButton(title: "Submit Order", font: .systemFont(ofSize: 18, weight: .semibold), backgroundColor: .deepGreen, titleColor: .white, iconName: "tray.and.arrow.up.fill", cornerStyle: .medium)
    
    // MARK: - Callbacks
    
    /// 回調：當提交按鈕被點擊時通知外部
    ///
    /// - 使用者可透過此回調接收點擊事件並執行後續操作。
    var onSubmitTapped: (() -> Void)?
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 Cell 的主要 UI 元素
    private func setupViews() {
        contentView.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            submitButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    /// 設置按鈕點擊事件的回調
    ///
    /// - 綁定按鈕的點擊事件，觸發 `onSubmitTapped` 回調。
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Handler
    
    /// 按鈕點擊事件處理
    ///
    /// - 觸發按鈕的彈跳動畫後，執行 `onSubmitTapped` 回調。
    @objc private func submitButtonTapped() {
        submitButton.addSpringAnimation(scale: 1.05) {_ in
            self.onSubmitTapped?()
        }
    }
    
    // MARK: - Helper Methods
    
    /// 配置按鈕狀態
    ///
    /// - 根據資料是否完整啟用或禁用按鈕，並自動調整按鈕樣式。
    /// - Parameter isEnabled: 按鈕是否可用。
    func configureSubmitButton(isEnabled: Bool) {
        submitButton.updateState(isEnabled: isEnabled)
    }
    
}
