//
//  LoginViewDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/27.
//

// MARK: - 重點筆記：是否需要在委派方法中傳遞 `LoginView` 參數

/**
 ## 重點筆記：是否需要在委派方法中傳遞 LoginView 參數

 `1. 單一 LoginView 實例：省略 loginView 參數`
 
 `* 適用場景：`
 
   - 應用程序中只有一個 `LoginView`。
   - 所有操作邏輯都由 `LoginViewController` 管理，沒有其他視圖控制器使用該 `LoginView`。
 
 `* 好處：`
 
   - 代碼更簡潔，委派方法不需要傳遞多餘的參數。
   - 事件的來源是唯一的，`LoginViewController` 可以直接處理事件而不需區分來源。
 
 `* 委派方法示例：`
 
   ```swift
   protocol LoginViewDelegate: AnyObject {
       func loginViewDidTapLoginButton()
       func loginViewDidTapForgotPasswordButton()
       // 其他方法...
   }
   ```

 `2. 多個 LoginView 實例：需要傳遞 loginView 參數`
 
 `* 適用場景：`
 
   - `LoginView` 在應用程序中多次使用，例如在不同的頁面或彈窗中。
   - 同一個控制器中存在多個 `LoginView` 實例，需要區分觸發事件的來源。
 
 `* 好處：`
 
   - 通過傳遞 `loginView` 參數，能夠辨別具體是哪一個 `LoginView` 引發了事件。
   - 可以根據事件的來源做出不同的邏輯處理，使代碼更具靈活性。
 
 `* 委派方法示例：`
 
   ```swift
   protocol LoginViewDelegate: AnyObject {
       func loginViewDidTapLoginButton(_ loginView: LoginView)
       func loginViewDidTapForgotPasswordButton(_ loginView: LoginView)
       // 其他方法...
   }
   ```

 `3.  總結選擇`
 
 - 使用單一 `LoginView` 實例時，可以省略傳遞 `loginView` 參數，保持代碼簡潔。
 - 使用多個 `LoginView` 實例時，應該傳遞 `loginView` 參數來區分事件的來源，增強代碼的靈活性和可維護性。
 */


// MARK: - LoginViewDelegate 重點筆記
/**
 
## LoginViewDelegate 重點筆記

`* What - 什麼是 LoginViewDelegate？`

- `LoginViewDelegate` 定義了在 `LoginView` 中使用者可能觸發的操作的回調方法。
- `LoginViewDelegate` 的主要功能是將 `LoginView` 中的使用者操作（例如按鈕點擊事件）回調到 `LoginViewController`，讓 `LoginView` 和控制器之間的職責劃分更為清晰。
- 它包含了登入、註冊、忘記密碼等按鈕的點擊事件，讓控制器可以負責處理這些業務邏輯。

----------------------------------------------

`* Why - 為什麼使用 LoginViewDelegate？`

- `解耦 UI 和業務邏輯`：
 
  - `LoginViewDelegate` 使得 `LoginView` 只專注於 UI 呈現，而不需要知道任何業務邏輯，這樣可以達到 `視圖與控制器的解耦`。
  - `LoginView` 通過 `delegate` 的方式，將使用者操作的事件通知給 `LoginViewController`，從而讓控制器負責具體的邏輯處理，如登入、跳轉頁面等。
  
- `保持代碼的清晰和易於維護`：
 
  - 透過 `LoginViewDelegate`，使用者的操作回調被統一管理在控制器中，保持了單一職責原則，讓各個元件的職責更加單一且清晰。
  - 這種結構更容易擴展，例如如果要新增一個按鈕，只需要在 `LoginView` 中添加相應的 UI，並通過 `LoginActionHandler` 設置事件，使用 `delegate` 回傳操作給控制器處理。

----------------------------------------------

`* How - 如何使用 LoginViewDelegate？`

`1. 設置 LoginActionHandler：`
 
   - 在 `LoginViewController` 的 `viewDidLoad` 中初始化 `LoginActionHandler`，並將 `LoginView` 和 `LoginViewDelegate` （即 `LoginViewController` 本身）傳入，讓 `LoginActionHandler` 可以設置按鈕的操作行為。
   
`2. 配置按鈕行為：`
 
   - `LoginActionHandler` 會設置每個按鈕的點擊行為，並透過代理將事件傳遞給 `LoginViewDelegate`。
   
`3. 實現回調方法：`
 
   - `LoginViewController` 通過實現 `LoginViewDelegate` 的方法，來集中處理使用者操作邏輯。
   - 例如，在點擊登入按鈕時，控制器會呼叫 Firebase 的登入方法進行處理。

----------------------------------------------

`* 具體的應用場景`

- `登入按鈕點擊`：
  - 使用者在 `LoginView` 中點擊登入按鈕後，`LoginActionHandler` 通知 `LoginViewController` 進行登入操作。
  
- `忘記密碼或註冊`：
  - 當使用者點擊相應的按鈕，回調方法會通知控制器進行頁面的跳轉。

- `記住我功能`：
  - 當使用者選擇記住我按鈕時，控制器會根據選中的狀態處理帳號密碼的保存與刪除。

----------------------------------------------

`* 總結`

- `LoginViewDelegate` 作為介面，定義了所有與登入相關的使用者操作。
- 它在 `LoginView` 和 `LoginViewController` 之間起到了橋樑作用，將 **UI 操作和邏輯處理解耦**，保持每個元件的職責單一。
- **`LoginView` 負責 UI 呈現，`LoginActionHandler` 負責設置操作，`LoginViewDelegate` 負責將操作回調到控制器進行業務邏輯處理**，這樣的設計提高了代碼的可讀性和可擴展性。
*/


import UIKit

/// `LoginViewDelegate` 用於將 `LoginView` 中各種使用者操作的回調事件傳送到 `LoginViewController`
/// - 主要目的為將 UI 操作與業務邏輯進行解耦，讓 `LoginView` 不直接處理邏輯
/// - 包含各種按鈕的點擊事件，如登入、忘記密碼、註冊等操作，讓 `LoginViewController` 可以集中管理這些事件並進行對應的邏輯處理
protocol LoginViewDelegate: AnyObject {
    
    /// 使用者點擊了登入按鈕
    func loginViewDidTapLoginButton()
    
    /// 使用者點擊了忘記密碼按鈕
    func loginViewDidTapForgotPasswordButton()
    
    /// 使用者點擊了註冊按鈕
    func loginViewDidTapSignUpButton()
    
    /// 使用者點擊了 Apple 登入按鈕
    func loginViewDidTapAppleLoginButton()
    
    /// 使用者點擊了 Google 登入按鈕
    func loginViewDidTapGoogleLoginButton()
    
    /// 使用者點擊了 "記住我" 按鈕
    /// - Parameter isSelected: 當前是否選中 "記住我" 選項
    func loginViewDidTapRememberMeButton(isSelected: Bool)
    
}
