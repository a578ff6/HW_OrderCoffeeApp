//
//  OrderConfirmationManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/4.
//

// MARK: - OrderConfirmationManager 設計筆記
/**
 
 ### OrderConfirmationManager 設計筆記

` * 設計目的`

    - `OrderConfirmationManager` 是一個專門用於從 Firebase Firestore 中獲取並解碼最新訂單的類別，並將其轉換為在訂單確認頁面可使用的模型。
    - 這樣的設計可以確保數據獲取、驗證與轉換邏輯集中在一起，使代碼結構清晰且更易於維護。

 ---------
 
 `* 主要用途和為何需要這樣的設計`

 `1. 集中管理訂單獲取與解碼的邏輯：`
 
    - 為了確保獲取最新的訂單資料後，能夠正確地進行驗證和轉換，`OrderConfirmationManager` 把這些邏輯集中在一個地方。
    - 這樣設計符合單一職責原則 (`Single Responsibility Principle`)，即每個類別都應只負責某一個功能，減少訂單確認頁面中出現複雜的數據處理邏輯。

 `2. 使用專屬模型進行展示：`
 
    - 設置一個專屬的 `OrderConfirmation` 模型，用於解碼並展示訂單數據。
    - 因為上傳到 Firebase 的訂單資料不完全需要與應用內的訂單模型一致，有些屬性可能在展示時並不需要顯示，這樣做可以簡化數據結構。
    - 通過建立簡化的專屬模型 (`OrderConfirmation`)，能更方便地直接將 Firebase 返回的數據轉換為 UI 需要的數據結構。

 ---------

 `* 獲取最近的訂單資料的原因`

 `1. 業務需求：`
 
    - 通常在訂單確認頁面中，需要展示的是使用者最新提交的訂單資料。因此，通過獲取按時間戳排序的最新訂單可以達到這個目的。
    - `order(by: "timestamp", descending: true)` 是按照訂單創建時間排序，確保最上方的是最新的訂單。
    - `limit(to: 1)` 只取最新的一筆資料，這樣做不僅節省了網絡資源，也減少了數據傳輸量。

 `2. 效能與可讀性：`
 
    - 透過 `async/await` 的方式進行資料獲取和錯誤處理，代碼直觀且便於維護。比起使用回調的方式，`async/await` 讓代碼更加可讀並且避免回調地獄 (`callback hell`)。

 ---------

 `* 為何設置專屬的 OrderConfirmation 模型`

 `1. 與 Firebase 數據結構保持對應：`
 
    - Firebase 中存儲的訂單資料結構和應用內的數據模型不一定完全相同。設置專屬的 `OrderConfirmation` 模型可以專門處理這些從 Firebase 獲取的簡化資料，避免重複和混淆。
    - 在展示資料時，通常只需要一部分屬性，例如顧客姓名、取件方式、訂單項目等。通過設置 `OrderConfirmation` 模型，可以只保留這些必要屬性，減少不需要的數據。

 `2. 減少複雜度與維護成本：`
 
    - 如果直接使用原有的模型，可能會包含許多在展示頁面不必要的細節信息，這樣會增加代碼的複雜度和維護成本。
    - 專屬模型可以更具針對性地設計，減少冗餘數據，確保所有數據只在需要的上下文中出現。

 ---------

 `### 流程總結`

 `1. 從 Firestore 獲取訂單資料：`
    - `OrderConfirmationManager` 使用 `async/await` 從 Firebase 獲取指定使用者的最新訂單資料。

 `2. 解碼資料並轉換為專屬模型：`
    - 使用 `decodeOrderConfirmation(from:)` 方法來解碼 Firestore 返回的 `[String: Any]` 格式數據，並將其轉換為 `OrderConfirmation` 模型。

 `3. 展示資料：`
    - 在 `OrderConfirmationViewController` 中使用解碼後的 `OrderConfirmation` 對象來展示訂單的詳細信息，例如顧客姓名、取件方式、飲品項目等。

 `4. 錯誤處理：`
    - 設計了專屬的 `OrderConfirmationError` 類型，用於處理必要欄位缺失的情況，以確保數據的完整性和有效性。
 */


