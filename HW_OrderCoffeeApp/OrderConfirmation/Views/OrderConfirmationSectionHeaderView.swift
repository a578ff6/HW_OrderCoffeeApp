//
//  OrderConfirmationSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/5.
//

// MARK: - SectionHeader、分格線

import UIKit

/// OrderConfirmationViewController 佈局使用，設置 Section Header
class OrderConfirmationSectionHeaderView: UICollectionReusableView {
    
    static let headerIdentifier = "OrderConfirmationSectionHeaderView"
    
    // MARK: - UI Elements
    
    private let titleLabel = OrderConfirmationSectionHeaderView.createLabel(font: .systemFont(ofSize: 22, weight: .semibold), textColor: .black)
    private let separatorView = OrderConfirmationSectionHeaderView.createSeparatorView(height: 2)
    private let titleAndSeparatorStackView = OrderConfirmationSectionHeaderView.createStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
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
        titleAndSeparatorStackView.addArrangedSubview(titleLabel)
        titleAndSeparatorStackView.addArrangedSubview(separatorView)
        
        addSubview(titleAndSeparatorStackView)
        
        NSLayoutConstraint.activate([
            titleAndSeparatorStackView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            titleAndSeparatorStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleAndSeparatorStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleAndSeparatorStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
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
    
    /// 設置標題文字
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Lifecycle Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
}


