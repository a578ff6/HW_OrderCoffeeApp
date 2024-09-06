//
//  DrinksCategorySectionFooterView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/5.
//

import UIKit

/// 用來作為 section 的底部線條
class DrinksCategorySectionFooterView: UICollectionReusableView {
    
    static let footerIdentifier = "DrinksCategorySectionFooterView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFooterView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 設置底部線條的外觀
    private func setupFooterView() {
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .lightGray
        addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1) // 設置線條高度
        ])
    }
}
