//
//  SignUpViewDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/30.
//

// MARK: - 筆記：`SignUpViewDelegate` 的設計目的與使用方法
/**

 ### 筆記：`SignUpViewDelegate` 的設計目的與使用方法

 * What：什麼是 `SignUpViewDelegate`

 - `SignUpViewDelegate` 是一個協議（Protocol），定義了 `SignUpView` 中各種使用者操作的回調事件，這些事件包括按鈕點擊行為，如「註冊按鈕」、「同意條款勾選框」和「閱讀條款按鈕」等。
 - 透過 `SignUpViewDelegate`，可以將使用者在視圖層的操作行為回調到控制層（例如 `SignUpViewController`），從而實現視圖層與邏輯層的解耦。

 -----------------------------------
 
 * Why：為什麼要使用 `SignUpViewDelegate`

 `1. 解耦 UI 與業務邏輯：`
     - 如果直接在 `SignUpView` 中處理使用者操作的業務邏輯，將會造成視圖與邏輯的高度耦合，不利於維護和擴展。
     - 使用 `SignUpViewDelegate` 可以將 UI 的操作回調給 `SignUpViewController`，讓控制層專注於邏輯處理，視圖層專注於 UI 呈現。

` 2. 提升可維護性：`
     - 透過 Delegate，可以使得視圖層和控制層的責任更加明確，各自專注於自己領域的工作。
     - 如果需要修改業務邏輯，只需要更新控制層，不會影響視圖層的代碼，反之亦然。

 `3. 清晰的責任分配：`
     - `SignUpView` 的職責是顯示 UI 元件並處理使用者操作，而 `SignUpViewController` 則負責使用者行為的後續邏輯處理。
     - `SignUpViewDelegate` 使得各自的責任劃分清晰，遵守了單一職責原則。

 -----------------------------------

 * How：如何在 `SignUpViewDelegate` 中設置和使用

 - 在 `SignUpViewDelegate` 中定義了以下幾個回調方法，讓控制層可以響應對應的使用者操作：
    
    1. `signUpViewDidTapTermsButton()`：
        - 當使用者點擊「閱讀條款」按鈕時，控制層可以捕捉到這一行為，從而顯示條款的相關內容（打開一個網頁鏈接）。

    2. `signUpViewDidTapTermsCheckBox()`：
        - 當使用者點擊「我同意條款」的勾選框時，控制層可以根據業務邏輯決定是否允許該操作，確保使用者在進行註冊前了解並同意條款。

    3. `signUpViewDidTapSignUpButton()`：
        - 當使用者點擊「註冊」按鈕時，控制層可以根據輸入內容進行驗證並發起註冊流程，例如檢查是否填寫了必須的欄位、是否符合條件等。

    4. `signUpViewDidTapGoogleSignUpButton()` 和 `signUpViewDidTapAppleSignUpButton()`：
        - 當使用者點擊第三方註冊按鈕時（例如 Google 或 Apple），控制層可以調用對應的第三方註冊 API 並處理後續的流程。

 - 使用步驟：
 
    `1. 設置 Delegate：`
        - 在 `SignUpViewController` 中設置 `signUpView` 的 `delegate` 為自己 (`signUpView.delegate = self`)。
        - 這樣當使用者在 `SignUpView` 中操作時，對應的回調方法就會被呼叫。
     
    `2.實作回調方法：`
        - 在 `SignUpViewController` 中實作這些回調方法，以便根據使用者的行為執行特定的邏輯操作。

 -----------------------------------

 `* 總結`

 - `SignUpViewDelegate` 通過將視圖層的使用者操作回調到控制層，實現了視圖與業務邏輯的分離，從而使代碼更易於維護和擴展。
 - 在 `SignUpView` 中，負責處理視圖的呈現；而 `SignUpViewController` 通過實作 `SignUpViewDelegate`，負責處理具體的業務邏輯，確保各層次之間的職責劃分明確。
 */


import UIKit

/// `SignUpViewDelegate` 用於將 `SignUpView` 中各種使用者操作的回調事件傳送到 `SignUpViewController`
/// - 主要目的為將 UI 操作與業務邏輯進行解耦，讓 `SignUpView` 不直接處理邏輯
/// - 包含各種按鈕的點擊事件，如註冊、我同意條款、閱讀條款等操作，讓 `SignUpViewController` 可以集中管理這些事件並進行對應的邏輯處理
protocol SignUpViewDelegate: AnyObject {
    
    /// 當使用者點擊「閱讀條款」按鈕時被觸發
    func signUpViewDidTapTermsButton()
    
    /// 當使用者點擊「我同意條款」的 CheckBox 按鈕時被觸發
    func signUpViewDidTapTermsCheckBox()
    
    /// 當使用者點擊「註冊」按鈕時被觸發
    func signUpViewDidTapSignUpButton()
    
    /// 當使用者點擊「使用 Google 註冊」按鈕時被觸發
    func signUpViewDidTapGoogleSignUpButton()
    
    /// 當使用者點擊「使用 Apple 註冊」按鈕時被觸發
    func signUpViewDidTapAppleSignUpButton()
    
}
