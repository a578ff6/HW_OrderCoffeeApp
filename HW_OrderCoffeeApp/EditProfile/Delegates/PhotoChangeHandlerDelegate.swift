//
//  PhotoChangeHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/8.
//

// MARK: - PhotoChangeHandlerDelegate 的用途與結合方式
/**
 
 ## PhotoChangeHandlerDelegate 的用途與結合方式
 
 * What

 - PhotoChangeHandlerDelegate 是一個專注於「處理更改大頭照」的協定，提供簡單的回調接口。
 - 將更改照片的邏輯集中在主控制器中，而非表格處理器或單元格內。
 
 ------------------------------
 
 * Why

 1.低耦合：

 - 單元格使用閉包通知事件，不直接處理具體業務邏輯。
 - 表格處理器通過 photoDelegate 將事件傳遞給主控制器。
 
 2.高內聚：

 - 單元格專注於顯示與用戶交互，表格處理器負責數據配置，主控制器則負責具體業務處理。
 
 3.靈活性：

 - 主控制器通過實現 PhotoChangeHandlerDelegate 可靈活處理照片邏輯（例如上傳到 Firebase 或更新模型數據）。
 
 ------------------------------

 * How

 - 在單元格中設置閉包事件（如 onChangePhotoButtonTapped）。
 - 在表格處理器中捕捉該事件，並使用 photoDelegate 將事件傳遞至主控制器。
 - 主控制器實現 PhotoChangeHandlerDelegate，集中處理更改照片的邏輯（如顯示照片選取器、上傳圖片、更新模型等）。
 
 * 設計結論
 
 - 使用協定（PhotoChangeHandlerDelegate）的結構，能在保持清晰責任分工的基礎上，實現靈活的事件處理。
 - 使用閉包與協定的結合方式，能進一步減少不同組件之間的直接依賴，提升代碼的可測試性與可維護性。
 */


// MARK: - (v)

import Foundation

/// `PhotoChangeHandlerDelegate` 協定，用於處理與用戶更改大頭照相關的行為回調。
/// - 功能定位：
///   1. 定義「更改大頭照」事件的行為接口，讓主控制器（如 `EditProfileViewController`）能夠監聽這類事件。
///   2. 分離表格處理器（`EditProfileTableHandler`）與大頭照處理的業務邏輯，促進模組化設計。
/// - 適用場景：
///   - 當用戶點擊「更改照片」按鈕時，觸發主控制器進行後續的照片選取、上傳和更新顯示。
protocol PhotoChangeHandlerDelegate: AnyObject {
    
    /// 處理用戶點擊「更改照片」按鈕的事件。
    /// - 使用場合：
    ///   - 在表格處理器中，通知主控制器觸發照片選取和相關邏輯處理。
    func didTapChangePhoto()
}
