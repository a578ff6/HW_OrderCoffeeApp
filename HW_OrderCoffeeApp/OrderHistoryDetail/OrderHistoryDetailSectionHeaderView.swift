//
//  OrderHistoryDetailSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//

import UIKit

/// OrderHistoryDetailSectionHeaderView 佈局使用，設置 Section Header
class OrderHistoryDetailSectionHeaderView: UICollectionReusableView {
        
    static let headerIdentifier = "OrderHistoryDetailSectionHeaderView"
    
    // MARK: - UI Elements

    /// 標題標籤，顯示每個區塊的名稱
    private let titleLabel = OrderHistoryDetailSectionHeaderView.createLabel(font: .systemFont(ofSize: 22, weight: .semibold), textColor: .black)
    /// 箭頭符號，指示區塊的展開或收起狀態
    private let arrowImageView = OrderHistoryDetailSectionHeaderView.createArrowImageView()
    /// 分隔線視圖，用於增強視覺上的分隔效果
    private let separatorView = OrderHistoryDetailSectionHeaderView.createSeparatorView(height: 2)
    
    /// 標題和箭頭的堆疊視圖，用於排列標題文字和箭頭符號
    private let titleAndArrowStackView = OrderHistoryDetailSectionHeaderView.createStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    
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
    
    // MARK: - Factory Methods
    
    /// 建立標題標籤
    private static func createLabel(font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = textColor
        return label
    }
    
    /// 建立箭頭符號視圖
    /// - Returns: 配置好的箭頭符號視圖，預設為向右箭頭
    private static func createArrowImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "chevron.right")  // 預設顯示向右箭頭
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return imageView
    }
    
    /// 建立分隔線視圖
    private static func createSeparatorView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .deepGreen.withAlphaComponent(0.5)
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    /// 建立 UIStackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Configuration Method
    
    /// 設置標題文字並更新箭頭方向
    /// - Parameters:
    ///   - title: 標題文字
    ///   - isExpanded: 是否展開狀態，展開時顯示向下箭頭
    ///   - showArrow: 是否顯示箭頭，對於無法展開的區塊則隱藏
    func configure(with title: String, isExpanded: Bool, showArrow: Bool) {
        titleLabel.text = title
        arrowImageView.isHidden = !showArrow
        arrowImageView.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置視圖的狀態以便重複使用
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        arrowImageView.image = UIImage(systemName: "chevron.right")
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }  // 清除手勢識別器，避免重複附加
    }

}
