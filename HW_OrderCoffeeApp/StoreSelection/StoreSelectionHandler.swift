//
//  StoreSelectionHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

/*
 ## StoreSelectionHandler 重點筆記

 1. 類別說明
    - StoreSelectionHandler 是用於處理地圖視圖 (MKMapView) 上店鋪選擇互動的物件。
    - 負責處理與地圖相關的事件，例如使用者點選地圖上的標註（店鋪）時的處理邏輯。
 
 2. 使用的屬性
    - delegate：用於和 StoreSelectionViewController 進行溝通，負責傳遞店鋪資料及顯示店鋪詳細信息。
 
 3. 主要方法
    
    * mapView(_:didSelect:)：
        - 當使用者在地圖上選擇某個標註時觸發。
        - 透過代理來取得所有店鋪資料，然後查找與所選標註匹配的店鋪。
        - 使用代理來取得該店鋪的今日營業時間並顯示詳細資料。
 
 4. Delegate 使用好處
    - 職責分離：StoreSelectionHandler 只負責地圖互動的處理，而不需要知道店鋪的資料是從哪裡來的，這些邏輯由代理 (StoreSelectionViewController) 處理。
    - 降低耦合度：使用代理讓 StoreSelectionHandler 和 StoreSelectionViewController 分離，保持了代碼的模組化與清晰度。
 
 5. 代理模式的運作
    - StoreSelectionHandlerDelegate 用於定義代理需要實作的方法，包括取得店鋪資料、取得營業時間以及顯示店鋪資訊。
    - StoreSelectionHandler 在需要店鋪資料或顯示信息時，會呼叫這些代理方法，由 StoreSelectionViewController 負責具體的實作和邏輯處理。
 
 6. 為什麼這麼設計
    - 這種設計增加模組的靈活性，使得地圖上的互動邏輯可以獨立處理，不需要關心資料的管理和顯示。
    - 有效減少了 ViewController 的負擔，將地圖相關的選擇邏輯委派給專門的 Handler 處理。
 */

import UIKit
import MapKit

/// 店鋪選擇的處理，負責處理地圖上的相關操作
class StoreSelectionHandler: NSObject {

    // MARK: - Properties

    /// 用於與 StoreSelectionViewController 進行溝通的代理
    weak var delegate: StoreSelectionHandlerDelegate?
}

// MARK: - MKMapViewDelegate
extension StoreSelectionHandler: MKMapViewDelegate {
    
    /// 當使用者點選地圖上的店鋪標記時觸發
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        // 使用 delegate 來取得 stores 並查找對應的店鋪
        guard let store = delegate?.getStores().first(where: { $0.name == annotation.title }) else {
            print("未找到對應的店鋪資料")
            return
        }
        
        // 使用 delegate 來取得店鋪的今日營業時間
        let todayHours = delegate?.getTodayOpeningHours(for: store.id) ?? "營業時間未提供"
        
        // 使用 delegate 來顯示店鋪詳細資料
        delegate?.presentStoreDetailsAlert(for: store, todayOpeningHours: todayHours)
    }
}
