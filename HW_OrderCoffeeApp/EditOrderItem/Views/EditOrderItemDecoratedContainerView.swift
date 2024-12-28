//
//  EditOrderItemDecoratedContainerView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// 帶有圓角與邊框的自訂容器視圖
/// - 用途：
///   用於包裝其他子視圖（例如 StackView），同時提供統一的樣式設置，包括圓角、邊框顏色與寬度。
/// - 優點：
///   透過該容器，樣式邏輯與子視圖配置可以分離，提升模組化與可重用性。
class EditOrderItemDecoratedContainerView: UIView {
    
    // MARK: - Initializer
    
    /// 初始化帶有圓角與邊框的容器視圖
    /// - Parameters:
    ///   - cornerRadius: 圓角半徑，默認為 10
    ///   - borderWidth: 邊框寬度，默認為 2
    ///   - borderColor: 邊框顏色，默認為淺灰色
    init(cornerRadius: CGFloat = 10, borderWidth: CGFloat = 2, borderColor: UIColor = .lightGray) {
        super.init(frame: .zero)
        setupStyle(cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置視圖樣式
    /// - Parameters:
    ///   - cornerRadius: 圓角半徑
    ///   - borderWidth: 邊框寬度
    ///   - borderColor: 邊框顏色
    private func setupStyle(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Public Methods
    
    /// 添加內容視圖到容器中，並設置其約束
    /// - Parameter contentView: 要添加到容器的內容視圖
    func addContentView(_ contentView: UIView) {
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
}
