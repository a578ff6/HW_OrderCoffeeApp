//
//  LoginViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

/*
 A.實現用戶登入、註冊後跳轉到其他視圖：
    * 設置 RootViewController：
        - 常用的方式，特別是在登入、註冊成功後。確保登入前的ViewController（登入、註冊頁面）不再存在於「ViewController堆棧」中，從而避免用戶通過Navigation返回到這些頁面。
        - 優點：
        - 確保App的狀態一致性。
        - 使用者無法通過Navigation回到登入、註冊頁面。
        - 適合用於MainNavigation的切換，像是從登入頁面到App的主頁面。
 
    * 使用 NavigationController：
        -如果App的結構是基於NavigtaionController，那麼可以通過push、modalPresent展示新的ViewController。不過這種發誓通常用於在同一個 「Navigation堆棧」中添加新的 ViewController，而不是替換整個 RootViewController。
        - 優點：
        - 間單直接，適用於非 RootViewController 的跳轉。
        - 在同一個「Navigation堆棧」中管理 ViewController。
 
    * 選擇的方式：
        - 設置 RootViewController 方式，特別是在登入、註冊成功後。
        - 原因：
            - 清除「Navigation堆棧」中不需要的 ViewController ，確保App的一致性。
            - 更適合用於主視圖的切換，例如登入、註冊頁面到App主頁面。
            - 只有在特定的場境下（EX：在同一個「Navigation堆棧」中添加新的 ViewController ），使用 NavigationController 進行視圖跳轉才會更適合。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 B. 處理「Remember Me」按鈕的流程：
    * 當用戶點擊 "Remember Me" 按鈕時，會將當前的電子郵件和密碼存儲到 Keychain 中。
 
    * 先檢查TextField是否有填寫：
        - 原本如果用戶先點擊 "Remember Me" 按鈕再輸入帳號密碼，那麼之前的空數據或錯誤的數據就會被存儲。
        - 因此我後來改成：用戶點擊 "Remember Me" 按鈕後檢查當前的電子郵件和密碼是否已經填寫好。如果未填寫好，提示用戶先完成輸入。
 
    * Remember Me 按鈕的邏輯和 loginButtonTapped 的關聯性：
        - Remember Me 按鈕的作用是在用戶選中時記住電子郵件和密碼，而 loginButtonTapped 則是在用戶點擊登錄按鈕後執行登錄操作。
 
    * 工作流程（確保這個流程的關鍵在於順序的控制和條件的檢查。）：
        - 用戶輸入電子郵件和密碼。
        -  用戶點擊 Remember Me 按鈕（可選）。
        -  用戶點擊 Login 按鈕，執行登錄操作。
        -  如果用戶選中了 Remember Me，則會將電子郵件和密碼存儲到 Keychain 中。
        -  在下一次 App 啟動時，如果檢測到 Remember Me 被選中，則自動填充電子郵件和密碼。

 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 C. googleLoginButtonTapped：
    * Google 登入或註冊成功後會調用 signInWithGoogle 。
 
    * 在 signInWithGoogle 成功後，會使用 Firebase 的憑證登入，並在 authResult 成功後調用 FirebaseController.shared.getCurrentUserDetails 獲取用戶的資訊。
   
    * 在獲取用戶資訊時：
        - 如果用戶數據存在（成功獲取用戶資訊），則會進入到主界面，並傳遞 userDetails。
        - 如果用戶數據不存在（獲取用戶資訊失敗），顯示錯誤資訊。）
 
    * 藉此確保在用戶首次通過 Google 登入、註冊時，正確存取用戶資訊，並在之後每次登入時能夠正確獲取用戶資訊，而不會重複建立或覆蓋已有資訊。
        -  GoogleSignInController：負責處理所有 Google 登入相關的邏輯。
        -  FirebaseController：負責處理 Firebase 認證和使用者資料相關的邏輯。
        -  這樣的設計可以讓 GoogleSignInController 專注於 Google 登入，而 FirebaseController 則負責處理從 Firebase 獲取用戶資訊的邏輯。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 C_1. Google 登入流程：
    * 點擊 Google 登入按鈕：
        - 觸發 googleLoginButtonTapped。
    
    * 調用 GoogleSignInController 進行 Google 登入：
        - 在 googleLoginButtonTapped 中，調用 GoogleSignInController.shared.signInWithGoogle ，傳入目前的視圖控制器（presentingViewController）和一個完成的回調。
        - GoogleSignInController 負責處理 Google 登入邏輯。
    
    * Google登入介面：
        - GoogleSignInController 調用 GIDSignIn.sharedInstance.signIn(withPresenting:)，顯示 Google 登入介面，用戶可以選擇或輸入 Google 帳號進行登入。

    * 獲取 Google 登入結果：
        - 用戶完成登入後，Google 登入介面結束，GoogleSignInController 的完成回調被調用。
        - 如果登入成功 Google 返回用戶資訊、身份驗證Token。
 
    * 使用 Google 憑證登入 Firebase：
        - GoogleSignInController 使用 GoogleAuthProvider.credential(withIDToken:accessToken:) 建立一個 Firebase 憑證。
        - 使用 Auth.auth().signIn(with:) 將 Google 憑證傳遞給 Firebase 進行身份驗證。
 
    * 處理 Firebase 登入結果：
        - 如果 Firebase 登入成功，將調用完成回調，並傳遞 AuthDataResult 對象。
        - 在 googleLoginButtonTapped 的回調中，根據結果更新 UI。

    * 獲取用戶詳細資訊：
        - 如果登入成功，調用 FirebaseController.shared.getCurrentUserDetails 從 Firestore 獲取當前用戶的詳細資訊。
    
    * 更新 UI：
        - 根據獲取的用戶詳細資訊，調用 NavigationHelper.navigateToMainTabBar ，導航到主介面。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 D. 關於顯示 HUD 的時機：
    
    - 原先在使用 Google 、 Apple 登入時，在「Google 或 Apple 提供的登錄介面」的時候就會出現 HUD，為了避免讓使用者困惑，因此進行修正。
 
    * 在 GoogleSignInController.shared.signInWithGoogle 和 AppleSignInController.shared.signInWithApple 的場景中。
        - 通常情況下，使用者會先看到 Google 或 Apple 提供的登錄介面（例如 Google 的選擇帳號頁面或 Apple 的輸入密碼頁面）。這些介面本身是系統級別的彈出視窗，它們會遮蓋 App 畫面。
 
    * HUD 的顯示邏輯
        - 不要在調用 Google 或 Apple 登錄時立即顯示 HUD：因為這樣會讓用戶誤以為系統正在進行某種操作，而實際上他們需要進行選擇帳號或輸入憑證的操作。
        - 改在獲得 Google 或 Apple 憑證後顯示 HUD：這樣當 HUD 出現時，確保用戶已經完成了帳號選擇或密碼輸入的過程，然後可以顯示“登入中...”來指示正在處理憑證並與 Firebase 進行認證。
 
    * 結論
        - 避免在用戶需要交互時顯示 HUD，比如選擇 Google 帳號或輸入 Apple 密碼。
        - 在完成用戶交互並開始後台處理時顯示 HUD，這樣可以更好地指示正在進行的操作，並避免用戶誤解。
 */


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

 `2. LoginActionHandler`
 
 - `職責`: 設置 `LoginView` 各個按鈕的點擊行為，並處理與按鈕的互動。
 - `關聯性`:
   - `LoginView`: 在初始化時，將 `LoginView` 傳入 `LoginActionHandler` 中，並透過 getter 取得按鈕，進而設置行為。
   - `LoginViewDelegate`: `LoginActionHandler` 透過 delegate 通知 `LoginViewController` 使用者點擊了哪個按鈕。
   - `LoginViewController`: `LoginViewController` 初始化 `LoginActionHandler`，並把 `LoginView` 和 `LoginViewDelegate` 傳入。

 `3. LoginViewDelegate`
 
 - `職責`: 用於定義登入頁面上的所有互動行為的回調方法。
 - `關聯性`:
   - `LoginActionHandler`: 當按鈕被點擊時，`LoginActionHandler` 透過 `delegate` 呼叫相應的回調方法。
   - `LoginViewController`: 實作了 `LoginViewDelegate`，以便在使用者點擊按鈕時執行具體的邏輯。

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
 
 - `loginViewDidTapRememberMeButton` 是用來處理當使用者點擊「記住我」按鈕時的操作邏輯。它會根據使用者是否選中「記住我」選項，進行保存或刪除帳號密碼的操作。

 ----------------------------------------

 `* Why：`
 
 - 此方法的目的是幫助使用者在下次登入時自動填入先前的帳號和密碼。當選中「記住我」時，會保存使用者輸入的帳號和密碼；當取消選中時，則刪除之前保存的帳號密碼，保證數據的安全和隱私。

 ----------------------------------------

 `* How：`
 
 `1. 取得用戶的 Email 和密碼：`
 
    - 使用 `loginView.email` 和 `loginView.password` 方法來取得用戶當前輸入的 Email 和密碼。

 ----------------------------------------

 `2. 檢查「記住我」按鈕是否被選中：`
 
    - `若選中（isSelected 為 true）`：
      - 檢查用戶是否輸入了有效的帳號和密碼。
      - `如果有輸入`：
        - 使用 `KeychainManager` 保存帳號和密碼，確保它們安全存儲。
        - 將「記住我」按鈕的狀態設置為選中 (`true`)。
        - 將 `UserDefaults` 中的 `RememberMe` 設為 `true`，以記錄用戶選中「記住我」的狀態。
      - `如果沒有輸入`：
        - 顯示警告，提示用戶必須輸入電子郵件和密碼。
        - 將「記住我」按鈕的狀態設置為未選中 (`false`)。
        - 確保 `UserDefaults` 中的 `RememberMe` 狀態為 `false`，避免錯誤保存選中狀態。

    - `若未選中（isSelected 為 false）`：
      - 使用 `KeychainManager` 刪除之前保存的帳號和密碼。
      - 將「記住我」按鈕的狀態設置為未選中 (`false`)。
      - 將 `UserDefaults` 中的 `RememberMe` 設為 `false`，以清除「記住我」的狀態。

 ----------------------------------------

 `* 總結：`
 
 - `選中「記住我」時`，必須輸入有效的帳號和密碼，才會保存這些信息，並將「記住我」狀態設為選中。
 - `未輸入有效資料，或 取消選中「記住我」時`，將確保刪除所有保存的帳號和密碼信息，並將狀態設為未選中。
 - 此邏輯確保只有在符合條件（即有有效帳號和密碼）時，才能選中「記住我」，避免在不正確情況下保存錯誤的狀態。
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



