//
//  OrderConfirmationHeaderGestureHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - OrderConfirmationHeaderGestureHandler 筆記
/**
 
 ## OrderConfirmationHeaderGestureHandler 筆記
 
 `* What`
 
 - `OrderConfirmationHeaderGestureHandler` 是一個專門處理 `訂單確認頁面` 中 `Section Header 點擊手勢` 的工具類別。
 
 - 此類負責：
 
 1. 為每個 Section Header 添加點擊手勢。
 2. 在點擊時切換 Section 的 **展開/收起** 狀態。
 3. 通知外部類別（例如 `OrderConfirmationViewController`）更新視圖。

 ------------
 
 `* Why`
 
 - 設計目標：
 
 1. 單一職責原則 (SRP)：
   
 - 集中處理點擊手勢邏輯，避免手勢處理分散在其他業務類別中，增強模組化和可維護性。
 
 2. 降低耦合性：
  
 - 與 `OrderConfirmationSectionExpansionManager` 協作，切換 Section 狀態，並透過 `OrderConfirmationSectionDelegate` 通知外部進行視圖更新。
 
 3. 高可擴展性：
   
 - 未來若需支持其他手勢行為（如長按、滑動等），可在此類基礎上輕鬆擴展。

 ------------

 `* 使用場景：`
 
 1. 點擊手勢處理：
 
 - 用戶點擊 Section Header 時，展開或收起內容。
 
 2. 視圖同步更新：
 
 - 確保 Section 展開狀態與 UI 顯示一致，避免狀態錯誤。

 ------------

 `* How `
 
 - 運作流程：
 
 1. 添加手勢：
 
 - 調用 `addTapGesture(to:section:)` 方法，將點擊手勢綁定到指定的 Section Header。
 - 為 Header View 設置 `tag`，用於標識對應的 Section 索引。

 2. 處理手勢事件：
 
    - 當用戶點擊 Header 時，觸發 `handleHeaderTap(_:)`。
    - 通過 `tag` 獲取 Section 索引。
    - 使用 `OrderConfirmationSectionExpansionManager` 切換 Section 展開/收起狀態。
    - 通知 `OrderConfirmationSectionDelegate`，外部類別可根據通知更新 UI。

 ------------
 
 `* 核心方法：`
 
 1. `addTapGesture(to:section:)`：
 
    - 為指定的 Header View 綁定點擊手勢，並設置 Section 索引。
 
 2. `handleHeaderTap(_:)`：
   
    - 處理點擊手勢，更新 Section 狀態並通知外部。

 ------------

 `* 主要協作物件：`
 
 - `OrderConfirmationSectionExpansionManager`：
 
   - 切換 Section 的展開/收起狀態。
 
 - `OrderConfirmationSectionDelegate`：
 
   - 通知外部（如 `OrderConfirmationViewController`）進行視圖更新。

 ------------

 `* 如何使用`
 
 `1. 初始化時注入：`
 
    - 在初始化 `OrderConfirmationHeaderGestureHandler` 時，需要注入 `OrderConfirmationSectionExpansionManager` 和 `OrderConfirmationSectionDelegate`。
    - 這樣能夠使 `HeaderGestureHandler` 在手勢被觸發時即刻更新展開狀態並通知委託來更新 UI。
    
 `2. 在 HeaderView 中添加手勢：`
 
    - 使用 `addTapGesture(to:section:)` 方法將手勢與指定的 `HeaderView` 綁定，這樣每個區域的 `HeaderView` 就可以響應自身的點擊事件。

 ------------

`* 示例使用流程`
 
 `- Step 1`:  在 `OrderConfirmationHandler` 中初始化 `OrderConfirmationHeaderGestureHandler`，並為需要展開/收起功能的 `HeaderView` 添加點擊手勢，例如 `itemDetails` 區域。
 `- Step 2`:  當使用者點擊 `itemDetails` 的 `HeaderView` 時，手勢管理器捕獲到事件，切換對應 `section` 的展開或收起狀態。
 `- Step 3:`  通知 `OrderConfirmationViewController` 更新顯示，以確保使用者看到的 UI 狀態與內部資料狀態一致。

 這樣的設計讓 `OrderConfirmationHandler` 可以專注於 `UICollectionView` 的資料管理與顯示。
 
 
 ------------

 `* 優點`
 
 1. 簡潔清晰：單一類別負責手勢處理，避免邏輯分散。
 2. 高度可維護：手勢行為與展開邏輯解耦，便於擴展與測試。
 3. 提升用戶體驗：確保用戶操作與視圖更新同步，避免狀態錯誤。

 */



