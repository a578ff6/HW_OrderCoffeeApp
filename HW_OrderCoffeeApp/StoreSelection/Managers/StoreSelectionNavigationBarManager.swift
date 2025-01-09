//
//  StoreSelectionNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/6.
//

import UIKit

/// `StoreSelectionNavigationBarManager` 負責配置「店家選擇頁面」的導航欄。
///
/// ### 功能說明
/// - 提供設置導航欄標題與關閉按鈕的功能，將導航欄相關邏輯與 `StoreSelectionViewController` 分離。
/// - 適用於需要簡化控制器內部導航欄邏輯的場景，提升代碼的模組化與可讀性。
class StoreSelectionNavigationBarManager {
    
    // MARK: - Properties
    
    /// 導航欄的 `UINavigationItem`，用於設置標題與按鈕。
    private weak var navigationItem: UINavigationItem?
    
    // MARK: - Initializer
    
    /// 初始化方法
    /// - Parameter navigationItem: 傳入的 `UINavigationItem`，用於導航欄配置
    init(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
    }
    
    // MARK: - NavigationBar Configuration
    
    /// 配置導航欄的標題
    ///
    /// - Parameter title: 導航欄的標題文字
    func configureTitle(_ title: String) {
        navigationItem?.title = title
    }
    
    /// 配置關閉按鈕
    ///
    /// - Parameters:
    ///   - target: 按鈕的目標物件
    ///   - action: 按鈕的行為
    func configureCloseButton(target: Any?, action: Selector) {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: target, action: action)
        navigationItem?.leftBarButtonItem = closeButton
    }
    
}
