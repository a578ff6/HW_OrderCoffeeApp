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
 
` 7.Header View 點擊展開/收起功能的分離處理`
    - 原本與 `HeaderView` 點擊展開/收起有關的部分，如添加手勢識別器 (`addTapGesture`) 和處理點擊事件 (`handleHeaderTap`) 已被分離至 `OrderConfirmationHeaderGestureHandler` 中。
 
    `* Header Gesture Handler 的作用`
        - `OrderConfirmationHeaderGestureHandler` 現在負責管理 `HeaderView` 的手勢處理邏輯。它為 `HeaderView` 添加手勢並在點擊時切換對應 Section 的展開狀態。
        - `OrderConfirmationHandler` 則根據 `expansionManager` 的狀態來配置每個 HeaderView，如設置展開箭頭的方向。
 
    `* 責任分離的優點`
        - 這樣的設計使得 `OrderConfirmationHandler` 不再負責手勢處理，而專注於數據配置和顯示邏輯。
        - `OrderConfirmationHeaderGestureHandler` 負責管理 `HeaderView` 的點擊手勢，這樣能確保責任分離，並使程式碼更具模塊化且易於維護。
 */


// MARK: - 重點筆記：OrderConfirmationHandler 中與 HeaderView 點擊展開/收起有關的部分

/**
 ## 重點筆記：OrderConfirmationHandler 中與 HeaderView 點擊展開/收起有關的部分

 `* 目的與設計`
    - `OrderConfirmationHandler`  負責訂單確認頁面的各個區域的資料顯示與管理，尤其是管理 UICollectionView 的數據配置。
    - `OrderConfirmationHandler` 與 `HeaderView` 點擊展開/收起的功能相關，因為它負責管理 HeaderView 的顯示邏輯（如箭頭方向）以及需要展示的內容數量。
    - 這些部分涉及手勢處理、狀態管理、以及更新顯示邏輯，確保使用者可以靈活地控制訂單內容的顯示。
 
 `1.分離手勢處理到 OrderConfirmationHeaderGestureHandler`
    - 原先的 `OrderConfirmationHandler` 中包含了手勢處理和狀態管理的邏輯，這部分被移到專門的 `OrderConfirmationHeaderGestureHandler` 中，進行更清晰的責任分離。
    - `OrderConfirmationHeaderGestureHandler` 專門負責為 `HeaderView` 添加點擊手勢並處理點擊事件，這樣使得 `OrderConfirmationHandler` 更加專注於數據源和顯示邏輯，減少了其複雜性。
 
`2.expansionManager 的作用`
    - `expansionManager` 是一個 `OrderConfirmationSectionExpansionManager` 類別，用於集中管理頁面上所有 Section 的展開或收起狀態。
    - 它由 `OrderConfirmationHandler` 管理，用於追蹤每個 Section 是否展開，以便決定應顯示多少內容（如 `itemDetails` 區域的商品數量）。

`3.OrderConfirmationHandler 與 HeaderView 展開/收起的關聯性`
    - 雖然手勢處理已經被分離出來，但 `OrderConfirmationHandler` 仍然需要根據 `HeaderGestureHandler` 的手勢結果更新顯示。
    - 在 `viewForSupplementaryElementOfKind` 方法中，`OrderConfirmationHandler` 根據當前的展開狀態來配置 HeaderView，例如設定箭頭方向。
    - 當手勢導致某個 Section 展開或收起時，`expansionManager` 會更新狀態，並通過委託通知 `ViewController` 來刷新對應區域的顯示。

 `4.addTapGesture 方法的調整`
    - 原本位於 `OrderConfirmationHandler` 中的 `addTapGesture` 方法已經被移至 `OrderConfirmationHeaderGestureHandler` 中進行專門管理。
    - 在 `OrderConfirmationHandler` 中，對 `itemDetails` 區域的 `HeaderView` 添加手勢時，現在會呼叫` headerGestureHandler.addTapGesture(to:headerView, section: indexPath.section)`，這樣使手勢管理更加集中，責任更加清晰。

 `改進後的設計流程`
 
 `1.初始化流程：`
    - 在初始化 `OrderConfirmationHandler` 時，將 `itemDetails` 區域預設設為展開狀態，使用` expansionManager.toggleSection(Section.itemDetails.rawValue) `來管理狀態。
    - 初始化 `OrderConfirmationHeaderGestureHandler` 並將其用於管理 `HeaderView` 點擊手勢，確保在顯示 HeaderView 時能添加手勢處理。
 
 `2.手勢處理與顯示邏輯的分離：`
    - `OrderConfirmationHeaderGestureHandler` 負責手勢處理，監聽 HeaderView 的點擊事件，並通過 `expansionManager` 切換展開/收起狀態。
    - `OrderConfirmationHandler` 則負責根據 `expansionManager` 的狀態來配置每個 HeaderView，以便顯示正確的內容。
 
 `3.用戶交互流程：`
    - 當用戶點擊某個 `HeaderView` 時，手勢管理器捕獲到該事件，然後通過 `expansionManager` 切換狀態。
    - 接著通過 `delegate` 通知 `OrderConfirmationViewController`，從而使對應的區域顯示或隱藏，保證 UI 狀態與內部資料一致。
 
 `總結`
    - 將 HeaderView 點擊手勢的管理分離到 `OrderConfirmationHeaderGestureHandler` 中，提高了責任分離的清晰度，減少了 `OrderConfirmationHandler` 的負擔，使其能專注於數據顯示。
    - `OrderConfirmationHandler` 與 `HeaderView` 展開/收起仍有關聯，因為它負責配置 HeaderView 的顯示邏輯，而手勢處理結果最終需要反映在這些顯示邏輯上。
 */


