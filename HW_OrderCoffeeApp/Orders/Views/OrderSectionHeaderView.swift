//
//  OrderSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/14.
//

// MARK: - 只有SectionHeader
/*
import UIKit

class OrderSectionHeaderView: UICollectionReusableView {
    
    static let headerIdentifier = "OrderSectionHeaderView"
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
*/



// MARK: - SectionHeader、分格線
import UIKit

/// OrderViewController 佈局使用
class OrderSectionHeaderView: UICollectionReusableView {
    
    static let headerIdentifier = "OrderSectionHeaderView"
    
    let titleLabel = UILabel()
    let separatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1)
        addSubview(titleLabel)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
