//
//  NoOrdersViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/12.
//

import UIKit

/// 在訂單飲品項目`為空`的時候，顯示使用NoOrdersViewCell。
class NoOrdersViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NoOrdersViewCell"
    
    // MARK: - UI Elements
    
    let messageLabel = createLabel(text: "No items in your order", font: .systemFont(ofSize: 18, weight: .semibold), textColor: .lightGray, alignment: .center)
    let cartImageView = createImageView(imageName: "basket", tintColor: .lightGray, weight: .bold)
    let noOrdersStackView = createStackView(axis: .horizontal, spacing: 8, alignment: .center)
    
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
        
        noOrdersStackView.addArrangedSubview(messageLabel)
        noOrdersStackView.addArrangedSubview(cartImageView)
        
        contentView.addSubview(noOrdersStackView)
        NSLayoutConstraint.activate([
            noOrdersStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noOrdersStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            noOrdersStackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            noOrdersStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Factory Method
    
    private static func createLabel(text: String, font: UIFont, textColor: UIColor, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment = .fill) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private static func createImageView(imageName: String, tintColor: UIColor? = nil, weight: UIImage.SymbolWeight = .regular) -> UIImageView {
        let imageView = UIImageView()
        let configuration = UIImage.SymbolConfiguration(weight: weight)
        imageView.image = UIImage(systemName: imageName, withConfiguration: configuration)
        imageView.tintColor = tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
}
