//
//  SignUpScrollView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/30.
//

import UIKit

/// 自訂的 ScrollView 類別，用於 Login 相關視圖中，提供標準化設置與佈局
class SignUpScrollView: UIScrollView {

    // MARK: - Initializers
    
    /// 初始化 SignUpScrollView，並配置標準設置與佈局
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    /// 設置 ScrollView 的約束條件
    /// - Parameter parentView: 父視圖，ScrollView 將設置其在此視圖中的約束
    func setupConstraints(in parentView: UIView) {
        parentView.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
            self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
}
