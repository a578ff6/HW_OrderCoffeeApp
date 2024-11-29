//
//  BottomLineTextField.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/19.
//

/*
 1. BottomLineTextField 在 layoutSubviews 中更新「底線」的 frame，確保「底線」在 UITextField 的 frame 確定之後設置正確。
    * 藉此不依賴於外部調用和佈局的時機。
    * 同時避免重複建立底線層的問題。
 */

// MARK: - BottomLineTextField 重點筆記
/**

 ## BottomLineTextField 重點筆記

 `* What - 什麼是 BottomLineTextField？`
 
 - `BottomLineTextField` 是一個繼承自 UITextField 的自訂化元件，除了基本的文字輸入功能，還具備以下特色：
 
 `1.底線樣式`：在文字輸入框下方顯示一條自訂底線。
 `2.右側圖標功能`：支持在輸入框右側添加一個按鈕，該按鈕可以是靜態圖標，也可以有交互行為，例如顯示/隱藏密碼的功能。
 
 ----------------------------------------------
 
 `* Why - 為什麼重構圖標按鈕的設計`
 
 - `統一設計和減少代碼冗餘：`
    - 最初的設計使用了 UIImageView 和 UIButton 分別來處理靜態和交互按鈕，這導致代碼結構冗長且難以維護。
    - 現在統一使用 UIButton，無論是靜態圖標還是需要交互的按鈕，這樣的設計使得代碼更加簡潔，容易擴展和維護。

 - `提升靈活性`：
    - 使用 UIButton 允許我們根據需要輕鬆添加按鈕的點擊行為，使得圖標不僅可以靜態顯示，還可以根據場景實現相應的交互功能，比如密碼的顯示/隱藏。
 
 ----------------------------------------------

 `* How - 如何使用 BottomLineTextField？`
 
 `1. 設置底線樣式：`
    -  使用 `setupBottomLine() `方法初始化底線的樣式，並在需要時通過` updateBottomLineFrame() `方法更新底線的位置和大小，以確保底線自動適應輸入框的尺寸變化。

 `2. 設置右側靜態圖標：`
    - 使用 `configureRightButton(iconName:isPasswordToggle:) `方法設置右側按鈕。該按鈕既可以是靜態顯示（如 Email 圖標），也可以是交互按鈕（如顯示/隱藏密碼）。
 
 `3. 靜態圖標`：
    - 只需提供圖標名稱，不需要點擊行為。
 
 ```swift
 bottomLineTextField.configureRightButton(iconName: "envelope")
 ```
 
 `4.交互按鈕（例如密碼顯示切換）：`
    - 設置 isPasswordToggle 為 true，添加按鈕的交互行為。
 
 ```swift
 bottomLineTextField.configureRightButton(iconName: "eye", isPasswordToggle: true)
 ```
 
 ----------------------------------------------

 `* 職責劃分明確`
 
 - `集中圖標按鈕的設置`：
    -  通過 `configureRightButton` 方法統一處理所有右側按鈕的設置，這樣的設計提高了代碼的可讀性和易維護性。
 
 - `減少代碼重複`：
    -  重構後的設計去除了對靜態圖標和交互按鈕的分別處理，改為統一管理，減少了代碼的重複和冗餘。

 ----------------------------------------------

 `* 程式碼結構和設計方式`
 
 - 設計方法：
    - `setupBottomLine()`：設置底線的樣式。
    - `updateBottomLineFrame()`：根據輸入框的尺寸動態更新底線的位置和大小。
    - `configureRightButton(iconName:isPasswordToggle:)`：設置右側按鈕，可以是靜態圖標或具有交互功能的按鈕。

 ----------------------------------------------

 `* 總結`
 
 - 重構後的 `BottomLineTextField` 通過統一使用 `UIButton` 來顯示右側圖標，不論是靜態還是交互功能，這樣的設計：
    - 減少了代碼重複：一個方法即可處理不同需求。
    - 提高了代碼的可讀性和可維護性：使用單一的方法來管理不同情境下的按鈕行為。
    - 增加了靈活性和擴展性：可以根據需求輕鬆調整按鈕的功能，使元件更加模組化。
 */


