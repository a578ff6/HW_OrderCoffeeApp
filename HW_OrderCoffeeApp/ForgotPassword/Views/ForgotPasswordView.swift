//
//  ForgotPasswordView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/17.
//


// MARK: - 筆記：ForgotPasswordView 使用說明
/**
 
 ## 筆記：ForgotPasswordView 使用說明

 `* What`
 
 - `ForgotPasswordView` 是負責處理忘記密碼頁面的自訂視圖類別，包含了頁面中的所有 UI 元件，包括標題、描述、電子郵件輸入框、重置密碼按鈕，以及登入頁面按鈕。
 - 它專注於頁面的佈局和 UI 元件的初始化、設定，讓視圖控制器 (ViewController) 專注於處理邏輯操作，達成分工明確。

 -----------------------------
 
 `* Why`
 
 - `分離責任`：
    - `ForgotPasswordView` 負責處理 UI 元件的配置和佈局，使得視圖控制器專注於業務邏輯，符合單一職責原則，提高程式碼的可讀性和可維護性。
 
 - `降低複雜度`：
    - 將 UI 結構的細節封裝到自訂的 `ForgotPasswordView` 中，降低視圖控制器的複雜度。
 
 - `重複使用`：
    - 由於 UI 的定義集中在 `ForgotPasswordView`，它能被重複使用或在不同的控制器中整合，具有更高的重用性。

 -----------------------------

 `* How`
 
 `1. 初始化`
 
 - 在 `ForgotPasswordViewController` 中，將 `ForgotPasswordView` 設定為主視圖。可以透過 `loadView()` 方法，直接將 `forgotPasswordView` 作為視圖控制器的主要視圖。

    ```swift
    override func loadView() {
        view = forgotPasswordView
    }
    ```

 `2. UI 元件的組成`
 
 - `titleLabel`：顯示標題，讓使用者了解當前頁面的功能。
 - `descriptionLabel`：提供說明文字，引導使用者輸入電子郵件。
 - `emailTextField`：用於輸入電子郵件地址，為必填欄位。
 - `resetPasswordButton`：用於提交重置密碼請求。
 - `loginPageButton`：用於讓使用者返回登入頁面。

 `3. StackView 與 ScrollView 的使用`
 
 - `StackView`：將標題、描述、輸入框和按鈕組織在一個垂直的 `StackView` 中，使得元件排列整齊且能自動適應畫面的大小變化。
 - `ScrollView`：使用 `ScrollView` 包裹所有內容，確保當鍵盤出現時能夠進行滾動，避免內容被遮擋。

 `4. 提供公共存取方法`
 
 - `按鈕與輸入框的存取`：提供公共方法來取得 `resetPasswordButton`、`loginPageButton` 及輸入的電子郵件文字。
 - 這樣可以在控制器中使用這些元件來實現互動功能，而不必直接操作私有屬性。

 -----------------------------

` * 結構與重點`
 
 `1. 屬性說明`
 
 - `titleLabel`、`descriptionLabel`、`emailTextField`、`resetPasswordButton`、`loginPageButton` 為頁面上的 UI 元件，設置為私有屬性，僅通過公共方法供外部使用。
 - `mainStackView`：垂直排列所有 UI 元件，簡化元件佈局。
 - `mainScrollView`：用於包裹 `mainStackView`，支援畫面滾動。

 `2. 方法說明`
 
 - `setupScrollView()`：配置 `ScrollView`，設定其在視圖中的約束。
 - `setupMainStackView()`：將 UI 元件加入 `StackView`，並添加至 `ScrollView` 中。
 - `setupConstraints()`：設置 `StackView` 的約束，確保所有元件能正確顯示於畫面上。
 - `setViewHeights()`：為每個元件設置特定的高度，統一 UI 風格。
 - `setupBackground()`：設置背景顏色。

 `3. Public Getters`
 
 - `getEmail()`：取得使用者輸入的電子郵件字串，並去除前後空白。
 - `getResetPasswordButton()`、`getLoginPageButton()`：取得按鈕元件，供外部的控制器設置事件行為。

 `* Summary`
 
 - `ForgotPasswordView` 將忘記密碼頁面的 UI 設置與邏輯分離，專注於 UI 元件的配置和佈局，提升了程式碼的可讀性與模組化特性。
 - 這樣的設計讓視圖控制器能專注於邏輯行為的處理，符合單一職責原則，使程式碼更容易維護及擴充。
 */



