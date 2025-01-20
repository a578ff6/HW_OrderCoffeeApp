//
//  OrderHistoryEditingHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - toggleEditingMode() 筆記
/**
 
 ## toggleEditingMode() 筆記

 ---

 `* What`
 
 - `toggleEditingMode()` 是一個用於切換表格編輯模式的核心方法，並返回當前的編輯狀態 (`OrderHistoryEditingState`)：

 1. 功能：
 
    - 切換表格的編輯模式（進入或退出）。
    - 計算當前的選中行狀態（是否有選中的行）。
    - 返回具體的編輯狀態（正常模式或編輯模式），供其他組件使用。

 2. 輸出：
 
    - 返回一個 `OrderHistoryEditingState`：
      - `.normal`：表格處於普通模式。
      - `.editing(hasSelection: Bool)`：表格處於編輯模式，並告知是否有選中的行。

 ---------

 `* Why`
 
 1. 集中管理編輯邏輯：
 
    - 編輯模式涉及多個操作（如切換狀態、更新表格、計算選中行），集中在一個方法中能減少邏輯分散，提高可維護性。

 2. 支持狀態同步：
 
    - 方法返回編輯狀態，使其他組件（如導航欄管理器）能根據此狀態更新界面（例如切換按鈕樣式）。

 3. 簡化其他組件的邏輯：
 
    - 將編輯邏輯完全封裝在 `OrderHistoryEditingHandler` 中，其他組件只需使用返回的狀態來執行對應操作，而不需要了解編輯模式的具體實現細節。

 4. 提高可測試性與擴展性：
 
    - 返回值模式便於單元測試，可以輕鬆驗證切換結果。
    - 未來若增加更多編輯模式的邏輯，只需擴展此方法，而不會影響其他組件。

 ---------

 `* How `

 1. 方法邏輯：
 
    - 確保表格存在，若不存在則返回 `.normal` 狀態。
    - 切換表格的 `isEditing` 屬性，並更新狀態。
    - 根據是否進入編輯模式計算選中行的狀態：
      - 進入編輯模式時計算選中的行數。
      - 退出編輯模式時將選中狀態設為 `false`。
    - 返回對應的編輯狀態。

 ---

 2. 程式碼：
 
    ```swift
    func toggleEditingMode() -> OrderHistoryEditingState {
        guard let tableView = tableView else { return .normal }
        let isEditing = !tableView.isEditing
        tableView.setEditing(isEditing, animated: true)
        let hasSelection = isEditing ? hasSelectedRows() : false
        return isEditing ? .editing(hasSelection: hasSelection) : .normal
    }
    ```

 ---

 3. 使用範例：
 
    - 在導航欄管理器中，結合該方法更新按鈕：
 
    ```swift
    @objc private func editButtonTapped() {
        // 通過 EditingHandler 切換模式並獲取當前狀態
        let newState = orderHistoryEditingHandler?.toggleEditingMode() ?? .normal
        
        // 根據新狀態更新導航欄按鈕
        updateNavigationBar(for: newState)
    }
    ```

 ---
 
 4. 優化設計的關鍵點：
 
    - 封裝性： 切換邏輯完全隱藏，其他組件僅需處理返回值。
    - 靈活性： 返回值可靈活擴展，例如未來可新增更多編輯模式狀態。
    - 高效性： 結合選中行計算，減少了冗餘操作。

 ---------

 `* 結論`
 
 - `toggleEditingMode()` 是一個 **封裝性高**、**靈活可擴展** 的狀態管理方法，能夠有效簡化其他組件（如導航欄管理器）的邏輯，並提供統一的編輯模式切換入口，適合多場景下的表格編輯邏輯需求。
 */


