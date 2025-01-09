//
//  StoreSelectionMapView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/6.
//


// MARK: - StoreSelectionMapView 筆記
/**
 
 ## StoreSelectionMapView 筆記

 `* What`
 
 - `StoreSelectionMapView` 是一個自訂的地圖視圖，繼承自 `MKMapView`，專門用於顯示店家位置和相關地圖資訊。
 - 它只負責地圖的靜態設定和行為（例如顯示使用者位置、追蹤模式），不處理地圖的交互邏輯（如點擊標註）。

 ---

 `* Why`
 
` 1. 單一職責原則：`
 
 - `StoreSelectionMapView` 的責任僅限於靜態配置，不包含交互邏輯，確保地圖視圖和交互處理分離。
 - 地圖的交互邏輯由 `StoreSelectionMapHandler` 負責，讓代碼更易於維護和測試。

` 2. 與交互分離：`
   
 - 將地圖的交互處理移至 `StoreSelectionMapHandler`，通過代理模式與控制器通信，減少耦合。

 ---

 `* How`
 
 `1. 基於 MKMapView 繼承：`
 
 - 繼承自 `MKMapView`，專注於地圖的靜態行為，避免與交互邏輯混合。

` 2. 設定地圖行為：`
 
 - `translatesAutoresizingMaskIntoConstraints = false`：支援自訂 Auto Layout。
 - `showsUserLocation = true`：啟用使用者位置顯示。
 - `userTrackingMode = .follow`：設置地圖自動追蹤使用者位置。

 `3. 與其他組件配合：`
   
 - 交互邏輯由 `StoreSelectionMapHandler` 處理，該處理器通過 `MKMapViewDelegate` 管理交互事件。
 - `StoreSelectionViewController` 協調 `StoreSelectionMapView` 和 `StoreSelectionMapHandler` 的交互。

` 4. 未來擴展：`
  
 - 可根據需求，在 `StoreSelectionMapHandler` 中處理地圖交互事件，例如標註點擊或拖動事件。
 - 保持 `StoreSelectionMapView` 專注於靜態行為，確保代碼清晰易懂。

 ---

 `* 範例場景`
 
 - `StoreSelectionMapView` 用於店家選擇場景，作為主要地圖視圖，顯示附近的店家位置。
 - 與 `StoreSelectionView` 或 `StoreSelectionViewController` 配合使用，形成完整的用戶介面。
 - 通過 `StoreSelectionMapHandler` 處理點擊標註等交互邏輯，實現職責分離。

 */


// MARK: - (v)

import UIKit
import MapKit

/// 用於顯示店家選擇的地圖視圖
/// StoreSelectionMapView 繼承自 MKMapView，並負責處理地圖相關的設定與行為。
/// 此類別著重於地圖的基本設定，例如顯示使用者位置與追蹤模式。
class StoreSelectionMapView: MKMapView {
    
    // MARK: - Initializer
    
    /// 以程式碼初始化地圖視圖
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMapView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置地圖視圖的初始設定
    /// 包含以下功能：
    /// 1. 顯示使用者當前位置。
    /// 2. 啟用使用者位置追蹤模式（跟隨模式）。
    private func setupMapView() {
        translatesAutoresizingMaskIntoConstraints = false
        showsUserLocation = true
        userTrackingMode = .follow      
    }
    
}
