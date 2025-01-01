//
//  OrderItemManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/9.
//

// MARK: - OrderItemManager 筆記
/**
 
 ## OrderItemManager 筆記

 `* What`

 - `OrderItemManager` 是一個單例類別，專注於管理訂單項目列表及其相關操作，主要功能如下：

 1. 訂單管理：
 
    - 提供新增、更新、刪除訂單項目，以及清空整個訂單的功能。
    - 透過監聽 `orderItems` 的變更，自動通知觀察者（例如 UI），以實現即時更新。

 2. 數據計算：
 
    - 計算訂單的總金額與準備時間，提供整體訂單的數據總覽。

 3. 數據同步：
 
    - 當訂單清空時，自動重置顧客資料，確保數據一致性。
    - 通過通知機制，讓其他模組（如 UI 層）獲取最新數據。

 ------------

 `* Why`

 `1. 集中化管理：`
 
    - 將所有與訂單相關的操作集中到一個管理器中，提升代碼的可讀性和可維護性。
    - 減少其他模組需要直接操作訂單數據的情況，避免邏輯分散。

 `2. 數據一致性：`
 
    - 使用 `didSet` 監控訂單數據變更，確保其他模組（如顯示層）能即時同步最新數據。
    - 清空訂單時自動重置顧客資料，防止遺留舊數據。

 `3. 提高效率：`
 
    - 在更新訂單項目時，僅在數據實際變更時進行更新，避免冗餘操作。
    - 提供方便的總金額與準備時間計算方法，避免每次手動計算。

 ------------

 `* How`

 `1. 訂單管理`

 - 新增訂單項目 (`addOrderItem`*：
   - 根據用戶選擇的飲品詳細信息，創建新的訂單項目並添加到列表中。
   - 計算項目總金額，並將項目數據存儲到 `orderItems`。

 - 更新訂單項目 (`updateOrderItem`)：
   - 根據訂單項目 ID，更新指定項目的尺寸與數量。
   - 自動同步更新價格與總金額，但保留與飲品類型相關的屬性（如準備時間）。

 - 清空訂單 (`clearOrder`)：
   - 移除所有訂單項目，並觸發通知以告知觀察者數據已清空。

 - 刪除單一項目 (`removeOrderItem`)：
   - 根據訂單項目 ID，移除對應的項目。

 ---

 `2. 訂單數據計算`

 - 計算總準備時間 (`calculateTotalPrepTime`)：
   - 遍歷訂單項目，根據每項飲品的數量累計準備時間。

 - 計算總金額 (`calculateTotalAmount`)：
   - 累加所有訂單項目的金額，返回整體訂單的總金額。

 ---

 `3. 數據同步與通知`

 - 變更通知機制：
   - 通過監聽 `orderItems` 的 `didSet`，自動向觀察者（例如 `OrderItemViewController`）發送數據更新通知。

 - 自動重置顧客資料：
   - 當訂單清空時，調用 `CustomerDetailsManager` 的 `resetCustomerDetails` 方法，確保顧客資料的正確性。

 ------------

 `* 適用場景`

 1. 訂單操作：
    - 當用戶新增、修改或刪除訂單項目時，`OrderItemManager` 提供統一的入口處理所有操作。

 2. 界面更新：
    - 透過通知機制，自動同步訂單數據到 UI 層（如訂單頁面的 `CollectionView`）。

 3. 數據查詢與分析：
    - 需要獲取訂單總金額或準備時間時，通過對應方法快速計算。
 
 ------------

 `* 補充說明：`
         
 `1. orderItems：`
    
 - 訂單項目列表，每次修改訂單項目（例如新增、刪除或更新）後，會透過 didSet 屬性監聽器來發送通知，確保其他視圖可以及時同步顯示。
  
 `2. updateOrderItem 詳細說明：`
  
 - 更新訂單項目的尺寸和數量，並確保相關的價格與總金額屬性同步更新。
 - 對於 prepTime，因為該屬性是基於飲品的準備時間，而與尺寸無關，所以在更新尺寸時，prepTime 無需改變。

 */


