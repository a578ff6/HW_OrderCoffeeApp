//
//  UserProfileSFSymbolImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/9.
//

import UIKit

/// 一個自定義的 `UIImageView`，用於顯示 SF Symbol 或 Assets 圖像，具有固定大小與色彩
///
/// 此類提供簡化的初始化方式，適用於需要顯示圖示並設定固定尺寸及色彩的情境。
/// - 預設內容模式為 `.scaleAspectFit`，確保圖像以適當比例顯示。
/// - 自動設置寬度與高度的約束，避免額外配置。
class UserProfileIconImageView: UIImageView {
    
    /// 初始化方法
    /// - Parameters:
    ///   - size: 圖標的尺寸（寬與高相等），預設為 `28`
    ///   - tintColor: 圖標的顏色，預設為 `.black`
    init(size: CGFloat = 28, tintColor: UIColor = .black) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFit
        self.tintColor = tintColor
        self.widthAnchor.constraint(equalToConstant: size).isActive = true
        self.heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
