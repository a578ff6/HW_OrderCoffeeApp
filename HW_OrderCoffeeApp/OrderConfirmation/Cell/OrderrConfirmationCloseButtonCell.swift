//
//  OrderrConfirmationCloseButtonCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/3.
//

import UIKit

/// `OrderrConfirmationCloseButtonCell` 是一個包含 "關閉" 按鈕的 UICollectionViewCell。
///
/// - 功能：
///   - 用戶點擊按鈕後，可執行關閉操作，例如返回上一頁或退出訂單確認頁面。
///   - 按鈕樣式簡潔，具有彈簧動畫效果，提升用戶體驗。
///
/// - 使用場景：
///   - 用於訂單確認頁面的底部，提供用戶操作完成後返回的功能。
///
/// - 特點：
///   1. 按鈕樣式可配置（字體、顏色、背景色、圓角等）。
///   2. 支援點擊事件回調，方便頁面控制邏輯的實現。
class OrderrConfirmationCloseButtonCell: UICollectionViewCell {
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderrConfirmationCloseButtonCell"
    
    // MARK: - UI Elements
    
    /// 關閉按鈕，帶有標題、圖標及背景樣式
    private let closeButton = OrderrConfirmationActionButton(title: "Close", font: .systemFont(ofSize: 18, weight: .semibold), backgroundColor: .deepGreen, titleColor: .white, iconName: "xmark.circle.fill", cornerStyle: .medium)
    
    // MARK: - Callback Closure
    
    /// 用戶點擊關閉按鈕時的回調處理
    var onCloseButtonTapped: (() -> Void)?
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupAction()
        setupButtonHeight()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置按鈕的佈局
    private func setupLayout() {
        contentView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    /// 配置按鈕高度的約束
    private func setupButtonHeight() {
        closeButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
    }
    
    /// 添加按鈕的點擊事件
    private func setupAction() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Handler
    
    /// 按鈕點擊事件的處理邏輯
    ///
    /// - 動畫效果：按下時有彈簧動畫。
    /// - 回調執行：通過 `onCloseButtonTapped` 通知外部執行關閉操作。
    /// 當`關閉`按鈕被點擊時呼叫，關閉 `OrderConfirmationViewController` ，並且返回到主頁，以及清空Order。
    @objc private func closeButtonTapped() {
        closeButton.addSpringAnimation(scale: 1.05) { _ in
            self.onCloseButtonTapped?()
        }
    }
    
}
