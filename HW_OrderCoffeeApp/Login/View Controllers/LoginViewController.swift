//
//  LoginViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//


// MARK: - LoginViewController 重點筆記
/**
 
 ## LoginViewController 重點筆記

 `* What - 什麼是 LoginViewController`

 - `LoginViewController` 是負責處理登入頁面邏輯和畫面的主控制器。
 
 - `主要職責包括`：
 
   1. 初始化並配置 `LoginView` 作為主 UI 畫面，負責顯示各種登入相關的元件。
   2. 使用 `LoginActionHandler` 設定按鈕的行為，將 UI 操作和邏輯處理進行解耦。
   3. 通過實現 `LoginViewDelegate`，處理使用者的操作行為，例如登入、註冊、忘記密碼等操作。

 ----------------------------------------------

 `* Why - 為什麼設計 LoginViewController`

 - `簡化主控制器邏輯`：
 
   - 使用 `LoginView` 來集中管理 UI 元件的呈現，讓 `LoginViewController` 的角色專注於處理使用者的交互邏輯，這樣可以避免大量視圖配置代碼在控制器中，使控制器保持精簡。
   
 - `解耦 UI 和邏輯`：
 
   - 通過 `LoginActionHandler` 來設置按鈕行為，並且利用 `LoginViewDelegate` 來進行邏輯處理，這樣可以有效解耦視圖層和業務邏輯層，提升代碼的可讀性和可維護性。
   
 - `優化用戶體驗`：
 
   - 提供「記住我」功能，讓用戶可以選擇保存登入資訊，避免重複輸入帳號密碼，提升登入體驗。

 ----------------------------------------------

 `* How - 如何使用 LoginViewController`

 `1. 初始化與配置視圖：`
 
    - 在 `loadView()` 方法中，將 `loginView` 設置為主視圖。
    - 在 `viewDidLoad()` 中，透過 `LoginActionHandler` 設置按鈕行為，並嘗試加載用戶的登入資訊。

 `2. 加載用戶資訊：`
 
    - 使用 `loadRememberedUser()` 方法，從 UserDefaults 檢查是否有「記住我」選項，如果有，從 Keychain 加載用戶的電子郵件和密碼，並填入 `loginView`。

 `3. 使用 LoginViewDelegate 處理使用者交互：`
 
    - `登入按鈕`：檢查電子郵件和密碼是否輸入，使用 Firebase Auth 進行登入，成功後進入主頁面。
    - `Google 和 Apple 登入`：通過 Google 或 Apple 提供的方法進行登入，成功後跳轉到主頁面。
    - `忘記密碼與註冊`：使用 `NavigationHelper` 進行頁面跳轉。
    - `記住我按鈕`：根據使用者選擇保存或刪除電子郵件和密碼。

 `4. 「記住我」功能：`
 
    - 當使用者勾選「記住我」時，透過 `KeychainManager` 保存用戶的電子郵件和密碼，並更新 UserDefaults 狀態。
    - 如果取消勾選「記住我」，則刪除保存的用戶資訊，並更新狀態。

 ----------------------------------------------

 `* 職責劃分明確`

 - `LoginView 負責 UI 呈現`：
 
   - `LoginView` 包含所有登入相關的視圖元件，統一管理 UI 佈局，並簡化主控制器的視圖配置代碼。

 - `LoginActionHandler 處理按鈕行為`：
 
   - `LoginActionHandler` 為 `LoginView` 的按鈕配置具體的交互行為，保持視圖邏輯與控制器邏輯的分離。

 - `LoginViewDelegate 處理用戶行為邏輯`：
 
   - 透過實現 `LoginViewDelegate`，`LoginViewController` 可以集中處理與用戶操作有關的邏輯，例如登入操作、頁面跳轉等。

 ----------------------------------------------

 `* 程式碼結構和設計方式`

 - `設計方法`：
 
   1. `loadView()`：將 `loginView` 設為主視圖，集中管理 UI 呈現。
   2. `viewDidLoad()`：設置按鈕行為與加載用戶資料。
   3. `loadRememberedUser()`：在啟動時自動加載用戶資料，提升使用者體驗。
   4. `LoginViewDelegate` 的實現：集中處理用戶交互邏輯，如登入、註冊、忘記密碼等。

 ----------------------------------------------

 `* 總結`

 - `LoginViewController` 通過組合 `LoginView`、`LoginActionHandler` 和 `LoginViewDelegate`，有效地分離了 UI 層、按鈕行為和業務邏輯，使得代碼結構清晰、職責分離：
 
   1. `LoginView`：負責視覺層和佈局。
   2. `LoginActionHandler`：處理視圖的按鈕行為。
   3. `LoginViewDelegate`：處理具體的登入、註冊等業務邏輯。
 
 - 這樣的設計使得登入頁面更具擴展性，易於維護，也有助於提升使用者的操作體驗。
 */


