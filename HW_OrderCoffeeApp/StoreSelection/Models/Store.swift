//
//  Store.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - Firestore 經緯度存取方式重點筆記 (重要)

/*
 ## Firestore 經緯度存取方式重點筆記
 
 - 主要原先在測試的時候，直接在  Cloud Firestore 設置 number 的 latitude、longitude，雖然可以定位到店家，但由於後續要測試距離位置的想法，發現 Firebase 有提供 GeoPoint 的方式，故特此紀錄。
 - 在 Cloud Firestore 中，對於經緯度的存取可以選擇使用數字 (`number`) 或是使用 `GeoPoint`。兩者都是可以的，但 `GeoPoint` 是 Firestore 提供的一個專門處理地理位置的資料類型，更加合適於存放經緯度資訊。

 1. 經緯度存取的兩種方式
    - 數字 (number)：分別使用 latitude（緯度）和 longitude（經度）兩個字段來存取經緯度。
    - GeoPoint 類型：Cloud Firestore 提供的專門用於地理位置的資料類型，包含 latitude 和 longitude 屬性，適合存放經緯度資訊。
 
 2. GeoPoint 是什麼？
 
    * GeoPoint 是 Cloud Firestore 用來表示地理位置的資料結構，包含：
        - latitude（緯度）：範圍 -90 到 90。
        - longitude（經度）：範圍 -180 到 180。
    
    * 適用場景：
        - 特別適合存放經緯度資料，並進行地理查詢和地圖操作。
 
 3. 使用 GeoPoint 的好處
    - 簡化資料結構：經緯度合併為一個字段，存取簡單，不需要分別操作 latitude 和 longitude。
    - 更好的地理查詢支援：Cloud Firestore 原生支援基於 GeoPoint 的地理查詢，可以方便進行範圍查找（例如找出附近的店鋪）。
    - 減少錯誤和提高可讀性：GeoPoint 使得經緯度作為單一實體，減少出錯機會，程式碼更容易理解和維護。
 
 4. 使用 number 和 GeoPoint 的比較
 
   * 使用數字（number）存取經緯度                                           使用 GeoPoint
   * 需要分開存取：分別存 latitude 和 longitude                             合併為一個字段：使用 location 來存取地理位置
   * 程式碼操作較繁瑣：需分別操作經緯度                                       簡化操作：直接處理 GeoPoint 物件
   * 地理查詢較複雜：需額外的計算來篩選地點                                    地理查詢更方便：Firestore 支援基於 GeoPoint 的地理查詢
 
 5. 實際使用情境
 
    * 數字存取方式：
        - 適合只需要顯示位置的情況，例如顯示店鋪位置而不進行地理查詢。
        - 需要分別存取 latitude 和 longitude，每次操作經緯度都需要寫額外的程式碼。
 
    * GeoPoint 存取方式：
        - 適合需要地理位置查詢、範圍篩選等功能的應用場景。
        - 可以輕鬆地與 Firestore 的查詢功能結合，實現如「找出附近店鋪」的功能。
 
 6. GeoPoint 範例
    - 在 Firestore 中，使用 GeoPoint 儲存經緯度：
 
 {
   "name": "三重三和門市",
   "location": {
     "latitude": 25.079199143910511,
     "longitude": 121.48238556551757
   },
   "address": "新北市三重區三和路四段388-2號"
 }
 

 7. 結論
    - 若 App 需要地理查詢（例如查詢附近店鋪）或希望操作經緯度資料更簡單方便，建議使用 GeoPoint。
    - 若只需要顯示位置或存取地點資料，也可以選擇使用 數字 (number) 存取經緯度。
    - GeoPoint 在維護上更簡單，有利於擴充地理相關的功能。
 */


// MARK: - Store 資料結構的重點筆記

/*
 ## Store 資料結構重點筆記

 1. Store 的屬性

 - id: String： 店家的唯一標識符，一般使用 Firebase 的 document ID，這樣可以確保每個店家都有唯一的識別碼，方便從資料庫中查找。
 - name: String： 店名，例如「Starbucks Da'an」，用來顯示在地圖標記和相關資訊卡片中。
 - location: GeoPoint：店家的經緯度位置，使用 Firebase 的 GeoPoint 類型來儲存，以更直觀的方式表示地理位置，便於地圖標記和查找。
 - address: String： 店家地址，便於顯示給使用者，或者提供導航等功能。
 - phoneNumber: String： 店家電話號碼，方便使用者撥打電話詢問或訂購。
 - openingHours: [String: String]：營業時間，以星期幾為 key（例如「星期一」、「星期二」等），對應的營業時間為 value。這樣可以靈活地表示每週不同天的營業時間。

 2. Computed Property

 - coordinate: (latitude: Double, longitude: Double)：計算屬性，用於從 GeoPoint 轉換地理位置為座標格式，便於地圖 API（如 Apple Maps 或 Google Maps）使用。

 3. 初始化方法 (init)

 - 提供自定義的初始化方法，用於設定店家所有的基本資訊，確保每個 `Store` 物件在初始化時擁有完整的屬性資料。
 
 
 &. 設計目的

 1. 清楚描述店家資訊：
    - Store 資料結構設計用於清楚描述店家的所有基本資訊，包括店名、地址、經緯度、電話號碼及營業時間。

 2. 方便地圖標示與顯示：
     - 使用 GeoPoint 作為地理位置屬性，讓 `Store` 可以輕鬆地標記在地圖上，提供地圖相關的功能（例如標記和導航）。
     - 地址 (`address`) 和電話號碼 (`phoneNumber`) 可以方便使用者找到或聯絡店家。
 
 3. 集中管理營業時間顯示：
    - 由 StoreManager 來處理營業時間的計算邏輯，使應用程式能夠根據當前日期動態顯示每個店鋪的營業時間，提升維護性與一致性。

 
 &. 好處

 1. 擴充性強：
    - 使用 Dictionary 來儲存營業時間 (openingHours: [String: String])，可以靈活地擴充每天不同的營業時間，例如假日或特殊營業時間。
    - 便於資料結構的擴展，未來若需新增更多店家屬性，例如「店家特色」或「服務項目」，只需要在 `Store` 結構中增加相應的屬性。

 2. 便於維護與查詢：
    - 營業時間計算方法集中於 StoreManager，讓程式碼維護更簡單，營業時間的變更只需修改 StoreManager 中的方法，避免重複代碼，提升程式碼的可讀性和可維護性。
    - 使用 GeoPoint 來管理店家的地理位置，可以更方便地進行地理相關查詢，例如查找附近的店鋪。

 3. 提升使用者體驗：
    - 提供電話號碼、地址、今日營業時間等資訊，有助於使用者快速了解店家的服務時間、導航到達位置或直接聯絡店家。
    - 動態顯示營業時間，使用者只需查看應用程式便可得知今日是否營業及具體時間，這對於便利店、咖啡店等經常需要查詢營業時間的場所尤其重要。
 */