// MARK: - BottomLineTextField Initialization and Layout Notes
/**
 
 ## BottomLineTextField Initialization and Layout Notes

 `* 設置 textFieldBottomLine.frame 的原因`
 
 `1. setupBottomLine 中的初始設置：`
 
    - 在初始化時設置底線的框架，確保 `TextField` 在首次顯示時有正確的底線呈現。
    - 這是初次創建 `TextField` 時必須要做的操作。

 `2. updateBottomLineFrame 中的動態更新：`
 
    - `updateBottomLineFrame` 在 `layoutSubviews()` 中調用，用於處理視圖尺寸變化。
    - 當 `TextField` 大小改變（例如屏幕旋轉或者容器大小改變）時，重新計算並設置底線的框架，保持底線寬度與 `TextField` 一致。

 ----------------------------------------------
 
 `* 提高可讀性和減少重複`

 - 初始化只設置一次背景色和圖層添加的邏輯，把框架設置留給 `updateBottomLineFrame`。
 
   ```swift
   private func setupBottomLine() {
       textFieldBottomLine.backgroundColor = UIColor.deepBrown.cgColor
       layer.addSublayer(textFieldBottomLine)
       updateBottomLineFrame() // 設置初始框架
   }
   ```
 
 - 保持 `layoutSubviews` 中調用 `updateBottomLineFrame` 的邏輯，以便每次尺寸變化時更新底線位置和大小。

 ----------------------------------------------

 `* 總結`
 
 - 使用 `setupBottomLine` 來初始化底線的顏色和添加到圖層。
 - 使用 `layoutSubviews` 來確保當視圖大小發生變化時，自動調整底線的框架。
 - 這種既能確保底線正確初始化，又能在動態布局時保持同步，達到顯示和邏輯的分離，提升代碼的可維護性和可讀性。

 */


// MARK: - BBottomLineTextField 中 Button 作為右側圖標的用法差異（重要）
/**

 ## BottomLineTextField 中 Button 作為右側圖標的用法
 
 - 主要是我一開始是分別設置UIImageVIew跟UIButton的方式，造成程式碼過於攏長。
 -  所以才集中使用UIButton的方式。
 
 `* What - 什麼是右側圖標按鈕的用法？`
 
 - 在 BottomLineTextField 中，右側圖標按鈕（rightButton）被用於顯示靜態或交互功能的圖標。
 
 - 這些按鈕可以根據需求來進行不同的配置，例如：
 1.`靜態顯示`：顯示 Email 圖標，僅作為提示。
 2.`交互功能`：顯示密碼顯示/隱藏圖標，允許用戶與其進行交互。
 
 ----------------------------------------------

 `* Why - 為什麼需要統一使用 Button？`
 
 `1. 減少代碼冗餘：`
 
 - 在最初的設計中，靜態圖標和交互按鈕是分開實現的，使用 UIImageView 和 UIButton 分別處理，這導致代碼結構冗長，難以維護。
 - 後來統一使用 UIButton 來顯示右側的靜態和交互功能，這樣設計使得邏輯更加簡潔。
 
 `2.提高靈活性和可擴展性：`
 
 - 使用同一個 UIButton 可以更容易地增加或更改右側圖標的行為，比如為右側按鈕添加不同的點擊事件。
 - 統一管理按鈕使代碼模組化，減少重複邏輯，也更容易實現新的右側圖標功能。
 
 ----------------------------------------------

 `* How - 如何設置靜態圖標和交互按鈕？`
 

 `- 設置右側按鈕的圖標和行為：`

 - 使用 `configureRightButton(iconName:isPasswordToggle:) `方法來設置按鈕。
 - 如果只需要靜態圖標，可以傳入圖標名稱且將 `isPasswordToggle` 設為 `false`。
 - 如果需要交互功能（如密碼顯示切換），將 `isPasswordToggle` 設為 `true`，這樣可以設置相應的點擊行為。
 
 ```
 func configureRightButton(iconName: String, isPasswordToggle: Bool = false) {
     // 設置按鈕圖標
     setRightIcon(iconName: iconName, pointSize: 14)
     
     // 如果是密碼切換按鈕，設置按鈕的交互行為
     if isPasswordToggle {
         isSecureTextEntry = true  // 初始狀態設為隱藏密碼
         rightButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
     }
     
     // 設定按鈕作為 TextField 右側圖標
     rightView = rightButton
     rightViewMode = .always
 }
```

 ----------------------------------------------

 `* 實際應用場景`
 
 - 靜態圖標：
    - 當輸入框需要顯示內容類型的提示時，例如電子郵件地址的輸入框，可以使用 `configureRightButton(iconName:) `來顯示「信封」圖標，幫助用戶理解輸入內容。
 
 - 交互按鈕：
    - 例如密碼輸入框，使用「眼睛」圖標，允許用戶點擊切換密碼的可見性，可以使用 configureRightButton(iconName:isPasswordToggle:) 設置該功能。
 
   ```swift
 // 設置密碼顯示切換按鈕
 passwordTextField.configureRightButton(iconName: "eye", isPasswordToggle: true)
   ```
 
 ----------------------------------------------

 `* 總結`
 
 - 重構後的 BottomLineTextField 中，統一使用 UIButton 來作為右側圖標按鈕，無論是靜態圖標還是交互按鈕，這樣的設計：
 - 簡化了代碼結構：統一的方式減少了重複邏輯。
 - 提高了代碼的可讀性和維護性：統一的接口讓使用更加直觀，對於開發者來說更易於理解和擴展。
 - 增加了靈活性：可根據需求靈活設置圖標和行為，無論是靜態展示還是交互操作，都能使用同一套代碼處理。
 */


