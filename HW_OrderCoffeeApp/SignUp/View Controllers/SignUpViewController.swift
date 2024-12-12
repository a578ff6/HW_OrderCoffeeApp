//
//  SignUpViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - 關於註冊要求的想法
/**
 
 ## 關於註冊要求的想法：
 
 1. 在 SignUpViewController 中，設置全名、電子郵件和密碼，以及註冊須知。另外還有 google、apple 註冊部分
    
    * 使用 Google 或 Apple 進行註冊和登入時，通常無法直接獲取用戶的地址和電話等額外資訊。這些第三方登錄方式通常只提供用戶的基本資訊，如姓名和電子郵件。
    * 因此，採取以下做法：
        - 簡化註冊流程：在使用電子郵件註冊的部分，只要求用戶提供姓名、信箱和密碼。
        - 延遲收集詳細資訊：在用戶完成註冊或登錄後，由在「訂單視圖控制器」讓使用者填寫額外的詳細資訊（地址和電話）。
        - 藉此提高註冊率，同時確保在需要時獲取完整的用戶資訊！！
 */


// MARK: - SignUpViewController 筆記
/**
 
 ## SignUpViewController 筆記
 
` * What`
 
 - SignUpViewController 是註冊流程中的核心控制器，負責管理註冊頁面的初始化、UI 操作的配置、以及使用者的註冊動作。

 - 主要工作包括：
    1. 使用 SignUpView 作為主要的 UI 視圖，將畫面配置和控制邏輯分開。
    2. 初始化並使用 SignUpActionHandler 來處理按鈕的行為，解耦 UI 和邏輯操作。
    3. 透過實作 SignUpViewDelegate 來處理來自 SignUpView 的用戶交互事件。
 
 -------------------------------

 `* Why`
 
 - `分離 UI 與業務邏輯`：
    - 將 UI 和行為邏輯分開，可以讓代碼結構更清晰、模組化，便於維護和擴展。具體來說，SignUpView 負責處理 UI 元件顯示，而 SignUpViewController 則專注於管理用戶交互的邏輯。
 
 - `提高程式碼的可讀性與可維護性`：
    - 透過使用 SignUpActionHandler 和 SignUpViewDelegate，將不同的責任分開，有助於減少單一類別的職責過多，降低耦合度，提高程式碼的可讀性和維護性。
 
 - `簡化控制邏輯的測試`：
    - 將行為邏輯從 UI 中解耦合之後，可以更容易地對行為邏輯進行單元測試，而不需要模擬整個 UI，這使得測試過程更加輕鬆。
 
 -------------------------------

 `* How`
 
` 1.初始化 SignUpView：`

 - 在 loadView() 方法中，將 signUpView 設為主視圖，這樣所有顯示的 UI 元件都是來自 signUpView，確保控制器和畫面的職責清楚分離。
 
 `2. 設定 SignUpActionHandler：`

 - 在 viewDidLoad() 方法中，初始化 SignUpActionHandler，並通過將 SignUpView 和 SignUpViewDelegate 作為參數傳入來處理 UI 中的行為。這樣可以確保按鈕行為由 SignUpActionHandler 集中管理。
 
 `3. 設置初始狀態：`

 - 使用 `setupInitialViewState() 方法`設置初始畫面狀態，例如將「同意條款」勾選框設為禁用，以確保用戶在閱讀條款之前不能勾選。
 
 `4. 實作 SignUpViewDelegate：`

 - 使用者點擊「閱讀條款」按鈕後，開啟條款的連結，如果成功開啟，則通過 signUpView.setTermsCheckBoxEnabled(true) 啟用「同意條款」的勾選框。
 - 在用戶點擊註冊按鈕時，首先進行輸入資料的驗證（包括確認框、必填欄位、電子郵件格式、密碼格式等），驗證成功後，通過 Firebase 進行註冊操作並導航至主頁面。
 
 `5. 驗證輸入資料：`

 - 將不同的驗證邏輯拆分為多個私有方法，例如 validateTermsCheckBox()、validateRequiredFields() 等，這樣可以讓 signUpViewDidTapSignUpButton() 方法更加簡潔且易於理解。
 
 `6. 支援其他註冊方式：`

 - 實作 Google 與 Apple 的註冊邏輯，當使用者選擇使用第三方服務進行註冊時，控制器負責調用相應的第三方服務並完成註冊流程，然後導航至主頁面。
 
 -------------------------------

 `* 總結`
 
 - 這種設計方法將 UI 畫面、用戶操作邏輯、以及業務處理清晰地劃分，透過 SignUpView、SignUpActionHandler 和 SignUpViewDelegate 分別處理各自的責任。如此一來，SignUpViewController 的程式碼變得更簡潔，易於閱讀和測試，同時也有助於後續的擴展和維護。
 */


