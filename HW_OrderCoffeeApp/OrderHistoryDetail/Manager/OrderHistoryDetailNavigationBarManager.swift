//
//  OrderHistoryDetailNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/14.
//

// MARK: - 重點筆記：OrderHistoryDetailNavigationBarManager

/**
 ## 重點筆記：OrderHistoryDetailNavigationBarManager
 
 `1.職責單一化`

 - `OrderHistoryDetailNavigationBarManager` 負責管理導航欄中的按鈕和標題，這使得 `OrderHistoryDetailViewController` 可以專注於顯示和處理訂單的邏輯。
 - 將導航欄管理的邏輯分離至一個單獨的 manager 類別，有助於提高代碼的可讀性和可維護性，避免主控制器過於臃腫。
 
 `2.弱引用避免循環引用`

 - 使用 `weak var navigationItem: UINavigationItem?`` 和 weak var navigationController: UINavigationController?` 是為了避免強引用循環（retain cycle）。
 - 這些引用是弱引用，因為 `OrderHistoryDetailNavigationBarManager` 不需要對導航欄擁有所有權，它只是幫助設置標題和按鈕。
 
 `3.設置導航欄標題`

 - `configureNavigationBarTitle(title:prefersLargeTitles:) `方法用於設置導航欄的標題和是否使用大標題顯示模式。
 - `navigationController?.navigationBar.prefersLargeTitles `讓整個應用風格更加一致，可以選擇是否在導航欄中顯示大標題。
 - 根據 `prefersLargeTitles` 的值決定是否啟用大標題顯示模式，靈活應對不同頁面的需求。
 
 `4.設置分享按鈕`

 - `setupShareButton(target:action:) `方法用於在導航欄上添加一個分享按鈕。這樣的設計允許調用者傳入 target 和 action，以決定按鈕點擊時要執行的動作。
 - 這樣讓主控制器能將分享行為以委託方式給 `OrderHistoryDetailSharingHandler` 等其他處理程序來完成。
 
 `5.設計的好處`

 - `職責分離`：將導航欄的設置和行為邏輯分離到專門的 manager 中，這樣 `OrderHistoryDetailViewController` 可以更加關注業務邏輯，提升其可讀性和維護性。
 - `提高可重用性`：`OrderHistoryDetailNavigationBarManager` 的設計使得它可以輕易重用於其他類似需要管理導航欄的控制器中。
 - `保持一致的導航欄設置`：確保不同控制器的導航欄設定風格一致，可以在應用程序中提供更一致的用戶體驗。
 
 `6.使用情境`

 - 在 `OrderHistoryDetailViewController` 中，可以透過 `OrderHistoryDetailNavigationBarManager` 來設定標題和按鈕，而不是直接修改 navigationItem。這讓代碼更加結構化和易於維護。
 - 可以通過這個 manager 的方法來設置不同場景下的導航標題和按鈕，比如在訂單詳情頁面設置分享按鈕，以便用戶可以快速分享訂單信息。
 */

import UIKit

/// 管理 `OrderHistoryDetailViewController` 的導航欄按鈕和標題
class OrderHistoryDetailNavigationBarManager {
    
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
    
    /// 設置分享按鈕
    /// - Parameters:
    ///   - target: 按鈕的 target 對象
    ///   - action: 按鈕的操作
    func setupShareButton(target: Any, action: Selector) {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: target, action: action)
        navigationItem?.rightBarButtonItem = shareButton
    }
}
