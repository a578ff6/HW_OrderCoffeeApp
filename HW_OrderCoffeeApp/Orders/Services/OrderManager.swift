//
//  OrderManagerError.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/1.
//

/*
 思考重點：
    A. 在 /orders 集合中存取訂單：
        - orders 集合中的每個文件檔案代表一個訂單，包含 uid 來表示該訂單屬於哪個客戶。
        - 優點：
            - 方便店家全面去查看、處理所有訂單。
            - 更容易進行全局訂單分析和統計。
        - 缺點：
            - 需要額外的邏輯來根據用戶ID查詢特定用戶的訂單。
 
    B. 在每個客戶的子集合中取取訂單：
        - users 集合中的每個用戶有一個 orders 子集合，訂單存取在這個子集合中。
        - 優點：
            - 用戶可以方便查看和管理自己的訂單。
            - 資料結構夠符合用戶的使用邏輯。
        - 缺點：
            - 店家全局查看和處理所有訂單時，需要遍歷每個用戶的子集合，查詢較複雜。
 
    C. 綜合考量：
        - 同時將訂單存取在 /orders 集合中，以及用戶的子集合中。
 
 
 --------------------------------------------------------------------------
 
 
 1. 在資料庫中設置訂單結構：
        - 將訂單資料存取在用戶的訂單集合中，方便管理查詢。

 2. 提交訂單資訊：
        - 在用戶提交訂單時，將訂單資訊提交到 Firebase，並設置本地通知。
 
 3. 設置本地通知：
        - 再訂單提交成功後，根據準備時間設置本地通知，提醒用戶訂單準備完成。
 
 藉由上述方式，確保每個訂單都與特定用戶關聯到，並在訂單準備完成後通知用戶。
 
 --------------------------------------------------------------------------

 
 */


