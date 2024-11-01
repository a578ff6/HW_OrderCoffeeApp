//
//  StoreManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - StoreManager 重點筆記

/*
 ## StoreManager 重點筆記
 
 1. 類別說明
    - StoreManager 是用來管理店鋪相關資料的管理器，負責從 Firestore 中拉取店鋪資料，並處理與店鋪相關的其他操作，例如計算使用者與店鋪之間的距離，及格式化店鋪的電話號碼。

 2. 主要方法
 
    * fetchStores()：
        - 從 Firestore 中拉取店鋪的數據，並將其轉換為 Store 結構的陣列。
        - 地理位置改為使用 `GeoPoint`，可以更方便地進行地理位置的查詢和操作。

    * getTodayOpeningHours(for:)：
        - 根據當前的日期，返回所有店鋪的今日營業時間。
        - 使用 DateFormatter 格式化出今天是星期幾，並以此查找店鋪的營業時間。
        - 回傳一個字典，字典的 key 是店鋪的 ID，值則是今日營業時間。
 
    * updateUserLocationAndCalculateDistances(userLocation:stores:)：
        - 當定位變化時更新用戶的位置，並重新計算與所有店鋪的距離。
        - 此方法將定位更新與距離計算結合，減少在多個地方重複執行的邏輯。

    * calculateDistances(to:)：
        - 計算所有店鋪與使用者的距離並保存，集中處理距離計算邏輯，確保所有距離計算都由 StoreManager 統一處理。
 
    * getDistanceToStore(for:)：
        - 根據店鋪的 ID，返回與使用者之間的距離。
        - 提供簡單的接口來獲取已計算好的距離，方便視圖控制器使用。
 
    * formatPhoneNumber(_ phoneNumber: String):
        - 格式化電話號碼為台灣常見格式。
        - 使用正規表達式將電話號碼拆分為區碼和主號碼，並根據主號碼的長度調整顯示格式。
 
 3. Helper 方法的設計
 
 * 營業時間：
    - getTodayOpeningHours 方法：這個方法將每個店鋪的今日營業時間計算集中在 StoreManager 中，這樣可以減少重複邏輯，也便於管理營業時間的顯示邏輯。
    - 使用 Locale 來設定地區：DateFormatter 的地區設置為 "zh_TW"，確保顯示的星期幾與台灣本地文化匹配。
 
 * 電話號碼格式化：
    - formatPhoneNumber(_:) 方法：此方法負責將電話號碼格式化為台灣的常見顯示格式。這樣可以在視圖中展示一致的電話號碼格式。
 
 4. 定位與距離計算的優化：
    - 將距離計算的邏輯抽取到 StoreManager 中，使得距離計算和資料管理集中化，增加了代碼的可讀性和可維護性。
    - 位置更新發生時，StoreManager 將根據最新的位置自動更新店鋪距離，減少了在控制器中進行額外處理的需要。

 5. 使用情境
    - 當應用需要顯示店鋪資訊時，StoreSelectionViewController 可以通過 StoreManager.shared 來呼叫 fetchStores()，非同步地獲取所有店鋪資訊。
    - 使用 getTodayOpeningHours(for:) 方法來取得店鋪的營業時間，這樣在顯示地圖標註資訊時可以同步顯示店鋪的當日營業時間。
    - 使用 formatPhoneNumber(_:) 方法來格式化電話號碼，在顯示店鋪資訊時保持一致的格式。
 */


// MARK: - 計算每個店鋪與使用者之間的距離（calculateDistances 方法重點筆記）

/*
 ## calculateDistances 方法重點筆記

 1. 方法功能：
    - 作用是計算使用者當前位置到每個店鋪之間的距離，並保存結果，以便其他地方調用這些距離資訊。

 2. 參數與返回值：
    
    * 參數：
        - stores: [Store]：包含所有店鋪的列表。

    * 返回值：
        - 該方法沒有直接返回值，而是更新 storeDistances 字典，字典的 key 是店鋪的 ID，value 是與使用者的距離。

 3. 計算過程：
 
    - 首先檢查使用者的位置是否已獲取。
    - 對於每一個店鋪，建立一個 CLLocation 物件來表示該店鋪的經緯度。
    - 使用 userLocation.distance(from:) 方法計算使用者位置與該店鋪之間的距離，並將結果存入 storeDistances 字典中。
 
 4. 設計目的：
    - 此方法的設計目的在於統一管理店鋪與使用者之間的距離計算，將距離計算邏輯集中在 StoreManager 中，減少重複邏輯並提高代碼的可維護性。
 
 5. 定位與距離計算的關係：
 
    * 先處理定位，再計算距離：
        - 在使用此方法前，必須先獲取使用者的當前位置。因此需要使用 CLLocationManager 來處理定位操作。
        - 當獲取到使用者的位置後，調用 `updateUserLocationAndCalculateDistances(userLocation:stores:)` 來更新距離資料，確保距離資訊是最新的。
        - 只有獲取到使用者位置後，才能調用此方法計算與店鋪的距離。因此，應先「處理定位」再「計算距離」。
 
 6. 方法使用流程：
 
    * 先處理定位：
        - 在 StoreSelectionViewController 中，使用 LocationManagerHandler 取得使用者當前的位置。
        - 當位置更新時，將最新位置傳給 StoreManager。
 
    * 再計算距離：
        -  使用 StoreManager 的 updateUserLocationAndCalculateDistances(userLocation:stores:) 方法來計算每個店鋪與使用者之間的距離。
 
    * 顯示結果：
        -  透過 StoreSelectionMapHandlerDelegate，將計算出的距離顯示在店鋪詳細訊息中，例如店鋪資訊彈窗中顯示與使用者的距離。
 
 7. 顯示距離的應用：
    - 當顯示店鋪詳細資料時 presentStoreDetailsAlert(for:todayOpeningHours:)，會使用 getDistanceToStore(for:) 取得店鋪距離，並以「公里」為單位顯示，增強使用者體驗，幫助他們了解店鋪與自己之間的距離。
 */


