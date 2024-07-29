//
//  ThickSeparatorView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/29.
//

import UIKit

/// 用於 DrinksCategoryCollectionViewController 的較粗分隔線
class ThickSeparatorView: UICollectionReusableView {
    
    static let reuseIdentifier = "ThickSeparatorView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 0.5)
        self.layer.cornerRadius = 1.5   // 設置角半徑為高度的一半
        self.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size.width = self.superview!.frame.size.width * 0.80
        self.frame.size.height = 3
        self.center.x = self.superview!.center.x
    }
    
}
