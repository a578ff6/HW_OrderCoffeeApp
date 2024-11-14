//
//  OrderHistoryDetailSharingHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/14.
//

// MARK: - OrderHistoryDetailSharingHandler 導航欄設置與分享邏輯架構
/**
 ## 重點筆記：OrderHistoryDetailSharingHandler 導航欄設置與分享邏輯架構

 `1. 單一職責原則：`
    - 每個類別或模組應只負責一個明確的職責，這樣有助於程式碼的維護與擴展。

 `2. 導航欄與分享邏輯的分工：`
    - `OrderHistoryDetailNavigationBarManager` 應該專注於導航欄的設定，包括標題、大標題顯示模式和按鈕的添加。
    - 分享按鈕的配置由 `NavigationBarManager` 處理，但分享邏輯的執行應放在與業務邏輯相關的類別內（例如 `OrderHistoryDetailViewController`）。

 `3. 分享邏輯的實作：`
    - 分享按鈕的操作屬於業務邏輯的一部分，因此應該放在 `OrderHistoryDetailViewController` 中，而不是在 `NavigationBarManager` 中處理。
    - 透過建立 `OrderHistoryDetailSharingHandler` 類別來分離分享邏輯，避免 `ViewController` 過於肥大。

 `4. 使用 SharingHandler 來分離邏輯：`
    - 創建 `OrderHistoryDetailSharingHandler`，專門負責訂單的分享操作。
    - `ViewController` 通過 `SharingHandler` 處理具體的分享邏輯，保持自身的職責僅限於管理 UI 流程。

 `5. 總結：`
    - 使用 `NavigationBarManager` 設定導航欄元素，保持其專注於導航相關的視覺和操作配置。
    - 使用 `SharingHandler` 來管理分享邏輯，分離業務邏輯，使得 `ViewController` 更加精簡，符合單一職責原則，增強可維護性。
 */


// MARK: - OrderHistoryDetailSharingHandler 重點筆記
/**
 ## OrderHistoryDetailSharingHandler 重點筆記
 
 `1.Handler 的職責劃分`

 - `OrderHistoryDetailSharingHandler` 是一個專門處理分享功能的管理器，將分享的邏輯從主要的 `ViewController` 中分離出來，達到職責單一、解耦的目標。
 - 這樣的設計保持了 `OrderHistoryDetailViewController` 的清晰性，讓它專注於控制和顯示訂單細節的功能。
 
 `2.使用弱引用`

 - 使用 weak var viewController: UIViewController? 來防止循環引用（retain cycle）。
 - `OrderHistoryDetailSharingHandler` 需要引用傳遞進來的 viewController 以呈現分享畫面，但由於 viewController 已經有對 `OrderHistoryDetailSharingHandler` 的引用，使用弱引用避免了記憶體的相互持有。
 
 `3.使用 UIActivityViewController`

 - `UIActivityViewController` 是一個用來呈現分享選項的標準控制器，支援多種系統級分享（如訊息、郵件、社交媒體）。
 - 在` shareOrderHistoryDetail(orderHistoryDetail:) `方法中，建立分享的內容並呼叫 viewController 來呈現分享視圖。
 
 `4.靈活的初始化方法`

 - 初始化時傳入的 UIViewController 可以是任何符合需求的視圖控制器。
 - 這樣設計的好處是增加了可重用性，不僅限於某一個 ViewController，可以根據不同需求靈活運用這個 SharingHandler。
 
` 5.設計的好處`

 - `職責單一`：把分享功能封裝進一個 handler 中，使得主 ViewController 不必管理 UI 顯示外的邏輯。
 - `增加可讀性`：這樣分離的邏輯使代碼更清晰，方便維護。
 - `防止重複代碼`：若在其他地方也需要分享功能，可以重用這個 handler，不必重複編寫相同的分享邏輯。
 
 `6.使用情境`

 - 當 `OrderHistoryDetailViewController` 需要提供分享功能時，只需調用 `OrderHistoryDetailSharingHandler` 中的` shareOrderHistoryDetail() `方法。
 - 在導航欄按鈕中，呼叫分享按鈕的操作，使用這個 handler 來處理分享行為。
 */


import UIKit

/// `OrderHistoryDetailSharingHandler` 負責處理歷史訂單詳情的分享邏輯
/// - 將分享的邏輯與顯示層解耦，從而保持 `OrderHistoryDetailViewController` 的職責單一
class OrderHistoryDetailSharingHandler {
    
    // MARK: - Properties

    /// 持有一個 `UIViewController` 的弱引用，用於呈現 `UIActivityViewController`
    private weak var viewController: UIViewController?
    
    // MARK: - Initialization

    /// 初始化方法
    /// - Parameter viewController: 用於展示分享界面的 `UIViewController`
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Share Method

    /// 執行分享訂單的邏輯
    /// - Parameter orderHistoryDetail: 需要分享的訂單詳細資訊
    /// - 使用 `UIActivityViewController` 來呈現分享的內容
    func shareOrderHistoryDetail(orderHistoryDetail: OrderHistoryDetail) {
        let shareText = """
        Order ID: \(orderHistoryDetail.id)
        Customer Name: \(orderHistoryDetail.customerDetails.fullName)
        Customer Phone: \(orderHistoryDetail.customerDetails.phoneNumber)
        Total Amount: \(orderHistoryDetail.totalAmount) 元
        """
    
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        viewController?.present(activityViewController, animated: true, completion: nil)
    }
}