// MARK: - Firestore.Decoder 的使用筆記
/**
 
 ### Firestore.Decoder 的使用筆記

 `* What`
 
 - `Firestore.Decoder` 是 Firebase 提供的一個工具，專為解碼 Firestore 資料結構設計。
 - 它讓 Firestore 的資料能直接映射到 Swift 的 `Codable` 模型，並自動處理 Firestore 特殊的數據類型，例如 `Timestamp`。

 -----------

 `* Why`

 1. 簡化解碼邏輯：
 
    - 手動解碼需要逐層檢查每個欄位是否存在，並進行類型轉換，代碼冗長且容易出錯。
    - `Firestore.Decoder` 自動處理解碼過程，只需定義符合 `Codable` 規範的模型，代碼更簡潔。

 2. 解決 Firestore 特殊數據類型的問題：
 
    - Firestore 的 `Timestamp` 需要手動轉換為 `Date`，`Firestore.Decoder` 自動完成這部分工作，減少額外邏輯。

 3. 提升可維護性：
 
    - 模型結構與 Firestore 資料結構保持一致，當資料結構改變時，只需更新模型，而無需重寫解碼邏輯。

 4. 符合 Swift 設計原則：
 
    - 完美整合 `Codable`，符合 iOS 開發的最佳實踐。
    - Firestore 提供的解碼器是專為 Firestore 設計，相較於手動實現，具有更高的準確性與效能。

 -----------

 `* How`

 1. 準備 `Codable` 模型
 
    - 定義與 Firestore 資料結構對應的 Swift 模型，確保字段名稱和資料結構一致。例如：

    ```swift
    struct OrderConfirmation: Codable {
        var id: String
        var customerDetails: OrderConfirmationCustomerDetails
        var orderItems: [OrderConfirmationItem]
        var timestamp: Date
        var totalPrepTime: Int
        var totalAmount: Int
    }
    ```
 
 ----

 2. 使用 `Firestore.Decoder` 解碼
 
    - 從 Firestore 獲取資料後，將資料傳入 `Firestore.Decoder` 進行解碼：

    ```swift
    import Firebase

    class OrderConfirmationManager {
        func fetchLatestOrder() async throws -> OrderConfirmation {
            guard let userID = Auth.auth().currentUser?.uid else {
                throw OrderConfirmationError.missingField("User ID")
            }

            let db = Firestore.firestore()
            let snapshot = try await db.collection("users")
                .document(userID)
                .collection("orders")
                .order(by: "timestamp", descending: true)
                .limit(to: 1)
                .getDocuments()

            guard let document = snapshot.documents.first else {
                throw OrderConfirmationError.missingField("No recent order found")
            }

            // 使用 Firestore.Decoder 進行解碼
            let decoder = Firestore.Decoder()
            return try decoder.decode(OrderConfirmation.self, from: document.data())
        }
    }
    ```

 ----
 
 3. 處理解碼錯誤
 
    - 若資料結構與模型不匹配，解碼會失敗。需添加錯誤處理邏輯以捕捉問題：

    ```swift
    enum OrderConfirmationError: Error, LocalizedError {
        case missingField(String)
        
        var errorDescription: String? {
            switch self {
            case .missingField(let field):
                return "Invalid or missing '\(field)' field."
            }
        }
    }
    ```

 -----------

 `* 總結`

 - What：
   使用 `Firestore.Decoder` 自動將 Firestore 資料解碼為 `Codable` 模型。

 - Why：
   提升代碼簡潔性與可維護性，減少手動解碼的冗長邏輯，並解決 Firestore 特殊數據類型（如 `Timestamp`）的處理問題。

 - How：
   定義符合 Firestore 資料結構的 `Codable` 模型，使用 `Firestore.Decoder` 解碼 Firestore 資料，處理可能的解碼錯誤。
 */