import UIKit

/// 自訂一個帶底線樣式的文字輸入框 (TextField)
/// - 支持在輸入框下方顯示一條自訂底線
/// - 可以配置右側圖標來顯示靜態圖標或交互按鈕（例如切換密碼顯示的眼睛圖標）
class BottomLineTextField: UITextField {
    
    // MARK: - Properties
    
    /// 底線圖層 (Layer)，用於在文字輸入框下方顯示一條自訂的底線
    private let textFieldBottomLine = CALayer()
    
    /// 右側按鈕，用於顯示靜態或交互圖標
    private let rightButton = createRightIconButton()
    
    // MARK: - Initializers
    
    /// 初始化 BottomLineTextField
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBottomLine()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    /// 當元件尺寸變動時，重新計算並更新底線的位置與寬度
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBottomLineFrame()
    }
    
    // MARK: - Setup Methods
    
    /// 設置底線的外觀和屬性
    /// - 為文字輸入框添加一條底線，並設置初始外觀
    private func setupBottomLine() {
        textFieldBottomLine.backgroundColor = UIColor.deepBrown.cgColor
        layer.addSublayer(textFieldBottomLine)
        updateBottomLineFrame() // 設置初始框架
    }
    
    /// 更新底線的框架，使其符合當前 TextField 的尺寸變化
    /// - 確保底線在輸入框大小調整時可以自動適應
    private func updateBottomLineFrame() {
        textFieldBottomLine.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 2)
    }
    
    // MARK: - Factory Method
    
    /// 創建右側圖標按鈕
    /// - Returns: 配置好屬性的 UIButton，用於作為右側圖標
    private static func createRightIconButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Private Methods
    
    /// 設置右側圖標
    /// - Parameters:
    ///   - iconName: 圖標的名稱
    ///   - pointSize: 圖標的尺寸
    /// - 用於設置靜態或交互按鈕的圖標
    private func setRightIcon(iconName: String, pointSize: CGFloat) {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
        let iconImage = UIImage(systemName: iconName, withConfiguration: configuration)
        rightButton.setImage(iconImage, for: .normal)
    }
    
    /// 切換密碼顯示狀態，並更新密碼圖標
    /// - 當用戶點擊右側圖標時，切換密碼的可見狀態，並更新圖標顯示
    @objc private func togglePasswordVisibility() {
        isSecureTextEntry.toggle()
        let eyeImageName = isSecureTextEntry ? "eye" : "eye.slash"
        setRightIcon(iconName: eyeImageName, pointSize: 14)
    }
    
    // MARK: - Public Methods
    
    /// 配置右側按鈕的圖標和行為
    /// - Parameters:
    ///   - iconName: 圖標的名稱
    ///   - isPasswordToggle: 是否用於密碼顯示切換
    /// - 用於設置右側的靜態或交互按鈕，例如郵件圖標或密碼切換圖標
    func configureRightButton(iconName: String, isPasswordToggle: Bool = false) {
        // 設置按鈕圖標
        setRightIcon(iconName: iconName, pointSize: 14)
        
        // 如果是密碼切換按鈕，設置按鈕的交互行為
        if isPasswordToggle {
            // 初始狀態設為隱藏密碼
            isSecureTextEntry = true
            rightButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        }
        
        // 設定按鈕作為 TextField 右側圖標
        rightView = rightButton
        rightViewMode = .always
    }
}
