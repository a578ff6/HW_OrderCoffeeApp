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


// MARK: - 尺寸完成，數量完成（訂單飲品項目回到DetailViewController處理修改訂單。）、Label完成。UUID
/*
import UIKit
import FirebaseAuth

 /// 用於展示和管理當前訂單
class OrderViewController: UIViewController {
    
    @IBOutlet weak var orderCollectionView: UICollectionView!
    
    weak var delegate: OrderModificationDelegate?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    enum Section: Int, CaseIterable {
        case orderItems, summary
    }
    
    enum Item: Hashable {
        case orderItem(OrderItem), summary(totalAmount: Int, totalPrepTime: Int), noOrders
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrders), name: .orderUpdatedNotification, object: nil)
        updateOrders()  // 初始化時也加載當前訂單
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .orderUpdatedNotification, object: nil)
    }
    
    /// 設置 CollectionView 的 delegate 和 dataSource，並註冊自定義單元格
    private func setupCollectionView() {
        orderCollectionView.delegate = self
        orderCollectionView.register(OrderItemCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier)
        orderCollectionView.register(OrderSummaryCollectionViewCell.self, forCellWithReuseIdentifier: OrderSummaryCollectionViewCell.reuseIdentifier)   // summary cell
        orderCollectionView.register(NoOrdersViewCell.self, forCellWithReuseIdentifier: NoOrdersViewCell.reuseIdentifier)        // no orders cell
        orderCollectionView.register(OrderSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OrderSectionHeaderView.headerIdentifier)
        orderCollectionView.collectionViewLayout = createLayout()
        configureDataSource()
    }
    
    /// 創建 CollectionView 佈局
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }
            var sectionLayout: NSCollectionLayoutSection
            
            switch sectionType {
            case .orderItems:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)), subitems: [item])
                sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                sectionLayout.boundarySupplementaryItems = [self.createSectionHeader()]
                
            case .summary:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
                sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                sectionLayout.boundarySupplementaryItems = [self.createSectionHeader()]
            }
            
            return sectionLayout
        }
        
        return layout
    }
    
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return header
    }

    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: orderCollectionView) { (collectionView, indexPath, item) in
            switch item {
            case .orderItem(let orderItem):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
                    fatalError("Cannot create OrderItemCollectionViewCell")
                }
                cell.configure(with: orderItem)
                cell.deleteAction = { [weak self] in
                    guard let self = self else { return }
                    AlertService.showAlert(withTitle: "確認刪除", message: "你確定要從訂單中刪除該品項嗎？", inViewController: self, showCancelButton: true) {
                        let orderItemID = orderItem.id
                        OrderController.shared.removeOrderItem(withID: orderItemID)
                        self.updateOrders()       // 刪除後更新訂單列表和總金額
                    }
                }
                return cell
                
            case .summary(totalAmount: let totalAmount, totalPrepTime: let totalPrepTime):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderSummaryCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderSummaryCollectionViewCell else {
                    fatalError("Cannot create OrderSummaryCollectionViewCell")
                }
                cell.configure(totalAmount: totalAmount, totalPrepTime: totalPrepTime)
                return cell
                
            case .noOrders:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoOrdersViewCell.reuseIdentifier, for: indexPath) as? NoOrdersViewCell else {
                    fatalError("Cannot create NoOrdersViewCell")
                }
                return cell
            }
            
        }
        
        dataSource.supplementaryViewProvider = createSupplementaryViewProvider()
    }
    
    private func createSupplementaryViewProvider() -> UICollectionViewDiffableDataSource<Section, Item>.SupplementaryViewProvider {
        return { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderSectionHeaderView.headerIdentifier, for: indexPath) as? OrderSectionHeaderView else {
                    fatalError("Cannot create OrderSectionHeaderView")
                }
                let section = Section(rawValue: indexPath.section)!
                switch section {
                case .orderItems:
                    headerView.configure(with: "訂單飲品項目")
                case .summary:
                    headerView.configure(with: "訂單詳情")
                }
                return headerView
            }
            
            return nil
        }
    }
    
    /// 更新訂單列表、重新加載數據並計算總金額
    @objc private func updateOrders() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        
        let orderItems = OrderController.shared.orderItems.map { Item.orderItem($0) }
        
        if orderItems.isEmpty {
            snapshot.appendItems([.noOrders], toSection: .orderItems)
        } else {
            snapshot.appendItems(orderItems, toSection: .orderItems)
        }
        
        let totalAmount = OrderController.shared.calculateTotalAmount()
        let totalPrepTime = OrderController.shared.calculateTotalPrepTime()
        snapshot.appendItems([.summary(totalAmount: totalAmount, totalPrepTime: totalPrepTime)], toSection: .summary)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}


 // MARK: - UICollectionViewDelegate
extension OrderViewController: UICollectionViewDelegate {
    /// 點擊訂單項目
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell at index \(indexPath.row) was selected.")   // 測試 cell 點擊
        
        // 檢查是否有訂單
        guard OrderController.shared.orderItems.count > 0 else { return }
        let orderItem = OrderController.shared.orderItems[indexPath.row]
        
        // 導航到 DrinkDetailViewController
        if let delegate = delegate {
            delegate.modifyOrderItem(orderItem, withID: orderItem.id)
        } else {
            presentDrinkDetailViewController(with: orderItem, at: indexPath.row)
        }
    }
    
    /// 顯示 DrinkDetailViewController
    private func presentDrinkDetailViewController(with orderItem: OrderItem, at index: Int) {
        if let detailVC = storyboard?.instantiateViewController(identifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController {
            detailVC.drinkId = orderItem.drink.id   // 傳遞 drinkId
            detailVC.categoryId = orderItem.categoryId  // 傳遞 categoryId
            detailVC.subcategoryId = orderItem.subcategoryId // 傳遞 subcategoryId
            detailVC.selectedSize = orderItem.size  // 傳遞已選擇的尺寸
            detailVC.isEditingOrderItem = true      // 編輯模式
            detailVC.editingOrderID = orderItem.id  // 設置編輯的訂單ID
            detailVC.editingOrderQuantity = orderItem.quantity  // 設置數量
            
            // 觀察傳遞的值
            print("傳遞給 DrinkDetailViewController 的資訊：drinkId: \(String(describing: orderItem.drink.id)), categoryId: \(String(describing: orderItem.categoryId)), subcategoryId: \(String(describing: orderItem.subcategoryId)), size: \(orderItem.size), quantity: \(orderItem.quantity)")
            
            detailVC.modalPresentationStyle = .pageSheet
            if let sheet = detailVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            present(detailVC, animated: true, completion: nil)
        }
    }
}
*/


