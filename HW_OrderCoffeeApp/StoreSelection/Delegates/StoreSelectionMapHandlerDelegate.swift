//
//  StoreSelectionMapHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/26.
//

/*
 ## StoreSelectionMapHandlerDelegate 重點筆記
 
 1. 協議用途：
    - StoreSelectionMapHandlerDelegate 是用來協調 StoreSelectionHandler 和 StoreSelectionViewController 之間的互動。
    - 此協議提供了必要的接口，讓 StoreSelectionHandler 可以：
    
    * 請求店鋪資料與營業時間： 
        - 協議定義的方法允許 StoreSelectionHandler 從 StoreSelectionViewController 獲取最新的店鋪資料及營業時間，用於在地圖上標註和顯示詳細資訊。
 
    * 通知用戶選擇的店鋪：
        - 通過 didSelectStore(_:) ，StoreSelectionHandler 可以將用戶選擇的店鋪信息通知給 StoreSelectionViewController，從而使用 `FloatingPanel` 更新顯示選定店鋪的詳細信息。
    
    * 更新 UI：
        - 協議的作用不僅限於提供資料，還包括根據用戶的操作更新 UI，從而確保地圖和店鋪信息展示之間的一致性。

    - 這樣設計的目的在於讓 StoreSelectionHandler 專注於地圖上的交互邏輯，而 StoreSelectionViewController 負責管理店鋪的數據和視圖展示，透過委派來保持兩者之間的溝通和狀態同步。
 
 
 2. 方法說明
 
    * getStores()：
        - 功能：取得所有店鋪的資料，通常用於在地圖上標註所有店鋪位置。
        - 回傳：返回一個包含所有 Store 的陣列，讓 StoreSelectionMapHandler 可以透過這些資料進行操作。
 
    * getTodayOpeningHours(for storeId: String)：
        - 功能：根據店鋪的唯一 ID，取得該店鋪的今日營業時間。
        - 參數：storeId，用於標識要查詢的店鋪。
        - 回傳：返回該店鋪的今日營業時間，如果該店鋪沒有營業時間的資料，則返回預設的「營業時間未提供」訊息。
 
    * fetchDistanceToStore(for storeId: String)：
        - 功能：取得與特定店鋪的距離（通過 StoreManager 計算）。
        - 參數：storeId，店鋪的唯一標識符。
        - 回傳：返回與用戶位置之間的距離，用於在顯示店鋪詳細資訊時提供額外的參考。
 
    * didSelectStore(_ store: Store)：
        - 功能：通知控制器用戶選擇了地圖上的某個店鋪。
        - 參數：store，被選定的店鋪，包含名稱、地址、電話等資料。
        - 用途：用戶點擊地圖上的店鋪標記時，會觸發此方法。通常會用於 `FloatingPanel` 中展示選定店鋪的詳細資訊。

    * didDeselectStore()：
        - 功能：通知控制器用戶取消選取地圖上的某個店鋪標記。
        - 用途：控制器在接收到取消選取的通知後，將 FloatingPanel 收起並重置其內容為初始狀態。

 3. 調整重構的部分：

    * 將原有的 `presentStoreDetailsAlert(for: todayOpeningHours:)` 移除：
         - 隨著設置了 didSelectStore(_ store:)，控制器現在使用 FloatingPanel 來展示店鋪的詳細信息，而不再使用彈窗顯示。
 
 
 4. 資料集中管理與高靈活性：
 
    * 資料集中管理
        - 所有的店鋪資料與營業時間的管理都集中在 StoreSelectionViewController，而 StoreSelectionHandler 只需要透過代理來請求這些資料。
 
    * 高靈活性
        - 使用代理模式讓處理店鋪展示邏輯變得更加靈活。如果要修改資料的取得方式或顯示方式，只需修改代理的方法實現，而不需要修改 StoreSelectionHandler 的內部邏輯。

 5. 想法：
 
    * 清晰的職責分離：
        - StoreSelectionMapHandler 負責地圖上的店鋪選擇相關的邏輯，包含地圖上的互動。
        - StoreSelectionViewController 則專注於管理店鋪資料和顯示選定店鋪的詳細信息，尤其是透過 `FloatingPanel` 來展示店鋪詳細資訊。
 
    * 提高可重用性：
        - 使用代理來確保地圖交互和資料展示的分離，可以讓各模組保持獨立，並易於維護和擴展。
 */


// MARK: - fetchDistanceToStore 方法重點筆記
/*
 ## fetchDistanceToStore 方法重點筆記
 
 1. 方法功能：
    - 該方法的作用是從 storeDistances 字典中，查找並返回特定店鋪與使用者之間的距離。
 
 2. 參數與返回值：

    * 參數：
        - storeId: String：店鋪的唯一標識符，用於查找該店鋪的距離。
 
    * 返回值：
        - 返回該店鋪與使用者之間的距離 (CLLocationDistance)。
        - 如果該店鋪的距離尚未計算，則返回 nil。
 
    * 使用方式：
        - 該方法由 StoreSelectionMapHandlerDelegate 的代理協議提供，因此可以在代理中使用此方法來獲取特定店鋪的距離，例如在用戶選擇店鋪時顯示該店鋪的詳細資訊時使用。
 
    * 記錄位置：
        - 由於距離的計算依賴於使用者的當前位置，因此需要在獲取使用者位置後，更新 storeDistances 字典。
        - 在 StoreSelectionViewController 中，透過 CLLocationManager 來獲取使用者的位置，並使用 StoreManager.shared.calculateDistances() 方法計算每個店鋪的距離，然後更新 storeDistances。

 
 &. 使用 fetchDistanceToStore 的流程：
 
 1. 位置獲取：
    - StoreSelectionViewController 使用 CLLocationManager 來獲取使用者的當前位置。
    - 當位置更新後，調用 StoreManager.shared.calculateDistances() 來計算每個店鋪的距離，並將結果保存在 storeDistances 中。
 
 2. 距離展示：
    - 當使用者選擇某個店鋪時，透過 fetchDistanceToStore(for:) 方法查找該店鋪與使用者之間的距離。
    - 在店鋪詳細信息的彈窗中展示該距離，增強使用者對店鋪位置的感知。
 */

import Foundation
import CoreLocation

/// 用於協調 StoreSelectionMapHandler 與 StoreSelectionViewController 的代理協議
/// 主要負責和地圖相關的交互行為，通常只用於處理地圖標記點擊和取消選取等地圖上的事件。
protocol StoreSelectionMapHandlerDelegate: AnyObject {
    
    /// 取得所有的店鋪資料
    /// - Returns: 一個包含所有店鋪 (`Store`) 的陣列
    func getStores() -> [Store]
    
    /// 取得特定店鋪的今日營業時間
    /// - Parameter storeId: 店鋪的唯一標識符
    /// - Returns: 該店鋪今日的營業時間，若無資料則返回預設訊息
    func getTodayOpeningHours(for storeId: String) -> String
    
    /// 取得特定店鋪的距離（通過 StoreManager）
    /// - Parameter storeId: 店鋪的唯一標識符
    /// - Returns: 與用戶位置之間的距離
    func fetchDistanceToStore(for storeId: String) -> CLLocationDistance?
    
    /// 當地圖上某個店鋪被選取時調用
    func didSelectStore(_ store: Store)
    
    /// 當地圖上某個店鋪被取消選取時調用
    func didDeselectStore()

}
