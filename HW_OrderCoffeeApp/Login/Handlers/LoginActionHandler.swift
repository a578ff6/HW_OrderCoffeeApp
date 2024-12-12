//
//  LoginActionHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/29.
//

// MARK: - LoginActionHandler 筆記
/**
 ### LoginActionHandler 筆記

 - 主要是按鈕等互動元件較多，為了避免LoginView過於肥大且職責模糊， 因此設置LoginActionHandler來處理動作行為。
 - `LoginActionHandler` 是一個負責管理 `LoginView` 中所有使用者行為的類別。
 - 它負責設置 `LoginView` 內各種 UI 元件的點擊事件，並將這些事件傳遞給 `LoginViewDelegate`。

 --------------------------------------

 `* Why: 為什麼使用 LoginActionHandler`
 
 `1. 分離邏輯：`
    - 把使用者行為的處理邏輯與 UI 元件的佈局分開，減少 `LoginView` 和 `LoginViewController` 的責任，確保單一職責原則。這樣可以使每個類別的功能更集中、代碼更易於維護。
 
 `2. 避免循環引用：`
    - `LoginActionHandler` 持有 `view` 和 `delegate` 的弱引用 (`weak`)。這樣設計可以避免強引用循環，防止內存洩漏。
 
 `3. 更好的可測試性：`
    - 將按鈕行為抽離到 `LoginActionHandler` 中，能更容易對行為處理邏輯進行單元測試，而不受 UI 布局或 `ViewController` 邏輯的影響。

 --------------------------------------

 `* How: 如何使用 LoginActionHandler`
 
 `1. 初始化時傳入 LoginView 和 LoginViewDelegate：`
 
    - 在初始化時，需要傳入 `LoginView` 和 `LoginViewDelegate` 的實例。
    - 這樣 `LoginActionHandler` 就可以對 `LoginView` 的 UI 元件進行管理，並通過 `delegate` 將行為回調至 `LoginViewController`。

    ```swift
    init(view: LoginView, delegate: LoginViewDelegate) {
        self.view = view
        self.delegate = delegate
        setupActions()
    }
    ```

 `2. 設置按鈕行為：`
 
    - 使用 `setupActions()` 方法為 `LoginView` 中的每個按鈕設置行為，將每個按鈕的 `touchUpInside` 事件與相應的處理方法綁定。
    
    ```swift
    private func setupActions() {
        guard let view = view else { return }
        
        view.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        view.googleLoginButton.addTarget(self, action: #selector(didTapGoogleLoginButton), for: .touchUpInside)
        // 其他按鈕設置類似...
    }
    ```

 `3. 回調事件通知 delegate：`
    - 當使用者點擊按鈕時，透過相應的 @objc 方法處理點擊事件，並通知 `delegate`。
    - 例如，當使用者點擊登入按鈕時，會調用 `delegate?.loginViewDidTapLoginButton()`。
    
    ```swift
    @objc private func didTapLoginButton() {
        delegate?.loginViewDidTapLoginButton()
    }
    
    @objc private func didTapRememberMeButton() {
        guard let rememberMeButton = view?.rememberMeButton else { return }
        let isSelected = !rememberMeButton.isSelected
        rememberMeButton.isSelected = isSelected
        delegate?.loginViewDidTapRememberMeButton(isSelected: isSelected)
    }
    ```

 --------------------------------------

` * 總結`
 
 `LoginActionHandler` 將 `LoginView` 的按鈕行為抽離至單獨的處理器中，這樣設計有以下好處：
 
 - `單一職責原則`：`LoginView` 專注於 UI 設置，`LoginActionHandler` 專注於行為邏輯，`LoginViewController` 則負責響應回調。
 - `弱引用避免循環引用`：使用弱引用來持有 `view` 和 `delegate`，防止強引用循環，避免內存洩漏。
 - `更好的代碼可測試性和維護性`：分離的邏輯使代碼模組化，讓每個模組的測試和維護更加獨立和容易。也使得各個模組間的耦合度更低，達到清晰的責任劃分。
 */



// MARK: - (v)

import UIKit

/// `LoginActionHandler` 負責管理 `LoginView` 中的使用者行為
class LoginActionHandler {
    
    // MARK: - Properties

    /// `view` 是 `LoginView` 的弱引用，用於設置和操作 `LoginView` 的各個 UI 元素，避免強引用循環
    private weak var view: LoginView?
    
    /// `delegate` 是 `LoginViewDelegate` 的弱引用，用於將使用者行為回調到 `LoginViewController`，避免強引用循環
    private weak var delegate: LoginViewDelegate?
    
    // MARK: - Initializer

    /// 初始化 `LoginActionHandler`，用於設置 `view` 和 `delegate`，並配置按鈕行為
    /// - Parameters:
    ///   - view: `LoginView` 的實例，用於設置按鈕行為
    ///   - delegate: `LoginViewDelegate` 的實例，用於將行為回調至 `LoginViewController`
    init(view: LoginView, delegate: LoginViewDelegate) {
        self.view = view
        self.delegate = delegate
        setupActions()
    }
    
    // MARK: - Private Methods

    /// 配置 `LoginView` 中所有按鈕的行為，將每個按鈕的點擊事件與相應的方法綁定
    private func setupActions() {
        guard let view = view else { return }
        
        view.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        view.googleLoginButton.addTarget(self, action: #selector(didTapGoogleLoginButton), for: .touchUpInside)
        view.appleLoginButton.addTarget(self, action: #selector(didTapAppleLoginButton), for: .touchUpInside)
        view.forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPasswordButton), for: .touchUpInside)
        view.signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        view.rememberMeButton.addTarget(self, action: #selector(didTapRememberMeButton), for: .touchUpInside)
    }
    
    // MARK: - Actions

    /// 處理登入按鈕的點擊事件，通知 `delegate` 使用者點擊了登入按鈕
    @objc private func didTapLoginButton() {
        delegate?.loginViewDidTapLoginButton()
    }

    /// 處理 Google 登入按鈕的點擊事件，通知 `delegate` 使用者點擊了 Google 登入按鈕
    @objc private func didTapGoogleLoginButton() {
        delegate?.loginViewDidTapGoogleLoginButton()
    }

    /// 處理 Apple 登入按鈕的點擊事件，通知 `delegate` 使用者點擊了 Apple 登入按鈕
    @objc private func didTapAppleLoginButton() {
        delegate?.loginViewDidTapAppleLoginButton()
    }

    /// 處理忘記密碼按鈕的點擊事件，通知 `delegate` 使用者點擊了忘記密碼按鈕
    @objc private func didTapForgotPasswordButton() {
        delegate?.loginViewDidTapForgotPasswordButton()
    }

    /// 處理註冊按鈕的點擊事件，通知 `delegate` 使用者點擊了註冊按鈕
    @objc private func didTapSignUpButton() {
        delegate?.loginViewDidTapSignUpButton()
    }

    /// 處理 "記住我" 按鈕的點擊事件，切換按鈕選中狀態，並通知 `delegate` 使用者點擊了 "記住我" 按鈕
    @objc private func didTapRememberMeButton() {
        guard let rememberMeButton = view?.rememberMeButton else { return }
        let isSelected = !rememberMeButton.isSelected
        rememberMeButton.isSelected = isSelected
        delegate?.loginViewDidTapRememberMeButton(isSelected: isSelected)
    }
}