// MARK: - 關於「電話號碼」的格式存取跟使用問題
/*
 ## 關於「電話號碼」的格式存取跟使用問題：
 
 1. 為何要將 Firebase 的電話改用純數字，而不要使用到特殊符號？
 
    - 一開始我在 Cloud Firestore 中存取電話的格式為 02-2345-6789。
    - 我的預想是會建立一個按鈕，可以藉此撥打電話號碼。
    - 才意識到撥打電話時不能有 '-' 特殊符號，一開始有去設置處理，但覺得有點多此一舉，因此就將資料庫的電話格式改為 0223456789。
    - 只有在前端畫面顯示的時候才會有 '-' 特殊符號，撥打時則直接使用 Cloud Firestore 沒有特殊符號的電話格式。
 
 * 簡單存取：
   - 電話號碼存成純數字（例如 `"0282839371"`）可以讓程式更簡單地進行數字處理或比較，例如判斷電話號碼是否相同。
 
 * 格式化顯示：
   - 這樣的設計讓資料保持一致，無論在資料庫中或後端都是簡單的數字格式。而在前端顯示時，可以依需求加上適合的格式（例如加上「-」），提高彈性。
 
 * 減少錯誤：
   - 如果直接在資料庫中儲存不同格式的電話號碼，容易在使用者輸入、資料處理等步驟中發生錯誤。因此，保持純數字格式儲存可以減少不同格式造成的潛在問題。

 2. 關於電話號碼格式
 
    - 接續的問題是，台灣區碼問題，雖然說不會輸入全部「星巴克」門市資料，但考量到「實際」層面問題，還是建立處理區碼的邏輯。
 
 * 台灣市話區碼：
   - 台灣的市話區碼不只包含 `02`，還有 `03、037、04、049、05、06、07、08、089、082、0826、0836` 等多種區碼。
 
 * 格式化顯示：
   - 在存取 Firebase 時，可以將電話號碼儲存為純數字，但在前端顯示時，可以依需求加上分隔符號，例如 `02-8283-9371`，讓用戶更容易閱讀。
 
 * 撥打電話處理：
   - 在撥打電話時，電話號碼需要保持純數字格式，以便透過 `tel://` 協議進行撥打。
   - 例如，也因為改成純數字，因此從資料庫中取出的電話號碼。所以不用在經過 `replacingOccurrences(of:)` 進行去除所有非數字字符後再使用。
 */


//MARK: - 關於 formatPhoneNumber 的處理。
/*
 ##  關於 formatPhoneNumber 的處理
 
 * 參考: https://reurl.cc/pvkZVd
 
 * 問題
    - 台灣電話號碼格式多樣，且區碼長度（2、3、4位）和號碼總長（9或10位）不一致，單純的條件判斷容易造成 - 錯誤分隔。
    - 某些地區（如離島）使用不同長度的區碼，導致無法統一格式化，例如 0836 開頭的號碼需要特殊處理。
 
 * 解決方式
    - 因為利用正規表達式有效區分區碼和主號碼，並針對主號碼的長度進行條件格式化，以滿足不同地區的格式需求，避免了區碼和號碼錯誤分段的情況。
    - 使用正規表達式解析：使用 NSRegularExpression 和模式 ^(0836|0826|082|089|08|07|06|05|049|04|037|03|02)(\d+)$，只匹配有效的台灣區碼開頭，並將區碼和號碼分開。
        
        1. ^(0836|0826|082|089|08|07|06|05|049|04|037|03|02)： 匹配台灣常見的區碼，避免處理不相關的格式。
        2. (\d+)$： 將區碼以後的部分視為主號碼，無論其長度為7或8位。
 
 * 分組擷取：
    - 若符合格式，透過 regex.firstMatch 方法擷取 areaCode 和 mainNumber 兩部分：

        1. areaCode：為符合的台灣地區區碼。
        2. mainNumber：區碼後的主號碼。
 
 * 動態格式化主號碼長度：
    - 若主號碼為 8位數：格式化為 XXXX-XXXX。
    - 若主號碼為 7位數或更短：格式化為 區碼-號碼，僅以單一 - 分隔，避免多餘的分段。
 
 * 備選方案：
    - 當無法匹配到正確格式時（如非有效區碼），直接返回原始號碼，避免錯誤分隔。
 */

