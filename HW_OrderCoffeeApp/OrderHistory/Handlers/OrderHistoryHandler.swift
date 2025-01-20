//
//  OrderHistoryHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - OrderHistoryHandler 筆記
/**
 
 ## OrderHistoryHandler 筆記

 `* What`
 
 - `OrderHistoryHandler` 是一個處理歷史訂單頁面表格視圖邏輯的類別，負責：
 
 1. 提供表格視圖數據源（`UITableViewDataSource`）實作，確保訂單資料正確顯示。
 2. 實現表格視圖委託（`UITableViewDelegate`），處理行選取、滑動刪除等用戶交互。
 3. 與多個代理協作，包括資料操作、選取狀態變更及導航邏輯。

 ----------

 `* Why`
 
 1. 模組化邏輯：
 
    - 將表格數據及行為邏輯從 `ViewController` 中抽離，減少控制器的複雜度，提升可維護性。
 
 2. 解耦數據層與視圖層：
 
    - 透過 `OrderHistoryDataDelegate`、`OrderHistorySelectionDelegate`、`OrderHistoryNavigationDelegate` 等協議，實現數據邏輯與視圖行為的清晰分工。
 
 3. 靈活性與重用性：
 
    - 支援多種交互邏輯（如選取、刪除、導航），適用於其他類似的表格視圖場景。
 
 4. 狀態驅動的交互：
 
    - 基於表格視圖的狀態（例如`編輯模式`或`正常模式`）動態執行相應邏輯。

 ----------

 `* How `

 1. 數據源（`UITableViewDataSource`）：
 
    - `numberOfRowsInSection`：透過 `OrderHistoryDataDelegate` 提供的 `getOrders()` 方法，返回訂單數量。
    - `cellForRowAt`：根據索引路徑配置並返回 `OrderHistoryCell`，顯示對應的訂單資訊。

 2. 行為邏輯（`UITableViewDelegate`）：
 
    - `commit editingStyle`：支援滑動刪除功能，透過 `deleteOrder(at:)` 通知代理刪除數據，並同步更新表格。
 
    - `didSelectRowAt` 和 `didDeselectRowAt`：根據行的選取或取消選取，執行不同邏輯：
      - 編輯模式：透過 `OrderHistorySelectionDelegate` 通知選取狀態變更（如啟用或禁用刪除按鈕）。
      - 正常模式：透過 `OrderHistoryNavigationDelegate` 導航至選定訂單的詳細頁面。

 3. 選取狀態處理：
 
    - `handleSelectionStateChange` 方法：
      - 編輯模式：計算是否有選取行，並通知 `OrderHistorySelectionDelegate`。
      - 正常模式：處理行選取的導航邏輯。

 4. 依賴協作：
 
    - `OrderHistoryDataDelegate`：提供數據操作方法（如獲取與刪除訂單）。
    - `OrderHistorySelectionDelegate`：負責處理選取狀態的變更。
    - `OrderHistoryNavigationDelegate`：處理導航至訂單詳細頁面的邏輯。

 5. 靈活設計：
 
    - 支援未來擴展，例如新增多選功能或其他交互模式，只需修改代理或增加新的方法。

 ----------
 
 `* 應用場景`
 
 - 在 `OrderHistoryViewController` 中作為表格視圖的核心處理器：
 
   - 提供訂單資料顯示功能。
   - 實現滑動刪除、行選取及導航等交互邏輯。
   - 通過代理進一步解耦，提升架構靈活性與可維護性。
  
 `1.資料分離設計：`
 
    - `OrderHistoryHandler` 與 `OrderHistoryViewController` 之間透過 `OrderHistoryDataDelegate` 來進行資料的分離和通信，使得控制器的責任減少，專注於資料展示邏輯。
  
 `2.資料驅動：`
 
    - 當訂單資料發生變化時，由 `OrderHistoryViewController` 通知 `OrderHistoryHandler`，並通過` reloadData() `重新加載數據，確保 UI 與資料同步。
 
 `3.選取狀態管理：`
 
    - `didChangeSelectionState(hasSelection: Bool)`管理選取狀態的變更。
    - 當使用者在`編輯模式`下選取或取消選取行時通知控制器更新導航欄按鈕的狀態，特別是`編輯模式下的「刪除」按鈕`的啟用狀態。
 
    - 用途：通知 `OrderHistoryViewController` 更新導航欄按鈕的狀態（例如「刪除」按鈕的啟用與禁用），確保按鈕的狀態與選取狀態保持一致。
 
    -  didSelectRowAt 可以根據模式來處理多選或導航行為，進一步提升了用戶體驗和邏輯的一致性。
 */