// MARK: - OrderHistoryEditingHandler 筆記
/**
 
 ## OrderHistoryEditingHandler 筆記

 
 `* What`
 
 - `OrderHistoryEditingHandler` 是一個負責管理「編輯模式」與「多選刪除」功能的類別。
 
 1. 編輯模式管理：
 
    - 控制 `UITableView` 的進入和退出編輯模式。
    - 提供 `isEditing` 狀態檢查，確保表格視圖的狀態與邏輯一致。
 
 2. 選中狀態檢查：
 
    - 提供方法檢查訂單列表是否為空 (`isOrderListEmpty`)。
    - 提供方法確認是否有選中的行 (`hasSelectedRows`)。
 
 3. 多選刪除操作：
 
    - 支援在編輯模式下刪除多個選中的訂單。
    - 通知數據層更新資料，並同步更新表格視圖。

 -------

 `* Why`
 
 1. 分離職責、提升可讀性：
 
    - 將與`編輯模式`及`刪除相關`的邏輯從控制器中抽離，避免控制器過於臃腫，提升代碼的可讀性與維護性。
 
 2. 單一責任原則 (SRP)：
 
    - 將表格視圖的「編輯模式管理」和「多選刪除邏輯」集中在單一類別中，避免與其他業務邏輯混雜。
 
 3. 模組化設計、增強重用性：
 
    - 該處理器可以方便地適配其他表格視圖，只需提供對應的數據代理即可使用，提升模組重用性。
 
 4. 增強協作性：
 
    - 通過與 `OrderHistoryDataDelegate` 和導航欄管理器 (`OrderHistoryNavigationBarManager`) 的交互，確保數據、視圖和導航邏輯的一致性。
 
 5. 動態管理按鈕狀態：
 
    - 通過檢查列表與選中狀態（例如「刪除」按鈕啟用/禁用），提升用戶體驗。

 -------

 `* How`
 
 1. 編輯模式管理：
 
    - 使用 `toggleEditingMode()` 切換編輯模式，更新表格的 `isEditing` 屬性，並返回當前的編輯狀態：
      - `.normal`：正常模式。
      - `.editing(hasSelection: Bool)`：編輯模式（包含是否有選中的行）。
 
    - 通過 `isEditing` 屬性檢查表格當前是否處於編輯模式。

 ---
 
 2. 選中狀態檢查：
 
    - 檢查訂單是否為空：
    - 用於導航欄按鈕（如「編輯模式」按鈕）的啟用與禁用控制。

      ```swift
      func isOrderListEmpty() -> Bool {
          return orderHistoryDataDelegate?.getOrders().isEmpty ?? true
      }
      ```

    - 檢查是否有選中行：
    - 用於控制「刪除」按鈕的啟用狀態。

      ```swift
      func hasSelectedRows() -> Bool {
          let selectedRows = tableView?.indexPathsForSelectedRows
          return !(selectedRows?.isEmpty ?? true)
      }
      ```

 ---

 3. 多選刪除操作：
 
    - 在編輯模式下，通過 `deleteSelectedRows()` 刪除選中的行：
    - 通知數據代理更新訂單數據。
    - 刪除後同步更新表格視圖的行。
 
      ```swift
      func deleteSelectedRows() {
          guard let tableView = tableView, let selectedRows = tableView.indexPathsForSelectedRows else { return }
          let indices = selectedRows.map { $0.row }
          orderHistoryDataDelegate?.deleteOrders(at: indices)
          tableView.deleteRows(at: selectedRows, with: .automatic)
      }
      ```

 ---

 4. 整體協作流程：
 
    - 該類與 `OrderHistoryNavigationBarManager` 和 `OrderHistoryDataDelegate` 協作：
 
      1. 檢查列表與選中狀態，更新導航欄按鈕。
      2. 通過委託刪除數據，並同步表格顯示。

 -------

 `* 結論`
 
 - `OrderHistoryEditingHandler` 適用於需要在表格中進行編輯、檢查狀態及刪除選中行的場景。
 
 1. 主要方法與作用：

 - `isTableEditing`：返回當前表格是否處於編輯模式，便於其他組件查詢當前狀態，特別是在更新導航欄按鈕狀態時使用。
 - `toggleEditingMode()`：負責進入和退出編輯模式。透過切換編輯狀態，使得視圖的使用體驗更為靈活。
 - `deleteSelectedRows()`：處理多選刪除操作。包括通知代理刪除相應數據，並且更新表格視圖以反映更改。
 - `isOrderListEmpty()`：檢查訂單列表是否為空，讓其他組件（例如 `OrderHistoryNavigationBarManager`）可以根據這個狀態動態調整編輯按鈕的啟用狀態。
 - `hasSelectedRows()`：檢查當前是否有被選中的行。在編輯模式下，此方法可幫助確定是否啟用「刪除」按鈕，以及其他依賴於行選擇的操作。
 
 2. 合作對象：

 - `OrderHistoryDelegate`：：
 
    - 負責與數據源進行互動，執行實際的刪除操作。
    - 例如，`deleteOrders(at:)` 方法會被調用來刪除本地資料和 Firebase 中的資料，確保資料同步。
 
 - `UITableView`：
 
    - 由 `OrderHistoryEditingHandler` 管理表格的編輯模式和刪除行的動畫。
    - 當進入或退出編輯模式時，`UITableView` 的狀態會根據 `toggleEditingMode()` 方法來變化。
 
 3. 編輯按鈕狀態的關聯設置：

 - `與 OrderHistoryNavigationBarManager 協作`：
 
    - `OrderHistoryEditingHandler` 與 `OrderHistoryNavigationBarManager` 協作，管理編輯模式和導航欄按鈕的狀態。
    - 當` isOrderListEmpty() `返回 true 時，`OrderHistoryNavigationBarManager` 中的編輯按鈕會被禁用，反之則啟用。
 
 - `編輯模式自動禁用`：
 
    - 當用戶刪除所有訂單後，編輯模式也會自動禁用，並更新導航欄按鈕的狀態，使使用者無法進入空訂單的編輯模式。
 
 -  `選擇行狀態影響刪除按鈕`：
 
    - `hasSelectedRows() `允許動態啟用或禁用「刪除」按鈕。
    - 當表格中沒有選中任何行時，「刪除」按鈕應被禁用，以防止用戶誤操作。
 */