// MARK: 新版（將所有訂單操作（添加、更新、移除等）集中在 OrderController 中管理）UUID
/*
 import Foundation
 import FirebaseFirestore
 import FirebaseAuth
 import UserNotifications


 /// OrderController  處理當前的訂單
 class OrderController {
     
     static let shared = OrderController()
     
     /// 存取當前訂單項目的 Array
     var orderItems: [OrderItem] = [] {
         didSet {
             NotificationCenter.default.post(name: .orderUpdated, object: nil)    // 每當訂單項目變化時發送通知
         }
     }
     
     /// 添加訂單項目
     func addOrderItem(drink: Drink, size: String, quantity: Int) {
         
         guard let user = Auth.auth().currentUser else {
             print("User not logged in")
             return
         }
         print("Adding item to cart for user: \(user.uid)")

         let prepTime = drink.prepTime   // 使用飲品的準備時間（分鐘）
         let timestamp = Date()      // 當前時間
         let price = drink.sizes[size]?.price ?? 0
         let totalAmount = price * quantity
         let orderItem = OrderItem(drink: drink, size: size, quantity: quantity, prepTime: prepTime, timestamp: timestamp, totalAmount: totalAmount, price: price)
         orderItems.append(orderItem)
         print("添加\(orderItem.id)")
     }
     
     /// 更新訂單中的訂單項目的尺寸和數量
     func updateOrderItem(withID id: UUID, with size: String, and quantity: Int) {
         guard let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
         let drink = orderItems[index].drink
         let price = drink.sizes[size]?.price ?? 0
         let totalAmount = price * quantity
         
         orderItems[index].size = size
         orderItems[index].quantity = quantity
         orderItems[index].price = price
         orderItems[index].totalAmount = totalAmount
     }
     
     /// 清空訂單
     func clearOrder() {
         orderItems.removeAll()
     }
     
     /// 刪除訂單飲品項目
     func removeOrderItem(withID id: UUID) {
         orderItems.removeAll { $0.id == id }
     }
     
     /// 提交訂單請求
     func submitOrder(forMenuIDs menuIDs: [Int], completion: @escaping (Result<Void, OrderControllerError>) -> Void) {
         guard let user = Auth.auth().currentUser else {
             completion(.failure(.orderRequestFailed))
             return
         }
         
         let db = Firestore.firestore()
         let orderData: [String: Any] = [
             "uid": user.uid,
             "orderItems": orderItems.map { item in
                 return [
                     "drink": [
                         "name": item.drink.name,
                         "subName": item.drink.subName,
                         "description": item.drink.description,
                         "imageUrl": item.drink.imageUrl.absoluteString,
                         "prepTime": item.drink.prepTime
                     ],
                     "size": item.size,
                     "quantity": item.quantity,
                     "prepTime": item.prepTime,
                     "timestamp": item.timestamp,
                     "totalAmount": item.totalAmount
                 ]
             },
             "timestamp": Timestamp(date: Date())
         ]
         
         // 在用戶子集合中添加訂單
         db.collection("users").document(user.uid).collection("orders").addDocument(data: orderData) { error in
             if let error = error {
                 completion(.failure(.form(error)))
             } else {
                 // 在全局 orders 集合中添加訂單
                 db.collection("orders").addDocument(data: orderData) { error in
                     if let error = error {
                         completion(.failure(.form(error)))
                     } else {
                         self.scheduleNotification(prepTime: self.calculateTotalPrepTime() * 60) // 轉換為秒
                         completion(.success(()))
                     }
                 }
             }
         }
     
     }
     
     /// 計算每杯飲品的準備時間
     func calculateTotalPrepTime() -> Int {
         return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
     }
     
     /// 計算總金額
     func calculateTotalAmount() -> Int {
         return orderItems.reduce(0) { $0 + $1.totalAmount }
     }
     
     /// 安排本地通知提醒用户訂單已經準備好
     /// - Parameter prepTime: 訂單準備時間
     private func scheduleNotification(prepTime: Int) {
         let content = UNMutableNotificationContent()
         content.title = "Order Ready"
         content.body = "Your order is ready for pickup!"
         content.sound = UNNotificationSound.default
         
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prepTime), repeats: false)
         let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
         
         UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
     }
  
     
 }


 // MARK: - NotificationName
 extension Notification.Name {
     static let orderUpdated = Notification.Name("OrderController.orderUpdated")
 }



 // MARK: - Error
 /// 處理Order訂單錯誤相關訊息
 enum OrderControllerError: Error, LocalizedError {
     case orderRequestFailed
     case unknownError
     case firebaseError(Error)
     
     static func form(_ error: Error) -> OrderControllerError {
         return .firebaseError(error)
     }
     
     var errorDescription: String? {
         switch self {
         case .orderRequestFailed:
             return NSLocalizedString("Order request failed.", comment: "Order request failed.")
         case .unknownError:
             return NSLocalizedString("An unknown error occurred.", comment: "An unknown error occurred.")
         case .firebaseError(let error):
             return error.localizedDescription
         }
     }
 }

 */