// MARK: - OrderConfirmationManager 筆記
/**
 
 ## OrderConfirmationManager 筆記

 - 原本使用手動解碼的方式，但是過於繁瑣，因此採用 Firestore.Decoder 處理。
 
 `* What`

 - `OrderConfirmationManager` 是一個專門與 Firebase Firestore 交互的類別，負責從數據庫中獲取最新訂單並解碼成應用可用的 Swift 模型。其主要功能包括：

 1. 獲取最新訂單：透過用戶 ID 查詢 Firestore，抓取用戶最近提交的訂單。
 2. 數據解碼：使用 `Firestore.Decoder` 自動處理 Firestore 特殊數據類型（如 `Timestamp`）並轉換為 Swift 模型。
 3. 錯誤處理：定義錯誤類型，提供針對缺少數據或解碼失敗的友善提示。

 ---------

 `* Why`

 1. 數據流整合：將 Firebase 的數據與應用邏輯結合，為訂單確認功能提供可靠的數據支持。
 2. 簡化解碼邏輯：通過 `Firestore.Decoder` 減少手動處理數據的複雜性，提升程式碼的可讀性與可維護性。
 3. 友善的錯誤處理：在數據不完整或模型解碼失敗時，提供清晰的錯誤描述，方便調試與用戶提示。

 ---------

 `* How`

 1. 流程概述：
 
    - Step 1：調用 `fetchLatestOrder` 方法，先驗證當前用戶是否已登入，並抓取該用戶的最近訂單。
    - Step 2：使用 Firestore 查詢 API，按照時間戳降序排列，只抓取最新一筆訂單。
    - Step 3：調用 `decodeOrderConfirmation` 方法，使用 `Firestore.Decoder` 將 Firestore 返回的數據解碼為 `OrderConfirmation` 模型。

 2. 關鍵方法解析：
 
    - `fetchLatestOrder`：
      - 驗證用戶 ID（`Auth.auth().currentUser?.uid`）。
      - 使用 Firestore 查詢訂單集合，按 `timestamp` 排序並限制只取一筆資料。
      - 檢查是否有數據，否則拋出錯誤。
 
    - `decodeOrderConfirmation`：
      - 使用 `Firestore.Decoder` 自動解碼 Firestore 返回的數據。
      - 支援 Firestore 的特殊類型（如 `Timestamp`）轉換為 Swift 的 `Date`。

 3. 錯誤處理：
 
    - 定義 `OrderConfirmationError`：
      - `missingField`：用於提示缺少必要欄位，如用戶 ID 或訂單數據。
      - 提供本地化的錯誤描述，方便用戶界面或開發者理解問題。

 ---------

 `* 優點`

 1. 優點：
 
    - 使用 `Firestore.Decoder` 減少手動處理數據的重複邏輯。
    - 清晰的錯誤處理機制，提升用戶體驗與開發效率。
    - 提供模組化設計，便於測試與擴展。

 ---------

 `* 範例程式碼（測試與使用）`

 ```swift
 let manager = OrderConfirmationManager()

 Task {
     do {
         let latestOrder = try await manager.fetchLatestOrder()
         print("最近訂單：\(latestOrder)")
     } catch {
         print("抓取訂單失敗：\(error.localizedDescription)")
     }
 }
 ```

 這樣的結構能讓 `OrderConfirmationManager` 成為訂單相關功能中的核心模組，保持清晰與高效的設計。
 */


// MARK: - Firestore.Decoder

import Firebase

/// OrderConfirmationManager
///
/// 此類別負責與 Firebase Firestore 進行交互，並解碼訂單數據為可用於應用邏輯的 Swift 模型。
///
/// 主要功能：
/// 1. 獲取指定用戶的最近提交訂單，並轉換為 `OrderConfirmation` 模型。
/// 2. 使用 `Firestore.Decoder` 自動處理 Firestore 特殊數據類型（如 `Timestamp`）。
/// 3. 定義與處理可能的錯誤情境，提供更友善的錯誤提示。
class OrderConfirmationManager {
    
    // MARK: - Fetch Order
    
