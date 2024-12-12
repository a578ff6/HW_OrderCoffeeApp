//
//  ForgotPasswordViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - 筆記：ForgotPasswordViewController 設計概述與職責說明
/**
 
 ## 筆記：ForgotPasswordViewController 設計概述與職責說明

 `* What - 忘記密碼畫面`
 
 - `ForgotPasswordViewController` 負責處理忘記密碼相關的邏輯和畫面顯示，主要使用 `ForgotPasswordView` 作為其 UI 主體。該控制器負責管理 UI 行為與業務邏輯之間的解耦，確保代碼的可維護性和模組化。

 ---------------------------------
 
 `* Why - 解耦與模組化的需求`
 
 1. `提升模組化`：
    - 將不同職責的邏輯分開，減少 `ForgotPasswordViewController` 的責任，使其更加精簡且可維護。
 
 2. `UI 與業務邏輯分離`：
    - 使用 `ForgotPasswordActionHandler` 來處理按鈕的行為，使 `ForgotPasswordView` 專注於 UI 顯示，業務邏輯則由 `ForgotPasswordViewController` 或 `ActionHandler` 處理，減少耦合。
 
 3. `導航欄邏輯的集中管理`：
    - 通過 `ForgotPasswordNavigationBarManager` 統一管理導航欄的配置邏輯，避免導航相關邏輯分散在控制器內，增加代碼的可讀性與易維護性。

 ---------------------------------

 `* How - 如何實現模組化與解耦`
 
 `1. 使用 ForgotPasswordNavigationBarManager 管理導航欄：`
     - 由 `ForgotPasswordNavigationBarManager` 負責設置導航欄中的按鈕，如「關閉」按鈕。這樣可以集中管理導航邏輯，增強代碼結構的清晰度。
     - `ForgotPasswordViewController` 中使用 `setupNavigationBarManager()` 方法初始化並設置導航欄管理器，並調用 `setupCloseButton()` 設置按鈕。

 `2. ForgotPasswordActionHandler 處理 UI 行為：`
     - `ForgotPasswordActionHandler` 負責處理 `ForgotPasswordView` 中所有按鈕的點擊事件，並將這些事件回調至 `ForgotPasswordDelegate` 進行具體邏輯的處理。這樣的設計可以將 UI 層的操作與業務邏輯進行解耦。

 `3. ForgotPasswordDelegate 實現使用者操作回應：`
     - 當使用者點擊「重置密碼」或「返回登入頁面」按鈕時，`ForgotPasswordDelegate` 會觸發對應的回應方法，執行具體邏輯。
     - `forgotPasswordDidTapResetPasswordButton()` 中，首先會調用 `dismissKeyboard()` 收起鍵盤，然後驗證電子郵件的有效性（`validateEmailInput(_:)` 方法），接著執行密碼重置操作。
     - `forgotPasswordDidTapLoginPageButton()` 負責關閉當前畫面並返回登入頁面。

 ---------------------------------

 `* Summary - 關鍵點整理`
 
 1. `ForgotPasswordViewController` 主要負責初始化 `ForgotPasswordView`，並與 `ForgotPasswordActionHandler`、`ForgotPasswordNavigationBarManager` 協同完成行為管理和邏輯處理。
 2. `解耦 UI 與邏輯`：通過 `ForgotPasswordActionHandler` 將按鈕行為從控制器中抽離，`ForgotPasswordDelegate` 實現行為與邏輯的解耦。
 3. `導航欄管理`：`ForgotPasswordNavigationBarManager` 統一處理導航欄的配置，保持代碼清晰並增強維護性。
 4. `Email 驗證方法 (validateEmailInput)`：集中處理 Email 格式的驗證，若驗證失敗則提示使用者，以確保操作流程的正確性。
 */


// MARK: - (v)

import UIKit

