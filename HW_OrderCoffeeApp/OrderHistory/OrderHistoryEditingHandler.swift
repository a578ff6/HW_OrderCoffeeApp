//
//  OrderHistoryEditingHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - OrderHistoryEditingHandler 的設計與功能
/**
 ## OrderHistoryEditingHandler 的設計與功能
 
 `* 功能概述：`
 
 - `OrderHistoryEditingHandler` 專門用於處理 `OrderHistory` 的編輯模式和多選刪除操作。它的主要責任是控制表格的編輯狀態，以及在多選模式下執行刪除操作。

 `* 設計決策：`

 - `分離責任`：將編輯模式的管理邏輯從主視圖控制器中提取出來，放到 `OrderHistoryEditingHandler` 中，這樣可以保持 `OrderHistoryViewController` 的職責單一，減少視圖控制器的臃腫，並提高代碼的可維護性。
 - `弱引用避免循環引用`：tableView 和 delegate 均設置為 weak，以避免強引用循環，導致記憶體泄漏。
 
 `* 主要方法與作用：`

 - `isEditing`：返回當前表格是否處於編輯模式，便於其他組件查詢當前狀態。
 - `toggleEditingMode()`：負責進入和退出編輯模式。透過切換編輯狀態，使得視圖的使用體驗更為靈活。
 - `deleteSelectedRows()`：處理多選刪除操作。包括通知代理刪除相應數據，並且更新表格視圖以反映更改。
 
 `* 責任分離與模組化：`

 - 將 `OrderHistoryEditingHandler` 作為獨立的模組，負責編輯模式和刪除操作，使得這些邏輯更加清晰可管理。
 - 與 `OrderHistoryDelegate` 代理合作，可以在處理數據的同時保持視圖的同步更新。
 
` * 合作對象：`

 - `OrderHistoryDelegate`：負責與數據源進行互動，執行實際的刪除操作。
 - `UITableView`：由 `OrderHistoryEditingHandler` 管理表格的編輯模式和刪除行的動畫。
 */

import UIKit

/// 負責管理`編輯模式`和`多選刪除`
/// - 主要責任是控制表格的編輯狀態，以及在多選模式下執行刪除操作。
class OrderHistoryEditingHandler {
    
    // MARK: - Properties

    /// 表格視圖，用於顯示歷史訂單的 UITableView
    private weak var tableView: UITableView?
    
    /// 代理，實現 `OrderHistoryDelegate` 協定，用於處理訂單相關操作
    /// - 例如刪除多筆訂單等
    private weak var delegate: OrderHistoryDelegate?
    
    // MARK: - Initialization

    /// 初始化方法，接受表格視圖和訂單代理
    /// - Parameters:
    ///   - tableView: 傳入的表格視圖，用於顯示訂單
    ///   - delegate: 傳入的代理，負責訂單操作
    init(tableView: UITableView, delegate: OrderHistoryDelegate) {
        self.tableView = tableView
        self.delegate = delegate
    }
    
    // MARK: - Edit Mode Methods
    
    /// 獲取當前是否處於編輯模式
    /// - Returns: 表示表格是否正在處於編輯模式
    var isEditing: Bool {
        return tableView?.isEditing ?? false
    }

    /// 切換表格的編輯模式
    /// - 說明：調用此方法以進入或退出編輯模式
    func toggleEditingMode() {
        guard let tableView = tableView else { return }
        let isEditing = !tableView.isEditing
        tableView.setEditing(isEditing, animated: true)
    }

    /// 刪除選擇的行
    /// - 說明：在編輯模式下，允許使用者多選並刪除訂單
    /// - 呼叫委託來刪除訂單，然後從表格視圖中刪除相應的行
    func deleteSelectedRows() {
        guard let tableView = tableView, let selectedRows = tableView.indexPathsForSelectedRows else { return }
        
        let indices = selectedRows.map { $0.row }
        // 通知代理刪除相應索引的訂單
        delegate?.deleteOrders(at: indices)
        // 從表格中刪除選中的行
        tableView.deleteRows(at: selectedRows, with: .automatic)
    }
    
}
