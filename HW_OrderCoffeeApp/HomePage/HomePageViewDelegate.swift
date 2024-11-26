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

 `* Why`
 
 - `職責清晰`：使用委派模式將 視圖（View） 和 控制器（ViewController） 的職責劃分得非常明確。視圖只負責捕捉按鈕的點擊事件，而具體的業務邏輯處理由控制器負責。
 - `符合 MVC 設計原則`：透過委派模式，視圖與控制器之間的交互更加符合 MVC（Model-View-Controller）架構。視圖純粹處理顯示邏輯，控制器負責業務邏輯和行為控制。
 - `增強可重用性`：當視圖需要被不同的控制器使用時，每個控制器可以實作自己的委派方法來處理按鈕行為，而不需要修改視圖本身的實作。這增強了 可重用性 和 可擴展性。
 
 `* How`
 
 - `定義協定`：首先定義一個協定（HomePageViewDelegate），包含需要通知控制器的按鈕點擊事件方法。
 - `設置委派屬性`：在 HomePageView 中設置一個委派屬性，並使用 weak var delegate: HomePageViewDelegate? 來防止循環引用。
 - `通知控制器`：當按鈕被點擊時，透過呼叫 delegate?.didTapLoginButton() 或 delegate?.didTapSignUpButton() 將事件傳遞給控制器，讓控制器來處理相應的業務邏輯。
 - `實作協定`：在 HomePageViewController 中實作這個協定，並設置 homePageView.delegate = self 來接收通知並執行相應的行為。
 
 `* 使用委派模式的好處`
 
 - `視圖與控制器分離`：使用委派讓視圖和控制器的邏輯分離，便於維護，符合 MVC 原則。
 - `提高擴展性`：透過委派，未來可以輕鬆擴展視圖中的功能，例如增加更多按鈕，控制器可以只實作自己需要的部分。
 - `避免循環引用`：使用 weak 修飾委派屬性，避免強引用造成的循環引用問題，確保記憶體能被正常釋放。
 
 `* 小結`
 
 - HomePageViewDelegate 定義了 didTapLoginButton() 和 didTapSignUpButton() 兩個方法，讓控制器可以處理按鈕的點擊事件。
 - 委派模式 幫助將視圖的顯示邏輯與控制器的業務邏輯分開，確保職責清晰，符合 MVC 模式的最佳實踐。
 - 透過使用 weak 參考 避免了記憶體洩漏的風險，增加了安全性和可維護性。
 */


import UIKit

/// HomePageView 的委派協定，用於處理登入和註冊按鈕的點擊行為
protocol HomePageViewDelegate: AnyObject {
    
    /// 當使用者按下登入按鈕時呼叫
    func didTapLoginButton()
    
    /// 當使用者按下註冊按鈕時呼叫
    func didTapSignUpButton()
}