/// 忘記密碼介面：負責處理忘記密碼相關的邏輯與畫面
/// - 主要職責包括：
///   1. 初始化並配置 `ForgotPasswordView` 作為主要的 UI 畫面。
///   2. 通過 `ForgotPasswordActionHandler` 設置各按鈕的行為，將 UI 操作與邏輯處理解耦。
///   3. 通過實現 `ForgotPasswordDelegate`，將使用者的操作行為進行相應的邏輯處理。
class ForgotPasswordViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 忘記密碼話面主體，用於顯示 UI 元件
    private let forgotPasswordView = ForgotPasswordView()
    
    // MARK: - Handlers

    /// `ForgotPasswordActionHandler` 負責處理 `ForgotPasswordView` 中按鈕的行為
    /// - 設定 `ForgotPasswordView` 和 `ForgotPasswordDelegate` 以實現事件與邏輯的分離
    private var forgotPasswordActionHandler: ForgotPasswordActionHandler?
    
    /// `ForgotPasswordNavigationBarManager` 負責管理導航欄相關操作
    private var navigationBarManager: ForgotPasswordNavigationBarManager?
    
    // MARK: - Lifecycle Methods
    
    /// 設置主要視圖
    override func loadView() {
        view = forgotPasswordView
    }
    
    /// 初始化畫面元件與行為處理器
    /// - 初始化 `SignUpActionHandler` 並設定按鈕行為
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarManager()
        setupActionHandler()
    }
    
    // MARK: - Private Methods
    
    /// 初始化並設置 `ForgotPasswordNavigationBarManager`
    /// - 通過 `ForgotPasswordNavigationBarManager` 來設置導航欄按鈕。
    private func setupNavigationBarManager() {
        navigationBarManager = ForgotPasswordNavigationBarManager(navigationItem: navigationItem, viewController: self)
        navigationBarManager?.setupCloseButton()
    }
    
    /// 初始化並設置 `ForgotPasswordActionHandler`
    /// - `ForgotPasswordActionHandler` 負責處理 `ForgotPasswordView` 中的按鈕行為
    /// - 通過設置 view 與 delegate，將 UI 行為與邏輯解耦合
    private func setupActionHandler() {
        forgotPasswordActionHandler = ForgotPasswordActionHandler(view: forgotPasswordView, delegate: self)
    }
    
    /// 統一的鍵盤收起方法
    /// - 收起當前視圖中活動的鍵盤
    /// - 使用於各種按鈕操作開始前，確保畫面整潔、避免鍵盤遮擋重要資訊或 HUD
    private func dismissKeyboard() {
        view?.endEditing(true)
    }
    
}

// MARK: - ForgotPasswordDelegate
extension ForgotPasswordViewController: ForgotPasswordDelegate {
    
    // MARK: - Reset Password Button
    
    /// 處理「重置密碼」按鈕點擊事件
    /// - 驗證輸入資料是否符合規範，若成功則進行重置密碼請求，並關閉模態視圖控制器
    /// - 在重置密碼請求流程開始前先收起鍵盤，確保畫面整潔並避免影響 HUD 顯示
    func forgotPasswordDidTapResetPasswordButton() {
        dismissKeyboard()
        
        let email = forgotPasswordView.email
        
        // 驗證電子郵件輸入
        guard validateEmailInput(email) else { return }
        
        HUDManager.shared.showLoading(text: "Sending...")
        Task {
            do {
                try await EmailSignInController.shared.resetPassword(forEmail: email)
                // 發送成功，顯示成功訊息，關閉模態視圖控制器
                print("Password reset email sent successfully")
                AlertService.showAlert(withTitle: "通知", message: "如果您的信箱已註冊，我們將發送密碼重置郵件給您。", inViewController: self) {
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {
                // 發送失敗，顯示錯誤信息
                print("Error sending password reset email: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Helper Methods for Reset Password Button Validation
    
    /// 驗證電子郵件輸入的有效性
    /// - Parameter email: 使用者輸入的電子郵件字串
    /// - Returns: Bool，表示輸入是否有效 (true 表示有效，false 表示無效)
    private func validateEmailInput(_ email: String) -> Bool {
        // 確保電子郵件輸入不為空
        guard !email.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫您的信箱", inViewController: self)
            return false
        }
        // 檢查電子郵件格式是否有效
        guard EmailSignInController.isEmailvalid(email) else {
            AlertService.showAlert(withTitle: "錯誤", message: "無效的電子郵件格式", inViewController: self)
            return false
        }
        
        return true
    }
    
    // MARK: - Login Page Actions
    
    /// 處理「返回登入頁面」按鈕點擊事件
    /// - 功能說明：當使用者點擊「返回登入頁面」按鈕後，該方法負責將當前的忘記密碼畫面關閉，並回到登入畫面。
    ///   1. 此方法適用於 `ForgotPasswordViewController` 以 `sheetPresentationController` 的 large 形式呈現的情況。
    ///   2. 執行 `dismiss` 動畫，關閉忘記密碼頁面，讓使用者返回至 `LoginViewController` 。
    func forgotPasswordDidTapLoginPageButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
