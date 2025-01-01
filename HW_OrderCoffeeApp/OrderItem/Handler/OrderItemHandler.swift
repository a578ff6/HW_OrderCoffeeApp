//
//  OrderItemHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/4.
//

// MARK: - OrderItemHandler 筆記
/**
 
 ## OrderItemHandler 筆記


 `* What`

 - `OrderItemHandler` 是專門為 `OrderItemViewController` 中的 `UICollectionView` 設計的邏輯處理器，主要負責以下功能：

 `1. 數據源管理：`
 
    - 使用 `UICollectionViewDiffableDataSource` 管理數據，確保界面與數據的一致性。
    - 支援多個區段（如訂單項目、總結、操作按鈕）的展示。

 `2. 交互邏輯：`
 
    - 處理用戶在 `UICollectionView` 中的交互（如點擊、滑動）。
    - 通過委託模式，將操作結果（如刪除訂單、清空訂單）通知 `OrderItemHandlerDelegate`。

 `3. 界面更新：`
 
    - 根據訂單數據變更動態刷新視圖，支持占位內容（如無訂單項目時顯示的空狀態）。

 ----------------

 `* Why`

 1. 責任分離：
 
    - 集中處理與 `UICollectionView` 相關的邏輯，讓控制器專注於高層次的功能整合。

 2. 提升性能：
 
    - 使用 `DiffableDataSource` 確保數據更新的高效性和動畫效果，減少不必要的刷新操作。

 3. 增強可讀性與可維護性：
 
    - 透過清晰的數據分段與項目類型，讓界面更新和數據處理更加直觀。
    - 使用委託模式將操作結果通知控制器，避免代碼耦合。

 4. 可擴展性：
 
    - 支援多種不同類型的區段（如訂單項目、摘要、按鈕），便於未來功能的擴展。

 ----------------

 `* How`


 `1. 配置數據源與項目類型`

 - 數據分段：
   - 使用 `Section` 定義不同的區段（`orderItems`, `summary`, `actionButtons`）。
   - 每個區段中的內容由 `Item` 定義，包括具體的訂單項目、摘要、占位項目或操作按鈕。

 - 數據源配置：
   - 通過 `configureDataSource` 設置 `DiffableDataSource`。
   - 根據項目類型動態返回對應的自定義單元格。
   - 支援使用輔助視圖（如區段標題）。

 ---

 `2. 處理視圖更新`

 - 更新數據邏輯：
   - 使用 `updateOrders` 方法根據當前的訂單數據動態生成 `snapshot`，並應用至 `DiffableDataSource`。
   - 支援以下場景：
     - 當訂單為空時，顯示 `.noOrderItem` 作為占位項目。
     - 當有訂單時，顯示訂單項目及摘要。

 - 按鈕狀態通知：
   - 當數據更新完成後，透過 `orderItemHandlerDelegate` 通知控制器更新按鈕的啟用狀態。

 ---

 `3. 處理用戶交互`

 - 點擊訂單項目：
   - 通過 `UICollectionViewDelegate` 的 `didSelectItemAt`，檢測用戶選擇的項目，並將操作委派給控制器處理。

 - 操作按鈕邏輯：
   - 在按鈕項目中，提供閉包回調（如清空訂單或進入顧客資料頁），通知控制器執行具體邏輯。

 ---

 `4. 模組化設計的細節`

 - 數據與視圖分離：
   - 訂單數據的管理交由 `OrderItemManager`，而 `OrderItemHandler` 僅負責將數據映射到視圖。

 - 委託模式的應用：
   - 使用 `OrderItemHandlerDelegate` 確保控制器能對用戶交互事件作出響應，例如刪除訂單或導航。

 */


// MARK: - 問題「OrderItemSummaryCollectionViewCell 和 OrderItemActionButtonsCell 觸發點擊事件」

/**
 &. 問題
    - 點擊 OrderItemSummaryCollectionViewCell 和 OrderItemActionButtonsCell 時，原本不應該觸發的點擊事件卻被執行，導致顯示「Cell at index 0 was selected」的訊息，甚至進入了不應該的訂單項目詳細頁面。
    - 實際上，只有 OrderItemCollectionViewCell（訂單項目 Cell）應該能夠被點擊，並進入詳細頁面。
 
 &. 問題的產生
    - 原本在 UICollectionViewDelegate 的方法 `collectionView(_:didSelectItemAt:) `中，沒有針對不同區段的 Cell 進行判斷，導致所有區段的 Cell 都觸發了點擊事件。
    - 因此，當用戶點擊任何 UICollectionView 的 Cell（包括 OrderItemSummaryCollectionViewCell 和 OrderItemActionButtonsCell）時，都會進入同樣的點擊處理邏輯，並執行不應該有的行為。
 
 &. 解決方式
 
    * 增加區段判斷：
        - 在 didSelectItemAt 方法中，使用 `Section(rawValue: indexPath.section) `來判斷當前點擊的 Cell 所屬的區段。
        - 只處理 .`orderItems` 區段的點擊：當點擊的 Cell 屬於 .`orderItems` 區段時，才執行進入訂單項目詳細頁面的操作。
        - 忽略其他區段：如果是 .summary 或 .actionButtons 區段，直接返回，不進行任何處理。
 */


