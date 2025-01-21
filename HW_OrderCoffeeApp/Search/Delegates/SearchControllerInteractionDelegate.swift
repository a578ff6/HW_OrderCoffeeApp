//
//  SearchControllerInteractionDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/17.
//


// MARK: - SearchControllerInteractionDelegate Notes
/**

## SearchControllerInteractionDelegate 的重點筆記

`1. 負責處理 UISearchController 的交互：`
 
 - didUpdateSearchText：當使用者在搜尋欄中輸入或修改文字時，觸發此方法，適合用於即時過濾搜尋結果。
 - didCancelSearch：當使用者取消搜尋時，觸發此方法，適合用於清空結果、關閉搜尋界面等。

 ------
 
`2. 適用的場景：`
 
 - 當你需要將 UISearchController 的邏輯與主要視圖控制器分離時，這個協議非常適合使用。
 - 通過使用這個委託，可以讓 SearchViewController 保持簡潔，而由其他的 handler 或 manager 來處理搜尋的具體行為。

 ------

`3. 建議的使用方式：`
 
 - 在 SearchViewController 中設置此協議的委託對象，可以有效分離搜尋的邏輯處理與 UI 顯示，減少視圖控制器的責任範圍，使其更易於維護。
*/

import Foundation

/// SearchControllerInteractionDelegate 協議
///
/// - 負責處理 UISearchController 的交互行為。
/// - 適用於管理`搜尋文字的更新`、`搜尋取消`等與 UISearchController 相關的交互事件。
protocol SearchControllerInteractionDelegate: AnyObject {
    
    /// 當使用者更新搜尋文字時觸發
    ///
    /// - Parameter searchText: 使用者輸入的搜尋文字。
    /// - 說明：當使用者在搜尋欄中輸入或修改文字時，透過此方法通知代理進行相應的操作，例如過濾搜尋結果。
    func didUpdateSearchText(_ searchText: String)
    
    /// 當使用者取消搜尋時觸發
    /// 
    /// - 說明：當使用者點擊取消按鈕以結束搜尋時，透過此方法通知代理進行相應的操作，例如清空搜尋結果或還原 UI 狀態。
    func didCancelSearch()
}
