//
//  MenuNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/23.
//


// MARK: - MenuNavigationBarManager 筆記
/**
 
 ### MenuNavigationBarManager 筆記

 
 `* What`
 
 - `MenuNavigationBarManager` 是一個專注於管理 `MenuViewController` 導航欄配置的類別。
 
 - 職責:
 
   - 設置導航欄標題和樣式，包括標準標題和大標題模式。
   - 減少 `MenuViewController` 的代碼負擔，專注於業務邏輯。
   - 提供一個高內聚、低耦合的解決方案，負責導航欄相關的操作。

 -------

 `* Why`

 1. 清晰的責任分離
 
    - 按照單一職責原則 (SRP)，`MenuViewController` 應專注於數據處理和用戶交互，而導航欄的設置應由專門的管理器負責，提升可維護性。

 2. 高內聚低耦合
 
    - 使用弱引用的方式 (`weak var`) 連接 `UINavigationItem` 和 `UINavigationController`，確保 `MenuNavigationBarManager` 不直接控制視圖層，降低耦合性。

 3. 提高代碼的可讀性和可重用性
 
    - 提供專門的初始化方法，避免在每個控制器中重複導航欄的設置邏輯，統一樣式和配置流程。

 4. 適應性強
 
    - 支持不同控制器的導航欄設置需求，例如標題文字、大標題模式和樣式配置的靈活調整。

 -------

 `* How`

 1. 設計初始化方法
 
    - 在初始化時接受 `UINavigationItem` 和 `UINavigationController`，確保該類在使用時具有明確的上下文。

    ```swift
    init(navigationItem: UINavigationItem, navigationController: UINavigationController?) {
        self.navigationItem = navigationItem
        self.navigationController = navigationController
    }
    ```

 ---
 
 2. 實現導航欄配置方法
 
    - 提供方法設置標題文字和大標題模式。

    ```swift
    func configureNavigationBarTitle(title: String, prefersLargeTitles: Bool = true) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }
    ```

 ---

 3. 在 `MenuViewController` 中使用
 
    - 初始化 `MenuNavigationBarManager` 並使用其方法來配置導航欄。

    ```swift
    class MenuViewController: UIViewController {

        private var navigationBarManager: MenuNavigationBarManager?

        override func viewDidLoad() {
            super.viewDidLoad()
            configureNavigationBar()
        }

        private func configureNavigationBar() {
            navigationBarManager = MenuNavigationBarManager(
                navigationItem: self.navigationItem,
                navigationController: self.navigationController
            )
            navigationBarManager?.configureNavigationBarTitle(title: "Menu", prefersLargeTitles: true)
        }
    }
    ```

 ---

 `* 優化與擴展的想法`

 1. 支持多樣化樣式設置
 
    - 增加方法來配置導航欄的背景色、標題字體等屬性。

    ```swift
    func configureAppearance(backgroundColor: UIColor, titleColor: UIColor, titleFont: UIFont) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: titleFont
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    ```

 2. 擴展至其他控制器
 
    - 將 `MenuNavigationBarManager` 泛化為適用於多控制器的通用導航欄管理器，並增加靈活的配置接口。

 -------

 `* 總結`

 - What: `MenuNavigationBarManager` 用於集中管理導航欄配置，減少控制器內的代碼負擔。
 - Why: 符合單一職責原則，提升代碼可讀性、模組化與維護性。
 - How: 提供初始化方法與標題設置接口，並支持靈活擴展以適應多控制器的需求。
 */



// MARK: - (v)

import UIKit

/// 負責管理 `MenuViewController` 導航欄配置的類別。
///
/// - 設計目標:
///   1. 提供簡單明確的導航欄標題與大標題模式設置。
///   2. 減少 `MenuViewController` 內的導航欄代碼，專注於業務邏輯。
///   3. 確保高內聚低耦合，方便維護與擴展。
class MenuNavigationBarManager {
    
    // MARK: - Properties
    
    /// `UINavigationItem` 用於設置導航欄的標題
    private weak var navigationItem: UINavigationItem?
    
    /// `UINavigationController` 用於設置導航欄的大標題顯示模式
    private weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - navigationItem: 傳入的 `UINavigationItem`，用於設置導航欄
    ///   - navigationController: 傳入的 `UINavigationController`，用於設置大標題顯示模式
    init(navigationItem: UINavigationItem,
         navigationController: UINavigationController?
    ) {
        self.navigationItem = navigationItem
        self.navigationController = navigationController
    }
    
    // MARK: - Setup Methods

    /// 配置導航欄的標題與大標題顯示模式
    ///
    /// - Parameters:
    ///   - title: 導航欄的標題文字
    ///   - prefersLargeTitles: 是否啟用大標題模式，預設為 `true`
    func configureNavigationBarTitle(title: String, prefersLargeTitles: Bool = true) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }
    
}
