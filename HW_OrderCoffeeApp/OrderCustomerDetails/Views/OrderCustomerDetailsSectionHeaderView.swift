//
//  OrderCustomerDetailsSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/11.
//

// MARK: - SectionHeader、分格線
import UIKit

/// OrderCustomerDetailsViewController 佈局使用，設置 Section Header
class OrderCustomerDetailsSectionHeaderView: UICollectionReusableView {
        
    static let headerIdentifier = "OrderCustomerDetailsSectionHeaderView"
    
    // MARK: - UI Elements
    
    private let titleLabel = OrderCustomerDetailsSectionHeaderView.createLabel(font: .systemFont(ofSize: 22, weight: .bold), textColor: .black)
    private let separatorView = OrderCustomerDetailsSectionHeaderView.createSeparatorView()
    
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
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            
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
