//
//  SignUpValidationManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/2/5.
//

// MARK: - SignUpValidationManager 筆記
/**
 
 ### SignUpValidationManager 筆記


 `* What`
 
 `SignUpValidationManager` 是一個 **註冊驗證管理器**，專門用來檢查使用者輸入的資料是否符合註冊規範，例如：
 
    - 是否填寫所有必填欄位
    - 電子郵件格式是否正確
    - 密碼是否符合規則（長度、特殊字符等）
    - 密碼與確認密碼是否一致
    - 是否勾選「同意條款」

 - 特性
 
    - 所有方法皆為 `static`，不需要建立實例即可直接使用。
    - 符合單一職責原則（SRP），確保 `SignUpViewController` 不直接處理驗證，而是專注於 UI 與流程控制。

 ----------

 `* Why`
 
 1. 將驗證邏輯與 UI 分離
 
 - 如果 `SignUpViewController` 直接負責驗證，會導致：
 
    - 可讀性下降：混雜 UI 操作與驗證邏輯，使程式碼難以維護。
    - 重複性高：如果其他地方也需要驗證邏輯（如重設密碼），則需要重寫相同的邏輯。

 - 將驗證邏輯抽離到 `SignUpValidationManager` 可帶來 **更好的結構性**：
 
    - `SignUpViewController` 只需關注 UI 顯示與 Firebase 註冊流程。
    - `SignUpValidationManager` 集中處理驗證邏輯，可在不同地方重複使用。

 ---

 2. 提供`即時本地端驗證`，提升使用者體驗
 
    - 若直接將輸入傳送至 Firebase 驗證，會有 **網路延遲** 問題，使用者需要等待回應。
    - 透過 `SignUpValidationManager` **本地驗證**，可以即時回饋錯誤訊息，避免無謂的 API 呼叫，提升流暢度。

 ---

 3. 符合 iOS 架構與單一職責原則（SRP）
 
    - `SignUpViewController` 只負責 **UI 操作與流程控制**。
    - `SignUpValidationManager` 只負責 **驗證邏輯**。
    - `EmailAuthController` 負責 **Firebase 驗證與 API 呼叫**。

 - 這樣的分工能讓系統 **模組化**，確保每個類別都專注於單一功能，讓維護更容易。

 ----------

 `* How`
 
 1. 基本驗證方法
 
    - `validateTermsCheckBox`：檢查是否勾選「同意條款」
    - `validateRequiredFields`：檢查所有欄位是否填寫
    - `validateEmailFormat`：檢查 email 格式是否正確
    - `validatePasswordCriteria`：檢查密碼是否符合規範
    - `validatePasswordConfirmation`：確認密碼是否一致

 ---

 2. 統一驗證入口
 
 - 提供一個 `validateSignUpInput` 方法，將所有驗證合併，若驗證失敗則回傳對應的錯誤訊息。

 ```swift
 static func validateSignUpInput(fullName: String, email: String, password: String, confirmPassword: String, isChecked: Bool) -> String? {
 }
 ```

 ---

 3. 在 `SignUpViewController` 使用
 
 - 當使用者點擊註冊時，呼叫 `SignUpValidationManager.validateSignUpInput()` 進行驗證。

 ```swift
 func signUpViewDidTapSignUpButton() {
     dismissKeyboard()
     
     let fullName = signUpView.fullName
     let email = signUpView.email
     let password = signUpView.password
     let confirmPassword = signUpView.confirmPassword
     let isChecked = signUpView.isTermsCheckBoxSelected
     
     /// 使用 `SignUpValidationManager` 進行驗證
     if let validationError = SignUpValidationManager.validateSignUpInput(
         fullName: fullName,
         email: email,
         password: password,
         confirmPassword: confirmPassword,
         isChecked: isChecked
     ) {
         AlertService.showAlert(withTitle: "錯誤", message: validationError, inViewController: self)
         return
     }
     
     /// 通過驗證後執行 Firebase 註冊
     HUDManager.shared.showLoading(text: "Signing up...")
     Task {
         do {
             _ = try await EmailAuthController.shared.registerUser(withEmail: email, password: password, fullName: fullName)
             NavigationHelper.navigateToMainTabBar()
         } catch let error as EmailAuthError {
             AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
         } catch {
             AlertService.showAlert(withTitle: "錯誤", message: "發生未知錯誤，請稍後再試。", inViewController: self)
         }
         HUDManager.shared.dismiss()
     }
 }
 ```

 ----------

 `* 總結`
 
 - What
 
    - `SignUpValidationManager` 是一個負責驗證註冊輸入的類別，確保輸入符合規範。

 - Why
 
    - 分離 UI 和驗證邏輯，符合單一職責原則（SRP）。
    - 提供即時驗證，避免不必要的 Firebase API 請求，提升使用者體驗。
    - 保持系統模組化，提高可維護性。

 - How
 
    - 提供 `static` 方法來驗證必填欄位、email 格式、密碼規則等。
    - 在 `SignUpViewController` 中調用 `SignUpValidationManager` 進行驗證，並在 UI 層顯示錯誤訊息。
 */


