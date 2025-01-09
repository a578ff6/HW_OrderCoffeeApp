//
//  Store.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - Firestore 經緯度存取方式重點筆記 (重要)
/**
 
 ## Firestore 經緯度存取方式重點筆記
 
 - 主要原先在測試的時候，直接在  Cloud Firestore 設置 `number` 的 `latitude`、`longitude`，雖然可以定位到店家。但由於後續要測試距離位置的想法，發現 Firebase 有提供 `GeoPoint` 的方式，故特此紀錄。
 - 在 Cloud Firestore 中，對於經緯度的存取可以選擇使用數字 (`number`) 或是使用 `GeoPoint`。兩者都是可以的，但 `GeoPoint` 是 Firestore 提供的一個專門處理地理位置的資料類型，更加合適於存放經緯度資訊。

 `1. 經緯度存取的兩種方式`
 
    - 數字 (number)：分別使用 latitude（緯度）和 longitude（經度）兩個字段來存取經緯度。
    - GeoPoint 類型：Cloud Firestore 提供的專門用於地理位置的資料類型，包含 latitude 和 longitude 屬性，適合存放經緯度資訊。
 
 `2. GeoPoint 是什麼？`
 
    * GeoPoint 是 Cloud Firestore 用來表示地理位置的資料結構，包含：
        - latitude（緯度）：範圍 -90 到 90。
        - longitude（經度）：範圍 -180 到 180。
    
    * 適用場景：
        - 特別適合存放經緯度資料，並進行地理查詢和地圖操作。
 
` 3. 使用 GeoPoint 的好處`
 
    - 簡化資料結構：經緯度合併為一個字段，存取簡單，不需要分別操作 latitude 和 longitude。
    - 更好的地理查詢支援：Cloud Firestore 原生支援基於 GeoPoint 的地理查詢，可以方便進行範圍查找（例如找出附近的店鋪）。
    - 減少錯誤和提高可讀性：GeoPoint 使得經緯度作為單一實體，減少出錯機會，程式碼更容易理解和維護。
 
 `4. 使用 number 和 GeoPoint 的比較`
 
   * 使用數字（number）存取經緯度                                           使用 GeoPoint
   * 需要分開存取：分別存 latitude 和 longitude                             合併為一個字段：使用 location 來存取地理位置
   * 程式碼操作較繁瑣：需分別操作經緯度                                       簡化操作：直接處理 GeoPoint 物件
   * 地理查詢較複雜：需額外的計算來篩選地點                                    地理查詢更方便：Firestore 支援基於 GeoPoint 的地理查詢
 
 `5. 實際使用情境`
 
    * 數字存取方式：
        - 適合只需要顯示位置的情況，例如顯示店鋪位置而不進行地理查詢。
        - 需要分別存取 latitude 和 longitude，每次操作經緯度都需要寫額外的程式碼。
 
    * GeoPoint 存取方式：
        - 適合需要地理位置查詢、範圍篩選等功能的應用場景。
        - 可以輕鬆地與 Firestore 的查詢功能結合，實現如「找出附近店鋪」的功能。
 
 `6. GeoPoint 範例`
 
    - 在 Firestore 中，使用 GeoPoint 儲存經緯度：
 
        ```
        {
        "name": "三重三和門市",
        "location": {
            "latitude": 25.079199143910511,
            "longitude": 121.48238556551757
        },
        "address": "新北市三重區三和路四段388-2號"
        }
        ```

 `7. 結論`
 
    - 若 App 需要地理查詢（例如查詢附近店鋪）或希望操作經緯度資料更簡單方便，建議使用 GeoPoint。
    - 若只需要顯示位置或存取地點資料，也可以選擇使用 數字 (number) 存取經緯度。
    - GeoPoint 在維護上更簡單，有利於擴充地理相關的功能。
 */


