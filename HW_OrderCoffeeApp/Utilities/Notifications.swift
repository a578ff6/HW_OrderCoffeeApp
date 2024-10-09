//
//  Notifications.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/24.
//

import Foundation

/// 將自定義的通知名稱，統一管理。
extension Notification.Name {
    
    // MARK: - Favorite Notifications

    /// 當「我的最愛」狀態變更時發送的通知
    ///
    /// 當使用者在「我的最愛」列表中添加或移除飲品時，會發送此通知。訂閱該通知的觀察者（如 `DrinkDetailViewController`）可以更新 UI 狀態。
    static let favoriteStatusChanged = Notification.Name("favoriteStatusChanged")
    
    // MARK: - Order Notifications

    /// 當訂單項目更新時發送的通知
    ///
    /// 每當 `OrderItemManager` 中的訂單項目（`orderItems`）變更時，會發送此通知。訂閱該通知的觀察者（如顯示訂單的頁面）可以即時刷新顯示內容。
    static let orderUpdatedNotification = Notification.Name("orderUpdated")
}
