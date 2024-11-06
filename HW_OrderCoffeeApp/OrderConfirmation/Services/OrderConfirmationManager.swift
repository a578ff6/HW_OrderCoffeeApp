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

 `* 主要用途和為何需要這樣的設計`

 `1. 集中管理訂單獲取與解碼的邏輯：`
    - 為了確保獲取最新的訂單資料後，能夠正確地進行驗證和轉換，`OrderConfirmationManager` 把這些邏輯集中在一個地方。
    - 這樣設計符合單一職責原則 (`Single Responsibility Principle`)，即每個類別都應只負責某一個功能，減少訂單確認頁面中出現複雜的數據處理邏輯。

 `2. 使用專屬模型進行展示：`
    - 設置一個專屬的 `OrderConfirmation` 模型，用於解碼並展示訂單數據。
    - 因為上傳到 Firebase 的訂單資料不完全需要與應用內的訂單模型一致，有些屬性可能在展示時並不需要顯示，這樣做可以簡化數據結構。
    - 通過建立簡化的專屬模型 (`OrderConfirmation`)，能更方便地直接將 Firebase 返回的數據轉換為 UI 需要的數據結構。

 `* 獲取最近的訂單資料的原因`

 `1. 業務需求：`
    - 通常在訂單確認頁面中，需要展示的是使用者最新提交的訂單資料。因此，通過獲取按時間戳排序的最新訂單可以達到這個目的。
    - `order(by: "timestamp", descending: true)` 是按照訂單創建時間排序，確保最上方的是最新的訂單。
    - `limit(to: 1)` 只取最新的一筆資料，這樣做不僅節省了網絡資源，也減少了數據傳輸量。

 `2. 效能與可讀性：`
    - 透過 `async/await` 的方式進行資料獲取和錯誤處理，代碼直觀且便於維護。比起使用回調的方式，`async/await` 讓代碼更加可讀並且避免回調地獄 (`callback hell`)。

 `* 為何設置專屬的 OrderConfirmation 模型`

 `1. 與 Firebase 數據結構保持對應：`
    - Firebase 中存儲的訂單資料結構和應用內的數據模型不一定完全相同。設置專屬的 `OrderConfirmation` 模型可以專門處理這些從 Firebase 獲取的簡化資料，避免重複和混淆。
    - 在展示資料時，通常只需要一部分屬性，例如顧客姓名、取件方式、訂單項目等。通過設置 `OrderConfirmation` 模型，可以只保留這些必要屬性，減少不需要的數據。

 `2. 減少複雜度與維護成本：`
    - 如果直接使用原有的模型，可能會包含許多在展示頁面不必要的細節信息，這樣會增加代碼的複雜度和維護成本。
    - 專屬模型可以更具針對性地設計，減少冗餘數據，確保所有數據只在需要的上下文中出現。

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


import FirebaseFirestore

/// `OrderConfirmationManager` 類別負責管理與獲取訂單確認相關的操作。
/// - 主要用途：從 Firebase Firestore 中獲取最新的訂單資料並進行解碼，將其轉換為訂單確認頁面可以使用的模型。
/// - 負責解碼並驗證獲取到的數據，確保所有必要欄位都完整有效。
class OrderConfirmationManager {
    
    // MARK: - Fetch Order

    /// 獲取最近提交的訂單，並轉換為 `OrderConfirmation` 模型
    /// - 透過使用者 ID 從 Firestore 中獲取該使用者的最新訂單資料，並進行解碼處理
    func fetchLatestOrder(for userID: String) async throws -> OrderConfirmation {
        let db = Firestore.firestore()
        
        // 從 Firestore 中取得指定使用者的訂單集合，按照時間戳降序排列，只取最新的一筆
        let snapshot = try await db.collection("users").document(userID).collection("orders").order(by: "timestamp", descending: true).limit(to: 1).getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw OrderConfirmationError.missingField("No recent order found")
        }
        
        let data = document.data()
        print("原始數據: \(data)")                                // 從 Firestore 獲取的原始數據
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
        
        // 返回解碼後的訂單項目
        return OrderConfirmationItem(
            name: name,
            subName: subName,
            imageUrl: imageUrl,
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
