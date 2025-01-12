//
//  OrderConfirmationHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/4.
//

// MARK: - OrderConfirmationHandlerDelegate 設計筆記
/**
 
 ## MARK: - OrderConfirmationHandlerDelegate 設計筆記

 `* What`
 
 - `OrderConfirmationHandlerDelegate` 是一個協議，負責協助 `OrderConfirmationHandler` 與外部類別進行通信。

 - 它的主要用途包括：
 
   1. 從外部獲取訂單確認資料（`OrderConfirmation`）。
   2. 處理用戶在視圖中的「關閉操作」。
 
 - 通過該協議，`OrderConfirmationHandler` 可以專注於顯示邏輯，將數據獲取與關閉操作的具體實現委託給外部類別。

 -----------

 `* Why`
 
 1. 降低耦合性：
 
    - `OrderConfirmationHandler` 不應直接處理數據的獲取邏輯或關閉操作的實現，以保持模組的單一責任。
    - 使用代理模式讓 `OrderConfirmationHandler` 依賴於抽象的接口，而不是具體的實現，從而降低類與類之間的耦合度。

 2. 易於擴展與維護：
 
    - 當需要更改數據提供方式或關閉操作的行為時，只需修改代理的實現類別，而不需要改變 `OrderConfirmationHandler` 的代碼邏輯。
    - 符合開放封閉原則（Open-Closed Principle），提高代碼的靈活性。

 3. 便於單元測試：
 
    - 通過代理模式，可以使用 Mock 代理來模擬資料提供與關閉操作的行為。
    - 測試 `OrderConfirmationHandler` 的顯示邏輯時，可輕鬆隔離外部依賴，提高測試覆蓋率與穩定性。

 -----------

 `* Who`
 
 - `OrderConfirmationHandlerDelegate` 的具體實現通常由持有訂單資料與控制視圖邏輯的類別負責，例如 `OrderConfirmationViewController`。
 
 - `OrderConfirmationViewController` 作為代理，實現以下兩個方法：
 
   1. `getOrder()`：提供目前的 `OrderConfirmation` 模型資料。
   2. `didTapCloseButton()`：處理用戶點擊關閉按鈕後的邏輯（如重置資料、導航至主畫面等）。

 -----------

` * 使用案例`

 - 訂單確認頁面 (`OrderConfirmationViewController`)
 
    - `OrderConfirmationViewController` 是訂單確認頁面的主控制器，負責管理顯示邏輯與數據來源。
    - 當 `OrderConfirmationHandler` 需要顯示訂單資料時，通過代理方法 `getOrder()` 獲取當前的 `OrderConfirmation`。
    - 當用戶點擊「關閉」按鈕時，`OrderConfirmationHandler` 通知 `OrderConfirmationViewController`，執行返回主畫面或清理資料的行為。

 -----------

 `* 總結`
 
 - 角色分工：
 
   - `OrderConfirmationHandler`：專注於訂單數據的顯示邏輯。
   - `OrderConfirmationHandlerDelegate`：負責提供訂單資料與處理用戶交互邏輯。

 - 優點：
 
   - 責任清晰，降低類別間耦合。
   - 符合單一職責原則（SRP）。
   - 增強代碼靈活性與可測試性。

 */


// MARK: - (v)

import UIKit

/// `OrderConfirmationHandlerDelegate`
///
/// 此協議用於協助 `OrderConfirmationHandler` 與外部類別（如 `OrderConfirmationViewController`）進行溝通。
/// 通過代理模式，`OrderConfirmationHandler` 可以專注於處理訂單數據的顯示邏輯，
/// 而由外部類別負責提供必要的訂單數據並處理相關的用戶交互。
///
/// - 設計用途:
///   1. 確保 `OrderConfirmationHandler` 能夠從外部安全地獲取所需的訂單數據。
///   2. 當用戶觸發「關閉」操作時，通知外部類別執行相應邏輯（如視圖重置或狀態更新）。
protocol OrderConfirmationHandlerDelegate: AnyObject {
    
    /// 從外部獲取當前的 `OrderConfirmation` 模型
    ///
    /// - 返回值: `OrderConfirmation?`
    ///   - 若訂單數據可用，返回當前的 `OrderConfirmation` 模型。
    ///   - 若訂單數據不可用，返回 `nil`。
    ///
    /// - 設計目的:
    ///   確保 `OrderConfirmationHandler` 可以專注於顯示邏輯，
    ///   而實際的訂單數據由外部類別負責提供。
    func getOrder() -> OrderConfirmation?
    
    /// 當用戶點擊「關閉」按鈕時的操作
    ///
    /// - 說明:
    ///   通知外部類別執行關閉視圖的相關操作。
    ///   外部類別可以根據具體需求，執行重置訂單資料、導航堆疊重置等邏輯。
    func didTapCloseButton()
    
}
