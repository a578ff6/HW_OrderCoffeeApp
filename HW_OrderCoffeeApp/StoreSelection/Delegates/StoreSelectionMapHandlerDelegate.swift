//
//  StoreSelectionMapHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/26.
//


// MARK: - StoreSelectionMapHandlerDelegate 筆記
/**
 
 ## StoreSelectionMapHandlerDelegate 筆記

 ---

 `* What`

 - `StoreSelectionMapHandlerDelegate` 是一個代理協議，用於協調 `StoreSelectionMapHandler` 與 `StoreSelectionViewController` 的互動。其核心功能是：
 
 1. 提供店鋪資料：讓地圖交互邏輯能夠檢索到所有店鋪資料。
 2. 處理選取事件：當使用者選取或取消選取地圖上的店鋪標記時，通知控制器進行視圖更新或其他邏輯處理。

 協議方法包含：
 
 - `getStores()`：
 
    - 功能：取得所有店鋪的資料，通常用於在地圖上標註所有店鋪位置。
    - 回傳：返回一個包含所有 Store 的陣列，讓 StoreSelectionMapHandler 可以透過這些資料進行操作。
 
 - `didSelectStore(_:)`：
 
    - 功能：通知控制器用戶選擇了地圖上的某個店鋪。
    - 參數：store，被選定的店鋪，包含名稱、地址、電話等資料。
    - 用途：用戶點擊地圖上的店鋪標記時，會觸發此方法。通常會用於 `FloatingPanel` 中展示選定店鋪的詳細資訊。

 - `didDeselectStore()`：通知控制器使用者取消選取店鋪標記。
 
    - 功能：通知控制器使用者取消選取店鋪標記。
    - 用途：控制器在接收到取消選取的通知後，將 FloatingPanel 收起並重置其內容為初始狀態。

 ---

 `* Why`

 1. 職責分離：
 
    - `StoreSelectionMapHandler` 專注於地圖交互邏輯，例如點擊或取消標記，而不直接處理數據來源。
    - `StoreSelectionViewController` 負責資料管理與視圖更新，代理協議確保兩者之間的溝通與解耦。

 2. 提高靈活性與可擴展性：
 
    - 使用代理模式避免地圖邏輯與具體資料耦合，讓資料的來源（如 Firebase、Mock Data）更易替換。
    - 確保模組間的獨立性，讓地圖交互邏輯能適配不同的控制器或資料結構。

 3. 簡化維護：
 
    - 地圖交互處理邏輯變更時，只需更新 `StoreSelectionMapHandler`，而控制器與資料邏輯不受影響。

 4. 一致的用戶體驗：
 
    - 通過代理方法將選取或取消事件即時通知控制器，確保地圖與店鋪資訊顯示同步。

 ---

 `* How`

 `1. 定義協議：`
 
    - 在協議中定義三個核心方法，分別用於獲取店鋪資料、通知選取與取消選取事件。

    ```swift
    protocol StoreSelectionMapHandlerDelegate: AnyObject {
        /// 獲取所有店鋪資料
        func getStores() -> [Store]
        
        /// 當使用者選取某個店鋪時觸發
        func didSelectStore(_ store: Store)
        
        /// 當使用者取消選取店鋪時觸發
        func didDeselectStore()
    }
    ```

` 2. 控制器實現協議：`
 
    - `StoreSelectionViewController` 實現協議方法，提供資料並處理選取事件。

    ```swift
    extension StoreSelectionViewController: StoreSelectionMapHandlerDelegate {
        func getStores() -> [Store] {
            return stores
        }
        
        func didSelectStore(_ store: Store) {
            // 更新 FloatingPanel 或顯示選定店鋪的詳細資訊
        }
        
        func didDeselectStore() {
            // 重置 FloatingPanel 或恢復至初始狀態
        }
    }
    ```

 `3. 地圖交互邏輯：`
 
    - 在 `StoreSelectionMapHandler` 中，透過代理方法獲取資料與回傳事件，保持地圖交互與數據管理的分離。

    ```swift
     func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
         
         // 確認 annotation 有效，並從代理中獲取店鋪列表
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

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        storeSelectionMapHandlerDelegate?.didDeselectStore()
    }
    ```

` 4. 結合資料與視圖更新：`
 
    - 當用戶選取地圖標記時，控制器使用代理方法回傳的資料更新 `FloatingPanel`，確保用戶界面與交互一致。

 ---

 `* 總結`

 - What：`StoreSelectionMapHandlerDelegate` 用於協調地圖交互邏輯與控制器之間的資料與事件處理。
 - Why：確保地圖邏輯與資料管理分離，提高靈活性、擴展性與可維護性。
 - How：通過定義協議、實現方法與代理模式，實現地圖交互與控制器之間的高效溝通與解耦設計。
 
 */


// MARK: - (v)

import Foundation

/// 協調 `StoreSelectionMapHandler` 與 `StoreSelectionViewController` 的代理協議。
///
/// 此協議負責處理地圖上與門市互動的行為，包含點擊標記與取消選取等事件，
/// 並將這些操作的結果回傳給控制器，方便進一步處理邏輯。
protocol StoreSelectionMapHandlerDelegate: AnyObject {
    
    /// 獲取所有店鋪資料。
    ///
    /// 此方法用於讓地圖標記點擊事件能檢索到所有門市的相關資料，
    /// 以便根據標記的資訊對應到特定店鋪。
    /// - Returns: 一個包含所有店鋪資料的陣列 (`Store`)。
    func getStores() -> [Store]
    
    /// 當使用者在地圖上選取某個店鋪標記時被調用。
    ///
    /// 此方法會回傳選取的店鋪資料，便於進一步處理，例如顯示店鋪詳細資訊。
    /// - Parameter store: 被選取的店鋪資料。
    func didSelectStore(_ store: Store)
    
    /// 當使用者取消選取地圖上的店鋪標記時被調用。
    ///
    /// 此方法通常用於清除當前顯示的店鋪資訊，回到預設狀態。
    func didDeselectStore()
    
}
