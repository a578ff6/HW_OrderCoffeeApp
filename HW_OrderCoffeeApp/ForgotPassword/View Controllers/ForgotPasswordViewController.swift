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
 
 - `ForgotPasswordViewController`
 
    - 負責處理忘記密碼相關的邏輯和畫面顯示，主要使用 `ForgotPasswordView` 作為其 UI 主體。該控制器負責管理 UI 行為與業務邏輯之間的解耦，確保代碼的可維護性和模組化。

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
 
    - `ForgotPasswordActionHandler` 負責處理 `ForgotPasswordView` 中所有按鈕的點擊事件，並將這些事件回調至 `ForgotPasswordDelegate` 進行具體邏輯的處理。
    - 這樣的設計可以將 UI 層的操作與業務邏輯進行解耦。

 `3. ForgotPasswordDelegate 實現使用者操作回應：`
 
    - 當使用者點擊「重置密碼」或「返回登入頁面」按鈕時，`ForgotPasswordDelegate` 會觸發對應的回應方法，執行具體邏輯。
    - `forgotPasswordDidTapResetPasswordButton()` 中，首先會調用 `dismissKeyboard()` 收起鍵盤，然後檢查是否輸入信箱，接著執行密碼重置操作。
    - `forgotPasswordDidTapLoginPageButton()` 負責關閉當前畫面並返回登入頁面。

 ---------------------------------

 `* Summary - 關鍵點整理`
 
 1. `ForgotPasswordViewController` 主要負責初始化 `ForgotPasswordView`，並與 `ForgotPasswordActionHandler`、`ForgotPasswordNavigationBarManager` 協同完成行為管理和邏輯處理。
 2. `解耦 UI 與邏輯`：通過 `ForgotPasswordActionHandler` 將按鈕行為從控制器中抽離，`ForgotPasswordDelegate` 實現行為與邏輯的解耦。
 3. `導航欄管理`：`ForgotPasswordNavigationBarManager` 統一處理導航欄的配置，保持代碼清晰並增強維護性。
 */