    /// 獲取最近提交的訂單
    ///
    /// 此方法從 Firestore 中抓取當前用戶的最新訂單，並將其轉換為 `OrderConfirmation` 模型。
    ///
    /// - Throws:
    ///   - `OrderConfirmationError.missingField`：當未能取得 `userID` 或最近訂單時拋出此錯誤。
    ///   - 解碼錯誤：當 Firestore 的數據格式與模型不匹配時，`decodeOrderConfirmation` 方法會拋出錯誤。
    ///
    /// - Returns: 已解碼的 `OrderConfirmation` 模型。
    func fetchLatestOrder() async throws -> OrderConfirmation {
        
        // 驗證並取得目前使用者的 userID
        guard let userID = Auth.auth().currentUser?.uid else {
            throw OrderConfirmationError.missingField("User ID")
        }
        
        // 從 Firestore 中抓取該用戶的最近訂單（按時間戳降序排列，只抓取一筆）
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users")
            .document(userID)
            .collection("orders")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments()
        
        // 確保有找到訂單資料，否則拋出錯誤
        guard let document = snapshot.documents.first else {
            throw OrderConfirmationError.missingField("No recent order found")
        }
        
        // 使用 FirestoreDecoder 解碼訂單數據
        return try decodeOrderConfirmation(from: document)
    }
    
    // MARK: - Decode Order Data
    
    /// 使用 `FirestoreDecoder` 解碼 Firestore 訂單數據
    ///
    /// 此方法利用 Firebase 提供的 `Firestore.Decoder` 工具，將 Firestore 的數據轉換為符合 `Codable` 的 Swift 模型。
    ///
    /// - Parameter document: Firestore 中的訂單數據文件。
    /// - Throws: 當數據結構與 `OrderConfirmation` 不匹配時，會拋出解碼錯誤。
    /// - Returns: 已解碼的 `OrderConfirmation` 模型。
    private func decodeOrderConfirmation(from document: QueryDocumentSnapshot) throws -> OrderConfirmation {
        let decoder = Firestore.Decoder()
        return try decoder.decode(OrderConfirmation.self, from: document.data())
    }
    
    // MARK: - Error Handling
    
    /// 訂單確認相關錯誤類型
    ///
    /// 定義可能遇到的錯誤，便於捕捉與顯示詳細錯誤訊息。
    enum OrderConfirmationError: Error, LocalizedError {
        
        /// 缺少必要欄位
        case missingField(String)
        
        /// 錯誤描述
        var errorDescription: String? {
            switch self {
            case .missingField(let field):
                return "Invalid or missing '\(field)' field."
            }
        }
    }
    
}




// MARK: - 手動處理

