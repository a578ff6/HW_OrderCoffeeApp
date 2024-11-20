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
  
 * `功能描述`：`OrderHistory` 結構主要用於從 Firestore 獲取並顯示歷史訂單的概覽資料。這些資料主要用於顯示訂單列表頁面，使得用戶能快速瀏覽過去訂單的基本信息。

    - id：訂單的唯一標識符，用於唯一識別每筆訂單。
    - customerDetails：顧客資料，使用 OrderHistoryCustomerDetails 結構描述顧客的基本信息，如姓名、電話、取件方式等。
    - timestamp：訂單建立的時間，顯示訂單生成的日期和時間。
    - totalPrepTime：訂單的總準備時間，用於顯示訂單準備所需的時間。
    - totalAmount：訂單的總金額，顯示該筆訂單的最終付款金額。
 
` 2.OrderHistoryCustomerDetails 顧客詳細資料：`

    - fullName：顧客姓名。
    - phoneNumber：顧客電話。
    - pickupMethod：取件方式，包括外送或到店取件。
    - address：配送地址（選填）。
    - storeName：取件店家名稱（選填）。

 `3.OrderHistoryPickupMethod 列舉：`

    - 取件方式選擇：
        - homeDelivery：外送服務。
        - inStore：到店取件。
 
 `* 調整後的優點`

    - `資料結構明確劃分`：OrderHistory 的每一部分都有清晰的分工，資料結構與 Firebase 返回的 JSON 完全對應，避免解析錯誤。
    - `Drink 嵌套結構`：新增 Drink 嵌套結構，有助於更好地描述訂單中飲品的詳細資訊，減少結構混亂的可能性。
    - `顧客詳細資料結構化`：顧客資料（`OrderHistoryCustomerDetails`）包含了顧客的基本聯絡信息及取件方式，並根據具體情況顯示取件店家或配送地址，增強了結構的可讀性。
    - `可選型別的使用`：對於配送地址、店家名稱、以及備註等可能為空的資料使用可選型別，增加了程式的彈性和穩定性。
 
 `* 適用場景`
 
    - `適用於訂單歷史列表的展示：`
        -  此模型結構非常適合在訂單歷史記錄列表中進行展示。例如：應用程序的「歷史訂單」頁面中，每一筆訂單只需顯示基本資料，如顧客姓名、取件方式、訂單建立時間等，便於用戶快速查看。
 
    - `主要用途為列表頁面概覽信息：`
        - `OrderHistory` 並不包括訂單的所有細節（例如飲品的具體信息），這使得它非常適合列表頁面的使用場景，快速顯示基本的訂單信息，減少不必要的資料加載，以提高列表顯示的性能。
 
 `* 與 OrderHistoryDetail 的不同之處`
 
 `1.資料範圍：`
    - `OrderHistory` 是訂單的概覽信息，適用於訂單列表頁面的快速預覽，並不包含詳細的飲品信息。
    - `OrderHistoryDetail` 則是訂單的完整描述，包含訂單中的每個飲品項目，用於顯示訂單的詳細內容。
 
 `2.應用場景：`
    - `OrderHistory` 的主要用途是在列表頁面中展示多筆訂單的基本資料，這樣用戶可以快速查看訂單記錄。
    - 當用戶點擊具體的訂單項目時，會進入詳細頁面，這時就需要使用 `OrderHistoryDetail` 來顯示完整的訂單細節，包括飲品信息、訂單備註等。
 
 `3.性能與加載效率：`
    - `OrderHistory` 中只包含訂單的概覽信息，減少不必要的數據加載，從而提高 UI 的加載速度和性能。
    - `OrderHistoryDetail` 在進入詳細頁面時才會被加載，以確保在用戶真正需要查看詳細信息時才執行較多的數據讀取操作。
 
 `4. 資料拆分與處理策略`
 
 `4.1 移除 orderItems 並簡化 OrderHistory`
 
    - `目的`：
        - 移除 `orderItems`，保持訂單的基本資料，使得初次載入訂單列表時更加輕量。
 
    - `優點`：
        - 減少初次載入時的資料量，減少網絡流量與資料處理的負擔，讓 `OrderHistoryViewController` 中的列表加載更快、更加輕量化。
 
 `4.2 資料完整性與一致性管理`
 
    - `延遲載入完整資料`：
        - 在進入詳細頁面（`OrderHistoryDetailViewController`）時再向 Firebase 請求完整的訂單資料，包括飲品項目等細節。
 
    - `處理異步請求`：
        - 詳細頁面會根據傳遞過來的訂單 ID，向 Firebase 發送額外的請求來獲取完整資料，這樣的設計雖然引入了額外的網絡請求，但能減少 OrderHistoryViewController 初次載入的等待時間。
 
 `4.3 資料拆分後的實作與維護`
 
 `OrderHistoryViewController 負責展示基本資料：`

 - 在列表中展示訂單 ID、顧客名稱、金額和訂單建立時間等基本信息。
 - 當用戶點擊訂單時，將`訂單 ID` 傳遞給 `OrderHistoryDetailViewController`。
 
 `OrderHistoryDetailViewController 負責完整資料的呈現：`

 - 根據訂單 ID，進行一次額外的網絡請求來獲取完整資料（包括飲品項目列表）。
 - 添加加載指示器，以處理異步加載，確保用戶在等待完整資料時能獲得良好的體驗。
 
 `5. 資料拆分的利弊權衡`
 
 `* 優點：`

 - `減少初次載入的壓力`：將完整訂單資料拆分，列表頁面只加載基本資料，能提升應用程序的載入速度。
 - `提升用戶體驗`：詳細資料在用戶需要時才載入，這樣不會對主列表的載入造成過大負擔。
 