// MARK: - (v)

import UIKit
import FirebaseAuth

/// 登入介面：負責處理登入相關的邏輯與畫面
/// - 主要職責包括：
///   1. 初始化並配置 `LoginView` 作為主要的 UI 畫面。
///   2. 通過 `LoginActionHandler` 設置各按鈕的行為，將 UI 操作與邏輯處理解耦。
///   3. 通過實現 `LoginViewDelegate`，將使用者的操作行為進行相應的邏輯處理。
class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// `LoginView` 為登入畫面主體，用於顯示 UI 元件
    private let loginView = LoginView()
    
    // MARK: - Handlers
    
    /// `LoginActionHandler` 負責處理 `LoginView` 中按鈕的行為
    /// - 設定 `LoginView` 和 `LoginViewDelegate` 以實現事件與邏輯的分離
    private var actionHandler: LoginActionHandler?
    
    // MARK: - Lifecycle Methods
    
    /// 將 `loginView` 設定為主視圖
    override func loadView() {
        view = loginView
    }
    
    /// 設置 `畫面元件` 與 `actionHandler`
    /// - 初始化 `LoginActionHandler` 並設定按鈕行為
    /// - 如果有記住的用戶資料，則嘗試加載用戶的登入資訊
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionHandler()
        loadRememberedUser()
    }
    
    // MARK: - Action Handler
    
    /// 初始化並設置 `LoginActionHandler`
    /// - `LoginActionHandler` 負責處理 `LoginView` 中的按鈕行為
    /// - 通過設置 view 與 delegate，將 UI 行為與邏輯解耦合，增加程式碼的模組化和可維護性
    private func setupActionHandler() {
        actionHandler = LoginActionHandler(view: loginView, delegate: self)
    }
    
    // MARK: - Dismiss Keyboard
    
    /// 統一的鍵盤收起方法
    /// - 收起當前視圖中活動的鍵盤
    /// - 使用於各種按鈕操作開始前，確保畫面整潔、避免鍵盤遮擋重要資訊或 HUD
    private func dismissKeyboard() {
        view?.endEditing(true)
    }
    
    // MARK: - User Data Management
    
    /// 在 App 啟動時存取並加載用戶資訊（若有記住我選項被勾選）
    /// - 首先檢查 UserDefaults 中是否有勾選 "記住我" 選項
    /// - 如果 "記住我" 選項被勾選，則設置 `RememberMe` 按鈕狀態為選中
    /// - 隨後，從 Keychain 加載用戶的電子郵件和密碼，並填入到 `LoginView` 的相應輸入框中
    private func loadRememberedUser() {
        guard shouldLoadRememberedUser() else { return }
        loginView.setRememberMeButtonSelected(true)
        loadUserCredentials()
    }
    
    /// 判斷是否應加載用戶信息
    /// - Returns: 若應該加載用戶信息則返回 true，否則返回 false
    private func shouldLoadRememberedUser() -> Bool {
        return UserDefaults.standard.value(forKey: "RememberMe") as? Bool ?? false
    }
    
    /// 從 Keychain 中加載用戶憑證並填入相應的輸入框
    private func loadUserCredentials() {
        if let emailData = KeychainManager.load(key: "userEmail"),
           let passwordData = KeychainManager.load(key: "userPassword") {
            setEmailAndPassword(emailData: emailData, passwordData: passwordData)
        }
    }
    
    /// 將加載的電子郵件和密碼設置到 loginView 中
    /// - Parameters:
    ///   - emailData: 加載的電子郵件數據
    ///   - passwordData: 加載的密碼數據
    private func setEmailAndPassword(emailData: Data, passwordData: Data) {
        if let email = String(data: emailData, encoding: .utf8) {
            loginView.setEmail(email)
        }
        
        if let password = String(data: passwordData, encoding: .utf8) {
            loginView.setPassword(password)
        }
    }
}

