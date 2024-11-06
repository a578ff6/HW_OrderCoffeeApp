//
//  OrderConfirmationHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/4.
//
// MARK: - OrderConfirmationHandlerDelegate 設計筆記
/**
 ## MARK: - OrderConfirmationHandlerDelegate 設計筆記

 `* 設計目的`
 
    - `OrderConfirmationHandlerDelegate` 是一個協定（protocol），設計的目的是允許 `OrderConfirmationHandler` 與外部類別進行通信，特別是用於從外部獲取所需的訂單確認資料 (OrderConfirmation)、處理視圖中的關閉操作，以及管理區塊（Section）的展開或收起狀態。
    - 使 `OrderConfirmationHandler` 能夠依賴代理來取得資料和處理關閉操作和區塊狀態切換，這樣 `OrderConfirmationHandler` 自身不需要知道資料的具體來源和具體的關閉行為，從而達到`降低耦合度`的目的。

 `* 為什麼需要使用代理模式`

 `1. 降低耦合性：`
    - `OrderConfirmationHandler` 需要訂單資料來顯示，但它不應該直接處理訂單資料的獲取邏輯。
    - 通過使用 `Delegate`，`OrderConfirmationHandler` 只需要知道如何從它的代理中獲取資料，而不需要關心資料的具體實現，這樣可以將責任分離，降低類之間的耦合性。
    - 同樣地，`OrderConfirmationHandler` 也不直接處理視圖關閉操作，這一操作委託由外部控制器來實現，使得 `OrderConfirmationHandler` 專注於顯示邏輯。

 `2. 易於擴展與維護：`
    - 使用代理模式可以使得 `OrderConfirmationHandler` 更加靈活。如果未來需要改變 `OrderConfirmation` 資料的提供方式或關閉操作的具體邏輯，只需修改代理的實現類別，而不需要改變 `OrderConfirmationHandler` 的代碼。

` 3. 便於單元測試：`
    - 由於 `OrderConfirmationHandler` 不直接依賴具體的數據源，而是通過代理來獲取資料和處理操作，這樣在進行單元測試時，可以方便地使用 Mock 代理來提供測試資料或監控按鈕操作，使測試更加方便和可控。

 `### 流程總結`

 `1. 獲取資料的流程：`
    - `OrderConfirmationHandler` 需要展示訂單資料時，會通過 `OrderConfirmationHandlerDelegate` 協定向代理請求資料。
    - 會是 `OrderConfirmationViewController`，它持有當前的 `OrderConfirmation` 模型並實現了 `getOrder()` 方法來提供這些資料。

 `2. 接口定義：`
    - `getOrder()`：返回當前的 `OrderConfirmation` 模型。當沒有可用訂單時，返回 `nil`。
    - `didTapCloseButton()`：當用戶在訂單確認頁面中按下關閉按鈕時，代理將處理相應的關閉操作（例如返回主菜單頁面，清除相關資料）。
    - `didToggleSection(_:)`：當用戶切換某個區塊（Section）的展開或收起狀態時，代理將處理相應的視圖更新操作，例如重新載入該區塊。

 `3. Delegate 具體的實現：`
    - 代理由持有訂單資料的控制器實現。
    - `OrderConfirmationViewController` 實現了 `OrderConfirmationHandlerDelegate`，並在` getOrder() `方法中返回當前的 OrderConfirmation 實例。
    - 同時在 `didTapCloseButton()` 方法中處理返回和清除的行為，在 `didToggleSection(_:) `方法中負責處理區塊的展開與收起顯示更新。
 
 `### 使用案例`

 `* 訂單確認頁面 (`OrderConfirmationViewController`)：`
        - `OrderConfirmationViewController` 是訂單確認頁面，在這個頁面中，它通過 `OrderConfirmationHandler` 來管理 `UICollectionView` 的顯示和交互。
        - `OrderConfirmationHandler` 需要從外部獲取當前的訂單資料來更新顯示，因此它依賴於 `OrderConfirmationHandlerDelegate` 來取得這些資料。
        - 當用戶點擊關閉按鈕時，`OrderConfirmationHandler` 通過 `didTapCloseButton()` 通知代理執行相應的關閉邏輯。
        - 當用戶點擊某個可展開的區塊時，`OrderConfirmationHandler` 通過` didToggleSection(_:) `通知代理處理區塊的展開與收起狀態，代理負責進行相關視圖的更新。

` * 降低類別之間的直接依賴：`
        - 通過 `OrderConfirmationHandlerDelegate`，`OrderConfirmationHandler` 不需要知道具體的 `OrderConfirmationViewController` 或其他持有資料的類別，而是通過代理模式來請求資料，從而使程式結構更具擴展性和維護性。
 */

import UIKit

/// `OrderConfirmationHandlerDelegate` 用於協助 `OrderConfirmationHandler` 與外部類別溝通，特別是從外部獲取訂單資料及處理關閉操作。
/// - 設計用途：通過代理模式 (`Delegate Pattern`)，`OrderConfirmationHandler` 可以從外部類別（如 `OrderConfirmationViewController`）獲取最新的訂單資料，並在用戶進行關閉操作時通知外部類別，以便更新視圖和狀態。
protocol OrderConfirmationHandlerDelegate: AnyObject {
    
    /// 從外部獲取當前的 `OrderConfirmation` 物件
    /// - 返回值：`OrderConfirmation?`，當前的訂單確認模型，如果沒有訂單則返回 `nil`
    func getOrder() -> OrderConfirmation?
    
    ///  當按下`關閉`按鈕時的操作
    func didTapCloseButton()
    
    /// 當切換某個 Section 展開/收起狀態時的操作
    func didToggleSection(_ section: Int)
}