// MARK: - (v)

import UIKit

/// `OrderConfirmationHeaderGestureHandler`
///
/// 負責處理訂單確認頁面中 Section Header View 的點擊手勢，
/// 協助管理 Section 展開與收起邏輯，並通知外部類別更新相關視圖。
///
/// - 設計目標:
///   1. 單一職責原則：
///      - 此類專注於處理 Header View 的手勢邏輯，避免在其他模組中增加不必要的手勢處理邏輯。
///   2. 降低耦合性：
///      - 與 `OrderConfirmationSectionExpansionManager` 協作，負責切換展開/收起狀態，
///        並透過 `OrderConfirmationSectionDelegate` 通知外部類別更新視圖。
///
/// - 使用情境:
///   1. 當用戶點擊 Section Header 時，觸發展開或收起操作。
///   2. 此類負責管理點擊手勢的處理，並確保展開狀態與視圖顯示同步更新。
class OrderConfirmationHeaderGestureHandler {
    
    // MARK: - Properties
    
    /// 用於管理 Section 展開狀態的管理器
    ///
    /// - 功能：集中管理 Section 的展開/收起狀態，避免直接將邏輯嵌入到手勢處理中。
    private let orderConfirmationSectionExpansionManager: OrderConfirmationSectionExpansionManager
    
    /// 用於通知外部類別進行視圖更新的代理
    ///
    /// - 功能：在手勢處理完成後，通知外部進行視圖的更新，例如刷新指定的 Section。
    weak var orderConfirmationSectionDelegate: OrderConfirmationSectionDelegate?
    
    // MARK: - Initialization
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - orderConfirmationSectionExpansionManager: 管理 Section 展開狀態的管理器。
    ///   - orderConfirmationSectionDelegate: 負責通知外部更新視圖的代理。
    init(
        orderConfirmationSectionExpansionManager: OrderConfirmationSectionExpansionManager,
        orderConfirmationSectionDelegate: OrderConfirmationSectionDelegate?
    ) {
        self.orderConfirmationSectionExpansionManager = orderConfirmationSectionExpansionManager
        self.orderConfirmationSectionDelegate = orderConfirmationSectionDelegate
    }
    
    // MARK: - Public Methods
    
    /// 添加點擊手勢至 Header View
    ///
    /// - Parameters:
    ///   - headerView: 要添加手勢的 Header View。
    ///   - section: 對應的 Section 索引，用於標記手勢目標。
    ///
    /// - 功能：
    ///   - 為指定的 Header View 綁定點擊手勢。
    ///   - 點擊時會觸發展開/收起狀態的切換。
    func addTapGesture(to headerView: OrderConfirmationSectionHeaderView, section: Int) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag = section
    }
    
    // MARK: - Private Methods
    
    /// 處理 Header View 的點擊手勢
    ///
    /// - Parameter sender: 點擊手勢識別器。
    ///
    /// - 功能：
    ///   1. 獲取點擊的 Section 索引。
    ///   2. 切換該 Section 的展開/收起狀態。
    ///   3. 通知外部類別更新對應的視圖。
    @objc private func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        print("Header tapped for section: \(section)")
        
        // 切換展開/收起狀態
        orderConfirmationSectionExpansionManager.toggleSection(section)
        // 通知 ViewController 更新顯示
        orderConfirmationSectionDelegate?.didToggleSection(section)
    }
    
}
