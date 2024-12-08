//
//  EditProfileNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/4.
//

// MARK: - EditProfileNavigationBarManager 筆記
/**
 
 ## EditProfileNavigationBarManager 筆記
 
 `* What`
 
 - `EditProfileNavigationBarManager` 是一個專門為導航欄設計的管理類別，簡化了標題與按鈕的設置操作。
 
 - 提供了一個統一接口，用於設置：
 
 1.導航欄的標題，支持大標題模式。
 2.左右側按鈕的標題、樣式與觸發行為。
 
 ------------------
 
 `* Why`
 
 `1.解耦導航欄邏輯與控制器邏輯：`

 - 在視圖控制器中，導航欄的配置（標題、按鈕等）通常占用多餘的代碼空間，且難以管理。
 - 使用管理類別可以讓控制器聚焦於業務邏輯，而導航欄配置則交由專用類別處理。
 
 `2.提高代碼重用性：`

 - 將標題與按鈕的設置邏輯抽象出來，可以重用於其他控制器中，減少代碼重複。
 
 `3.動態調整的靈活性：`

 - 支持根據業務需求動態更改標題模式（如大標題與普通標題之間的切換）。
 - 按鈕配置可以通過一個統一接口動態更改，適應不同場景的需求。
 
 `4.提升代碼可讀性與可測試性：`

 - 將導航欄相關邏輯獨立封裝，減少視圖控制器的責任範圍，符合單一職責原則。
 - 測試時可以獨立驗證導航欄配置是否正確。
 
 ------------------

 `* How`
 
 `1.設置標題：`

 - 使用 `configureNavigationBarTitle(title:prefersLargeTitles:) `方法設置標題內容，並控制是否啟用大標題模式。
 - 可在初始化控制器時或場景切換時使用。
 
 `2.設置按鈕：`

 - 使用 `setupBarButton` 方法動態設置左或右側按鈕，支持以下參數：
 
 按鈕標題（title）
 按鈕樣式（style）
 按鈕觸發目標與操作（target 與 action）
 
 3.位置控制：

 - 通過自定義的 UIBarButtonPosition 枚舉明確指定按鈕的位置，避免使用不直觀的數值或字符串標記位置。
 */


import UIKit

/// `EditProfileNavigationBarManager` 負責管理個人資料編輯頁面的導航欄配置，包括標題設定和按鈕的管理。
/// - 設計目標：
///   1. 提供簡化的導航欄配置方法，減少主控制器中的導航欄相關代碼。
///   2. 支援標題（包括大標題模式）與按鈕的動態設置。
class EditProfileNavigationBarManager {
    
    // MARK: - Properties
    
    /// `UINavigationItem` 用於設置導航欄的標題和按鈕
    private weak var navigationItem: UINavigationItem?
    
    /// `UINavigationController` 用於設置導航欄的大標題顯示模式
    private weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// - Parameters:
    ///   - navigationItem: 傳入的 `UINavigationItem`，用於設置導航欄
    ///   - navigationController: 傳入的 `UINavigationController`，用於設置大標題顯示模式
    init(navigationItem: UINavigationItem, navigationController: UINavigationController?) {
        self.navigationItem = navigationItem
        self.navigationController = navigationController
    }
    
    // MARK: - Setup NavigationBar
    
    /// 配置導航欄的標題與大標題顯示模式
    /// - Parameters:
    ///   - title: 導航欄的標題文字。
    ///   - prefersLargeTitles: 是否啟用大標題模式，預設為 `true`。
    /// - 使用場合：
    ///   - 在初始化控制器時設置標題。
    ///   - 可根據頁面需求動態切換標題模式（如切換到普通標題）。
    func configureNavigationBarTitle(title: String, prefersLargeTitles: Bool = true) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
    }
    
    /// 通用方法設置導航欄按鈕
    /// - Parameters:
    ///   - title: 按鈕的標題
    ///   - style: 按鈕樣式（如 `.plain` 或 `.done`）
    ///   - position: 按鈕的位置（左側或右側）
    ///   - target: 按鈕的目標對象
    ///   - action: 按鈕的觸發操作
    func setupBarButton(title: String, style: UIBarButtonItem.Style, position: UIBarButtonPosition, target: Any, action: Selector) {
        let barButton = UIBarButtonItem(title: title, style: style, target: target, action: action)
        
        switch position {
        case .left:
            navigationItem?.leftBarButtonItem = barButton
        case .right:
            navigationItem?.rightBarButtonItem = barButton
        }
    }
}

// MARK: - UIBarButtonPosition

/// 定義導航欄按鈕的位置
/// - 使用場合：
///   - 提供明確的按鈕位置定義，減少直接使用 `UIBarButtonItem` 的耦合。
enum UIBarButtonPosition {
    case left
    case right
}