// MARK: - OrderHistoryHandler 中行選取與取消選取邏輯的優化設計
/**
 
 ## OrderHistoryHandler 中行選取與取消選取邏輯的優化設計


 `* What`
 
 - `選取與取消選取邏輯`功能是透過 `UITableViewDelegate` 來處理表格視圖中行選取與取消選取的邏輯，並根據當前模式（編輯模式或正常模式）執行不同的操作。

 1. 在編輯模式：
 
    - 監聽行的選取與取消選取，通知 `orderHistorySelectionDelegate` 更新選取狀態（例如控制導航欄按鈕的啟用狀態）。

 2. 在正常模式：
 
    - 當行被選取時，導航至對應的歷史訂單詳細頁面。

 ---------

 `* Why`
 
 1. 支援多模式操作：
 
    - 在編輯模式下，需要監控選取狀態的變化，以便即時更新「刪除」等導航欄按鈕的狀態。
    - 在正常模式下，選取行應觸發導航至詳細頁面，以提升使用者體驗。

 2. 提升程式碼可維護性與重用性：
 
    - 提取公共邏輯至 `handleSelection` 方法，減少重複程式碼，提升程式碼可讀性與維護性。

 3. 遵循單一職責原則：
 
    - 將選取狀態的處理邏輯清晰劃分到 `UITableViewDelegate`，確保責任分工明確。

 ---------

 `* How`
 
 - 以下是具體實作步驟與邏輯說明：

 1. 建立 `didSelectRowAt` 與 `didDeselectRowAt`：
 
    - 利用 `UITableViewDelegate` 的協定方法分別處理行的選取與取消選取事件，並調用公共方法 `handleSelection`。

 ---
 
 2. 定義 `handleSelection`：
 
    - 輸入參數：
 
      - `tableView`：觸發事件的表格視圖。
      - `indexPath`：被選取或取消選取行的索引。
      - `isSelected`：布林值，表示行是否被選取。
 
    - 內部邏輯：
 
      - 若處於編輯模式，通知 `orderHistorySelectionDelegate` 更新選取狀態。
      - 若處於正常模式且行被選取，執行取消選取動畫，並導航至對應的詳細頁面。

 ---

 3. 提供適當的代理方法：
 
    - 在 `orderHistorySelectionDelegate` 中實作具體的更新邏輯，例如更新導航欄按鈕狀態。

 ---

 4. 範例程式碼：

 ```swift
 extension OrderHistoryHandler: UITableViewDelegate {

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         handleSelection(for: tableView, at: indexPath, isSelected: true)
     }
     
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
         handleSelection(for: tableView, at: indexPath, isSelected: false)
     }

     private func handleSelection(for tableView: UITableView, at indexPath: IndexPath, isSelected: Bool) {
         if tableView.isEditing {
             orderHistorySelectionDelegate?.didChangeSelectionState()
         } else if isSelected {
             tableView.deselectRow(at: indexPath, animated: true)
             guard let orders = OrderHistoryDataDelegate?.getOrders() else { return }
             let selectedOrder = orders[indexPath.row]
             orderHistoryDataDelegate?.navigateToOrderHistoryDetail(with: selectedOrder)
         }
     }
 }
 ```

 ---------

 `* 小結`
 
 - What：此部分負責處理表格行選取與取消選取事件。
 - Why：支援多模式操作、提升可維護性與重用性、遵循單一職責原則。
 - How：透過 `UITableViewDelegate` 實作選取與取消選取邏輯，並抽取公共方法處理。

 */


