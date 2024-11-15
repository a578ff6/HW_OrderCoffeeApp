//
//  OrderConfirmationHeaderGestureHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

// MARK: - 重點筆記：`OrderConfirmationHeaderGestureHandler` 設計與應用
/**
 ## 重點筆記：`OrderConfirmationHeaderGestureHandler` 設計與應用

 `* 設計目的`
    - `OrderConfirmationHeaderGestureHandler` 是專門用來處理訂單確認頁面中 Header View 點擊手勢的管理器，旨在分離手勢處理邏輯，讓代碼更加清晰與可維護。
    - 把手勢處理邏輯獨立出來，減少 `OrderConfirmationHandler` 的責任，使其專注於資料管理，而手勢處理的邏輯則由 `OrderConfirmationHeaderGestureHandler` 負責。

 `* 功能概述`
 
 `1. 添加手勢到 Header View：`
    - 使用 `addTapGesture(to:section:)` 方法將點擊手勢添加至 `HeaderView`，並設置對應的 `section`，使得不同的 Header 可以響應自己的展開或收起事件。

 `2. 處理點擊手勢：`
    - 當 `HeaderView` 被點擊時，執行 `handleHeaderTap(_:)` 方法。
    - 方法中通過手勢的 `view.tag` 獲取被點擊的 `section`，進一步通過 `expansionManager` 切換該區域的展開或收起狀態。
    - 使用 `delegate` 通知外部類別 (例如 `OrderConfirmationViewController`) 更新 UI，保持資料驅動的狀態更新。

 `* 解決的問題`
 - `降低耦合`：將手勢處理從 `OrderConfirmationHandler` 中分離，減少了 `OrderConfirmationHandler` 的邏輯複雜度，讓不同類別專注於各自的職責，從而提高代碼的可讀性與可維護性。
 - `提高重用性`：透過獨立的手勢管理器，使手勢邏輯更加通用化。如果需要在其他場景中對 `HeaderView` 添加手勢，可以輕鬆重用這個處理器。

 `* 設計中的注意事項`
 
 `1. 手勢與 UI 之間的協同：`
    - 在手勢被觸發時，切換對應 `section` 的展開或收起狀態 (`toggleSection`) 並通知 `ViewController` 更新畫面 (`delegate?.didToggleSection(section)`)。
    - 在多層代理架構中，透過 `delegate` 保持外部類別與手勢管理器的通信，從而確保畫面的同步更新。

` 2. 手勢處理的隔離性：`
    - 手勢的處理完全由 `OrderConfirmationHeaderGestureHandler` 負責，使得 `OrderConfirmationHandler` 無需直接管理手勢，僅需專注於 `CollectionView` 的數據顯示邏輯。

 `* 如何使用`
 
 `1. 初始化時注入：`
    - 在初始化 `OrderConfirmationHeaderGestureHandler` 時，需要注入 `OrderConfirmationSectionExpansionManager` 和 `OrderConfirmationHandlerDelegate`。這樣能夠使 `HeaderGestureHandler` 在手勢被觸發時即刻更新展開狀態並通知委託來更新 UI。
    
 `2. 在 `HeaderView` 中添加手勢：`
    - 使用 `addTapGesture(to:section:)` 方法將手勢與指定的 `HeaderView` 綁定，這樣每個區域的 `HeaderView` 就可以響應自身的點擊事件。

 ---
 
 `### 示例使用流程`
 `- Step 1`:  在 `OrderConfirmationHandler` 中初始化 `OrderConfirmationHeaderGestureHandler`，並為需要展開/收起功能的 `HeaderView` 添加點擊手勢，例如 `itemDetails` 區域。
 `- Step 2`:  當使用者點擊 `itemDetails` 的 `HeaderView` 時，手勢管理器捕獲到事件，切換對應 `section` 的展開或收起狀態。
 `- Step 3:`  通知 `OrderConfirmationViewController` 更新顯示，以確保使用者看到的 UI 狀態與內部資料狀態一致。

 這樣的設計讓 `OrderConfirmationHandler` 可以專注於 `UICollectionView` 的資料管理與顯示。
 而手勢處理則完全交由 `OrderConfirmationHeaderGestureHandler`，大幅提升模組化和可維護性。
 */

import UIKit

/// 負責處理訂單確認頁面中的 Header View 點擊手勢的管理器
class OrderConfirmationHeaderGestureHandler {
    
    // MARK: - Properties

    /// ExpansionManager 用於管理 Section 展開狀態
    private let expansionManager: OrderConfirmationSectionExpansionManager

    /// Delegate 用於通知 ViewController 進行視圖更新
    weak var delegate: OrderConfirmationHandlerDelegate?

    // MARK: - Initialization

    init(expansionManager: OrderConfirmationSectionExpansionManager, delegate: OrderConfirmationHandlerDelegate?) {
        self.expansionManager = expansionManager
        self.delegate = delegate
    }
    
    // MARK: - Public Methods

    /// 添加手勢辨識器到 Header View
    func addTapGesture(to headerView: OrderConfirmationSectionHeaderView, section: Int) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag = section
    }
    
    /// 處理 Header View 的點擊手勢
    @objc private func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        print("Header tapped for section: \(section)")
        
        // 切換展開/收起狀態
        expansionManager.toggleSection(section)
        // 通知 ViewController 更新顯示
        delegate?.didToggleSection(section)
    }
    
}
