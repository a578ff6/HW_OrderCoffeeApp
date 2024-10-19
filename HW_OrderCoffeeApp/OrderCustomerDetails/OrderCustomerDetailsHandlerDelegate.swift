//
//  OrderCustomerDetailsHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/19.
//

// MARK: - OrderCustomerDetailsHandlerDelegate 筆記

/*
 - 用於定義 OrderCustomerDetailsHandlerDelegate 協議，主要是與 OrderCustomerDetailsHandler 進行溝通。

 * 協議說明：

    - customerDetailsDidChange()：用於即時處理顧客資料的變更，例如更新按鈕狀態或其他 UI 反應。
    - submitOrder()：用於處理訂單提交的事件，這通常是在用戶點擊提交按鈕後所需要的操作。
*/


import Foundation


/// 用於通知 OrderCustomerDetailsHandler 的相關變更
///
/// OrderCustomerDetailsHandlerDelegate 用於處理與`訂單顧客資料的變更`和`訂單提交操作`的相關事件。
protocol OrderCustomerDetailsHandlerDelegate: AnyObject {
    
    /// 當顧客資料（例如姓名、電話或取件方式）有變更時被調用
    ///
    /// - 用於更新表單提交按鈕的狀態或進行其他需要即時反應的操作。
    func customerDetailsDidChange()
    
    /// 用於處理提交訂單的操作
    ///
    /// - 當用戶在畫面上點擊提交訂單按鈕時被調用。
    func submitOrder()
    
}



