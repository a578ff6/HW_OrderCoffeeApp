//
//  OrderHistoryDetailHandler.swift.
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

// MARK: - OrderHistoryDetailHandler 重點筆記
/**
 ## OrderHistoryDetailHandler 重點筆記
 
 `1.職責分離：`

 - `OrderHistoryDetailHandler` 負責處理歷史訂單詳細頁的 UICollectionView 數據源和委託。
 - 使用 `OrderHistoryDetailDelegate` 來從外部（通常是 `OrderHistoryDetailViewController`）獲取訂單詳細資料，這樣可以保持 Handler 專注於 UI 層而不直接管理資料。
 
 `2.展開狀態管理：`

 - `OrderHistoryDetailSectionExpansionManager` 用於管理 Section 的展開與收起狀態，使 UI 操作邏輯和狀態管理邏輯分開，增加了可維護性。
 - 初次初始化時，默認讓 itemDetails 這個部分展開，這是為了提升用戶體驗。
 
 `3.手勢處理：`

 - 使用 `OrderHistoryDetailHeaderGestureHandler` 來管理 Header View 的點擊手勢。
 - 這樣設計可以在每次配置 Header 時為其添加手勢辨識器，實現用戶點擊展開或收起 Section 的功能。
 
 `4.UICollectionView 的數據源方法：`

 - `numberOfSections` 返回所有區域數量。
 - `numberOfItemsInSection` 根據 Section 的展開狀態來決定顯示的項目數量。例如，在 itemDetails 展開時顯示所有商品，不展開則顯示為 0。
 - `cellForItemAt` 根據 Section 類型設置不同的 Cell，實現顯示不同的內容。
 
 `5.視圖和數據的分離：`

 - 使用 `delegate?.getOrderHistoryDetail()` 來獲取 `orderDetail`，這樣的設計保持了數據來源的靈活性，使 Handler 不直接依賴於數據，而是通過委託取得資料。
 
 `6.區域（Section）定義：`

 - enum Section 定義了三個主要區域，分別是商品明細（itemDetails）、顧客資料（customerInfo）和訂單摘要（details）。
 
 `7.手勢添加與處理：`

 - 在 `viewForSupplementaryElementOfKind` 方法中為每個 Header 添加手勢，通過 headerGestureHandler 實現。這使得每次點擊 Header 都可以觸發展開或收起的操作。
 */


import UIKit

/// 負責管理歷史訂單詳細頁面的 CollectionView 的處理器
class OrderHistoryDetailHandler: NSObject {

    // MARK: - Properties

    /// 委託，用於從外部獲取歷史訂單的詳細資料
    weak var delegate: OrderHistoryDetailDelegate?
    
    /// 用於管理 Section 展開狀態的管理器
    private let expansionManager = OrderHistoryDetailSectionExpansionManager()
    
    /// 由外部設定，以確保 `delegate` 已經被初始化後再初始化手勢管理器
    private var headerGestureHandler: OrderHistoryDetailHeaderGestureHandler?
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// - Parameter delegate: 由外部設置的 `OrderHistoryDetailDelegate`，用於提供資料
    init(delegate: OrderHistoryDetailDelegate?) {
        super.init()
        self.delegate = delegate
        
        // 初始化手勢處理管理器，並將 `delegate` 傳入
        self.headerGestureHandler = OrderHistoryDetailHeaderGestureHandler(expansionManager: expansionManager, delegate: delegate)
        // 初次顯示時讓 itemDetails 展開
        expansionManager.toggleSection(Section.itemDetails.rawValue)
    }
    
    // MARK: - Section

    /// 定義各個區域（用於顯示歷史訂單項目的不同區塊內容）
    enum Section: Int, CaseIterable {
        case itemDetails     // 訂單內商品的詳細資料區域。
        case customerInfo    // 顧客基本資料（例如姓名、電話）的區域。
        case details         // 訂單摘要（例如訂單編號、總金額等）的區域。
    }

}

// MARK: - UICollectionViewDataSource
extension OrderHistoryDetailHandler: UICollectionViewDataSource {
    
    // MARK: - CollectionView DataSource Methods

    /// 設定顯示的區域數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    /// 設定每個區域中顯示的項目數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section), let orderDetail = delegate?.getOrderHistoryDetail() else {
            return 0
        }
        
        switch sectionType {
        case .itemDetails:
            // 根據是否展開狀態返回對應的 item 數量
            return expansionManager.isSectionExpanded(section) ?  orderDetail.orderItems.count : 0
        case .customerInfo, .details:
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
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderHistoryDetailSectionHeaderView.headerIdentifier, for: indexPath) as? OrderHistoryDetailSectionHeaderView else {
            fatalError("Cannot create OrderHistoryDetailSectionHeaderView")
        }
                
        switch sectionType {
        case .itemDetails:
            let isExpanded = expansionManager.isSectionExpanded(indexPath.section)
            headerView.configure(with: "Item Details", isExpanded: isExpanded, showArrow: true)
            headerGestureHandler?.addTapGesture(to: headerView, section: indexPath.section)          // 確保在設置 Header 時，添加手勢處理
            
        case .customerInfo:
            headerView.configure(with: "Customer Information", isExpanded: false, showArrow: false)
        case .details:
            headerView.configure(with: "Order Summary", isExpanded: false, showArrow: false)
        }
        
        return headerView
    }
    
    // MARK: - Cell Configuration Methods

    /// 根據區域配置相應的 Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section),
              let orderDetail = delegate?.getOrderHistoryDetail() else {
            fatalError("Invalid section")
        }

        switch sectionType {
        case .itemDetails:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderrHistoryDetailItemCell.reuseIdentifier, for: indexPath) as? OrderrHistoryDetailItemCell else {
                fatalError("Cannot create OrderrHistoryDetailItemCell")
            }
            let item = orderDetail.orderItems[indexPath.row]
            cell.configure(with: item)
            return cell
            
        case .customerInfo:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderHistoryDetailCustomerInfoCell.reuseIdentifier, for: indexPath) as? OrderHistoryDetailCustomerInfoCell else {
                fatalError("Cannot create OrderHistoryDetailCustomerInfoCell")
            }
            cell.configure(with: orderDetail.customerDetails)
            return cell

        case .details:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderrHistoryDetailCell.reuseIdentifier, for: indexPath) as? OrderrHistoryDetailCell else {
                fatalError("Cannot create OrderrHistoryDetailCell")
            }
            cell.configure(with: orderDetail)
            return cell
            
        }
    }
    
}

// MARK: - UICollectionViewDelegate
extension OrderHistoryDetailHandler: UICollectionViewDelegate {
}
