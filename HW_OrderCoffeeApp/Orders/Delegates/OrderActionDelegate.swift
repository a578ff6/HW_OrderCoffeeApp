//
//  OrderActionDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/5.
//

/*
 ## 重點筆記 - OrderActionDelegate
 
    * 用途：
        - OrderActionDelegate 是用於處理訂單刪除與清空操作的委託模式，提供給其他對象刪除指定訂單項目或清空所有訂單的能力。
 
    * 說明：
        - orderItem：需要被刪除的訂單項目，包含飲品、數量、尺寸等資訊。
        - clearAllOrderItems：負責清空訂單中的所有項目。
 
    * 適用場景：
        - 當用戶從訂單列表中選擇刪除某個飲品時，透過此委託協議通知相關的 ViewController 執行刪除邏輯，例如顯示確認刪除的提示框，或直接從訂單列表中移除該飲品。
        - 當用戶希望清空所有訂單項目時，透過 clearAllOrderItems 方法執行清空動作，並顯示相應的提示框確認。
 */

import Foundation

/// 用於處理`訂單刪除`操作的協議
///
/// 當用戶希望刪除訂單中的某個項目時，會透過此協議來通知負責的對象。
protocol OrderActionDelegate: AnyObject {
    
    /// 刪除訂單項目
    /// - Parameter orderItem: 需要刪除的訂單項目
    func deleteOrderItem(_ orderItem: OrderItem)
    
    /// 清空定單所有項目
    func clearAllOrderItems()
    
}
