//
//  LocationManagerHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/27.
//

// MARK: - LocationManagerHandlerDelegate 重點筆記

/*
 ## LocationManagerHandlerDelegate 重點筆記
 
 1. 協議簡介：
    - LocationManagerHandlerDelegate 用於與 LocationManagerHandler 進行溝通，特別是在用戶位置更新或位置權限變更的情況下。
 
 2. 協議方法：
    
    * didUpdateUserLocation(location:)：
        - 功能：在成功獲取到用戶的位置後調用，將最新的位置資訊傳遞給代理對象。
        - 參數：location 是一個 CLLocation 物件，包含用戶的當前經緯度及其他相關資訊。
 
    * didReceiveLocationAuthorizationDenied()：
        - 功能：當用戶拒絕授權位置權限或授權受限時調用，用於通知代理對象處理相應的 UI 提示，例如顯示一個警告框，引導用戶前往開啟位置授權。
 
    * 使用情境：
        - 當需要分離定位邏輯和視圖控制器時，LocationManagerHandler 可以使用此協議將定位結果通知給視圖控制器。
        - 視圖控制器通過實現此協議，可以根據用戶的位置更新做出反應，或在位置權限被拒絕時，適當地向用戶顯示提示訊息。
 
    * 協議的設置：
        - 清晰的責任劃分：LocationManagerHandler 負責處理位置獲取的具體邏輯，而視圖控制器負責 UI 顯示和用戶交互。通過代理協議，可以將兩者之間的溝通簡化，使各自專注於自己的職責。
        - 提高可重用性：不只 StoreSelectionViewController 可以使用此協議， App 中的其他視圖控制器也可以實現這個協議來獲取位置更新或處理授權問題。
 */

import CoreLocation

/// 用於與 LocationManagerHandler 進行溝通的代理協議
/// - 提供了兩個主要方法，用來通知位置更新或權限被拒絕的情況。
protocol LocationManagerHandlerDelegate: AnyObject {
    
    /// 當用戶位置成功更新時調用
    /// - Parameter location: 用戶的最新位置
    func didUpdateUserLocation(location: CLLocation)

    /// 當用戶拒絕位置授權時調用
    /// - 提示視圖控制器顯示相關訊息，引導用戶開啟授權
    func didReceiveLocationAuthorizationDenied()

}
