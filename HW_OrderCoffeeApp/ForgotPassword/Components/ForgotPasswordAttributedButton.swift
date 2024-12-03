//
//  ForgotPasswordAttributedButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/2.
//

import UIKit

/// 自訂的帶有多樣樣式文字的按鈕，用於在忘記密碼頁面中設置擁有主要文本和高亮文本的按鈕
/// - 支持設置兩段不同顏色與樣式的文字，通常用於忘記密碼頁面中的提示或其他動作連結
class ForgotPasswordAttributedButton: UIButton {

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
