//
//  LoginCheckBoxButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/28.
//

// MARK: - LoginCheckBoxButton 筆記
/**
 
 ## LoginCheckBoxButton 筆記
 
 `* What`
 
 - LoginCheckBoxButton 是一個自訂的 UIButton，具有「選擇」和「取消選擇」的可視化狀態切換功能，常用於「記住我」這類選擇項的設置。
 - 它包含一個方形圖標，未選擇時顯示空方塊，選擇後顯示對勾，並帶有相應的描述文字。

 `* Why`
 
 - 在登入頁面中，像「記住我」這樣的選擇功能需要讓用戶能夠清晰地看到其當前的狀態（選中或未選中）。
 - 使用 LoginCheckBoxButton 可以讓這種狀態切換更加直觀，不僅圖標明顯，且搭配文本說明，用戶在交互過程中不容易出現混淆。
 - 此外，通過設置自訂的按鈕，更好地統一 UI 的風格，並使後續的樣式調整更加方便。

 `* How`
 
 `1. 繼承 UIButton：`

 - `LoginCheckBoxButton` 繼承自 UIButton，主要提供了一個帶有方形圖標（選中/未選中）和描述文本的按鈕。
 
 `2. 初始化方法：`

 - `init(title:)：`
    - 使用這個方法時可以設置按鈕的標題（例如「記住我」），並且完成按鈕的基本配置。
 
` 3. 設置按鈕外觀的私有方法 (setupButton(title:))：`

 - 這個方法被抽取出來以便更好地組織代碼，設置所有按鈕的屬性，包括圖標、標題、字體、顏色及對齊方式。
 - 通過設置 setImage() 方法，分別設置未選中（normal）和選中（selected）狀態下的圖標，提供清晰的狀態指示。
 - 設置標題文字、顏色及字體，讓按鈕的樣式在不同狀態下保持一致。
 
 `4. 使用範例：`

 - 在登入頁面中使用這個按鈕：
    ```swift
    let rememberMeButton = LoginCheckBoxButton(title: " Remember Me")
    ```
 */


import UIKit

/// 自訂的 CheckBox 按鈕，使用方形圖標來表示選擇或取消選擇狀態
/// - 用於登入頁面中的「記住我」等選擇功能，提供直觀的可選中圖標和文字
class LoginCheckBoxButton: UIButton {
    
    // MARK: - Initializers
    
    /// 初始化 LoginCheckBoxButton，設置按鈕標題及外觀
    /// - Parameter title: 按鈕的標題文字，用於描述 CheckBox 的選擇項
    init(title: String) {
        super.init(frame: .zero)
        setupButton(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置按鈕的外觀及屬性
    /// - Parameter title: 按鈕的標題文字
    private func setupButton(title: String) {
        // 設定按鈕在不同狀態下的圖標
        setImage(UIImage(systemName: "square"), for: .normal)
        setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        
        // 設定按鈕的標題文字及其樣式
        setTitle(title, for: .normal)
        setTitleColor(.gray, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        // 設置按鈕的圖標和標題位置
        tintColor = .gray
        contentHorizontalAlignment = .leading
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}

