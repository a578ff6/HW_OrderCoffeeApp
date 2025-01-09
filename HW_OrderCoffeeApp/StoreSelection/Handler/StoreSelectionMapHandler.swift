//
//  StoreSelectionMapHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - StoreSelectionMapHandler 筆記
/**

 ## StoreSelectionMapHandler 筆記

 `* What`
 
 - `StoreSelectionMapHandler` 是一個處理地圖互動邏輯的類別，作為 `MKMapView` 的委派（Delegate）：
 
 1. 地圖標註管理：
    - 動態添加或移除地圖上的標註。
 
 2. 點選地圖標註：
    - 當使用者點擊標註時，通知控制器相關的店鋪資訊。
 
 3. 取消選取標註：
    - 當使用者取消標註選取時，通知控制器重置狀態。
 
 它透過代理模式（Delegate）將互動結果回傳給控制器，實現與控制器的低耦合設計。

 -------

 `* Why`
 
 1. 分離邏輯：
 
    - 將地圖互動邏輯從 `StoreSelectionViewController` 中抽離，專注處理地圖相關事件，提升模組化與可維護性。
    
 2. 簡化控制器職責：
 
    - 控制器只需關注具體的業務邏輯，而不需要處理複雜的地圖事件細節。

 3. 增強可測試性：
 
    - `StoreSelectionMapHandler` 的互動邏輯可以單獨測試，而不依賴控制器的其他功能。
 
 4. 高內聚性：
 
    - 地圖相關的功能（如標註管理、互動邏輯）集中在 `StoreSelectionMapHandler`，提升代碼結構的清晰度。
 
 -------

` * How`

 1. 代理協議設計：
 
    - 定義 `StoreSelectionMapHandlerDelegate`，包括：
      - `getStores`：提供地圖標註所需的店鋪資料。
      - `didSelectStore`：通知控制器某個店鋪被選取。
      - `didDeselectStore`：通知控制器取消選取狀態。
 
 2. 標註管理：
 
    - 提供 `addAnnotations(for:to:)` 方法，將店鋪數據轉換為標註並添加到地圖上。

 3. 事件處理：
 
    - 在 `mapView(_:didSelect:)` 中，獲取被選取的標註，查找對應的店鋪資料，並通知代理。
    - 在 `mapView(_:didDeselect:)` 中，通知代理重置狀態。

 3. 與控制器集成：
 
    - 將 `StoreSelectionMapHandler` 設置為地圖的委派。
    - 控制器作為 `StoreSelectionMapHandler` 的代理，實現具體的業務邏輯。
 

 -------

 `* 完整設計與程式碼整合`

 `- Delegate 協議`

 ```swift
 /// 負責處理地圖與門市互動的代理協議
 protocol StoreSelectionMapHandlerDelegate: AnyObject {
     
     /// 獲取所有店鋪資料
     func getStores() -> [Store]
     
     /// 當使用者選取地圖上的店鋪標記時被調用
     func didSelectStore(_ store: Store)
     
     /// 當使用者取消選取地圖上的店鋪標記時被調用
     func didDeselectStore()
 }
 ```

 `- StoreSelectionViewController 集成`

 ```swift
 // MARK: - Setup Map Interaction
 private func setupMapInteractionHandler() {
     storeSelectionView.storeSelectionMapView.delegate = storeSelectionMapHandler
     storeSelectionMapHandler.storeSelectionMapHandlerDelegate = self
 }

 // MARK: - StoreSelectionMapHandlerDelegate
 extension StoreSelectionViewController: StoreSelectionMapHandlerDelegate {
     
     func getStores() -> [Store] {
         return stores
     }
     
     func didSelectStore(_ store: Store) {
         guard let storeInfoVC = floatingPanelController?.contentViewController as? StoreInfoViewController else { return }
         
         let userLocation = locationManagerHandler.currentUserLocation
         let viewModel = StoreInfoViewModel(store: store, userLocation: userLocation)
         
         storeInfoVC.setState(.details(viewModel: viewModel))
         storeInfoVC.storeSelectionResultDelegate = self
         
         floatingPanelController?.move(to: .half, animated: true)
     }
     
     func didDeselectStore() {
         guard let storeInfoVC = floatingPanelController?.contentViewController as? StoreInfoViewController else { return }
         
         storeInfoVC.setState(.initial(message: "請點選門市地圖取得詳細資訊"))
         floatingPanelController?.move(to: .tip, animated: true)
     }
 }
 ```

 -------

 `* 優化效益`
 
 1. 模組化設計：
 
    - 地圖事件與業務邏輯解耦，提升代碼結構的清晰度。
    
 2. 高內聚、低耦合：
 
    - `StoreSelectionMapHandler` 專注地圖事件，控制器負責業務邏輯。

 3. 靈活擴展：
 
    - 未來若需新增地圖互動行為（如拖動標註），僅需擴展 `StoreSelectionMapHandler` 即可。
 */


