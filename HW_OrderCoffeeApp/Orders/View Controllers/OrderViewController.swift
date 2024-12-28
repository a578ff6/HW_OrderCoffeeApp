//
//  OrderViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/1.
//

// 真
/*
 1. 分開處理當前訂單和歷史訂單：
        - 區分當前訂單和歷史訂單的處理方式。OrderItemManager 處理當前的訂單，而歷史訂單通過 FirebaseController 獲取。
 
 2. 即時更新訂單列表：
        - 每次添加訂單項目後，使用通知或委託機制來立即更新 OrderViewController 的訂單列表。
 
 3. OrderViewController 應該只處理當前訂單，而不是加載所有的歷史訂單。
        - 需要確保每次訂單更新後，OrderViewController 能即時更新顯示。這樣可以避免顯示過往的歷史訂單，並且每次添加訂單項目後能即時反映在訂單列表中。
 
 */


// MARK: - 重構視圖與資料分離 & 第一版本成功（刪除功能備份版本）尺寸完成，數量完成（訂單飲品項目回到DetailViewController處理修改訂單。）、Label完成

/*
 執行在 OrderViewController 中點擊某個訂單飲品項目後，跳轉到 DrinkDetailViewController 讓使用者修改該訂單飲品項目的尺寸、數量：
 
 1. 在 OrderViewController 中處理點擊事件：
    - 當用戶電擊某個訂單項目時，導航到 DrinkDetailViewController 並跳轉該訂單項目的資訊。

 2. 在 DrinkDetailViewController 中展示並允許修改：
    - 在 DrinkDetailViewController 中，展示傳遞過來的訂單飲品項目資訊，且允許使用者憂改尺寸、數量。

 3. 更新訂單飲品項目：
    - 當用戶在 DrinkDetailViewController 中點擊「更新訂單」按鈕時，將修改後的資訊凡回並更新 OrderItemManager 中的相應訂單飲品項目。
 
 4. 關於沒有訂單時，如點擊訂單section時會出錯：
        - 檢查是否有訂單飲品項目，在點擊事件中先檢查 OrderItemManager.shared.orderItems 是否為nil，如果是nil則不執行後續操作。
 
-------------------------------------------------------------------------------------------------------------------------
 
 ## OrderViewController：
 
    & 功能：
        - OrderViewController 用於展示當前訂單，包括顯示訂單項目、總金額和準備時間，並提供修改訂單、刪除項目、清空所有項目和進入顧客資料頁面的功能。

    & 視圖設置：
        - 使用 OrderView 作為主要視圖，展示訂單項目。
        - 透過 OrderHandler 處理 UICollectionView 的資料顯示和用戶交互，並使用委託處理訂單的修改、刪除、清空和進入下一步的操作。
 
    & 資料加載與更新流程：

        1. 在 viewDidLoad 初始化：
            - 註冊通知來監聽訂單資料更新。
            - 使用 setupCollectionView 方法初始化 UICollectionView 和其相關的委託。
            - 呼叫 refreshOrderView 方法以加載當前訂單。

        2. 使用委託模式處理訂單項目的操作：
           - OrderViewInteractionDelegate:  處理修改訂單項目，並在需要時顯示 DrinkDetailViewController 來編輯飲品資料，或者進入顧客資料頁面。
           - OrderActionDelegate: 負責通知刪除訂單項目或清空所有訂單，並顯示相應的確認提示框。
 
        3. 通知處理：
            - registerNotifications 註冊通知以監聽訂單的更新，使用 NotificationCenter.default。
            - removeNotifications 在控制器釋放時移除註冊的通知。
 
    & 資料處理：
        - OrderHandler： 負責 UICollectionView 的 dataSource 和 delegate 方法，包括顯示訂單項目、訂單摘要和無訂單的情況，並處理修改與刪除操作。

    & 主要流程：
        - 資料接收與顯示： 從 OrderItemManager 獲取訂單資料，並在初始化時透過 orderHandler.updateOrders() 更新視圖。
        - 修改訂單： 當使用者選擇訂單項目時，透過 OrderViewInteractionDelegate 委託方式顯示飲品詳細資料頁面（DrinkDetailViewController），以修改飲品資訊。
        - 刪除訂單項目： 點擊「刪除」或「清空」按鈕時，透過 OrderActionDelegate 委託方式顯示警告視窗以確認操作，並刪除相應訂單項目或清空所有項目，最後更新視圖。
        - 進入顧客資料頁面： 當使用者點擊「proceed」按鈕且訂單中有項目時，透過 OrderViewInteractionDelegate 進入 OrderCustomerDetailsViewController，讓用戶填寫顧客資料（如姓名、電話等）。
 
    & 主要功能概述：
        - 資料更新： 在資料發生變動時透過 Notification 觸發更新，保持顯示內容與訂單資料同步。
        - 視圖與資料分離： OrderView 負責視覺顯示，OrderHandler 負責資料處理，清楚劃分 UI 與業務邏輯。
 
 */



