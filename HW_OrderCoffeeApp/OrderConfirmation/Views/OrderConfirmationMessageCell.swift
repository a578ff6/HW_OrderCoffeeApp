//
//  OrderConfirmationMessageCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

import UIKit

/// 顯示成功提交的提示訊息的Cell
class OrderConfirmationMessageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderConfirmationMessageCell"

    // MARK: - UI Elements
    
    /// 主標籤，用於顯示「Success」
    private let titleLabel = createLabel(text: "Success", font: UIFont.systemFont(ofSize: 28, weight: .bold), textColor: .black, textAlignment: .center)
    
    /// 副標籤，用於顯示補充文字
    private let subtitleLabel = createLabel(text: "Your order has been successfully submitted", font: UIFont.systemFont(ofSize: 16, weight: .medium), numberOfLines: 0, textColor: .lightGray, textAlignment: .center)
    
    /// 整合標籤的 StackView
    private let titleAndSubtitleStackView = createStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
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
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleLabel)
        
        contentView.addSubview(titleAndSubtitleStackView)
        
        NSLayoutConstraint.activate([
            titleAndSubtitleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleAndSubtitleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleAndSubtitleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleAndSubtitleStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Factory Method
    
    /// 建立並配置 UILabel
    private static func createLabel(text: String? = nil, font: UIFont, numberOfLines: Int = 1, textColor: UIColor = .black, scaleFactor: CGFloat = 1.0, textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = font
        label.numberOfLines = numberOfLines
        label.textColor = textColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = scaleFactor
        label.textAlignment = textAlignment
        return label
    }
    
    /// 創建並配置 UIStackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
}