// MARK: - (v)

import UIKit


/// `OrderHistoryEditingHandler`
///
/// 負責管理「編輯模式」及「多選刪除操作」的邏輯。
///
/// ### 職責範圍
/// - 控制表格視圖進入或退出編輯模式，維持與 `UITableView` 的互動一致性。
/// - `檢查訂單資料`與`選中狀態`，為導航欄按鈕（如「刪除」按鈕）啟用/禁用提供支持。
/// - 實現多選刪除功能，通過代理協議與數據層互動更新視圖。
///
/// ### 為何需要
/// - 分離邏輯與視圖：將`編輯模式`和`刪除操作`的邏輯從控制器中抽離，簡化控制器代碼，提升可維護性。
/// - 集中處理狀態邏輯：集中管理與表格視圖編輯相關的狀態（如是否處於編輯模式、是否有選中項）。
/// - 增強重用性：通過委託與視圖交互，使該邏輯模組化，可在其他具有類似需求的場景中重用。
///
/// ### 功能概述
///
/// - 編輯模式管理
///   - 提供 `isEditing` 屬性以檢查當前表格狀態。
///   - 提供 `toggleEditingMode()` 方法切換編輯模式並返回當前狀態。
///
/// - 選中狀態檢查
///   - `isOrderListEmpty()`：檢查訂單列表是否為空，決定是否啟用「編輯模式」按鈕。
///   - `hasSelectedRows()`：檢查是否有選中行，決定是否啟用「刪除」按鈕。
///
/// - 多選刪除
///   - 提供 `deleteSelectedRows()` 方法實現多選刪除，通過委託更新數據並同步視圖。
///
/// ### 典型使用場景
/// - 與 `OrderHistoryNavigationBarManager` 配合，根據選中狀態動態更新導航欄按鈕（如「刪除」或「完成」）。
/// - 支持 `UITableView` 的編輯操作，包括進入編輯模式、多選、刪除選中項。
class OrderHistoryEditingHandler {
    
