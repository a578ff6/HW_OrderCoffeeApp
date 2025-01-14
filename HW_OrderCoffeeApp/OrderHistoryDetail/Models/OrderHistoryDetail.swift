//
//  OrderHistoryDetail.swift.
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

// MARK: - OrderHistoryDetail 與 OrderHistory 的結構不同之處 重點筆記
/**
 
 ## OrderHistoryDetail 與 OrderHistory 的結構不同之處 重點筆記

` * 資料的詳細程度：`

 - `OrderHistoryDetail` 提供了更詳細的訂單資訊，包括 `orderItems`（訂單中的每個飲品項目）和飲品的所有細節。
 - `OrderHistory` 則僅包含基本的訂單概覽（如 id、customerDetails、timestamp、totalAmount），沒有細項飲品列表。
 
 ---
 
 `* 訂單項目：`

 - `OrderHistoryDetail` 包含一個 `orderItems` 屬性，是 `OrderHistoryItemDetail` 的陣列，專門用於顯示訂單中的各個飲品的詳細資訊。
 - `OrderHistory` 並未包含 `orderItems`，因此僅顯示訂單的基本資料。
 
 ---

 `* 顧客資料結構：`

 - `OrderHistoryDetail` 使用 `OrderHistoryDetailCustomerInfo`，其內容包含了配送地址和店家名稱等額外資訊。
 - `OrderHistory` 中的顧客資料為簡化版，並不包含飲品和訂單項目的詳盡內容。
 
 ---

 `* 應用場景不同：`

 - `OrderHistory` 主要用於列表頁面，提供基本訂單信息以便於快速顯示給用戶。
 - `OrderHistoryDetail` 用於點擊單個訂單後的詳細頁面，提供更深入的資訊以滿足用戶的查詢需求。
 
 ---

 `* 使用情境`

 - `OrderHistoryDetail` 結構用於詳細描述每一筆訂單，尤其是在使用者點擊歷史訂單項目，進入訂單詳細頁面時，顯示該筆訂單的完整資訊。
 - `OrderHistory` 主要用於訂單列表顯示頁面，包含每筆訂單的基本概覽，如訂單編號、顧客資料、訂單日期等。
 
 ---

 `* 設計優勢與考量`

 - `資料結構的分層設計`：將詳細信息和概覽信息分開，使得列表頁和詳細頁的顯示效率更高。列表頁面只需展示概覽信息，降低了數據處理的負擔，而詳細頁面則提供全方位的訂單資料。
 - `擴展性與可維護性`：若需要在顯示訂單時添加新屬性（如詳細飲品信息），只需修改 OrderHistoryDetail，而不影響 OrderHistory，增加了代碼的可維護性和擴展性。
 - `性能優化`：在展示訂單列表時，只需要使用 OrderHistory 的基本信息，避免了不必要的數據加載，從而提升了 UI 的加載速度和響應效率。
 */