// MARK: - LoginViewController 的角色和設計
/**

 ### LoginViewController 的角色和設計

 `* What: LoginViewController 的角色和設計`
 
 - `LoginViewController` 是整個登入畫面的主控制器，負責處理使用者與登入畫面的互動，並實作具體的登入邏輯。
 
 - 它主要與三個組件交互：
 
    - `LoginActionHandler`: 負責處理 `LoginView` 中按鈕的行為。
    - `LoginView`: 視圖組件，包含了所有的 UI 元件，負責顯示登入頁面。
    - `LoginViewDelegate`: 定義登入操作後的回調，用於將使用者的行為從 `LoginView` 傳遞給 `LoginViewController`，讓控制器執行具體的業務邏輯。

 ----------------------------------------
 
 `* Why: 使用 LoginActionHandler 的原因`
 
 - `解耦視圖與行為邏輯`: 為了將 `LoginView`（純 UI 部分）與使用者行為的處理邏輯（例如按下按鈕後該做什麼）解耦，避免 UI 直接與邏輯糾纏，使代碼更具模組化與可讀性。
 - `簡化 LoginViewController 的責任`: 通過 `LoginActionHandler`，將與 UI 的互動邏輯抽離出來，`LoginViewController` 僅負責控制流程及登入相關的業務邏輯，降低了控制器的複雜度。
 - `使用委託模式進行回調`: 使用 `LoginViewDelegate`，讓 `LoginActionHandler` 將處理完的使用者行為通知到 `LoginViewController`，確保處理邏輯能在控制器內進行。

 ----------------------------------------
 
 `* How: 關鍵組件及其間的關聯性`

 `1. LoginView`
 
 - `職責`: 顯示登入頁面的所有 UI 元件，如標題、輸入框、登入按鈕等。
 
 - `關聯性`:
 
   - `LoginActionHandler`: `LoginActionHandler` 透過 `getter` 方法取得 `LoginView` 的各個按鈕，然後綁定點擊事件。`LoginView` 不直接處理按鈕的點擊行為。
   - `LoginViewController`: 被 `LoginViewController` 初始化並設為主視圖。

 ---
 
 `2. LoginActionHandler`
 
 - `職責`: 設置 `LoginView` 各個按鈕的點擊行為，並處理與按鈕的互動。
 
 - `關聯性`:
 
   - `LoginView`: 在初始化時，將 `LoginView` 傳入 `LoginActionHandler` 中，並透過 getter 取得按鈕，進而設置行為。
   - `LoginViewDelegate`: `LoginActionHandler` 透過 delegate 通知 `LoginViewController` 使用者點擊了哪個按鈕。
   - `LoginViewController`: `LoginViewController` 初始化 `LoginActionHandler`，並把 `LoginView` 和 `LoginViewDelegate` 傳入。

 ---

 `3. LoginViewDelegate`
 
 - `職責`: 用於定義登入頁面上的所有互動行為的回調方法。
 
 - `關聯性`:
 
   - `LoginActionHandler`: 當按鈕被點擊時，`LoginActionHandler` 透過 `delegate` 呼叫相應的回調方法。
   - `LoginViewController`: 實作了 `LoginViewDelegate`，以便在使用者點擊按鈕時執行具體的邏輯。

 ---

 `4. LoginViewController`
 
 - `職責`: 控制整個登入頁面，負責實作登入、第三方登入、註冊跳轉等業務邏輯。
 
 - `關聯性`:
 
   - `LoginView`: 初始化並設為 `view`，用於展示 UI。
   - `LoginActionHandler`: 初始化並設置 `view` 和 `delegate`，用於處理 `LoginView` 中的按鈕行為。
   - `LoginViewDelegate`: `LoginViewController` 自身實作 `LoginViewDelegate`，接收來自 `LoginActionHandler` 的事件回調，並執行相應的業務邏輯。

 ----------------------------------------
 
` * Summary: LoginViewController 的設計關係與原因`
 
 - `模組化與責任劃分`：
 
    - `LoginViewController` 的設計將顯示邏輯（`LoginView`）、行為邏輯（`LoginActionHandler`）、事件回調（`LoginViewDelegate`）和業務邏輯（`LoginViewController` 本身）進行了清晰的模組化和責任劃分。
 
 - `高內聚、低耦合`：
 
    - `LoginView` 專注於 UI，`LoginActionHandler` 專注於使用者行為處理，`LoginViewDelegate` 用於事件的傳遞。
    - 而 `LoginViewController` 集中處理具體的業務邏輯，從而達成高內聚低耦合的效果，易於維護和擴展。
 */


