//
//  OrderHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/4.
//

/*
 ## OrderHandler：

    & 功能：
        - 負責管理訂單視圖的邏輯與資料源，包括顯示訂單項目、訂單總結等內容，並與 UICollectionView 進行互動。
 
    & 資料加載與展示流程：

        1. 初始化與配置：
            - 在初始化時，傳入 UICollectionView 並設置 dataSource 和 delegate。
            - 使用 configureDataSource 方法來配置 UICollectionView 的資料源。
 
        2. 訂單項目的顯示：
            - 根據不同 Section，分別顯示訂單飲品、訂單總結或無訂單情況。
            - 每個訂單項目透過 OrderItemCollectionViewCell 來顯示，包含刪除操作的閉包邏輯。
 
        3.更新訂單列表：
            - 使用 updateOrders 方法更新訂單的快照，包括訂單項目與訂單總結的展示。
            - 在更新完快照後，確保按鈕狀態會依照最新訂單狀況進行更新（例如：清空訂單按鈕的啟用狀態）。
 
    & 訂單操作處理：
 
        *  使用委託（delegate）來處理訂單項目的修改與刪除操作。
            - orderViewInteractionDelegate： 負責通知視圖控制器進行訂單項目的修改（顯示飲品詳細頁面）或是進入到顧客資料頁面。
            - orderActionDelegate： 負責通知視圖控制器進行訂單項目的刪除和清空操作，並確保操作後能正確刷新訂單列表。
 
    & 主要流程：
        - 資料配置： 透過 configureDataSource 配置 UICollectionView 的資料源。
        - 更新快照： 透過 updateOrders 方法更新訂單列表，並在資料更新後立即調整按鈕的狀態。
        - 使用者交互： 使用委託通知 OrderViewController 處理具體的訂單修改或刪除操作。

 & 主要功能概述：
        - 視圖邏輯與資料源分離： OrderHandler 專注於訂單資料的展示和邏輯處理，與視圖控制器的職責分離。
        - 使用委託來處理互動： 使用兩個不同的委託（orderViewInteractionDelegate 和 orderActionDelegate）來確保訂單的修改與刪除邏輯可以由 OrderViewController 實現。
 */

import UIKit

/// OrderHandler 負責管理訂單視圖的邏輯與資料源
class OrderHandler: NSObject {
    
    // MARK: - Properties

    private var collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    /// 使用委託來處理`修改訂單項目`
    weak var orderViewInteractionDelegate: OrderViewInteractionDelegate?
    /// 使用委託來處理`刪除訂單項目`
    weak var orderActionDelegate: OrderActionDelegate?
    
    // MARK: - Section & Item
    
    /// 定義訂單視圖的 Section 類型
    enum Section: Int, CaseIterable {
        case orderItems, summary, actionButtons
    }
    
    /// 定義訂單視圖中的 Item 類型
    enum Item: Hashable {
        case orderItem(OrderItem), summary(totalAmount: Int, totalPrepTime: Int), noOrders, actionButtons
    }
    
