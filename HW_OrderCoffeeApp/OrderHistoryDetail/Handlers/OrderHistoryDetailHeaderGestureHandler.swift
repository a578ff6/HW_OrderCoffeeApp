//
//  OrderHistoryDetailHeaderGestureHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//

// MARK: - OrderHistoryDetailHeaderGestureHandler 筆記
/**
 
 ## OrderHistoryDetailHeaderGestureHandler 筆記


 * What
 
 - `OrderHistoryDetailHeaderGestureHandler` 是一個專門處理歷史訂單詳細頁面中 Header View 點擊手勢的管理器。

 - 主要職責：
 
   1. 為每個 Section Header 綁定點擊手勢，確保用戶的交互正確映射到對應的 Section。
   2. 在用戶點擊 Header 後，觸發對應 Section 的展開/收起邏輯。
   3. 通過代理模式通知外部類別（如 `OrderHistoryDetailViewController`）執行 UI 更新操作。

 ---------

 * Why
 
 - 設計這個類的目的，是為了解耦點擊事件的處理與展開/收起邏輯，並提升模組化與代碼的可維護性。

 1. 單一職責原則 (SRP)：
 
    - 此類僅負責處理點擊事件，將展開/收起邏輯交由 `OrderHistoryDetailSectionExpansionManager`，UI 更新交由 `OrderHistoryDetailSectionDelegate`。
    - 確保每個模組只專注於自己的責任，降低代碼的複雜度。
    
 2. 提升可讀性與可測試性：
 
    - 將手勢的配置與點擊事件的處理邏輯集中管理，代碼更清晰，便於單獨測試。
    
 3. 解耦業務邏輯與視圖更新：
 
    - 手勢處理、展開狀態管理、視圖刷新各司其職，避免邏輯耦合，便於日後修改或擴展功能。

 4. 靈活應對未來需求：
 
    - 若需要支持其他手勢（如長按、雙擊）或不同的展開策略（如僅允許單一 Section 展開），可在此類擴展實現。

 ---------

 `* How`

 1. 初始化管理器
 
 ```swift
 let gestureHandler = OrderHistoryDetailHeaderGestureHandler(
     orderHistoryDetailSectionExpansionManager: sectionExpansionManager,
     orderHistoryDetailSectionDelegate: viewController
 )
 ```
 
 - 依賴注入：
   - `OrderHistoryDetailSectionExpansionManager` 負責展開狀態的管理。
   - `OrderHistoryDetailSectionDelegate` 通知外部類別執行對應的視圖刷新。

 ---
 
 2. 為 Section Header 添加點擊手勢
 
 ```swift
 gestureHandler.addTapGesture(to: headerView, section: sectionIndex)
 ```
 
 - 邏輯：
   - 每個 Header 綁定對應的 Section 索引（使用 `headerView.tag`）。
   - 確保用戶點擊的事件可以準確識別是哪個 Section。

 ---

 3. 處理點擊手勢
 
 ```swift
 @objc private func handleHeaderTap(_ sender: UITapGestureRecognizer) {
     guard let section = sender.view?.tag else { return }
     sectionExpansionManager.toggleSection(section) // 切換展開狀態
     sectionDelegate?.didToggleSection(section)    // 通知外部更新 UI
 }
 ```
 
 - 流程：
   1. 獲取點擊事件的 Section 索引。
   2. 更新展開/收起狀態。
   3. 通知外部執行 Section 的 UI 刷新（如重載對應 Section）。

 ---------

 `* 範例場景`

 - 用戶點擊 Section Header，觸發展開/收起邏輯
 
 1. 用戶點擊「訂單摘要」的 Header：
    - `handleHeaderTap` 方法被觸發。
    - `OrderHistoryDetailSectionExpansionManager` 更新展開狀態。
    - 通知 `OrderHistoryDetailViewController` 執行對應的 Section 重載。

 ---------

 `* 整體流程`
 
 1. 添加手勢：在 `UICollectionView` 配置 Header 時，使用 `addTapGesture` 為每個 Header 綁定點擊事件。
 2. 點擊處理：手勢被觸發時，執行 `handleHeaderTap` 方法，切換狀態並通知外部更新 UI。
 3. UI 刷新：由外部（如 ViewController）負責執行對應的 Section 重載邏輯。

 ---------

` * 結論`
 
 - 設計關鍵點：
 
   - 解耦點擊事件、狀態管理、UI 更新。
   - 確保每個模組專注於單一職責，提升代碼的靈活性與可維護性。
 
 - 適用場景：
 
   - 多 Section 的頁面邏輯，特別是需要用戶交互切換展開/收起狀態的情況。
 
 ---------

 ` ### 注意事項`
  
  - 每次點擊 Header 時，必須透過 `delegate?.didToggleSection(section)` 來通知外部更新，以保證頁面上的顯示與內部的展開狀態一致。
  - 使用 `tag` 來標識每個 Header View 對應的區塊，在大規模使用時應小心避免 `tag` 重複導致錯誤操作。
 */




