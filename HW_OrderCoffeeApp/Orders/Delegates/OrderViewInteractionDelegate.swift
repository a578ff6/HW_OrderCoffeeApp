//
//  OrderViewInteractionDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/10.
//

/*
 // 發生的問題：
 
 1. NotificationCenter 是否適合修改尺寸、數量：
    - 在當前情況下， NotificationCenter 的使用是合適的，因為允許在整個App中傳播更改的通知。
    - 但是，如果打算在修改尺寸、數量時進行更多的交互，例如從 OrderViewController 導航回 DrinkDetailViewController，並在 DrinkDetailViewController 中進行更改，那麼使用委託（delegate）比較適合。
    - 因為委託（delegate）模式提供了更明確和直接的雙向通信方式，特別在兩個ViewController之間。
 
 2. 添加新飲品與修改訂單飲品的處理邏輯的分開：
    - 這樣可以確保在使用者點擊“Add to Cart”按鈕時，系統知道是要將新的飲品添加到訂單中，還是修改現有的訂單飲品項目。

 3. 閉包的使用會影響到用戶在 OrderViewController 中點擊訂單飲品項目進行修改的處理邏輯嗎？
    - 閉包使用是為了處理在 DrinkDetailViewController 中尺寸和數量的選擇。他與用戶在 OrderViewController 中點擊訂單飲品項目進行修改的邏輯是分開的。
    - 不過，這邊需要確保在用戶點擊訂單飲品項目時，能夠正確的導航回 DrinkDetailViewController，並且再回到 DrinkDetailViewController 時，能夠正確的顯示和修改之前的選擇。
 
 
 ====== 解决方案====
 
 1. 使用委託模式來處理 OrderViewController 與 DrinkDetailViewController的交互：
    - 建立一個 delegate，以便 OrderViewController 可以通知 DrinkDetailViewController 用戶希望修改訂單飲品項。
    - 在 OrderViewController 中實現該協議，並在用戶點擊訂單飲品項目時調用相關的委託方法。
 
 2. 區分添加新飲品和修改訂單飲品項目的邏輯：
    - 在 DrinkDetailViewController 中，添加一個標誌來確定訂單前是否在編輯模式。
    - 如果是編輯模式，那麼修改現有的訂單飲品項目，如果不是，則添加新飲品到訂單。
 
 ------------------------------------------------------------------------------
 
 
 ## 重點筆記 - OrderViewInteractionDelegate

    * 用途：
        - OrderViewInteractionDelegate 是用於處理訂單修改和視圖交互的委託模式，允許其他對象在用戶需要修改訂單或進入顧客資料頁面時被通知。
 
    * 說明：
        
        1. modifyOrderItemToDetailViewDetail(orderItem, id)： 處理用戶希望修改訂單項目時的邏輯，包含飲品、數量、尺寸等相關資訊。
 
                - orderItem： 需要被修改的訂單項目，包含飲品、數量、尺寸等相關資訊。
                - id： 每個訂單項目的唯一識別碼，用於精準識別需要修改的項目。
    
        2. proceedToCustomerDetails()： 處理進入顧客資料頁面的邏輯，用於填寫顧客信息。

    * 適用場景：
 
        - 當用戶從訂單頁面選擇某個飲品進行修改時，透過此委託協議通知相關的 ViewController 執行相應的邏輯，例如顯示修改訂單的詳細頁面。

        - 當用戶想要繼續到顧客資料頁面時，使用 proceedToCustomerDetails() 來進行下一步的操作。
 
 */


import Foundation

/// 用於`處理訂單視圖交互`的協議
///
/// 當用戶`選取某個訂單項目進行修改`或`進入顧客資料頁面`時，會透過此協議來通知負責的對象。
protocol OrderViewInteractionDelegate: AnyObject {
    
    /// 修改訂單項目並進入詳細頁面
    /// - Parameters:
    ///   - orderItem: 需要修改的訂單項目
    ///   - id: 訂單項目的唯一識別碼
    func modifyOrderItemToDetailViewDetail(_ orderItem: OrderItem, withID id: UUID)
    
    /// 繼續到顧客資料頁面（`OrderCustomerDetailsViewController`）
    func proceedToCustomerDetails()
}
