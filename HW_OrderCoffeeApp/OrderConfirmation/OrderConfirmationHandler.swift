//
//  OrderConfirmationHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

// MARK: - OrderConfirmationHandler 重點筆記
/**
 ## OrderConfirmationHandler 重點筆記
 
 `* 功能概述`
    - `OrderConfirmationHandler` 主要用於管理訂單確認頁面上各區域的顯示資料來源及顯示邏輯。它實現了 UICollectionViewDataSource 和 UICollectionViewDelegate，負責管理 UICollectionView 內的各個區域和對應的資料。

 `* 重點`
 
 `1.委託模式 (delegate)：`
    - 使用委託模式 (`OrderConfirmationHandlerDelegate`) 來提供訂單資料。
    - 透過委託方法從外部獲取訂單資料，以保持 `OrderConfirmationHandler` 的通用性和靈活性。

` 2. Section 部分：`
    - checkMark：顯示訂單確認的勾選圖示。
    - message：訂單確認的訊息提示。
    - customerInfo：顯示顧客的基本資料。
    - itemDetails：顯示訂單內各個商品的詳細資料。
    - details：顯示訂單的摘要（例如訂單編號、總金額等）。
    - closeButton：顯示返回按鈕，讓用戶返回主頁面。
 
 `3. 區域數據源的管理 (UICollectionViewDataSource)：`
    - 根據不同的 Section 來決定每個區域需要顯示的項目數量。
    - 對於商品細節區域 (`itemDetails`)，顯示的項目數量由訂單的商品數量決定。
    - 對其他區域來說，通常只有一個對應的項目。
 
 `4. Cell 的配置 (UICollectionViewCell)：`

`* 提供多個私有的配置方法，用來設置不同區域內的 UICollectionViewCell：`
    - configureCheckmarkCell()：設置訂單確認成功的勾選圖示。
    - configureMessageCell()：設置訂單確認訊息提示。
    - configureCustomerInfoCell()：配置顧客的基本資料，例如姓名和電話。
    - configureItemDetailsCell()：設置每個商品的詳細信息，包括名稱、數量等。
    - configureOrderDetailsCell()：設置訂單摘要，例如總金額和準備時間。
    - configureCloseButtonCell()：配置關閉按鈕，點擊後執行返回操作。
 
` 5. 委託的 Cell 內容配置：`
    - 對於顧客資料、訂單商品等，需要透過委託 (delegate?.getOrder()) 來獲取最新的訂單資料，再配置對應的 Cell。
    - 這樣的設計能夠使得 `OrderConfirmationHandler` 較為輕量，只需關注視圖配置，具體數據由外部提供。
 
` 6. 委託模式處理按鈕事件：`
    - 關閉按鈕的點擊事件由委託處理，`configureCloseButtonCell() `中配置 `onCloseButtonTapped`，讓 `OrderConfirmationHandlerDelegate` 的方法負責關閉操作。
 */


import UIKit

/// 負責處理訂單確認頁面的資料顯示
/// - 主要用途：管理訂單確認畫面上各個區域的資料來源及顯示邏輯。
class OrderConfirmationHandler: NSObject {

    // MARK: - Properties

    /// 委託，用於提供訂單資料
    weak var delegate: OrderConfirmationHandlerDelegate?
    
    // MARK: - Section
    
    /// 定義各個區域（用於顯示不同的訂單確認內容）
    enum Section: Int, CaseIterable {
        case checkMark       // 勾選圖示區域，表示訂單確認成功。
        case message         // 訂單確認的訊息提示區域。
        case itemDetails     // 訂單內商品的詳細資料區域。
        case customerInfo    // 顧客基本資料（例如姓名、電話）的區域。
        case details         // 訂單摘要（例如訂單編號、總金額等）的區域。
        case closeButton     // 關閉按鈕，讓用戶返回上一頁面。
    }
    
}

// MARK: - UICollectionViewDataSource
extension OrderConfirmationHandler: UICollectionViewDataSource {
    
