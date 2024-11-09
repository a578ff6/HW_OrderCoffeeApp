//
//  OrderHistoryView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - OrderHistoryView 重點筆記

/**
 
 `* 概述：`
 
 - `OrderHistoryView` 是一個自定義視圖，包含用於顯示歷史訂單的 UITableView。
 - 提供了動態行高的支持，以便根據訂單資料自動調整行高。
 
` * 重點設計：`

 `1. 自動行高：`
    - `ableView.rowHeight = UITableView.automaticDimension`：設置行高為自動計算，允許根據內容動態調整。
    - `tableView.estimatedRowHeight = 60`：設置行高的預估值，幫助表格視圖提前優化佈局和提高滾動性能。
 
` 2. 統一配置：`
    - createTableView() 為表格視圖的創建和配置提供了一個統一的方法，確保每次初始化表格視圖時的設置是一致的。
 
 `3. 佈局和約束管理：`
    - 使用 Auto Layout 約束 (NSLayoutConstraint.activate) 來確保 tableView 填滿整個 OrderHistoryView，使得視圖可以在不同設備和尺寸下自適應。
 */


// MARK: - 關於設置 rowHeight 和 estimatedRowHeight：
/**
 ## 關於設置 rowHeight 和 estimatedRowHeight：
 
 `1. rowHeight 設置為 UITableView.automaticDimension：`
 
    - 表示表格視圖的行高是自動計算的，基於內容和布局約束來確定每一行的高度。這通常用於支持動態高度的 Cell，尤其是當 Cell 的內容（如文本）長度不固定時。

 `2. estimatedRowHeight 設置為一個預估的值：`
 
    - `estimatedRowHeight` 為 UITableView 提供一個估算的行高，幫助它提前計算和優化捲動的性能。如果不設置，UITableView 可能會花較多的時間來計算整個表格的佈局。
    - 通常來說，設置一個大致的預估高度，比如 60，能夠幫助 UITableView 更流暢地加載和捲動。
 */

import UIKit

/// 自定義視圖，包含用於顯示歷史訂單的 UITableView。
class OrderHistoryView: UIView {

    // MARK: - UI Elements
    
    /// 用於顯示歷史訂單的 UITableView
    let tableView = OrderHistoryView.createTableView()
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCells()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置表格的佈局，使表格填滿整個視圖
    private func setupLayout() {
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊表格視圖使用的 Cell 類型
    private func registerCells() {
        tableView.register(OrderHistoryCell.self, forCellReuseIdentifier: OrderHistoryCell.reuseIdentifier)
    }

    // MARK: - Factory Methods

    /// 建立並配置表格視圖
    private static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.alwaysBounceVertical = true                       // 總是允許垂直捲動
        tableView.showsVerticalScrollIndicator = false              // 隱藏垂直捲動條
        tableView.allowsMultipleSelectionDuringEditing = true       // 允許編輯模式下多選
        tableView.rowHeight = UITableView.automaticDimension        // 行高自動調整
        tableView.estimatedRowHeight = 60                           // 行高的預估值，幫助優化佈局
        return tableView
    }
}
