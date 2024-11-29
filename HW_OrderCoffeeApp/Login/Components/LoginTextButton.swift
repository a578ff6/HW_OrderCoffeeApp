//
//  LoginTextButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/28.
//

// MARK: - LoginTextButton 筆記
/**
 
 ## LoginTextButton 筆記
 
 `* What`
 
 - LoginTextButton 是一個自訂的 UIButton，主要用於顯示僅含文本的按鈕，例如登入頁面中的「忘記密碼？」或「註冊帳號」這類輔助功能的按鈕。
 - 它提供了自訂標題、字體大小、字體粗細、顏色等參數來配置按鈕的外觀。

 `* Why`
 
 - 登入頁面中的按鈕有多種用途，有些僅需顯示文本並提供點擊行為（如「忘記密碼？」）。
 - 使用 LoginTextButton 可以統一這些按鈕的樣式和屬性配置，讓代碼更易於維護，也能減少樣式變更時需要修改的地方。
 - 此外，這種設計符合單一職責原則，每個類別負責單一的視覺效果和行為，增加了代碼的清晰度和可擴展性。

 `* How`
 
 `1. 繼承 UIButton：`

 - LoginTextButton 繼承自 UIButton，並提供了簡化初始化和配置按鈕外觀的方法。
 
 `2. 初始化方法：`

 `- init(title:fontSize:fontWeight:textColor:)：`
    - 使用這個初始化方法可以快速設置按鈕的標題文字及其相關樣式。可以提供默認參數來減少代碼重複。
 
` 3. 抽出設置按鈕外觀的私有方法 (setupButton(title:fontSize:fontWeight:textColor:))：`

 - 將按鈕的配置代碼抽取到 setupButton 方法中，使初始化方法更加簡潔，同時提高代碼的可讀性。
 - 在這個方法中，配置按鈕的標題、字體、顏色等屬性，統一樣式以便後續維護。
 
 `4. 使用範例：`

 - 在登入頁面中使用這個按鈕：
 ```swift
 let forgotPasswordButton = LoginTextButton(title: "Forgot your password?", fontSize: 14, fontWeight: .medium, textColor: .gray)
 ```
 這樣可以確保所有顯示文本的按鈕擁有一致的外觀，方便後續修改樣式或新增不同用途的文本按鈕。
 
 */

import UIKit

/// 自訂的僅顯示文本的按鈕，用於登入頁面的輔助功能按鈕（例如「忘記密碼？」等）
class LoginTextButton: UIButton {
    
    // MARK: - Initializers
    
    /// 初始化 LoginTextButton，設置按鈕標題及文字樣式
    /// - Parameters:
    ///   - title: 按鈕的標題文字
    ///   - fontSize: 標題文字的字體大小，默認為 16
    ///   - fontWeight: 標題文字的字體粗細，默認為 `.regular`
    ///   - textColor: 標題文字的顏色，默認為黑色
    init(title: String, fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular, textColor: UIColor = .black) {
        super.init(frame: .zero)
        setupButton(title: title, fontSize: fontSize, fontWeight: fontWeight, textColor: textColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置按鈕的標題、字體、顏色及佈局屬性
    /// - Parameters:
    ///   - title: 按鈕的標題文字
    ///   - fontSize: 標題文字的字體大小
    ///   - fontWeight: 標題文字的字體粗細
    ///   - textColor: 標題文字的顏色
    private func setupButton(title: String, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) {
        // 設置標題文字
        setTitle(title, for: .normal)
        
        // 設置標題文字的字體及粗細
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        
        // 設置標題文字顏色
        setTitleColor(textColor, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
