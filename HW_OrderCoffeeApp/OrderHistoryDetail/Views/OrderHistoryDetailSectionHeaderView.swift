//
//  OrderHistoryDetailSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//

import UIKit

/// `OrderHistoryDetailSectionHeaderView` 是用於 `OrderHistoryDetailViewController` 的區段標題視圖。
///
/// - 功能：
///   - 用於展示區塊標題，並支援展開/收起的視覺提示（箭頭）。
///   - 增強分隔區塊的視覺效果，便於用戶理解頁面結構。
///
/// - 特點：
///   1. 支援自定義標題文字和箭頭符號的顯示狀態（展開或收起）。
///   2. 分隔線增強視覺層次感，清晰劃分區塊內容。
///   3. 使用堆疊視圖（StackView）統一管理標題和箭頭符號，簡化佈局。
///
/// - 使用場景：
///   - 用於歷史訂單詳細頁面的不同區塊，例如飲品項目、訂單明細、顧客資訊等，提供區塊標題並指示展開狀態。
class OrderHistoryDetailSectionHeaderView: UICollectionReusableView {
        
    static let headerIdentifier = "OrderHistoryDetailSectionHeaderView"
    
    // MARK: - UI Elements

    /// 標題標籤，顯示每個區塊的名稱
    private let titleLabel = OrderHistoryDetailLabel(font: .systemFont(ofSize: 22, weight: .heavy), textColor: .black)
    
    /// 箭頭符號，指示區塊的展開或收起狀態
    private let arrowImageView = OrderHistoryDetailIconImageView(image: UIImage(systemName: "chevron.right"), tintColor: .gray, size: 20, symbolWeight: .medium)
    
    /// 分隔線視圖，用於增強視覺上的分隔效果
    private let separatorView = OrderHistoryDetailBottomLineView(backgroundColor: .deepGreen.withAlphaComponent(0.5), height: 2.0)
    
    /// 標題和箭頭的堆疊視圖，用於排列標題文字和箭頭符號
    private let titleAndArrowStackView = OrderHistoryDetailStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    
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

    /// 配置視圖的子視圖佈局
    ///
    /// - 包括標題與箭頭堆疊視圖，以及分隔線的佈局。
    private func setupView() {
        titleAndArrowStackView.addArrangedSubview(titleLabel)
        titleAndArrowStackView.addArrangedSubview(arrowImageView)
        
        addSubview(titleAndArrowStackView)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleAndArrowStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleAndArrowStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleAndArrowStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            separatorView.topAnchor.constraint(equalTo: titleAndArrowStackView.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }

    // MARK: - Configuration Method
    
    /// 配置區塊標題及箭頭狀態
    ///
    /// - Parameters:
    ///   - title: 區塊的標題文字
    ///   - isExpanded: 是否展開狀態（`true` 顯示向下箭頭，`false` 顯示向右箭頭）
    ///   - showArrow: 是否顯示箭頭，對於無法展開的區塊則隱藏（隱藏時只顯示標題）
    func configure(with title: String, isExpanded: Bool, showArrow: Bool) {
        titleLabel.text = title
        arrowImageView.isHidden = !showArrow
        arrowImageView.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置視圖的狀態以便重複使用
    ///
    /// - 清空標題文字及箭頭符號，並移除所有手勢識別器，確保狀態不被污染。
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        arrowImageView.image = UIImage(systemName: "chevron.right")
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
    }

}