// MARK: - StoreSelectionMapHandler 職責
/**
 
 ## StoreSelectionMapHandler 職責

 1. `StoreSelectionViewController`
 
 - 作為核心協調者，負責管理 `StoreSelectionView` 和 `StoreSelectionMapHandler`。
 - 通過 `StoreSelectionMapHandlerDelegate` 接收地圖交互事件的回調。

 2. `StoreSelectionView`
 
 - 作為容器視圖，包含 `StoreSelectionMapView` 並負責其布局。
 - 提供與 `StoreSelectionViewController` 的視圖交互。

 3. `StoreSelectionMapHandler`
  
 - 負責地圖交互邏輯，例如點擊標註、取消選取標註等行為。
 - 通過 `StoreSelectionMapHandlerDelegate` 與 `StoreSelectionViewController` 通信，通知地圖交互事件。

 4. `StoreSelectionMapHandlerDelegate`
   
 - 定義了 `StoreSelectionMapHandler` 與 `StoreSelectionViewController` 的交互協議，用於傳遞地圖交互事件。
 */


// MARK: - `StoreSelectionMapHandler` 與 `StoreSelectionMapView` 分離設計的筆記
/**
 
 ## `StoreSelectionMapHandler` 與 `StoreSelectionMapView` 分離設計的筆記

 - 主要是在重構的過程中，因為我將`StoreSelectionMapView`設置成獨立的class，而不是 Factory Method，因此在思考是否要將`StoreSelectionMapHandler`調整到`StoreSelectionMapView`。
 
 -------------

 `* What`

 - `StoreSelectionMapHandler` 是專門負責地圖交互邏輯（如標註選取與取消）的處理器。
 - `StoreSelectionMapView` 繼承自 `MKMapView`，負責地圖的靜態配置（如顯示用戶位置、追蹤模式）。
 - 兩者分離的設計符合單一職責原則，讓視圖專注於渲染，邏輯處理則由專屬的處理器負責。

 -------------

 `* Why`

 `1. 單一職責原則（SRP）：`
 
    - 保持 `StoreSelectionMapView` 專注於靜態配置，避免視圖同時承擔交互邏輯，避免變成「胖類別」。
    - 將交互邏輯放入 `StoreSelectionMapHandler`，讓地圖交互與視圖渲染邏輯分離。

 2. 降低耦合性：
 
    - 視圖與邏輯分離，`StoreSelectionMapView` 不需要知道交互處理的細節，只專注於展示。
    - `StoreSelectionMapHandler` 可獨立測試和替換，而不影響視圖的行為。

 3. 提升擴展性：
 
    - 若需要增加地圖的交互行為（如多選標註或拖放功能），可以直接在 `StoreSelectionMapHandler` 擴展，視圖無需修改。
    - `StoreSelectionMapView` 可重用於其他場景，而不攜帶特定的交互邏輯。

 4. 提升可測試性：
 
    - 分離後，`StoreSelectionMapHandler` 的交互邏輯可以單獨測試，而視圖保持簡單，減少測試難度。

 -------------

 `* How`

 `1. 保持分層設計：`
 
    - `StoreSelectionMapView`：
      - 只負責靜態配置（如顯示用戶位置和追蹤模式）。
      - 通過代理將交互事件委派給 `StoreSelectionMapHandler`。
 
    - `StoreSelectionMapHandler`：
      - 實現 `MKMapViewDelegate`，專注於處理地圖的交互事件（如點擊標註）。
      - 通過 `StoreSelectionMapHandlerDelegate` 與控制器通信，將事件傳遞到 `StoreSelectionViewController`。

` 2. 代碼實現：`
 
    - 在 `StoreSelectionMapView` 中設置委派，將交互邏輯轉交給 `StoreSelectionMapHandler`。
 
    ```
    // StoreSelectionViewController
    private func setupMapInteractionHandler() {
        // 設置 StoreSelectionMapView 的 delegate 為 StoreSelectionMapHandler
        storeSelectionView.storeSelectionMapView.delegate = storeSelectionMapHandler
        // 設置 MapHandler 的代理為 ViewController
        storeSelectionMapHandler.storeSelectionMapHandlerDelegate = self
    }
    ```
 
    - 在 `StoreSelectionMapHandler` 中實現 `MKMapViewDelegate`，專注於處理交互行為。
 
    - 在 `StoreSelectionViewController` 中協調 `StoreSelectionMapHandler` 和 `StoreSelectionMapView`。
 */