/*
import Firebase

/// `OrderConfirmationManager` 類別負責管理與獲取訂單確認相關的操作。
/// - 主要用途：從 Firebase Firestore 中獲取最新的訂單資料並進行解碼，將其轉換為訂單確認頁面可以使用的模型。
/// - 負責解碼並驗證獲取到的數據，確保所有必要欄位都完整有效。
class OrderConfirmationManager {
    
    // MARK: - Fetch Order

    /// 獲取最近提交的訂單，並轉換為 `OrderConfirmation` 模型
    ///
    /// - 透過使用者 ID 從 Firestore 中獲取該使用者的最新訂單資料，並進行解碼處理
    func fetchLatestOrder() async throws -> OrderConfirmation {
        
        // 檢查並獲取 userID
        guard let userID = Auth.auth().currentUser?.uid else {
            throw OrderConfirmationError.missingField("User ID")
        }
        
        // 從 Firestore 中取得指定使用者的訂單集合，按照時間戳降序排列，只取最新的一筆
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").document(userID).collection("orders").order(by: "timestamp", descending: true).limit(to: 1).getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw OrderConfirmationError.missingField("No recent order found")
        }
        
        let data = document.data()
        print("[OrderConfirmationManager]: 原始數據: \(data)")                                // 從 Firestore 獲取的原始數據
        return try decodeOrderConfirmation(from: data)
    }

    // MARK: - Decode Order Data

    /// 將 Firestore 訂單數據轉換為 `OrderConfirmation` 模型
    /// - 使用解碼邏輯將 Firestore 中的訂單字典轉換為 `OrderConfirmation` 結構
    private func decodeOrderConfirmation(from data: [String: Any]) throws -> OrderConfirmation {
        guard let id = data["id"] as? String,
              let customerDetailsData = data["customerDetails"] as? [String: Any],
              let orderItemsData = data["orderItems"] as? [[String: Any]],
              let timestamp = data["timestamp"] as? Timestamp,
              let totalPrepTime = data["totalPrepTime"] as? Int,
              let totalAmount = data["totalAmount"] as? Int
        else {
            throw OrderConfirmationError.missingField("Order fields")
        }
        
        // 解碼顧客詳細資料和訂單項目資料
        let customerDetails = try decodeOrderConfirmationCustomerDetails(from: customerDetailsData)
        let orderItems = try orderItemsData.map { try decodeOrderConfirmationItem(from: $0) }
        let timestampDate = timestamp.dateValue()
        
        // 返回解碼後的 `OrderConfirmation` 結構
        return OrderConfirmation(
            id: id,
            customerDetails: customerDetails,
            orderItems: orderItems,
            timestamp: timestampDate,
            totalPrepTime: totalPrepTime,
            totalAmount: totalAmount
        )
    }
    
    // MARK: - Decode Customer Details

    /// 將 Firestore 的 customerDetails 字段數據轉換為 `OrderConfirmationCustomerDetails` 模型
    /// - 將顧客的詳細資料轉換為顧客模型以便顯示在訂單確認畫面
    private func decodeOrderConfirmationCustomerDetails(from data: [String: Any]) throws -> OrderConfirmationCustomerDetails {
        guard let fullName = data["fullName"] as? String,
              let phoneNumber = data["phoneNumber"] as? String,
              let pickupMethodString = data["pickupMethod"] as? String,
              let pickupMethod = OrderConfirmationPickupMethod(rawValue: pickupMethodString)
        else {
            throw OrderConfirmationError.missingField("Customer Details fields")
        }
        
        // 可選欄位的處理
        let address = data["address"] as? String
        let storeName = data["storeName"] as? String
        let notes = data["notes"] as? String
        
        // 返回解碼後的顧客詳細資料
        return OrderConfirmationCustomerDetails(
            fullName: fullName,
            phoneNumber: phoneNumber,
            pickupMethod: pickupMethod,
            address: address,
            storeName: storeName,
            notes: notes
        )
    }
    
    // MARK: - Decode Order Item

    /// 將 Firestore 的 orderItem 字段數據轉換為 `OrderConfirmationItem` 模型
    /// - 將單個訂單項目資料轉換為可在訂單確認畫面使用的訂單項目模型
    private func decodeOrderConfirmationItem(from data: [String: Any]) throws -> OrderConfirmationItem {
        guard let drinkData = data["drink"] as? [String: Any],
              let name = drinkData["name"] as? String,
              let subName = drinkData["subName"] as? String,
              let imageUrlString = drinkData["imageUrl"] as? String,
              let imageUrl = URL(string: imageUrlString),
              let size = data["size"] as? String,
              let quantity = data["quantity"] as? Int,
              let price = data["price"] as? Int
        else {
            throw OrderConfirmationError.missingField("Order Item fields")
        }
        
        // 解析飲品資料
        let drink = OrderConfirmationItem.Drink(name: name, subName: subName, imageUrl: imageUrl)
        
        // 返回解碼後的訂單項目
        return OrderConfirmationItem(
            drink: drink,
            size: size,
            quantity: quantity,
            price: price
        )
    }
    
    // MARK: - Error Handling

    /// 訂單確認錯誤類型
    /// - 用於處理缺少必要欄位的情況
    enum OrderConfirmationError: Error, LocalizedError {
        case missingField(String)
        
        var errorDescription: String? {
            switch self {
            case .missingField(let field):
                return "Invalid or missing '\(field)' field."
            }
        }
    }
    
}
*/
