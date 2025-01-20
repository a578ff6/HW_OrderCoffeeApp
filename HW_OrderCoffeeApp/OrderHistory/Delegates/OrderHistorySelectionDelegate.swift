//
//  OrderHistorySelectionDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/16.
//

// MARK: - OrderHistorySelectionDelegate 筆記
/**
 
 ### OrderHistorySelectionDelegate 筆記

 ---

 `* What`
 
 - `OrderHistorySelectionDelegate` 是一個負責處理表格視圖 (`UITableView`) 中「選取狀態變更」的協定 (Protocol)。
 
 - 當使用者在編輯模式下選取或取消選取行時，通知代理物件進行狀態更新，例如：
    - 更新導航欄按鈕（例如「刪除」按鈕）的啟用或禁用。

 ----------

 `* Why `
 
 1. 解耦邏輯：
 
    - 將表格的「選取狀態變更」邏輯從具體實作中抽離，統一交由代理處理，提升代碼模組化與可讀性。
    - 減少 `UITableView` 與其他邏輯之間的耦合，符合單一責任原則。

 2. 增強靈活性：
 
    - 可以根據具體場景（如導航欄按鈕、提示狀態）自由擴展，適應不同的 UI 或功能需求。

 3. 提升效率：
 
    - 利用協定方法，減少重複檢查選取行狀態的邏輯，降低性能負擔。

 4. 易於測試與維護：
    - 通過協定，將狀態變更與 UI 更新解耦，便於單元測試與功能擴展。

 ----------

 `* How`

 1. 定義協定
 
 - 定義協定並加入 `hasSelection` 參數，用於傳遞當前是否有選取行的狀態：
 
 ```swift
 protocol OrderHistorySelectionDelegate: AnyObject {
     /// 通知表格視圖的選取狀態變更
     /// - Parameter hasSelection: 是否有選取行，`true` 表示至少有一行被選取。
     func didChangeSelectionState(hasSelection: Bool)
 }
 ```

 ---
 
 2. 在 Handler 中呼叫協定
 
 - 在表格的選取邏輯中 (`UITableViewDelegate`) 呼叫協定方法：
 
 ```swift
 extension OrderHistoryHandler: UITableViewDelegate {
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         handleSelectionStateChange(for: tableView, isSelected: true)
     }
     
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
         handleSelectionStateChange(for: tableView, isSelected: false)
     }
     
     private func handleSelectionStateChange(for tableView: UITableView, isSelected: Bool) {
         let hasSelection = tableView.indexPathsForSelectedRows?.isEmpty == false
         orderHistorySelectionDelegate?.didChangeSelectionState(hasSelection: hasSelection)
     }
 }
 ```

 ---

 3. 代理物件實現協定
 
 - 在 `OrderHistoryViewController` 中實現協定，根據 `hasSelection` 更新導航欄按鈕狀態：
 
 ```swift
 extension OrderHistoryViewController: OrderHistorySelectionDelegate {
     func didChangeSelectionState(hasSelection: Bool) {
         orderHistoryNavigationBarManager?.updateNavigationBar(for: .editing(hasSelection: hasSelection))
     }
 }
 ```

 ---

 4. 設置代理
 
 - 初始化 `OrderHistoryHandler` 時，將 `OrderHistoryViewController` 設為其代理：
 
 ```swift
 private func setupOrderHistoryHandler() {
     let handler = OrderHistoryHandler(
         orderHistoryDataDelegate: self,
         orderHistorySelectionDelegate: self,
         orderHistoryNavigationDelegate: self
     )
     self.orderHistoryHandler = handler
     configureTableView(with: handler)
 }
 ```

 ----------

 `* 總結 (Summary)`

 - What：
    
    - `OrderHistorySelectionDelegate` 負責通知「表格選取狀態變更」，以便進行狀態更新。
 
 - Why：
 
   1. 符合單一責任原則，降低耦合。
   2. 提升靈活性，適應不同的場景需求。
   3. 減少重複邏輯，提升性能與可維護性。
 
 - How：
 
   1. 定義協定並加入 `hasSelection` 參數。
   2. 在表格的選取事件中調用協定方法。
   3. 實現協定以處理導航欄或其他 UI 的更新邏輯。
   4. 設置代理以完成責任分配。

 */



// MARK: - (v)

import Foundation


/// `OrderHistorySelectionDelegate`
///
/// 此協定負責處理表格視圖中「選取狀態」變更的通知邏輯。
///
/// - 使用場景：
///   1. 當表格視圖進入`編輯模式`，使用者`選取`或`取消選取行`時，透過該協定通知代理物件進行相關處理。
///   2. 通知代理物件根據當前的選取狀態更新 UI 或執行相應的邏輯，例如更新導航欄按鈕的啟用狀態。
///
/// - 設計考量：
///   1. `hasSelection` 參數明確傳遞當前是否有選取行，減少重複邏輯，提升效能。
///   2. 將「計算選取狀態」的責任交由觸發方，代理物件僅專注於執行響應操作。
///
/// - 實作範例：
///   在 `UITableViewDelegate` 的 `didSelectRowAt` 與 `didDeselectRowAt` 方法中呼叫此協定方法。
protocol OrderHistorySelectionDelegate: AnyObject {
    
    /// 通知表格視圖的選取狀態變更
    ///
    /// - Parameters:
    ///   - hasSelection: 當前是否有選取行，`true` 表示至少有一行被選取，`false` 表示沒有任何選取行。
    ///
    /// - 使用範例：在`編輯模式`下，當使用者選取或取消選取行時，觸發此方法以通知委託物件更新相關按鈕狀態（例如啟用或禁用「刪除」按鈕）。
    func didChangeSelectionState(hasSelection: Bool)
    
}
