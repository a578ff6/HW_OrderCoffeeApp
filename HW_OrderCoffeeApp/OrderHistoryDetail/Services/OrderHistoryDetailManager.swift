//
//  OrderHistoryDetailManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

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


// MARK: - OrderHistoryDetailManager 筆記
/**
 
 ## OrderHistoryDetailManager 筆記

 `* What`
 
 - `OrderHistoryDetailManager` 是一個負責從 Firebase Firestore 獲取歷史訂單詳細資料的管理類別。

 - 主要職責:
 
   - 根據當前用戶的 `userId` 和指定的 `orderId`，從 Firestore 中檢索訂單詳細資料。
   - 將 Firestore 返回的原始數據轉換為 `OrderHistoryDetail` 模型。
   - 提供異步數據獲取方法，支援在 UI 或邏輯層中使用。

 ----------

 `* Why`
 
 1. 模組化設計:
 
    - 將數據檢索邏輯集中在一個專門的類中，避免在控制器或其他模組中重複實現數據獲取邏輯。
    - 增強代碼的可讀性、可測試性和易於維護性。

 2. 單一職責原則 (SRP):
 
    - 使該類僅專注於 Firestore 數據的檢索與轉換，不涉及其他業務邏輯或 UI 更新，確保類的職責單一且清晰。

 3. 提高可重用性:
 
    - 其他模組也可以直接使用該類來獲取訂單數據，無需了解 Firestore 的具體實現細節。

 4. 減少錯誤風險:
 
    - 集中處理用戶驗證（`Auth`）和數據解析的邏輯，減少因數據不一致或驗證錯誤導致的問題。

 ----------

 `* How`
 
 1. 初始化 Firestore 實例:
 
    - 使用 `Firestore.firestore()` 建立與 Firebase 的數據庫連接，確保數據檢索的基本設置。

 2. 提供異步數據檢索方法:
 
    - 使用 `async/await` 結合 Firestore 的 `getDocument(as:)` 方法，實現高效且簡潔的數據檢索與轉換。

 3. 方法實現細節:
 
    - 檢查當前用戶是否登錄:
      - 使用 `Auth.auth().currentUser?.uid` 確保用戶已登錄並獲取 `userId`。
      - 如果用戶未登錄，拋出自定義錯誤 `AuthError`。
 
    - 定位指定文檔:
      - 根據 `userId` 和 `orderId` 構造 Firestore 的文檔路徑。
 
    - 解析數據:
      - 使用 Firestore 的 `getDocument(as:)` 方法自動將數據轉換為 `OrderHistoryDetail` 模型。
 
    - 錯誤處理:
      - 捕獲 Firestore 的數據檢索錯誤，並提供詳細的錯誤描述以便於調試。

 4. 錯誤處理與拋出:
 
    - 當用戶未登錄時：
      - 拋出 `NSError`，描述用戶認證失敗。
 
    - 當數據檢索或解析失敗時：
      - 拋出 `NSError`，描述數據檢索或解析的具體錯誤原因。
 
 */




// MARK: - (v)

import UIKit
import Firebase

/// `OrderHistoryDetailManager`
///
/// 此類負責從 Firestore 中獲取並管理歷史訂單的詳細資料。
///
/// - 設計目標:
///   - 單一職責原則 (SRP)：專注於訂單數據的獲取與解析，不涉及 UI 或其他邏輯。
///   - 模組化設計：通過 Firebase 提供異步方法以簡化數據交互，保持代碼清晰且易於擴展。
///
/// - 功能:
///   1. 提供基於 `userId` 和 `orderId` 的訂單詳細資料獲取功能，藉此取特定訂單的完整詳細資訊。
///   2. 使用 Firebase 的 `getDocument(as:)` 方法自動將 Firestore 數據解析為指定模型類型 (`OrderHistoryDetail`)。
///   3. 確保只有當前已登錄的用戶才能獲取其對應的訂單詳細資料。
class OrderHistoryDetailManager {
    
    // MARK: - Properties
    
    /// Firestore 資料庫實例，用於與 Firebase 進行數據交互
    private let db = Firestore.firestore()
    
    // MARK: - Public Methods
    
    /// 獲取訂單的詳細資料
    ///
    /// 此方法會檢查當前用戶是否已登錄，並嘗試從 Firestore 中獲取指定 `orderId` 的訂單資料。
    ///
    /// - Parameters:
    ///   - orderId: 訂單的唯一標識符，用於定位 Firestore 中的訂單文檔。
    ///
    /// - Returns: 返回對應 `orderId` 的 `OrderHistoryDetail` 資料結構。
    ///
    /// - Throws:
    ///   - 如果當前用戶未登錄，拋出 `AuthError`。
    ///   - 如果訂單資料獲取失敗或解析失敗，拋出 `OrderDetailError`。
    ///
    /// - 使用場景:
    ///   1. 用於歷史訂單詳情頁的數據初始化。
    ///   2. 提供數據給其他模塊進行處理或展示。
    ///
    /// - 實現細節:
    ///   - 使用 `Auth.auth().currentUser` 確保當前用戶已登錄並提取其 `uid`。
    ///   - 通過 Firestore 的 `getDocument(as:)` 方法自動將文檔轉換為 `OrderHistoryDetail` 模型。
    ///   - 捕獲錯誤並提供詳細的錯誤描述以便調試。
    func fetchOrderDetail(for orderId: String) async throws -> OrderHistoryDetail {
        
        // 確保當前用戶已登錄並提取用戶 ID
        guard let userID = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "AuthError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User is not logged in."]
            )
        }
        
        // 定位指定用戶的訂單文檔
        let documentRef = db.collection("users").document(userID).collection("orders").document(orderId)
        
        do {
            let orderDetail = try await documentRef.getDocument(as: OrderHistoryDetail.self)
            return orderDetail
        } catch {
            throw NSError(
                domain: "OrderDetailError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch or decode order detail: \(error.localizedDescription)"]
            )
        }
    }
    
}
