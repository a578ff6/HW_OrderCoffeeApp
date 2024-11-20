//
//  SearchNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/20.
//

import UIKit

/// 管理 `SearchViewController` 的導航欄按鈕和標題
class SearchNavigationBarManager {
    
    // MARK: - Properties

    /// `UINavigationItem` 用於管理導航欄上的按鈕和標題
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

    /// 設置導航欄標題和大標題顯示模式
    /// - Parameters:
    ///   - title: 要顯示的導航標題
    ///   - prefersLargeTitles: 是否顯示大標題
    func configureNavigationBarTitle(title: String, prefersLargeTitles: Bool = true) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }
    
}
