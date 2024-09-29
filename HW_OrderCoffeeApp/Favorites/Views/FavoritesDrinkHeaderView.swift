//
//  FavoritesDrinkHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/28.
//

import UIKit

/// 用來顯示 subcategory 的標題。
class FavoritesDrinkHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "FavoritesDrinkHeaderView"
    
    // MARK: - UI Element
    
    let titleLabel = FavoritesDrinkHeaderView.createLabel(fontSize: 25, weight: .bold, textColor: .black)
    
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
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Factory Methods
    
    private static func createLabel(fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: - Configuration
    
    /// 設置 subcategory
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
