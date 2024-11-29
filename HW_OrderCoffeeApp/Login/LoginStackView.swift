//
//  LoginStackView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/29.
//

// MARK: - LoginStackView 筆記
/**
 
 ## LoginStackView 筆記
 
 `* What`
 
 - LoginStackView 是一個自訂的 UIStackView 類別，用於在 Login 相關視圖中提供統一的佈局設置。它繼承自 UIStackView，並在初始化時封裝了一些通用的屬性設置。

 `* Why`
 
 - 統一風格：通過使用 LoginStackView，可以保持應用中所有 Login 相關視圖的 StackView 具有一致的外觀和佈局設定，避免手動重複設置。
 - 減少重複代碼：避免在每個使用 StackView 的地方重複進行配置（如 axis、spacing 等），降低代碼的重複度，提高可維護性。
 - 降低 LoginView 的肥大：將常見的 StackView 配置抽取到這個自訂類別中，使得 LoginView 和其他使用該類的視圖更加簡潔，符合單一職責原則。
 
 `* How`
 
 - 只需通過簡單的初始化來創建 LoginStackView，傳入佈局所需的屬性參數即可：
 
 ```swift
 let mainStackView = LoginStackView(axis: .vertical, spacing: 13, alignment: .fill, distribution: .fill)
 ```
 - LoginStackView 自動配置常用的屬性，如 translatesAutoresizingMaskIntoConstraints = false，使得視圖佈局更加簡單和直觀。
 */

import UIKit

/// 自訂的 `LoginStackView` 類別，用於建立 Login 畫面中使用的 StackView，統一配置
class LoginStackView: UIStackView {
    
    /// 初始化 LoginStackView，設置 StackView 的屬性
    /// - Parameters:
    ///   - axis: 堆疊的方向（水平或垂直）
    ///   - spacing: 元件間的間距
    ///   - alignment: 元件在 StackView 中的對齊方式
    ///   - distribution: 元件的分佈方式
    init(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) {
        super.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
