//
//  OrderConfirmation.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/4.
//

// MARK: - 重點筆記：為何設置 OrderConfirmation 模型
/**
 ### 重點筆記：為何設置 `OrderConfirmation` 模型

 `1. 專門化用途，適應特定場景需求`

    - `OrderConfirmation` 模型的設計目的是為了處理特定場景，即`訂單確認頁面的顯示與數據獲取`。訂單確認頁面需要展示最終提交的訂單內容，如顧客資料、訂單項目、取件方式等。
    - 相比較原有的 `Order` 模型，`OrderConfirmation` 專注於顯示特定的信息，去除了不需要的細節，使它在這個場景下更輕量、更易於處理。

 `2. 保持數據模型的簡潔性與專屬性`

    - 原有的 `Order` 模型結構複雜，包含了一些在訂單提交過程中才有用的額外字段，如內部處理邏輯、計算準備時間等。
    - 這些字段在訂單確認頁面並沒有直接展示或必要。因此，通過設計一個專屬的模型來處理訂單確認頁面，可以`保持數據模型的簡潔性與專屬性`，避免冗餘數據的解碼，進而提升性能與可靠性。

 `3. 解碼數據更靈活，避免解碼錯誤`

    - 在從 Firestore 獲取訂單資料時，直接使用原始的 `Order` 模型進行解碼，往往會遇到一些不匹配的情況。
    - 例如，原有模型的某些字段要求是必須的，但上傳到 Firestore 時，有些字段可能是可選的或是完全省略的。
    - 因此，設計一個專屬的解碼模型（`OrderConfirmation`）可以使解碼過程更加靈活，根據需要設置字段的選擇性，從而避免解碼錯誤。

    `* 例如：`
        - 原始的 `Order` 模型中的 `description` 字段可能是必需的，但 Firestore 中不需要該字段，因此會導致解碼失敗。
        - 通過設計 `OrderConfirmation` 模型，可以只包含必要的字段，避免不匹配的字段造成的錯誤。

 `4. 降低耦合性，提高維護性`

    - 不同的場景對數據有著不同的需求，若直接使用統一的數據模型，不同功能間的變更可能會互相影響。例如，修改 `Order` 模型中的一個字段，可能會導致訂單確認的顯示功能需要不必要的調整。
    - 通過設計一個專門的 `OrderConfirmation` 模型，可以將不同場景之間的耦合降到最低，提高代碼的維護性，便於針對特定場景進行調整。

 `5. 簡化顯示邏輯，提高開發效率`

    - 訂單確認頁面只需展示核心的顧客資料、訂單項目、取件方式和總金額等信息，因此 `OrderConfirmation` 模型只包含與顯示相關的字段，去除了額外的處理信息。
    
   ` * 例如：`
        - `OrderConfirmationCustomerDetails` 只包含顧客姓名、電話、取件方式等基本信息，無需包含與訂單處理邏輯相關的複雜字段。
        - 這樣的設計可以`簡化顯示邏輯`，避免顯示層處理與展示無關的信息，從而提高開發效率和代碼的可讀性。

 `6. 數據隔離性，減少業務邏輯相互干擾`

    - 使用專屬的 `OrderConfirmation` 模型可以確保數據的隔離性，即`避免不同層之間的業務邏輯互相干擾`。
    - `OrderConfirmation` 專門用於顯示訂單確認信息，和訂單提交的業務邏輯分開，使得在修改提交邏輯時不會影響顯示功能的正常運行，反之亦然。

    `* 例如：`
        - 如果訂單結構需要調整以適應新的業務需求（例如增加內部計算字段），只需更改 `Order` 模型，`OrderConfirmation` 無需同步修改。
        - 這樣的設計降低了不同功能之間的耦合，減少未來擴展和維護時出現潛在問題的機會。

 `### 總結`

    - 設計 `OrderConfirmation` 模型的主要目的，是為了讓數據的處理更簡潔、靈活、且能夠應對不同場景的需求。
    - 透過設置專屬的模型，不僅提高了代碼的可讀性和維護性，也確保了解碼過程的安全性，並減少了因不同功能耦合導致的修改困難。
    - 此外，針對特定場景設計專屬的枚舉類型，能讓代碼更加專注、靈活，進一步提升開發效率。
 */


import Foundation

/// 訂單確認模型，用於從 Firestore 獲取並顯示的訂單資料。
/// - 設計用途：專門用於從 Firebase Firestore 中獲取並解碼訂單資料，並在訂單確認頁面中使用
struct OrderConfirmation: Codable {
    var id: String                                          // 訂單唯一標識符（作為訂單的唯一識別）
    var customerDetails: OrderConfirmationCustomerDetails   // 顧客資料（包括姓名、電話、取件方式等資訊）
    var orderItems: [OrderConfirmationItem]                 // 訂單中的飲品項目列表
    var timestamp: Date                                     // 訂單建立時間（用於顯示訂單生成的時間）
    var totalPrepTime: Int                                  // 訂單的總準備時間（用於顯示準備所需的總時間）
    var totalAmount: Int                                    // 訂單的總金額（用於顯示訂單的最終金額）
}

/// 顧客詳細資料
struct OrderConfirmationCustomerDetails: Codable {
    var fullName: String                                  // 顧客姓名
    var phoneNumber: String                               // 顧客電話
    var pickupMethod: OrderConfirmationPickupMethod       // 取件方式
    var address: String?                                  // 配送地址
    var storeName: String?                                // 取件店家名稱
    var notes: String?                                    // 額外備註
}

/// 訂單項目模型
struct OrderConfirmationItem: Codable {
    var drink: Drink                        // 飲品資料（包含名稱、子名稱、圖片等）
    var size: String                         // 飲品尺寸
    var quantity: Int                        // 飲品數量
    var price: Int                           // 單項飲品價格
    
    /// 鉗套結構，用於描述飲品的詳細資料
    struct Drink: Codable {
        var name: String                     // 飲品名稱
        var subName: String                  // 飲品子名稱
        var imageUrl: URL                    // 飲品圖片 URL
    }
}

/// 用於顯示顧客的取件選擇。
enum OrderConfirmationPickupMethod: String, Codable {
    case homeDelivery = "Home Delivery"  // 外送服務
    case inStore = "In-Store Pickup"     // 到店取件
}