    // MARK: - Initializer
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        configureDataSource()
    }
    
    // MARK: - Setup Methods
    
    /// 配置 DataSource 並註冊自定義單元格
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) in
            switch item {
            case .orderItem(let orderItem):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
                    fatalError("Cannot create OrderItemCollectionViewCell")
                }
                cell.configure(with: orderItem)
                cell.deleteAction = { [weak self] in
                    guard let self = self else { return }
                    self.orderActionDelegate?.deleteOrderItem(orderItem)     // 呼叫委託來刪除訂單項目
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
            
            case .actionButtons:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderActionButtonsCell.reuseIdentifier, for: indexPath) as? OrderActionButtonsCell else {
                    fatalError("Cannot create OrderActionButtonsCell")
                }
            
                // 利用委託處理「進入顧客資料」視圖控制器
                cell.onProceedButtonTapped = { [weak self] in
                    guard let self = self else { return }
                    self.orderViewInteractionDelegate?.proceedToCustomerDetails()
                }
                
                /// 呼叫委託來清空所有訂單項目
                cell.onClearButtonTapped = { [weak self] in
                    guard let self = self else { return }
                    self.orderActionDelegate?.clearAllOrderItems()
                }
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = createSupplementaryViewProvider()
    }
    
    // MARK: - Supplementary View Setup

    /// 建立輔助視圖提供者，用於設定各區段的標題
    private func createSupplementaryViewProvider() -> UICollectionViewDiffableDataSource<Section, Item>.SupplementaryViewProvider {
        return { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderSectionHeaderView.headerIdentifier, for: indexPath) as? OrderSectionHeaderView else {
                    fatalError("Cannot create OrderSectionHeaderView")
                }
                let section = Section(rawValue: indexPath.section)!
                switch section {
                case .orderItems:
                    headerView.configure(with: "Order Items")
                case .summary:
                    headerView.configure(with: "Order Summary")
                case .actionButtons:
                    return nil                                  // actionButtons 區段不設置 header
                }
                return headerView
            }
            return nil
        }
    }
    
    // MARK: - Update Orders
    
    /// 更新訂單列表，並刷新顯示資料快照，並更新按鈕狀態。
    func updateOrders() {
        var snapshot = createSnapshot()        
        dataSource.apply(snapshot, animatingDifferences: true) {
            /// 將`清空按鈕狀態`的更新放在快照應用之後，確保每次更新訂單視圖後根據最新資料更新按鈕狀態
            self.refreshActionButtonsState()
        }
    }
    
    /// 建立訂單快照，用於更新資料源
    ///
    /// - 加載訂單項目，並根據當前訂單狀態更新視圖。
    /// - 若訂單為空，顯示 noOrders ，否則顯示所有訂單項目。
    /// - 計算總金額和總準備時間並顯示。
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)

        /// 添加訂單項目
        let orderItems = OrderItemManager.shared.orderItems.map { Item.orderItem($0) }
        
        if orderItems.isEmpty {
            snapshot.appendItems([.noOrders], toSection: .orderItems)
        } else {
            snapshot.appendItems(orderItems, toSection: .orderItems)
        }

        // 添加訂單總結
        let summaryItem = createSummaryItem()
        snapshot.appendItems([summaryItem], toSection: .summary)
        
        // 添加 actionButtons 按鈕到 actionButtons 區段
        snapshot.appendItems([.actionButtons], toSection: .actionButtons)

        return snapshot
    }
    
    /// 建立訂單總結項目（包含`總金額`與`總準備時間`）
    private func createSummaryItem() -> Item {
        let totalAmount = OrderItemManager.shared.calculateTotalAmount()
        let totalPrepTime = OrderItemManager.shared.calculateTotalPrepTime()
        return .summary(totalAmount: totalAmount, totalPrepTime: totalPrepTime)
    }
    
    // MARK: - Button State Management

    /// 更新`清空按鈕`和`繼續按鈕`的啟用狀態
    func refreshActionButtonsState() {
        guard let actionButtonsCell = collectionView.cellForItem(at: IndexPath(item: 0, section: Section.actionButtons.rawValue)) as? OrderActionButtonsCell else {
            print("OrderActionButtonsCell 還沒準備好")
            return
        }
        let isOrderItemsEmpty = OrderItemManager.shared.orderItems.isEmpty
        print("更新清空按鈕狀態，當前訂單是否為空: \(isOrderItemsEmpty)")  // 觀察訂單狀態與按鈕的變化
        
        // 更新所有按鈕的狀態
        actionButtonsCell.updateActionButtonsState(isOrderEmpty: isOrderItemsEmpty)
    }
    
}

// MARK: - UICollectionViewDelegate
extension OrderHandler: UICollectionViewDelegate {
    
    /// 處理選擇訂單項目的操作
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell at index \(indexPath.row) was selected.")   // 測試 cell 點擊
        /// 檢查是否有訂單
        guard OrderItemManager.shared.orderItems.count > 0 else { return }
        let orderItem = OrderItemManager.shared.orderItems[indexPath.row]
        
        /// 通知委託處理選中的訂單項目。若委託存在，則由委託實現訂單項目的導航邏輯，顯示`飲品詳細頁面`。
        guard let delegate = orderViewInteractionDelegate else { return }
        delegate.modifyOrderItemToDetailViewDetail(orderItem, withID: orderItem.id)
    }
    
}
