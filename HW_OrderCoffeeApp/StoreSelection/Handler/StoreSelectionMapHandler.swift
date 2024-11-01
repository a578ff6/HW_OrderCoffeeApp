//
//  StoreSelectionMapHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

/*
 ## StoreSelectionMapHandler.swift 重點筆記

 1. 類別說明
    - StoreSelectionMapHandler 是用於處理地圖視圖 (MKMapView) 上店鋪選擇互動的物件。
    - 負責處理與地圖相關的事件，例如使用者點選地圖上的標註（店鋪）時的處理邏輯。
 
 2. 使用的屬性
    - delegate：用於和 StoreSelectionViewController 進行溝通，負責傳遞店鋪資料及顯示店鋪詳細信息。
 
 3. 主要方法
    
    * mapView(_:didSelect:)：
        - 當使用者在地圖上選擇某個標註時觸發。
        - 透過代理來取得所有店鋪資料，然後查找與所選標註匹配的店鋪。
        - 通知控制器更新選定的店鋪資訊，使用 FloatingPanel 顯示該店鋪的詳細資訊。
 
    * mapView(_:didDeselect:)：
       - 當店鋪的標註被取消選取時，透過代理通知控制器收起浮動面板，並將顯示內容重置為初始狀態。
 
 4. Delegate 使用好處
    
    * 職責分離：
        - StoreSelectionMapHandler 只負責地圖互動的處理，而不需要知道店鋪的資料是從哪裡來的，這些邏輯由代理 (StoreSelectionViewController) 處理。
        - 地圖交互和店鋪詳細資料顯示的邏輯相互分離，保持了程式碼的模組化和高可維護性。
 
    * 降低耦合度：
        - 使用代理讓 StoreSelectionMapHandler 和 StoreSelectionViewController 分離，保持了代碼的模組化與清晰度。使得地圖交互的修改不會影響到店鋪資料的管理和顯示。
 
 5. 代理模式的運作
    - StoreSelectionMapHandlerDelegate 用於定義代理需要實作的方法，包括取得店鋪資料、取得營業時間以及顯示店鋪資訊。
    - StoreSelectionMapHandler 在需要店鋪資料或顯示信息時，會呼叫這些代理方法，由 StoreSelectionViewController 負責具體的實作和邏輯處理。
    - - 當店鋪被選取時，控制器會使用 FloatingPanel 來顯示詳細資訊，避免了使用臨時彈窗的方式，提供更好的用戶體驗。
 
 6. 為什麼這麼設計
 
    * 模組靈活性：
        - 地圖上的互動邏輯可以獨立處理，不需要關心資料的管理和顯示。
        - 在地圖上選擇店鋪後，由控制器負責展示浮動面板中的店鋪詳細資訊，有助於減少 `ViewController` 中地圖交互的負擔。
 
    * 使用浮動面板提升用戶體驗：
        - 使用 FloatingPanel 來持續展示店鋪詳細資訊，而不是使用臨時的彈出視窗，這樣用戶可以更方便地檢視和交互。
 */

import UIKit
import MapKit

/// 店鋪選擇的處理，負責處理地圖上的相關操作
class StoreSelectionMapHandler: NSObject {

    // MARK: - Properties

    /// 用於與 StoreSelectionViewController 進行溝通的代理
    weak var delegate: StoreSelectionMapHandlerDelegate?
}

// MARK: - MKMapViewDelegate
extension StoreSelectionMapHandler: MKMapViewDelegate {
    
    /// 當使用者點選地圖上的店鋪標記時觸發
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        // 使用 delegate 來取得 stores 並查找對應的店鋪
        guard let store = delegate?.getStores().first(where: { $0.name == annotation.title }) else {
            print("未找到對應的店鋪資料")
            return
        }
        
        // 調用 didSelectStore 方法通知控制器
        delegate?.didSelectStore(store)
    }
    
    /// 當大頭針被取消選取時通知代理
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        delegate?.didDeselectStore()
    }
    
}