// MARK: - 重構

import UIKit
import FirebaseAuth

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
    
    /// `修改訂單項目`並`進入詳細頁面`
    func modifyOrderItemToDetailViewDetail(_ orderItem: OrderItem, withID id: UUID) {
        presentDrinkDetailViewController(with: orderItem, at: id)
    }

    /// 顯示 DrinkDetailViewController 並傳遞相關數據
    private func presentDrinkDetailViewController(with orderItem: OrderItem, at id: UUID) {
        if let detailVC = storyboard?.instantiateViewController(identifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController {
            detailVC.drinkId = orderItem.drink.id   // 傳遞 drinkId
            detailVC.categoryId = orderItem.categoryId  // 傳遞 categoryId
            detailVC.subcategoryId = orderItem.subcategoryId // 傳遞 subcategoryId
            detailVC.selectedSize = orderItem.size  // 傳遞已選擇的尺寸
            detailVC.isEditingOrderItem = true      // 編輯模式
            detailVC.editingOrderID = orderItem.id  // 設置編輯的訂單ID
            detailVC.editingOrderQuantity = orderItem.quantity  // 設置數量
            
            // 觀察傳遞的值
            print("傳遞給 DrinkDetailViewController 的資訊：drinkId: \(String(describing: orderItem.drink.id)), categoryId: \(String(describing: orderItem.categoryId)), subcategoryId: \(String(describing: orderItem.subcategoryId)), size: \(orderItem.size), quantity: \(orderItem.quantity)")
            
            /// 呈現`詳細頁面`
            configureAndPresent(detailVC)
        }
    }
    
    /// 配置並顯示`頁面樣式`並呈現`詳細頁面`
    private func configureAndPresent(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(viewController, animated: true, completion: nil)
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