// MARK: - 將距離計算邏輯抽取到 StoreManager 中，以便統一處理所有店鋪相關的邏輯。

import Foundation
import Firebase
import MapKit

/// 用於處理與店鋪相關的資料操作
class StoreManager {
    
    // MARK: - Properties
    
    static let shared = StoreManager()
    
    /// 保存每個店鋪與使用者的距離
    private var storeDistances: [String: CLLocationDistance] = [:]
    /// 使用者目前的位置
    private var userLocation: CLLocation?
    
    // MARK: - Fetch Stores

    /// 從 Firestore 中獲取所有店鋪資料
    /// - Returns: 返回包含所有店鋪的陣列
    func fetchStores() async throws -> [Store] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("stores").getDocuments()
        
        var stores: [Store] = []
        for document in snapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String,
               let location = data["location"] as? GeoPoint,
               let address = data["address"] as? String,
               let phoneNumber = data["phoneNumber"] as? String,
               let openingHours = data["openingHours"] as? [String: String]{
                
                let store = Store(id: document.documentID, name: name, location: location, address: address, phoneNumber: phoneNumber, openingHours: openingHours)
                stores.append(store)
            }
        }
        return stores
    }
    
    // MARK: - Helper Methods
    
    /// 根據當前日期返回所有店鋪的今日營業時間
    /// - Parameter stores: 包含所有店鋪的陣列
    /// - Returns: 每個店鋪 ID 與其對應今日營業時間的字典
    func getTodayOpeningHours(for stores: [Store]) -> [String: String] {
        var todayOpeningHoursDict: [String: String] = [:]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")  // 設定地區
        formatter.dateFormat = "EEEE"                   // 取得今天是星期幾

        let today = formatter.string(from: Date())

        for store in stores {
            if let todayHours = store.openingHours[today] {
                todayOpeningHoursDict[store.id] = todayHours
            } else {
                todayOpeningHoursDict[store.id] = "營業時間未提供"
            }
        }
        
        return todayOpeningHoursDict
    }
    
    /// 格式化電話號碼為台灣常見格式
    /// - Parameter phoneNumber: 原始電話號碼
    /// - Returns: 格式化後的電話號碼
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        
        /// 定義台灣的有效區碼
        let pattern = #"^(0836|0826|082|089|08|07|06|05|049|04|037|03|02)(\d+)$"#
        
        // 使用正規表達式來解析區碼和主號碼部分
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: phoneNumber, options: [], range: NSRange(location: 0, length: phoneNumber.count)) {
            let areaCodeRange = match.range(at: 1)
            let mainNumberRange = match.range(at: 2)
            
            if let areaCode = Range(areaCodeRange, in: phoneNumber),
               let mainNumber = Range(mainNumberRange, in: phoneNumber) {
                let areaCodeStr = String(phoneNumber[areaCode])
                let mainNumberStr = String(phoneNumber[mainNumber])
                
                // 根據主號碼長度調整格式
                if mainNumberStr.count == 8 {
                    return "\(areaCodeStr)-\(mainNumberStr.prefix(4))-\(mainNumberStr.suffix(4))"   // 8碼情況：分成4-4格式
                } else {
                    return "\(areaCodeStr)-\(mainNumberStr)"                                       // 7碼或更短情況：顯示為完整號碼
                }
            }
        }
        return phoneNumber       // 若無法匹配到正確格式，返回原始號碼
    }

    // MARK: - Distance Calculation
    
    /// 更新用戶的位置並計算與店鋪的距離
    /// - Parameter userLocation: 用戶當前的位置
    /// - Parameter stores: 店鋪的列表
    func updateUserLocationAndCalculateDistances(userLocation: CLLocation, stores: [Store]) {
        self.userLocation = userLocation
        calculateDistances(to: stores)
    }
    
    /// 計算每個店鋪與用戶當前位置的距離
    /// - Parameter stores: 店鋪的列表
    private func calculateDistances(to stores: [Store]) {
        guard let userLocation = userLocation else { return }
        
        var distances: [String: CLLocationDistance] = [:]
        
        for store in stores {
            let storeLocation = CLLocation(latitude: store.location.latitude, longitude: store.location.longitude)
            let distance = userLocation.distance(from: storeLocation)
            distances[store.id] = distance
        }
        
        storeDistances = distances
    }
    
    /// 取得與特定店鋪的距離
    /// - Parameter storeId: 店鋪的唯一標識符
    /// - Returns: 與用戶位置之間的距離
    func getDistanceToStore(for storeId: String) -> CLLocationDistance? {
        return storeDistances[storeId]
    }
    
}