// MARK: - 筆記：`loginViewDidTapRememberMeButton` 邏輯流程（重要）
/**
 
 ## 筆記：`loginViewDidTapRememberMeButton` 邏輯流程

 `* What：`
 
 - `loginViewDidTapRememberMeButton` 用於處理當使用者點擊「記住我」按鈕時的操作邏輯。
 - 根據「記住我」的狀態 (`isSelected`)，決定是否 **保存** 或 **刪除** 使用者的帳號與密碼。
 
 ------

 `* Why：`
 
 - 目的是 **提升使用者體驗**，讓已勾選「記住我」的使用者，在下次登入時自動填入帳號與密碼，無需重複輸入。
 - **確保安全性與隱私**，當使用者取消「記住我」時，會刪除已儲存的憑證，防止帳號資料留存於裝置中。
 
 ------

 `* How：`
 
 `1. 取得當前使用者的 Email 和密碼：`
 
    - 透過 `loginView.email` 和 `loginView.password` 取得使用者輸入的登入資訊。
 
 ---
 
 `2. 根據「記住我」的狀態 (`isSelected`) 進行不同處理：`
 
 - `isSelected == true`（選中「記住我」）：
 
   1. 驗證 Email 和密碼是否為有效輸入
 
      - 若 **未輸入** Email 或密碼，則：
        - 顯示警告 (`AlertService`)，提示用戶必須輸入電子郵件與密碼。
        - 取消「記住我」的選中狀態 (`setRememberMeState(false)`)。
        - `return`，避免存入無效資料。
 
   2. 存入帳號密碼
 
      - 使用 `KeychainManager` 將 Email & 密碼安全存儲。
      - 將 `UserDefaults` 設定 `RememberMe = true`，記錄使用者的選擇。
 
 ---
 
 - `isSelected == false`（取消「記住我」）：
 
   1. 刪除帳號密碼
 
      - 使用 `KeychainManager` **刪除** 先前存儲的 Email & 密碼，確保裝置中不再留存憑證。
 
   2. 更新「記住我」狀態
 
      - 將 `UserDefaults` 設為 `false`，確保使用者的選擇被記錄。
      - 將「記住我」按鈕狀態設為 `false`，避免 UI 顯示錯誤資訊。

 ------

 `* 總結：`
 
 - 「記住我」功能只有在使用者輸入有效帳號 & 密碼時才會生效，確保不會存入無效憑證。
 - 安全性考量：當使用者取消選取時，會**完全刪除**帳號與密碼，避免資料殘留。
 - 使用者體驗最佳化：允許下次登入時自動填入憑證，但確保用戶能自由開關此功能。
 */


