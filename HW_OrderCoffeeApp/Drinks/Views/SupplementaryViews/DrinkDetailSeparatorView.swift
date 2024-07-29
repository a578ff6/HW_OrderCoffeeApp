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
        self.backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size.width = self.superview!.frame.size.width * 0.93
        self.center.x = self.superview!.center.x
    }
    
}

