//
//  HomePageViewDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/26.
//

// MARK: - 重點筆記：HomePageViewDelegate 使用

/**
 
 ## 重點筆記：HomePageViewDelegate 使用
 
 `* What `
 
 - `HomePageViewDelegate` 是一個 協定（Protocol），定義了兩個方法：`didTapLoginButton()` 和 `didTapSignUpButton()`，分別用於處理登入和註冊按鈕的點擊行為。
 - `HomePageActionHandler` 是一個處理按鈕行為的類別，負責在按鈕被點擊時，將事件透過 `HomePageViewDelegate` 傳遞給控制器。
 
 -------------------------------
 
 `* Why`
 
 `1.職責清晰：`

 - 使用 `HomePageActionHandler` 讓 `HomePageView` 專注於 UI 顯示，按鈕行為的邏輯處理則由 `ActionHandler` 負責，確保按鈕行為與顯示邏輯分離。
 - 透過 `HomePageViewDelegate`，控制器 (`HomePageViewController`) 可以在被通知後進行相應的頁面導航操作，達到視圖與控制器的職責劃分。
 
 `2.符合 MVC 設計原則：`

 - 將行為邏輯交由 `ActionHandler` 管理，確保 `View` 層純粹處理顯示邏輯，符合 MVC 模式。
 - 使用 `delegate` 來通知控制器，進一步減少 `View` 與 `Controller` 之間的耦合。
 
 -------------------------------

 `* How`
 
 `1.定義協定 (HomePageViewDelegate)：`

 - 協定中包含 didTapLoginButton() 和 didTapSignUpButton() 兩個方法，用來通知控制器處理相應的行為。
 
 `2.使用 HomePageActionHandler：`

 - `HomePageActionHandler` 負責初始化按鈕點擊行為處理。它持有 `HomePageView` 和 `HomePageViewDelegate` 的弱引用。
 - 透過 setupActions()，ActionHandler 為按鈕添加 target，確保按鈕被點擊後能正確觸發回調方法。
 
 `3.行為處理：`

 - 當使用者點擊按鈕時，`HomePageActionHandler` 會呼叫 `handleLoginButtonTapped()` 或` handleSignUpButtonTapped()`，透過 delegate 將行為傳遞給控制器。
 - 控制器 (`HomePageViewController`) 實作了 `HomePageViewDelegate` 協定，並進行具體的導航操作，例如前往登入頁面或註冊頁面。
 
 -------------------------------

 `* 使用委派模式的好處`
 
 - `視圖與控制器分離`：使用委派讓視圖和控制器的邏輯分離，便於維護，符合 MVC 原則。
 - `提高擴展性`：透過委派，未來可以輕鬆擴展視圖中的功能，例如增加更多按鈕，控制器可以只實作自己需要的部分。
 - `避免循環引用`：使用 weak 修飾委派屬性，避免強引用造成的循環引用問題，確保記憶體能被正常釋放。
 
 -------------------------------

 `* 小結`
 
 - `HomePageViewDelegate` 定義了 didTapLoginButton() 和 didTapSignUpButton() 兩個方法，讓控制器可以處理按鈕的點擊事件。
 -  將 delegate 的設置移到 HomePageActionHandler，並由 ActionHandler 集中處理所有按鈕的行為，確保視圖與行為邏輯解耦。
 -  `HomePageActionHandler` 集中管理按鈕的點擊行為，並將結果回調至控制器，這樣的設計符合 MVC 模式，職責清晰，增強了代碼的模組化和可重用性。
 */


import UIKit

/// HomePageView 的委派協定，用於處理登入和註冊按鈕的點擊行為
protocol HomePageViewDelegate: AnyObject {
    
    /// 當使用者按下登入按鈕時呼叫
    func didTapLoginButton()
    
    /// 當使用者按下註冊按鈕時呼叫
    func didTapSignUpButton()
}
