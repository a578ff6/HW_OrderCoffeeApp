//
//  HomePageActionHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/3.
//

// MARK: - HomePageActionHandler 筆記
/**
 
 ## HomePageActionHandler 筆記
 
 `* What`
 
 - `HomePageActionHandler` 是負責處理 `HomePageView` 中按鈕行為的類別，主要管理登入和註冊按鈕的點擊事件。
 - 這些事件最終會透過 `HomePageViewDelegate` 回調至 `HomePageViewController`。

 -------------------------------
 
 `* Why`
 
 `1.分離視圖與行為邏輯：`
 
 - 將按鈕行為從 `HomePageView` 中分離出來，以遵循單一職責原則（Single Responsibility Principle），讓 HomePageView 專注於 UI 顯示，而行為處理則交由 HomePageActionHandler 處理。
 
 `2.增強模組化：`
 
 - 這樣的設計使得按鈕行為的處理可以集中管理，避免視圖層與控制邏輯過度耦合，提高代碼的可讀性和可維護性。
 
 `3.減少耦合度：`
 
 - 透過 `HomePageViewDelegate` 的回調，讓 `HomePageActionHandler` 能夠將按鈕點擊的行為通知給 `HomePageViewController`，而不直接持有控制器的引用，降低兩者間的耦合度。
 
 -------------------------------

 `* How`
 
 `1.屬性設置：`

 - view: 使用弱引用 (weak) 來持有 HomePageView 的實例，防止循環引用導致的記憶體洩漏。
 - delegate: 使用弱引用來持有 HomePageViewDelegate 的實例，用於將使用者行為回調給外部，例如 HomePageViewController。
 
 `2.初始化方法：`

 - init(view: HomePageView, delegate: HomePageViewDelegate)：將 HomePageView 和 HomePageViewDelegate 傳入 HomePageActionHandler，並呼叫 setupActions() 方法來設置按鈕的行為。
 
 `3.按鈕行為設置：`

 - setupActions()：設置登入與註冊按鈕的點擊事件。
 - 透過 getLoginButton() 和 getSignUpButton() 方法，取得按鈕並添加 target，確保點擊事件能夠由 HomePageActionHandler 處理。
 
 `4.行為處理方法：`

 - handleLoginButtonTapped(): 當使用者點擊登入按鈕時，通知 delegate 呼叫 didTapLoginButton() 方法，讓控制器可以執行登入畫面的導航。
 - handleSignUpButtonTapped(): 當使用者點擊註冊按鈕時，通知 delegate 呼叫 didTapSignUpButton() 方法，讓控制器可以執行註冊畫面的導航。
 */


import UIKit

/// HomePageActionHandler 負責處理 HomePageView 中的使用者行為，包括前往登入和註冊按鈕的點擊事件
class HomePageActionHandler {
    
    // MARK: - Properties

    /// `HomePageView` 用於處理按鈕行為
    private weak var view: HomePageView?
    
    /// `HomePageViewDelegate` 的弱引用，用於將使用者行為回調至 HomePageViewController
    private weak var delegate: HomePageViewDelegate?
    
    // MARK: - Initializer

    /// 初始化 HomePageActionHandler
    /// - Parameters:
    ///   - view: `HomePageView` 的實例，用於設置按鈕行為
    ///   - delegate: `HomePageViewDelegate` 的實例，用於將按鈕點擊行為回調給外部
    init(view: HomePageView, delegate: HomePageViewDelegate) {
        self.view = view
        self.delegate = delegate
        setupActions()
    }
    
    // MARK: - Private Methods

    /// 設置 HomePageView 中按鈕的行為
    private func setupActions() {
        guard let view = view else { return }
        
        view.getLoginButton().addTarget(self, action: #selector(handleLoginButtonTapped), for: .touchUpInside)
        view.getSignUpButton().addTarget(self, action: #selector(handleSignUpButtonTapped), for: .touchUpInside)
    }
    
    /// 處理登入按鈕的點擊事件，進行導航
    @objc private func handleLoginButtonTapped() {
        delegate?.didTapLoginButton()
    }
    
    /// 處理註冊按鈕的點擊事件，通知 `delegate`
    @objc private func handleSignUpButtonTapped() {
        delegate?.didTapSignUpButton()
    }
    
}
