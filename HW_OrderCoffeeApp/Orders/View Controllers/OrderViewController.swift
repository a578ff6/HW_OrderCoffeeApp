//
//  OrderViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/1.
//

// 真
/*
 1. 分開處理當前訂單和歷史訂單：
        - 區分當前訂單和歷史訂單的處理方式。OrderController 處理當前的訂單，而歷史訂單通過 FirebaseController 獲取。
 
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
    - 當用戶在 DrinkDetailViewController 中點擊「更新訂單」按鈕時，將修改後的資訊凡回並更新 OrderController 中的相應訂單飲品項目。
 
 4. 關於沒有訂單時，如點擊訂單section時會出錯：
        - 檢查是否有訂單飲品項目，在點擊事件中先檢查 OrderController.shared.orderItems 是否為nil，如果是nil則不執行後續操作。
 
-------------------------------------------------------------------------------------------------------------------------
 
 ## OrderViewController：
 
    & 功能：
        - 展示當前訂單的視圖控制器，負責顯示訂單項目，並提供訂單項目修改、刪除的功能。
 
    & 視圖設置：
        - 透過 OrderView 設置主要視圖，並使用 OrderHandler 處理 UICollectionView 的資料顯示和用戶交互。
 
    & 資料加載與更新流程：

        1. 在 viewDidLoad 初始化：
            - 註冊通知來監聽訂單資料更新。
            - 使用 setupCollectionView 方法初始化 UICollectionView 和其相關的委託。
            - 呼叫 refreshOrderView 方法以加載當前訂單。

        2. 使用委託模式處理訂單項目的操作：
            - 使用 OrderModificationDelegate 來通知修改訂單項目，並在需要時顯示 DrinkDetailViewController。
            - 使用 OrderActionDelegate 來通知刪除訂單項目，並顯示確認刪除的警告視窗。
 
        3. 通知處理：
            - registerNotifications 註冊通知以監聽訂單的更新，使用 NotificationCenter.default。
            - removeNotifications 在控制器釋放時移除註冊的通知。
 
    & 資料處理：
        - OrderHandler： 負責 UICollectionView 的 dataSource 和 delegate 方法，包括顯示訂單項目、訂單摘要和無訂單的情況，並處理修改與刪除操作。

    & 主要流程：
        - 資料接收與顯示： 從 OrderController 獲取訂單資料，並在初始化時更新視圖。
        - 修改訂單： 當使用者選擇訂單項目時，透過委託方式呈現飲品詳細資料頁面。
        - 刪除訂單： 點擊刪除按鈕時，透過委託方式顯示警告視窗確認，並進行訂單刪除後的更新操作。

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
        orderHandler.orderModificationDelegate = self
        orderHandler.orderActionDelegate = self
    }
    
}

// MARK: - OrderModificationDelegate
extension OrderViewController: OrderModificationDelegate {
    
    /// 修改訂單項目
    func modifyOrderItem(_ orderItem: OrderItem, withID id: UUID) {
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
    
}

// MARK: - OrderActionDelegate
extension OrderViewController: OrderActionDelegate {
    
    /// 刪除訂單項目
    func deleteOrderItem(_ orderItem: OrderItem) {
        AlertService.showAlert(withTitle: "確認刪除", message: "你確定要從訂單中刪除該品項嗎？", inViewController: self, showCancelButton: true) {
            print("Deleting order item with ID: \(orderItem.id)")           // Debug
            OrderController.shared.removeOrderItem(withID: orderItem.id)
            self.orderHandler.updateOrders()                    // 刪除後更新訂單列表和總金額
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
        orderHandler.updateOrders()
    }
    
}



// MARK: - 方法一 訂單數據量不大版本（只是用來處理當前訂單而不是歷史訂單）

/*
 1. 直接從 OrderController 獲取 orderItems。
 2. 當訂單項目變化時，直接從 OrderController 獲取最新的訂單數據並更新 UI。
 3. 適合訂單數據只需從單一數據源獲取的情況，並且 OrderController 的數據變化立即需要反映到 UI 上。
 */