// MARK: - (v)

import UIKit
import MapKit

/// `StoreSelectionMapHandler`
///
/// ### 核心職責
/// - 管理地圖視圖的交互行為，包括點選和取消點選店鋪標註（`Annotation`）。
/// - 添加或移除地圖上的標註，集中處理地圖操作邏輯。
/// - 透過 `StoreSelectionMapHandlerDelegate` 與 `StoreSelectionViewController` 進行通信。
///
/// ### 核心功能
/// 1. 添加店鋪標註：
///    - 根據提供的店鋪數據，將標註添加到地圖視圖上。
/// 2. 點選交互：
///    - 使用者點選地圖標註時，查找對應店鋪資料，並通知控制器進行處理。
/// 3. 取消點選交互：
///    - 當使用者取消選取地圖標註時，通知控制器重置視圖狀態。
///
/// ### 設計目標
/// - 單一責任：專注於地圖操作與交互邏輯，減少控制器的代碼量與複雜度。
/// - 高可擴展性：未來若需新增地圖功能（如篩選店鋪或自定義標註），可直接在此處擴展。
/// - 低耦合：通過代理模式與控制器交互，保持代碼模組化設計。
class StoreSelectionMapHandler: NSObject {
    
    // MARK: - Properties
    
    /// 代理，用於與 `StoreSelectionViewController` 溝通
    ///
    /// - 透過 `StoreSelectionMapHandlerDelegate`，將地圖上的交互事件（如選擇店鋪）回傳至控制器。
    weak var storeSelectionMapHandlerDelegate: StoreSelectionMapHandlerDelegate?
    
    // MARK: - Public Methods
    
    /// 添加店鋪標註至地圖
    ///
    /// ### 功能說明
    /// - 根據傳入的店鋪數據，生成對應的 `MKPointAnnotation`，並添加到地圖視圖。
    ///
    /// - Parameters:
    ///   - stores: 店鋪數據陣列
    ///   - mapView: 地圖視圖，目標標註將添加至此視圖
    func addAnnotations(for stores: [Store], to mapView: MKMapView) {
        let annotations = stores.map { store -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = store.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: store.location.latitude, longitude: store.location.longitude)
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
}

// MARK: - MKMapViewDelegate
extension StoreSelectionMapHandler: MKMapViewDelegate {
    
    /// 當使用者點選地圖上的店鋪標記時觸發
    /// - Parameters:
    ///   - mapView: 觸發事件的地圖視圖
    ///   - view: 被選取的標註視圖
    ///
    /// 功能：
    /// 1. 確認選取的標註是否有效，並透過代理獲取所有店鋪資料。
    /// 2. 查找對應的店鋪資訊（根據標註的標題）。
    /// 3. 通知代理（StoreSelectionViewController）選取的店鋪資訊。
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation,
              let stores = storeSelectionMapHandlerDelegate?.getStores(),
              let store = stores.first(where: { $0.name == annotation.title })
        else {
            print("未找到對應的店鋪資料或 annotation 無效")
            return
        }
        
        // 通知代理已選取的店鋪
        storeSelectionMapHandlerDelegate?.didSelectStore(store)
    }
    
    /// 當大頭針被取消選取時觸發
    /// - Parameters:
    ///   - mapView: 觸發事件的地圖視圖
    ///   - view: 被取消選取的標註視圖
    ///
    /// 功能：
    /// 1. 通知代理（ `StoreSelectionViewController`），用戶已取消選取的動作。
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        storeSelectionMapHandlerDelegate?.didDeselectStore()
    }
    
}
