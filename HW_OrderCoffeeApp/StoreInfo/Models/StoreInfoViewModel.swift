//
//  StoreInfoViewModel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/8.
//

// MARK: - StoreInfoViewModel 筆記
/**
 
 ## StoreInfoViewModel 筆記

 - 本來是直接在 StoreInfo 相關視圖的部分直接使用 Store ，以及在 Store 設置格式化的方法。
 - 結果發現 StoreInfo 在使用這些數據時很分散，尤其又要格式化距離、電話、營業時間給UI呈現，導致職責模糊。
 - 因此設置 StoreInfoViewModel 來給 StoreInfo 使用，避免讓 Store 過於肥大。
 
 --------------------

 `* What`
 
 - `StoreInfoViewModel` 是一個用於門市資料的視圖模型（ViewModel），負責將核心的門市數據轉換為易於視圖層顯示的格式化數據。
 
 - `核心功能：`
 
   1. 將 `Store` 模型中的原始數據進行格式化。
   2. 提供包含距離、今日營業時間等的格式化資訊。
   3. 隔離數據層與視圖層的業務邏輯，提升模組化與可維護性。

 --------------------

 `* Why`
 
 - 設計動機與優勢：
 
 `1. 解耦：`
 
    - 將與數據顯示相關的邏輯與 `Store` 模型分離，避免模型直接與視圖層交互，提升設計的清晰度與可測試性。
 
 `2. 單一責任：`
 
    - 讓 `Store` 專注於數據存儲與基礎處理，而`格式化`邏輯由 `ViewModel` 專門負責，符合單一責任原則。
 
 `3. 靈活擴展：`
 
    - 在需要新增更多格式化數據時，可以直接在 ViewModel 中擴展，而無需修改核心數據模型。
 
 `4. 視圖易用性：`
 
    - 為視圖層（如 `StoreInfoViewController`）提供即時可用的格式化數據，減少視圖層的複雜性。

 --------------------

 `* How`
 
` 1. 建立 StoreInfoViewModel：`
 
    - 接收 `Store` 和 `userLocation` 作為初始化參數，將其保存為私有屬性。
 
    ```swift
    init(store: Store, userLocation: CLLocation?) {
        self.store = store
        self.userLocation = userLocation
    }
    ```

 `2. 格式化屬性：`
 
    - 通過計算型屬性，將門市名稱、地址、電話號碼、距離、營業時間等數據格式化。
 
    - 例如：
      - 將電話號碼格式化為符合台灣樣式。
      - 計算與使用者當前位置的距離，並以公里為單位顯示。
      - 顯示包含星期的今日營業時間，若無資料則提供預設訊息。

 `3. 使用示例：`
 
    - 視圖層透過 `ViewModel` 獲取所需數據：
 
    ```swift
    let viewModel = StoreInfoViewModel(store: store, userLocation: userLocation)
    nameLabel.text = viewModel.name
    distanceLabel.text = viewModel.formattedDistance
    todayHoursLabel.text = viewModel.formattedTodayHours
    ```

 `4. 核心屬性說明：`
 
    - `name`：提供門市名稱。
    - `address`：提供門市地址。
    - `formattedPhoneNumber`：格式化後的電話號碼。
    - `formattedDistance`：與使用者的距離（公里數，保留兩位小數）。
    - `formattedTodayHours`：今日營業時間（如 "星期一: 07:00–21:30"）。

 --------------------

 `* 結論與注意事項`
 
 - `適用場景：`
 
   - `StoreInfoViewModel` 適用於需要顯示格式化門市資訊的視圖場景，如 `StoreInfoViewController` 或 `FloatingPanel`。
   
 - `注意事項：`
 
   1. 格式化邏輯應保持與視圖層需求一致，避免過度耦合。
   2. 與 `Store` 模型的邏輯應保持簡單的依賴關係，避免對原始模型進行過多操作。

 */


// MARK: - (v)

import Foundation
import CoreLocation

/// `StoreInfoViewModel`
///
/// - 功能：
///   1. 提供門市數據的格式化表示，以便視圖直接使用。
///   2. 將與 UI 顯示相關的邏輯從 `Store` 模型中解耦，專注於轉換與格式化數據。
///   3. 對應於使用者當前位置，計算門市的距離並格式化為可讀字串。
///
/// - 設計目標：
///   1. 單一責任：負責將核心門市數據轉換為符合視圖顯示需求的格式化數據。
///   2. 可擴展性：方便在未來根據 UI 需求添加更多格式化邏輯。
///   3. 解耦合：隔離數據層與視圖層，避免直接操作數據模型以提升維護性。
///
/// - 使用場景：
///   1. 作為 `StoreInfoViewController` 或其他視圖的數據提供層，生成格式化的門市資訊。
///   2. 提供與使用者位置相關的距離信息以便顯示。
struct StoreInfoViewModel {
    
    // MARK: - Properties
    
    /// 原始門市數據模型
    private let store: Store
    
    /// 使用者當前位置，用於計算與門市的距離
    private let userLocation: CLLocation?
    
    // MARK: - Initializer
    
    /// 初始化 ViewModel
    ///
    /// - Parameters:
    ///   - store: 門市數據模型
    ///   - userLocation: 使用者當前的地理位置（可選）
    init(store: Store, userLocation: CLLocation?) {
        self.store = store
        self.userLocation = userLocation
    }
    
    // MARK: - Computed Properties
    
    /// 門市名稱
    ///
    /// - Returns: 門市的名稱字串，例如 "三峽學成門市"
    var name: String {
        return store.name
    }
    
    /// 門市地址
    ///
    /// - Returns: 門市的完整地址，例如 "新北市三峽區學成路317號"
    var address: String {
        return store.address
    }
    
    /// 格式化的電話號碼
    ///
    /// - Returns: 台灣格式化後的電話號碼，例如 "02- 3501-2834"
    var formattedPhoneNumber: String {
        return PhoneNumberFormatter.formatForTaiwan(store.phoneNumber)
    }
    
    /// 格式化的距離
    ///
    /// - Returns: 使用者與門市之間的距離（以公里為單位，保留 2 位小數）。
    ///   若無法獲取位置，返回 "Not available"。
    var formattedDistance: String {
        guard let location = userLocation else { return "Not available" }
        let distance = store.distance(from: location)
        return String(format: "%.2f km", distance / 1000)
    }
    
    /// 格式化的今日營業時間
    ///
    /// - Returns: 包含星期的今日營業時間字串，例如 "星期一: 07:00–21:30"。
    ///   若無資料，返回 "No hours provided"。
    var formattedTodayHours: String {
        guard let hours = store.todayOpeningHours() else { return "No hours provided" }
        let today = DateUtility.getWeekday()
        return "\(today)： \(hours)"
    }
    
}