// MARK: -  OrderHistoryDetail 重點筆記
/**
 
 ## OrderHistoryDetail 重點筆記
 
 `* OrderHistoryDetail 概述`

 - `功能描述`：`OrderHistoryDetail` 資料結構主要用於描述歷史訂單的詳細內容，包含訂單 ID、顧客資料、訂單中的飲品項目、建立時間、總準備時間及總金額等。
 - `資料驅動`：使用 `Codable` 協定來實現 JSON 編碼和解碼，便於與 Firebase Firestore 或其他 API 通訊時的數據序列化和反序列化。
 
 ---

 `* 結構與屬性詳解`

 `1. OrderHistoryDetail`

 - id：訂單的唯一標識符。
 - customerDetails：顧客資料，使用 OrderHistoryDetailCustomerInfo 結構來描述顧客的相關信息。
 - orderItems：訂單中的飲品項目列表，使用 OrderHistoryItemDetail 陣列來表示訂單中所有的飲品詳細資料。
 - timestamp：訂單建立的時間，主要用於顯示訂單生成的日期和時間。
 - totalPrepTime：訂單的總準備時間，以分鐘為單位，用於顯示訂單準備所需的時間。
 - totalAmount：訂單的總金額，以顯示訂單的最終付款金額。
 
 `2. OrderHistoryDetailCustomerInfo`

 - fullName：顧客的全名。
 - phoneNumber：顧客的聯絡電話。
 - pickupMethod：顧客的取件方式，使用 OrderHistoryDetailPickupMethod 枚舉來表示是外送服務還是到店取件。
 - address：顧客的配送地址，當取件方式為外送時會有此資料。
 - storeName：取件店家的名稱，當取件方式為到店取件時會有此資料。
 - notes：顧客對訂單的額外備註，例如特殊需求或其他提醒。
 
 `3. OrderHistoryItemDetail`

 - drink：飲品的詳細資料，使用 Drink 結構來描述飲品名稱、子名稱和圖片。
 - size：飲品的尺寸，如大杯、中杯等。
 - quantity：飲品的訂購數量。
 - price：該飲品的單項價格，以整數表示。
 
 `4. OrderHistoryDetailPickupMethod`

 - homeDelivery：外送服務。
 - inStore：到店取件。
 
 ---

 `* 使用情境`
 
 - `OrderHistoryDetail` 結構用於詳細描述每一筆訂單，尤其是在使用者點擊歷史訂單項目，進入訂單詳細頁面時，顯示該筆訂單的完整資訊。
 - `OrderHistoryDetailManager` 負責從 Firebase Firestore 獲取詳細的訂單資料，並透過 OrderHistoryDetail 模型解析，確保資料的正確性和結構的一致性。
 
 ---

 `* 優勢與設計考量`

 - `資料結構清晰`：通過將訂單的詳細資料分成 `OrderHistoryDetail`、`OrderHistoryDetailCustomerInfo` 和 `OrderHistoryItemDetail`，每個結構負責特定的資料部分，使程式碼結構清晰，便於維護和擴展。
 - `資料分層顯示`：顧客資料與訂單項目詳細資料進行分層顯示，使 UI 顯示時能更方便地組織和布局不同部分的資訊。
 */


import Foundation

/// `OrderHistoryDetail` 用於表示一筆歷史訂單的詳細資料，包括顧客訊息、訂單項目列表、時間戳等。
struct OrderHistoryDetail: Codable {
    let id: String                                            // 訂單唯一標識符（作為訂單的唯一識別）
    let customerDetails: OrderHistoryDetailCustomerInfo       // 顧客資料（包括姓名、電話、取件方式等資訊）
    let orderItems: [OrderHistoryItemDetail]                  // 訂單中的飲品項目列表
    let timestamp: Date                                       // 訂單建立時間（用於顯示訂單生成的時間）
    let totalPrepTime: Int                                    // 訂單的總準備時間（用於顯示準備所需的總時間）
    let totalAmount: Int                                      // 訂單的總金額（用於顯示訂單的最終金額）
}

/// 顧客詳細資料，用於表示顧客信息，如姓名、電話、取件方式等。
struct OrderHistoryDetailCustomerInfo: Codable {
    let fullName: String                                // 顧客姓名
    let phoneNumber: String                             // 顧客電話
    let pickupMethod: OrderHistoryDetailPickupMethod    // 取件方式
    let address: String?                                // 配送地址
    let storeName: String?                              // 取件店家名稱
    let notes: String?                                  // 額外備註
}

/// 訂單項目的詳細資料，用於表示訂單中每個飲品項目及其訊息。
struct OrderHistoryItemDetail: Codable {
    let drink: Drink                                    // 飲品資料（包含名稱、子名稱、圖片等）
    let size: String                                    // 飲品尺寸
    let quantity: Int                                   // 飲品數量
    let price: Int                                      // 單項飲品價格
    
    /// `Drink` 用於表示飲品的詳細資料，如名稱、子名稱、圖片等。
    struct Drink: Codable {
        let name: String                // 飲品名稱
        let subName: String             // 飲品子名稱
        let imageUrl: URL               // 飲品圖片 URL
    }
}

/// `OrderHistoryDetailPickupMethod` 枚舉，用於表示取件方式
enum OrderHistoryDetailPickupMethod: String, Codable {
    case homeDelivery = "Home Delivery"  // 外送服務
    case inStore = "In-Store Pickup"     // 到店取件
}