// MARK: - 「營業時間」的處理方式（重要）
/**
 
 ## 「營業時間」的處理方式
 
 `&. 營業時間每天不一樣的話該怎麼處理？`
 
 `1. 營業時間每天不一樣的情況`
 
    - 門市的營業時間可能在不同的日子有所不同，例如平日和假日的營業時間不一致。這種情況需要在資料結構中詳細記錄每一天的營業時間。
 
 `* 結構設計：`
 
    - `openingHours` 使用一個 `Dictionary`，以星期幾（例如：Monday, Tuesday）作為 key，對應的營業時間作為 value。
 
 `* 資料結構設計的好處：`
 
    - 可以靈活地記錄每一天不同的營業時間。
    - 資料結構簡單且容易管理，特別適合 UI 顯示，例如在卡片式的門市資訊視圖中。

 --------
 
 `2. 根據今日日期來顯示營業時間`
 
    - 為了顯示今日的營業時間，需要取得當前日期並找到相應的營業時間。
 
 `* 處理方式：`
 
    - 使用 DateFormatter 格式化當前日期，並以星期幾（例如：Monday, Tuesday）來取得對應的營業時間。

 `* 處理的步驟：`
 
    - 使用 `DateFormatter` 格式化當前日期。
    - 取得今日是星期幾。
    - 根據 `openingHours` 字典取得對應的營業時間。

 `* 好處：`
 
    - 動態顯示：無論何時打開 App ，都可以根據當天自動顯示正確的營業時間，減少硬編碼或手動更新的需要。
    - 使用者體驗佳：顯示「今日營業時間」可以讓使用者更方便了解當天是否營業及開放時間，增強使用者的體驗。
 
 --------

 `3. 總結`
 
    - `營業時間每天不一樣的處理方式`： 使用 Dictionary 來記錄每一天的營業時間，以便靈活管理。
 
    - `顯示今日營業時間的方法`： 透過 DateFormatter 取得當前日期的星期幾，並從 openingHours 中找出對應的營業時間。
 
    - `好處`： 方便維護和動態顯示營業資訊，提升使用者體驗。
 
 */


// MARK: - 重點筆記：Store 的營業時間設計（資料結構設計）
/**

 - 主要是因為我的目的是「根據今日的時間顯示營業時間」
 
 `1. 營業時間每天不同的處理方法`
 
    - 使用 字典（Dictionary/Map） 來存儲每一天的營業時間。
    - 使用星期幾（例如："Monday"）作為 key，對應的營業時間（例如："07:00–22:00"）作為 value。
 
 `2. Firebase Cloud Firestore 的資料結構`
 
    - 在 Firestore 中，將 `openingHours` 設置為一個 Map，包含每一天的營業時間。
 
` 3. 使用字典（Map）的好處`
 
    - 方便查找特定日期的營業時間： 直接通過 openingHours["Monday"] 查找，不需要遍歷整個陣列。
    - 程式碼簡潔，提高可讀性： 更直接簡單，不需要額外的邏輯來處理陣列，減少錯誤的風險。
    - 提升結構的靈活性和易用性： 對於需要快速查找、更新或添加特定日期的營業時間，使用字典更加靈活且易於維護。
 */




