//
//  OrderHistoryDetailSectionDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/13.
//

// MARK: - OrderHistoryDetailSectionDelegate 筆記
/**
 
 ## OrderHistoryDetailSectionDelegate 筆記

 `* What:`
 
 - `OrderHistoryDetailSectionDelegate` 是一個協議，專門用於處理歷史訂單詳細頁面中 Section 的展開與收起行為。
 - 它負責將 Section 狀態變更事件（如展開或收起）從 `OrderHistoryDetailHandler` 傳遞給外部類別（如 `OrderHistoryDetailViewController`），由外部類別負責執行相應的 UI 更新。

 -------

 `* Why`

 1. 責任分離：
 
    - `OrderHistoryDetailHandler` 僅需專注於管理 Section 的展開與收起狀態，而不需直接處理視圖更新，符合單一職責原則 (SRP)。

 2. 降低耦合：
 
    - 使用代理模式，將狀態管理與視圖更新解耦，讓 `OrderHistoryDetailHandler` 不直接依賴於具體的 UI 實現（如 `UIViewController`）。
    - 提高系統靈活性，方便後續擴展或修改。

 3. 集中控制視圖更新：
 
    - 由外部類別（如 `OrderHistoryDetailViewController`）統一處理所有的 UI 刷新邏輯，確保更新行為集中且可控。

 4. 提升可測試性：
 
    - `OrderHistoryDetailHandler` 可以獨立測試其狀態管理邏輯，因為視圖更新被隔離到外部。

 -------

 `* How`

 1. 定義協議：
 
    - 協議中包含方法 `didToggleSection(_ section: Int)`，用於通知外部某個 Section 的展開或收起狀態發生了變化。
    - 外部類別實現此協議，負責接收事件並執行視圖刷新。

    ```swift
    protocol OrderHistoryDetailSectionDelegate: AnyObject {
        func didToggleSection(_ section: Int)
    }
    ```

 2. 實現協議：
 
    - 在外部類別（如 `OrderHistoryDetailViewController`）中實現該協議，根據收到的 Section 狀態變更事件進行 UI 更新。

    ```swift
    extension OrderHistoryDetailViewController: OrderHistoryDetailSectionDelegate {
        func didToggleSection(_ section: Int) {
            print("[OrderHistoryDetailViewController]: Section toggled: \(section)")
            orderHistoryDetailView.orderHistoryDetailCollectionView.reloadSections(IndexSet(integer: section))
        }
    }
    ```

 3. 注入代理：
 
    - 在初始化 `OrderHistoryDetailHandler` 時，將實現了該協議的外部類別作為代理注入。

    ```swift
    private func initializeDetailHandler() {
        let handler = OrderHistoryDetailHandler(
            orderHistoryDetailHandlerDelegate: self,
            orderHistoryDetailSectionDelegate: self
        )
        self.orderHistoryDetailHandler = handler
        configureCollectionView(handler: handler)
    }
    ```

 4. 處理點擊事件：
 
    - `OrderHistoryDetailHeaderGestureHandler` 通過手勢監聽 Header 點擊事件，並通知 `OrderHistoryDetailSectionExpansionManager` 更新狀態。
    - 透過 `OrderHistoryDetailSectionDelegate` 將狀態變更事件傳遞給外部類別。

    ```swift
    @objc private func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        orderHistoryDetailSectionExpansionManager.toggleSection(section)
        orderHistoryDetailSectionDelegate?.didToggleSection(section)
    }
    ```

 -------

 `* 結論`

 - `OrderHistoryDetailSectionDelegate` 是實現責任分離和降低耦合的核心工具：
 
    它允許 `OrderHistoryDetailHandler` 專注於狀態管理，並讓外部類別（如 `OrderHistoryDetailViewController`）處理視圖更新，符合良好的設計原則。
   
 - 適用場景：
 
    適用於任何需要集中管理狀態更新且需要通知外部進行 UI 操作的情境，特別是具有多個 Section 且每個 Section 有展開/收起行為的頁面設計。
 */


// MARK: - (v)

import Foundation

/// `OrderHistoryDetailSectionDelegate`
///
/// 此協議專注於處理 `OrderHistoryDetailHandler` 的 Section 展開與收起邏輯，
/// 採用代理模式將 Section 狀態變更事件通知到外部類別（如 `OrderHistoryDetailViewController`）。
///
/// - **設計目的**:
///   1. 責任分離：讓 `OrderHistoryDetailHandler` 專注於管理 Section 狀態，避免直接處理視圖更新，確保單一職責原則 (SRP)。
///   2. 降低耦合：透過協議，將狀態管理與視圖更新解耦合，提升靈活性與可維護性。
///   3. 視圖更新控制：將 UI 刷新行為集中到外部控制器中進行統一管理。
///
/// - 使用場景:
///   當用戶點擊某個 Section Header，切換展開或收起狀態時:
///   1. `OrderHistoryDetailHandler` 通知外部類別 (如 `OrderHistoryDetailViewController`)。
///   2. 外部類別負責執行相應的視圖刷新邏輯（例如，重載 Section 的 UI）。
protocol OrderHistoryDetailSectionDelegate: AnyObject {
    
    /// 通知外部 Section 被展開或收起
    ///
    /// - Parameter section: 被切換狀態的 Section 索引
    ///
    /// - 設計目的:
    ///   1. 確保 `OrderHistoryDetailHandler` 只專注於處理展開/收起邏輯。
    ///   2. 外部類別負責更新對應的 UI（如刷新 Section 的顯示）。
    func didToggleSection(_ section: Int)
    
}
