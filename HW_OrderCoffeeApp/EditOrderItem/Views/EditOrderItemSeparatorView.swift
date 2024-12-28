//
//  EditOrderItemSeparatorView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// 分隔線視圖 (適用於 `EditOrderItemViewController` 的 `UICollectionView` 中)
///
///     
class EditOrderItemSeparatorView: UICollectionReusableView {
    
    // MARK: - Reuse Identifier
    
    /// 分隔線視圖的重用識別碼，用於註冊與重用
    static let reuseIdentifier = "EditOrderItemSeparatorView"
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFooterView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置分隔線的外觀與佈局
    ///
    /// - 添加一條寬度為視圖寬度 93% 的灰色線條，並置中於視圖底部。
    /// - 線條高度固定為 1 點，確保簡潔不占版面。
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