` * 可能的複雜性：`

 - `額外的網絡請求`：詳細頁面需要額外進行一次資料請求，這需要處理異步邏輯、網絡延遲以及錯誤情況。
 - `狀態管理的增加`：需要額外處理異步請求的狀態，例如加載中、請求失敗的錯誤處理等，這會增加一定的代碼複雜度。
 
 `6. 適用情境`
 
 - `完整資料載入適合的情況`：如果訂單的項目數量不多，保留完整資料並直接在 `OrderHistoryViewController` 中展示，這樣詳細頁面可以直接使用傳遞的資料，減少網絡請求和狀態管理的複雜性。
 - `延遲載入適合的情況`：如果訂單包含較多飲品項目，或用戶的歷史訂單數量龐大，建議採用延遲載入方式，以確保應用程序性能良好且用戶體驗不受影響。
 
 `7. 總結`
 
 - 移除 `orderItems` 後，`OrderHistory` 的結構更加簡潔，有助於提高 `OrderHistoryViewController` 的加載速度。
 - 如果需要顯示詳細訂單資料，可以在 `OrderHistoryDetailViewController` 中進行延遲加載，這樣可以更好地平衡應用性能和用戶體驗。
 - 根據應用情境選擇資料處理方式：若資料量少則可保持完整性，資料量大則可選擇延遲載入。
 */


