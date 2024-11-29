//
//  LoginAttributedButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/28.
//

// MARK: - LoginAttributedButton 筆記
/**
 
 ## LoginAttributedButton 筆記
 
 `* What`
 
 - LoginAttributedButton 是一個自訂的 UIButton，提供兩段樣式不同的文字標題。
 - 它允許設置主要文本和高亮文本，並以不同的樣式呈現，用於提供視覺上的對比和吸引用戶的關注，例如登入頁面中的提示訊息或動作按鈕。

 `* Why`
 
 - 在登入頁面中，經常需要按鈕來提示用戶執行特定動作，例如「沒有帳號？註冊」這類提示，其中「註冊」部分需要特別突出，以引導用戶操作。
 - 通過 LoginAttributedButton，可以有效地統一這些按鈕的風格，避免每次都手動設置 NSAttributedString。這樣的設計讓代碼更具可讀性且易於維護，並且為設計一致性的 UI 提供了保障。

 `* How`
 
` 1. 繼承 UIButton：`

 - LoginAttributedButton 繼承自 UIButton，並提供一個自訂的初始化方法，用於設置帶有多樣樣式的文字標題。
 
 `2. 初始化方法：`

 - `init(mainText:highlightedText:fontSize:mainTextColor:highlightedTextColor:)：`
    - 使用這個方法時，可以設置按鈕標題的主要部分（如提示文字）和高亮部分（如關鍵動作）。
    - 例如，當需要提示用戶「沒有帳號？註冊」時，「註冊」部分會使用不同的顏色來引導用戶。
 
 `3. 樣式設置方法 (setupButton())：`

 - `setupButton(mainText:highlightedText:fontSize:mainTextColor:highlightedTextColor:)：`
    - 使用 NSMutableAttributedString 來創建帶有不同樣式的標題文本。
    - 主要文本和高亮文本可以使用不同的顏色和字體樣式，從而讓按鈕的外觀更加吸引用戶注意力。
    - 設置 translatesAutoresizingMaskIntoConstraints 為 false，以便使用 Auto Layout 進行佈局。
 
 `4. 使用範例：`

 - 在登入頁面中使用這個按鈕：

```swift
 let signUpButton = LoginAttributedButton(
     mainText: "Don't have an account? ",
     highlightedText: "Sign up",
     fontSize: 14,
     mainTextColor: .gray,
     highlightedTextColor: .deepGreen
 )
 ``` 
 */


import UIKit

/// 自訂的帶有多樣樣式文字的按鈕，用於在登入頁面中設置擁有主要文本和高亮文本的按鈕
/// - 支持設置兩段不同顏色與樣式的文字，通常用於登入頁面中的提示或其他動作連結
class LoginAttributedButton: UIButton {
    
    // MARK: - Initializers
    
    /// 使用帶有多樣樣式的標題文字初始化按鈕
    /// - Parameters:
    ///   - mainText: 主要的文本，用於按鈕標題的常規部分
    ///   - highlightedText: 高亮顯示的文本，用於按鈕標題中特別突出的部分
    ///   - fontSize: 文字的字體大小
    ///   - mainTextColor: 主要文本的顏色
    ///   - highlightedTextColor: 高亮文本的顏色
    init(mainText: String, highlightedText: String, fontSize: CGFloat, mainTextColor: UIColor, highlightedTextColor: UIColor) {
        super.init(frame: .zero)
        setupButton(mainText: mainText, highlightedText: highlightedText, fontSize: fontSize, mainTextColor: mainTextColor, highlightedTextColor: highlightedTextColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置按鈕的標題文本
    /// - 將主要文字與高亮文字組合，並設置為按鈕的標題
    /// - Parameters:
    ///   - mainText: 主要的文本
    ///   - highlightedText: 高亮顯示的文本
    ///   - fontSize: 文字的字體大小
    ///   - mainTextColor: 主要文本的顏色
    ///   - highlightedTextColor: 高亮文本的顏色
    private func setupButton(mainText: String, highlightedText: String, fontSize: CGFloat, mainTextColor: UIColor, highlightedTextColor: UIColor) {
        
        // 創建主要文字部分的屬性
        let attributedTitle = NSMutableAttributedString(string: mainText, attributes: [.foregroundColor: mainTextColor, .font: UIFont.boldSystemFont(ofSize: fontSize)])
        
        // 添加高亮顯示的文字
        attributedTitle.append(NSAttributedString(string: highlightedText, attributes: [.foregroundColor: highlightedTextColor, .font: UIFont.boldSystemFont(ofSize: fontSize)]))
        
        // 設定按鈕的標題
        self.setAttributedTitle(attributedTitle, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}