// MARK: - 測試用
/*
import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications


/// OrderController  處理當前的訂單
class OrderController {
    
    static let shared = OrderController()
    
    /// 存取當前訂單項目的 Array
    var orderItems: [OrderItem] = [] {
        didSet {
            print("訂單項目更新，當前訂單數量: \(orderItems.count)")
            NotificationCenter.default.post(name: .orderUpdatedNotification, object: nil)    // 每當訂單項目變化時發送通知
        }
    }
    
    /// 添加訂單項目
    func addOrderItem(drink: Drink, size: String, quantity: Int, categoryId: String?, subcategoryId: String?) {
        
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        print("Adding item to cart for user: \(user.uid)")

        let prepTime = drink.prepTime   // 使用飲品的準備時間（分鐘）
        let timestamp = Date()      // 當前時間
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        let orderItem = OrderItem(drink: drink, size: size, quantity: quantity, prepTime: prepTime, timestamp: timestamp, totalAmount: totalAmount, price: price, categoryId: categoryId, subcategoryId: subcategoryId)
        orderItems.append(orderItem)
        print("添加訂單項目 ID: \(orderItem.id)")
    }
    
    /// 更新訂單中的訂單項目的尺寸和數量
    func updateOrderItem(withID id: UUID, with size: String, and quantity: Int) {
        guard let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let drink = orderItems[index].drink
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        
        orderItems[index].size = size
        orderItems[index].quantity = quantity
        orderItems[index].price = price
        orderItems[index].totalAmount = totalAmount
    }
    
    /// 清空訂單
    func clearOrder() {
        orderItems.removeAll()
    }
    
    /// 刪除訂單飲品項目
    func removeOrderItem(withID id: UUID) {
        orderItems.removeAll { $0.id == id }
    }
    
    /// 提交訂單請求
    func submitOrder(forMenuIDs menuIDs: [Int], completion: @escaping (Result<Void, OrderControllerError>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(.orderRequestFailed))
            return
        }
        
        let db = Firestore.firestore()
        let orderData: [String: Any] = [
            "uid": user.uid,
            "orderItems": orderItems.map { item in
                return [
                    "drink": [
                        "name": item.drink.name,
                        "subName": item.drink.subName,
                        "description": item.drink.description,
                        "imageUrl": item.drink.imageUrl.absoluteString,
                        "prepTime": item.drink.prepTime
                    ],
                    "size": item.size,
                    "quantity": item.quantity,
                    "prepTime": item.prepTime,
                    "timestamp": item.timestamp,
                    "totalAmount": item.totalAmount
                ]
            },
            "timestamp": Timestamp(date: Date())
        ]
        
        // 在用戶子集合中添加訂單
        db.collection("users").document(user.uid).collection("orders").addDocument(data: orderData) { error in
            if let error = error {
                completion(.failure(.form(error)))
            } else {
                // 在全局 orders 集合中添加訂單
                db.collection("orders").addDocument(data: orderData) { error in
                    if let error = error {
                        completion(.failure(.form(error)))
                    } else {
                        self.scheduleNotification(prepTime: self.calculateTotalPrepTime() * 60) // 轉換為秒
                        completion(.success(()))
                    }
                }
            }
        }
    
    }
    
    /// 計算每杯飲品的準備時間
    func calculateTotalPrepTime() -> Int {
        return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
    }
    
    /// 計算總金額
    func calculateTotalAmount() -> Int {
        return orderItems.reduce(0) { $0 + $1.totalAmount }
    }
    
    /// 安排本地通知提醒用户訂單已經準備好
    /// - Parameter prepTime: 訂單準備時間
    private func scheduleNotification(prepTime: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Order Ready"
        content.body = "Your order is ready for pickup!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prepTime), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
 
    
}


// MARK: - NotificationName
extension Notification.Name {
    static let orderUpdatedNotification = Notification.Name("OrderController.orderUpdated")
}



// MARK: - Error
/// 處理Order訂單錯誤相關訊息
enum OrderControllerError: Error, LocalizedError {
    case orderRequestFailed
    case unknownError
    case firebaseError(Error)
    
    static func form(_ error: Error) -> OrderControllerError {
        return .firebaseError(error)
    }
    
    var errorDescription: String? {
        switch self {
        case .orderRequestFailed:
            return NSLocalizedString("Order request failed.", comment: "Order request failed.")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "An unknown error occurred.")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}
*/


