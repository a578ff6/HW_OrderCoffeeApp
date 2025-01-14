//
//  OrderHistoryDetailViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

// MARK: - OrderHistoryDetailViewController 筆記
/**
 
 ## OrderHistoryDetailViewController 筆記

 
 `* What`
 
 - `OrderHistoryDetailViewController` 是一個視圖控制器，專門用於顯示歷史訂單的詳細資訊，包括訂單項目、顧客資訊、訂單摘要等。
 - 該控制器提供用戶友好的界面，讓用戶可以查閱並分享歷史訂單內容。

 - 主要功能包括：
 
 1. 數據獲取與展示：
 
    - 從 Firebase 獲取特定訂單的詳細資料。
    - 在自定義的 `UICollectionView` 中展示訂單的各類資訊。
 
 2. 用戶交互：
 
    - 支持點擊展開或收起 `Section Header`，方便用戶查看不同區塊的內容。
 
 3. 分享功能：
 
    - 用戶可以快速分享訂單詳細資訊，例如訂單編號、顧客資料和總金額。

 ----------

 `* Why`
 
 1. 單一職責原則 (SRP)：
 
    - 控制器專注於展示和管理歷史訂單的詳細資訊，數據獲取、分享邏輯以及導航欄設置均被分離到專門的管理器中。
    - 確保控制器的職責簡單且專一，提升可維護性。

 2. 解耦合：
 
    - 透過協議和管理器分離數據處理與視圖更新邏輯，降低控制器與其他模塊的耦合度，提升靈活性。
 
    - 例如：
      - `OrderHistoryDetailManager`：負責數據獲取。
      - `OrderHistoryDetailHandler`：管理 `UICollectionView` 的數據源與交互。
      - `OrderHistoryDetailNavigationBarManager`：處理導航欄的設置。

 3. 模組化設計：
 
    - 通過自定義的 `OrderHistoryDetailView` 和專屬管理器，將視圖層和邏輯層的職責劃分清晰，易於擴展和測試。

 4. 用戶體驗：
 
    - 提供直觀的界面，展示清晰且結構化的訂單信息。
    - 支持展開/收起操作，讓用戶可以根據需求查看更詳細的區域內容。
    - 分享功能為用戶提供便利，提升應用的實用性。

 ----------

 `* How`

 1. 設計架構：
 
    - 採用 MVC 模式，進一步細分邏輯與視圖的責任。
    - `OrderHistoryDetailViewController` 作為主要控制器，協調數據處理、視圖更新和用戶交互。
    - 依賴多個管理器（如 `OrderHistoryDetailHandler` 和 `OrderHistoryDetailSharingHandler`）來執行具體功能。

 2. 核心邏輯劃分：
 
    - 數據獲取 (`fetchOrderDetail`)：
      - 使用 `OrderHistoryDetailManager` 與 Firebase 交互，異步獲取數據。
      - 獲取數據後，初始化數據處理器 (`OrderHistoryDetailHandler`) 並刷新 `UICollectionView`。
 
    - 視圖設置 (`setupNavigationBar` 和 `setupOrderHistoryDetailHandlerAndCollectionView`)：
      - 配置導航欄標題和按鈕。
      - 配置 `UICollectionView`，綁定數據源和委託。
 
    - 分享功能 (`setupSharingHandler` 和 `shareOrderHistoryDetail`)：
      - 使用 `OrderHistoryDetailSharingHandler` 處理分享邏輯，顯示分享界面。
 
    - 用戶交互 (`didToggleSection`)：
      - 通過協議通知控制器執行 UI 更新。

 3. 片段解讀：
 
    - 數據處理與視圖配置整合：
 
      ```swift
      private func setupOrderHistoryDetailHandlerAndCollectionView() {
          let handler = OrderHistoryDetailHandler(
              orderHistoryDetailHandlerDelegate: self,
              orderHistoryDetailSectionDelegate: self
          )
          self.orderHistoryDetailHandler = handler
          let collectionView = orderHistoryDetailView.orderHistoryDetailCollectionView
          collectionView.dataSource = handler
          collectionView.delegate = handler
          collectionView.reloadData()
      }
      ```

 ----

    - 分享功能的實現：
 
      ```swift
      @objc private func shareOrderHistoryDetail() {
          guard let orderHistoryDetail = orderHistoryDetail else { return }
          sharingHandler?.shareOrderHistoryDetail(orderHistoryDetail: orderHistoryDetail)
      }
      ```

 ----
 
    - 區域展開/收起交互：
 
      ```swift
      func didToggleSection(_ section: Int) {
          print("[OrderHistoryDetailViewController]: Section toggled: \(section)")
          orderHistoryDetailView.orderHistoryDetailCollectionView.reloadSections(IndexSet(integer: section))
      }
      ```
 
 */


// MARK: - (v)

import UIKit

