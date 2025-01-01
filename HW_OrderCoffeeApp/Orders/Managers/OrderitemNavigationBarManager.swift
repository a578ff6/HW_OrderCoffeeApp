//
//  OrderitemNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/31.
//

import UIKit

/// `OrderitemNavigationBarManager` 負責管理「OrderItem」頁面的導航欄配置。
///
/// ### 功能說明
/// - 提供設置導航欄標題與大標題顯示模式的接口。
/// - 將導航欄的邏輯與控制器分離，提升代碼的模組化和可讀性。
class OrderitemNavigationBarManager {
    
    // MARK: - Properties
    
    /// `UINavigationItem` 用於設置導航欄的標題
    private weak var navigationItem: UINavigationItem?
    
    /// `UINavigationController` 用於設置導航欄的大標題顯示模式
    private weak var navigationController: UINavigationController?
    
    // MARK: - Initializer
    
    /// 初始化方法
    /// - Parameters:
    ///   - navigationItem: 傳入的 `UINavigationItem`，用於設置導航欄
    ///   - navigationController: 傳入的 `UINavigationController`，用於設置大標題顯示模式
    init(navigationItem: UINavigationItem, navigationController: UINavigationController?) {
        self.navigationItem = navigationItem
        self.navigationController = navigationController
    }
    
    // MARK: - Setup NavigationBar
    
    /// 配置導航欄的標題與大標題顯示模式。
    /// - Parameters:
    ///   - title: 導航欄的標題文字。
    ///   - prefersLargeTitles: 是否啟用大標題模式，預設為 `true`。
    ///
    /// ### 設置流程
    /// 1. 將 `title` 設置為導航欄標題。
    /// 2. 設置 `largeTitleDisplayMode` 以控制當前頁面的大標題模式。
    /// 3. 更新 `UINavigationController` 的 `prefersLargeTitles` 屬性以統一風格。
    func configureNavigationBarTitle(title: String, prefersLargeTitles: Bool = true) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }
    
}