    /// 設定顯示的區域數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    /// 設定每個區域中顯示的項目數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else {
            return 0
        }
        
        switch sectionType {
        case .itemDetails:
            // 如果是 itemDetails 區域，根據 delegate 中的 orderItem 資料數量返回對應數量
            return delegate?.getOrder()?.orderItems.count ?? 0
        default:
            return 1
        }
    }
    
    /// 配置每個區域的標題
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Invalid supplementary element kind")
        }
        
        guard let sectionType = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section")
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderConfirmationSectionHeaderView.headerIdentifier, for: indexPath) as? OrderConfirmationSectionHeaderView else {
            fatalError("Cannot create OrderConfirmationSectionHeaderView")
        }
        
        switch sectionType {
        case .itemDetails:
            headerView.configure(with: "Item Details")
        case .customerInfo:
            headerView.configure(with: "Customer Information")
        case .details:
            headerView.configure(with: "Order Summary")
        default:
            break
        }
        
        return headerView
    }

    /// 根據區域配置相應的 Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section")
        }
        
        switch sectionType {
        case .checkMark:
            return configureCheckmarkCell(for: collectionView, at: indexPath)
            
        case .message:
            return configureMessageCell(for: collectionView, at: indexPath)
            
        case .itemDetails:
            return configureItemDetailsCell(for: collectionView, at: indexPath)
            
        case .customerInfo:
            return configureCustomerInfoCell(for: collectionView, at: indexPath)
            
        case .details:
            return configureOrderDetailsCell(for: collectionView, at: indexPath)
            
        case .closeButton:
            return configureCloseButtonCell(for: collectionView, at: indexPath)
        }
    }
    
    // MARK: - Private Cell Configuration Methods
    
    /// 配置 OrderConfirmationCheckmarkCell
    private func configureCheckmarkCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderConfirmationCheckmarkCell.reuseIdentifier, for: indexPath) as? OrderConfirmationCheckmarkCell else {
            fatalError("Cannot create OrderConfirmationCheckmarkCell")
        }
        return cell
    }
    
    /// 配置 OrderConfirmationMessageCell
    private func configureMessageCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderConfirmationMessageCell.reuseIdentifier, for: indexPath) as? OrderConfirmationMessageCell else {
            fatalError("Cannot create OrderConfirmationMessageCell")
        }
        return cell
    }
    
    /// 配置 OrderrConfirmationItemDetailsCell
    private func configureItemDetailsCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderrConfirmationItemDetailsCell.reuseIdentifier, for: indexPath) as? OrderrConfirmationItemDetailsCell else {
            fatalError("Cannot create OrderrConfirmationItemDetailsCell")
        }
        
        // 根據 indexPath 配置對應的訂單項目資料
        if let orderItems = delegate?.getOrder()?.orderItems {
            let orderItem = orderItems[indexPath.item]
            cell.configure(with: orderItem)
        }
        return cell
    }
    
    /// 配置 OrderConfirmationCustomerInfoCell
    private func configureCustomerInfoCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderConfirmationCustomerInfoCell.reuseIdentifier, for: indexPath) as? OrderConfirmationCustomerInfoCell else {
            fatalError("Cannot create OrderConfirmationCustomerInfoCell")
        }
        
        // 獲取訂單資料並配置 Cell
        if let customerDetails = delegate?.getOrder()?.customerDetails {
            cell.configure(with: customerDetails)
        }
        return cell
    }
    
    /// 配置 OrderrConfirmationDetailsCell
    private func configureOrderDetailsCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderrConfirmationDetailsCell.reuseIdentifier, for: indexPath) as? OrderrConfirmationDetailsCell else {
            fatalError("Cannot create OrderrConfirmationDetailsCell")
        }
        
        // 獲取訂單資料並配置 Cell
        if let order = delegate?.getOrder() {
            cell.configure(with: order)
        }
        return cell
    }
    
    /// 配置 OrderrConfirmationCloseButtonCell
    private func configureCloseButtonCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderrConfirmationCloseButtonCell.reuseIdentifier, for: indexPath) as? OrderrConfirmationCloseButtonCell else {
            fatalError("Cannot create OrderrConfirmationCloseButtonCell")
        }
        
        // 配置 close button 的 action
        cell.onCloseButtonTapped = {
            self.delegate?.didTapCloseButton()
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension OrderConfirmationHandler: UICollectionViewDelegate {
    
}
