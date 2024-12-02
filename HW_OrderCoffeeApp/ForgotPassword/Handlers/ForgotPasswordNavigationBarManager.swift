//
//  ForgotPasswordNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/2.
//

// MARK: - 筆記：ForgotPasswordNavigationBarManager 使用說明
/**
 
 ## 筆記：ForgotPasswordNavigationBarManager 使用說明

 `* What`
 
 - `ForgotPasswordNavigationBarManager` 是一個負責管理 `ForgotPasswordViewController` 導航欄（Navigation Bar）的類別，主要用於設置導航欄的按鈕和標題，並且處理按鈕的點擊事件。

 -------------------
 
 `* Why`
 
 - 使用 `ForgotPasswordNavigationBarManager` 可以有效地將導航欄相關的配置與控制邏輯從 `ForgotPasswordViewController` 中分離出來，讓程式碼結構更清晰，並遵循單一職責原則。
 - 這樣可以提高程式碼的可維護性，減少 `ViewController` 中的職責，使各個類別負責單一任務，減少耦合。

 -------------------

 `* How`

 `1. 初始化`
    
 - 在 `ForgotPasswordViewController` 中，使用 `ForgotPasswordNavigationBarManager` 來設置導航欄按鈕和行為，讓視圖控制器可以集中在邏輯處理，導航欄的操作則交由 `ForgotPasswordNavigationBarManager` 處理。

    ```swift
    private func setupNavigationBarManager() {
        navigationBarManager = ForgotPasswordNavigationBarManager(navigationItem: navigationItem, viewController: self)
        navigationBarManager?.setupCloseButton()
    }
    ```

 `2. 設置關閉按鈕`
    
 - `setupCloseButton()` 方法負責設置導航欄左側的關閉按鈕，點擊後會執行 `closeButtonTapped()` 方法，讓當前視圖控制器 (`viewController`) 關閉。

 `3. 處理關閉行為`
 
 - 當用戶點擊關閉按鈕時，`closeButtonTapped()` 方法會被觸發，用於關閉當前的 `UIViewController`。

 -------------------

` * 結構與重點：`

 `1. Properties`
 
    - `navigationItem`: 用於操作導航欄的按鈕與標題。
    - `viewController`: 用於控制與 `ForgotPasswordViewController` 的關閉行為。
    
 `2. Initialization`
 
    - 將 `navigationItem` 和 `viewController` 作為參數傳入，便於設置導航欄並處理關閉事件。

 `3. Setup NavigationBar`
 
    - `setupCloseButton()` 設置了一個關閉按鈕，使得導航欄上可以看到一個標準的關閉按鈕，並將按鈕行為與 `closeButtonTapped()` 方法關聯。
    - `closeButtonTapped()` 則透過 `viewController` 的 `dismiss()` 方法來關閉視圖控制器，達到退出當前頁面的效果。

 -------------------

 `* Summary - 總結`
 
 - `ForgotPasswordNavigationBarManager` 幫助將導航欄相關的按鈕設置及點擊處理從 `ForgotPasswordViewController` 中抽離，讓 `ViewController` 專注於處理使用者的業務邏輯。
 - 這樣的分離使程式碼更加模組化、便於維護及擴展，符合單一職責原則，提升可讀性和易維護性。
 */


import UIKit

/// 管理 `ForgotPasswordViewController` 的導航欄按鈕和標題
class ForgotPasswordNavigationBarManager {
    
    // MARK: - Properties
    
    /// `UINavigationItem` 用於管理導航欄上的按鈕和標題
    private weak var navigationItem: UINavigationItem?
    private weak var viewController: UIViewController?
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// - Parameters:
    ///   - navigationItem: 傳入的 `UINavigationItem`，用於設置導航欄
    ///   - viewController: 傳入的 `UIViewController`，用於處理關閉行為
    init(navigationItem: UINavigationItem, viewController: UIViewController) {
        self.navigationItem = navigationItem
        self.viewController = viewController
    }
    
    // MARK: - Setup NavigationBar
    
    /// 設置導航欄的關閉按鈕
    func setupCloseButton() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        navigationItem?.leftBarButtonItem = closeButton
    }
    
    /// 處理關閉按鈕的點擊行為
    @objc private func closeButtonTapped() {
        viewController?.dismiss(animated: true, completion: nil)
    }
    
}