// MARK: - `dismissKeyboard()` 的設置筆記
/**

 ## `dismissKeyboard()` 的設置筆記

 - 雖然在有設置 IQKeyboardManager 點擊空白處收起鍵盤
 - 但是在輸入欄位的時候保持著`鍵盤呈現狀態`，這時候去點擊「登入」、「Google」、「Apple」按鈕時，鍵盤並不會收起鍵盤，這時候會與HUD重疊。
 - 因此設置` dismissKeyboard()` 再點擊按鈕的時候就收起鍵盤。
 
` * What - 什麼是  dismissKeyboard()`
 
 - `dismissKeyboard()` 是一個用來收起鍵盤的方法，當用戶在輸入框中輸入完畢後點擊某些按鈕（如註冊或登入）時，自動隱藏鍵盤，確保頁面的整體視覺狀態乾淨整齊。
 - 在 `LoginViewController` 中，這個方法被設置為當用戶點擊「登入」或其他按鈕後，鍵盤會被自動收起，從而改善使用者的操作體驗。

 -------------------------------

` * Why - 為什麼需要 dismissKeyboard()`
 
 `1. 提升用戶體驗：`
 
    - 當用戶在完成表單輸入後，點擊註冊或登入按鈕時，如果鍵盤依然存在，會影響頁面的顯示和操作。
    - 隱藏鍵盤可以讓頁面變得整潔，讓用戶的注意力集中在登入過程的其他部分，例如確認訊息或錯誤提示。

 `2. 避免鍵盤遮擋視圖：`
 
    - 若不收起鍵盤，畫面可能會被鍵盤遮擋，特別是在顯示 `HUD` 時，鍵盤可能影響到加載指示器的顯示，導致頁面操作的流暢度變差。

 `3. 提升頁面的整體性：`
 
    - 當用戶完成操作，例如點擊註冊或登入按鈕，鍵盤已經不再是所需的界面元素。
    - 通過收起鍵盤，可以讓頁面進入下一步的狀態（例如顯示成功提示或進行頁面跳轉），更符合用戶的操作邏輯。

 -------------------------------

 `* How - 如何使用 dismissKeyboard()`
 
 `1. 方法設置：`
 
    - `dismissKeyboard()` 被設置在 `LoginViewController` 中，以集中管理所有與鍵盤有關的頁面行為。這樣能保持控制器對整體視圖的控制，符合 MVC 模式中「控制器管理頁面狀態」的原則。
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
    func loginViewDidTapLoginButton() {
        dismissKeyboard()  // 點擊註冊按鈕後先收起鍵盤
        // 進行其他註冊操作...
    }
    ```
 
    - 此方法可以被多次重複使用在需要收起鍵盤的地方，如點擊「Google 登入」或「Apple 登入」時，確保操作的統一性。

 `3. 位置設置：`
 
    - `dismissKeyboard()` 設置在 `LoginViewController` 中，而不是 `LoginActionHandler`，因為這樣符合控制器管理整個頁面狀態的職責，保持 `LoginActionHandler` 專注於按鈕行為的處理，不涉及整體視圖管理的邏輯。

 -------------------------------

 `* 總結`
 
 - `dismissKeyboard()` 用於在用戶提交註冊或登入表單時隱藏鍵盤，提供乾淨的視覺效果和良好的用戶體驗。
 - 將其放置在控制器中，可以集中管理鍵盤收起的行為，讓整體頁面狀態更易於維護。
 - 它不僅提高了代碼的清晰性，也改善了用戶的交互流暢度，使應用的行為更符合用戶的操作邏輯。
 */