/// `OrderHistoryDetailViewController`
///
/// 此視圖控制器負責顯示歷史訂單的詳細資訊，提供包括訂單項目、顧客資訊、訂單摘要等內容的展示和分享功能。
///
/// - 設計目標:
///   1. 單一職責: 專注於顯示歷史訂單的詳細資訊，並為用戶提供分享功能。
///   2. 模組化: 通過分離邏輯（如數據獲取、分享、導航欄設置），提升可讀性與維護性。
///   3. 解耦合: 使用管理器和協議分離邏輯層與視圖層，減少依賴，提升靈活性。
///
/// - 功能:
///   - 獲取並展示特定訂單的詳細資訊。
///   - 支持用戶分享訂單內容。
///   - 通過自定義視圖和導航欄設置，提供直觀的用戶界面。
class OrderHistoryDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 接收的訂單 ID，用於查找訂單的詳細資料
    var orderId: String?
    
    /// 保存歷史詳細訂單資料，供 UI 顯示使用
    private var orderHistoryDetail: OrderHistoryDetail?
    
    /// 自訂的 OrderHistoryDetailView，包含 UICollectionView，用於顯示訂單的詳細資訊
    private let orderHistoryDetailView = OrderHistoryDetailView()
    
    /// 負責管理 CollectionView 的數據源與委託的處理器
    private var orderHistoryDetailHandler: OrderHistoryDetailHandler?
    
    /// 歷史訂單資料管理器，用於從 Firebase 獲取訂單資料
    private let orderHistoryDetailManager = OrderHistoryDetailManager()
    
    /// 導航欄管理器，用於設置導航欄的標題和按鈕
    private var orderHistoryDetailNavigationBarManager: OrderHistoryDetailNavigationBarManager?
    
    /// 分享邏輯的管理器，用於處理分享訂單詳細資訊的行為
    private var orderHistoryDetailSharingHandler: OrderHistoryDetailSharingHandler?
    
    // MARK: - Lifecycle Methods
    
    /// 設置主要的 View 為自定義的 `OrderHistoryDetailView`
    override func loadView() {
        view = orderHistoryDetailView
    }
    
    /// 初始化控制器時配置必要的 UI 和數據邏輯
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSharingHandler()
        fetchOrderDetail()
    }
    
    // MARK: - Data Fetching
    
    /// 獲取指定的訂單詳細資料
    ///
    /// - 說明:
    ///   - 傳遞有效的訂單 ID，通過 `OrderHistoryDetailManager` 從 Firebase 獲取訂單詳細資料。
    ///   - 成功獲取資料後初始化處理器，並更新 UI。
    private func fetchOrderDetail() {
        guard let orderId = orderId else { return }
        HUDManager.shared.showLoading(text: "History Detail...")
        Task {
            do {
                let detail = try await orderHistoryDetailManager.fetchOrderDetail(for: orderId)
                self.orderHistoryDetail = detail
                // 成功獲取詳細資料後，初始化處理器並配置 UI
                setupOrderHistoryDetailHandlerAndCollectionView()
            } catch {
                print("Failed to fetch order detail: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: "Failed to fetch order detail: \(error.localizedDescription)", inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Setup Methods
    
    /// 初始化 `OrderHistoryDetailHandler` 並配置 `CollectionView`
    ///
    /// - 說明:
    ///   1. 初始化數據處理器 `OrderHistoryDetailHandler`。
    ///   2. 綁定數據源與委託到 `CollectionView`。
    private func setupOrderHistoryDetailHandlerAndCollectionView() {
        // 初始化數據處理器
        let handler = OrderHistoryDetailHandler(
            orderHistoryDetailHandlerDelegate: self,
            orderHistoryDetailSectionDelegate: self
        )
        
        self.orderHistoryDetailHandler = handler
        
        // 綁定數據處理器到 CollectionView
        let collectionView = orderHistoryDetailView.orderHistoryDetailCollectionView
        collectionView.dataSource = handler
        collectionView.delegate = handler
        collectionView.reloadData()
    }
    
    /// 設置分享邏輯的管理器
    private func setupSharingHandler() {
        orderHistoryDetailSharingHandler = OrderHistoryDetailSharingHandler(viewController: self)
    }
    
    /// 設置導航欄按鈕和標題
    private func setupNavigationBar() {
        orderHistoryDetailNavigationBarManager = OrderHistoryDetailNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        orderHistoryDetailNavigationBarManager?.configureNavigationBarTitle(title: "Order Details", prefersLargeTitles: true)
        orderHistoryDetailNavigationBarManager?.setupShareButton(target: self, action: #selector(shareOrderHistoryDetail))
    }
    
    // MARK: - Share Button Action
    
    /// 分享歷史訂單的詳細資訊
    ///
    /// - 使用分享管理器 (`OrderHistoryDetailSharingHandler`) 執行分享邏輯
    @objc private func shareOrderHistoryDetail() {
        guard let orderHistoryDetail = orderHistoryDetail else { return }
        orderHistoryDetailSharingHandler?.shareOrderHistoryDetail(orderHistoryDetail: orderHistoryDetail)
    }
    
}


// MARK: - OrderHistoryDetailHandlerDelegate
extension OrderHistoryDetailViewController: OrderHistoryDetailHandlerDelegate {
    
    /// 提供當前顯示的訂單詳細資料
    ///
    /// - Returns: 當前顯示的訂單詳細資料（`OrderHistoryDetail`）
    /// - 若資料不存在則觸發錯誤，確保數據一致性。
    func getOrderHistoryDetail() -> OrderHistoryDetail {
        guard let orderHistoryDetail = orderHistoryDetail else {
            fatalError("OrderHistoryDetail is not available")
        }
        return orderHistoryDetail
    }
    
}

// MARK: - OrderHistoryDetailSectionDelegate
extension OrderHistoryDetailViewController: OrderHistoryDetailSectionDelegate {
    
    /// 切換指定區域的展開/收起狀態
    ///
    /// - Parameter section: 被點擊的區域索引
    /// - 說明：
    ///   - 接收來自 `OrderHistoryDetailHandler` 的通知。
    ///   - 更新對應區域的 UI。
    func didToggleSection(_ section: Int) {
        print("[OrderHistoryDetailViewController]: Section toggled: \(section)")
        orderHistoryDetailView.orderHistoryDetailCollectionView.reloadSections(IndexSet(integer: section))
    }
    
}