// MARK: - SignUpValidationManager 與 EmailAuthController 責任劃分筆記
/**
 
 
 ## SignUpValidationManager 與 EmailAuthController 責任劃分筆記

 - 原本在 EmailAuthController 設置「驗證電子郵件格式」、「驗證密碼規範」，但這部分是屬於前段的範疇，而不是firebase後端的處理驗證。
 - 因此將其調整到 `SignUpValidationManager`。
 
 `* What：`
 
 - 在 `SignUpValidationManager` 和 `EmailAuthController` 之間，`validateEmailFormat` 和 `validatePasswordCriteria` 是否應該使用 `EmailAuthController`？
 - 或者應該讓 `SignUpValidationManager` 自己設置驗證邏輯？
 - 此外，`EmailAuthController` 中的 `isEmailvalid` 和 `isPasswordValid` 方法是否還應該存在？

 -----------
 
 `* Why：`
 
 1. 職責劃分 (Separation of Concerns, SoC)
 
    - `SignUpValidationManager` 負責 UI 層的輸入驗證（格式檢查，如 email 格式、密碼規則）。
    - `EmailAuthController` 負責 Firebase 相關的帳號管理（登入、註冊、密碼重設）。
    - 這兩者的關注點不同，應該分開處理。

 2. 降低 Firebase 依賴，讓驗證邏輯更獨立
 
    - Email 格式和密碼強度檢查 **與 Firebase 無關**，應該由 UI 層的驗證管理來負責。
    - 若 `validateEmailFormat` 依賴 `EmailAuthController`，則 UI 層會變得耦合 Firebase，這不符合單一職責原則 (SRP)。

 3. 提高可維護性和測試性
 
    - `SignUpValidationManager` 是一個 **純 Swift 類別**，不依賴 Firebase，可以獨立測試。
    - 若未來更改驗證邏輯（例如密碼需要至少 10 位數），只需修改 `SignUpValidationManager`，不影響 Firebase 相關邏輯。
    - `ForgotPasswordViewController` 也可能需要 Email 格式檢查，因此應該讓 `SignUpValidationManager` 提供驗證功能，而不是讓 `EmailAuthController` 負責這部分。

 -----------

 `* How：`
 
 1. 讓 `SignUpValidationManager` 完全負責輸入格式驗證
 
    - 移除 `EmailAuthController` 的 `isEmailvalid` 和 `isPasswordValid`。
    - 在 `SignUpValidationManager` 內部定義 `validateEmailFormat` 和 `validatePasswordCriteria`，確保其獨立性。

 ---
 
 2. `SignUpValidationManager` 的實作應該如下：
 
     ```swift
     class SignUpValidationManager {
         
         /// 驗證電子郵件格式是否有效
         static func validateEmailFormat(_ email: String) -> Bool {
             let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
             let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
             return emailTest.evaluate(with: email)
         }
         
         /// 驗證密碼是否符合規範
         static func validatePasswordCriteria(_ password: String) -> Bool {
             let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
             let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
             return passwordTest.evaluate(with: password)
         }
     }
     ```

 ---

 3. `EmailAuthController` 只專注於 Firebase 帳戶管理
 
     ```swift
     class EmailAuthController {
         static let shared = EmailAuthController()
         
         func registerUser(withEmail email: String, password: String, fullName: String) async throws -> AuthDataResult {
             return try await Auth.auth().createUser(withEmail: email, password: password)
         }
     }
     ```

 -----------

 `* 結論`
 
 1. 刪除 `EmailAuthController` 的 `isEmailvalid` 和 `isPasswordValid`，讓 `SignUpValidationManager` 負責格式驗證。
 2. 保持 `EmailAuthController` 負責 Firebase 帳戶管理，不與 UI 層耦合。
 3. 提高測試性，讓 `SignUpValidationManager` 獨立於 Firebase，方便未來變更驗證規則。

 */