// MARK: - LoginViewDelegate
extension LoginViewController: LoginViewDelegate {
    
    // MARK: - Standard Login Actions
    
    /// 當使用者點擊登入按鈕時的處理邏輯
    /// - 檢查電子郵件和密碼是否輸入
    /// - 進行登入請求，若成功則導向主頁面
    /// - 在登入流程開始前先收起鍵盤，確保畫面整潔並避免影響 HUD 顯示
    func loginViewDidTapLoginButton() {
        dismissKeyboard()
        let email = loginView.email
        let password = loginView.password
        
        guard !email.isEmpty, !password.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
            return
        }
        
        HUDManager.shared.showLoading(text: "Logging in...")
        Task {
            do {
                _ = try await EmailSignInController.shared.loginUser(withEmail: email, password: password)
                NavigationHelper.navigateToMainTabBar(from: self)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Google Login Actions
    
    /// 當使用者點擊 Google 登入按鈕時的處理邏輯
    /// - 使用 Google 提供的方法進行登入，若成功則導向主頁面
    /// - 登入過程開始前收起鍵盤，避免鍵盤遮擋 HUD
    func loginViewDidTapGoogleLoginButton() {
        dismissKeyboard()
        Task {
            HUDManager.shared.showLoading(text: "Logging in...")
            do {
                _ = try await GoogleSignInController.shared.signInWithGoogle(presentingViewController: self)
                NavigationHelper.navigateToMainTabBar(from: self)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Apple Login Actions
    
    /// 當使用者點擊 Apple 登入按鈕時的處理邏輯
    /// - 使用 Apple 提供的方法進行登入，若成功則導向主頁面
    /// - 登入過程開始前收起鍵盤，避免鍵盤遮擋 HUD
    func loginViewDidTapAppleLoginButton() {
        dismissKeyboard()
        Task {
            HUDManager.shared.showLoading(text: "Logging in...")
            do {
                _ = try await AppleSignInController.shared.signInWithApple(presentingViewController: self)
                NavigationHelper.navigateToMainTabBar(from: self)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
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
    
    /// 當使用者點擊 "記住我" 按鈕時的處理邏輯
    /// - 根據用戶選擇是否保存電子郵件和密碼
    func loginViewDidTapRememberMeButton(isSelected: Bool) {
        let email = loginView.email
        let password = loginView.password
        
        if isSelected {
            handleRememberMeSelected(email: email, password: password)
        } else {
            handleRememberMeDeselected()
        }
    }
    
    // MARK: - Private Remember Me Methods
    
    /// 處理選中「記住我」的邏輯
    private func handleRememberMeSelected(email: String, password: String) {
        /// 若未輸入有效的帳號和密碼，顯示錯誤提示
        guard !email.isEmpty, !password.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
            setRememberMeState(isSelected: false)
            return
        }
        
        /// 保存用戶的帳號和密碼
        KeychainManager.save(key: "userEmail", data: Data(email.utf8))
        KeychainManager.save(key: "userPassword", data: Data(password.utf8))
        
        /// 將「記住我」的狀態設置為`選中`
        setRememberMeState(isSelected: true)
    }
    
    /// 處理取消選中「記住我」的邏輯
    private func handleRememberMeDeselected() {
        /// 刪除已保存的帳號和密碼
        KeychainManager.delete(key: "userEmail")
        KeychainManager.delete(key: "userPassword")
        
        /// 將「記住我」的狀態設置為`未選中`
        setRememberMeState(isSelected: false)
    }
    
    /// 設置「記住我」按鈕的狀態和 UserDefaults 的狀態
    private func setRememberMeState(isSelected: Bool) {
        loginView.setRememberMeButtonSelected(isSelected)
        UserDefaults.standard.set(isSelected, forKey: "RememberMe")
    }
    
}