// MARK: - 處理「Remember Me」按鈕的流程
/**
 
 ## 處理「Remember Me」按鈕的流程：
 
 - 當用戶點擊 "Remember Me" 按鈕時，會將當前的電子郵件和密碼存儲到 `Keychain` 中。
 
 `1.先檢查TextField是否有填寫：`
 
    - 原本如果用戶先點擊 "`Remember Me`" 按鈕再輸入帳號密碼，那麼之前的空數據或錯誤的數據就會被存儲。
    - 因此我後來改成：用戶點擊 "`Remember Me`" 按鈕後檢查當前的電子郵件和密碼是否已經填寫好。如果未填寫好，提示用戶先完成輸入。
 
 ---
 
 `2. Remember Me 按鈕的邏輯和 loginButtonTapped 的關聯性：`
 
    - `Remember Me` 按鈕的作用是在用戶選中時記住電子郵件和密碼，而 `loginButtonTapped` 則是在用戶點擊登錄按鈕後執行登錄操作。
 
 ---

 3.作業流程（確保這個流程的關鍵在於順序的控制和條件的檢查。）：
 
    - 用戶輸入電子郵件和密碼。
    -  用戶點擊 Remember Me 按鈕（可選）。
    -  用戶點擊 Login 按鈕，執行登錄操作。
    -  如果用戶選中了 Remember Me，則會將電子郵件和密碼存儲到 Keychain 中。
    -  在下一次 App 啟動時，如果檢測到 Remember Me 被選中，則自動填充電子郵件和密碼。
 
 */




// MARK: - (v)

import UIKit
import FirebaseAuth

/// `LoginViewController`
/// - 負責管理登入流程，包括 UI 顯示、使用者輸入處理、認證邏輯等。
/// - 採用 `LoginView` 作為 UI，並透過 `LoginActionHandler` 來處理使用者行為，確保**UI 和業務邏輯解耦**。
///
/// - 主要功能：
///   1. 初始化 `LoginView`，顯示登入頁面
///   2. 處理登入行為（Email、Google、Apple 登入）
///   3. 管理「記住我」的功能，從 `Keychain` 加載/儲存登入資訊
///
/// - 職責架構：
///   1. 初始化並配置 `LoginView` 作為主要的 UI 畫面。
///   2. 通過 `LoginActionHandler` 設置各按鈕的行為，將 UI 操作與邏輯處理解耦。
///   3. 通過實現 `LoginViewDelegate`，將使用者的操作行為進行相應的邏輯處理。
class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// `LoginView` 為登入畫面主體，用於顯示 UI 元件
    private let loginView = LoginView()
    
    // MARK: - Handlers
    
    /// `LoginActionHandler` 負責處理 `LoginView` 中按鈕的行為
    ///
    /// - 設定 `LoginView` 和 `LoginViewDelegate` 以實現事件與邏輯的分離
    private var loginActionHandler: LoginActionHandler?
    
    // MARK: - Lifecycle Methods
    
    /// 將 `loginView` 設定為主視圖
    override func loadView() {
        view = loginView
    }
    
    /// 初始化登入頁面
    ///
    /// - 設定按鈕行為 (`LoginActionHandler`)
    /// - 檢查是否需要加載記住的登入資訊
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionHandler()
        loadRememberedUser()
    }
    
    // MARK: - Action Handler
    
    /// 初始化並設置 `LoginActionHandler`
    ///
    /// - `LoginActionHandler` 負責處理 `LoginView` 中的按鈕行為
    /// - 通過設置 view 與 delegate，將 UI 行為與邏輯解耦合，增加程式碼的模組化和可維護性
    private func setupActionHandler() {
        loginActionHandler = LoginActionHandler(view: loginView, delegate: self)
    }
    
    // MARK: - Dismiss Keyboard
    
    /// 統一的鍵盤收起方法
    ///
    /// - 收起當前視圖中活動的鍵盤
    /// - 使用於各種按鈕操作開始前，確保畫面整潔、避免鍵盤遮擋重要資訊或 HUD
    private func dismissKeyboard() {
        view?.endEditing(true)
    }
    
    // MARK: - User Data Management
    
    /// 嘗試載入已記住的使用者登入資訊（若啟用了「記住我」）
    ///
    /// - 先檢查 `UserDefaults` 是否啟用了「記住我」選項
    /// - 若已啟用，則嘗試從 `Keychain` 加載電子郵件和密碼
    /// - 若成功載入，則填入 `LoginView` 的輸入框，並更新「記住我」按鈕狀態
    private func loadRememberedUser() {
        guard UserDefaults.standard.value(forKey: "RememberMe") as? Bool ?? false else { return }
        loadUserCredentials()
    }
    
    /// 從 `Keychain` 載入使用者憑證並填入登入輸入框
    ///
    /// - 功能:
    ///   1. 嘗試從 Keychain 加載已存儲的使用者帳號與密碼
    ///   2. 若成功載入，則填入 `LoginView` 的輸入框
    ///   3. 更新「記住我」的按鈕狀態，以確保 UI 與資料同步
    ///
    /// - 設計考量:
    ///   - 提高使用者體驗: 若 `Remember Me` 選項啟用，則使用者無需重新輸入帳密
    ///   - 確保安全性: 資料存儲於 `Keychain`，不會被 iOS 自動清除
    ///   - 避免 UI 失配: 只有成功載入 Keychain 資料後，才更新「記住我」按鈕狀態
    private func loadUserCredentials() {
        
        /// 嘗試從 `KeychainManager` 讀取使用者的 Email & 密碼
        guard let emailData = KeychainManager.load(key: "userEmail"),
              let passwordData = KeychainManager.load(key: "userPassword"),
              let email = String(data: emailData, encoding: .utf8),
              let password = String(data: passwordData, encoding: .utf8) else { return }
        
        /// 將讀取到的帳號與密碼填入 UI
        loginView.setEmail(email)
        loginView.setPassword(password)
        
        /// 確保「記住我」按鈕與 Keychain 資料同步
        /// - 只有成功載入 Email & 密碼後，才設定 `Remember Me` 為開啟狀態
        setRememberMeState(isSelected: true)
    }
    
}

