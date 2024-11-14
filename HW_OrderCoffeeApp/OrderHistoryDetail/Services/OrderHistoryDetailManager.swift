//
//  OrderHistoryDetailManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

// MARK: -  OrderHistoryDetailManager 重點筆記
/**
 ## OrderHistoryDetailManager 重點筆記
 
 `* OrderHistoryDetailManager 概述`

 - `功能描述`：
    - `OrderHistoryDetailManager` 是負責從 `Firebase` 的 Firestore 獲取並管理指定訂單詳細資料的管理器類別。
    - 透過此管理器可以根據使用者的 ID 和訂單 ID 獲取詳細的訂單資訊，適合在訂單詳細頁面中使用。
 
 - `資料驅動方式`：
    - 利用 Firebase 提供的` getDocument(as:) `方法來獲取並解析訂單資料，省去手動解析 JSON 格式的繁瑣步驟，確保資料獲取的準確性與便利性。

 `* 功能與方法詳解`

 `1. Properties：`

 * `db`：Firestore 的連結，負責與後端資料庫溝通，用於進行資料的讀寫操作。
 
 `2. Methods：`

 * `fetchOrderDetail(for userId: String, orderId: String) async throws -> OrderHistoryDetail`
 
    - `功能描述`：
        - 根據傳入的使用者 ID (userId) 及訂單 ID (orderId)，從 Firestore 獲取並返回對應的 OrderHistoryDetail。
 
    - `參數`：
        - userId：當前使用者的唯一標識符，用於在 Firebase 中定位使用者訂單資料。
        - orderId：特定訂單的唯一標識符。
        - 返回：回傳指定訂單 ID 的 OrderHistoryDetail 資料結構，包含訂單的所有詳細資訊。
 
 `3. 使用情境`

 - 該管理器在 `OrderHistoryDetailViewController` 中被調用，以便根據傳遞過來的 `orderId` 獲取完整的訂單詳細資料。
 - 使用 `Firebase` 的異步 getDocument(as:) 方法能夠直接將資料映射為 `OrderHistoryDetail` 的模型，這樣使得資料的獲取和解碼變得簡潔明了。
 
 `4. 優勢與考量`

 - `資料完整性`：由於詳細資料涉及訂單的項目、顧客信息等，將這部分的資料獲取從 `OrderHistoryViewController` 中分離，有助於保持訂單概覽和詳細資料之間的區分，使代碼更易維護。
 - `異步處理`：使用 `async/await` 確保獲取資料的過程是異步的，避免在主線程中進行阻塞操作，從而提升用戶體驗。
 - `用戶驗證`：在獲取訂單資料之前，應先檢查當前是否有登入的使用者（即 `currentUser` 是否有效），確保只有在用戶有效時才能進行數據請求，這是應用安全性的一部分。
 */


// MARK: - 使用 Firebase 提供的 getDocument(as:) 方法的重點筆記（額外補充想法）
/**
 ## 使用 Firebase 提供的 getDocument(as:) 方法的重點筆記
 
 `1. Firebase 簡化資料解析`

 - 使用 Firebase 提供的` getDocument(as:)` 方法，可以直接將 `Firestore` 中的文件解析為 Swift 中的型別 (`OrderHistoryDetail`)。
 - 此方法利用 `Codable` 協定來進行資料的自動解析，這意味著只要對應的資料模型符合 `Codable`，就能方便地從 `Firebase` 中獲取並轉換成相應的類型。
 
 `2. 省去手動 JSON 轉換`

 - 相比於使用 `JSONSerialization` 進行資料解析，`getDocument(as:) `方法不需要手動將 Firebase 的原始資料進行 JSON 格式的轉換，也省去了可能的錯誤處理流程。
 - 減少了編碼過程中的樣板代碼和重複性操作，使得代碼更加簡潔和易於維護。
 
 `3. 自動錯誤管理`

 - 在使用` getDocument(as:) `方法時，任何解析失敗的情況會自動產生錯誤，方便捕捉和處理，例如轉型失敗或資料缺失。
 - 這樣的錯誤處理機制能幫助開發者更有效率地管理錯誤並改善使用者體驗。
 */


