//
//  OrderHistoryNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - OrderHistoryNavigationBarManager 的設計與功能
/**
 ## OrderHistoryNavigationBarManager 的設計與功能
 
` 1.功能概述：`
 
 - `OrderHistoryNavigationBarManager` 是一個負責管理 `OrderHistory` 導航欄按鈕配置的類別。主要目的是將導航欄按鈕的邏輯與主視圖控制器分離，減少 `OrderHistoryViewController` 的責任。
 
 `2.設計決策：`

 - `責任分離與簡化視圖控制器`：這樣的設計有助於讓 `OrderHistoryViewController` 專注於視圖的展示和用戶操作，而 `OrderHistoryNavigationBarManager` 則專注於導航欄按鈕的設置和邏輯處理。
 - `弱引用避免循環引用`：所有的 `navigationItem`、`editingHandler`、`sortMenuHandler` 都設置為 weak，以避免強引用循環，導致記憶體泄漏。
 
 `3.主要方法與作用：`

 `* setupInitialNavigationBar()：`
    - 設置初始的導航欄按鈕，包括「排序」和「編輯」按鈕。這些按鈕通常在非編輯模式下顯示。
    - 編輯按鈕的啟用狀態根據是否有訂單進行設置（透過 `editingHandler.isOrderListEmpty()` 方法）。
    - 當訂單列表為空時，禁用編輯按鈕；當有可編輯的訂單時，啟用編輯按鈕。

 `* setupEditingNavigationBar()：`
    - 設置編輯模式下的導航欄按鈕，包括「完成」和「刪除」兩個按鈕，讓使用者在編輯模式下可以完成編輯或者刪除選中的訂單。
 
 `* editButtonTapped()：`
    - 處理「編輯/完成」按鈕的切換，當用戶點擊「編輯」時進入編輯模式，並切換按鈕為「完成」和「刪除」；當用戶點擊「完成」時退出編輯模式，恢復為初始狀態。
 
 `* deleteButtonTapped()：`
    -  處理「刪除」按鈕的動作，調用 editingHandler 來執行多選刪除的邏輯。
 
 
 `4. 編輯按鈕的啟用/禁用邏輯：`
 
 `* 初始化導航欄按鈕的狀態：`
    - 當首次設置導航欄按鈕時（如在視圖加載後），通過 `setupNavigationBar() `方法根據當前的訂單狀態設置編輯按鈕是否可用。
 
 `* 訂單數據的變化處理：`
    - 在 `OrderHistoryViewController` 中，每次訂單數據` (orders) `發生變化時，會調用 `updateEditButtonState()`，這個方法會通過` navigationBarManager?.setupInitialNavigationBar() `重新檢查並設置編輯按鈕的狀態，確保按鈕反映當前的訂單情況。
    - 這種方式確保了當所有訂單都被刪除後，編輯按鈕會被禁用，防止進入不應該的編輯狀態。
 
` 5.責任分離與模組化：`

 - `導航欄管理模組化`：`OrderHistoryNavigationBarManager` 獨立於主視圖控制器，使得導航邏輯更易於管理，並提高代碼的可讀性和可維護性。
 - `與其他處理器協作`：`OrderHistoryNavigationBarManager` 通過與 `OrderHistoryEditingHandler` 和 `SortMenuHandler` 協作，管理表格的編輯狀態及排序選單。
 
` 6.合作對象：`
 
 - `OrderHistoryEditingHandler`：
    - 負責管理表格的編輯模式和多選刪除操作，通過 `toggleEditingMode() `和 `deleteSelectedRows() `與 `OrderHistoryNavigationBarManager` 互動。
    - 編輯按鈕的狀態是基於 isOrderListEmpty() 來決定的，這使得按鈕的啟用狀態能動態反映當前的訂單情況。
 
 - `SortMenuHandler`：
    - 負責創建排序選單，通過` createSortMenu() `提供排序按鈕的菜單。方便用戶對歷史訂單進行不同方式的排序。 
 */

import UIKit

/// 負責 `OrderHistory` 導航欄按鈕的配置和更新
/// - 將導航欄按鈕的邏輯與主視圖控制器分離，使代碼更模組化、責任分離
class OrderHistoryNavigationBarManager {
    
    // MARK: - Properties

    /// `UINavigationItem` 用於設置導航欄上的按鈕
    private weak var navigationItem: UINavigationItem?
    
    /// 負責管理編輯模式的 `OrderHistoryEditingHandler`，處理多選和刪除邏輯
    private weak var editingHandler: OrderHistoryEditingHandler?
    
    /// 排序選單的處理器，用於創建排序選項
    private weak var sortMenuHandler: OrderHistorySortMenuHandler?

    // MARK: - Initialization

    /// 初始化方法
    /// - Parameters:
    ///   - navigationItem: 傳入的 `UINavigationItem`，用於管理導航欄上的按鈕
    ///   - editingHandler: 負責管理編輯模式的處理器
    ///   - sortMenuHandler: 負責創建排序選單的處理器
    init(navigationItem: UINavigationItem, editingHandler: OrderHistoryEditingHandler, sortMenuHandler: OrderHistorySortMenuHandler) {
        self.navigationItem = navigationItem
        self.editingHandler = editingHandler
        self.sortMenuHandler = sortMenuHandler
    }
    
    // MARK: - Setup NavigationBar
    
    /// 設置`初始`的導航欄按鈕
    /// - 包含「排序」和「編輯」按鈕，適合初始非編輯模式的情境
    func setupInitialNavigationBar() {
        // 設置排序按鈕
        guard let sortMenuHandler = sortMenuHandler else { return }
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), primaryAction: nil, menu: sortMenuHandler.createSortMenu())
        
        // 設置編輯按鈕，根據是否有訂單決定是否啟用
        guard let editingHandler = editingHandler else { return }
        let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil.and.list.clipboard"), style: .plain, target: self, action: #selector(editButtonTapped))
        editButton.isEnabled = !editingHandler.isOrderListEmpty()
        print("Setup Initial Navigation Bar - Edit Button is enabled: \(editButton.isEnabled)")

        navigationItem?.rightBarButtonItems = [sortButton, editButton]
    }
    
    /// 設置`編輯模式`下的導航欄按鈕
    /// - 包含「完成」和「刪除」按鈕，適合在進入編輯模式後使用
    func setupEditingNavigationBar() {
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .done, target: self, action: #selector(editButtonTapped))
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteButtonTapped))
        
        navigationItem?.rightBarButtonItems = [doneButton, deleteButton]
        print("Setup Editing Navigation Bar - Done Button added, Delete Button added")
    }
    
    // MARK: - Button Actions
    
    /// 處理「編輯/完成」按鈕的動作
    /// - 根據當前是否處於編輯模式，切換導航欄上的按鈕
    @objc private func editButtonTapped() {
        
        // 切換編輯模式
        editingHandler?.toggleEditingMode()
        
        // 根據當前編輯模式更新導航欄
        editingHandler?.isEditing == true ? setupEditingNavigationBar() : setupInitialNavigationBar()
        print("Edit button tapped - Current isEditing: \(editingHandler?.isEditing ?? false)")
    }
    
    /// 處理「刪除」按鈕的動作
    /// - 調用 `editingHandler` 來刪除選中的行
    @objc private func deleteButtonTapped() {
        editingHandler?.deleteSelectedRows()
        print("Delete button tapped - Attempted to delete selected rows")
    }
    
}
