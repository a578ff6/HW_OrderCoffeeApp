//
//  OrderHistoryDetailViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

// MARK: - OrderHistoryDetailViewController 重點筆記
/**
 ## OrderHistoryDetailViewController 重點筆記
 
 `1.ViewController 職責分離`

 - `OrderHistoryDetailViewController` 的主要目標是顯示特定訂單的詳細資訊。
 - 它透過多個 Handler（例如 `OrderHistoryDetailHandler` 和 `OrderHistoryDetailNavigationBarManager`）來分離 UI 和邏輯，減少控制器的職責，從而提高可維護性。
 
` 2.導航欄管理（Navigation Bar Manager）`

 - `OrderHistoryDetailNavigationBarManager` 被用來管理導航欄的標題和按鈕設置，這使得主控制器更專注於業務邏輯。
 - 通過 `setupNavigationBar() `方法來設置導航欄標題和分享按鈕，按鈕點擊後會觸發 `shareOrderHistoryDetail` 方法。
 
 `3.分享邏輯管理器（Sharing Handler）`

 - 使用 `OrderHistoryDetailSharingHandler` 來處理分享按鈕的功能，將分享的邏輯從控制器中分離出來，以達到單一職責原則。
 - 這讓 `OrderHistoryDetailViewController` 可以保持更輕量，只關注訂單的顯示和數據更新，而不是管理分享的具體行為。
 
 `4.Collection View 的數據源和委託`

 - `OrderHistoryDetailHandler` 負責處理 UICollectionView 的數據源和委託，使得 `OrderHistoryDetailViewController` 更專注於高層次的控制流，而不涉及具體的 UI 顯示邏輯。
 
` 5.詳細資料的獲取與展示`

 - 在 `fetchOrderDetail() `方法中，透過 Firebase 獲取指定的訂單詳細資料，並在成功後初始化 Detail Handler 並更新 UI。
 - 這樣的設計確保數據和顯示是動態更新的，並且在數據獲取之前不會嘗試顯示資料。
 
 `6.ViewController 輕量化`

 - 通過將不同的功能（如導航欄設置、分享行為、數據處理）分離到不同的管理器和 Handler，這種方法遵循了單一職責原則（Single Responsibility Principle），使 `OrderHistoryDetailViewController` 保持輕量，且更易於維護和測試。
 */

import UIKit
import Firebase

/// `OrderHistoryDetailViewController` 用於顯示指定的歷史訂單詳細資訊
/// - 包括顯示訂單的所有項目和顧客資料，以及允許用戶分享訂單詳細資訊。
class OrderHistoryDetailViewController: UIViewController {

    // MARK: - Properties

    /// 接收的訂單 ID，用於查找訂單的詳細資料
    var orderId: String?
    
    /// 保存歷史詳細訂單資料，供 UI 顯示使用
    private var orderHistoryDetail: OrderHistoryDetail?
    
    /// 歷史訂單資料管理器，用於從 Firebase 獲取訂單資料
    private let detailManager = OrderHistoryDetailManager()
    
    /// 自訂的 OrderHistoryDetailView，包含 UICollectionView，用於顯示訂單的詳細資訊
    private let orderHistoryDetailView = OrderHistoryDetailView()
    
    /// OrderHistoryDetailHandler 負責處理 collectionView 的數據源和委託
    private var orderHistoryDetailHandler: OrderHistoryDetailHandler?
    
    /// 導航欄管理器，用於設置導航欄按鈕和標題
    private var orderHistoryDetailNavigationBarManager: OrderHistoryDetailNavigationBarManager?
    
    /// 分享邏輯的管理器，用於處理分享訂單詳細資訊的行為
    private var sharingHandler: OrderHistoryDetailSharingHandler?
 
    // MARK: - Lifecycle Methods

    override func loadView() {
        view = orderHistoryDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSharingHandler()
        fetchOrderDetail()
    }
    
    // MARK: - Data Fetching

