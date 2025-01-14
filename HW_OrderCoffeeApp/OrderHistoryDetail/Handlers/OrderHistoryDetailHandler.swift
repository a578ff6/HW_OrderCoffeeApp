//
//  OrderHistoryDetailHandler.swift.
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/12.
//

// MARK: - OrderHistoryDetailHandler 筆記
/**
 
 ## OrderHistoryDetailHandler 筆記

 
 `* What`
 
 - `OrderHistoryDetailHandler` 是專為管理歷史訂單詳細頁面 `UICollectionView` 的處理器類別，負責以下功能：
 
 1. 數據源管理：
 
    - 提供 `UICollectionView` 的 `DataSource` 和 `Delegate` 方法。
    - 通過動態的 `numberOfItemsInSection` 和 `cellForItemAt` 方法顯示正確的數據。
 
 2. Section 展開/收起邏輯：
 
    - 集成 `OrderHistoryDetailSectionExpansionManager` 來管理 Section 的展開狀態。
    - 確保展開/收起行為由單一模塊負責。
 
 3. 手勢處理：
 
    - 通過 `OrderHistoryDetailHeaderGestureHandler` 處理 Section Header 點擊事件，並通知外部類別進行 UI 更新。

 ----------

 `* Why`

 1. 職責分離：
 
    - 問題：如果將 `UICollectionView` 的數據源與視圖更新邏輯直接混入到 `ViewController` 中，會增加耦合度，且影響可讀性與可維護性。
    - 解決方案：`OrderHistoryDetailHandler` 負責數據源管理，`ViewController` 僅需專注於外部事件處理與頁面導航。

 2. 高模組化與低耦合：
 
    - 透過 `OrderHistoryDetailSectionExpansionManager` 集中處理展開狀態，避免狀態邏輯分散，保持代碼簡潔。
    - 使用代理 (`OrderHistoryDetailHandlerDelegate`) 解耦數據獲取與視圖更新。

 3. 可測試性：
 
    - 每個模塊（例如 `SectionExpansionManager`、`HeaderGestureHandler`）各自專注於單一功能，容易進行單元測試。
    - 通過依賴注入模擬數據與行為，測試 Handler 的數據顯示是否正確。

 4. 可擴展性：
 
    - 如果需要添加更多區域（例如新增「配送狀態」），只需在 `Section` 枚舉中新增條目，並在數據源方法中配置邏輯。

 ----------

 `* How`

 1. 數據源與代理方法實現：
 
    - Section 管理：使用 `Section` 枚舉定義所有區域，並通過 `numberOfSections` 方法確保 `CollectionView` 區域數量一致。
    - 動態項目數量：通過 `numberOfItemsInSection` 判斷 Section 是否展開，確保顯示正確的數量。
    - Cell 配置：根據不同的 Section 類型，調用對應的 `configure` 方法，確保 Cell 顯示正確的數據。

    ```swift
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sectionType {
        case .itemDetails:
            let item = orderDetail.orderItems[indexPath.row]
            cell.configure(with: item)
        case .customerInfo:
            cell.configure(with: orderDetail.customerDetails)
        case .details:
            cell.configure(with: orderDetail)
        }
    }
    ```

 ------
 
 2. Section 展開/收起邏輯：
 
    - 使用 `OrderHistoryDetailSectionExpansionManager` 管理展開狀態。
    - 點擊 Header 時，切換 Section 的展開狀態，並通知外部類別刷新對應的 UI：

    ```swift
    orderHistoryDetailSectionExpansionManager.toggleSection(section)
    orderHistoryDetailSectionDelegate?.didToggleSection(section)
    ```

 ------

 3. 手勢處理：
 
    - 通過 `OrderHistoryDetailHeaderGestureHandler` 將點擊事件綁定到 Section Header，解耦展開邏輯與手勢邏輯：

    ```swift
    orderHistoryDetailHeaderGestureHandler?.addTapGesture(to: headerView, section: indexPath.section)
    ```

 ------

 4. 初始化與預設行為：
 
    - 在初始化時，讓第一個 Section (`itemDetails`) 預設展開，提升用戶體驗：

    ```swift
    orderHistoryDetailSectionExpansionManager.toggleSection(Section.itemDetails.rawValue)
    ```

 ----------

 `* 範例場景`

 - 假設用戶進入歷史訂單詳細頁面：
 
 1. 首次顯示時：
  
 - 預設展開「商品明細」區域，顯示訂單內所有商品。
 
 2. 點擊 Section Header：
   
 - 點擊「顧客資訊」，觸發展開/收起操作，刷新 UI 顯示顧客詳細資料。
 
 3. 動態數據顯示：
    
 - 根據展開狀態，正確顯示對應區域內的數據數量。

 ----------

 `* 總結`
 
 - `OrderHistoryDetailHandler` 將數據源管理、展開狀態邏輯、手勢處理三部分邏輯有機結合，通過職責分離和解耦設計提高代碼的可讀性、可測試性與可擴展性，適合用於需要多區域管理和高交互性的 `UICollectionView` 場景。
 */


// MARK: - (v)

import UIKit