// MARK: - 新版（將所有訂單操作（添加、更新、移除等）集中在 OrderController 中管理）UUID & async/await
/*
import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

/// OrderController 負責管理當前的訂單列表（如增加、更新、刪除），管理當前的狀態。
class OrderController {
    
    static let shared = OrderController()
    
    // MARK: - Properties

    /// 當前訂單項目列表
    var orderItems: [OrderItem] = [] {
        didSet {
            print("訂單項目更新，當前訂單數量: \(orderItems.count)")
            NotificationCenter.default.post(name: .orderUpdatedNotification, object: nil)   // 當訂單變更時發送通知
        }
    }
    
    // MARK: - Order Management Methods
    
    /// 新增訂單項目
    /// - Parameters:
    ///   - drink: 選擇的飲品
    ///   - size: 飲品的尺寸
    ///   - quantity: 數量
    ///   - categoryId: 飲品所屬的類別 ID
    ///   - subcategoryId: 飲品所屬的子類別 ID
    func addOrderItem(drink: Drink, size: String, quantity: Int, categoryId: String?, subcategoryId: String?) {
        
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        print("為使用者 \(user.uid) 添加訂單項目")

        let prepTime = drink.prepTime   // 使用飲品的準備時間（分鐘）
        let timestamp = Date()      // 當前時間
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        
        let orderItem = OrderItem(drink: drink, size: size, quantity: quantity, prepTime: prepTime, totalAmount: totalAmount, price: price, categoryId: categoryId, subcategoryId: subcategoryId)
        
        orderItems.append(orderItem)
        print("添加訂單項目 ID: \(orderItem.id)")
    }
    
    /// 更新訂單中的訂單項目的尺寸&數量
    /// - Parameters:
    ///   - id: 訂單項目 ID
    ///   - size: 新的尺寸
    ///   - quantity: 新的數量
    func updateOrderItem(withID id: UUID, with size: String, and quantity: Int) {
        guard let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let drink = orderItems[index].drink
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        
        orderItems[index].size = size
        orderItems[index].quantity = quantity
        orderItems[index].price = price
        orderItems[index].totalAmount = totalAmount
    }
    
    /// 清空訂單
    func clearOrder() {
        orderItems.removeAll()
    }
    
    /// 刪除特定訂單項目
    /// - Parameter id: 訂單項目 ID
    func removeOrderItem(withID id: UUID) {
        orderItems.removeAll { $0.id == id }
    }
    
    // MARK: - Submit Order

    /// 提交訂單
    /// - Parameter menuIDs: 訂單中飲品的菜單 ID 清單
    /// - Throws: 若提交失敗，則拋出錯誤
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws {
        guard let user = Auth.auth().currentUser else {
            throw OrderControllerError.orderRequestFailed
        }
        
        let orderData = buildOrderData(for: user.uid)
        
        do {
            try await saveOrderData(orderData: orderData, for: user.uid)
            // 安排通知
            scheduleNotification(prepTime: calculateTotalPrepTime() * 60) // 轉換為秒
        } catch {
            throw OrderControllerError.form(error)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// 構建訂單資料
    /// - Parameter userId: 當前的使用者
    /// - Returns: 包含訂單資訊的字典
    private func buildOrderData(for userId: String) -> [String: Any] {
        return [
            "uid": userId,
            "orderItems": orderItems.map { item in
                return [
                    "drink": [
                        "name": item.drink.name,
                        "subName": item.drink.subName,
                        "description": item.drink.description,
                        "imageUrl": item.drink.imageUrl.absoluteString,
                        "prepTime": item.drink.prepTime
                    ],
                    "size": item.size,
                    "quantity": item.quantity,
                    "prepTime": item.prepTime,
                    "totalAmount": item.totalAmount
                ]
            },
            "timestamp": Timestamp(date: Date())
        ]
    }
    
    /// 儲存訂單資料至 Firestore
    /// - Parameters:
    ///   - orderData: 訂單資料
    ///   - userID: 當前使用者
    private func saveOrderData(orderData: [String: Any], for userID: String) async throws {
        let db = Firestore.firestore()

        /// 在`用戶子集合`中添加訂單
        try await db.collection("users").document(userID).collection("orders").addDocument(data: orderData)

        /// 在`全局 orders 集合`中添加訂單
        try await db.collection("orders").addDocument(data: orderData)
    }
    
    // MARK: - Public Helper Methods

    /// 計算所有飲品的準備時間
    /// - Returns: 總準備時間（分鐘）
    func calculateTotalPrepTime() -> Int {
        return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
    }
    
    /// 計算訂單的總金額
    /// - Returns: 總金額
    func calculateTotalAmount() -> Int {
        return orderItems.reduce(0) { $0 + $1.totalAmount }
    }
    
    // MARK: - Local Notification

    /// 安排本地通知提醒用户訂單已經準備好
    /// - Parameter prepTime: 訂單準備時間（秒）
    private func scheduleNotification(prepTime: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Order Ready"
        content.body = "Your order is ready for pickup!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prepTime), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}

// MARK: - Error

/// 處理Order訂單錯誤相關訊息
enum OrderControllerError: Error, LocalizedError {
    case orderRequestFailed
    case unknownError
    case firebaseError(Error)
    
    static func form(_ error: Error) -> OrderControllerError {
        return .firebaseError(error)
    }
    
    var errorDescription: String? {
        switch self {
        case .orderRequestFailed:
            return NSLocalizedString("Order request failed.", comment: "Order request failed.")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "An unknown error occurred.")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}
*/


