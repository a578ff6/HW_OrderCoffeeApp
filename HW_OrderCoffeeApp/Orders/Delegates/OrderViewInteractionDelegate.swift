//
//  OrderViewInteractionDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/10.
//

// MARK: - 重點筆記 - OrderViewInteractionDelegate
/**
 
 ## 重點筆記 - OrderViewInteractionDelegate

 `* 用途：`
    
    - `OrderViewInteractionDelegate` 是用於處理訂單修改和視圖交互的委託模式，允許其他對象在用戶需要修改訂單或進入顧客資料頁面時被通知。
 
 ------------------

 `1. navigateToEditOrderItemView(with orderItem)：`

 - `用途：`
 
 - 處理用戶希望修改訂單項目時的邏輯，包含飲品、數量、尺寸等相關資訊。
 
 - `參數：`
 
 - `orderItem`： 需要被修改的訂單項目，包含飲品、數量、尺寸等相關資訊。
 
 - `行為：`
 
 - 導航到編輯訂單項目頁面 (`EditOrderItemViewController`)。
 - 顯示當前選定的訂單項目並允許用戶編輯。
 
 ------------------
 
 `2. proceedToCustomerDetails()：`
 
 - `用途：`
 
 - 處理進入顧客資料頁面的邏輯，用於填寫或檢視顧客資訊。

 `- 行為：`
 
 - 導航到顧客資料頁面 (`OrderCustomerDetailsViewController`)。
 
 ------------------
 
 `3. 適用場景：`
 
 - 當用戶從訂單頁面選擇某個飲品進行修改時，透過此委託協議通知相關的 ViewController 執行相應的邏輯，例如顯示修改訂單的詳細頁面。
 - 當用戶想要繼續到顧客資料頁面時，使用 proceedToCustomerDetails() 來進行下一步的操作。
 */


import Foundation

/// 用於`處理訂單視圖交互`的協議
///
/// 當用戶`選取某個訂單項目進行修改`或`進入顧客資料頁面`時，會透過此協議來通知負責的對象。
protocol OrderViewInteractionDelegate: AnyObject {
    
    /// 導航到編輯訂單項目頁面 (`EditOrderItemViewController`)
    /// - Parameter orderItem: 需要修改的訂單項目
    ///
    /// ### 用途：
    /// - 負責將用戶導向編輯頁面，並提供當前選定的訂單項目資訊。
    func navigateToEditOrderItemView(with orderItem: OrderItem)

    /// 繼續到顧客資料頁面 (`OrderCustomerDetailsViewController`)
    ///
    /// ### 用途：
    /// - 當用戶完成訂單內容確認後，進一步填寫或檢視顧客資訊。
    func proceedToCustomerDetails()
    
}
