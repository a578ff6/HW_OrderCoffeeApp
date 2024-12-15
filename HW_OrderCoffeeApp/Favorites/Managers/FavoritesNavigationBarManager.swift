//
//  FavoritesNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/14.
//

// MARK: - (v)

import UIKit

/// `FavoritesNavigationBarManager` 負責管理「我的最愛」頁面的導航欄配置，包括標題和大標題模式的設置。
/// - 設計目標：
///   1. 提供簡單明確的導航欄標題設置方法。
///   2. 減少主控制器中與導航欄相關的代碼，專注於業務邏輯。
class FavoritesNavigationBarManager {
    
    // MARK: - Properties
    
    /// `UINavigationItem` 用於設置導航欄的標題
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
    ///   - title: 導航欄的標題文字
    ///   - prefersLargeTitles: 是否啟用大標題模式，預設為 `true`
    func configureNavigationBarTitle(title: String, prefersLargeTitles: Bool = true) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }
    
}