// MARK: - handleSelectionStateChange 筆記
/**
 
 ### handleSelectionStateChange 筆記

 ---

 `* What`
 
 - `handleSelectionStateChange` 是 `OrderHistoryHandler` 中負責處理表格視圖行的選取狀態變更。
 - 其根據表格的當前模式（編輯模式或正常模式）以及行是否被選取，執行以下操作：
 
 1. 編輯模式：
 
    - 通知選取狀態變更代理（`OrderHistorySelectionDelegate`），用於更新導航欄按鈕的狀態（如刪除按鈕是否啟用）。
 
 2. 正常模式：
 
    - 當行被選取時，透過導航代理（`OrderHistoryNavigationDelegate`）導航至選定的訂單詳細頁面。

 ----------

 `* Why`

 1. 區分模式處理邏輯：
 
    - 表格視圖可能處於編輯模式或正常模式，不同模式下行選取的邏輯有所不同：
 
      - 編輯模式專注於管理選取狀態，用於多選和刪除。
      - 正常模式則專注於行點擊的導航行為。
 
    - 此方法將兩者的邏輯進行統一處理，減少代碼重複。

 2. 解耦邏輯與代理：
 
    - 將選取狀態變更的具體操作（如更新按鈕狀態、導航至詳細頁面）委派給代理，提升靈活性和可測試性。
    - 使用 `OrderHistorySelectionDelegate` 和 `OrderHistoryNavigationDelegate`，確保業務邏輯的清晰分工。

 3. 狀態驅動的行為管理：
 
    - 通過表格視圖的當前狀態（是否編輯模式、是否選取）決定執行邏輯，避免處理不必要的操作。
    - 支援未來擴展，例如針對行取消選取的特定處理邏輯。

 ----------

 `* How `

 1. 根據模式與選取狀態執行分支邏輯：
 
    - 使用 `switch` 判斷表格視圖是否處於編輯模式，以及行是否被選取：
 
      - `(true, _)`：編輯模式下，計算是否有選取的行，並通知 `OrderHistorySelectionDelegate` 更新按鈕狀態。
      - `(false, true)`：正常模式且行被選取，取消該行的選取狀態，並透過 `OrderHistoryNavigationDelegate` 導航至詳細頁面。
      - `(false, false)`：正常模式且行取消選取，目前未執行操作，但為未來擴展留有空間。

 2. 編輯模式處理：
 
    - 調用 `tableView.indexPathsForSelectedRows` 檢查當前是否有選取的行。
    - 傳遞計算結果（`hasSelection`）至 `didChangeSelectionState`，更新按鈕的啟用狀態。

 3. 正常模式處理：
 
    - 當行被選取時，調用 `navigateToOrderHistoryDetail`，將選定的訂單資料傳遞給代理執行導航邏輯。

 4. 使用安全檢查：
 
    - 確保代理（如 `orderHistoryDataDelegate` 和 `orderHistoryNavigationDelegate`）及返回的資料有效，避免因空值導致的應用崩潰。

 ----------

 `* 使用場景`
 
 1. 行選取邏輯：
 
    - 在 `didSelectRowAt` 和 `didDeselectRowAt` 中調用，統一處理行選取與取消選取的邏輯。

 2. 支持不同的交互模式：
 
    - 編輯模式下實現多選並更新狀態，提升用戶體驗。
    - 正常模式下實現單筆訂單導航，提供詳細資訊查看功能。

 */


