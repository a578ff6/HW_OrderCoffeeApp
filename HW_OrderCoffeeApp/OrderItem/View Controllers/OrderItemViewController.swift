//
//  OrderItemViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/1.
//

// MARK: - OrderItemViewController 筆記
/**
 
 ## OrderItemViewController 筆記

 ---

 `* What`
 
 - `OrderItemViewController` 是負責展示和管理訂單頁面的核心控制器，包含以下主要功能：
 
 1. 展示訂單資料：顯示每個訂單項目的列表、總金額及準備時間。
 
 2. 與視圖和邏輯的整合：
    - 使用自訂視圖 `OrderItemView` 處理 UI 佈局。
    - 使用 `OrderItemHandler` 管理邏輯和數據處理。
    - 整合 `OrderItemManager` 實現訂單的數據同步。
 
 3. 訂單交互邏輯：支援用戶執行操作（如刪除、清空、編輯訂單）。
 
 4. 動態更新：訂單數據變更時自動刷新視圖，保持資料一致性。

 ------------------
 
` * Why`
 
 1. 清晰的責任分工：
    - 視圖管理 (`OrderItemView`) 和邏輯處理 (`OrderItemHandler`) 職責分離，提升可維護性。
 
 2. 訂單管理需求：
    - 實現動態更新訂單數據，滿足用戶管理當前訂單的需求。
 
 3. 高內聚性：
    - 將訂單相關的顯示和操作邏輯集中在單一控制器，減少模塊間耦合。
 
 4. 可擴展性：
    - 支援新增功能（如導覽到客戶資料頁），保持代碼結構清晰。

 ------------------

 `* How`

 `1. 訂單數據的初始化與更新`
 
 - 初始化訂單數據：
   - 在 `viewDidLoad` 中調用 `loadOrderData()`，通過 `OrderItemManager` 獲取訂單數據，並更新視圖。
 
 - 刷新數據邏輯：
   - 在通知監聽中使用 `refreshOrderView()`，確保視圖與訂單數據的同步。

 ---

 `2. 設置和管理 CollectionView`
 
 - 邏輯處理：
   - 使用 `setupCollectionView` 初始化 `OrderItemHandler`，負責訂單相關的數據源和交互處理。
   - `OrderItemHandler` 使用 `UICollectionViewDiffableDataSource` 動態更新視圖，確保數據一致。
 
 - 交互邏輯：
   - 通過 `OrderItemHandlerDelegate`，處理按鈕狀態更新、刪除、清空訂單等操作。

 ---

 `3. 與通知中心整合`
 
 - 監聽數據變更：
   - 註冊 `NotificationCenter`，監聽訂單數據的變更事件（如新增或刪除項目）。
 
 - 響應邏輯：
   - 在通知觸發時調用 `refreshOrderView()`，動態刷新訂單數據。

 ---

 `4. 用戶交互與導航邏輯`
 
 - 刪除或清空訂單項目：
   - 使用 `AlertService` 提供交互提示，確認操作後執行對應邏輯。
 
 - 導航邏輯：
   - 支援導航到 `EditOrderItemViewController` 或 `OrderCustomerDetailsViewController`，便於用戶編輯或填寫訂單相關信息。

 ------------------

 `* 結構設計細節`
 
 1. `viewDidLoad`
 
    - 負責初始化控制器的基礎模塊：
      - 設置導航欄（`setupNavigationBar`）
      - 配置 `CollectionView` 和邏輯處理器（`setupCollectionView`）
      - 加載初始數據（`loadOrderData`）
      - 註冊通知監聽。

 2. `loadOrderData`
 
    - 作為初始化和刷新訂單數據的通用方法，從數據管理器獲取訂單數據並更新視圖。

 3. `refreshOrderView`
 
    - 通過通知觸發，調用 `loadOrderData` 確保視圖與最新數據同步。

 4. `模組化設計`
 
    - **視圖展示**：使用 `OrderItemView` 提供統一的視圖管理。
    - **數據邏輯**：將邏輯處理交由 `OrderItemHandler`，確保視圖與數據分離。
    - **數據管理**：依賴 `OrderItemManager` 獲取數據並觸發更新，提升邏輯集中性。

 */



