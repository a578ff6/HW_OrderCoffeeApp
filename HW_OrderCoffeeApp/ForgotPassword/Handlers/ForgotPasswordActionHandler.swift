//
//  ForgotPasswordActionHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/2.
//

// MARK: - 筆記：ForgotPasswordActionHandler 使用說明
/**
 
 ## 筆記：ForgotPasswordActionHandler 使用說明

 `* What`
 
 - `ForgotPasswordActionHandler` 是一個負責處理 `ForgotPasswordView` 中各個按鈕行為的類別。
 - 主要目的是管理使用者在 `ForgotPasswordView` 上的交互操作，並將按鈕點擊事件回調至遵循 `ForgotPasswordDelegate` 協定的對象。

 -----------------------------------
 
 `* Why`
 
 - 使用 `ForgotPasswordActionHandler` 可以將使用者行為管理的邏輯從 `ForgotPasswordViewController` 中分離出來，這樣能夠有效地降低視圖控制器的複雜性，讓 `ViewController` 更專注於控制畫面的邏輯，而按鈕行為則由 `ForgotPasswordActionHandler` 來處理。
 - 這樣可以遵循單一職責原則，使程式碼更具可讀性和可維護性。

 -----------------------------------

 `* How`

 `1. 初始化`
    
 - `ForgotPasswordActionHandler` 在初始化時，會將 `ForgotPasswordView` 及 `ForgotPasswordDelegate` 設置為其屬性，並透過 `setupActions()` 方法來設定按鈕的行為。

    ```swift
    private func setupActionHandler() {
        forgotPasswordActionHandler = ForgotPasswordActionHandler(view: forgotPasswordView, delegate: self)
    }
    ```

 `2. 設置按鈕行為`
 
 - `setupActions()` 方法負責綁定按鈕與其點擊處理邏輯。透過 `guard let` 確保 `view` 存在後，為「重置密碼」和「前往登入頁面」兩個按鈕分別設置行為處理方法。
 - 例如，當「重置密碼」按鈕被點擊時，`handleResetPasswordButtonTapped()` 方法被呼叫並通知 `delegate` 進行對應的操作。

 `3. 行為處理方法`
 
 - `handleResetPasswordButtonTapped()` 會通知 `delegate` 使用者點擊了重置密碼按鈕，透過 `delegate` 將點擊事件傳遞給 `ForgotPasswordViewController`。
 - `handleLoginPageButtonTapped()` 同樣通知 `delegate`，使用者點擊了前往登入頁面按鈕，讓控制器處理相關的操作。

 -----------------------------------

 `* 結構與重點`

 `1. Properties`
 
 - `view`: 使用弱引用 (`weak`) 指向 `ForgotPasswordView`，避免強引用循環，確保當視圖被釋放時不會造成記憶體洩漏。
 - `delegate`: 使用弱引用指向 `ForgotPasswordDelegate`，同樣為了避免強引用循環，讓控制器可以釋放。

 `2. Initializer`
 
 - 初始化 `view` 與 `delegate`，並在初始化後立即呼叫 `setupActions()` 設置按鈕的點擊行為。

 `3. Setup Actions`
 
 - `setupActions()`: 確保 `view` 存在後，設定按鈕的行為，將按鈕的點擊事件與相應的方法綁定。

 `4. Actions Methods`
 
 - `handleResetPasswordButtonTapped()`: 處理重置密碼按鈕的點擊事件，並將事件回傳給 `ForgotPasswordDelegate`。
 - `handleLoginPageButtonTapped()`: 處理登入頁面按鈕的點擊事件，並回傳給 `ForgotPasswordDelegate`。

 -----------------------------------

` * Summary`
 
 - `ForgotPasswordActionHandler` 的使用使得 `ForgotPasswordViewController` 中的使用者行為管理邏輯得以分離，讓視圖控制器的職責更加明確。
 - 它負責管理 `ForgotPasswordView` 中所有按鈕的行為，透過 `delegate` 將這些行為回調給控制器，讓整個流程更具模組化和可維護性。這樣的設計讓 UI 操作與邏輯控制解耦合，遵循了單一職責原則，提升程式碼的可讀性和重用性。
 */


import UIKit

/// `ForgotPasswordActionHandler` 負責管理 `ForgotPasswordView` 中的使用者行為，包括處理按鈕的點擊事件並將這些行為回調至 `ForgotPasswordDelegate`
class ForgotPasswordActionHandler {
    
    // MARK: - Properties
    
    /// `view` 是 `ForgotPasswordView` 的弱引用，用於設置和操作 `ForgotPasswordView` 的各個 UI 元素，避免強引用循環
    private weak var view: ForgotPasswordView?
    
    /// `delegate` 是 `ForgotPasswordDelegate` 的弱引用，用於將使用者行為回調到 `ForgotPasswordViewController`，避免強引用循環
    private weak var delegate: ForgotPasswordDelegate?
 
    // MARK: - Initializer
    
    /// 初始化 `ForgotPasswordDelegate`，用於設置 `view` 和 `delegate`，並配置按鈕行為
    /// - Parameters:
    ///   - view: `ForgotPasswordView` 的實例，用於設置按鈕行為
    ///   - delegate: `ForgotPasswordDelegate` 的實例，用於將行為回調至 `ForgotPasswordViewController`
    init(view: ForgotPasswordView, delegate: ForgotPasswordDelegate) {
        self.view = view
        self.delegate = delegate
        setupActions()
    }
    
    // MARK: - Private Methods

    /// 配置 `ForgotPasswordView` 中所有按鈕的行為，將每個按鈕的點擊事件與相應的方法綁定
    /// - 注意：透過 `guard let` 確保 `view` 存在，避免因 `view` 被釋放而導致的錯誤
    private func setupActions() {
        guard let view = view else { return }
        
        view.getResetPasswordButton().addTarget(self, action: #selector(handleResetPasswordButtonTapped), for: .touchUpInside)
        view.getLoginPageButton().addTarget(self, action: #selector(handleLoginPageButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions

    /// 處理「重置密碼」按鈕的點擊事件，通知 `delegate` 使用者點擊了重置密碼按鈕
    @objc private func handleResetPasswordButtonTapped() {
        delegate?.forgotPasswordDidTapResetPasswordButton()
    }
    
    /// 處理「前往登入頁面」按鈕的點擊事件，通知 `delegate` 使用者點擊了前往登入頁面按鈕
    @objc private func handleLoginPageButtonTapped() {
        delegate?.forgotPasswordDidTapLoginPageButton()
    }
}
