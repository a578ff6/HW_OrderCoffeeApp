//
//  StoreSelectionMapView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - 設計 MKMapView 的想法

/*
 ## 設置 StoreSelectionMapView 時，依據在地圖選擇界面中提供的功能與視圖結構的靈活性：

 1. StoreSelectionMapView: UIView，並添加 MKMapView：
 
    - 靈活的方式，尤其是如果想在地圖之上添加其他 UI 元素，例如搜索框、列表、按鈕或一些其他自定義的控制項。
 
    * 做法：
        - 創建一個自定義的 StoreSelectionMapView: UIView。
        - 在這個視圖中，可以添加一個 `MKMapView`，並設置地圖的大小和位置。
        - 如果需要添加其他 UI 元素（例如選擇按鈕、返回按鈕），可以很方便地組織所有的子視圖。
 
    * 優勢：
        - 更靈活，可以控制地圖的布局、與其他 UI 元素的相對位置。
        - 適合如果想在地圖之上展示店鋪列表，或者使用自定義的控制項來選擇店鋪。

 2. StoreSelectionMapView: MKMapView：
 
    - 如果界面主要就是顯示地圖，且不需要添加額外的 UI 控件，這樣做會比較簡單。
 
    * 做法：
        - 將 StoreSelectionMapView 直接設置為 MKMapView 的子類。
        - 所有地圖相關的設置和操作直接在這個視圖上進行。
 
    * 優勢：
        - 更簡單直接，因為地圖就是整個視圖。
        - 適合如果不打算添加其他 UI 控件，只想簡單展示地圖，並允許用戶點選標記（如星巴克店鋪）來選擇。

 3. 哪一種更合適：
 
    - 如果想要更多的 UI 控件和靈活性（如在地圖之上還要顯示店鋪列表、距離顯示或選擇按鈕），建議使用 StoreSelectionMapView: UIView，然後在其中嵌入一個 MKMapView。這樣可以根據需要自由設置不同 UI 元素的位置和樣式。
    - 如果只需要地圖本身，不需要添加其他的控制項，那麼可以直接使用 MKMapView 作為主視圖的類別（`StoreSelectionMapView: MKMapView`）。

 4. 總結建議：
 
    - 對於需求，考慮到可能還需要展示店鋪的詳細訊息（如電話、地址等）以及其他互動按鈕，因此使用 StoreSelectionMapView: UIView，並在其中嵌入一個 MKMapView。這樣更符合未來可能擴展功能的需求，也能讓用戶體驗更佳。
 */


import UIKit
import MapKit

/// 用於顯示店家選擇的自訂簡視圖
/// StoreSelectionMapView 包含一個 MKMapView 來幫助用戶選擇附近的店家
class StoreSelectionMapView: UIView {
    
    // MARK: - UI Elements
    
    let mapView = StoreSelectionMapView.createMapView()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMapView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    private func setupMapView() {
        addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Factory Method
    
    /// 創建並配置 MKMapView
    private static func createMapView() -> MKMapView {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true            // 顯示使用者的位置
        mapView.userTrackingMode = .follow          // 追蹤用戶位置
        return mapView
    }
}
