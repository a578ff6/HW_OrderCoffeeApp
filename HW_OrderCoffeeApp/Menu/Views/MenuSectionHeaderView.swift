//
//  MenuSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/3.
//

// MARK: - 已完善

import UIKit

/// 用於 MenuViewController 展示，為每個 section 配置並返回一個 header view。每個 header view 顯示對應的標題。
class MenuSectionHeaderView: UICollectionReusableView {
    
    static let headerIdentifier = "MenuSectionHeaderView"
    
    // MARK: - UI Elements

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    
    /// 設置 sectionHeader 的標題文字
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