// MARK: - 為何在 OrderItemManager 中增加重置 customerDetails 的邏輯
/**
 
 ## 為何在 OrderItemManager 中增加重置 customerDetails 的邏輯
 
 `1. 保持訂單與顧客資料的同步：`

    - `OrderItemManager` 管理所有的訂單項目，當所有訂單項目被刪除時，代表當前的訂單流程需要完全重新開始。
    - 因此，此時顧客資料也應該被重置，保證整個流程從頭開始，不會殘留之前的資料。
    - 將重置 `customerDetails` 的邏輯放在 `OrderItemManager` 中，可以保證當訂單項目被完全清空時，顧客資料也同步清空，避免狀態不一致的情況。
 
 -----------

 `2. 邏輯集中與責任劃分：`
 
    - `OrderItemManager` 的責任在於管理訂單項目。當訂單被清空時，同時清空顧客資料的邏輯屬於訂單狀態管理的一部分，因此這樣的行為應該由 `OrderItemManager` 來負責。
    - 這樣可以使邏輯更加集中，避免不同管理層之間的責任不清。顧客資料重置與訂單狀態變化同步，能提升可維護性。

 -----------

` 3. 避免重複程式碼：`

    - 若不在 `OrderItemManager` 中加入這個邏輯，可能會導致在 `OrderItemViewController` 或其他地方多次手動調用` resetCustomerDetails()`。這樣做不僅增加了代碼的重複性，也更容易出現錯誤。
    - 在 OrderItemManager 中統一管理這部分邏輯，能避免重複代碼，保持代碼簡潔清晰。
 
 -----------

 `4. 補充`：
 
 - 它涉及到訂單狀態管理的責任範圍，以及在清空訂單時自動處理顧客資料的邏輯。具體來說：

    - `OrderItemManager`：管理訂單項目、處理與訂單相關的增刪改查邏輯，當訂單項目被清空時，對應的顧客資料也應該被重置。
    - `CustomerDetailsManager`：主要負責顧客資料的管理和操作，它不應該去決定何時重置顧客資料，而應由管理訂單狀態的 OrderItemManager 來觸發這一動作。
 */


// MARK: - 筆記：避免冗餘更新與通知觸發
/**
 
 ## 筆記：避免冗餘更新與通知觸發

 `* What`
 
 - 在 `OrderItemManager` 的 `updateOrderItem` 方法中，新增一個條件檢查：
 
    - 用來確保僅在訂單項目的數據（尺寸或數量）發生實際變化時，才執行更新邏輯。

 ```swift
 guard orderItem.size != size || orderItem.quantity != quantity else { return }
 ```

 ---------

 * Why
 
 - 避免冗餘更新：
 
   - 之前的邏輯即使數據沒有變化，依然會更新 `orderItems`，導致 `didSet` 被多次觸發。
   - 冗餘的更新會觸發通知，進而引發多餘的 UI 刷新，影響性能和用戶體驗。
   
 - 減少不必要的通知：
 
   - 通知的重複發送會讓觀察者（如 `OrderItemViewController`）執行多次刷新操作，導致日誌冗餘、按鈕狀態多次更新，甚至可能造成視覺閃爍等問題。

 - 提升效能與穩定性：
 
   - 通過避免冗餘更新，減少不必要的資源消耗和 UI 重繪次數。
   - 確保僅在數據真正變化時觸發通知與刷新，提升邏輯的精確性與可靠性。

 ---------

 `* How`
 
 1. 新增條件檢查
 
 - 在更新邏輯前，檢查數據是否真的變化：
 - 當尺寸或數量沒有變化時，直接返回，不執行後續更新邏輯。

    ```swift
    guard orderItem.size != size || orderItem.quantity != quantity else { return }
    ```
    
 2. 更新訂單數據
 
 - 如果條件檢查通過（數據有變化），執行更新邏輯：
 - 這部分確保數據正確更新到最新狀態。

    ```swift
    orderItem.size = size
    orderItem.quantity = quantity
    orderItem.price = orderItem.drink.sizes[size]?.price ?? 0
    orderItem.totalAmount = orderItem.price * quantity
    orderItems[index] = orderItem
    ```

 3. 減少通知與刷新
 
 - 通過條件檢查減少 `orderItems` 的賦值次數，從而避免不必要的通知觸發：
 - 當 `orderItems` 實際變化時，才會執行 `didSet` 並發送通知。

    ```swift
    NotificationCenter.default.post(name: .orderUpdatedNotification, object: nil)
    ```

 ---------

 `* 總結`
 
 - 核心目的：確保數據變更才執行更新，避免冗餘操作與資源浪費。
 
 - 效果：
   1. 減少通知觸發次數，降低觀察者的冗餘刷新。
   2. 提升性能，避免重複日誌輸出和 UI 問題。
   3. 提高代碼的邏輯準確性與維護性。
 */


import UIKit
import Firebase


/// `OrderItemManager`
///
/// ### 功能描述
/// `OrderItemManager` 是單例類別，負責管理訂單項目列表及其相關操作，提供訂單新增、更新、刪除等功能，
/// 並通過通知機制同步數據變更，確保觀察者（如 UI）及時更新顯示。
class OrderItemManager {
    
    // MARK: - Singleton
    
    /// 單例實例
    static let shared = OrderItemManager()
    
    // MARK: - Properties
    