/*
 
 import UIKit

class OrderViewController: UIViewController {

    @IBOutlet weak var orderCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrders), name: .orderUpdated, object: nil)
        updateOrders()  // 初始化時也加載當前訂單
    }
 
 deinit {
      NotificationCenter.default.removeObserver(self, name: .orderUpdated, object: nil)
  }
    

    private func setupCollectionView() {
        orderCollectionView.delegate = self
        orderCollectionView.dataSource = self
        orderCollectionView.register(OrderItemCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier)
    }
    
    @objc private func updateOrders() {
        orderCollectionView.reloadData()
        updateTotalAmount()
    }
    
    private func updateTotalAmount() {
        let totalAmount = OrderController.shared.orderItems.reduce(0) { $0 + $1.totalAmount }
        print("總金額\(totalAmount)")  // 測試用
    }

 
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension OrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let orderCount = OrderController.shared.orderItems.count
        if orderCount == 0 {
            let noOrdersLabel = UILabel()
            noOrdersLabel.text = "目前沒有商品在訂單中"
            noOrdersLabel.textAlignment = .center
            noOrdersLabel.frame = orderCollectionView.bounds
            orderCollectionView.backgroundView = noOrdersLabel
        } else {
            orderCollectionView.backgroundView = nil
        }
        return orderCount
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
            fatalError("Cannot create OrderItemCollectionViewCell")
        }
        
        let orderItem = OrderController.shared.orderItems[indexPath.row]
        cell.configure(with: orderItem)
        cell.stepperChanged = { [weak self] newQuantity in
            OrderController.shared.updateOrderItemQuantity(at: indexPath.row, to: newQuantity)
            self?.updateTotalAmount()
        }
        return cell
    }
    
}
 */


 
 // MARK: -  方法二（只是用來處理當前訂單而不是歷史訂單）適合訂單量大：訂單數據量較大

/*
 1. 在 OrderViewController 中有一個本地的 orders 變數來存放訂單數據。
 2. 在初始化和通知更新時，都會同步 OrderController 的數據到本地 orders 變數。
 3. 適合需要在本地對訂單數據進行一些處理或變換，並且希望減少對 OrderController 的直接依賴的情況。
 4. initializeOrderData 是為了在初始化時從 OrderController 獲取當前的訂單數據，這樣可以保證 OrderViewController 的 orders 變數一開始就有正確的數據。
 */

/*
import UIKit

/// 處理訂單
class OrderViewController: UIViewController {

    @IBOutlet weak var orderCollectionView: UICollectionView!
    
    var orders: [OrderItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        initializeOrderData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrders), name: .orderUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .orderUpdated, object: nil)
    }
    
    private func setupCollectionView() {
        orderCollectionView.delegate = self
        orderCollectionView.dataSource = self
        orderCollectionView.register(OrderItemCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier)
    }
    
    private func initializeOrderData() {
        orders = OrderController.shared.orderItems
        orderCollectionView.reloadData()
        updateTotalAmount()
    }
    
    private func updateTotalAmount() {
        let totalAmount = orders.reduce(0) { $0 + $1.totalAmount }
        print("總金額\(totalAmount)")  // 測試用
    }
    
    @objc private func updateOrders() {
        orders = OrderController.shared.orderItems
        orderCollectionView.reloadData()
        updateTotalAmount()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension OrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let orderCount = orders.count
        if orderCount == 0 {
            let noOrdersLabel = UILabel()
            noOrdersLabel.text = "目前沒有商品在訂單中"
            noOrdersLabel.textAlignment = .center
            noOrdersLabel.frame = orderCollectionView.bounds
            orderCollectionView.backgroundView = noOrdersLabel
        } else {
            orderCollectionView.backgroundView = nil
        }
        return orderCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
            fatalError("Cannot create OrderItemCollectionViewCell")
        }
        
        let orderItem = orders[indexPath.row]
        cell.configure(with: orderItem)
        cell.stepperChanged = { [weak self] newQuantity in
            self?.orders[indexPath.row].quantity = newQuantity
            OrderController.shared.updateOrderItemQuantity(at: indexPath.row, to: newQuantity)
            self?.updateTotalAmount()
        }
        
        return cell
    }
}
*/