/// 負責管理歷史訂單詳細頁面的 CollectionView 的處理器
///
/// - 主要功能:
///   1. 管理和提供 `CollectionView` 的數據源與代理方法。
///   2. 通過 `OrderHistoryDetailSectionExpansionManager` 集中處理各 Section 的展開/收起邏輯。
///   3. 使用 `OrderHistoryDetailHeaderGestureHandler` 添加手勢處理器，實現 Section Header 點擊功能。
///
/// - 設計目的:
///   1. 單一職責原則 (SRP):
///      - 負責數據源管理及展開/收起行為，與其他邏輯模塊解耦。
///   2. 高可測試性與可維護性:
///      - 通過依賴注入和協議分離數據獲取與視圖更新，降低耦合度。
///   3. 模組化:
///      - 集成 `OrderHistoryDetailSectionExpansionManager` 和 `OrderHistoryDetailHeaderGestureHandler`，將邏輯分開，保持代碼清晰。
class OrderHistoryDetailHandler: NSObject {
    
    // MARK: - Properties
    
    /// 委託，用於從外部獲取歷史訂單的詳細資料
    ///
    /// - 功能:
    ///   - 通知外部類別執行視圖刷新。
    ///   - 提供所需的訂單詳細數據，避免直接依賴外部數據結構。
    weak var orderHistoryDetailHandlerDelegate: OrderHistoryDetailHandlerDelegate?
    
    /// 用於管理 Section 展開狀態的管理器
    ///
    /// - 功能:
    ///   - 集中管理各 Section 的展開/收起狀態。
    private let orderHistoryDetailSectionExpansionManager = OrderHistoryDetailSectionExpansionManager()
    
    /// 負責處理 Header 點擊手勢的管理器
    ///
    /// - 功能:
    ///   - 將點擊事件與展開/收起邏輯解耦。
    ///   - 通過代理通知外部刷新 UI。
    private var orderHistoryDetailHeaderGestureHandler: OrderHistoryDetailHeaderGestureHandler?
    
    
    // MARK: - Initialization
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - orderHistoryDetailHandlerDelegate: 提供歷史訂單詳細資料的代理。
    ///   - orderHistoryDetailSectionDelegate: 負責更新 UI 的外部代理。
    init(
        orderHistoryDetailHandlerDelegate: OrderHistoryDetailHandlerDelegate?,
        orderHistoryDetailSectionDelegate: OrderHistoryDetailSectionDelegate?
    ) {
        super.init()
        
        self.orderHistoryDetailHandlerDelegate = orderHistoryDetailHandlerDelegate
        
        /// 初始化手勢處理器，並傳入展開狀態管理器和外部代理
        self.orderHistoryDetailHeaderGestureHandler = OrderHistoryDetailHeaderGestureHandler(
            orderHistoryDetailSectionExpansionManager: orderHistoryDetailSectionExpansionManager,
            orderHistoryDetailSectionDelegate: orderHistoryDetailSectionDelegate
        )
        
        /// 初次顯示時讓 `itemDetails` Section 預設展開
        orderHistoryDetailSectionExpansionManager.toggleSection(Section.itemDetails.rawValue)
    }
    
    // MARK: - Section
    
    /// 定義各個區域（用於顯示歷史訂單項目的不同區塊內容）
    ///
    /// - itemDetails: 訂單內商品的詳細資料區域。
    /// - customerInfo: 顧客基本資料（例如姓名、電話）的區域。
    /// - details: 訂單摘要（例如訂單編號、總金額等）的區域。
    enum Section: Int, CaseIterable {
        case itemDetails
        case customerInfo
        case details
    }
    
}

// MARK: - UICollectionViewDataSource
extension OrderHistoryDetailHandler: UICollectionViewDataSource {
        
    /// 設定顯示的區域數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    /// 設定每個區域中顯示的項目數量
    ///
    /// - Parameters:
    ///   - collectionView: CollectionView 實例。
    ///   - section: 區域索引。
    /// - Returns: 該區域的項目數量。
    /// - 說明: 根據展開狀態或資料決定數量。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section),
              let orderDetail = orderHistoryDetailHandlerDelegate?.getOrderHistoryDetail()
        else {
            return 0
        }
    
        switch sectionType {
        case .itemDetails:
            // 根據是否展開狀態返回對應的 item 數量
            return orderHistoryDetailSectionExpansionManager.isSectionExpanded(section) ?  orderDetail.orderItems.count : 0
        case .customerInfo, .details:
            return 1
        }
    }

    /// 配置每個區域的標題
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = Section(rawValue: indexPath.section),
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderHistoryDetailSectionHeaderView.headerIdentifier, for: indexPath) as? OrderHistoryDetailSectionHeaderView else {
            fatalError("Invalid supplementary element configuration")
        }
        
        switch sectionType {
        case .itemDetails:
            let isExpanded = orderHistoryDetailSectionExpansionManager.isSectionExpanded(indexPath.section)
            headerView.configure(with: "Item Details", isExpanded: isExpanded, showArrow: true)
            // 添加手勢處理
            orderHistoryDetailHeaderGestureHandler?.addTapGesture(to: headerView, section: indexPath.section)
            
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
              let orderDetail = orderHistoryDetailHandlerDelegate?.getOrderHistoryDetail() else {
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