    /// 當前訂單項目列表
    ///
    /// 每次修改時觸發 `didSet`，自動通知觀察者數據更新，並在清空訂單時重置顧客資料。
    var orderItems: [OrderItem] = [] {
        didSet {
            notifyOrderUpdated()
            resetCustomerDetailsIfEmpty()
        }
    }
    
    // MARK: - Order Items Update Helpers

    /// 發送訂單更新通知
    ///
    /// ### 功能：
    /// - 當 `orderItems` 發生變更時，透過 `NotificationCenter` 發送通知。
    /// - 通知觀察者（如視圖層）更新 UI。
    private func notifyOrderUpdated() {
        print("[OrderItemManager]: 訂單項目更新，當前訂單數量: \(orderItems.count)")
        NotificationCenter.default.post(name: .orderUpdatedNotification, object: nil)
    }

    /// 當訂單為空時，重置顧客資料
    ///
    /// ### 功能：
    /// - 當 `orderItems` 為空時，重置 `CustomerDetailsManager` 的顧客資料。
    /// - 避免顧客資料在無訂單的情況下保留。
    private func resetCustomerDetailsIfEmpty() {
        guard orderItems.isEmpty else { return }
        CustomerDetailsManager.shared.resetCustomerDetails()
        print("[OrderItemManager]: 所有訂單項目已被清空，重置顧客資料")
    }
    
    // MARK: - Order Management Methods
    
    /// 新增訂單項目
    ///
    /// ### 功能：
    /// 根據提供的飲品詳細信息，創建並添加新的訂單項目到 `orderItems` 列表中。
    ///
    /// - Parameters:
    ///   - drink: 選擇的飲品物件，包含名稱、價格等詳細信息。
    ///   - size: 飲品的尺寸（如小杯、中杯、大杯）。
    ///   - quantity: 購買數量。
    func addOrderItem(drink: Drink, size: String, quantity: Int) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        print("為使用者 \(user.uid) 添加訂單項目")
        
        // 計算飲品價格與總金額
        let prepTime = drink.prepTime
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        
        // 建立新的訂單項目
        let orderItem = OrderItem(drink: drink, size: size, quantity: quantity, prepTime: prepTime, totalAmount: totalAmount, price: price)
        
        // 添加到訂單列表
        orderItems.append(orderItem)
        print("添加訂單項目 ID: \(orderItem.id)")
    }
    
    /// 更新訂單項目的`尺寸`與`數量`
    ///
    /// ### 功能：
    /// 根據提供的 ID，更新對應的訂單項目的尺寸與數量，並自動重新計算價格與總金額。
    ///
    /// - Parameters:
    ///   - id: 要更新的訂單項目 ID。
    ///   - size: 新的尺寸。
    ///   - quantity: 新的數量。
    ///
    /// ### 設計優化：
    /// 僅在數據有實際變更時執行更新，避免冗餘操作。
    /// 更新了訂單項目的尺寸和數量，同時也更新了價格和總金額。
    /// `prepTime` 不變，因為它取決於飲品類型，而非尺寸。
    func updateOrderItem(withID id: UUID, with size: String, and quantity: Int) {
        guard let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        var orderItem = orderItems[index]
        
        // 僅在數據變更時進行更新，避免冗餘操作
        guard orderItem.size != size || orderItem.quantity != quantity else { return }
        
        // 更新尺寸、數量及相關金額
        orderItem.size = size
        orderItem.quantity = quantity
        orderItem.price = orderItem.drink.sizes[size]?.price ?? 0
        orderItem.totalAmount = orderItem.price * quantity
        
        // 更新列表中的訂單項目
        orderItems[index] = orderItem
    }
    
    /// 清空所有訂單項目
    ///
    /// ### 功能：
    /// 清空 `orderItems` 列表，並自動觸發通知與顧客資料重置。
    func clearOrder() {
        orderItems.removeAll()
    }
    
    /// 刪除特定訂單項目
    ///
    /// ### 功能：
    /// 根據指定的 ID，從 `orderItems` 列表中移除對應的訂單項目。
    ///
    /// - Parameter id: 要刪除的訂單項目 ID。
    func removeOrderItem(withID id: UUID) {
        orderItems.removeAll { $0.id == id }
    }
    
    // MARK: - Public Helper Methods
    
    /// 計算所有飲品的總準備時間
    ///
    /// ### 功能：
    /// 遍歷所有訂單項目，根據數量累加準備時間。
    ///
    /// - Returns: 訂單的總準備時間（分鐘）。
    func calculateTotalPrepTime() -> Int {
        return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
    }
    
    /// 計算訂單的總金額
    ///
    /// ### 功能：
    /// 遍歷所有訂單項目，累加各項目的總金額。
    ///
    /// - Returns: 訂單的總金額。
    func calculateTotalAmount() -> Int {
        return orderItems.reduce(0) { $0 + $1.totalAmount }
    }
    
}
