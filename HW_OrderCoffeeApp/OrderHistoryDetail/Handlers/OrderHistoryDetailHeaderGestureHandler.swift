//
//  OrderHistoryDetailHeaderGestureHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/13.
//

// MARK: - OrderHistoryDetailHeaderGestureHandler - 重點筆記
/**
 ## OrderHistoryDetailHeaderGestureHandler - 重點筆記
 
 `### 主要功能`
 
 - `OrderHistoryDetailHeaderGestureHandler` 負責處理歷史訂單細項畫面中 Header View 的點擊手勢，並控制每個區塊的展開和收起。
 - 此類別透過手勢辨識器來監控使用者的點擊行為，配合 Section 展開管理器來實現頁面視圖的互動。

 `### 關鍵概念`
 
 `1. 手勢管理：`
    - 使用 `UITapGestureRecognizer` 來監控使用者點擊 Header View 的行為，從而觸發展開或收起 Section 的操作。
    - 每個 Header View 都會附加一個點擊手勢，並且根據所屬的區塊設置標籤（`tag`）來識別點擊的是哪一個區塊。

 `2. 展開/收起邏輯：`
    - 通過 `OrderHistoryDetailSectionExpansionManager` 來集中管理各個區塊的展開狀態。當使用者點擊 Header View 時，會切換對應區塊的展開或收起狀態。

 `3. 委託模式：`
    - `delegate` 用於通知 ViewController 更新相應區塊的顯示，確保 UI 能及時反映使用者的操作。
    - `OrderHistoryDetailDelegate` 提供 `didToggleSection(_:)` 方法來處理 Section 展開或收起後的 UI 更新。

 `### 使用步驟`
 
` 1. 初始化時：`
    - 傳入 `OrderHistoryDetailSectionExpansionManager` 和 `OrderHistoryDetailDelegate`，用於管理展開狀態和通知外部類別更新。

 `2. 添加手勢：`
    - 使用 `addTapGesture(to:section:)` 方法為每個 Header View 添加手勢辨識器，並透過標籤來區分不同的區塊。

 `3. 處理點擊：`
    - 當 Header 被點擊時，呼叫 `handleHeaderTap(_:)` 方法，透過委託來通知 ViewController 切換相應區塊的狀態，並更新顯示。

` ### 注意事項`
 
 - 每次點擊 Header 時，必須透過 `delegate?.didToggleSection(section)` 來通知外部更新，以保證頁面上的顯示與內部的展開狀態一致。
 - 使用 `tag` 來標識每個 Header View 對應的區塊，在大規模使用時應小心避免 `tag` 重複導致錯誤操作。

 `### 重點總結`
 
 - `職責單一`：  該類別只負責處理手勢和展開狀態切換，確保程式結構清晰，職責分明。
 - `與擴展管理器協作`：  集中管理展開狀態，避免在各處重複管理展開/收起邏輯。
 - `委託通知更新`： 確保每次展開或收起操作後，UI 的顯示及時更新，提供良好的使用者體驗。
 */

import UIKit

/// 負責處理歷史訂單細項面中的 Header View 點擊手勢的管理器
class OrderHistoryDetailHeaderGestureHandler {
    
    // MARK: - Properties

    /// ExpansionManager 用於管理 Section 展開狀態
    private let expansionManager: OrderHistoryDetailSectionExpansionManager

    /// Delegate 用於通知 ViewController 進行視圖更新
    weak var delegate: OrderHistoryDetailDelegate?
    
    // MARK: - Initialization

    init(expansionManager: OrderHistoryDetailSectionExpansionManager, delegate: OrderHistoryDetailDelegate?) {
        self.expansionManager = expansionManager
        self.delegate = delegate
    }
    
    // MARK: - Public Methods

    /// 添加手勢辨識器到 Header View
    func addTapGesture(to headerView: OrderHistoryDetailSectionHeaderView, section: Int) {
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
