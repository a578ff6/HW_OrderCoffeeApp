//
//  SeparatorView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/22.
//

import UIKit

/// 分隔線（用於DrinkDetailViewController）
class DrinkDetailSeparatorView: UICollectionReusableView {
        
    static let reuseIdentifier = "DrinkDetailSeparatorView"
    
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
            lineView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.93),
            lineView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])        
    }
    
}
