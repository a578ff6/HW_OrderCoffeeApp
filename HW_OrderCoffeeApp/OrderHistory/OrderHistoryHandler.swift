//
//  OrderHistoryHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - OrderHistoryHandler 重點筆記
/**
 ## OrderHistoryHandler 重點筆記

 `* 概述`
 
 - `功能`：`OrderHistoryHandler` 是專門用於處理訂單歷史紀錄表格視圖的資料處理器，負責 UITableView 的資料源和委託邏輯。
 - `資料源 (UITableViewDataSource)`：提供表格視圖的數據顯示，確保訂單資料能夠正確展示。
 - `委託 (UITableViewDelegate)`：處理表格視圖的互動行為，例如滑動刪除、多選刪除，以及導航至詳細頁面等操作。
 
 `* 結構`
 
 `1.Properties：`
 
 `* delegate：`
    - 用途：用於提供訂單資料的代理，符合 `OrderHistoryDelegate` 協定。
    - 弱引用 (weak)：防止循環引用，保持合理的內存管理。在 `OrderHistoryHandler` 和 `OrderHistoryViewController` 之間互相依賴的情況下。
 
 `2.初始化：`
    - `初始化方法 (init(delegate:))`：接受一個 `OrderHistoryDelegate` 類型的代理，負責在初始化時設定訂單資料的來源。
 
 `3.UITableViewDataSource 實作：`

` * tableView(_:numberOfRowsInSection:)：`
    - 返回特定部分的行數，根據 delegate 提供的訂單數量來決定。
 
 `* tableView(_:cellForRowAt:)：`
    - 重用 Cell：使用 `dequeueReusableCell` 重複使用已存在的 `OrderHistoryCell`，提升效能。
    - 資料配置：透過 delegate 獲取訂單資料，並配置 Cell 顯示訂單的各項資訊（例如顧客姓名、取件方式等）。
    - 如果無法獲取到訂單資料，返回一個空的 UITableViewCell。
 
` 4.UITableViewDelegate 實作：`

` * 滑動刪除行：`
    - `tableView(_:commit:forRowAt:)`：實作滑動刪除行的功能，透過委託通知 `OrderHistoryViewController` 刪除本地和遠端的訂單資料，並從表格中移除該行。
 
 `* 多選刪除行：`
 
    - `tableView(_:didSelectRowAt:)`：在選取某行時，根據當前模式進行不同的操作。
        - 在編輯模式下，處理多選狀態變更並通知 delegate 更新導航欄按鈕狀態。
        - 在正常模式下，導航至訂單的詳細頁面。
 
    - `tableView(_:didDeselectRowAt:)`：在編輯模式下，處理取消選擇行的操作，並通知 `delegate` 選取狀態變更。

    - `deleteSelectedRows(from:)`：處理多選刪除的功能，透過委託通知 `OrderHistoryViewController` 刪除指定的多筆訂單，並從表格中刪除相應行。
 
 `* 重點設計`
 
 `1.資料分離設計：`
    - `OrderHistoryHandler` 與 `OrderHistoryViewController` 之間透過 `OrderHistoryDelegate` 來進行資料的分離和通信，使得控制器的責任減少，專注於資料展示邏輯。
 
` 2.弱引用委託：`
    - 使用 weak var delegate，防止循環引用，特別是在 `OrderHistoryHandler` 和 `OrderHistoryViewController` 之間的相互依賴情況下。
 
 `3.資料驅動：`
    - 當訂單資料發生變化時，由 `OrderHistoryViewController` 通知 `OrderHistoryHandler`，並通過` reloadData() `重新加載數據，確保 UI 與資料同步。
 
 `4.選取狀態管理：`
     - `didChangeSelectionState()` 方法來管理選取狀態的變更，當使用者在編輯模式下選取或取消選取行時通知控制器更新導航欄按鈕的狀態，特別是「刪除」按鈕的啟用狀態。
     - 用途：通知 `OrderHistoryViewController` 更新導航欄按鈕的狀態（例如「刪除」按鈕的啟用與禁用），確保按鈕的狀態與選取狀態保持一致。
     -  didSelectRowAt 可以根據模式來處理多選或導航行為，進一步提升了用戶體驗和邏輯的一致性。
 */


import UIKit

/// `OrderHistoryHandler` 是處理歷史訂單表格視圖數據和委託的類別。
/// - 負責表格視圖的數據源 (`UITableViewDataSource`) 以及與 `OrderHistoryDelegate` 的協作。
/// - 確保訂單資料能夠正確顯示在表格視圖中。
class OrderHistoryHandler: NSObject {
    
    // MARK: - Properties
    
    /// 代理，用於提供訂單資料。`delegate` 符合 `OrderHistoryDelegate` 協定，以提供需要顯示的資料
    weak var delegate: OrderHistoryDelegate?
    
    // MARK: - Initialization
    
    /// 初始化方法，接受一個 `OrderHistoryDelegate` 代理
    /// - Parameter delegate: 傳入的委託，用於提供訂單資料
    init(delegate: OrderHistoryDelegate?) {
        self.delegate = delegate
    }
}

 // MARK: - UITableViewDataSource
extension OrderHistoryHandler: UITableViewDataSource {
    
    /// 返回指定部分的行數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getOrders().count ?? 0
    }
    
    /// 返回特定行的 `UITableViewCell`
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let orders = delegate?.getOrders() else {
            return UITableViewCell()        // 若無資料，返回一個空的 Cell
        }
        
        // OrderHistoryCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryCell.reuseIdentifier, for: indexPath) as? OrderHistoryCell else {
            fatalError("Cannot create OrderHistoryCell")
        }
        // 根據訂單資料配置 Cell
        let order = orders[indexPath.row]
        cell.configure(with: order)
        return cell
    }
}

 // MARK: - UITableViewDataSource
extension OrderHistoryHandler: UITableViewDelegate {
    
    /// 支援滑動刪除行的功能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // 通知委託刪除訂單資料
        delegate?.deleteOrder(at: indexPath.row)
        
        // 從表格視圖中刪除相應行
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Selection State Changes (選取狀態變更)
 
    /// 在選取某行時處理`多選狀態變更`或`導航行為`
    /// - 說明：根據當前模式（編輯模式或正常模式）進行不同的操作。
    ///   - 如果在編輯模式下選取行，通知 `delegate` 以便更新導航欄按鈕（例如啟用/禁用「刪除」按鈕）。
    ///   - 如果在正常模式下選取行，則導航至該訂單的詳細頁面。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            delegate?.didChangeSelectionState()
        } else {
            guard let orders = delegate?.getOrders() else { return }
            let selectedOrder = orders[indexPath.row]
            delegate?.navigateToOrderHistoryDetail(with: selectedOrder)
        }
    }
    
    /// 在編輯模式下，當取消選取某行時處理多選狀態變更
    /// - 說明：通知 `delegate`，以便更新導航欄按鈕（例如啟用/禁用「刪除」按鈕）
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        delegate?.didChangeSelectionState()
    }
    
    // MARK: - Batch Deletion (多選刪除)

    /// 處理多選刪除操作
    /// - Parameter tableView: 目標表格視圖
    func deleteSelectedRows(from tableView: UITableView) {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return }

        /// 取得選中行的索引
        let indices = selectedRows.map { $0.row }
        /// 通知委託進行多筆訂單的刪除
        delegate?.deleteOrders(at: indices)
        /// 刪除表格中的相應行
        tableView.deleteRows(at: selectedRows, with: .automatic)
    }
}
