//
//  CustomerDetails.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/9.
//

/*
 ## 筆記：

    - CustomerDetails 是用來描述顧客的詳細資料，其中 fullName 和 phoneNumber 是必填欄位。
    - pickupMethod 可以是到店取件或外送服務，這個屬性影響了其他欄位是否需要填寫（如地址或取件店名）。
    - 如果顧客選擇外送服務，就會需要填寫 address，而到店取件則需填寫 storeName。
 */

import Foundation

/// `顧客詳細資料`結構，用於描述訂單中的顧客相關資訊
struct CustomerDetails: Codable {
    var fullName: String                      // 顧客姓名（必填）
    var phoneNumber: String                   // 顧客電話（必填）
    var pickupMethod: PickupMethod            // 取件方式，包含 "到店取件" 或 "外送服務"
    var address: String?                      // 配送地址（選填），只有選擇外送服務時才需填寫
    var storeName: String?                    // 取件店家名稱（選填），只有選擇到店取件時才需填寫
    var notes: String?                        // 額外備註（選填），可填寫特殊需求或提醒事項
}

/// 取件方式的枚舉類型，用於描述顧客選擇的取件方式
enum PickupMethod: String, Codable {
    case homeDelivery = "Home Delivery"       // 外送服務
    case inStore = "In-Store Pickup"          // 到店取件
}