// MARK: - ForgotPasswordViewController 信箱筆記
/**
 
 ### ForgotPasswordViewController 信箱筆記


 `* What`
 
 - `ForgotPasswordViewController` **負責處理忘記密碼的 UI 及邏輯**，並透過 **Firebase 的密碼重置功能** 讓使用者重設密碼。
 
 - 主要職責包含：
 
 1. 顯示 UI
 
    - 使用 `ForgotPasswordView` 作為主要視圖，確保 UI 與邏輯分離。

 2. 處理使用者行為
 
    - 透過 `ForgotPasswordActionHandler` 處理 UI 操作，如「送出重設密碼請求」。

 3. 驗證輸入
 
    - 確保使用者至少有輸入 `Email`，避免發送空白請求。
    - 原本考慮驗證 Email 格式 (`SignUpValidationManager.validateEmailFormat`)。

 4. 發送 Firebase 密碼重設請求
 
    - 透過 `EmailAuthController.resetPassword(forEmail:)` 與 Firebase 互動。
    - 若 Email 記錄存在，Firebase 會發送密碼重設郵件。
    - 若 Email 不存在，則不影響安全性，Firebase 也不會返回錯誤。

 ---------

 `* Why`
 
 1.是否應該驗證 Email 格式？
 
 - 在 `SignUpViewController` 中，會驗證 Email 格式 (`validateEmailFormat`)，因為：
    
    - 註冊需要嚴格驗證 Email，以確保格式正確，避免無效帳戶註冊。
    -  防止使用者輸入錯誤 Email 而導致註冊失敗。

 - 但在 `ForgotPasswordViewController`，不一定需要驗證 Email 格式，因為：
 
    - Firebase 本身會檢查 Email 是否有效，不需要額外處理格式驗證。
    - 主要關注點應該是使用者是否有輸入 Email，而不是格式。
    - 即使 Email 格式錯誤，Firebase 會回傳 `invalidEmailFormat` 錯誤，並交由 `EmailAuthError` 統一處理。

 - 作法：
 
    - 只檢查 Email 是否輸入 (`!email.isEmpty`)，避免無效請求。
    - 讓 Firebase 處理 Email 格式錯誤，透過 `EmailAuthError` 轉換錯誤訊息。

 ---

 2.是否應該調用 `SignUpValidationManager.validateEmailFormat`？
 
 - 不使用 `SignUpValidationManager.validateEmailFormat(email)`，因為：
 
    - `validateEmailFormat` 是為 **註冊** 設計的，而非忘記密碼流程。
    - 這樣做反而會與 Firebase **重複驗證**，造成不必要的邏輯。
    - **Firebase 會回傳 `invalidEmailFormat`，可以透過 `EmailAuthError` 處理。**

 ---------

 `* How`
 
 1. 原本的驗證方式
 
     ```swift
     // 檢查是否輸入信箱
     guard !email.isEmpty else {
         AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件", inViewController: self)
         return
     }

     // 使用 SignUpValidationManager 驗證 Email 格式
     guard SignUpValidationManager.validateEmailFormat(email) else {
         AlertService.showAlert(withTitle: "錯誤", message: "請輸入有效的電子郵件地址", inViewController: self)
         return
     }
     ```
 
 - 問題點：
 
 - 這樣的驗證 **多餘且不必要**，因為：
   1. Firebase 本身會檢查 Email 格式，不需要額外驗證。
   2. 只需要確保 Email 欄位不為空。

 ---

 2. 改進後的寫法
 
 - 移除 `validateEmailFormat`，讓 Firebase 處理 Email 錯誤
 
     ```swift
     /// 處理「重置密碼」按鈕點擊事件
     func forgotPasswordDidTapResetPasswordButton() {
         dismissKeyboard()
         
         let email = forgotPasswordView.email
         
         /// 檢查是否輸入信箱
         guard !email.isEmpty else {
             AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件", inViewController: self)
             return
         }
         
         HUDManager.shared.showLoading(text: "Sending...")
         
         Task {
             do {
                 try await EmailAuthController.shared.resetPassword(forEmail: email)
                 AlertService.showAlert(
                     withTitle: "通知",
                     message: "如果您的信箱已註冊，我們將發送密碼重置郵件給您。",
                     inViewController: self
                 ) {
                     self.dismiss(animated: true, completion: nil)
                 }
             } catch let error as EmailAuthError {
                 AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
             } catch {
                 AlertService.showAlert(withTitle: "錯誤", message: "發生未知錯誤，請稍後再試。", inViewController: self)
             }
             
             HUDManager.shared.dismiss()
         }
     }
     ```
 ---

 3. Email 格式錯誤如何處理？
 
 - 當使用者輸入 **錯誤 Email 格式**（如 `test@@gmail..com`），Firebase 會回傳錯誤：
 
     ```swift
     case .invalidEmail:
         print("[EmailAuthError]: 請輸入有效的電子郵件格式。")
         return .invalidEmailFormat
     ```
 
 - 這樣就不需要在 `ForgotPasswordViewController` 手動驗證 Email 格式。

 ---------

 `* 總結`
 
 - What
 
    - `ForgotPasswordViewController` 負責處理忘記密碼流程，包含 **UI 顯示、檢查 Email 是否輸入**，以及 **透過 Firebase 進行密碼重設請求**。

 - Why
 
 - 不需要使用 `SignUpValidationManager.validateEmailFormat`，因為：
 
   - Firebase 會自動檢查 Email 格式，不需要重複驗證。
   - 只需要確保 Email 欄位不為空 (`!email.isEmpty`)，避免送出空請求。
   - 錯誤由 `EmailAuthError` 統一處理，讓程式碼更簡潔。

 - How
 
    - 只檢查 `!email.isEmpty`，避免無效請求。
    - 讓 Firebase 自行驗證 Email 格式，並透過 `EmailAuthError` 處理錯誤。
    - 移除 `SignUpValidationManager.validateEmailFormat`，減少不必要的驗證邏輯。
 */


// MARK: - (v)

import UIKit

