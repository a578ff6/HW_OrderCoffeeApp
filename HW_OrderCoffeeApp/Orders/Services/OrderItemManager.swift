//
//  OrderItemManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/9.
//

/*
 
 ## 重點筆記 - OrderItemManager

    &. 用途：
        - OrderItemManager 用於管理當前的訂單項目列表，包含增、刪、改訂單項目的方法，以及計算總金額與準備時間的功能。
        - 通過 OrderItemManager，可以方便地對訂單項目進行操作，例如新增飲品至訂單、更新訂單項目、刪除單一訂單項目，或是清空整個訂單。
 
    &. 功能：
 
        1. 訂單操作方法
            - 新增訂單項目 (addOrderItem)：用於向當前訂單列表中新增飲品，並計算總價等屬性。
            - 更新訂單項目 (updateOrderItem)：更新指定訂單項目的尺寸和數量，並重新計算其價格與總金額。
            - 清空訂單 (clearOrder)：移除所有的訂單項目。
            - 刪除特定訂單項目 (removeOrderItem)：根據訂單項目 ID，從訂單列表中刪除對應的項目。
 
        2. 訂單數據計算
            - 計算所有飲品的準備時間 (calculateTotalPrepTime)： 遍歷所有訂單項目，根據飲品數量來累計準備時間。
            - 計算訂單的總金額 (calculateTotalAmount)： 遍歷所有訂單項目，累加每項訂單的金額來計算訂單的總金額。
 
    &. 說明：
        
        * orderItems：訂單項目列表，每次修改訂單項目（例如新增、刪除或更新）後，會透過 didSet 屬性監聽器來發送通知，確保其他視圖可以及時同步顯示。
 
        * updateOrderItem 詳細說明：
            - 更新訂單項目的尺寸和數量，並確保相關的價格與總金額屬性同步更新。
            - 對於 prepTime，因為該屬性是基於飲品的準備時間，而與尺寸無關，所以在更新尺寸時，prepTime 無需改變。
 
    &. 適用場景：
 
        * 當用戶在訂單中新增、修改或刪除飲品時，OrderItemManager 提供了一個集中化的管理入口來處理這些操作，並自動觸發對應的視圖更新。

        * 在需要計算整體訂單金額或總準備時間時，OrderItemManager 可以方便地提供這些數據。
 */

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

/// OrderItemManager 負責管理當前的`訂單項目列表`（如增加、更新、刪除），管理當前的狀態。
class OrderItemManager {
    
    static let shared = OrderItemManager()
    
    // MARK: - Properties
    
    /// 當前訂單項目列表
    var orderItems: [OrderItem] = [] {
        didSet {
            print("訂單項目更新，當前訂單數量: \(orderItems.count)")
            NotificationCenter.default.post(name: .orderUpdatedNotification, object: nil)   // 當訂單變更時發送通知
        }
    }
    
    // MARK: - Order Management Methods

    /// 新增訂單項目
    /// - Parameters:
    ///   - drink: 選擇的飲品
    ///   - size: 飲品的尺寸
    ///   - quantity: 數量
    ///   - categoryId: 飲品所屬的類別 ID
    ///   - subcategoryId: 飲品所屬的子類別 ID
    func addOrderItem(drink: Drink, size: String, quantity: Int, categoryId: String?, subcategoryId: String?) {
        
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        print("為使用者 \(user.uid) 添加訂單項目")

        let prepTime = drink.prepTime   // 使用飲品的準備時間（分鐘）
        let timestamp = Date()      // 當前時間
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        
        let orderItem = OrderItem(drink: drink, size: size, quantity: quantity, prepTime: prepTime, totalAmount: totalAmount, price: price, categoryId: categoryId, subcategoryId: subcategoryId)
        
        orderItems.append(orderItem)
        print("添加訂單項目 ID: \(orderItem.id)")
    }

    /// 更新訂單中的訂單項目的`尺寸`&`數量`
    /// - Parameters:
    ///   - id: 訂單項目 ID
    ///   - size: 新的尺寸
    ///   - quantity: 新的數量
    ///
    /// 更新了訂單項目的尺寸和數量，同時也更新了價格和總金額。
    /// `prepTime` 不變，因為它取決於飲品類型，而非尺寸。
    func updateOrderItem(withID id: UUID, with size: String, and quantity: Int) {
        guard let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let drink = orderItems[index].drink
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        
        orderItems[index].size = size
        orderItems[index].quantity = quantity
        orderItems[index].price = price
        orderItems[index].totalAmount = totalAmount
    }
    
    /// 清空訂單
    func clearOrder() {
        orderItems.removeAll()
    }
    
    /// 刪除特定訂單項目
    /// - Parameter id: 訂單項目 ID
    func removeOrderItem(withID id: UUID) {
        orderItems.removeAll { $0.id == id }
    }
    
    // MARK: - Public Helper Methods

    /// 計算所有飲品的準備時間
    /// - Returns: 總準備時間（分鐘）
    func calculateTotalPrepTime() -> Int {
        return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
    }
    
    /// 計算訂單的總金額
    /// - Returns: 總金額
    func calculateTotalAmount() -> Int {
        return orderItems.reduce(0) { $0 + $1.totalAmount }
    }
    
}