// MARK: - 調整OrderItemManager

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications


class OrderManager {
    
    static let shared = OrderManager()
    
    // MARK: - Submit Order

    /*
    /// 提交訂單（需要調整？）
    /// - Parameter menuIDs: 訂單中飲品的菜單 ID 清單
    /// - Throws: 若提交失敗，則拋出錯誤
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws {
        guard let user = Auth.auth().currentUser else {
            throw OrderManagerError.orderRequestFailed
        }
        
        let orderData = buildOrderData(for: user.uid)
        
        do {
            try await saveOrderData(orderData: orderData, for: user.uid)
            // 安排通知
            scheduleNotification(prepTime: calculateTotalPrepTime() * 60) // 轉換為秒
        } catch {
            throw OrderManagerError.form(error)
        }
    }
     */
    
    // MARK: - Private Helper Methods
    
    /*
    /// 構建訂單資料（需要調整？）
    /// - Parameter userId: 當前的使用者
    /// - Returns: 包含訂單資訊的字典
    private func buildOrderData(for userId: String) -> [String: Any] {
        return [
            "uid": userId,
            "orderItems": orderItems.map { item in
                return [
                    "drink": [
                        "name": item.drink.name,
                        "subName": item.drink.subName,
                        "description": item.drink.description,
                        "imageUrl": item.drink.imageUrl.absoluteString,
                        "prepTime": item.drink.prepTime
                    ],
                    "size": item.size,
                    "quantity": item.quantity,
                    "prepTime": item.prepTime,
                    "totalAmount": item.totalAmount
                ]
            },
            "timestamp": Timestamp(date: Date())
        ]
    }
     */
    
    /// 儲存訂單資料至 Firestore（需要調整？）
    /// - Parameters:
    ///   - orderData: 訂單資料
    ///   - userID: 當前使用者
    private func saveOrderData(orderData: [String: Any], for userID: String) async throws {
        let db = Firestore.firestore()

        /// 在`用戶子集合`中添加訂單
        try await db.collection("users").document(userID).collection("orders").addDocument(data: orderData)

        /// 在`全局 orders 集合`中添加訂單
        try await db.collection("orders").addDocument(data: orderData)
    }
    
    // MARK: - Local Notification

    /// 安排本地通知提醒用户訂單已經準備好（需要調整？）
    /// - Parameter prepTime: 訂單準備時間（秒）
    private func scheduleNotification(prepTime: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Order Ready"
        content.body = "Your order is ready for pickup!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prepTime), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}

// MARK: - Error

/// 處理Order訂單錯誤相關訊息
enum OrderManagerError: Error, LocalizedError {
    case orderRequestFailed
    case unknownError
    case firebaseError(Error)
    
    static func form(_ error: Error) -> OrderManagerError {
        return .firebaseError(error)
    }
    
    var errorDescription: String? {
        switch self {
        case .orderRequestFailed:
            return NSLocalizedString("Order request failed.", comment: "Order request failed.")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "An unknown error occurred.")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}