// MARK: - 重點筆記：實現滑動刪除功能的步驟與設計
/**
 
 ## 重點筆記：實現滑動刪除功能的步驟與設計

 `1. 擴展 OrderHistoryHandler 支持滑動刪除`
 
    - 在 `OrderHistoryHandler` 中擴展 UITableViewDelegate，並實作 `tableView(_:commit:forRowAt:) `方法來支援滑動刪除功能。
    - 使用 `UITableViewCell.EditingStyle.delete` 判斷是否是刪除操作。
    - 通過 `orderHistoryDataDelegate` 通知控制器去刪除對應的訂單資料。
 
 -----
 
 `2. 擴展 OrderHistoryDataDelegate 添加刪除訂單的方法`
 
    - 在 `OrderHistoryDataDelegate` 中新增 `deleteOrder(at:) `方法，讓 `OrderHistoryHandler` 可以通知控制器去刪除訂單。
    - 此方法用於管理訂單資料的刪除，包括更新本地的訂單陣列和通知 Firebase。

 -----

 `3. 實作刪除邏輯 (OrderHistoryViewController)`
 
    - 當 `OrderHistoryHandler` 通知刪除請求時，`OrderHistoryViewController` 中負責刪除訂單的資料。
    - 先更新本地存儲的 `orders` 陣列，然後非同步地從 `Firebase` 中刪除對應的訂單資料。
    - 使用 Firebase 提供的非同步 API 確保刪除資料的成功。
 
 -----

 `4. 設計概述`
 
 - 資料同步：
 
    - 滑動刪除訂單時，首先從本地陣列中刪除相應資料，然後非同步刪除 Firebase 中的資料，確保資料同步性。
 
 - 分離關心點：
 
    - `OrderHistoryHandler` 負責表格視圖的數據顯示及操作邏輯（如刪除）。
    - `OrderHistoryViewController` 負責數據的管理，包括與 Firebase 的互動和處理刪除的邏輯。
 
 - 使用委託 (Delegate) 進行溝通：
 
    - 利用 `OrderHistoryDataDelegate` 協議來將數據處理與 UI 操作分離，減少耦合性，使代碼更具可維護性和可擴展性。
 */



// MARK: - (v)

import UIKit

/// `OrderHistoryHandler`
///
/// 此類別負責處理 `OrderHistory` 頁面中表格視圖的數據源及委託邏輯。
///
/// ### 職責範圍
/// - 提供表格視圖的數據源 (`UITableViewDataSource`) 實作，確保訂單資料正確顯示於視圖中。
/// - 實現表格視圖的委託方法 (`UITableViewDelegate`)，處理用戶交互邏輯，如行選取與滑動刪除功能。
/// - 與多個代理協作，包括資料操作、選取狀態更新與導航邏輯。
///
/// ### 功能概述
/// - 數據顯示：
///   - 使用 `OrderHistoryDataDelegate` 提供訂單資料，作為數據源顯示於表格視圖中。
///   - 負責初始化並配置表格的 `UITableViewCell`。
///
/// - 刪除功能：
///   - 支援滑動刪除單筆訂單，並通知資料代理同步刪除操作。
///
/// - 選取與導航：
///   - 處理行選取與取消選取的事件，在編輯模式下通知選取狀態變更，或在正常模式下導航至詳細頁面。
///
/// ### 依賴
/// - `OrderHistoryDataDelegate`：
///   - 提供表格所需的訂單資料，並處理刪除邏輯。
/// - `OrderHistorySelectionDelegate`：
///   - 通知選取狀態的變更，用於更新 UI（例如導航欄按鈕的啟用狀態）。
/// - `OrderHistoryNavigationDelegate`：
///   - 處理點選行的導航邏輯，進入歷史訂單的詳細資訊頁面。
///
/// ### 適用場景
/// - 在 `OrderHistoryViewController` 中用於管理表格的數據與交互邏輯，提升視圖控制器的模組化與可維護性。
class OrderHistoryHandler: NSObject {
    
    // MARK: - Properties
    
    /// 提供訂單資料的代理，用於作為表格視圖的數據來源。
    weak var orderHistoryDataDelegate: OrderHistoryDataDelegate?
    
    /// 負責處理選取狀態變更的代理。
    weak var orderHistorySelectionDelegate: OrderHistorySelectionDelegate?
    
