//
//  ForgotPasswordDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/2.
//

// MARK: - ForgotPasswordDelegate 筆記
/**

 ## ForgotPasswordDelegate 筆記
 
` * What`

 - ForgotPasswordDelegate 用於定義忘記密碼頁面 (ForgotPasswordView) 中兩個主要按鈕的行為，即「重置密碼按鈕」和「返回登入頁面按鈕」的點擊事件。

 1.`forgotPasswordDidTapResetPasswordButton()` - 當使用者點擊重置密碼按鈕時呼叫。

 2. `forgotPasswordDidTapLoginPageButton() `- 當使用者點擊返回登入頁面按鈕時呼叫。

 -----------------------------
 
 `* Why`

 - 使用 ForgotPasswordDelegate 可以達到「解耦合 UI 與邏輯」的目的。
 - 由於按鈕的具體點擊邏輯可能會涉及到多種不同的處理，例如驗證電子郵件、顯示錯誤提示、跳轉至不同頁面等，因此將按鈕行為通過協定交由控制器處理可以更靈活地管理這些邏輯，並提高代碼的可維護性與可重用性。
 - 單一責任原則：把按鈕點擊行為和畫面 UI 控制分開，各自負責不同的職責，減少各個元件之間的耦合度。
 - 提高靈活性：允許外部控制器實現協定中的方法，可以根據具體需求實現不同的行為，避免視圖層中的行為邏輯過於複雜。

 -----------------------------

 `* How`

 - `在 ForgotPasswordViewController 中實現 ForgotPasswordDelegate 方法`：

    1.實現 forgotPasswordDidTapResetPasswordButton() 方法來處理當使用者點擊重置密碼按鈕時的行為，例如驗證電子郵件和執行密碼重置操作。

    2.實現 forgotPasswordDidTapLoginPageButton() 方法來處理當使用者想要返回登入頁面的行為。

    在 ForgotPasswordView 中設置 delegate 屬性，並在按鈕點擊時調用協定方法：

 ```
 // ForgotPasswordViewController 實現 ForgotPasswordDelegate
 extension ForgotPasswordViewController: ForgotPasswordDelegate {
     func forgotPasswordDidTapResetPasswordButton() {
         // 點擊重置密碼按鈕後執行的具體邏輯
     }

     func forgotPasswordDidTapLoginPageButton() {
         // 點擊返回登入按鈕後執行的具體邏輯
     }
 }
 ```
 
 - 將按鈕的點擊事件設置為呼叫 delegate 方法，將具體的行為邏輯交給控制器去實現。
 */


import UIKit

/// `ForgotPasswordDelegate` 是用於處理 `ForgotPasswordView` 內與按鈕操作相關的事件協定。
/// - 通過實現這個協定，外部可以對特定的按鈕點擊行為進行回應並執行相應的邏輯處理。
protocol ForgotPasswordDelegate: AnyObject {
    
    /// 當使用者點擊重置密碼按鈕時觸發。
    /// - 用於驗證使用者輸入，並進行密碼重置請求。
    func forgotPasswordDidTapResetPasswordButton()
    
    /// 當使用者點擊返回登入頁面的按鈕時觸發。
    /// - 用於讓使用者跳轉回登入頁面，關閉當前視圖或返回到先前的頁面。
    func forgotPasswordDidTapLoginPageButton()
}
