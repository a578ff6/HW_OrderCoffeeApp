//
//  LoginLabel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/28.
//

// MARK: - LoginLabel 筆記：
/**
 
 ## LoginLabel 筆記：
 
 `* What`
 
 - LoginLabel 是一個自訂的 UILabel 類別，用於在登入頁面中顯示標準樣式的文字。這個類別可以輕鬆配置標籤的文字、字體大小、字重、顏色和對齊方式。

 `* Why`
 
 - 在登入頁面中，為了保持 UI 樣式的一致性，這個 LoginLabel 類別可以統一管理標籤的外觀屬性。
 - 這樣可以減少重複代碼，並確保整個登入頁面中的標籤風格一致。

 `* How`
 
 `1. 繼承 UILabel：`

 - LoginLabel 繼承自 UILabel，透過簡單的屬性設置，將初始化和樣式應用於所有使用該類別的標籤。
 
 `2. 初始化方法：`

 - 使用 init(text:fontSize:weight:textColor:textAlignment:) 方法來初始化標籤，提供常用的設置參數，例如標籤的文字、字體大小和字重等。
 
 `3. 重構初始化邏輯：`

 - 把初始化邏輯抽取到私有方法 setupLabel 中，使得主初始化方法保持簡潔。這樣的做法可以提高代碼的可讀性，並在未來需要調整樣式時更易於修改。
 
 `4. 使用範例：`

 - 可以在登入頁面中直接使用這個標籤：
 
 ```swift
 let titleLabel = LoginLabel(text: "Log in to your account", fontSize: 28, weight: .bold, textColor: .black, textAlignment: .center)
 ```
 
 - 這樣可以確保頁面上所有標籤的風格一致，並且方便修改屬性時影響到所有標籤。
 */

import UIKit

/// 自訂的 UILabel，用於 LoginView 頁面中的標準文字樣式
class LoginLabel: UILabel {
    
    // MARK: - Initializers
    
    /// 使用特定屬性初始化 LoginLabel
    /// - Parameters:
    ///   - text: 標籤顯示的文字
    ///   - fontSize: 文字大小
    ///   - weight: 文字的字重
    ///   - textColor: 文字顏色，默認為黑色
    ///   - textAlignment: 文字對齊方式，默認為自然對齊
    init(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor = .black, textAlignment: NSTextAlignment = .natural) {
        super.init(frame: .zero)
        setupLabel(text: text, fontSize: fontSize, weight: weight, textColor: textColor, textAlignment: textAlignment)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置標籤的基本屬性
    /// - Parameters:
    ///   - text: 標籤顯示的文字
    ///   - fontSize: 文字大小
    ///   - weight: 文字的字重
    ///   - textColor: 文字顏色
    ///   - textAlignment: 文字對齊方式
    private func setupLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, textAlignment: NSTextAlignment) {
        self.text = text
        self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