    /// 負責處理導航邏輯的代理。
    weak var orderHistoryNavigationDelegate: OrderHistoryNavigationDelegate?
    
    
    // MARK: - Initialization
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - orderHistoryDataDelegate: 提供訂單資料的代理。
    ///   - orderHistorySelectionDelegate: 處理選取狀態變更的代理。
    ///   - orderHistoryNavigationDelegate: 處理導航邏輯的代理。
    init(
        orderHistoryDataDelegate: OrderHistoryDataDelegate?,
        orderHistorySelectionDelegate: OrderHistorySelectionDelegate?,
        orderHistoryNavigationDelegate: OrderHistoryNavigationDelegate?
    ) {
        self.orderHistoryDataDelegate = orderHistoryDataDelegate
        self.orderHistorySelectionDelegate = orderHistorySelectionDelegate
        self.orderHistoryNavigationDelegate = orderHistoryNavigationDelegate
    }
    
}

 // MARK: - UITableViewDataSource
extension OrderHistoryHandler: UITableViewDataSource {
    
    /// 返回指定部分的行數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderHistoryDataDelegate?.getOrders().count ?? 0
    }
    
    /// 返回特定行的 `UITableViewCell`
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let orders = orderHistoryDataDelegate?.getOrders() else {
            return UITableViewCell()
        }
        
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
    
    /// 支援滑動刪除功能
    ///
    /// - Parameters:
    ///   - tableView: 表格視圖。
    ///   - editingStyle: 編輯操作的類型。
    ///   - indexPath: 要刪除的行的索引路徑。
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // 通知資料代理刪除指定訂單
        orderHistoryDataDelegate?.deleteOrder(at: indexPath.row)
        
        // 從表格視圖中刪除行
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Selection State Changes (選取狀態變更)
    
    /// 當表格中的行被選取時觸發
    ///
    /// - 說明：
    ///   - 根據`當前模式`執行不同的邏輯：
    ///     - 編輯模式：通知代理更新選取狀態（例如啟用/禁用「刪除」按鈕）。
    ///     - 正常模式：導航至選取的訂單詳細頁面。
    ///
    /// - Parameters:
    ///   - tableView: 當前的表格視圖
    ///   - indexPath: 被選取的行的索引路徑
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSelectionStateChange(for: tableView, at: indexPath, isSelected: true)
    }
    
    /// 當表格中的行取消選取時觸發
    ///
    /// - 說明：
    ///   - 僅在編輯模式下執行，通知代理更新選取狀態（例如啟用/禁用「刪除」按鈕）。
    ///
    /// - Parameters:
    ///   - tableView: 當前的表格視圖
    ///   - indexPath: 被取消選取的行的索引路徑
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        handleSelectionStateChange(for: tableView, at: indexPath, isSelected: false)
    }
    
    /// 處理表格行選取狀態變更
    ///
    /// - 說明：
    ///   - 根據當前模式（編輯模式或正常模式）和行的選取狀態執行相應操作：
    ///     - 編輯模式：通知 `orderHistorySelectionDelegate` 更新選取狀態，通常用於更新導航欄按鈕的狀態。
    ///     - 正常模式（僅在行被選取時執行）：導航至選取的訂單詳細頁面。
    ///
    /// - Parameters:
    ///   - tableView: 當前的表格視圖
    ///   - indexPath: 發生選取變更的行的索引路徑
    ///   - isSelected: 指定當前行是否被選取
    private func handleSelectionStateChange(for tableView: UITableView, at indexPath: IndexPath, isSelected: Bool) {
        switch (tableView.isEditing, isSelected) {
        case (true, _):
            // 編輯模式：在編輯模式下通知選取狀態變更，用於更新相關按鈕狀態
            let hasSelection = tableView.indexPathsForSelectedRows?.isEmpty == false
            orderHistorySelectionDelegate?.didChangeSelectionState(hasSelection: hasSelection)
            
        case (false, true):
            // 正常模式且行被選取：導航至詳細頁面
            tableView.deselectRow(at: indexPath, animated: true)
            guard let orders = orderHistoryDataDelegate?.getOrders() else { return }
            let selectedOrder = orders[indexPath.row]
            orderHistoryNavigationDelegate?.navigateToOrderHistoryDetail(with: selectedOrder)
            
        case (false, false):
            // 正常模式且行取消選取：暫無操作，保留未來擴展的可能
            break
        }
    }
    
}