// MARK: - 註冊驗證流程的重點筆記（重要）
/**
 
 ### 註冊驗證流程的重點筆記

 `* What: 驗證流程及邏輯設計`
 
 此段驗證流程處理用戶註冊時的數據檢查，包含以下步驟：
 
 1. 一次性提取所有輸入的資料（全名、電子郵件、密碼、確認密碼）。
 2. 確認使用者已勾選「我同意條款」。
 3. 檢查輸入欄位是否為空。
 4. 驗證電子郵件格式。
 5. 驗證密碼是否符合規範。
 6. 確認密碼與確認密碼的值一致。
 7. 若驗證成功，進行用戶註冊，並導航至主頁面。

 -------------------------------

 `* Why: 調整與優化的原因`
 
 `1. 提高效率：`
    - 將所有輸入值一次性提取，避免在每個驗證步驟中反覆調用 `signUpView` 的 getter 方法，減少視圖層的交互次數，提升代碼的執行效率。

 `2. 增加代碼可讀性與維護性：`
    - 每個驗證步驟單獨進行，並使用清晰的 `guard` 和 `if` 語句，使代碼條理分明，易於閱讀和理解。
    - 提取輸入值並統一檢查，能讓驗證邏輯更為集中，便於未來的功能修改或擴展。

 `3. 錯誤提示與用戶體驗：`
    - 在每個驗證步驟中給出具體的錯誤提示，例如「請同意並閱讀註冊須知」或「請輸入有效的電子郵件地址」，提供更佳的用戶體驗。

 -------------------------------

 `* How: 驗證邏輯的實現方式`
 
 `1. 提取用戶輸入：`
    - 將 `signUpView.fullName`、`email`、`password` 等方法調用集中到方法的最初始階段，減少重複調用。

 `2. 逐步進行驗證：`
    - 使用 `guard` 語句和 `if` 語句逐一檢查輸入的值。
    - 首先檢查是否同意條款，接著驗證每個輸入欄位是否有值。
    - 依序進行郵件格式、密碼規範的驗證，最後驗證密碼是否一致。

 `3. 錯誤處理與提示：`
    - 在每個驗證失敗的情況下，使用 `AlertService.showAlert` 顯示錯誤訊息，讓用戶知道具體的問題所在。
    - 當所有驗證通過後，顯示註冊中的加載提示，並進行用戶註冊操作。

 `4. 用戶註冊與導航：`
    - 使用 `HUDManager` 顯示註冊進行中的狀態，避免用戶重複點擊。
    - 成功註冊後，使用 `FirebaseController` 獲取用戶詳細資料，並導航到主頁面。

 -------------------------------

 `* 總結`
 
 - What* 實現用戶註冊的數據驗證流程，包含多重檢查及提示。
 - Why: 提高代碼效率與可讀性，增強用戶體驗。
 - How: 使用集中提取輸入值、逐步驗證邏輯、錯誤提示及導航至主頁面的方法，實現完整的驗證和註冊流程。
 */


