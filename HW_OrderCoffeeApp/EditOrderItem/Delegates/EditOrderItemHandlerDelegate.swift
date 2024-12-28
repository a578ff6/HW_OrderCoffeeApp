//
//  EditOrderItemHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/25.
//


// MARK: -  EditOrderItemHandlerDelegate 筆記
/**
 ### EditOrderItemHandlerDelegate 筆記

 `* What (功能說明)`

 - `EditOrderItemHandlerDelegate` 是一個協議，負責處理與「編輯訂單飲品頁面」相關的資訊交互。
 - 主要任務是讓 `EditOrderItemHandler` 能夠向控制器（ `EditOrderItemViewController`）回報操作結果，並要求控制器進行相應的資料更新。

 - `提供編輯訂單的資料模型`：使得 `EditOrderItemHandler` 可以取得當前編輯的訂單項目資料。
 - `處理尺寸變更`：當訂單的尺寸發生變更時，通知控制器並`更新 UI`。
 - `處理數量變更`：當訂單的數量發生變更時，通知控制器並`更新相關資料`。

 -----------------------
 
 `* Why (為什麼需要這個協議)`

 這個協議的設計目的是實現「視圖控制器和操作邏輯」之間的分離，提供一種抽象化的方式來通知和處理尺寸與數量的變更，從而讓編輯訂單的邏輯更加靈活，並且在不同的視圖中復用。

 - **數據更新與 UI 更新分離**：通過將尺寸與數量的更新操作放入協議中，控制器可以專注於處理視圖的更新，而不需要直接處理操作邏輯。
 - **減少視圖與邏輯的耦合**：這樣的設計提高了代碼的可維護性與可測試性，特別是在需要多次修改訂單項目的情況下。

 -----------------------

 `* How (如何實現)`

 - `getEditOrderItemModel()`：
   這個方法允許 `EditOrderItemHandler` 獲取當前編輯的訂單項目資料模型（`EditOrderItemModel`）。該模型包含了訂單的各項詳細資訊（例如尺寸、數量等），並且是後續操作的基礎。
   
 - `didChangeSize(_:)`：
   當使用者在 UI 中選擇不同的尺寸時，會觸發這個方法，並更新 `EditOrderItemModel` 中的 `selectedSize` 屬性。該方法通知控制器，並且控制器需要更新相關的 UI（例如刷新尺寸選擇按鈕的選中狀態）。

 - `didChangeQuantity(to:)`：
   當使用者調整訂單的數量時，這個方法被觸發，並會更新 `EditOrderItemModel` 中的 `quantity` 屬性。方法內會同步更新 `OrderItemManager` 中的訂單數據，確保數據保持一致。
 
 -----------------------

 `* 小結：`

 - 主要職責：`EditOrderItemHandlerDelegate` 主要負責處理編輯訂單頁面上的尺寸和數量變更，並更新模型及 UI。
 - 如何處理：控制器（例如 `EditOrderItemViewController`）實現這個協議，通過協議方法來更新尺寸和數量，並向後端管理（如 `OrderItemManager`）同步訂單數據。
 */


// MARK: - (v)
import Foundation

/// `EditOrderItemHandlerDelegate` 協議負責處理與編輯訂單飲品頁面相關的資訊交互。
/// 這個協議的實現使得 `EditOrderItemHandler` 能夠向控制器回報操作結果，並要求控制器進行相應的資料更新。
///
/// ### 主要職責：
/// - 獲取當前的訂單項目資料模型 (`EditOrderItemModel`)。
/// - 當訂單的尺寸或數量發生變更時，通知控制器並更新 UI 或資料。
protocol EditOrderItemHandlerDelegate: AnyObject {
    
    /// 獲取當前編輯中的訂單項目資料模型。
    /// - 返回：`EditOrderItemModel`，包含當前訂單項目的詳細資料。
    func getEditOrderItemModel() -> EditOrderItemModel
    
    /// 當訂單尺寸發生變更時觸發。
    /// - Parameter newSize: 新選擇的尺寸。
    func didChangeSize(_ newSize: String)
    
    /// 當訂單數量發生變更時觸發。
    /// - Parameter quantity: 新的數量。
    func didChangeQuantity(to quantity: Int)
    
}