// MARK: - LoginViewDelegate
extension LoginViewController: LoginViewDelegate {
    
    // MARK: - Standard Login Actions
    
    /// 處理使用者點擊登入按鈕的行為
    ///
    /// - 功能:
    ///   1.檢查電子郵件與密碼是否輸入
    ///   2.顯示 HUD (載入動畫)，提供即時反饋
    ///   3.透過 `EmailAuthController` 進行 Firebase 登入
    ///   4.登入成功後，導航至主頁面
    ///   5.若發生錯誤，則根據錯誤類型提供適當的錯誤提示
    ///
    /// - 錯誤處理:
    ///   - 若 `email` 或 `password` 為空，則彈出警告視窗 (`AlertService`)
    ///   - 若 `EmailAuthController` 拋出 `EmailAuthError`，則顯示對應的錯誤訊息
    ///   - 若發生未知錯誤，則顯示通用錯誤訊息
    func loginViewDidTapLoginButton() {
        dismissKeyboard()
        
        let email = loginView.email
        let password = loginView.password
        
        /// 檢查是否輸入帳號與密碼
        guard !email.isEmpty, !password.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
            return
        }
        
        HUDManager.shared.showLoading(text: "Logging in...")
        Task {
            do {
                _ = try await EmailAuthController.shared.loginUser(withEmail: email, password: password)
                NavigationHelper.navigateToMainTabBar()
            } catch let error as EmailAuthError {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: "發生未知錯誤，請稍後再試。", inViewController: self)
            }
            
