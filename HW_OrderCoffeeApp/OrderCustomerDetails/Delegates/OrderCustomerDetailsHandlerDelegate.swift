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

// MARK: - 關於 navigateToStoreSelection

/*
 ## 關於 navigateToStoreSelection
 
 * 在 OrderCustomerDetailsHandlerDelegate 中添加了 navigateToStoreSelection 方法，用於導航至店家選擇視圖控制器 (StoreSelectionViewController)。
 
 - navigateToStoreSelection 方法的設計目的是將導航的邏輯從 OrderPickupMethodCell 中抽出來，集中到 OrderCustomerDetailsViewController 進行管理，確保邏輯集中且清晰。
 - 使用此委託的好處是使得 OrderPickupMethodCell 僅需通知外部用戶操作，而不需要直接處理具體的導航行為，這符合單一責任原則。
 - 在 OrderCustomerDetailsViewController 中實作此方法來執行具體的導航邏輯，這樣做可以讓代碼更具有可維護性和可擴展性。
 
 * 具體的使用方式
 
 1. 在 OrderPickupMethodCell 中點擊：
    - 當用戶在 OrderPickupMethodCell 點擊 selectStoreButton 時，回調閉包 onStoreButtonTapped 被觸發，然後通知外部。
 
 2. 在 OrderCustomerDetailsHandler 中設置回調：
    - 使用 onStoreButtonTapped 來通知 OrderCustomerDetailsViewController。
 
 3. 在 OrderCustomerDetailsViewController 中實現導航：
    - 在 OrderCustomerDetailsViewController 中實作委託方法 navigateToStoreSelection()，該方法中可以執行推送 StoreSelectionViewController 的邏輯。
 */


import Foundation


/// 用於通知 OrderCustomerDetailsHandler 的相關變更
///
/// OrderCustomerDetailsHandlerDelegate 用於處理與`訂單顧客資料的變更`和`訂單提交操作`以及`導航至門市選擇畫面`的相關事件。
protocol OrderCustomerDetailsHandlerDelegate: AnyObject {
    
    /// 當顧客資料（例如姓名、電話或取件方式）有變更時被調用
    ///
    /// - 用於更新表單提交按鈕的狀態或進行其他需要即時反應的操作。
    func customerDetailsDidChange()
    
    /// 用於處理提交訂單的操作
    ///
    /// - 當用戶在畫面上點擊提交訂單按鈕時被調用。
    func submitOrder()
    
    /// 導航至門市選擇畫面
    ///
    /// - 當使用者在 OrderPickupMethodCell 中點擊選擇店家的按鈕時調用。
    /// - 通過此方法，OrderCustomerDetailsViewController 負責推進至 StoreSelectionViewController，進行店鋪的選擇。
    func navigateToStoreSelection()
    
}



