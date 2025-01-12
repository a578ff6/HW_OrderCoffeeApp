//
//  OrderConfirmationSectionDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/11.
//

// MARK: - OrderConfirmationSectionDelegate 設計筆記
/**
 
 ## OrderConfirmationSectionDelegate 設計筆記

 `* What`
 
 - `OrderConfirmationSectionDelegate` 是一個協議，專門負責處理 `OrderConfirmationHandler` 中 Section 展開與收起邏輯的通知與回調。
 
 - 此協議的功能包括：
   1. 通知外部類別某個 Section 的狀態已經改變（展開或收起）。
   2. 將具體的視圖更新邏輯交由外部類別實現。

 -----------

 `* Why`
 
 1. 單一職責原則（SRP）：
 
    - Section 的展開/收起邏輯應與訂單資料管理邏輯分離。
    - 通過專門的 `OrderConfirmationSectionDelegate` 處理 Section 狀態變更，確保代碼責任分明，便於維護。

 2. 降低耦合性：
 
    - `OrderConfirmationHandler` 不需要直接處理 UI 更新，而是僅通過代理通知外部類別。
    - 外部類別（如 `OrderConfirmationViewController`）負責具體的視圖刷新邏輯，減少模組間的耦合。

 3. 靈活擴展：
 
    - 如果需要更改 Section 的行為邏輯，例如新增動畫效果或記錄交互數據，只需修改代理的實現類別，不影響 `OrderConfirmationHandler` 的代碼。

-----------

 `* How`
 
 `1. 整體流程：`
 
 - 事件觸發：
   - 當用戶點擊某個 Section Header 時，`OrderConfirmationHeaderGestureHandler` 處理點擊手勢，並切換 Section 的展開狀態。
 
 - 狀態變更：
   - `OrderConfirmationHeaderGestureHandler` 通知 `OrderConfirmationSectionDelegate`，調用 `didToggleSection(_:)` 方法，告知外部類別該 Section 的狀態發生變更。
 
 - UI 更新：
   - 外部類別（如 `OrderConfirmationViewController`）根據通知，執行對應的視圖刷新邏輯（如重新加載對應 Section 的資料）。

 ---

 `2. 代理方法：`
 
 - `didToggleSection(_ section: Int)`
 
   - 參數：
     - `section`：被切換的 Section 的索引。
 
   - 功能：
     - 通知外部類別執行與該 Section 狀態變更相關的操作，例如刷新 UI。

 -----------

 `* Who`
 
 - `OrderConfirmationHeaderGestureHandler`
 
   - 負責處理用戶點擊事件，切換 Section 展開狀態，並通知代理。
 
 - `OrderConfirmationViewController`
 
   - 作為代理的實現類別，負責根據 `didToggleSection(_:)` 的通知執行視圖更新操作，例如重新加載 Section。

 -----------

 `* 使用案例`

 1. 用戶操作：
 
 - 用戶點擊某個 Section Header，想要展開或收起該區域。

 2. 系統處理：
 
 - `OrderConfirmationHeaderGestureHandler` 捕獲點擊事件，通過 `OrderConfirmationSectionExpansionManager` 更新 Section 狀態，並通知 `OrderConfirmationSectionDelegate`。

 3. 視圖更新：
 
 - `OrderConfirmationViewController` 作為 `OrderConfirmationSectionDelegate` 的實現類別，接收到 `didToggleSection(_:)` 通知後，執行對應的 UI 更新邏輯，例如刷新 Section 的顯示狀態。

 -----------

 `* 總結`
 
 - 角色分工：
 
   - `OrderConfirmationHandler`：負責處理 Section 展開/收起邏輯，專注於業務層。
   - `OrderConfirmationSectionDelegate`：作為橋樑，負責通知外部類別狀態變更。
   - `OrderConfirmationViewController`：作為代理的實現類別，負責具體的視圖更新。

 - 優點：
   - 符合單一職責原則，責任分離清晰。
   - 降低模組間的耦合性，增強代碼靈活性。
   - 便於測試與擴展，例如通過 Mock 測試 Section 行為。

 */


// MARK: - (v)

import Foundation

/// `OrderConfirmationSectionDelegate`
///
/// 此協議用於處理 `OrderConfirmationHandler` 中的 Section 展開/收起邏輯，
/// 通過代理模式將 Section 的狀態變更通知外部類別（ `OrderConfirmationViewController`）。
///
/// - 設計用途:
///   1. 集中處理 Section 的展開與收起行為，並與外部類別保持低耦合。
///   2. 通知外部類別更新對應 Section 的顯示狀態（如重新載入 UI）。
///
/// - 使用場景:
///   當用戶點擊 Section Header，觸發展開或收起操作時，透過此代理將事件傳遞給外部類別。
protocol OrderConfirmationSectionDelegate: AnyObject {
    
    /// 通知外部 Section 被展開或收起
    ///
    /// - Parameter section: 被切換狀態的 Section 索引
    ///
    /// - 設計目的:
    ///   1. 確保 `OrderConfirmationHandler` 只專注於處理展開/收起邏輯。
    ///   2. 外部類別負責更新對應的 UI（如刷新 Section 的顯示）。
    func didToggleSection(_ section: Int)
    
}