// MARK: - ## OrderHistory  與 Order History Detail 資料處理重點筆記（重要）
/**
 ## OrderHistory 資料處理重點筆記

 `1. 移除 orderItems 並簡化 OrderHistory`

 `* 目的：`
    - 將 `OrderHistory` 中的 `orderItems`（飲品項目列表）移除，保持訂單的基本資料（例如顧客資訊、訂單時間、金額等），使得初次載入訂單列表時更加輕量。
 
 `* 優點：`
    - 減少初次載入時的資料量，減少網路流量與資料處理的負擔，讓 `OrderHistoryViewController` 中的列表加載更快、更加輕量化。

 `2. 資料完整性與一致性管理`

` * 延遲載入完整資料：`
    - 在進入詳細頁面（`OrderHistoryDetailViewController`）時再向 Firebase 請求完整的訂單資料，包含飲品項目等細節。
 
 `* 處理異步請求：`
    - 詳細頁面會根據傳遞過來的`訂單 ID`，向 Firebase 發送額外的請求來獲取完整資料，這樣雖然引入了額外的網路請求，但能減少 `OrderHistoryViewController` 初次載入的等待時間。

 `3. 資料拆分後的實作與維護`

 `* OrderHistoryViewController 負責展示基本資料：`
   - 在列表中展示訂單 ID、顧客名稱、金額和訂單建立時間等基本信息。
   - 當用戶點擊訂單時，將訂單 ID 傳遞給 `OrderHistoryDetailViewController`。

 `* OrderHistoryDetailViewController` 負責完整資料的呈現：`
   - 根據訂單 ID，進行一次額外的路絡請求來獲取完整資料（包括飲品項目列表）。
   - 添加加載指示器，以處理異步加載，確保用戶在等待完整資料時能獲得良好的體驗。

 `4. 資料拆分的利弊權衡`

 `* 優點：`
   - `減少初次載入的壓力`：將完整訂單資料拆分，列表頁面只加載基本資料，能提升應用程序的載入速度。
   - `提升用戶體驗`：詳細資料在用戶需要時才載入，這樣不會對主列表的載入造成過大負擔。

 `* 可能的複雜性：`
   - `額外的網路請求`：詳細頁面需要額外進行一次資料請求，這需要處理異步邏輯、網路延遲以及錯誤情況。
   - `狀態管理的增加`：需要額外處理異步請求的狀態，例如加載中、請求失敗的錯誤處理等，這會增加一定的代碼複雜度。

 `5. 資料處理方式的常見選擇與考量`

 `* 完整資料提前載入到 OrderHistoryViewController：`
    - 適合資料量較小的情況，例如單筆訂單中飲品數量較少，或每位用戶的歷史訂單數量不多。
    - 這樣可以讓用戶在點擊訂單進入詳細頁面時，獲得更即時的響應，因為已經有了全部的資料，不再需要額外的網絡請求。
    - `優勢`：減少網絡請求和異步邏輯的處理，保持邏輯簡單。
    - `缺點`：如果資料量過大，初次載入時間會較長，影響用戶體驗。

 `* 基本資料載入，詳細資料在 OrderHistoryDetailViewController 延遲請求：`
    - 適合資料量大的應用，例如每筆訂單包含多個飲品，或用戶擁有大量的歷史訂單。
    - 這樣的方式可以減少初次載入的壓力，讓列表頁面的加載更快、更流暢，然後在用戶點擊查看時，才進行額外的資料請求。
    - `優勢`：提升初次載入的性能，適合資料結構較為複雜的應用。
    - `缺點`：需要處理異步請求的狀態管理，例如加載中、網絡錯誤等情況，增加了實現的複雜性。

 `6. 適用情境`

 `* 完整資料載入適合的情況：`
    - 如果訂單的項目數量不多，保留完整資料並直接在 `OrderHistoryViewController` 中展示，這樣詳細頁面可以直接使用傳遞的資料，減少網絡請求和狀態管理的複雜性。

 `* 延遲載入適合的情況：`
    - 如果訂單包含較多飲品項目，或用戶的歷史訂單數量龐大，建議採用延遲載入方式，以確保應用程序性能良好且用戶體驗不受影響。

 `7. 總結`

 - 將 `orderItems` 拆分並延遲到詳細頁面進行載入，能有效減少初次載入的負擔，提高應用的性能。
 - 這樣的做法需要在詳細頁面進行額外的請求並處理狀態管理，複雜度相對增加，但可以更好地優化列表的載入速度。
 - 根據應用情境決定是否拆分資料，如果資料量小可以保持完整性，如果資料量大則採用延遲載入來平衡性能和用戶體驗。

 */


// MARK: - 調整資料（簡化）

import Foundation

/// 歷史訂單，用於從 Firestore 獲取並顯示的訂單資料。
struct OrderHistory: Codable {
    let id: String                                      // 訂單唯一標識符（作為訂單的唯一識別）
    let customerDetails: OrderHistoryCustomerDetails    // 顧客資料（包括姓名、電話、取件方式等資訊）
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
}

/// 用於顯示顧客的取件選擇。
enum OrderHistoryPickupMethod: String, Codable {
    case homeDelivery = "Home Delivery"  // 外送服務
    case inStore = "In-Store Pickup"     // 到店取件
}