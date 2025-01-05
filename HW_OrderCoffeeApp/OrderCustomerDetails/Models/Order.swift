//
//  Order.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/9.
//

/*
 ## 筆記：
 
    - Order 是用於記錄完整訂單的結構，包含顧客詳細資料、訂單中的所有飲品項目、訂單建立時間、總金額，以及總準備時間。
    - 將 totalAmount 設置為 Order 中的屬性，而非計算屬性，這樣可以在檢視訂單時快速得到總金額，不需要每次重新計算，並且確保在包含外送服務費的情況下能正確地顯示。
    - totalPrepTime 為計算屬性，透過所有飲品項目計算訂單的總準備時間。
    - 設置 Order 的 id 為 UUID，以便在 Firebase 中有效管理和查詢訂單。每個訂單都有唯一的識別符，這樣可以在「用戶子集合」和「全局訂單集合」中追蹤同一筆訂單，確保資料的一致性。
    - 這些改動主要是為了在資料庫操作中保持一致性並提高讀取效率，尤其在檢視歷史訂單時，不再需要重新計算總金額，而是直接使用記錄的金額。
 
 */


import Foundation

/// 訂單結構，包含`顧客資料`與`訂單項目`
struct Order: Codable {
    var id: UUID                             // 訂單唯一標識符，用於在 Firebase 中區分每個訂單
    var customerDetails: CustomerDetails     // 顧客詳細資料（包含姓名、電話、取件方式等）
    var orderItems: [OrderItem]              // 訂單中所有的飲品項目
    var timestamp: Date                      // 訂單建立時間，用於追蹤訂單生成的時間
    var totalAmount: Int                     // 訂單的總金額
    
    // 計算屬性：總準備時間
    var totalPrepTime: Int {
        return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
    }
    
}