// MARK: - 重點筆記：OrderConfirmationHeaderGestureHandler 的放置位置
/**
 ## 重點筆記：OrderConfirmationHeaderGestureHandler 的放置位置

` * 背景描述`
    - `OrderConfirmationHandler` 負責管理訂單確認頁面的資料顯示，特別是 UICollectionView 的數據配置和顯示邏輯。
    - `OrderConfirmationHeaderGestureHandler` 負責處理 Header View 的點擊手勢，對應於 UICollectionView 中各區域的展開/收起操作。
    - 需要考慮 `OrderConfirmationHeaderGestureHandler` 放置於 OrderConfirmationHandler 或 OrderConfirmationViewController 中的合適性。
 
 `* 決策原因`
 
 `1.責任分離原則`
    - `OrderConfirmationHandler` 的主要責任是管理 UICollectionView 的顯示和交互，這包含配置標題、添加手勢等操作。
    - `OrderConfirmationHeaderGestureHandler` 專注於 Header View 點擊手勢的處理，這是 UICollectionView 交互的一部分。
    - 將 `headerGestureHandler` 放在 `OrderConfirmationHandler` 中，有助於保持責任單一，符合責任分離的原則。
 
 `2.降低耦合度`
    - 如果將 `headerGestureHandler` 放在 `OrderConfirmationViewController` 中，會增加 ViewController 的複雜度，使其必須處理 UICollectionView 的低層級操作。
    - 這樣會導致 ViewController 的耦合度過高，不利於代碼的擴展和維護。
    - 將手勢處理交由 `OrderConfirmationHandler` 管理，可以讓 ViewController 專注於高層級的操作，如初始化、資料獲取等，從而降低耦合度。
 
 `3.關聯性更強`
    - `headerGestureHandler` 的行為完全與 UICollectionView 的 Header View 相關，這些行為應由 `OrderConfirmationHandler` 管理，以保持邏輯的一致性。
    - 將其包含在 `OrderConfirmationHandler` 中更符合這些功能的邏輯歸屬和責任範圍。
 
 `結論`
    - 將 `OrderConfirmationHeaderGestureHandler` 放在 `OrderConfirmationHandler` 中，符合責任分離原則，降低了耦合度，讓 `OrderConfirmationHandler` 更好地管理 UICollectionView 的展示和交互。
 */


import UIKit

/// 負責處理訂單確認頁面的資料顯示
/// - 主要用途：管理訂單確認畫面上各個區域的資料來源及顯示邏輯。
class OrderConfirmationHandler: NSObject {

    // MARK: - Properties

    /// 委託，用於提供訂單資料
    weak var delegate: OrderConfirmationHandlerDelegate?
    
    /// 用於管理 Section 展開狀態的管理器
    private let expansionManager = OrderConfirmationSectionExpansionManager()
    
    /// 由外部設定，以確保 `delegate` 已經被初始化後再初始化手勢管理器
    private var headerGestureHandler: OrderConfirmationHeaderGestureHandler?

    // MARK: - Initialization

    // 初始化方法
    /// - Parameter delegate: 外部提供的代理
    init(delegate: OrderConfirmationHandlerDelegate?) {
        super.init()
        self.delegate = delegate
        
        // 初始化手勢處理管理器，並將 `delegate` 傳入
        self.headerGestureHandler = OrderConfirmationHeaderGestureHandler(expansionManager: expansionManager, delegate: delegate)
        // 初次顯示時讓 itemDetails 展開
        expansionManager.toggleSection(Section.itemDetails.rawValue)
    }
    
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
    
    // MARK: - CollectionView DataSource Methods

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
            // 根據是否展開狀態返回對應的 item 數量
            return expansionManager.isSectionExpanded(section) ? (delegate?.getOrder()?.orderItems.count ?? 0) : 0
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
            let isExpanded = expansionManager.isSectionExpanded(indexPath.section)
            headerView.configure(with: "Item Details", isExpanded: isExpanded, showArrow: true)
            // 確保在設置 Header 時，添加手勢處理
            headerGestureHandler?.addTapGesture(to: headerView, section: indexPath.section)
    
        case .customerInfo:
            headerView.configure(with: "Customer Information", isExpanded: false, showArrow: false)
        case .details:
            headerView.configure(with: "Order Summary", isExpanded: false, showArrow: false)
        default:
            break
        }
        
        return headerView
    }

    // MARK: - Cell Configuration Methods

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
    
    /// 配置勾選圖示 Cell，表示訂單確認成功
    private func configureCheckmarkCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderConfirmationCheckmarkCell.reuseIdentifier, for: indexPath) as? OrderConfirmationCheckmarkCell else {
            fatalError("Cannot create OrderConfirmationCheckmarkCell")
        }
        return cell
    }
    
    /// 配置訂單訊息提示 Cell
    private func configureMessageCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderConfirmationMessageCell.reuseIdentifier, for: indexPath) as? OrderConfirmationMessageCell else {
            fatalError("Cannot create OrderConfirmationMessageCell")
        }
        return cell
    }
    
    /// 配置訂單項目詳細資料的 Cell
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
    
    /// 配置顧客基本資料的 Cell
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
    
    /// 配置訂單摘要的 Cell（例如訂單編號、總金額等）
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
    
    /// 配置關閉按鈕 Cell，讓使用者能夠返回上一頁面
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
