//
//  OrderCustomerSubmitCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/16.
//

/*
 
 ## OrderCustomerSubmitCell 重點筆記
 
    * 功能：
        - 提供提交訂單的按鈕，並檢查顧客資料是否完整，將訂單提交到 Firestore。
 
    * 組成部分：

        1. UI 元素
            - submitButton：提交訂單的按鈕，設置顏色、樣式及圖標，並使用 UIButton.Configuration 來管理按鈕的外觀。
 
        2. 回調 (Callback)
            - onSubmitTapped：當用戶點擊按鈕時觸發的回調，可在外部實現具體的提交訂單邏輯，例如將訂單資料傳遞至 Firestore。
 
        3. 初始化
            - setupViews()：設置按鈕的佈局，包括邊距和高度限制。
            - setupActions()：為按鈕添加點擊事件的監聽。
 
        4. 按鈕配置方法
            - configureSubmitButton(isEnabled:)：用於控制按鈕的啟用狀態，例如當顧客資料不完整時禁用按鈕，並改變按鈕顏色以提供視覺提示。
 
    * 重要方法：
            
        1. createButton(title:font:backgroundColor:cornerStyle:titleColor:iconMame:)
            - 使用 UIButton.Configuration 來設定按鈕的標題、顏色、圖標及字體，確保按鈕樣式的統一性和可擴展性。
 
        2. configureSubmitButton(isEnabled:)
            - 根據顧客資料的完整性來控制按鈕的可用狀態，避免用戶提交不完整的訂單資料。
 
    * 設計考量：

        1. 按鈕的外觀設計
            - 使用 UIButton.Configuration 使得按鈕的設計簡化，同時提供了一致且可定制的樣式，讓代碼更具可讀性和易維護性。
 
        2. 資料完整性控制
            - configureSubmitButton(isEnabled:) 用於控制提交按鈕的狀態，確保只有在資料完整時用戶才能進行提交操作，提升用戶體驗並減少錯誤提交的可能性。
 
        3. 圖標的添加
            - 按鈕上添加圖標，並將圖標置於標題後，讓按鈕不僅在視覺上更有吸引力，也能更好地表達按鈕的功能性。
 
    * 未來改進空間：

        1. 按鈕的動態反饋
            - 可以為按鈕添加點擊動畫或顏色變化，增強用戶的操作回饋效果。
 
        2. 提交結果的回饋
            - 在提交訂單後，可以顯示一個 HUD 或提示，告知用戶提交成功或失敗的結果。
            - 提交成功後會彈出訂單成功視圖。
            - 提交失敗後會出現警告視窗。
 */

import UIKit

/// 設置`按鈕`判斷資料是否完整，並且用於提交整個 Order 到 FireStore
class OrderCustomerSubmitCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "OrderCustomerSubmitCell"
    
    // MARK: - UI Elements
    
    /// 提交訂單的按鈕
    private let submitButton = createButton(title: "Submit Order", font: UIFont.systemFont(ofSize: 18, weight: .semibold), backgroundColor: .deepGreen, cornerStyle: .medium, titleColor: .white, iconMame: "tray.and.arrow.up.fill")
    
    // MARK: - Callbacks
    
    /// 點擊提交按鈕時的回調
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
    
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Factory Method
    
    private static func createButton(title: String, font: UIFont, backgroundColor: UIColor, cornerStyle: UIButton.Configuration.CornerStyle, titleColor: UIColor, iconMame: String) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseForegroundColor = titleColor
        configuration.baseBackgroundColor = backgroundColor
        configuration.cornerStyle = cornerStyle
        
        // 設置圖標
        configuration.image = UIImage(systemName: iconMame)
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        
        // 使用 NSAttributedString 設置字體
        var titleAttr = AttributedString(title)
        titleAttr.font = font
        configuration.attributedTitle = titleAttr
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Action Handler
    
    @objc private func submitButtonTapped() {
        submitButton.addSpringAnimation(scale: 1.05) {_ in 
            self.onSubmitTapped?()
        }
    }
    
    // MARK: - Helper Methods
    
    /// 配置按鈕狀態（根據驗證資料未完成時禁用按鈕）
    /// - Parameter isEnabled: 按鈕是否可用
    func configureSubmitButton(isEnabled: Bool) {
        print("配置提交按鈕: \(isEnabled ? "啟用" : "禁用")")
        submitButton.isEnabled = isEnabled
        
        // 使用 AttributeContainer 來設置字體和顏色
        var attributedTitle = AttributedString("Submit Order")
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        container.foregroundColor = isEnabled ? UIColor.white : UIColor.lightGray
        attributedTitle.mergeAttributes(container)
        
        submitButton.configuration?.attributedTitle = attributedTitle
    }
    
}