    /// 獲取指定的訂單詳細資料
    /// - 說明：檢查當前使用者是否已登入，並且是否有傳遞有效的訂單 ID。然後從 Firebase 獲取訂單詳細資料。
    private func fetchOrderDetail() {
        guard let (userId, orderId) = validateCurrentUserAndOrderId() else {
             return
         }

        HUDManager.shared.showLoading(text: "Loading OrderDetail...")
        Task {
            do {
                let fetchedDetail = try await detailManager.fetchOrderDetail(for: userId, orderId: orderId)
                self.orderHistoryDetail = fetchedDetail
                // 成功獲取詳細資料後，設置 Handler 並更新 UI
                initializeDetailHandler()
            } catch {
                print("Failed to fetch order detail: \(error.localizedDescription)")
            }
            HUDManager.shared.dismiss()
        }
    }
    
    /// 檢查當前用戶是否已登入且訂單 ID 是否有效
    /// - Returns: 返回 (userId, orderId) 的元組，如果檢查失敗則返回 nil
    private func validateCurrentUserAndOrderId() -> (String, String)? {
        guard let currentUser = Auth.auth().currentUser, let orderId = orderId else {
            print("No Order ID provided or user not logged in")
            return nil
        }
        return (currentUser.uid, orderId)
    }
    
    // MARK: - Setup Methods

    /// 設置分享邏輯的管理器
    private func setupSharingHandler() {
        sharingHandler = OrderHistoryDetailSharingHandler(viewController: self)
    }
    
    /// 初始化 `Detail Handler`
    private func initializeDetailHandler() {
        guard let orderHistroyDetail = orderHistoryDetail else { return }
        let handler = OrderHistoryDetailHandler(delegate: self)
        orderHistoryDetailHandler = handler
        configureCollectionView(handler: handler)
    }

    /// 配置 `CollectionView` 的數據源和委託
    /// - Parameter handler: 已初始化的 `OrderHistoryDetailHandler`
    private func configureCollectionView(handler: OrderHistoryDetailHandler) {
        let collectionView = orderHistoryDetailView.collectionView
        collectionView.dataSource = handler
        collectionView.delegate = handler
        collectionView.reloadData()
    }

    /// 設置導航欄按鈕和標題
    private func setupNavigationBar() {
        orderHistoryDetailNavigationBarManager = OrderHistoryDetailNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        orderHistoryDetailNavigationBarManager?.configureNavigationBarTitle(title: "Order Details", prefersLargeTitles: true)
        orderHistoryDetailNavigationBarManager?.setupShareButton(target: self, action: #selector(shareOrderHistoryDetail))
    }
    
    // MARK: - Share Button Action
 
    /// 分享歷史訂單的詳細資訊
    /// - 使用分享管理器 (`sharingHandler`) 將訂單資訊分享。
    @objc private func shareOrderHistoryDetail() {
        guard let orderHistoryDetail = orderHistoryDetail else { return }
        sharingHandler?.shareOrderHistoryDetail(orderHistoryDetail: orderHistoryDetail)
    }
 
}

// MARK: - OrderHistoryDetailDelegate
extension OrderHistoryDetailViewController: OrderHistoryDetailDelegate {
    
    // MARK: - Section Handling
    
    /// 切換指定區域的展開/收起狀態
    /// - Parameter section: 被點擊的區域索引
    /// - 說明：收到 `OrderHistoryDetailHandler` 的通知後，重新載入對應的區域顯示，以反映使用者的展開或收起操作
    func didToggleSection(_ section: Int) {
        print("Did toggle section: \(section)")
        orderHistoryDetailView.collectionView.reloadSections(IndexSet(integer: section))
    }
    
    // MARK: - Order Data Methods
    
    /// 提供訂單的詳細資料給外部調用
    /// - Returns: 當前顯示的訂單詳細資料
    /// - 如果訂單資料不存在則會導致程序崩潰（為確保數據完整性）
    func getOrderHistoryDetail() -> OrderHistoryDetail {
        guard let orderHistoryDetail = orderHistoryDetail else {
            fatalError("OrderHistoryDetail is not available")
        }
        return orderHistoryDetail
    }
    
}