import UIKit

/// `OrderItemViewController` 負責展示和管理當前的訂單頁面。
///
/// ### 功能說明
/// - 顯示當前訂單，包括每個訂單項目的列表、總金額及準備時間等資訊。
/// - 使用自訂的 `OrderItemView` 作為主視圖，並透過 `OrderItemHandler` 管理訂單的邏輯與數據。
/// - 提供與導航欄和通知中心的整合，確保視圖與訂單資料保持同步。
///
/// ### 模組化設計
/// - 視圖展示： 使用 `OrderItemView` 處理視圖佈局與展示邏輯。
/// - 邏輯處理： 將數據源和事件處理委派給 `OrderItemHandler`。
/// - 導航控制： 使用 `OrderitemNavigationBarManager` 管理導航欄標題與樣式。
///
/// ### 核心功能
/// 1. 動態更新訂單資料並刷新視圖。
/// 2. 處理用戶與訂單的交互邏輯（如刪除訂單、清空訂單、編輯訂單）。
/// 3. 與 `OrderItemManager` 整合，確保訂單數據的實時同步。
///
/// ### 使用場景
/// - 訂單管理模塊的主要頁面，適用於顯示和操作當前訂單內容。
class OrderItemViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 主視圖，用於展示訂單項目。
    private let orderItemView = OrderItemView()
    
    /// 訂單數據管理器
    private let orderItemManager = OrderItemManager.shared
    
    /// 處理訂單數據與邏輯的管理器。
    private var orderItemHandler: OrderItemHandler?
    
    /// 導航欄管理器，用於設置導航標題與樣式。
    private var navigationBarManager: OrderitemNavigationBarManager?
    
    // MARK: - Lifecycle Methods
    
    /// 設置 `OrderItemView` 作為主視圖。
    override func loadView() {
        view = orderItemView
    }
    
    /// 頁面加載完成後初始化相關模組。
    ///
    /// - 初始化導航欄樣式。
    /// - 初始化 `CollectionView` 並配置相關的數據處理器。
    /// - 加載並顯示初始的訂單數據。
    /// - 註冊通知以監聽訂單數據的更新。
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        loadOrderData()
        registerNotifications()
    }
    
    // MARK: - deinit
    
    /// 移除通知觀察者，釋放資源。
    deinit {
        removeNotifications()
    }
    
    // MARK: - Setup Methods
    
    /// 配置導航欄的標題與樣式。
    ///
    /// 使用 `OrderitemNavigationBarManager` 管理導航欄的配置，包括標題和樣式。
    private func setupNavigationBar() {
        navigationBarManager = OrderitemNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        navigationBarManager?.configureNavigationBarTitle(title: "Order", prefersLargeTitles: true)
    }
    
    /// 配置 `CollectionView` 並初始化 `OrderItemHandler`。
    ///
    /// - 負責設置 `CollectionView` 的數據源與代理處理。
    /// - 配置 `OrderItemHandler` 來管理與訂單相關的邏輯。
    private func setupCollectionView() {
        orderItemHandler = OrderItemHandler(collectionView: orderItemView.orderItemCollectionView)
        orderItemView.orderItemCollectionView.delegate = orderItemHandler
        orderItemHandler?.orderItemHandlerDelegate = self
    }
    
    /// 加載訂單數據並更新視圖。
    ///
    /// 從 `OrderItemManager` 獲取當前的訂單數據，計算總金額與準備時間，並通過 `OrderItemHandler` 更新視圖。
    ///
    /// ### 使用場景
    /// - 在 `viewDidLoad` 中加載初始數據。
    /// - 在訂單數據變更時（通過通知）更新視圖。
    private func loadOrderData() {
        guard let orderItemHandler = orderItemHandler else { return }
        let orderItems = orderItemManager.orderItems
        let totalAmount = orderItemManager.calculateTotalAmount()
        let totalPrepTime = orderItemManager.calculateTotalPrepTime()
        orderItemHandler.updateOrders(with: orderItems, totalAmount: totalAmount, totalPrepTime: totalPrepTime)
    }
    
    // MARK: - Update Orders
    
    /// 刷新訂單視圖數據。
    ///
    /// 通過調用 `loadOrderData` 更新視圖，確保與最新的訂單數據保持同步。
    ///
    /// ### 使用場景
    /// - 通過通知監聽到訂單數據變更時調用。
    @objc private func refreshOrderView() {
        loadOrderData()
    }
    
}

