//
//  SignUpActionHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/30.
//

// MARK: - 筆記：`SignUpActionHandler` 的設計與使用
/**
 
 ## 筆記：`SignUpActionHandler` 的設計與使用

 `* What`
 
 - `SignUpActionHandler` 是一個專門用來管理 `SignUpView` 中使用者行為的處理器類別，主要負責：
 
 1. 處理 `SignUpView` 各按鈕的點擊事件。
 2. 通過 `SignUpViewDelegate` 回調至 `SignUpViewController`，實現行為的傳遞。

 -----------------------------

 `* Why：為什麼需要 SignUpActionHandler`
 
 `1. 職責分離：`
 
    - 將按鈕的行為邏輯從 `SignUpView` 和 `SignUpViewController` 中抽離，遵守單一職責原則，使每個類別的職責更加明確，減少控制層的複雜度。

 `2. 降低耦合度：`
 
    - 使用 `SignUpActionHandler` 可以降低 `SignUpView` 與 `SignUpViewController` 的耦合度。
    - 視圖和控制層之間通過委派模式（`delegate`）進行通信，這樣可以讓視圖的操作與控制邏輯彼此分離，提升代碼的可維護性。

 `3. 提升可讀性與重用性：`
 
    - 透過一個專門的行為處理器來管理按鈕事件，`SignUpViewController` 更專注於業務邏輯的實現，而 `SignUpView` 更專注於 UI 的呈現，使代碼邏輯更加清晰。

 -----------------------------

 `* How：如何實作 SignUpActionHandler`
 
 `1. 初始化與依賴注入：`
 
    - `SignUpActionHandler` 透過構造函數接受 `SignUpView` 和 `SignUpViewDelegate` 作為參數進行初始化，將按鈕行為的設置與回調的責任一併注入，避免不必要的強引用循環。

 `2. 配置按鈕行為：`
 
    - 使用 `setupActions()` 方法將 `SignUpView` 中的所有按鈕與相應的行為方法進行綁定。這樣的設計讓 `SignUpViewController` 不直接涉及具體的 UI 操作，只需負責處理高層次的業務邏輯。

 `3. 透過 delegate 回調使用者行為：`
 
    - 每當按鈕被點擊，對應的行為會被觸發，並通過委派回調至控制器，以進一步執行相應的操作，例如跳轉到其他頁面、進行表單提交等。`SignUpActionHandler` 中的方法如 `didTapSignUpButton()`、`didTapTermsButton()` 等，都是通知控制層進行下一步業務邏輯的觸發點。

 -----------------------------

 `* 總結`
 
 - `SignUpActionHandler` 提供了一個中間層來管理 `SignUpView` 中按鈕的點擊行為，這樣可以讓 `SignUpView` 負責 UI 展現，`SignUpViewController` 負責業務邏輯，行為處理器則管理使用者行為，三者之間的責任劃分明確，符合單一職責原則並提升了代碼的可讀性與可維護性。
 */


// MARK: - (v)

import UIKit

/// `SignUpActionHandler` 負責管理 `SignUpView` 中的使用者行為，包括處理按鈕的點擊事件並將這些行為回調至 `SignUpViewDelegate`
class SignUpActionHandler {
    
    // MARK: - Properties
    
    /// `view` 是 `SignUpView` 的弱引用，用於設置和操作 `SignUpView` 的各個 UI 元素，避免強引用循環
    private weak var view: SignUpView?
    
    /// `delegate` 是 `SignUpViewDelegate` 的弱引用，用於將使用者行為回調到 `SignUpViewController`，避免強引用循環
    private weak var delegate: SignUpViewDelegate?
    
    // MARK: - Initializer
    
    /// 初始化 `SignUpActionHandler`，用於設置 `view` 和 `delegate`，並配置按鈕行為
    /// - Parameters:
    ///   - view: `SignUpView` 的實例，用於設置按鈕行為
    ///   - delegate: `SignUpViewDelegate` 的實例，用於將行為回調至 `SignUpViewController`
    init(view: SignUpView, delegate: SignUpViewDelegate) {
        self.view = view
        self.delegate = delegate
        setupActions()
    }
    
    // MARK: - Private Methods
    
    /// 配置 `SignUpView` 中所有按鈕的行為，將每個按鈕的點擊事件與相應的方法綁定
    /// - 注意：透過 `guard let` 確保 `view` 存在，避免因 `view` 被釋放而導致的錯誤
    private func setupActions() {
        guard let view = view else { return }
        
        view.signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        view.googleLoginButton.addTarget(self, action: #selector(didTapGoogleSignUpButton), for: .touchUpInside)
        view.appleLoginButton.addTarget(self, action: #selector(didTapAppleSignUpButton), for: .touchUpInside)
        view.termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        view.termsCheckBox.addTarget(self, action: #selector(didTapTermsCheckBox), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    /// 處理「註冊」按鈕的點擊事件，通知 `delegate` 使用者點擊了註冊按鈕
    @objc private func didTapSignUpButton() {
        delegate?.signUpViewDidTapSignUpButton()
    }

    /// 處理「使用 Google 註冊」按鈕的點擊事件，通知 `delegate` 使用者點擊了 Google 註冊按鈕
    @objc private func didTapGoogleSignUpButton() {
        delegate?.signUpViewDidTapGoogleSignUpButton()
    }

    /// 處理「使用 Apple 註冊」按鈕的點擊事件，通知 `delegate` 使用者點擊了 Apple 註冊按鈕
    @objc private func didTapAppleSignUpButton() {
        delegate?.signUpViewDidTapAppleSignUpButton()
    }

    /// 處理「閱讀條款」按鈕的點擊事件，通知 `delegate` 使用者點擊了閱讀條款按鈕
    @objc private func didTapTermsButton() {
        delegate?.signUpViewDidTapTermsButton()
    }
    
    /// 處理「我同意條款」的 CheckBox 按鈕的點擊事件，通知 `delegate` 使用者點擊了「同意條款」
    @objc private func didTapTermsCheckBox() {
        delegate?.signUpViewDidTapTermsCheckBox()
    }
}