// MARK: - SignUpValidationManager 與 SignUpViewController 的架構
/**
 
 ### SignUpValidationManager 與 SignUpViewController 的架構
 
 - 因為最一開始是採用Firebase驗證，結果需要等待後端的回覆，相對沒那麼直觀。
 
 `* What`
 
 - `SignUpValidationManager` 是負責處理使用者註冊時的輸入驗證。
 -  `SignUpViewController` 則是管理 UI 顯示、處理使用者輸入及呼叫 Firebase 進行帳號註冊的控制器。

 - 目前的架構：
 
    - `SignUpValidationManager`：負責驗證註冊輸入（如 email 格式、密碼規則、確認密碼等）。
    - `SignUpViewController`：負責 UI 管理，並在註冊時呼叫 `SignUpValidationManager` 進行驗證，再調用 `EmailAuthController` 來進行 Firebase 註冊。
    - `EmailAuthController`：封裝 Firebase 註冊邏輯，確保 ViewController 不直接操作 Firebase，並使用 `EmailAuthError` 來統一錯誤處理。

 ---------

 `* Why`
 
 - 這種設計符合 單一職責原則（SRP），提升可讀性與可維護性：
 
 1. 驗證與業務邏輯解耦：
 
    - `SignUpValidationManager` 負責驗證，`SignUpViewController` 只需判斷是否通過驗證，避免 UI 層過度負責驗證邏輯。
 
 2. 避免 UI 直接與 Firebase 交互：
 
    - 透過 `EmailAuthController` 封裝 Firebase API，確保 ViewController 不直接操作 Firebase，讓 API 更容易替換或擴充。
 
 3. 錯誤統一管理：
 
    - `EmailAuthError` 將 Firebase 的錯誤轉換成可讀的錯誤訊息，避免在 UI 層直接解析 Firebase 的錯誤碼。

 ---------

 `* How`
 
 - 架構職責想法：
 
 1. 完全交給 Firebase 處理驗證（簡單直覺但失去控制）：
 
    - 直接依賴 Firebase 的錯誤機制，不使用 SignUpValidationManager，而是讓 Firebase 來檢查 email 格式、密碼規則等，然後回傳錯誤訊息。
 
    - 優點：簡化代碼，減少自訂驗證邏輯。
    - 缺點：無法客製化錯誤訊息，且 Firebase 只會在 API 呼叫後才回傳錯誤（UI 層無法在本地端立即阻止錯誤輸入）。

 ---
 
 2. 保留本地端驗證，並補充 Firebase 驗證（目前架構 + Firebase API 驗證）：
 
    - 仍然使用 SignUpValidationManager 進行基本驗證，但將某些驗證（如 email 是否已註冊）交給 Firebase 處理。
 
    - 優點：
      - 使用者輸入時即時回饋（本地驗證）。
      - Firebase 提供最終的驗證與錯誤回饋，確保資料符合安全規範。
 
    - 缺點：代碼較多，但符合 iOS 良好架構設計。

 ---

 3. 僅使用 Firebase 進行所有驗證（過度依賴後端）：
 
    - 不做任何本地端驗證，所有輸入都直接送至 Firebase，並依賴 Firebase 回傳錯誤碼來決定錯誤訊息。
 
    - 優點：簡化代碼，減少額外驗證邏輯。
 
    - 缺點：
      - 需要等待 Firebase 回應，使用者體驗較差。
      - 每次請求都可能會產生 Firebase API 調用，影響效能。

 ---------

 `* 結論：`
 
 - 目前的方式是合理的，並且可以透過方案 2 進一步優化
 
 - 目前 SignUpValidationManager、SignUpViewController、EmailAuthController 的分層設計是合理的，因為：
 
 1. 本地端驗證提升使用者體驗：先在 UI 層阻擋明顯錯誤，避免無謂的 Firebase API 呼叫。
 2. Firebase 作為最後的安全機制：避免繞過本地驗證直接送無效請求。
 3. 錯誤處理一致性：EmailAuthError 提供統一錯誤處理方式，避免直接依賴 Firebase 的錯誤代碼。

 - 若要優化，可以：
 
 - 在本地端驗證失敗時，不調用 Firebase API，減少無謂的請求。
 - 整合 Firebase 驗證錯誤，確保即使本地端驗證通過，Firebase 仍然能夠提供更進一步的檢查（如 email 是否已註冊）。

 這樣的方式可以兼顧使用者體驗、錯誤處理一致性，以及確保 Firebase 提供最終驗證！
 */