// MARK: - `dismissKeyboard()` 的設置筆記
/**

 ## `dismissKeyboard()` 的設置筆記

 - 雖然在有設置 IQKeyboardManager 點擊空白處收起鍵盤
 - 但是在輸入欄位的時候保持著`鍵盤呈現狀態`，這時候去點擊「註冊」、「Google」、「Apple」按鈕時，鍵盤並不會收起鍵盤，這時候會與HUD重疊。
 - 因此設置` dismissKeyboard()` 再點擊按鈕的時候就收起鍵盤。
 
` * What - 什麼是  dismissKeyboard()`
 
 - `dismissKeyboard()` 是一個用來收起鍵盤的方法，當用戶在輸入框中輸入完畢後點擊某些按鈕（如註冊或登入）時，自動隱藏鍵盤，確保頁面的整體視覺狀態乾淨整齊。
 - 在 `SignUpViewController` 中，這個方法被設置為當用戶點擊「註冊」或其他按鈕後，鍵盤會被自動收起，從而改善使用者的操作體驗。

 -------------------------------

` * Why - 為什麼需要 dismissKeyboard()`
 
 `1. 提升用戶體驗：`
 
    - 當用戶在完成表單輸入後，點擊註冊或登入按鈕時，如果鍵盤依然存在，會影響頁面的顯示和操作。
    - 隱藏鍵盤可以讓頁面變得整潔，讓用戶的注意力集中在註冊過程的其他部分，例如確認訊息或錯誤提示。

 `2. 避免鍵盤遮擋視圖：`
 
    - 若不收起鍵盤，畫面可能會被鍵盤遮擋，特別是在顯示 `HUD` 時，鍵盤可能影響到加載指示器的顯示，導致頁面操作的流暢度變差。

 `3. 提升頁面的整體性：`
 
    - 當用戶完成操作，例如點擊註冊或登入按鈕，鍵盤已經不再是所需的界面元素。
    - 通過收起鍵盤，可以讓頁面進入下一步的狀態（例如顯示成功提示或進行頁面跳轉），更符合用戶的操作邏輯。

 -------------------------------

 `* How - 如何使用 dismissKeyboard()`
 
 `1. 方法設置：`
 
    - `dismissKeyboard()` 被設置在 `SignUpViewController` 中，以集中管理所有與鍵盤有關的頁面行為。這樣能保持控制器對整體視圖的控制，符合 MVC 模式中「控制器管理頁面狀態」的原則。
    - 具體實現上，透過 `view.endEditing(true)` 來結束當前的輸入操作並收起鍵盤。
 
    ```swift
    private func dismissKeyboard() {
        view?.endEditing(true)
    }
    ```

 `2. 使用時機：`
 
    - 當用戶點擊註冊或登入等按鈕時，會在這些按鈕的事件處理方法中調用 `dismissKeyboard()`。
    - 例如：
 
    ```swift
    func signUpViewDidTapSignUpButton() {
        dismissKeyboard()  // 點擊註冊按鈕後先收起鍵盤
        // 進行其他註冊操作...
    }
    ```
 
    - 此方法可以被多次重複使用在需要收起鍵盤的地方，如點擊「Google 註冊」或「Apple 註冊」時，確保操作的統一性。

 `3. 位置設置：`
 
    - `dismissKeyboard()` 設置在 `SignUpViewController` 中，而不是 `SignUpActionHandler`，因為這樣符合控制器管理整個頁面狀態的職責，保持 `SignUpActionHandler` 專注於按鈕行為的處理，不涉及整體視圖管理的邏輯。

 -------------------------------

 `* 總結`
 
 - `dismissKeyboard()` 用於在用戶提交註冊或登入表單時隱藏鍵盤，提供乾淨的視覺效果和良好的用戶體驗。
 - 將其放置在控制器中，可以集中管理鍵盤收起的行為，讓整體頁面狀態更易於維護。
 - 它不僅提高了代碼的清晰性，也改善了用戶的交互流暢度，使應用的行為更符合用戶的操作邏輯。
 */



// MARK: - 重構職責(v)

import UIKit

