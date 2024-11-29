//
//  LoginSeparatorView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/28.
//

// MARK: - LoginSeparatorView 筆記
/**
 
 `* What`
 
 - LoginSeparatorView 是一個自訂的 UIView，用於在登入頁面中以視覺方式分隔不同部分。它包含兩條水平分隔線和中間的一個標籤，通常用來標示分隔符，如「或繼續使用」等提示。

` * Why`
 
 - 在使用者界面中，清晰的視覺分隔符可以提高使用者的理解和操作效率。
 - 例如在登入頁面中，為了區分一般帳戶登入與其他社交平台登入選項，可以使用這樣的視覺分隔符來區分。
 - LoginSeparatorView 提供了一個統一的設置方法，確保所有分隔視圖在風格上保持一致，並減少重複代碼。

 `* How`
 
 `1. 繼承 UIView：`

 - LoginSeparatorView 繼承自 UIView，它包含了兩條分隔線和中間的一個標籤，便於在不同的 UI 場景中進行重用。
 
` 2. 初始化方法：`

 - 使用 init(text:textColor:lineColor:) 方法來初始化分隔線視圖，並設置分隔線的標籤文字、文字顏色和分隔線顏色。
 
 `3. 重構初始化邏輯：`

 - 把初始化邏輯抽取到私有方法 setupSeparatorView 中，使得主初始化方法保持簡潔。這樣做的目的是提高代碼的可讀性和可維護性。
 
 `4. Factory 方法：`

 - 使用私有工廠方法來創建 UIStackView、UIView（分隔線）、和 UILabel，避免重複代碼並提高代碼的模組化程度。
 
 `5. 使用範例：`

 - 可以在登入頁面中直接使用這個分隔視圖，提供一個統一風格的視覺分隔符：
 
 ```swift
 let separatorView = LoginSeparatorView(text: "Or continue with")
 ````
 這樣可以確保頁面上的所有分隔符樣式一致，後續如需修改樣式時，只需在 LoginSeparatorView 中進行一次修改即可應用到所有分隔符。
 */

import UIKit

/// 自訂的分隔線視圖，包含兩條橫線和中間的一個標籤，用於登入頁面中以視覺方式分隔不同部分
class LoginSeparatorView: UIView {
    
    // MARK: - Initializers
    
    /// 初始化 LoginSeparatorView
    /// - Parameters:
    ///   - text: 分隔線中間顯示的文字
    ///   - textColor: 標籤文字的顏色，默認為淺灰色
    ///   - lineColor: 分隔線的顏色，默認為淺灰色
    init(text: String, textColor: UIColor = .lightGray, lineColor: UIColor = .lightGray) {
        super.init(frame: .zero)
        setupSeparatorView(text: text, textColor: textColor, lineColor: lineColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
        
    /// 設置分隔線視圖的基本屬性
    /// - Parameters:
    ///   - text: 分隔線中間顯示的文字
    ///   - textColor: 標籤文字的顏色
    ///   - lineColor: 分隔線的顏色
    private func setupSeparatorView(text: String, textColor: UIColor, lineColor: UIColor) {
        translatesAutoresizingMaskIntoConstraints = false
        
        // 創建分隔符專用的 StackView
        let separatorStackView = createStackView(axis: .horizontal, spacing: 3, alignment: .center, distribution: .fill)
        
        // 創建兩條分隔線和中間的標籤
        let line1 = createLineView(color: lineColor)
        let line2 = createLineView(color: lineColor)
        let textLabel = createLabel(text: text, fontSize: 14, weight: .regular, textColor: textColor, textAlignment: .center)
        
        // 添加子視圖到 StackView 中
        separatorStackView.addArrangedSubview(line1)
        separatorStackView.addArrangedSubview(textLabel)
        separatorStackView.addArrangedSubview(line2)
        
        // 添加 StackView 到主視圖
        addSubview(separatorStackView)
        
        // 設置 StackView 的約束
        NSLayoutConstraint.activate([
            separatorStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Private Factory Methods

    /// 創建一個 StackView
    /// - Parameters:
    ///   - axis: 排列方向（水平或垂直）
    ///   - spacing: 元素之間的間距
    ///   - alignment: 元素的對齊方式
    ///   - distribution: 元素的分佈方式
    /// - Returns: 配置好的 UIStackView
    private func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// 創建一條分隔線
    /// - Parameter color: 分隔線的顏色
    /// - Returns: 配置好的 UIView，表示一條分隔線
    private func createLineView(color: UIColor) -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: 95).isActive = true
        return lineView
    }
    
    /// 創建一個標籤
    /// - Parameters:
    ///   - text: 標籤顯示的文字
    ///   - fontSize: 文字大小
    ///   - weight: 文字的字重
    ///   - textColor: 文字顏色
    ///   - textAlignment: 文字對齊方式
    /// - Returns: 配置好的 UILabel
    private func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
}
