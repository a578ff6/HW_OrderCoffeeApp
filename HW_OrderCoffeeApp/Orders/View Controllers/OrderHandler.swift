//
//  OrderHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/4.
//

import UIKit

/// OrderHandler 負責管理訂單視圖的邏輯與資料源
class OrderHandler: NSObject {
    
    // MARK: - Properties

    private var collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<OrderViewController.Section,

}

// MARK: - UICollectionViewDelegate

extension OrderHandler: UICollectionViewDelegate {
    
}


/*
 import UIKit

 /// OrderHandler 負責管理訂單視圖的邏輯與資料源
 class OrderHandler: NSObject {
     
     // MARK: - Properties
     
     private var collectionView: UICollectionView
     private var dataSource: UICollectionViewDiffableDataSource<OrderViewController.Section, OrderViewController.Item>!
     
     // MARK: - Initializer
     
     init(collectionView: UICollectionView) {
         self.collectionView = collectionView
         super.init()
         setupCollectionView()
         configureDataSource()
     }
     
     // MARK: - Setup Methods
     
     /// 設置 CollectionView 的代理
     private func setupCollectionView() {
         collectionView.delegate = self
     }
     
     /// 配置 DataSource 並註冊自定義單元格
     private func configureDataSource() {
         dataSource = UICollectionViewDiffableDataSource<OrderViewController.Section, OrderViewController.Item>(collectionView: collectionView) { (collectionView, indexPath, item) in
             switch item {
             case .orderItem(let orderItem):
                 guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
                     fatalError("Cannot create OrderItemCollectionViewCell")
                 }
                 cell.configure(with: orderItem)
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
         // 設置 SupplementaryViewProvider（如標題）
         dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
             guard kind == UICollectionView.elementKindSectionHeader else { return nil }
             guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderSectionHeaderView.headerIdentifier, for: indexPath) as? OrderSectionHeaderView else {
                 fatalError("Cannot create OrderSectionHeaderView")
             }
             let section = OrderViewController.Section(rawValue: indexPath.section)!
             switch section {
             case .orderItems:
                 headerView.configure(with: "訂單飲品項目")
             case .summary:
                 headerView.configure(with: "訂單詳情")
             }
             return headerView
         }
     }
     
     /// 更新訂單內容
     func updateOrders(orderItems: [OrderItem], totalAmount: Int, totalPrepTime: Int) {
         var snapshot = NSDiffableDataSourceSnapshot<OrderViewController.Section, OrderViewController.Item>()
         snapshot.appendSections(OrderViewController.Section.allCases)
         
         if orderItems.isEmpty {
             snapshot.appendItems([.noOrders], toSection: .orderItems)
         } else {
             snapshot.appendItems(orderItems.map { .orderItem($0) }, toSection: .orderItems)
         }
         
         snapshot.appendItems([.summary(totalAmount: totalAmount, totalPrepTime: totalPrepTime)], toSection: .summary)
         dataSource.apply(snapshot, animatingDifferences: true)
     }
 }

 // MARK: - UICollectionViewDelegate
 extension OrderHandler: UICollectionViewDelegate {
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         print("Item at index \(indexPath.row) selected")
         // 處理點擊事件，例如跳轉到詳細頁面
     }
 }

 */
