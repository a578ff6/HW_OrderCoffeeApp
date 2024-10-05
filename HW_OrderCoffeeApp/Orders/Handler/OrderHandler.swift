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
 
    & 訂單操作處理：
 
        *  使用委託（delegate）來處理訂單項目的修改與刪除操作。
            - orderModificationDelegate： 負責通知視圖控制器顯示詳細飲品頁面，並進行訂單項目修改。
            - orderActionDelegate： 負責通知視圖控制器進行訂單項目的刪除，並確保操作後能正確刷新訂單列表。
 
    & 主要流程：
        - 資料配置： 透過 configureDataSource 配置 UICollectionView 的資料源。
        - 更新快照： 透過 updateOrders 方法更新訂單列表。
        - 使用者交互： 使用委託通知 OrderViewController 處理具體的訂單修改或刪除操作。

 & 主要功能概述：
        - 視圖邏輯與資料源分離： OrderHandler 專注於訂單資料的展示和邏輯處理，與視圖控制器的職責分離。
        - 使用委託來處理互動： 使用兩個不同的委託（orderModificationDelegate 和 orderActionDelegate）來確保訂單的修改與刪除邏輯可以由 OrderViewController 實現。
 */

import UIKit

/// OrderHandler 負責管理訂單視圖的邏輯與資料源
class OrderHandler: NSObject {
    
    // MARK: - Properties

    private var collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    /// 使用委託來處理`修改訂單項目`
    weak var orderModificationDelegate: OrderModificationDelegate?
    /// 使用委託來處理`刪除訂單項目`
    weak var orderActionDelegate: OrderActionDelegate?
    
    // MARK: - Section & Item
    
    enum Section: Int, CaseIterable {
        case orderItems, summary
    }
    
    enum Item: Hashable {
        case orderItem(OrderItem), summary(totalAmount: Int, totalPrepTime: Int), noOrders
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
            }
        }
        
        dataSource.supplementaryViewProvider = createSupplementaryViewProvider()
    }
    
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
                }
                return headerView
            }
            return nil
        }
    }
    
    // MARK: - Update Orders
    
    /// 更新訂單列表，並刷新顯示資料快照
    func updateOrders() {
        var snapshot = createSnapshot()
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    /// 建立訂單快照，用於更新資料源
    ///
    /// - 加載訂單項目，並根據當前訂單狀態更新視圖。
    /// - 若訂單為空，顯示 noOrders ，否則顯示所有訂單項目。
    /// - 計算總金額和總準備時間並顯示。
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)

        let orderItems = OrderController.shared.orderItems.map { Item.orderItem($0) }

        if orderItems.isEmpty {
            snapshot.appendItems([.noOrders], toSection: .orderItems)
        } else {
            snapshot.appendItems(orderItems, toSection: .orderItems)
        }

        let summaryItem = createSummaryItem()
        snapshot.appendItems([summaryItem], toSection: .summary)

        return snapshot
    }
    
    /// 建立訂單總結項目（包含`總金額`與`總準備時間`）
    private func createSummaryItem() -> Item {
        let totalAmount = OrderController.shared.calculateTotalAmount()
        let totalPrepTime = OrderController.shared.calculateTotalPrepTime()
        return .summary(totalAmount: totalAmount, totalPrepTime: totalPrepTime)
    }
    
}

// MARK: - UICollectionViewDelegate
extension OrderHandler: UICollectionViewDelegate {
    
    /// 處理選擇訂單項目的操作
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell at index \(indexPath.row) was selected.")   // 測試 cell 點擊
        /// 檢查是否有訂單
        guard OrderController.shared.orderItems.count > 0 else { return }
        let orderItem = OrderController.shared.orderItems[indexPath.row]
        
        /// 通知委託處理選中的訂單項目。若委託存在，則由委託實現訂單項目的導航邏輯，顯示`飲品詳細頁面`。
        guard let delegate = orderModificationDelegate else { return }
        delegate.modifyOrderItem(orderItem, withID: orderItem.id)
    }
    
}