// MARK: - (v)

import UIKit


/// `OrderHistoryDetailHeaderGestureHandler`
///
/// 此類負責處理歷史訂單詳細頁面的 Header View 點擊手勢，將點擊事件與 Section 展開/收起邏輯分離，並透過代理通知外部類別執行視圖更新。
///
/// - 設計目的:
///   1. 解耦點擊與邏輯：讓手勢處理器專注於處理點擊事件，並將狀態變更與 UI 刷新交由外部模組（如 ViewController）。
///   2. 單一職責原則 (SRP)：專注於點擊手勢的添加和處理，避免混入其他邏輯。
///   3. 高可維護性：集中管理 Header 的手勢邏輯，方便未來擴展或修改。
///
/// - 使用場景:
///   1. 用戶點擊 Section Header，觸發展開/收起操作時，此類負責：
///      - 更新 Section 展開/收起的狀態。
///      - 通知外部類別（如 ViewController）刷新對應的 UI。
///   2. 配置手勢到特定的 Section Header，確保點擊事件正確綁定到對應的 Section。
class OrderHistoryDetailHeaderGestureHandler {
    
    // MARK: - Properties
    
    /// `OrderHistoryDetailSectionExpansionManager` 用於管理 Section 的展開狀態
    ///
    /// - 功能:
    ///   - 集中管理展開/收起的狀態。
    ///   - 提供狀態查詢與切換的接口。
    private let orderHistoryDetailSectionExpansionManager: OrderHistoryDetailSectionExpansionManager
    
    /// `OrderHistoryDetailSectionDelegate` 用於通知外部類別進行視圖更新
    ///
    /// - 功能:
    ///   - 在 Section 狀態切換後，告知外部類別執行對應的 UI 刷新操作。
    weak var orderHistoryDetailSectionDelegate: OrderHistoryDetailSectionDelegate?
    
    // MARK: - Initialization
    
    /// 初始化手勢處理器
    ///
    /// - Parameters:
    ///   - orderHistoryDetailSectionExpansionManager: 用於管理 Section 狀態的管理器。
    ///   - orderHistoryDetailSectionDelegate: 用於通知外部類別更新視圖的代理。
    init(
        orderHistoryDetailSectionExpansionManager: OrderHistoryDetailSectionExpansionManager,
        orderHistoryDetailSectionDelegate: OrderHistoryDetailSectionDelegate?
    ) {
        self.orderHistoryDetailSectionExpansionManager = orderHistoryDetailSectionExpansionManager
        self.orderHistoryDetailSectionDelegate = orderHistoryDetailSectionDelegate
    }
    
    // MARK: - Public Methods
    
    /// 將點擊手勢添加到指定的 Header View
    ///
    /// - Parameters:
    ///   - headerView: 要添加手勢的 Section Header View。
    ///   - section: 對應的 Section 索引。
    ///
    /// - 使用場景:
    ///   - 在 `UICollectionView` 的 Header 配置階段，為每個 Section Header 綁定點擊手勢。
    func addTapGesture(to headerView: OrderHistoryDetailSectionHeaderView, section: Int) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag = section
    }
    
    /// 處理 Header View 的點擊事件
    ///
    /// - Parameter sender: 點擊事件的手勢識別器。
    ///
    /// - 邏輯:
    ///   1. 獲取被點擊的 Section 索引。
    ///   2. 通過 `OrderHistoryDetailSectionExpansionManager` 切換 Section 的展開狀態。
    ///   3. 通知外部代理 (`OrderHistoryDetailSectionDelegate`) 刷新對應 Section 的 UI。
    @objc private func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        print("Header tapped for section: \(section)")
        
        // 切換展開/收起狀態
        orderHistoryDetailSectionExpansionManager.toggleSection(section)
        // 通知 ViewController 更新顯示
        orderHistoryDetailSectionDelegate?.didToggleSection(section)
    }
    
}
