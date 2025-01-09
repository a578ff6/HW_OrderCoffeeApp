//
//  StoreDefaultInfoView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//

import UIKit

/// 用於顯示預設資訊的 View（未選取門市時）
///
/// 此視圖用於顯示當用戶尚未選擇任何店鋪時的提示訊息，
/// 包括一個標題、一條分隔線以及提示訊息的標籤。
/// - 特點：
///   - 使用 `UIStackView` 統一管理子視圖的佈局，簡化約束配置。
///   - 支援自定義子視圖間距，例如分隔線與提示訊息之間的間距。
class StoreDefaultInfoView: UIView {
    
    // MARK: - UI Elements
    
    /// 提示選擇店鋪的標題
    private let titleLabel = StoreInfoLabel(text: "請選擇門市", font: .systemFont(ofSize: 24, weight: .bold), textColor: .black, textAlignment: .left)
    
    /// 提示訊息的標籤（例如「尚未選擇店鋪」）
    private let infoLabel = StoreInfoLabel(font: .systemFont(ofSize: 18, weight: .bold), textColor: .lightGray, textAlignment: .center)
    
    /// 用於視覺分隔的水平線
    private let separatorView = StoreInfoSeparatorView(height: 1, color: .lightWhiteGray)
    
    /// 主 StackView，統一管理子視圖的垂直佈局
    private let mainStackView = StoreInfoStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer
    
    /// 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置視圖結構和佈局
    ///
    /// - 使用 `UIStackView` 添加並管理 `titleLabel`、`separatorView` 和 `infoLabel`。
    /// - 設置自定義間距：在分隔線和提示訊息之間設置額外的間距以符合設計需求。
    private func setupViews() {
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(separatorView)
        mainStackView.addArrangedSubview(infoLabel)
        
        // 設置分隔線與提示訊息之間的間距為 125
        mainStackView.setCustomSpacing(125, after: separatorView)
        
        addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configure Method
    
    /// 配置 StoreDefaultInfoView 的提示訊息
    ///
    /// - Parameter message: 預設訊息，用於顯示在提示訊息標籤上
    func configure(with message: String) {
        infoLabel.text = message
    }
    
}