// MARK: - 前端驗證 vs 完全交給 Firebase 處理（重要）
/**
 
 `* What：`
 
 - 在註冊與登入流程中，可以選擇：
 
 1. `完全依賴 Firebase` 來驗證 Email 格式、密碼強度、帳號是否存在等。
 2. `前端先做驗證，再由 Firebase 做最後檢查`，減少 API 調用次數並提升使用者體驗。

 ---------
 
 `* Why：`
 
 1.完全交給 Firebase
 
 - 優點
 
    - 簡單直觀，所有驗證邏輯由 Firebase 負責，減少重複邏輯。
    - 確保 Email 格式、密碼強度、帳號是否存在等規則與 Firebase 一致。
    - 減少前端代碼維護成本，降低驗證規則變更的影響。

 - 缺點
 
    - 需要等待 API 回應，使用者體驗較差（例如 Email 格式錯誤時，必須等到請求返回才知道）。
    - 可能會增加 Firebase API 調用次數，導致額外的成本。

 ---
 
 2：前端先驗證 + Firebase 最終檢查（目前作法）
 
 - 優點
 
    - 提升使用者體驗：前端可以即時提供錯誤訊息，不需要等 API 回應。
    - 減少 Firebase API 調用次數：避免因為 Email 格式錯誤等基本錯誤而浪費 API 呼叫。
    - 更好的安全性：前端提供基本防護，但最終還是由 Firebase 負責驗證，確保數據正確。

 - 缺點
 
    - 需要在前端額外維護一套驗證邏輯，增加開發與維護成本。
    - 若 Firebase 驗證規則變更，前端也需要同步修改。

 ---------

 `* How：`
 
 - 混合方案：前端基本驗證 + Firebase 負責最終檢查
 
 1. 前端驗證（即時回饋）
 
    - Email 格式：使用正則表達式驗證，確保符合標準。
    - 密碼強度：至少 8 位字符，包含特殊字符與大小寫字母。
    - 必填欄位：確保使用者填寫完整資訊。
    - 立即顯示錯誤訊息，提升使用者體驗。

 2. Firebase 最終驗證（安全性保障）
 
    - 檢查 Email 是否已被註冊。
    - 確保密碼強度符合 Firebase 設定的規範。
    - 統一錯誤管理，確保 UI 層只需要處理 Firebase 返回的錯誤。

 ---------

 `* 總結`
 
 1.若要簡化開發 → 完全交給 Firebase，減少前端驗證邏輯，適合小型專案或快速開發。
 2.若要最佳使用者體驗與效能→ 前端 + Firebase 混合方案，減少 API 調用，提升即時回饋，適合需要更好 UX 的專案。

 */




