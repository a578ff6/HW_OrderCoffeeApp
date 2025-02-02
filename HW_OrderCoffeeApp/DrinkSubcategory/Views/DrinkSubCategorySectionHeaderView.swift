//
//  DrinkSubCategorySectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/20.
//



// MARK: - (v)

import UIKit

/// 用於 DrinkSubCategoryViewController 展示，為每個 section 配置並返回一個 header view。每個 header view 顯示對應子類別的標題。
class DrinkSubCategorySectionHeaderView: UICollectionReusableView {
    
    static let headerIdentifier = "DrinkSubCategorySectionHeaderView"
    
    // MARK: - UI Elements

    private let titleLabel = DrinkSubcategoyLabel(font: .systemFont(ofSize: 25, weight: .bold), textColor: .black)
    
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    private func setupViews() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    
    /// 設置 section header 的標題文字。
    ///
    /// - Parameter title: 要顯示的標題文字。
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