// MARK: - 使用單例 (Singleton) vs. 獨立實例的選擇（額外補充想法）
/**
 ## 使用單例 (Singleton) vs. 獨立實例的選擇

 * 當需要創建一個管理器類別 (例如 `OrderHistoryDetailManager`) 時，可能會面臨選擇：是否應使用單例模式 (`shared`) 還是每次創建一個獨立的實例 (`private let detailManager = OrderHistoryDetailManager()`)。以下是這兩種方式的對比和選擇指南。

 1`. 在 OrderHistoryDetailManager 設置 shared 實例 (Singleton)`

 - `用法`：使用靜態共享實例，這樣可以讓管理器在應用的不同部分共用同一個實例。
   
   ```swift
   class OrderHistoryDetailManager {
       static let shared = OrderHistoryDetailManager()
       
       private init() {} // 確保外部無法直接初始化這個類
       ...
   }
   ```

` - 優點：`
   - 確保只會有一個 `OrderHistoryDetailManager` 實例存在，並且應用的不同部分都可以共用這個單例實例。
   - 適合用於狀態保持的情境，例如管理整個應用的配置、緩存、或是持續共享的狀態。

 `- 缺點：`
   - 單例實例的生命周期是全局的，在應用運行期間都會存在。如果對內存管理或某些功能的獨立性有要求，單例可能會不太合適。
   - 當使用單例的時候，需要特別小心狀態管理，尤其是確保不會有多個不同的視圖控制器或場景同時修改它的狀態，導致數據不一致。

 `2. 在 OrderHistoryDetailViewController 中設置獨立的實例`

 - `用法`： 在 `OrderHistoryDetailViewController` 中使用局部變數來創建新的管理器實例。

   ```swift
   private let detailManager = OrderHistoryDetailManager()
   ```

 `- 優點：`
   - 確保每個 `OrderHistoryDetailViewController` 的管理器實例是獨立的，不會影響其他的視圖控制器。
   - 適合用於只在某一個視圖或功能中使用管理器的情況，並且需要避免共享狀態帶來的問題。

 `- 缺點：`
   - 每次創建新的實例，可能會有一些性能開銷，尤其是在管理器的初始化或資源消耗較多的情況下。
   - 無法在應用的不同部分之間共享同一個管理器的狀態。

 `3. 何時使用單例 (shared) vs. 獨立實例？`

 `- 適合使用 shared（單例） 的情況：`
   - 管理器需要在應用程序的不同部分被共用，例如管理某些全局狀態、緩存、或是管理和監控某些資源的情況。
   - 例如，`AuthManager.shared` 可以用於管理登錄狀態，`DatabaseManager.shared` 可以用於統一管理數據庫的讀寫操作。

 `- 適合使用獨立實例的情況：`
   - 管理器的用途是特定的，只用於某些特定的場景或視圖控制器，且需要避免狀態共享帶來的問題。
   - 例如，只需要在 `OrderHistoryDetailViewController` 中獨立使用管理器，不需要與其他地方共用任何狀態。

 `4. 總結`

 - 如果只在 `OrderHistoryDetailViewController` 使用 `OrderHistoryDetailManager`，且不需要其他地方共享這個管理器的狀態，使用局部的實例會更簡單且避免不必要的共享。
 - 如果管理器的狀態需要在應用的多個部分之間共享，例如用於全局的資料管理或緩存，那麼使用 `shared` 單例是一個好選擇。
 */


import UIKit
import Firebase

/// `OrderHistoryDetailManager` 負責從 Firestore 中獲取並管理訂單的詳細資料。
/// - 功能：提供異步的方法來根據 `userId` 和 `orderId` 獲取特定訂單的完整詳細資訊。
class OrderHistoryDetailManager {
    
    /// 初始化 Firestore 資料庫連結
    private let db = Firestore.firestore()
    
    /// 獲取訂單的詳細資料
    /// - Parameters:
    ///   - userId: 使用者的唯一標識符，用於定位使用者資料庫中訂單的父層
    ///   - orderId: 訂單的唯一標識符，用於獲取特定訂單的詳細資訊
    /// - Returns: 回傳指定 `orderId` 的 `OrderHistoryDetail` 資料結構
    /// - 說明：使用 Firebase 的 `getDocument(as:)` 方法來進行資料解析，從而簡化從 Firebase 獲取並解析成特定資料模型的過程。
    func fetchOrderDetail(for userId: String, orderId: String) async throws -> OrderHistoryDetail {
        let documentRef = db.collection("users").document(userId).collection("orders").document(orderId)

        do {
            let orderDetail = try await documentRef.getDocument(as: OrderHistoryDetail.self)
            return orderDetail
        } catch {
            throw NSError(domain: "OrderDetailError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch or decode order detail for order ID \(orderId): \(error.localizedDescription)"])
        }
    }
    
}