// MARK: - 模擬版本(早期概念版本)
/*
 A. 在處理使用者訂單資料時，可以在使用者登入後載入其歷史訂單，這樣使用者可以查看自己的歷史訂單記錄。
    不需要在 FirebaseController 中對現有的方法做太多調整，只需新增一個新的方法來載入使用者的訂單資料。

 B.處理空訂單清單的邏輯
  - 在 updateUI 方法中，透過判斷 orderItems 是否為 nil 來控制 emptyOrdersLabel 的顯示與隱藏。
    - 這樣，當使用者沒有訂單時，會顯示提示Label；當使用者有訂單時，顯示訂單清單。

 ------------------------------------------------------------------------------

  1. OrderViewController 中的 Storyboard 修改
  - 在 Storyboard 中新增 UILabel，用於提示使用者沒有訂單數據，並將其連接到 emptyOrdersLabel。
  - 設定該Label的初始狀態為隱藏。

  2. 處理空訂單清單的邏輯
  - 在 updateUI 方法中，透過判斷 orderItems 是否為空來控制 emptyOrdersLabel 的顯示與隱藏。
  - 這樣，當使用者沒有訂單時，會顯示提示標籤；當使用者有訂單時，顯示訂單清單。


  3. 設計考慮
  - 載入使用者訂單：在使用者登入成功後，可以載入使用者的訂單資料並顯示在 UI 上。
  - 通知機制：透過 NotificationCenter 監聽訂單變化，即時更新 UI。
  - 資料持久化：將訂單資料儲存在 Firestore 中，確保使用者每次登入都能看到自己的歷史訂單。
 
  - 總結：
  - 透過在 FirebaseController 中新增 loadUserOrders 方法，可以在使用者登入後載入其歷史訂單，
    - 並在 OrderViewController 中展示這些訂單。保證了資料的即時性，也提供了良好的使用者體驗。
 */

/*
 import UIKit

 class OrderViewController: UIViewController {

     @IBOutlet weak var orderCollectionView: UICollectionView!
     
     var orders: [OrderItem] = []
     var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
     let layoutProvider = OrderLayoutProvider() // 假設你有一個 layout provider 來設置 collection view 的 layout
     
     enum Section: CaseIterable {
         case orderItems, phone, buyerName, pickupMethod
     }
     
     enum Item: Hashable {
         case orderItem(OrderItem), phone, buyerName, pickupMethod
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupCollectionView()
         configureDataSource()
         applyInitialSnapshot()
         NotificationCenter.default.addObserver(self, selector: #selector(updateOrders), name: .orderUpdated, object: nil)
     }
     
     deinit {
         NotificationCenter.default.removeObserver(self, name: .orderUpdated, object: nil)
     }
     
     private func setupCollectionView() {
         orderCollectionView.delegate = self
         orderCollectionView.collectionViewLayout = layoutProvider.createLayout()
         
         // 註冊 cell
         orderCollectionView.register(OrderItemCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier)
         orderCollectionView.register(PhoneCollectionViewCell.self, forCellWithReuseIdentifier: PhoneCollectionViewCell.reuseIdentifier)
         orderCollectionView.register(BuyerNameCollectionViewCell.self, forCellWithReuseIdentifier: BuyerNameCollectionViewCell.reuseIdentifier)
         orderCollectionView.register(PickupMethodCollectionViewCell.self, forCellWithReuseIdentifier: PickupMethodCollectionViewCell.reuseIdentifier)
     }
     
     @objc private func updateOrders() {
         orders = OrderController.shared.orderItems
         applySnapshot()
     }
     
     private func applySnapshot() {
         var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
         snapshot.appendSections(Section.allCases)
         
         snapshot.appendItems(orders.map { .orderItem($0) }, toSection: .orderItems)
         snapshot.appendItems([.phone], toSection: .phone)
         snapshot.appendItems([.buyerName], toSection: .buyerName)
         snapshot.appendItems([.pickupMethod], toSection: .pickupMethod)
         
         dataSource.apply(snapshot, animatingDifferences: true)
     }
     
     private func applyInitialSnapshot() {
         orders = OrderController.shared.orderItems
         applySnapshot()
     }
     
     private func configureDataSource() {
         dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: orderCollectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
             switch item {
             case .orderItem(let orderItem):
                 guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
                     fatalError("Cannot create OrderItemCollectionViewCell")
                 }
                 cell.configure(with: orderItem)
                 cell.stepperChanged = { [weak self] newQuantity in
                     self?.orders[indexPath.row].quantity = newQuantity
                     OrderController.shared.updateOrderItemQuantity(at: indexPath.row, to: newQuantity)
                     self?.applySnapshot()
                 }
                 return cell
                 
             case .phone:
                 guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhoneCollectionViewCell.reuseIdentifier, for: indexPath) as? PhoneCollectionViewCell else {
                     fatalError("Cannot create PhoneCollectionViewCell")
                 }
                 // 配置電話 cell
                 return cell
                 
             case .buyerName:
                 guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BuyerNameCollectionViewCell.reuseIdentifier, for: indexPath) as? BuyerNameCollectionViewCell else {
                     fatalError("Cannot create BuyerNameCollectionViewCell")
                 }
                 // 配置購買人姓名 cell
                 return cell
                 
             case .pickupMethod:
                 guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PickupMethodCollectionViewCell.reuseIdentifier, for: indexPath) as? PickupMethodCollectionViewCell else {
                     fatalError("Cannot create PickupMethodCollectionViewCell")
                 }
                 // 配置取件方式 cell
                 return cell
             }
         }
         
         orderCollectionView.delegate = self
     }
 }

 */