/// `ForgotPasswordViewController`
///
/// - 負責處理忘記密碼相關的 UI 與邏輯，並與 Firebase 進行密碼重置請求。
/// - 將視圖 (`ForgotPasswordView`)、行為處理 (`ForgotPasswordActionHandler`)、
///   以及網路請求 (`EmailAuthController`) 明確分離，增強可讀性與維護性。
///
/// - 主要職責：
/// 1. UI 管理：
///    - 使用 `ForgotPasswordView` 作為主要畫面，確保視圖與邏輯分離。
///
/// 2. 處理使用者行為：
///    - 透過 `ForgotPasswordActionHandler` 處理按鈕點擊等 UI 互動邏輯。
///
/// 3.驗證輸入：
///    - 只檢查 Email 是否輸入 (`!email.isEmpty`)，避免空白請求。
///    - Email 格式錯誤交由 Firebase 處理，不需額外驗證。
///
/// 4.執行 Firebase 密碼重設請求：
///    - 透過 `EmailAuthController.resetPassword(forEmail:)` 與 Firebase 互動。
///    - 若 Email 存在，Firebase 會發送密碼重設郵件。
///
/// - 職責架構：
/// - `ForgotPasswordView`：負責 UI 顯示，不包含業務邏輯。
/// - `ForgotPasswordViewController`：管理 UI、驗證輸入、調用密碼重置 API。
/// - `ForgotPasswordActionHandler`：處理 UI 互動邏輯，如按鈕點擊事件。
/// - `EmailAuthController`：封裝 Firebase 認證邏輯，避免直接操作 Firebase。
class ForgotPasswordViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 忘記密碼話面主體，用於顯示 UI 元件
    private let forgotPasswordView = ForgotPasswordView()
    
    // MARK: - Handlers

    /// `ForgotPasswordActionHandler`
    ///
    /// - 負責處理 `ForgotPasswordView` 中按鈕的行為
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
    ///
    /// - 初始化 `SignUpActionHandler` 並設定按鈕行為
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarManager()
        setupActionHandler()
    }
    
    // MARK: - Private Methods
    
    /// 初始化並設置 `ForgotPasswordNavigationBarManager`
    ///
    /// - 通過 `ForgotPasswordNavigationBarManager` 來設置導航欄按鈕。
    private func setupNavigationBarManager() {
        navigationBarManager = ForgotPasswordNavigationBarManager(navigationItem: navigationItem, viewController: self)
        navigationBarManager?.setupCloseButton()
    }
    
    /// 初始化並設置 `ForgotPasswordActionHandler`
    ///
    /// - `ForgotPasswordActionHandler` 負責處理 `ForgotPasswordView` 中的按鈕行為
    /// - 通過設置 view 與 delegate，將 UI 行為與邏輯解耦合
    private func setupActionHandler() {
        forgotPasswordActionHandler = ForgotPasswordActionHandler(view: forgotPasswordView, delegate: self)
    }
    
    /// 統一的鍵盤收起方法
    ///
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
      ///
      /// - 驗證輸入： 確保 Email 不為空（`!email.isEmpty`）。
      /// - 調用 Firebase API： 透過 `EmailAuthController.resetPassword` 進行密碼重設。
      /// - 錯誤處理： 透過 `EmailAuthError` 統一管理錯誤，提高可讀性與維護性。
    func forgotPasswordDidTapResetPasswordButton() {
        dismissKeyboard()
        
        let email = forgotPasswordView.email
        
        /// 檢查是否輸入信箱
        guard !email.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件", inViewController: self)
            return
        }
        
        HUDManager.shared.showLoading(text: "Sending...")
        
        Task {
            do {
                // 調用 Firebase API 發送密碼重設郵件。
                try await EmailAuthController.shared.resetPassword(forEmail: email)
                
                // 成功後，顯示通知，提示使用者檢查電子郵件。
                AlertService.showAlert(withTitle: "通知", message: "如果您的信箱已註冊，我們將發送密碼重置郵件給您。", inViewController: self) {
                    self.dismiss(animated: true, completion: nil)
                }
            } catch let error as EmailAuthError {
                // 處理 Firebase 回傳的錯誤。
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            } catch {
                // 處理未知錯誤，顯示通用錯誤訊息。
                AlertService.showAlert(withTitle: "錯誤", message: "發生未知錯誤，請稍後再試。", inViewController: self)
            }
            
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Login Page Actions
    
    /// 處理「返回登入頁面」按鈕點擊事件
    ///
    /// - 功能說明：當使用者點擊「返回登入頁面」按鈕後，該方法負責將當前的忘記密碼畫面關閉，並回到登入畫面。
    ///   1. 此方法適用於 `ForgotPasswordViewController` 以 `sheetPresentationController` 的 large 形式呈現的情況。
    ///   2. 執行 `dismiss` 動畫，關閉忘記密碼頁面，讓使用者返回至 `LoginViewController` 。
    func forgotPasswordDidTapLoginPageButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