    // MARK: - Properties
    
    /// 表格視圖，用於顯示歷史訂單的 `UITableView`
    ///
    /// - 與表格進行互動，例如切換編輯模式、刪除選中行等操作。
    private weak var tableView: UITableView?
    
    /// 代理，用於與數據層交互的協議
    ///
    /// - 提供數據操作方法（如刪除訂單），用於處理訂單相關操作
    private weak var orderHistoryDataDelegate: OrderHistoryDataDelegate?
    
    // MARK: - Initialization
    
    /// 初始化方法，接受表格視圖和數據代理。
    ///
    /// - Parameters:
    ///   - tableView: `UITableView` 實例，處理編輯和多選操作。
    ///   - orderHistoryDataDelegate: 符合 `OrderHistoryDataDelegate` 協議的代理。
    init(
        tableView: UITableView,
        orderHistoryDataDelegate: OrderHistoryDataDelegate
    ) {
        self.tableView = tableView
        self.orderHistoryDataDelegate = orderHistoryDataDelegate
    }
    
    // MARK: - Edit Mode Management
    
    /// 當前是否處於`編輯模式`
    ///
    /// - Returns: 如果表格正在`編輯模式`，返回 `true`；否則返回 `false`。
    var isTableEditing: Bool {
        return tableView?.isEditing ?? false
    }
    
    /// 切換表格的編輯模式
    ///
    /// - 說明：
    ///   - 如果當前表格處於正常模式（未編輯），則啟用編輯模式。
    ///   - 如果當前表格已處於編輯模式，則退出編輯模式。
    ///   - 方法會更新表格的編輯狀態，並返回新的 `OrderHistoryEditingState`，用於同步 UI 或其他狀態。
    ///
    /// - Returns: 編輯模式的狀態：
    ///   - `.normal`：正常模式（編輯模式已關閉）。
    ///   - `.editing(hasSelection: Bool)`：編輯模式（包括是否有選中的行）。
    func toggleEditingMode() -> OrderHistoryEditingState {
        guard let tableView = tableView else { return .normal }
        let isEditing = !tableView.isEditing
        tableView.setEditing(isEditing, animated: true)
        let hasSelection = isEditing ? hasSelectedRows() : false
        return isEditing ? .editing(hasSelection: hasSelection) : .normal
    }
    
    // MARK: - Row Deletion Methods
    
    /// 刪除選中的行
    ///
    /// - 說明：
    ///   - 在編輯模式下，允許多選並刪除選中項。
    ///   - 通過代理通知數據層刪除選中項，並同步更新表格視圖。
    func deleteSelectedRows() {
        guard let tableView = tableView, let selectedRows = tableView.indexPathsForSelectedRows else { return }
        
        let indices = selectedRows.map { $0.row }
        orderHistoryDataDelegate?.deleteOrders(at: indices)
        tableView.deleteRows(at: selectedRows, with: .automatic)
    }
    
    // MARK: - Public Method _ Data State Checks
    
    /// 確認訂單列表是否為空
    ///
    /// - Returns: 如果訂單列表為空返回 `true`；否則返回 `false`。
    /// - 使用場景：
    ///   - 決定是否啟用「編輯模式」按鈕。
    func isOrderListEmpty() -> Bool {
        return orderHistoryDataDelegate?.getOrders().isEmpty ?? true
    }
    
    // MARK: - Private Method _ Data State Checks
    
    /// 確認是否有選中的行
    ///
    /// - Returns: 如果有選中的行返回 `true`；否則返回 `false`。
    /// - 使用場景：
    ///   - 此方法在`編輯模式`下用於檢查使用者是否選擇了任何行，並可以進一步決定是否啟用「刪除」按鈕。
    private func hasSelectedRows() -> Bool {
        let selectedRows = tableView?.indexPathsForSelectedRows
        print("[OrderHistoryEditingHandler]: Currently selected rows: \(String(describing: selectedRows))")
        return !(selectedRows?.isEmpty ?? true)
    }
    
}