// MARK: - (v)

import UIKit

/// 用於展示和管理當前訂單的視圖控制器
///
/// `OrderViewController` 負責顯示當前的訂單，包括各訂單項目的列表、總金額和準備時間等。
/// 使用自訂的 `OrderView` 作為主視圖，並與 `OrderHandler` 交互來管理訂單邏輯。
class OrderViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 自訂的 OrderView，用於`展示訂單項目`
    private let orderView = OrderView()
    
    /// 處理`訂單邏輯`的 OrderHandler
    private var orderHandler: OrderHandler!
    
    // MARK: - Lifecycle Methods
    
    /// 設置 OrderView 作為主視圖
    override func loadView() {
        view = orderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        registerNotifications()
        refreshOrderView()           // 初始化時也加載當前訂單
    }
    
    // MARK: - deinit

    deinit {
        removeNotifications()
    }
    
    // MARK: - Setup Methods
    
    /// 設置 CollectionView 的 delegate 並初始化 OrderHandler
    private func setupCollectionView() {
        orderHandler = OrderHandler(collectionView: orderView.collectionView)
        orderView.collectionView.delegate = orderHandler
        
        /// 設置委託 (用於`修改訂單`與`刪除訂單`的交互)
        orderHandler.orderViewInteractionDelegate = self
        orderHandler.orderActionDelegate = self
    }
    
}

// MARK: - OrderViewInteractionDelegate
extension OrderViewController: OrderViewInteractionDelegate {
    
    /// `修改訂單項目`並進入`編輯頁面`
    func navigateToEditOrderItemView(with orderItem: OrderItem) {
         guard let editOrderItemVC = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.editOrderItemViewController) as? EditOrderItemViewController else {
             print("Failed to instantiate EditOrderItemViewController.")
             return
         }

         // 傳遞 OrderItem 資料
         editOrderItemVC.orderItem = orderItem

         // 配置並呈現視圖
         editOrderItemVC.modalPresentationStyle = .pageSheet
         if let sheet = editOrderItemVC.sheetPresentationController {
             sheet.detents = [.large()]
             sheet.prefersGrabberVisible = true
         }
         present(editOrderItemVC, animated: true, completion: nil)
     }
    
    /// 進入`顧客資料頁面`
    ///
    /// 確保訂單中有項目後才能進行，然後顯示 `OrderCustomerDetailsViewController` 以讓用戶填寫顧客資料。
    func proceedToCustomerDetails() {
        
        // 確保訂單中有項目才能繼續
        guard !OrderItemManager.shared.orderItems.isEmpty else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let customerDetailsVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.orderCustomerDetailsViewController) as? OrderCustomerDetailsViewController {
            customerDetailsVC.orderItems = OrderItemManager.shared.orderItems    // 傳遞訂單資料
            navigationController?.pushViewController(customerDetailsVC, animated: true)
        }
    }
    
}

// MARK: - OrderActionDelegate
extension OrderViewController: OrderActionDelegate {
    
    /// 刪除訂單項目
    func deleteOrderItem(_ orderItem: OrderItem) {
        AlertService.showAlert(withTitle: "確認刪除", message: "你確定要從訂單中刪除該品項嗎？", inViewController: self, showCancelButton: true) {
            print("Deleting order item with ID: \(orderItem.id)")           // Debug
            OrderItemManager.shared.removeOrderItem(withID: orderItem.id)
            self.orderHandler.updateOrders()                    // 刪除後更新訂單列表和總金額
        }
    }
    
    /// 清空訂單所有項目
    func clearAllOrderItems() {
        AlertService.showAlert(withTitle: "確認清空訂單", message: "你確定要清空所有訂單項目嗎？", inViewController: self, showCancelButton: true) {
            OrderItemManager.shared.clearOrder()
            self.orderHandler.updateOrders()                 // 清空後更新訂單列表和總金額
        }
    }
    
}

// MARK: - Notifications Handling
extension OrderViewController {
    
    /// 註冊通知觀察者以監聽訂單資料變更
    ///
    /// 保持顯示內容與訂單資料同步更新。
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOrderView), name: .orderUpdatedNotification, object: nil)
    }
    
    /// 移除通知觀察者
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Update Orders
    
    /// 更新訂單資料以同步顯示內容
    ///
    /// 當接收到通知或在初始化時調用，確保視圖與當前訂單資料同步顯示。
    @objc private func refreshOrderView() {
        orderHandler.updateOrders()             // 更新訂單列表，快照應用後按鈕狀態也會更新
    }
    
}