// MARK: - 測試 OrderItemManager.shared

import UIKit

/// `OrderItemHandler` 負責管理訂單視圖的邏輯與資料源。
///
/// ### 功能說明
/// - 管理 `UICollectionView` 的數據源與委派，負責訂單項目的展示與互動邏輯。
/// - 通過 `UICollectionViewDiffableDataSource` 動態更新訂單視圖，確保資料與界面一致。
/// - 通過委託模式，將刪除訂單、清空訂單等操作通知給 `OrderItemHandlerDelegate`。
///
/// ### 模組化設計
/// - 數據源管理： 使用 `DiffableDataSource` 確保高效且一致的資料更新。
/// - 交互處理： 處理用戶操作，例如點擊訂單項目或觸發按鈕回調。
/// - 職責分離： 將業務邏輯（如訂單計算）交由 `OrderItemManager` 處理，確保單一職責原則。
class OrderItemHandler: NSObject {
    
    // MARK: - Properties
    
    /// 用於展示訂單的 `UICollectionView`
    private var collectionView: UICollectionView
    
    /// 管理數據源的 `DiffableDataSource`
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    /// 處理訂單操作與交互的委託
    weak var orderItemHandlerDelegate: OrderItemHandlerDelegate?
    
    // MARK: - Section & Item
    
    /// 定義訂單視圖的 Section 類型
    ///
    /// - orderItems: 訂單項目列表。
    /// - summary: 訂單的總金額與準備時間摘要。
    /// - actionButtons: 操作按鈕（例如清空訂單或繼續下一步）。
    enum Section: Int, CaseIterable {
        case orderItems
        case summary
        case actionButtons
    }
    
    /// 定義訂單視圖中的 Item 類型
    ///
    /// - orderItem: 單個訂單項目。
    /// - summary: 訂單總結，包括總金額與總準備時間。
    /// - noOrderItem: 當訂單為空時顯示的占位項目。
    /// - actionButtons: 操作按鈕項目。
    enum Item: Hashable {
        case orderItem(OrderItem)
        case summary(totalAmount: Int, totalPrepTime: Int)
        case noOrderItem
        case actionButtons
    }
    
    // MARK: - Initializer
    