            HUDManager.shared.dismiss()
        }
    }
    
    
    // MARK: - Google Login Actions
    
    /// 當使用者點擊 Google 登入按鈕時，處理登入流程
    ///
    /// - 行為:
    ///   1. 先關閉鍵盤，避免影響登入 UI 顯示
    ///   2. 顯示載入動畫（HUD），提供使用者即時反饋
    ///   3. 調用 `GoogleSignInController.shared.signInWithGoogle` 進行 Google 登入
    ///   4. 登入成功後，導向主頁面 (`MainTabBar`)
    ///   5. 若登入失敗，則根據錯誤類型進行適當處理
    ///
    /// - 錯誤處理:
    ///   - 若為 `GoogleSignInError`，調用 `handleGoogleSignInError` 統一處理
    ///   - 其他錯誤則顯示通用錯誤訊息
    func loginViewDidTapGoogleLoginButton() {
        dismissKeyboard()
        Task {
            HUDManager.shared.showLoading(text: "Logging in...")
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
                print("[LoginViewController]: 使用者取消或拒絕授權 Google 登入，無需顯示錯誤訊息。")
                return
            default:
                AlertService.showAlert(withTitle: "錯誤", message: googleError.localizedDescription ?? "發生未知錯誤", inViewController: self)
            }
        } else {
            // 處理一般錯誤
            AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
        }
    }
    
    // MARK: - Apple Login Actions
    
    /// 當使用者點擊 Apple 登入按鈕時的處理邏輯
    ///
    /// - 行為:
    ///   1. 收起鍵盤，確保 UI 整潔
    ///   2. 顯示 HUD (載入動畫)，提供使用者即時反饋
    ///   3. 調用 `AppleSignInController.shared.signInWithApple` 進行 Apple 登入
    ///   4. 若登入成功，則導向主頁 (`MainTabBar`)
    ///   5. 若登入失敗，則統一交給 `handleAppleSignInError` 處理錯誤
    ///
    /// - 錯誤處理:
    ///   - 若為 `AppleSignInError.userCancelled`，則不彈出錯誤訊息
    ///   - 其他錯誤則顯示 `AlertService`
    func loginViewDidTapAppleLoginButton() {
        dismissKeyboard()
        Task {
            HUDManager.shared.showLoading(text: "Logging in...")
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
    
    // MARK: - Navigation Actions
    
    /// 當使用者點擊忘記密碼按鈕時，跳轉到 `ForgotPasswordViewController`
    func loginViewDidTapForgotPasswordButton() {
        NavigationHelper.navigateToForgotPassword(from: self)
    }
    
    /// 當使用者點擊註冊按鈕時，跳轉到 `SignUpViewController`
    func loginViewDidTapSignUpButton() {
        NavigationHelper.navigateToSignUp(from: self)
    }
    
    // MARK: - Remember Me Functionality
    
    /// 「記住我」邏輯
    ///
    /// - 若勾選「記住我」，則儲存 Email & 密碼至 `Keychain`
    /// - 若取消勾選，則刪除 `Keychain` 中的登入資訊
    func loginViewDidTapRememberMeButton(isSelected: Bool) {
        let email = loginView.email
        let password = loginView.password
        handleRememberMe(isSelected: isSelected, email: email, password: password)
    }
    
    // MARK: - Private Remember Me Methods
    
    /// 處理「記住我」行為
    private func handleRememberMe(isSelected: Bool, email: String, password: String) {
        if isSelected {
            /// 若未輸入有效的帳號和密碼，顯示錯誤提示
            guard !email.isEmpty, !password.isEmpty else {
                AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
                setRememberMeState(isSelected: false)
                return
            }
            /// 保存用戶的帳號和密碼
            KeychainManager.save(key: "userEmail", data: Data(email.utf8))
            KeychainManager.save(key: "userPassword", data: Data(password.utf8))
            
        } else {
            /// 處理取消選中「記住我」的邏輯
            KeychainManager.delete(key: "userEmail")
            KeychainManager.delete(key: "userPassword")
        }
        
        setRememberMeState(isSelected: isSelected)
    }
    
    /// 設置「記住我」按鈕的狀態和 UserDefaults 的狀態
    private func setRememberMeState(isSelected: Bool) {
        loginView.setRememberMeButtonSelected(isSelected)
        UserDefaults.standard.set(isSelected, forKey: "RememberMe")
    }
    
}