// MARK: - OrderItemHandlerDelegate
extension OrderItemViewController: OrderItemHandlerDelegate {
    
    /// 獲取當前的訂單項目列表。
    /// - Returns: 當前所有的訂單項目。
    func getOrderItems() -> [OrderItem] {
        return orderItemManager.orderItems
    }
    
    /// 更新按鈕狀態的回調。
    /// - Parameter isOrderEmpty: 當前訂單是否為空。
    ///
    /// 用於根據訂單的狀態（是否為空）更新按鈕的啟用或禁用狀態。
    func orderItemHandlerDidUpdateButtons(isOrderEmpty: Bool) {
        let visibleCells = orderItemView.orderItemCollectionView.visibleCells
        guard let actionButtonsCell = visibleCells.first(where: { $0 is OrderItemActionButtonsCell }) as? OrderItemActionButtonsCell else {
            return
        }
        actionButtonsCell.updateActionButtonsState(isOrderEmpty: isOrderEmpty)
        print("[OrderItemViewController]: 按鈕狀態已更新: 訂單是否為空 \(isOrderEmpty)")
    }
    
    /// 刪除指定的訂單項目。
    /// - Parameter orderItem: 要刪除的訂單項目。
    ///
    /// 彈出確認框，確認刪除後更新數據並刷新視圖。
    func deleteOrderItem(_ orderItem: OrderItem) {
        AlertService.showAlert(
            withTitle: "確認刪除",
            message: "你確定要刪除該品項嗎？",
            inViewController: self,
            showCancelButton: true
        ) {
            print("[OrderItemViewController]: Deleting order item with ID: \(orderItem.id)")
            self.orderItemManager.removeOrderItem(withID: orderItem.id)
        }
    }
    
    /// 清空所有訂單項目。
    ///
    /// 彈出確認框，確認清空後更新數據並刷新視圖。
    func clearAllOrderItems() {
        AlertService.showAlert(
            withTitle: "確認清空訂單",
            message: "你確定要清空所有訂單項目嗎？",
            inViewController: self,
            showCancelButton: true
        ) {
            self.orderItemManager.clearOrder()
        }
    }
    
    /// 導航到編輯訂單項目頁面。
    /// - Parameter orderItem: 要編輯的訂單項目。
    ///
    /// 傳遞訂單資料並顯示 `EditOrderItemViewController`，供用戶編輯。
    func navigateToEditOrderItemView(with orderItem: OrderItem) {
        guard let editOrderItemVC = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.editOrderItemViewController) as? EditOrderItemViewController else {
            print("Failed to instantiate EditOrderItemViewController.")
            return
        }
        
        editOrderItemVC.orderItem = orderItem
        editOrderItemVC.modalPresentationStyle = .pageSheet
        editOrderItemVC.sheetPresentationController?.detents = [.large()]
        editOrderItemVC.sheetPresentationController?.prefersGrabberVisible = true
        present(editOrderItemVC, animated: true)
    }
    
    /// 導航至顧客資料頁面。
    ///
    /// 確保當前訂單中有項目後，顯示 `OrderCustomerDetailsViewController` 供用戶填寫顧客資訊。
    func proceedToCustomerDetails() {
        
        // 確保訂單中有項目才能繼續
        guard !orderItemManager.orderItems.isEmpty else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let customerDetailsVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.orderCustomerDetailsViewController) as? OrderCustomerDetailsViewController else {
            print("無法實例化 OrderCustomerDetailsViewController")
            return
        }
        
        customerDetailsVC.orderItems = orderItemManager.orderItems   // 傳遞訂單資料
        navigationController?.pushViewController(customerDetailsVC, animated: true)
    }
    
}


// MARK: - Notifications Handling
extension OrderItemViewController {
    
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
    
}
