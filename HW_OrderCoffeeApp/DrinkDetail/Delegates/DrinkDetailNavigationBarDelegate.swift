//
//  DrinkDetailNavigationBarDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/19.
//


// MARK: - 重點筆記：DrinkDetailNavigationBarDelegate
/**
 
 ## 重點筆記：DrinkDetailNavigationBarDelegate
 
 `* What`
 
 - `DrinkDetailNavigationBarDelegate` 是一個協議，定義了導航欄按鈕的點擊行為，負責將按鈕事件傳遞給相關對象。
 
 - 包含兩個事件方法：
 
 1.`分享按鈕`：觸發與分享功能相關的操作。
 2.`收藏按鈕`：切換收藏狀態並通知相關對象更新按鈕圖示或執行收藏邏輯。

 ------------------
 
 `* Why`
 
 `1.分離關注點：`
 
 - 把按鈕的交互行為與業務邏輯解耦，讓 DrinkDetailNavigationBarManager 專注於導航欄配置。
 
 `2.降低耦合性：`
 
 - 避免直接依賴特定的業務邏輯，提升代碼的靈活性與可擴展性。
 
 ------------------

 `* Who`
 
 `1.分享按鈕行為：`
 
 - 觸發 `didTapShareButton`，例如調用分享管理器進行內容分享。
 
 `2.收藏按鈕行為：`
 
 - 觸發 `didTapFavoriteButton`，由控制器調用收藏相關的業務邏輯，`切換狀態並更新 UI`。
 
 `3.步驟：`

 - 在 `DrinkDetailNavigationBarManager` 中，設置代理對象（ `DrinkDetailViewController`）。
 - 在控制器中實現 `DrinkDetailNavigationBarDelegate` 方法，處理按鈕點擊事件。
 
 ------------------

 `* 實現架構`
 
 [DrinkDetailNavigationBarManager]
          |
          v
 [DrinkDetailNavigationBarDelegate (Protocol)]
          |
          v
 [DrinkDetailViewController (Implements Delegate)]

 `* 總結`
 
 - DrinkDetailNavigationBarDelegate 提供了導航欄按鈕行為的統一接口。
 - 控制器通過實現協議，靈活處理分享與收藏邏輯，避免導航欄按鈕與業務邏輯過度耦合，提升代碼的可維護性與可讀性。
 */



import Foundation

/// `DrinkDetailNavigationBarDelegate`
///
/// ### 功能概述
/// `DrinkDetailNavigationBarDelegate` 定義了導航欄按鈕交互的代理協議，
/// 用於處理分享和收藏按鈕的點擊事件。
///
/// ### 設計目標
/// - 分離關注點：將按鈕的交互行為與具體的業務邏輯分離。
/// - 支援可測試性：利用代理模式，方便模擬按鈕點擊事件進行測試。
/// - 降低耦合性：避免 `DrinkDetailNavigationBarManager` 直接處理業務邏輯。
///
/// ### 功能說明
/// 1. 分享按鈕點擊：
///    - 通過 `didTapShareButton()` 將分享事件傳遞給控制器進行處理。
/// 2. 收藏按鈕點擊：
///    - 通過 `didTapFavoriteButton()` 將收藏事件傳遞給控制器進行處理。
protocol DrinkDetailNavigationBarDelegate: AnyObject {
    
    /// 分享按鈕點擊事件
    func didTapShareButton()
    
    /// 收藏按鈕點擊事件
    func didTapFavoriteButton()
    
}