// MARK: - (v)

import Foundation

/// `SignUpValidationManager` 負責處理註冊相關的輸入驗證
///
/// - 目的：確保 `SignUpViewController` 內部不直接處理驗證，符合單一職責原則 (SRP)
/// - 此類別的方法都是 `static`，可以直接調用，不需要建立實例
class SignUpValidationManager {
    
    /// 驗證是否勾選「同意條款」
    ///
    /// - Parameter isChecked: 勾選框是否被選中
    /// - Returns: `true` 代表已勾選，`false` 代表未勾選
    static func validateTermsCheckBox(isChecked: Bool) -> Bool {
        return isChecked
    }
    
    /// 驗證所有必填欄位是否已填寫
    ///
    /// - Parameters:
    ///   - fullName: 全名
    ///   - email: 電子郵件
    ///   - password: 密碼
    ///   - confirmPassword: 確認密碼
    /// - Returns: 若所有欄位均不為空則返回 `true`
    static func validateRequiredFields(fullName: String, email: String, password: String, confirmPassword: String) -> Bool {
        return !fullName.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    /// 驗證電子郵件格式是否有效
    ///
    /// - Parameter email: 電子郵件地址
    /// - Returns: 若格式有效返回 `true`
    static func validateEmailFormat(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    /// 驗證密碼是否符合規範
    ///
    /// - Parameter password: 密碼
    /// - Returns: 若符合規範返回 `true`
    static func validatePasswordCriteria(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    /// 驗證密碼與確認密碼是否一致
    ///
    /// - Parameters:
    ///   - password: 密碼
    ///   - confirmPassword: 確認密碼
    /// - Returns: 若兩次輸入相同返回 `true`
    static func validatePasswordConfirmation(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
    
    /// 驗證註冊輸入是否符合所有規則
    ///
    /// - 驗證項目
    ///   1. 必填欄位
    ///   2. Email 格式
    ///   3. 密碼規則
    ///   4. 密碼確認
    ///   5. 是否勾選「同意條款」
    /// - 回傳：檢查失敗時，回傳對應錯誤訊息
    ///
    /// - Parameters:
    ///   - fullName: 使用者姓名
    ///   - email: 使用者 Email
    ///   - password: 使用者密碼
    ///   - confirmPassword: 確認密碼
    ///   - isChecked: 是否勾選同意條款
    /// - Returns: 若符合所有規則則回傳 `nil`，否則回傳對應的錯誤訊息
    static func validateSignUpInput(fullName: String, email: String, password: String, confirmPassword: String, isChecked: Bool) -> String? {
        
        guard validateTermsCheckBox(isChecked: isChecked) else {
            return "請同意並閱讀註冊須知"
        }
        
        guard validateRequiredFields(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword) else {
            return "請填寫所有資料"
        }
        
        guard validateEmailFormat(email) else {
            return "請輸入有效的電子郵件地址，例如：example@example.com"
        }
        
        guard validatePasswordCriteria(password) else {
            return "密碼需至少包含 8 位字符，並包括至少一個小寫字母和一個特殊字符"
        }
        
        guard validatePasswordConfirmation(password, confirmPassword) else {
            return "兩次輸入的密碼不一致"
        }
        
        return nil  // 代表驗證成功
    }
    
}
