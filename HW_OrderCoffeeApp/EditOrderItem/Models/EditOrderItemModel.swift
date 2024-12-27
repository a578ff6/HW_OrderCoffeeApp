//
//  EditOrderItemModel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

// MARK: - EditOrderItemModel 筆記
/**
 
 ## EditOrderItemModel 筆記

 `* What (功能說明)`

 - `EditOrderItemModel` 是一個用來處理編輯訂單項目的資料結構，負責儲存飲品訂單項目（`OrderItem`）的詳細資料。
 - 它提供了便於修改訂單項目資訊（如尺寸、數量）的接口，並可將更新反映到使用者介面上。

 - `主要屬性：`
 
   - `id`: 訂單項目 ID。
   - `drinkName`, `drinkSubName`, `description`: 飲品的基本資訊。
   - `imageUrl`: 飲品圖片的 URL。
   - `selectedSize`: 當前選擇的飲品尺寸。
   - `quantity`: 訂單中的飲品數量。
   - `sortedSizes`: 已排序的尺寸列表。
   - `sizeDetails`: 各尺寸的詳細資訊，包含了每個尺寸的價格等。

 - `初始化方法`：
 
    - `init(orderItem:)`，將來自 `OrderItem` 的數據轉換成 `EditOrderItemModel`，方便後續操作。

 ------------------

 `* Why (為什麼需要這個資料模型)`

 - `EditOrderItemModel` 的作用是將 `OrderItem` 資料結構轉換為一個可編輯的模型，並且能夠便捷地更新訂單項目的尺寸和數量。這樣的設計有以下優點：

 - `數據管理分離`：將原始的 `OrderItem` 資料與用戶在編輯過程中的修改分開，避免直接改動原始資料。
 - `UI 更新簡便`：這個模型作為數據層與 UI 層之間的橋樑，使得在 UI 上的修改能夠快速反映到資料模型中。
 - `便於擴展`：未來如果需要擴展更多屬性（如價格、備註等），可以輕鬆添加，而不影響到現有的編輯邏輯。

 ------------------

  `* How (如何實現)`

 `1.初始化：`
 
 - `EditOrderItemModel` 是從 `OrderItem` 生成的，通過傳入一個 `OrderItem` 來初始化，並將其基本資訊、尺寸、數量等屬性轉換為可變的屬性（如 `selectedSize` 和 `quantity`）。
   
 `2.尺寸更新方法：`
 
 - 提供了 `sizeInfo(for:)` 方法，用來獲取指定尺寸的詳細資料（例如價格），並確保使用者選擇的尺寸有效。

 `3.數據修改：`
 
 - 在 `EditOrderItemViewController` 中，當使用者改變尺寸或數量時，會更新 `EditOrderItemModel` 中的 `selectedSize` 和 `quantity` 屬性。這些更新將自動觸發 UI 變更和數據同步。

 `4.職責：`
 
 - `EditOrderItemModel` 本身不會處理 UI 更新，它專注於數據的管理和修改。
 - UI 更新由控制器（`EditOrderItemViewController`）負責，這樣可以確保數據邏輯與顯示邏輯分離。

 ------------------
 
 `* 小結：`

 - 主要職責：`EditOrderItemModel` 負責儲存編輯訂單項目的數據，特別是訂單項目的尺寸、數量等屬性，並提供對這些屬性進行修改和查詢的方法。
 - 如何實現：通過將 `OrderItem` 資料轉換為可變屬性的 `EditOrderItemModel`，使得 UI 和數據操作可以互相獨立，同時簡化了控制器中對訂單項目的管理和更新。
 */


// MARK: - (v)

import UIKit

/// `EditOrderItemModel`
///
/// 此結構體負責管理編輯訂單項目的資料模型，
/// 提供飲品的詳細資訊與操作接口，讓視圖可以有效展示與更新資料。
///
/// ### 功能：
/// - 以 `OrderItem` 初始化模型，提取飲品基本資訊（名稱、描述、圖片等）與訂單資訊（尺寸、數量）。
/// - 支援存取飲品尺寸詳細資訊，讓視圖可以展示或更新特定尺寸的相關資訊。
/// - 提供變更訂單數量與尺寸的操作，讓資料始終與視圖同步。
struct EditOrderItemModel {
    
    /// 訂單項目唯一識別碼
    let id: UUID
    /// 飲品名稱
    let drinkName: String
    /// 飲品副名稱
    let drinkSubName: String
    /// 飲品描述
    let description: String
    /// 飲品圖片的 URL
    let imageUrl: URL
    /// 飲品可用尺寸的排序列表（例如 ["Small", "Medium", "Large"]）
    let sortedSizes: [String]
    /// 每個尺寸對應的詳細資訊字典（尺寸名稱對應 `SizeInfo`）
    let sizeDetails: [String: SizeInfo]
    
    /// 使用者當前選擇的飲品尺寸（例如 "Medium" 或 "Large"）
    var selectedSize: String
    /// 使用者當前選擇的數量
    var quantity: Int
    
    // MARK: - Initializer

    /// 從 `OrderItem` 初始化模型
    ///
    /// - Parameter orderItem: 原始訂單項目，包含飲品與選項資料。
    init(orderItem: OrderItem) {
        self.id = orderItem.id
        self.drinkName = orderItem.drink.name
        self.drinkSubName = orderItem.drink.subName
        self.description = orderItem.drink.description
        self.imageUrl = orderItem.drink.imageUrl
        self.selectedSize = orderItem.size
        self.quantity = orderItem.quantity
        self.sizeDetails = orderItem.drink.sizes
        self.sortedSizes = orderItem.drink.sizes.keys.sorted()  // 確保尺寸排序
    }
    
    // MARK: - Methods

    /// 獲取指定尺寸的詳細資訊
    ///
    /// - Parameter size: 尺寸名稱（如 "Medium", "Large"）
    /// - Returns: 該尺寸對應的 `SizeInfo`
    func sizeInfo(for size: String) -> SizeInfo {
        guard let sizeInfo = sizeDetails[size] else {
            fatalError("無法找到對應尺寸的資訊：\(size)")
        }
        return sizeInfo
    }
    
}