// MARK: - 「營業時間」的處理方式（重要）

/*
 ## 「營業時間」的處理方式
 
 &. 營業時間每天不一樣的話該怎麼處理？
 
 1. 營業時間每天不一樣的情況
    - 門市的營業時間可能在不同的日子有所不同，例如平日和假日的營業時間不一致。這種情況需要在資料結構中詳細記錄每一天的營業時間。
 
    * 結構設計：
        - openingHours 使用一個 Dictionary，以星期幾（例如：Monday, Tuesday）作為 key，對應的營業時間作為 value。
 
    * 資料結構設計的好處：
        - 可以靈活地記錄每一天不同的營業時間。
        - 資料結構簡單且容易管理，特別適合 UI 顯示，例如在卡片式的門市資訊視圖中。

 
 2. 根據今日日期來顯示營業時間
    - 為了顯示今日的營業時間，需要取得當前日期並找到相應的營業時間。
 
    * 處理方式：
        - 使用 DateFormatter 格式化當前日期，並以星期幾（例如：Monday, Tuesday）來取得對應的營業時間。

    * 處理的步驟：
        - 使用 DateFormatter 格式化當前日期。
        - 取得今日是星期幾。
        - 根據 openingHours 字典取得對應的營業時間。

    * 好處：
        - 動態顯示：無論何時打開 App ，都可以根據當天自動顯示正確的營業時間，減少硬編碼或手動更新的需要。
        - 使用者體驗佳：顯示「今日營業時間」可以讓使用者更方便了解當天是否營業及開放時間，增強使用者的體驗。
 
 
 3. 總結
    - 營業時間每天不一樣的處理方式： 使用 Dictionary 來記錄每一天的營業時間，以便靈活管理。
    - 顯示今日營業時間的方法： 透過 DateFormatter 取得當前日期的星期幾，並從 openingHours 中找出對應的營業時間。
    - 好處： 方便維護和動態顯示營業資訊，提升使用者體驗。
 */


// MARK: - 重點筆記：Store 的營業時間設計（資料結構設計）

/*
 * 主要是因為我的目的是「根據今日的時間顯示營業時間」
 
 1. 營業時間每天不同的處理方法
    - 使用 字典（Dictionary/Map） 來存儲每一天的營業時間。
    - 使用星期幾（例如："Monday"）作為 key，對應的營業時間（例如："07:00–22:00"）作為 value。
 
 2. Firebase Cloud Firestore 的資料結構
    - 在 Firestore 中，將 openingHours 設置為一個 Map，包含每一天的營業時間。
 
 3. 使用字典（Map）的好處
    - 方便查找特定日期的營業時間： 直接通過 openingHours["Monday"] 查找，不需要遍歷整個陣列。
    - 程式碼簡潔，提高可讀性： 更直接簡單，不需要額外的邏輯來處理陣列，減少錯誤的風險。
    - 提升結構的靈活性和易用性： 對於需要快速查找、更新或添加特定日期的營業時間，使用字典更加靈活且易於維護。
 */


import Foundation
import Firebase
/// 描述門市的資料結構
struct Store: Codable {
    
    // MARK: - Properties
    
    let id: String                           // 店家唯一標識（例如使用 Firebase 的 document ID）
    let name: String                         // 店名，例如 "Starbucks Da'an"
    let location: GeoPoint                   // 經緯度，以 GeoPoint 類型儲存
    let address: String                      // 店家地址
    let phoneNumber: String                  // 店家電話號碼
    let openingHours: [String: String]       // 營業時間，以星期幾為 key

    // MARK: - Computed Properties

    /// 計算屬性來轉換位置為座標格式，便於地圖 API 使用
    var coordinate: (latitude: Double, longitude: Double) {
        return (location.latitude, location.longitude)
    }
    
    // MARK: - Initializer

    /// 初始化方法
    init(id: String, name: String, location: GeoPoint, address: String, phoneNumber: String, openingHours: [String: String]) {
        self.id = id
        self.name = name
        self.location = location
        self.address = address
        self.phoneNumber = phoneNumber
        self.openingHours = openingHours
    }
    
}
