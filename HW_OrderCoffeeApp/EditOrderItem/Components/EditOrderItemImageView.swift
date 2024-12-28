//
//  EditOrderItemImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// 自訂義的 UIImageView，用於展示飲品圖片
class EditOrderItemImageView: UIImageView {

    // MARK: - Initializer

    init(contentMode: UIView.ContentMode) {
        super.init(frame: .zero)
        setupStyle(contentMode: contentMode)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 設置基本樣式
    /// - Parameter contentMode: 圖片的顯示模式
    private func setupStyle(contentMode: UIView.ContentMode) {
        self.contentMode = contentMode
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
