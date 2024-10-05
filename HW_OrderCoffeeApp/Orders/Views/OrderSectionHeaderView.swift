//
//  OrderSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/14.
//

/*
 ## OrderSectionHeaderView 筆記：
 
    * 功能：
        - 顯示訂單頁面中各區塊的標題。
        - 每個區塊標題(titleLabel)下方有一條分隔線(separatorView)，用於區分各區塊。
 
    * 視圖設置：
        - 包含一個 titleLabel 用於顯示區塊標題文字。
        - separatorView 用於在標題下方顯示分隔線，增強視覺分區效果。
 */

// MARK: - SectionHeader、分格線
import UIKit

/// OrderViewController 佈局使用，設置 Section Header
class OrderSectionHeaderView: UICollectionReusableView {
    
    static let headerIdentifier = "OrderSectionHeaderView"
    
    // MARK: - UI Elements
    
    private let titleLabel = OrderSectionHeaderView.createLabel(font: .systemFont(ofSize: 22, weight: .bold), textColor: .black)
    private let separatorView = OrderSectionHeaderView.createSeparatorView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func configureLayout() {
        addSubview(titleLabel)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 2)
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
    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        return view
    }
    
    // MARK: - Configure Method
    
    /// 設置標題
    /// - Parameter title: 要顯示的標題文字
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Lifecycle Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
}