// MARK: - 職責未分離
/*
import UIKit

/// 處理 ForgotPasswordViewController 相關 UI元件 佈局
class ForgotPasswordView: UIView {

    // MARK: - UI Elements
    
    let titleLabel = ForgotPasswordLabel(text: "Forgot Password ?", fontSize: 26, weight: .black, textColor: .deepGreen)

    let descriptionLabel = ForgotPasswordLabel(text: "Enter your email address below and we'll send your password reset instructions by email.", fontSize: 16, weight: .medium, textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    let emailTextField = ForgotPasswordTextField(placeholder: "Email", rightIconName: "envelope", isPasswordField: false, fieldType: .email)
    
    let resetPasswordButton = ForgotPasswordFilledButton(title: "Rest Password", textFont: .systemFont(ofSize: 18, weight: .black), textColor: .white, backgroundColor: .deepGreen, symbolName: "key.horizontal.fill")
    
    let loginPageButton = ForgotPasswordAttributedButton(mainText: "You remember your password? ", highlightedText: "Login", fontSize: 14, mainTextColor: .gray, highlightedTextColor: .deepGreen)
    
    // MARK: - StackView
    
    private let topStackView = ForgotPasswordStackView(axis: .vertical, spacing: 20, alignment: .fill, distribution: .fill)
    
    private let bottomStackView = ForgotPasswordStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)

    
    // MARK: - ScrollView
    
    /// ScrollView 用來包裹所有 StackView，支援畫面滾動，特別是在鍵盤顯示時仍能滾動
    private let mainScrollView = ForgotPasswordScrollView()


    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupStackViews()
        setupConstraints()
        setViewHeights()            // 設置元件高度
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 設置 ScrollView
    private func setupScrollView() {
        mainScrollView.setupConstraints(in: self) // 將 scrollView 加入 ForgotPasswordView 並設置其約束
    }
    
    // MARK: - Setup Methods
    
    /// 設置 StackViews 並加入 ScrollView
    private func setupStackViews() {

        // 設置子 StackView 的元件
        topStackView.addArrangedSubview(titleLabel)
        topStackView.addArrangedSubview(descriptionLabel)
        topStackView.addArrangedSubview(emailTextField)
        
        bottomStackView.addArrangedSubview(resetPasswordButton)
        bottomStackView.addArrangedSubview(loginPageButton)
        
        // 將 StackView 添加到 ScrollView 中
        mainScrollView.addSubview(topStackView)
        mainScrollView.addSubview(bottomStackView)
    }
    
    /// 設置 StackView 的約束
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 20),
            topStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 30),
            topStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -30),
            topStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -60),

            bottomStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 40),
            
            bottomStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 30),
            bottomStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -30),
            bottomStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: -20),
            bottomStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -60)

        ])
    }

    /// 設置元件高度
    private func setViewHeights() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 100),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            resetPasswordButton.heightAnchor.constraint(equalToConstant: 55),
            loginPageButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
}
*/


// MARK: - 重構職責

import UIKit

/// 處理 ForgotPasswordViewController 相關 UI元件 佈局
class ForgotPasswordView: UIView {

    // MARK: - UI Elements
    
    private let titleLabel = ForgotPasswordLabel(text: "Forgot Password ?", fontSize: 26, weight: .black, textColor: .deepGreen)
    private let descriptionLabel = ForgotPasswordLabel(text: "Enter your email address below and we'll send your password reset instructions by email.", fontSize: 16, weight: .medium, textColor: .black, textAlignment: .left, numberOfLines: 0)
    private let emailTextField = ForgotPasswordTextField(placeholder: "Email", rightIconName: "envelope", isPasswordField: false, fieldType: .email)
    private let resetPasswordButton = ForgotPasswordFilledButton(title: "Rest Password", textFont: .systemFont(ofSize: 18, weight: .black), textColor: .white, backgroundColor: .deepGreen, symbolName: "key.horizontal.fill")
    private let loginPageButton = ForgotPasswordAttributedButton(mainText: "You remember your password? ", highlightedText: "Login", fontSize: 14, mainTextColor: .gray, highlightedTextColor: .deepGreen)
    
    // MARK: - StackView
    private let mainStackView = ForgotPasswordStackView(axis: .vertical, spacing: 20, alignment: .fill, distribution: .fill)
    
    // MARK: - ScrollView
    private let mainScrollView = ForgotPasswordScrollView()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()                         // 設置 mainScrollView
        setupMainStackView()                      // 設置 mainStackView 和其子視圖
        setupConstraints()                        // 設置約束
        setViewHeights()                          // 設置元件高度
        setupBackground()                         // 設置背景色
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置 ScrollView
    private func setupScrollView() {
        mainScrollView.setupConstraints(in: self)
    }
    
    /// 設置 StackViews 並加入 ScrollView
    private func setupMainStackView() {
        // 設置子 StackView 的元件
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(emailTextField)
        mainStackView.addArrangedSubview(resetPasswordButton)
        mainStackView.addArrangedSubview(loginPageButton)
        
        // 為 resetPasswordButton 前的元素（即 emailTextField）設置較大的間距
        mainStackView.setCustomSpacing(80, after: emailTextField)
        
        mainScrollView.addSubview(mainStackView)
    }
    
    /// 設置 StackView 的約束
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 30),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -30),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: -20),
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -60)
        ])
    }
    
    /// 設置元件高度
    private func setViewHeights() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 100),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            resetPasswordButton.heightAnchor.constraint(equalToConstant: 55),
            loginPageButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    /// 設置背景顏色
    private func setupBackground() {
        backgroundColor = .white
    }
    
    // MARK: - Public Getters for UI Elements

    // MARK: Text Fields
    
    /// 獲取使用者輸入的電子郵件地址
    /// - Returns: 使用者輸入的電子郵件地址字串 (Email)，若無輸入則返回空字串
    func getEmail() -> String {
        return emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    // MARK: Buttons

    /// 提供重置密碼按鈕的公共存取方法
    /// - Returns: 重置密碼按鈕 (Reset Password Button)
    func getResetPasswordButton() -> UIButton {
        return resetPasswordButton
    }
    
    /// 提供進入登入頁面按鈕的公共存取方法
    /// - Returns: 重置密碼按鈕 (Login Page Button)
    func getLoginPageButton() -> UIButton {
        return loginPageButton
    }
    
}