// MARK: - 一開始將歷史訂單及當前訂單放在一起的錯誤部分
/*
import UIKit

/// 處理訂單
class OrderViewController: UIViewController {

    var userDetails: UserDetails?

    @IBOutlet weak var orderCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loaduserOrders()
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrders), name: .orderUpdated, object: nil)
    }
    
    
    private func setupCollectionView() {
        orderCollectionView.delegate = self
        orderCollectionView.dataSource = self
        orderCollectionView.register(OrderItemCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier)
    }
    
    
    private func loaduserOrders() {
        FirebaseController.shared.getCurrentUserDetails { [weak self] result in
            switch result {
            case .success(let userDetails):
                self?.userDetails = userDetails
                self?.userDetails?.orders = OrderController.shared.orderItems   // 確保初始訂單從 OrderController 中獲取
                self?.orderCollectionView.reloadData()
                self?.updateTotalAmount()
            case .failure(let error):
                print("Error loading user details: \(error)")
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
            }
        }
    }
    
    
    private func updateTotalAmount() {
        let totalAmount = userDetails?.orders?.reduce(0) { $0 + $1.totalAmount } ?? 0
        print("總金額\(totalAmount)")  // 測試用
    }
    
    @objc private func updateOrders() {
        userDetails?.orders = OrderController.shared.orderItems
        orderCollectionView.reloadData()
        updateTotalAmount()
    }

}


// MARK: - Extension UICollectionViewDelegate、UICollectionViewDataSource
extension OrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let orderCount = userDetails?.orders?.count ?? 0
        if orderCount == 0 {
            // 顯示提示訊息
            let noOrdersLabel = UILabel()
            noOrdersLabel.text = "目前沒有商品在訂單中"
            noOrdersLabel.textAlignment = .center
            noOrdersLabel.frame = orderCollectionView.bounds
            orderCollectionView.backgroundView = noOrdersLabel
        } else {
            orderCollectionView.backgroundView = nil
        }
        return orderCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
            fatalError("Cannot create OrderItemCollectionViewCell")
        }
        
        if let orderItem = userDetails?.orders?[indexPath.row] {
            cell.configure(with: orderItem)
            cell.stepperChanged = { [weak self] newQuanity in
                self?.userDetails?.orders?[indexPath.row].quantity = newQuanity
                OrderController.shared.updateOrderItemQuantity(at: indexPath.row, to: newQuanity)
                self?.updateTotalAmount()
            }
        }
        
        return cell
    }
    
}
*/
