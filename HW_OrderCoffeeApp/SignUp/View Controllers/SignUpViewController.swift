//
//  SignUpViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - 關於註冊要求的想法
/**
 
 ## 關於註冊要求的想法：
 
 1. 在 `SignUpViewController` 中，設置全名、電子郵件和密碼，以及註冊須知。另外還有 google、apple 註冊部分
    
 - 使用 Google 或 Apple 進行註冊和登入時，通常無法直接獲取用戶的地址和電話等額外資訊。這些第三方登錄方式通常只提供用戶的基本資訊，如姓名和電子郵件。
 
 - 因此，採取以下做法：
 
    - 簡化註冊流程：在使用電子郵件註冊的部分，只要求用戶提供姓名、信箱和密碼。
    - 延遲收集詳細資訊：在用戶完成註冊或登錄後，由在「訂單視圖控制器」讓使用者填寫額外的詳細資訊（地址和電話）。
    - 藉此提高註冊率，同時確保在需要時獲取完整的用戶資訊！！
 */


// MARK: - SignUpViewController 筆記
/**
 
 ### SignUpViewController 筆記


 `* What`
 
 `SignUpViewController` 負責 **管理註冊流程**，包括：
 
 1. 顯示 UI
 
    - 採用 `SignUpView` 作為畫面主體，確保視圖與控制器分離。
    
 2. 處理使用者輸入
 
    - 透過 `SignUpValidationManager` 驗證輸入是否合法（Email 格式、密碼規範、勾選同意條款等）。
    
 3. 處理使用者行為
 
    - 透過 `SignUpActionHandler` 管理 `SignUpView` 中按鈕的點擊行為。
    
 4. 呼叫 Firebase 註冊 API
 
    - 透過 `EmailAuthController` 與 Firebase 進行註冊，成功後導向主畫面。

 -  主要組件：
 
    - `SignUpView`：**視圖層**，只負責 UI 顯示，不包含業務邏輯。
    - `SignUpViewController`：**控制器層**，負責 UI 管理、輸入驗證、註冊 API 呼叫。
    - `SignUpValidationManager`：**驗證層**，負責檢查輸入資料是否符合規則。
    - `SignUpActionHandler`：**行為處理層**，處理 `SignUpView` 的按鈕操作。

 ---------

 `* Why`
 
 1. 解耦 UI、業務邏輯與驗證
 
 - 如果 `SignUpViewController` 直接處理驗證與註冊 API 呼叫，會導致：

    - 可讀性下降：驗證、業務邏輯與 UI 操作混雜，難以維護。
    - 重複性高：如果其他頁面（如 `ForgotPasswordViewController`）也需要驗證，則必須重寫相同邏輯。
    - 單一職責違反（SRP）：控制器負責過多職責，導致耦合性增加。

 - 最佳解法
 
    - UI 行為 交由 `SignUpActionHandler` 管理。
    - 驗證邏輯 交由 `SignUpValidationManager` 處理。
    - Firebase API 操作 交由 `EmailAuthController` 負責。

 - 這樣 `SignUpViewController` **只專注於 UI 狀態管理與流程控制**，提高程式碼的 **可維護性、可讀性與模組化設計**。

 ---

 2. 提升使用者體驗
 
 - 透過 **本地端驗證** (`SignUpValidationManager`) 提供即時反饋，避免：
 
    - 等待 Firebase 回應 才顯示錯誤。
    - 不必要的 API 請求，減少網路流量。

 - 此外，透過 **HUD 加載動畫 (`HUDManager`)**，可避免使用者頻繁點擊註冊按鈕造成多次請求。

 ---

 3. 更好的測試性與可擴展性
 
    - 驗證邏輯 可以獨立測試 (`SignUpValidationManager` 可寫單元測試)。
    - 行為處理器 (`SignUpActionHandler`) 可以根據不同 UI 元件獨立測試，不影響 `SignUpViewController` 。
    - Firebase API (`EmailAuthController`) 可以模擬不同的錯誤回應，提高測試覆蓋率。

 ---------

 `* How`
 
 1. UI 初始化
 
    - 在 `loadView()` 中，將 `SignUpView` 設為畫面主體，確保 UI 和 `UIViewController` 分離。

     ```swift
     override func loadView() {
         view = signUpView
     }
     ```

    - 初始化 UI 狀態**（例如禁用「同意條款」按鈕）：
 
     ```swift
     private func setupInitialViewState() {
         signUpView.setTermsCheckBoxEnabled(false)
     }
     ```

 ---

 2.設置 `SignUpActionHandler` 處理按鈕行為
 
    - 使用 `SignUpActionHandler` 來管理 UI 互動行為：

     ```swift
     private func setupActionHandler() {
         signUpActionHandler = SignUpActionHandler(view: signUpView, delegate: self)
     }
     ```

    - 這樣 `SignUpViewController` **不需要直接處理 UI 事件**，而是透過 `SignUpViewDelegate` 回應 `SignUpActionHandler` 的行為。

 ---

 3. 處理註冊流程
 
 - 當使用者點擊「註冊」按鈕：
 
    1. 先收起鍵盤，確保 UI 乾淨。
    2. 透過 `SignUpValidationManager` **本地驗證輸入**。
    3. 驗證成功後，調用 `EmailAuthController` 註冊 Firebase。
    4. 註冊成功後，導航至主頁 (`MainTabBar`)。

     ```swift
     func signUpViewDidTapSignUpButton() {
         dismissKeyboard()
         
         let fullName = signUpView.fullName
         let email = signUpView.email
         let password = signUpView.password
         let confirmPassword = signUpView.confirmPassword
         let isChecked = signUpView.isTermsCheckBoxSelected
         
         // 進行輸入驗證
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
         
         // 透過 Firebase 註冊
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

 ---

 4. Google / Apple 註冊流程
 
 除了 Email 註冊，也支援 Google、Apple 登入：
 
     - Google 註冊
     
     ```swift
     func signUpViewDidTapGoogleSignUpButton() {
         dismissKeyboard()
         Task {
             HUDManager.shared.showLoading(text: "Signing up...")
             do {
                 _ = try await GoogleSignInController.shared.signInWithGoogle(presentingViewController: self)
                 NavigationHelper.navigateToMainTabBar()
             } catch {
                 handleGoogleSignInError(error)
             }
             HUDManager.shared.dismiss()
         }
     }
     ```

 ---
 
     - Apple 註冊
     
     ```swift
     func signUpViewDidTapAppleSignUpButton() {
         dismissKeyboard()
         Task {
             HUDManager.shared.showLoading(text: "Signing up...")
             do {
                 _ = try await AppleSignInController.shared.signInWithApple(presentingViewController: self)
                 NavigationHelper.navigateToMainTabBar()
             } catch {
                 handleAppleSignInError(error)
             }
             HUDManager.shared.dismiss()
         }
     }
     ```

 ---------

 `* 總結`
 
 - What
 
    - `SignUpViewController` 負責 UI 顯示、輸入驗證、註冊請求，但不直接處理業務邏輯與驗證。
    - 而是交由 `SignUpValidationManager` 和 `EmailAuthController` 處理。

 -  Why
 
    - 符合單一職責原則（SRP），不讓 `ViewController` 過於臃腫。
    - 解耦 UI、驗證與 Firebase API，提高可維護性與測試性。
    - 提供即時輸入驗證，提升使用者體驗並減少不必要的 API 呼叫。

 - How
 
    - 透過 `SignUpValidationManager` 驗證輸入，確保格式正確。
    - 透過 `EmailAuthController` 註冊 Firebase，確保 `ViewController` 不直接操作 Firebase API。
    - 透過 `SignUpActionHandler` 管理 UI 行為，提高模組化設計。
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
    - 成功註冊後，使用 `EmailAuthController` 獲取用戶詳細資料，並導航到主頁面。

 -------------------------------

 `* 總結`
 
 - What： 實現用戶註冊的數據驗證流程，包含多重檢查及提示。
 - Why：提高代碼效率與可讀性，增強用戶體驗。
 - How：使用集中提取輸入值、逐步驗證邏輯、錯誤提示及導航至主頁面的方法，實現完整的驗證和註冊流程。
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


// MARK: - (v)

import UIKit

/// `SignUpViewController`
///
/// - 負責管理註冊流程，包括 UI 顯示、使用者輸入處理、驗證邏輯、認證請求等。
/// - 採用 `SignUpView` 作為 UI，並透過 `SignUpActionHandler` 來處理使用者行為，確保**UI 和業務邏輯解耦**。
///
/// ## 主要功能
/// 1. 初始化 UI
///    - 設置 `SignUpView` 作為主要畫面，並管理其 UI 狀態（如啟用/禁用「同意條款」按鈕）。
///
/// 2. 驗證使用者輸入
///    - 透過 `SignUpValidationManager` 進行輸入檢查，確保格式正確並符合密碼規範。
///
/// 3. 處理使用者行為
///    - 透過 `SignUpActionHandler` 處理 `SignUpView` 按鈕的點擊行為，並透過 `SignUpViewDelegate` 讓 `SignUpViewController` 負責應對使用者操作。
///
/// 4. 進行註冊請求
///    - 若驗證成功，則調用 `EmailAuthController` 完成 Firebase 註冊並導航至主畫面。
///
/// ## 職責架構
/// - SignUpView ：負責 UI 顯示，不包含業務邏輯
/// - SignUpViewController：負責管理 UI、驗證輸入、呼叫註冊 API
/// - SignUpValidationManager：負責驗證邏輯，確保輸入資料符合要求
/// - SignUpActionHandler：負責處理 `SignUpView` 的按鈕行為
class SignUpViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 註冊畫面主體，用於顯示 UI 元件
    private let signUpView = SignUpView()
    
    // MARK: - Handlers
    
    /// `SignUpActionHandler` 負責處理 `SignUpView` 中按鈕的行為
    ///
    /// - 設定 `SignUpView` 和 `SignUpViewDelegate` 以實現事件與邏輯的分離
    private var signUpActionHandler: SignUpActionHandler?
    
    // MARK: - Lifecycle Methods
    
    /// 設置主要視圖
    override func loadView() {
        view = signUpView
    }
    
    /// 初始化畫面元件與行為處理器
    ///
    /// - 設定 `SignUpActionHandler` 負責按鈕行為
    /// - 設定 `signUpView` 的初始 UI 狀態
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionHandler()
        setupInitialViewState()
    }
    
    // MARK: - Private Methods
    
    /// 初始化並設置 `SignUpActionHandler`
    ///
    /// - `SignUpActionHandler` 負責處理 `SignUpView` 中的按鈕行為
    /// - 通過設置 view 與 delegate，將 UI 行為與邏輯解耦合，增加程式碼的模組化和可維護性
    private func setupActionHandler() {
        signUpActionHandler = SignUpActionHandler(view: signUpView, delegate: self)
    }
    
    /// 設置初始的畫面狀態
    ///
    /// 初始設置「同意條款」勾選框為禁用狀態
    private func setupInitialViewState() {
        signUpView.setTermsCheckBoxEnabled(false)
    }
    
    /// 統一的鍵盤收起方法
    ///
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
    ///
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
    ///
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
    
    /// 當使用者點擊「註冊」按鈕時執行的邏輯
    ///
    /// - 依序執行驗證邏輯，確保資料符合規範
    /// - 若驗證成功則呼叫 `EmailAuthController` 進行註冊
    /// - 在註冊流程開始前先收起鍵盤，確保畫面整潔並避免影響 HUD 顯示
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
    
    
    // MARK: - Google SignUp Actions
    
    /// 當使用者點擊 Google 註冊按鈕時的處理邏輯
    ///
    /// - 流程:
    ///   1. 收起鍵盤，確保 UI 整潔
    ///   2. 顯示 HUD (載入動畫)，提供使用者即時反饋
    ///   3. 調用 `GoogleSignInController.shared.signInWithGoogle` 進行 Google 註冊流程
    ///   4. 若註冊成功，則導向主頁 (`MainTabBar`)
    ///   5. 若註冊失敗，則統一交給 `handleGoogleSignInError` 處理錯誤
    ///
    /// - 錯誤處理:
    ///   - 若為 `GoogleSignInError`，調用 `handleGoogleSignInError` 統一處理
    ///   - 其他錯誤則顯示通用錯誤訊息
    func signUpViewDidTapGoogleSignUpButton() {
        dismissKeyboard()
        Task {
            HUDManager.shared.showLoading(text: "Signing up...")
            do {
                _ = try await GoogleSignInController.shared.signInWithGoogle(presentingViewController: self)
                NavigationHelper.navigateToMainTabBar()
            } catch {
                handleGoogleSignInError(error)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    /// Google 登入錯誤處理
    ///
    /// - 依照錯誤類型決定應對策略:
    ///   - `userCancelled`: 使用者主動取消登入，不需提示錯誤
    ///   - `accessDenied`: 使用者拒絕授權，也不需彈出錯誤訊息
    ///   - 其他錯誤: 顯示適當錯誤訊息，提示使用者
    ///
    /// - 設計考量:
    ///   - 避免彈出多餘的錯誤警告，減少使用者困擾
    ///
    /// - 參數:
    ///   - `error`: 錯誤資訊，可能是 `GoogleSignInError` 或其他 `Error`
    private func handleGoogleSignInError(_ error: Error) {
        if let googleError = error as? GoogleSignInError {
            switch googleError {
            case .userCancelled, .accessDenied:
                print("[SignUpViewController]: 使用者取消或拒絕授權 Google 註冊，無需顯示錯誤訊息。")
                return
            default:
                AlertService.showAlert(withTitle: "錯誤", message: googleError.localizedDescription ?? "發生未知錯誤", inViewController: self)
            }
        } else {
            // 統一處理所有非 GoogleSignInError 的錯誤
            AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
        }
    }
    
    // MARK: - Apple SignUp Actions
    
    /// 當使用者點擊 Apple 註冊按鈕時的處理邏輯
    ///
    /// - 流程:
    ///   1. 收起鍵盤，確保 UI 整潔
    ///   2. 顯示 HUD (載入動畫)，提供使用者即時反饋
    ///   3. 調用 `AppleSignInController.shared.signInWithApple` 進行 Apple 註冊流程
    ///   4. 若註冊成功，則導向主頁 (`MainTabBar`)
    ///   5. 若註冊失敗，則統一交給 `handleAppleSignInError` 處理錯誤
    ///
    /// - 錯誤處理:
    ///   - 若為 `AppleSignInError`，調用 `handleAppleSignInError` 統一處理
    ///   - 其他錯誤則顯示通用錯誤訊息
    func signUpViewDidTapAppleSignUpButton() {
        dismissKeyboard()
        Task {
            HUDManager.shared.showLoading(text: "Signing up...")
            do {
                _ = try await AppleSignInController.shared.signInWithApple(presentingViewController: self)
                NavigationHelper.navigateToMainTabBar()
            } catch {
                handleAppleSignInError(error)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    /// Apple 登入錯誤處理
    ///
    /// - 依照錯誤類型決定應對策略:
    ///   - `userCancelled`: 使用者主動取消登入，不需提示錯誤
    ///   - `appleIDNotSignedIn`:未登入 Apple ID，無需顯示錯誤訊息
    ///   - 其他錯誤: 顯示適當錯誤訊息，提示使用者
    ///
    /// - 設計考量:
    ///   - 避免彈出多餘的錯誤警告，減少使用者困擾
    ///
    /// - 參數:
    ///   - `error`: 錯誤資訊，可能是 `AppleSignInError` 或一般 `Error`
    private func handleAppleSignInError(_ error: Error) {
        if let appleError = error as? AppleSignInError {
            switch appleError {
            case .userCancelled, .appleIDNotSignedIn:
                print("[LoginViewController]: 使用者取消或未登入 Apple ID，無需顯示錯誤訊息。")
                return
            default:
                AlertService.showAlert(withTitle: "錯誤", message: appleError.localizedDescription ?? "發生未知錯誤", inViewController: self)
            }
        } else {
            // 處理一般錯誤
            AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
        }
    }
    
}