/// 註冊介面：負責處理註冊相關的邏輯與畫面
/// - 主要職責包括：
///   1. 初始化並配置 `SignUpView` 作為主要的 UI 畫面。
///   2. 通過 `SignUpActionHandler` 設置各按鈕的行為，將 UI 操作與邏輯處理解耦。
///   3. 通過實現 `SignUpViewDelegate`，將使用者的操作行為進行相應的邏輯處理。
class SignUpViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 註冊畫面主體，用於顯示 UI 元件
    private let signUpView = SignUpView()
    
    // MARK: - Handlers
    
    /// `SignUpActionHandler` 負責處理 `SignUpView` 中按鈕的行為
    /// - 設定 `SignUpView` 和 `SignUpViewDelegate` 以實現事件與邏輯的分離
    private var signUpActionHandler: SignUpActionHandler?
    
    // MARK: - Lifecycle Methods
    
    /// 設置主要視圖
    override func loadView() {
        view = signUpView
    }
    
    /// 初始化畫面元件與行為處理器
    /// - 初始化 `SignUpActionHandler` 並設定按鈕行為
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionHandler()
        setupInitialViewState()
    }
    
    // MARK: - Private Methods
    
    /// 初始化並設置 `SignUpActionHandler`
    /// - `SignUpActionHandler` 負責處理 `SignUpView` 中的按鈕行為
    /// - 通過設置 view 與 delegate，將 UI 行為與邏輯解耦合，增加程式碼的模組化和可維護性
    private func setupActionHandler() {
        signUpActionHandler = SignUpActionHandler(view: signUpView, delegate: self)
    }
    
    /// 設置初始的畫面狀態
    /// 初始設置「同意條款」勾選框為禁用狀態
    private func setupInitialViewState() {
        signUpView.setTermsCheckBoxEnabled(false)
    }
    
    /// 統一的鍵盤收起方法
    /// - 收起當前視圖中活動的鍵盤
    /// - 使用於各種按鈕操作開始前，確保畫面整潔、避免鍵盤遮擋重要資訊或 HUD
    private func dismissKeyboard() {
        view?.endEditing(true)
    }
    
}


// MARK: - SignUpViewDelegate
extension SignUpViewController: SignUpViewDelegate {
    
    // MARK: - Terms & Conditions Actions
    
    /// 處理點擊「閱讀條款」按鈕的邏輯
    /// - 成功打開條款連結後啟用「確認框」
    func signUpViewDidTapTermsButton() {
        guard let url = URL(string: "https://www.starbucks.com.tw/stores/allevent/show.jspx?n=1016") else {
            print("URL 格式錯誤")
            return
        }
        
        UIApplication.shared.open(url) { [weak self] success in
            guard success else {
                print("條款頁面打開失敗")
                return
            }
            self?.signUpView.setTermsCheckBoxEnabled(true)
        }
    }
    
    /// 處理點擊「同意條款」勾選框的邏輯
    /// - 使用者尚未點擊「註冊須知連結」，不允許勾選
    /// - 切換選中狀態
    func signUpViewDidTapTermsCheckBox() {
        guard signUpView.isTermsCheckBoxEnabled else {
            signUpView.setTermsCheckBoxEnabled(false)
            return
        }
        signUpView.toggleTermsCheckBox()
    }
    
    // MARK: - Standard Login Actions
    
