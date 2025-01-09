//
//  StoreSelectionView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - 設計 MKMapView 的想法
/**
 
 ## 設置 StoreSelectionView 時，依據在地圖選擇界面中提供的功能與視圖結構的靈活性：

 `1. StoreSelectionView: UIView，並添加 MKMapView：`
 
    - 靈活的方式，尤其是如果想在地圖之上添加其他 UI 元素，例如搜索框、列表、按鈕或一些其他自定義的控制項。
 
    * 做法：
        - 創建一個自定義的 StoreSelectionView: UIView。
        - 在這個視圖中，可以添加一個 `MKMapView`，並設置地圖的大小和位置。
        - 如果需要添加其他 UI 元素（例如選擇按鈕、返回按鈕），可以很方便地組織所有的子視圖。
 
    * 優勢：
        - 更靈活，可以控制地圖的布局、與其他 UI 元素的相對位置。
        - 適合如果想在地圖之上展示店鋪列表，或者使用自定義的控制項來選擇店鋪。

 `2. StoreSelectionView: MKMapView：`
 
    - 如果界面主要就是顯示地圖，且不需要添加額外的 UI 控件，這樣做會比較簡單。
 
    * 做法：
        - 將 StoreSelectionView 直接設置為 MKMapView 的子類。
        - 所有地圖相關的設置和操作直接在這個視圖上進行。
 
    * 優勢：
        - 更簡單直接，因為地圖就是整個視圖。
        - 適合如果不打算添加其他 UI 控件，只想簡單展示地圖，並允許用戶點選標記（如星巴克店鋪）來選擇。

 3. 哪一種更合適：
 
    - 如果想要更多的 UI 控件和靈活性（如在地圖之上還要顯示店鋪列表、距離顯示或選擇按鈕），使用 StoreSelectionView: UIView，然後在其中嵌入一個 MKMapView。這樣可以根據需要自由設置不同 UI 元素的位置和樣式。
    - 如果只需要地圖本身，不需要添加其他的控制項，那麼可以直接使用 MKMapView 作為主視圖的類別（`StoreSelectionView: MKMapView`）。

 4. 總結建議：
 
    - 對於需求，考慮到可能還需要展示店鋪的詳細訊息（如電話、地址等）以及其他互動按鈕，因此使用 StoreSelectionView: UIView，並在其中嵌入一個 MKMapView。這樣更符合未來可能擴展功能的需求，也能讓用戶體驗更佳。
 */


// MARK: - StoreSelectionView 筆記
/**
 
 ## StoreSelectionView 筆記


 `* What`

 - `StoreSelectionView` 是一個自訂的容器視圖 (`UIView`)，專門用於組織和呈現地圖視圖，幫助用戶選擇附近的店家。它的主要功能是：

 1. 容器視圖：包含 `StoreSelectionMapView`（自訂的地圖視圖）。
 2. 視圖布局：透過 Auto Layout，讓地圖視圖填滿整個容器，並適配安全區域。

 ---

 `* Why`

 `1. 視圖組織與分離：`
 
 - 將地圖視圖與其他功能（如按鈕、標題等）進行解耦，確保每個組件有明確的職責。
 - 使用容器視圖 `StoreSelectionView` 統一管理布局和子視圖，提升結構清晰度與可維護性。

 `2. 支援擴展性：`
   
 - 若未來需要添加其他 UI 元素（如按鈕、標題等），可以直接在 `StoreSelectionView` 中擴展，而無需修改地圖相關邏輯。
 - 確保 `StoreSelectionMapView` 專注於地圖邏輯，而容器視圖負責視圖的組織與布局。

 `3. 簡化代碼邏輯：`
  
 - 將地圖視圖的初始化與布局統一處理，減少外部重複編寫布局邏輯的需求。
 - 集中控制子視圖的約束與層級，提升代碼的可讀性。

 ---

 `* How`

 1. 類別設計：
 
 - 繼承自 `UIView`，專注於子視圖的組織與布局，保持單一責任。
 - 包含 `StoreSelectionMapView` 作為地圖子視圖。

 2. 子視圖管理：
 
 - 將 `StoreSelectionMapView` 添加為子視圖。
 - 使用 Auto Layout 約束確保地圖視圖填滿容器，並適配安全區域。

 ---

 `* 範例場景`

 - 在應用中，`StoreSelectionView` 作為主要的店家選擇介面，包含地圖，並可擴展添加其他功能（如確認按鈕、返回按鈕）。
 - 透過統一布局，保證地圖視圖與其他子視圖協調一致，提供用戶友好的界面體驗。

*/


// MARK: - (v)

import UIKit

/// 用於顯示店家選擇的自訂視圖
/// StoreSelectionView 是一個容器視圖，內含 StoreSelectionMapView，專門用於呈現附近的店家地圖，並提供必要的視圖布局。
class StoreSelectionView: UIView {
    
    // MARK: - UI Elements
    
    /// StoreSelectionMapView：自訂地圖視圖，用於顯示店家位置
    private(set) var storeSelectionMapView = StoreSelectionMapView()
    
    // MARK: - Initializer
    
    /// 使用程式碼初始化 StoreSelectionView
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置子視圖和背景顏色
    private func setupView() {
        backgroundColor = .systemBackground
        addSubview(storeSelectionMapView)
        NSLayoutConstraint.activate([
            storeSelectionMapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            storeSelectionMapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            storeSelectionMapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            storeSelectionMapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
