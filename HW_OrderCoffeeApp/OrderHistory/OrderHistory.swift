//
//  OrderHistory.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: -  重點筆記：OrderHistory 資料模型

/**
 ## 重點筆記：OrderHistory 資料模型
 
 `1.OrderHistory 結構：`
 
    - 用於描述從 Firestore 獲取的歷史訂單資料，包括訂單的唯一標識符（id）、顧客詳細資料（customerDetails）、訂單項目（orderItems）、時間戳（timestamp）、總準備時間（totalPrepTime）以及訂單總金額（totalAmount）。

` 2.OrderHistoryCustomerDetails 顧客詳細資料：`

    - fullName：顧客姓名。
    - phoneNumber：顧客電話。
    - pickupMethod：取件方式，包括外送或到店取件。
    - address：配送地址（選填）。
    - storeName：取件店家名稱（選填）。
    - notes：訂單備註（選填）。

 `3.OrderHistoryItem 訂單項目模型：`

    - 包含飲品的詳細資料（drink）、尺寸（size）、數量（quantity）、單項價格（price）。
 
    - Drink 子結構：
        name：飲品名稱。
        subName：飲品子名稱（例如：特殊口味說明）。
        imageUrl：飲品圖片的 URL。

 `4.OrderHistoryPickupMethod 列舉：`

    - 取件方式選擇：
        - homeDelivery：外送服務。
        - inStore：到店取件。
 
 `* 調整後的優點`

    - `資料結構明確劃分`：OrderHistory 的每一部分都有清晰的分工，資料結構與 Firebase 返回的 JSON 完全對應，避免解析錯誤。
    - `Drink 嵌套結構`：新增 Drink 嵌套結構，有助於更好地描述訂單中飲品的詳細資訊，減少結構混亂的可能性。
    - `可選型別的使用`：對於配送地址、店家名稱、以及備註等可能為空的資料使用可選型別，增加了程式的彈性和穩定性。
 
 `* 適用場景`
 
    - 此模型適合用於訂單歷史記錄的展示，特別是在需要從 Firestore 獲取資料並呈現訂單的情境。這些模型結構可以幫助你在 UI 層級上展示訂單的詳細資訊，例如顯示顧客姓名、訂單中的飲品明細、取件方式等，提供更好的用戶體驗。
 */

import Foundation

/// 歷史訂單，用於從 Firestore 獲取並顯示的訂單資料。
struct OrderHistory: Codable {
    let id: String                                      // 訂單唯一標識符（作為訂單的唯一識別）
    let customerDetails: OrderHistoryCustomerDetails    // 顧客資料（包括姓名、電話、取件方式等資訊）
    let orderItems: [OrderHistoryItem]                  // 訂單中的飲品項目列表
    let timestamp: Date                                 // 訂單建立時間（用於顯示訂單生成的時間）
    let totalPrepTime: Int                              // 訂單的總準備時間（用於顯示準備所需的總時間）
    let totalAmount: Int                                // 訂單的總金額（用於顯示訂單的最終金額）
}

/// 歷史訂單顧客詳細資料
struct OrderHistoryCustomerDetails: Codable {
    let fullName: String                                // 顧客姓名
    let phoneNumber: String                             // 顧客電話
    let pickupMethod: OrderHistoryPickupMethod          // 取件方式
    let address: String?                                // 配送地址
    let storeName: String?                              // 取件店家名稱
    let notes: String?                                  // 額外備註
}

/// 歷史訂單項目模型
struct OrderHistoryItem: Codable {
    let drink: Drink                // 飲品資料（包含名稱、子名稱、圖片等）
    let size: String                // 飲品尺寸
    let quantity: Int               // 飲品數量
    let price: Int                  // 單項飲品價格
    
    /// 鉗套結構，用於描述飲品的詳細資料
    struct Drink: Codable {
        let name: String                // 飲品名稱
        let subName: String             // 飲品子名稱
        let imageUrl: URL               // 飲品圖片 URL
    }
}

/// 用於顯示顧客的取件選擇。
enum OrderHistoryPickupMethod: String, Codable {
    case homeDelivery = "Home Delivery"  // 外送服務
    case inStore = "In-Store Pickup"     // 到店取件
}


