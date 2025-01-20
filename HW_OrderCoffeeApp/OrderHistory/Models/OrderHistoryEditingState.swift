//
//  OrderHistoryEditingState.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/17.
//


// MARK: - OrderHistoryEditingState 筆記
/**
 
 ## OrderHistoryEditingState 筆記

 ---

 `* What`
 
 - `OrderHistoryEditingState` 是一個枚舉，用於表示 `OrderHistory` 導航欄的不同編輯狀態。

 - 狀態定義：
 
   - `normal`：正常模式，顯示排序和編輯按鈕。
   - `editing(hasSelection: Bool)`：編輯模式，顯示完成和刪除按鈕，並根據 `hasSelection` 判斷刪除按鈕是否啟用。

 - 功能：
 
   - 為導航欄按鈕配置提供統一的邏輯基礎。
   - 簡化不同狀態下導航按鈕的更新和切換。

 ---

 `* Why`
 
 1. 解耦狀態邏輯與按鈕配置：
 
    枚舉的設計可以清晰地分離導航欄的狀態與具體的按鈕邏輯，避免多層 `if-else` 判斷，提高程式的可讀性和可維護性。

 2. 提高擴展性：
 
    使用枚舉可以方便地新增其他狀態（例如篩選模式），而不需要大幅修改既有邏輯。

 3. 簡化狀態管理：
 
    - 明確區分正常模式與編輯模式的行為和按鈕配置。
    - 通過 `hasSelection` 動態控制刪除按鈕的啟用狀態。

 4. 提升可測試性：
 
    - 枚舉的結構化設計讓開發者可以更方便地針對不同狀態進行單元測試，確保按鈕行為與設計一致。

 -----------

 `* How`
 
 1. 使用場景：
 
    - 正常模式：
 
      ```swift
      updateNavigationBar(for: .normal)
      // 顯示排序按鈕與編輯按鈕。
      ```
 
    - 編輯模式：
 
      ```swift
      updateNavigationBar(for: .editing(hasSelection: true))
      // 顯示完成按鈕與刪除按鈕，並啟用刪除按鈕。
      ```

 ---
 
 2. 應用於導航邏輯：
 
    - 在 `OrderHistoryNavigationBarManager` 中：
 
      ```swift
      func updateNavigationBar(for state: OrderHistoryEditingState) {
          switch state {
          case .normal:
              // 設置正常狀態的按鈕
          case .editing(let hasSelection):
              // 根據選取狀態設置按鈕
          }
      }
      ```

 ---

 3. 狀態控制簡化邏輯：
 
    - 在按鈕操作中直接切換狀態：
 
      ```swift
     @objc private func editButtonTapped() {
         let newState = orderHistoryEditingHandler?.toggleEditingMode() ?? .normal
         updateNavigationBar(for: newState)
     }
      ```

 ---

 `* 核心價值`
 
 - 透過 `狀態枚舉` 將導航邏輯清晰化。
 - 增強程式的 **擴展性、測試性**，並簡化 **狀態管理** 的實作。
 */




// MARK: - (v)

import Foundation


/// 表示導航欄的編輯狀態
///
/// 此枚舉定義了 `OrderHistory` 導航欄的兩種狀態：
///
/// - `normal`：正常模式，用於顯示排序和編輯按鈕，適合非編輯模式的情境。
/// - `editing(hasSelection: Bool)`：編輯模式，用於顯示完成和刪除按鈕，並根據是否有選取的項目控制刪除按鈕的啟用狀態。
///
/// ### 功能與用途
/// - 用於更新導航欄按鈕配置，根據當前模式（正常或編輯）及用戶行為（如選取行）調整按鈕狀態。
///
/// ### 設計優點
/// - 簡化邏輯： 透過枚舉定義狀態，清晰地表達不同情境下的導航欄配置需求。
/// - 高擴展性： 未來可方便地新增其他狀態（如過濾模式）而不影響現有邏輯。
///
/// ### 使用場景
/// 1. 當用戶進入編輯模式時，切換狀態為 `.editing(hasSelection: false)` 並顯示刪除按鈕、離開按鈕。
/// 2. 當用戶退出編輯模式時，切換狀態為 `.normal`，恢復排序和編輯按鈕。
///
/// ### 典型用法
/// 在 `OrderHistoryNavigationBarManager` 中根據狀態切換按鈕配置：
///
/// ```swift
/// updateNavigationBar(for: .normal) // 切換到正常模式
/// updateNavigationBar(for: .editing(hasSelection: true)) // 編輯模式，且有選中項目
/// ```
enum OrderHistoryEditingState {
    
    /// 正常模式
    ///
    /// - 功能：顯示排序和編輯按鈕。
    case normal
    
    /// 編輯模式
    ///
    /// - 參數：
    ///   - `hasSelection`: 表示當前是否有選中的行，用於控制刪除按鈕的啟用狀態。
    ///
    /// - 功能：顯示完成和刪除按鈕。
    case editing(hasSelection: Bool)
    
}