    /// 初始化 `OrderItemHandler`
    /// - Parameter collectionView: 用於展示訂單的 `UICollectionView`
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        configureDataSource()
    }
    
    // MARK: - Setup Methods
    
    /// 配置 `DiffableDataSource` 並註冊自定義單元格。
    ///
    /// 根據不同的 `Item` 類型，返回對應的自定義單元格。
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) in
            switch item {
            case .orderItem(let orderItem):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
                    fatalError("Cannot create OrderItemCollectionViewCell")
                }
                cell.configure(with: orderItem)
                cell.deleteAction = { self.orderItemHandlerDelegate?.deleteOrderItem(orderItem)} // 通知委託刪除訂單項目
                return cell
                
            case .summary(totalAmount: let totalAmount, totalPrepTime: let totalPrepTime):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemSummaryCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemSummaryCollectionViewCell else {
                    fatalError("Cannot create OrderItemSummaryCollectionViewCell")
                }
                cell.configure(totalAmount: totalAmount, totalPrepTime: totalPrepTime)
                return cell
                
            case .noOrderItem:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoOrderItemViewCell.reuseIdentifier, for: indexPath) as? NoOrderItemViewCell else {
                    fatalError("Cannot create NoOrderItemViewCell")
                }
                return cell
                
            case .actionButtons:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemActionButtonsCell.reuseIdentifier, for: indexPath) as? OrderItemActionButtonsCell else {
                    fatalError("Cannot create OrderItemActionButtonsCell")
                }
                cell.onProceedButtonTapped = { self.orderItemHandlerDelegate?.proceedToCustomerDetails() }  // 進入顧客資料頁
                cell.onClearButtonTapped = { self.orderItemHandlerDelegate?.clearAllOrderItems() }          // 清空所有訂單
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = createSupplementaryViewProvider()
    }
    
    // MARK: - Supplementary View Setup
    
    /// 建立輔助視圖提供者，用於設置各區段的標題。
    ///
    /// - Returns: 提供輔助視圖的閉包。
    private func createSupplementaryViewProvider() -> UICollectionViewDiffableDataSource<Section, Item>.SupplementaryViewProvider {
        return { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderItemSectionHeaderView.headerIdentifier, for: indexPath) as? OrderItemSectionHeaderView else {
                    fatalError("Cannot create OrderItemSectionHeaderView")
                }
                let section = Section(rawValue: indexPath.section)!
                switch section {
                case .orderItems:
                    headerView.configure(with: "Order Items")
                case .summary:
                    headerView.configure(with: "Order Summary")
                case .actionButtons:
                    return nil
                }
                return headerView
            }
            return nil
        }
    }
    
    // MARK: - Update Orders
    
    /// 更新訂單數據並刷新 `UICollectionView`
    ///
    /// - Parameters:
    ///   - orderItems: 當前的訂單項目列表。
    ///   - totalAmount: 訂單的總金額。
    ///   - totalPrepTime: 訂單的總準備時間。
    ///
    /// ### 功能描述
    /// - 透過 `DiffableDataSource` 將新數據應用於 `UICollectionView`，確保資料與界面一致。
    /// - 當 `orderItems` 為空時，顯示占位項目 (`.noOrderItem`)。
    /// - 當有訂單數據時，顯示具體的訂單內容。
    /// - 包含總結區 (`.summary`) 顯示金額與準備時間，以及操作按鈕區 (`.actionButtons`)。
    ///
    /// ### 更新過程
    /// 1. 根據 `orderItems` 的內容生成 `items`：
    ///    - 如果為空，插入占位項目 (`.noOrderItem`)。
    ///    - 如果不為空，將每個訂單項目映射為 `.orderItem`。
    /// 2. 為每個區段（`orderItems`、`summary`、`actionButtons`）添加對應的項目到 `snapshot`。
    /// 3. 應用 `snapshot` 至 `dataSource`，並自動計算動畫差異。
    /// 4. 通知委託更新按鈕狀態（如是否禁用清空按鈕）。
    ///
    /// ### 使用場景
    /// - 當訂單列表發生變化時（例如新增、刪除或清空訂單），使用此方法更新界面。
    func updateOrders(with orderItems: [OrderItem], totalAmount: Int, totalPrepTime: Int) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        
        // 添加訂單項目
        let items: [Item] = orderItems.isEmpty ? [.noOrderItem] : orderItems.map { .orderItem($0) }
        snapshot.appendItems(items, toSection: .orderItems)
        
        // 添加總結區內容
        snapshot.appendItems([.summary(totalAmount: totalAmount, totalPrepTime: totalPrepTime)], toSection: .summary)
        
        // 添加操作按鈕
        snapshot.appendItems([.actionButtons], toSection: .actionButtons)
        
        // 應用更新到 DataSource
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            let isOrderEmpty = orderItems.isEmpty
            self?.orderItemHandlerDelegate?.orderItemHandlerDidUpdateButtons(isOrderEmpty: isOrderEmpty)
        }
    }
    
}

// MARK: - UICollectionViewDelegate
extension OrderItemHandler: UICollectionViewDelegate {
    
    /// 處理選擇訂單項目的操作
    ///
    /// - 當用戶在 `orderItems` 區段點擊某個項目時，
    ///   將觸發此方法進行對應邏輯處理，例如導航到訂單編輯頁面。
    /// - 此方法確保只有在有效的索引範圍內點擊時才會執行後續邏輯。
    ///
    /// - Parameters:
    ///   - collectionView: 當前的 `UICollectionView`。
    ///   - indexPath: 被點擊的項目的索引位置。
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// 檢查點擊的區段是否為 `orderItems`
        guard let section = Section(rawValue: indexPath.section), section == .orderItems else { return }
        
        /// 確保 `indexPath.row` 不超出 `orderItems` 的有效範圍。
        guard let orderItems = orderItemHandlerDelegate?.getOrderItems(),
              indexPath.row < orderItems.count else { return }
        
        /// 根據選中的 `orderItem`，通知委託進行頁面導航。
        let orderItem = orderItems[indexPath.row]
        orderItemHandlerDelegate?.navigateToEditOrderItemView(with: orderItem)
    }
    
}