// MARK: - Store 筆記
/**
 
 ## Store 筆記


 `* What:`
 
 - `Store` 是一個用於描述門市基本數據的模型，專注於存儲與計算相關的業務邏輯。

 `1. 結構描述：`
 
    - 包含店鋪的名稱、位置、電話號碼、營業時間等基本資訊。
    - 提供與地理位置相關的距離計算。

 `2. 功能：`
 
    - 存儲數據：作為 Firebase 資料的反序列化模型。
    - 邏輯處理：例如計算與當前位置的距離，查詢今日營業時間。

 ---------------

` * Why:`
 
 `1. 單一責任原則（SRP）：`
 
    - 將與門市相關的核心數據與邏輯集中管理，避免與 UI 格式化混雜。

 `2. 解耦合設計：`
 
    - 與 ViewModel 配合，分離數據存儲與顯示邏輯，提升模組的清晰度與可測試性。

 `3. 可重用性：`
 
    - 其他功能模組（如地圖顯示、搜尋功能）可以重複使用這些基礎數據和邏輯。

 `4. 易於擴展：`
 
    - 能快速擴展門市資料屬性或邏輯（如新增特殊營業時間的處理）。

 ---------------

 `* How:`

 `1. 基礎結構設計：`
 
    - 定義與 Firebase 結構對應的屬性，支援序列化與反序列化：
 
      ```swift
      struct Store: Codable {
          let id: String
          let name: String
          let location: GeoPoint
          let address: String
          let phoneNumber: String
          let openingHours: [String: String]
      }
      ```
 ----

 `2. 核心邏輯：`
 
    - 計算距離： 提供一個簡單的方法計算與使用者當前位置的距離：
 
      ```swift
      func distance(from userLocation: CLLocation) -> CLLocationDistance {
          let storeLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
          return userLocation.distance(from: storeLocation)
      }
      ```
 
    - 今日營業時間查詢： 返回當天的營業時間或提示「未提供」：
 
      ```swift
      func todayOpeningHours() -> String? {
          let today = DateUtility.getWeekday()
          return openingHours[today]
      }
      ```
 ----

 `3. 避免與視圖混雜：`
 
    - 格式化邏輯：例如電話號碼格式化應移交給 ViewModel：
 
      ```swift
      var formattedPhoneNumber: String {
          PhoneNumberFormatter.formatForTaiwan(phoneNumber)
      }
      ```
 
    - 今日營業時間格式化：透過 ViewModel 處理成符合顯示需求的格式。

 ----
 
` 4. 與 ViewModel 配合：`
 
    - `Store` 提供基礎數據，`StoreInfoViewModel` 將其轉換為適合 UI 的格式：
 
      ```swift
      struct StoreInfoViewModel {
          private let store: Store
          var formattedDistance: String {
              guard let location = userLocation else { return "Not available" }
              let distance = store.distance(from: location)
              return String(format: "%.2f km", distance / 1000)
          }
      }
      ```

 ---------------

` * 結論：`
 
 `1.單一責任與邏輯清晰度：`
 
   `Store` 專注於門市核心數據存儲與基礎邏輯，與格式化或視圖相關邏輯分離。
   
 `2.模組化與可測試性：`
 
   提供清晰的數據接口，能被多個模組重複使用，降低耦合並提升測試效率。

 */


// MARK: - (v)

import Foundation
import Firebase
import CoreLocation

/// 描述門市資料結構的模型，用於存儲與門市相關的基本資訊。
///
/// - 功能：
///   1. 提供基礎屬性描述店鋪資訊：名稱、地址、電話號碼、位置、營業時間。
///   2. 簡化基礎的數據計算邏輯（如距離計算）。
///   3. 支援 Firebase 的序列化與反序列化。
///
/// - 設計目標：
///   1. 單一責任：專注於店鋪數據的存儲與基本業務邏輯，避免視圖相關的格式化邏輯混合，將其留給 `ViewModel` 處理。
///   2. 解耦合：將門市資料的核心數據與具體視圖展示隔離，確保模組化設計。
///   3. 可擴展性：提供擴展數據處理的基礎，便於未來新增功能（如支持更多屬性或自定義格式）。
struct Store: Codable {
    
    // MARK: - Properties
    
    /// 店鋪唯一識別碼（例如 Firebase 的 document ID）
    let id: String
    
    /// 店鋪名稱，例如 "三峽學成門市"
    let name: String
    
    /// 店鋪位置（經緯度），使用 `GeoPoint` 類型儲存
    let location: GeoPoint
    
    /// 店鋪地址，例如 "新北市三峽區學成路317號"
    let address: String
    
    /// 店鋪電話號碼，例如 "0235012834"
    let phoneNumber: String
    
    /// 營業時間，以星期幾為 key，例如：
    /// - "星期一": "07:00–21:30"
    /// - "星期日": "07:30–22:00"
    let openingHours: [String: String]
    
}

// MARK: - Extensions
extension Store {
    
    /// 取得今日的營業時間
    ///
    /// 此方法通過使用 `DateUtility` 獲取當前日期的星期，並返回對應的營業時間。
    ///
    /// - Returns: 今日的營業時間（例如："07:00–21:30"），若無資料則返回 `nil`
    func todayOpeningHours() -> String? {
        let today = DateUtility.getWeekday()
        return openingHours[today]
    }
    
    /// 計算與指定位置的距離
    ///
    /// 使用門市的地理座標計算與指定位置之間的直線距離，結果以公尺為單位返回。
    ///
    /// - Parameter userLocation: 使用者目前的位置，類型為 `CLLocation`
    /// - Returns: 該門市與使用者之間的距離（單位：公尺）
    func distance(from userLocation: CLLocation) -> CLLocationDistance {
        let storeLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return userLocation.distance(from: storeLocation)
    }
    
}