    /// 當使用者點擊註冊按鈕時的處理邏輯
    /// - 驗證輸入資料是否符合規範，若成功則進行註冊請求，並導向主頁面
    /// - 在註冊流程開始前先收起鍵盤，確保畫面整潔並避免影響 HUD 顯示
    func signUpViewDidTapSignUpButton() {
        dismissKeyboard()
        let fullName = signUpView.fullName
        let email = signUpView.email
        let password = signUpView.password
        let confirmPassword = signUpView.confirmPassword
        
        // 驗證輸入資料
        guard validateTermsCheckBox() &&
                validateRequiredFields(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword) &&
                validateEmailFormat(email) &&
                validatePasswordCriteria(password) &&
                validatePasswordConfirmation(password, confirmPassword) else {
            return
        }
        
        HUDManager.shared.showLoading(text: "Signing up...")
        Task {
            do {
                _ = try await EmailSignInController.shared.registerUser(withEmail: email, password: password, fullName: fullName)
                let userDetails = try await FirebaseController.shared.getCurrentUserDetails()
                NavigationHelper.navigateToMainTabBar(from: self, with: userDetails)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Helper Methods for SignUp Validation
    
    /// 驗證是否勾選了「同意條款」的勾選框
    /// - Returns: 若已勾選返回 true，否則顯示錯誤並返回 false
    private func validateTermsCheckBox() -> Bool {
        guard signUpView.isTermsCheckBoxSelected else {
            AlertService.showAlert(withTitle: "錯誤", message: "請同意並閱讀註冊須知", inViewController: self)
            return false
        }
        return true
    }
    
    /// 驗證必填欄位是否已填寫
    /// - Parameters:
    ///   - fullName: 全名
    ///   - email: 電子郵件
    ///   - password: 密碼
    ///   - confirmPassword: 確認密碼
    /// - Returns: 若所有欄位均不為空返回 true，否則顯示錯誤並返回 false
    private func validateRequiredFields(fullName: String, email: String, password: String, confirmPassword: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty, !fullName.isEmpty, !confirmPassword.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫所有資料", inViewController: self)
            return false
        }
        return true
    }
    
    /// 驗證電子郵件格式是否有效
    /// - Parameter email: 電子郵件地址
    /// - Returns: 若格式有效返回 true，否則顯示錯誤並返回 false
    private func validateEmailFormat(_ email: String) -> Bool {
        if !EmailSignInController.isEmailvalid(email) {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入有效的電子郵件地址，例如：example@example.com", inViewController: self)
            return false
        }
        return true
    }
    
    /// 驗證密碼是否符合規範
    /// - Parameter password: 密碼
    /// - Returns: 若符合規範返回 true，否則顯示錯誤並返回 false
    private func validatePasswordCriteria(_ password: String) -> Bool {
        if !EmailSignInController.isPasswordValid(password) {
            AlertService.showAlert(withTitle: "錯誤", message: "密碼需至少包含8位字符，並包括至少一個小寫字母和一個特殊字符", inViewController: self)
            return false
        }
        return true
    }
    
    /// 驗證兩次密碼輸入是否相同
    /// - Parameters:
    ///   - password: 密碼
    ///   - confirmPassword: 確認密碼
    /// - Returns: 若兩次輸入相同返回 true，否則顯示錯誤並返回 false
    private func validatePasswordConfirmation(_ password: String, _ confirmPassword: String) -> Bool {
        if password != confirmPassword {
            AlertService.showAlert(withTitle: "錯誤", message: "兩次輸入的密碼不一致", inViewController: self)
            return false
        }
        return true
    }
    
    // MARK: - Google SignUp Actions
    
    /// 當使用者點擊 Google 註冊按鈕時的處理邏輯
    /// - 使用 Google 提供的方法進行註冊，若成功則導向主頁面
    /// - 註冊過程開始前收起鍵盤，避免鍵盤遮擋 HUD
    func signUpViewDidTapGoogleSignUpButton() {
        dismissKeyboard()
        Task {
            HUDManager.shared.showLoading(text: "Logging in...")
            do {
                _ = try await GoogleSignInController.shared.signInWithGoogle(presentingViewController: self)
                let userDetails = try await FirebaseController.shared.getCurrentUserDetails()
                NavigationHelper.navigateToMainTabBar(from: self, with: userDetails)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Apple SignUp Actions
    
    /// 當使用者點擊 Apple 註冊按鈕時的處理邏輯
    /// - 使用 Apple 提供的方法進行註冊，若成功則導向主頁面
    /// - 註冊過程開始前收起鍵盤，避免鍵盤遮擋 HUD
    func signUpViewDidTapAppleSignUpButton() {
        dismissKeyboard()
        Task {
            HUDManager.shared.showLoading(text: "Logging in...")
            do {
                _ = try await AppleSignInController.shared.signInWithApple(presentingViewController: self)
                let userDetails = try await FirebaseController.shared.getCurrentUserDetails()
                NavigationHelper.navigateToMainTabBar(from: self, with: userDetails)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
}
