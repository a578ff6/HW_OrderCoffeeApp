//
//  Order.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/9.
//

/*
 ## 筆記：
 
    - Order 是用於記錄完整訂單的結構，包含了顧客的詳細資料、訂單中的所有飲品項目，以及訂單的建立時間和總金額。
    - 將 totalAmount 記錄在 Order 中，可以在檢視訂單時快速得到總金額，不需要每次重新計算。（測試中）
    - 設置 `Order` 的 `id` 為 UUID，以便在 Firebase 中有效地管理和查詢訂單，每個訂單都能有唯一的識別符。這樣可以在「用戶子集合」和「全局訂單集合」中追蹤同一筆訂單，以確保資料的一致性。

 */


import Foundation

/// 訂單結構，包含`顧客資料`與`訂單項目`
struct Order: Codable {
    var id: UUID                             // 訂單唯一標識符，用於在 Firebase 中區分每個訂單
    var customerDetails: CustomerDetails     // 顧客詳細資料（包含姓名、電話、取件方式等）
    var orderItems: [OrderItem]              // 訂單中所有的飲品項目
    var timestamp: Date                      // 訂單建立時間，用於追蹤訂單生成的時間
    
    /// 計算屬性：訂單的總金額
    ///
    /// 使用 `orderItems` 中每個項目的 `totalAmount` 來計算訂單的總金額。
    /// 保證每次查詢時總金額都是即時且準確的。
    var totalAmount: Int {
        return orderItems.reduce(0) { $0 + $1.totalAmount }
    }

}
