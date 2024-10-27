//
//  StoreSelectionViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - https://reurl.cc/0dNdzM ( MapKit / CoreLocation / CLGeocode)

// MARK: - 設計構想

/*
 ## 設計構想：
 
    - 主要是 OrderPickupMethodCell 目前的 selectStoreButtonTapped 是設置「大安店」來模擬店家。
    - 而想法是搭配「星巴克」門市資訊，讓使用者可以透過地圖來定位自身位置，並且可以知道自己附近有哪些「星巴克」門市。
 
 1. 「選擇店家視圖控制器」的設計：
    - 使用地圖顯示門市資訊，讓用戶可以快速找到附近門市，直覺且實用。
 
 2. 門市資訊導入方式：
    - 在 Firebase 中儲存門市資料（座標、名稱、電話、地址等）。
    - 進入店家選擇視圖控制器時，從 Firebase 讀取資料並顯示在地圖上。
 
 3. 定位自身位置：
    - 使用 CoreLocation API 來獲取使用者位置，配合地圖顯示附近的門市。
    - 使用 MKPointAnnotation 來標示門市位置（使用 Apple Maps）。
 
 4. 資料儲存位置的選擇：
    - 若門市資訊不常變動，可考慮本地端儲存（如 plist）。
    - 若門市資訊需經常更新，建議使用 Firebase 儲存，以便隨時更新和同步。
 
 5. 地圖 API 選擇：
    - Apple Maps (MapKit)：適合 iOS 平台，簡單易用，與 CoreLocation 結合良好。
    - 第三方框架（如 Google Maps SDK）：適合需要自定義地圖樣式、跨平台或更豐富的功能，但增加應用的複雜性。
 
 7. 想法：
    - 使用 MapKit 配合 CoreLocation，足以滿足門市顯示和定位需求，且與 iOS 系統整合好。
    - 將門市資料存儲在 Firebase 中，方便更新變動資訊。
    - 先從 Apple Maps 開始設計，後續若有需求再考慮整合 Google Maps 或其他框架。
 */

// MARK: - 進一步討論且需要調整

/*
 ## 進一步討論
 
 1. Apple Maps 是否可以實現「卡片式呈現門市資訊」：
    - Apple Maps (MapKit) 本身不內建「卡片式」資訊展示，需要自定義實現。
    - 當用戶點擊地圖上的標記時，可以使用 mapView(_:didSelect:) 方法顯示自定義的卡片式視圖，展示門市的電話、距離、地址、營業時間等詳細資訊。
 
 2. 門市資料如何存取：
    - Firebase 存儲：門市的「座標、電話、地址、營業時間」等資訊應儲存在 Firebase 中，以便動態讀取並在地圖上展示。
 
     {
       "storeName": "Starbucks Da'an",
       "latitude": 25.0330,
       "longitude": 121.5654,
       "phoneNumber": "+886-2-1234-5678",
       "address": "台北市大安區信義路三段 123 號",
       "openingHours": "8:00 AM - 10:00 PM"
     }
 
    - 距離計算：距離計算可在用戶端進行，使用 CoreLocation 的 API 來計算使用者位置與門市之間的距離。
 
 3. 想法的正確性與常見性：
    - 資料存取：將門市資訊存放在 Firebase 中是常見且靈活的做法，有助於同步變更。
    - 地圖呈現：使用 MapKit 搭配 Firebase 資料，是開發店鋪選擇功能的典型方法，符合用戶需求。
    - 卡片式視圖：自定義卡片式視圖顯示門市詳細資訊，增強了應用的互動性與可用性。
 */


// MARK: -  ## StoreSelectionViewController 重點筆記

/*
 ## StoreSelectionViewController 重點筆記
 
 1. 類別說明
    - StoreSelectionViewController 用來呈現地圖視圖，並顯示所有店鋪的位置，讓使用者可以選擇特定的店鋪。
    - 此類別包含地圖視圖、店鋪資料，以及與 StoreSelectionHandler 和 LocationManagerHandler 的交互邏輯。
    - 定位功能已抽離至 LocationManagerHandler 中，以更好地管理和處理位置授權與更新。
 
 2. 使用的屬性
    - storeSelectionView：包含地圖視圖的自訂視圖。
    - stores：存放從 Firebase 取得的所有店鋪資料。
    - todayOpeningHours：儲存每個店鋪今日的營業時間。
    - storeSelectionHandler：用於處理地圖上和店鋪相關的互動操作。
    - locationManagerHandler：用於管理位置更新的 Handler，負責獲取和監控使用者的位置變化，並更新店鋪距離。
 
 3. 主要方法

    * setupHandler()：
        - 將地圖視圖的代理設置為 StoreSelectionHandler，並將 StoreSelectionHandler 的代理設置為 StoreSelectionViewController，以便協作處理地圖上的選擇動作及店鋪資訊的顯示。
 
    * setupLocationManagerHandler()：
        - 設置 LocationManagerHandler 的代理，並啟動位置更新。
        - 透過委派模式，當位置授權和更新變化時，LocationManagerHandler 會通知 StoreSelectionViewController。
 
    * fetchAndDisplayStores()：
        - 從 Firebase 獲取所有店鋪資料，並將每個店鋪以標註 (annotation) 的方式顯示在地圖上。 
 
    * formatPhoneNumber(_:)：
        - 格式化店鋪的電話號碼，使其符合台灣的常見格式，例如添加區域碼和適當的符號分隔。
 
 4. StoreSelectionHandlerDelegate 作用
    - 代理模式的使用：StoreSelectionHandlerDelegate 用於讓 StoreSelectionHandler 請求資料並顯示店鋪詳細資訊，而這些邏輯由 StoreSelectionViewController 實作，從而將視圖控制器和地圖交互邏輯分離。
    - 距離計算的整合：新增了 fetchDistanceToStore(for:) 方法，使得在使用者點選店鋪標註時，可以顯示與該店鋪的距離。

 5. 定位與距離計算部分
 
 * 位置獲取與更新：
    - setupLocationManagerHandler()：
        - 設置 LocationManagerHandler 並啟動位置更新。
 
    - didUpdateUserLocation(location:)：
        - 當位置更新時，由 LocationManagerHandler 通知代理 (StoreSelectionViewController) 並進一步調用 StoreManager.shared.updateUserLocationAndCalculateDistances() 更新與店鋪的距離。
 
    - didReceiveLocationAuthorizationDenied：
        - 當位置權限被拒絕時調用，顯示提示訊息，引導使用者前往設定頁面開啟位置權限。

 * 距離展示：
    - 使用 fetchDistanceToStore(for:) 方法（StoreSelectionHandlerDelegate 的實現）來查找特定店鋪與使用者之間的距離，並在店鋪詳細信息的彈窗中顯示該距離。
    - 該方法最終調用的是 StoreManager 中的 getDistanceToStore(for:) 方法來獲取距離資料，從而增強使用者對店鋪位置的感知。 
    - 在店鋪詳細信息的彈窗中顯示該距離，增強使用者對店鋪位置的感知。

 5. 想法
 
    * 清晰的職責分離：
        - StoreSelectionViewController 負責資料的獲取和顯示。
        - StoreSelectionHandler 負責地圖交互。
        - LocationManagerHandler 負責位置更新和授權處理，減少了重複的邏輯並簡化了視圖控制器的負擔。
 
    * 提高可重用性：
        - 如果需要重新設計地圖交互，修改 StoreSelectionHandler 不會影響 StoreSelectionViewController。
        - 使用 LocationManagerHandler 集中處理位置邏輯，讓其他視圖控制器可以重複使用這部分的功能。
 */


// MARK: - 關於 「地區時間」轉換：

/*
 ### 重點筆記

 * 關於 "Today's Opening Hours: 營業時間未提供" 的問題：
    - 雖然已經在 Cloud Firestore 設定好營業時間了。但因為我是設置「星期一、星期二」，而非「Monday等」。
    - print("Today's Opening Hours: \(todayHours)") 出現 「Today's Opening Hours: 營業時間未提供」。
 
 * 問題原因：
   - 出現「營業時間未提供」是因為在尋找今天的營業時間時，無法匹配到相應的資料。
   - 這與 DateFormatter 設定的地區 (Locale) 有關，或是與 dateFormat 格式不正確導致日期轉換錯誤。
 
 - 解決方式：
   - 確保 DateFormatter 使用正確的地區（台灣應設為 "zh_TW"）。
   - 使用與 Firebase 資料中的日期鍵值相符的格式，例如 Firebase 中使用「星期一、星期二」，那 DateFormatter 應設為「EEEE」並設定為台灣的語系。
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

// MARK: -  StoreSelectionHandler vs. LocationManagerHandler 的責任劃分

/*
 ## StoreSelectionHandler vs. LocationManagerHandler 的責任劃分
 
 &. StoreSelectionHandler：

    * 職責：
        - 處理「地圖視圖上的交互邏輯」。
    
    * 主要任務：
        - 管理使用者與地圖之間的互動，例如選取地圖上的標註（annotation）以顯示店鋪詳細資訊。
        - 簡單來說，`StoreSelectionHandler` 專注於地圖上的點選與標註的互動，因此它的職責應聚焦於處理使用者如何與地圖進行交互。
 
    * 責任劃分：
        - 確保與地圖標註相關的所有操作都集中在這裡，減少視圖控制器的複雜度，便於管理地圖交互的相關邏輯。
 
 &. LocationManagerHandler：

    * 職責：
        - 處理「定位和位置更新」。

    * 主要任務：
        - 管理位置權限的請求，例如首次請求定位權限以及監聽權限變更。
        - 追蹤用戶的實時位置，並在位置更新時通知代理，以便其他模組根據位置變化執行相應邏輯。

    * 責任劃分：
        - 所有與位置權限、位置更新相關的邏輯都應集中在 `LocationManagerHandler` 中，使得位置管理的邏輯與其他應用邏輯分離，保持職責單一。

    * 設計優勢
        - 透過使用代理 (`delegate`) 通知位置更新或權限變更，這樣可以讓 `LocationManagerHandler` 易於與不同的視圖控制器進行整合，提高代碼的可重用性
 */

// MARK: - 定位與店面距離處理步驟總結

/*
 ## 定位與店面距離處理步驟總結
 
    - 在 App 中設置「與門市的距離」功能，能夠提升使用者體驗，幫助他們找到最適合的店鋪。

 1. 先處理定位
    - 定位是整個流程的第一步，需要獲取使用者的當前位置才能計算與門市的距離。這部分由 LocationManagerHandler 來實現，使用 Core Location 框架來管理位置更新。

    * 請求定位權限：
        - 在 LocationManagerHandler 中使用 CLLocationManager 請求和獲取使用者的定位權限。
        - 在初始化時（init() 方法），設定 CLLocationManager 的代理，並設置精度（desiredAccuracy）。
        - 使用 startLocationUpdates() 方法請求權限，並根據授權狀態來決定是否啟動位置更新。

    * 獲取使用者的當前位置：
        - 當 CLLocationManager 更新到使用者的位置時，LocationManagerHandler 會通過代理（LocationManagerHandlerDelegate）通知 StoreSelectionViewController，將最新的位置信息傳遞過去。
 
 2. 計算與每個門市的距離
    - 當定位獲取成功後，可以進行距離計算，這部分由 StoreManager 負責處理。

    * 在 StoreManager 中集中處理距離計算：
        - 使用 updateUserLocationAndCalculateDistances(userLocation: stores:) ，計算使用者當前位置到每個店鋪的距離，並將結果保存起來。
        - 使用者的當前位置通過 LocationManagerHandler 傳遞給 StoreSelectionViewController，再傳遞給 StoreManager 進行距離計算，這樣能保持位置和店鋪數據的一致性。
 
 3. 顯示距離資訊
    
    * 地圖上的互動與詳細資訊顯示：
        - 在地圖上顯示店鋪位置，並標註每個店鋪的距離。使用 StoreSelectionHandler 處理地圖視圖的互動，當使用者選取地圖上的標註時，顯示店鋪的詳細資訊，包括與使用者的距離。
        - 使用 StoreSelectionHandlerDelegate 取得店鋪距離，並在顯示店鋪詳細訊息的彈窗中顯示，例如「距離：2.5 公里」。
 
 4. 設計思路與建議

    * 定位與距離計算的順序：
        - 先處理定位，再計算距離。定位是距離計算的基礎，只有獲取到使用者位置後，才能計算與店鋪的距離。
 
    * 集中管理距離計算的邏輯：
        - 距離計算邏輯應放置在 StoreManager 中，這樣能統一處理與店鋪數據相關的操作，保持代碼的可維護性和邏輯的一致性。
 
    * 保持視圖控制器的簡潔：
        - StoreSelectionViewController 應該專注於視圖展示和用戶互動，避免混合太多數據處理的邏輯。
        - 因此，將距離計算集中在 StoreManager 和定位邏輯集中在 LocationManagerHandler 中，是一個較好的設計選擇。
 
 5. 總結
    - 先處理定位：使用 LocationManagerHandler 獲取使用者的位置，並通過代理通知 StoreSelectionViewController。
    - 再計算距離：使用 StoreManager 計算每個店鋪到使用者之間的距離，並保存結果。
    - 最佳化使用者體驗：當定位成功後，根據計算的距離顯示最接近的店鋪，或標示距離遠近，讓使用者可以方便地選擇合適的店鋪。
 */


import UIKit
import MapKit

/// StoreSelectionViewController 用來呈現地圖視圖，並顯示所有店鋪的位置，讓使用者可以選擇特定的店鋪。
class StoreSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 顯示店家選擇地圖的主要視圖
    private let storeSelectionView = StoreSelectionView()
    /// 所有店鋪資料的陣列
    private var stores: [Store] = []
    /// 保存每個店鋪的今日營業時間
    private var todayOpeningHours: [String: String] = [:]
    /// 處理地圖上相關互動的 handler
    private let storeSelectionHandler = StoreSelectionHandler()
    /// 處理定位距離的 handler
    private let locationManagerHandler = LocationManagerHandler()
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        view = storeSelectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupHandler()
        setupLocationManagerHandler()
        fetchAndDisplayStores()
    }
    
    // MARK: - Setup Methods
    
    /// 設置導航欄的標題
    private func setupNavigationTitle() {
        title = "Select Store"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    /// 設置 StoreSelectionHandler 的代理
    private func setupHandler() {
        storeSelectionView.mapView.delegate = storeSelectionHandler
        storeSelectionHandler.delegate = self
    }
    
    /// 設置 setupLocationManagerHandler 的代理
    private func setupLocationManagerHandler() {
        locationManagerHandler.delegate = self
        locationManagerHandler.startLocationUpdates()
    }

    // MARK: - Fetch Stores and Display
    
    /// 從 Firestore 中拉取`店鋪資料`並顯示在地圖上
    private func fetchAndDisplayStores() {
        Task {
            do {
                stores = try await StoreManager.shared.fetchStores()
                todayOpeningHours = StoreManager.shared.getTodayOpeningHours(for: stores)
                
                // 在地圖上顯示店鋪
                for store in stores {
                    let annotation = MKPointAnnotation()
                    annotation.title = store.name
                    annotation.coordinate = CLLocationCoordinate2D(latitude: store.location.latitude, longitude: store.location.longitude)
                    storeSelectionView.mapView.addAnnotation(annotation)
                }
            } catch {
                print("Failed to fetch stores: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: "無法載入店鋪資訊，請稍後再試。", inViewController: self, showCancelButton: false, completion: nil)
            }
        }
    }
    
    // MARK: - Helper Methods

    /// 格式化電話號碼為台灣常見格式
    private func formatPhoneNumber(_ phoneNumber: String) -> String {
        // 處理台北區域碼，例如 "02xxxxxxxx"
        if phoneNumber.hasPrefix("02") {
            let areaCode = phoneNumber.prefix(2)
            let mainNumber = phoneNumber.dropFirst(2)
            return "\(areaCode)-\(mainNumber.prefix(4))-\(mainNumber.suffix(4))"
        } else if phoneNumber.count == 10 {
            // 處理其他區域碼，例如 "03xxxxxxxx" 或 "04xxxxxxxx"
            let areaCode = phoneNumber.prefix(3)
            let mainNumber = phoneNumber.dropFirst(3)
            return "\(areaCode)-\(mainNumber.prefix(3))-\(mainNumber.suffix(4))"
        } else if phoneNumber.count == 9 {
            // 處理區域碼例如 "0826xxxx" 或 "037xxxx"
            let areaCode = phoneNumber.prefix(4)
            let mainNumber = phoneNumber.dropFirst(4)
            return "\(areaCode)-\(mainNumber)"
        }
        return phoneNumber
    }
    
}

// MARK: - LocationManagerHandlerDelegate
extension StoreSelectionViewController: LocationManagerHandlerDelegate {
    
    /// 當位置更新時調用
    /// - Parameter location: 使用者當前的位置 (`CLLocation`)
    /// 調用 StoreManager 更新使用者位置並計算與所有店鋪之間的距離。
    func didUpdateUserLocation(location: CLLocation) {
        StoreManager.shared.updateUserLocationAndCalculateDistances(userLocation: location, stores: stores)
    }
    
    /// 當位置權限被拒絕時調用
    /// 顯示提示訊息，引導使用者前往設定頁面開啟位置權限。
    func didReceiveLocationAuthorizationDenied() {
        AlertService.showAlert(withTitle: "位置權限已關閉", message: "請前往設定開啟位置權限，以使用附近店鋪的相關功能。", inViewController: self, showCancelButton: true, completion: nil)
    }
}

// MARK: - StoreSelectionHandlerDelegate
extension StoreSelectionViewController: StoreSelectionHandlerDelegate {
    
    /// 取得所有店鋪資料
    func getStores() -> [Store] {
        return stores
    }
    
    /// 取得特定店鋪的今日營業時間
    func getTodayOpeningHours(for storeId: String) -> String {
        return todayOpeningHours[storeId] ?? "營業時間未提供"
    }
    
    /// 取得特定店鋪的距離
    func fetchDistanceToStore(for storeId: String) -> CLLocationDistance? {
        return StoreManager.shared.getDistanceToStore(for: storeId)
    }
    
    /// 顯示選定店鋪的詳細訊息
    func presentStoreDetailsAlert(for store: Store, todayOpeningHours: String) {
        let formattedPhoneNumber = formatPhoneNumber(store.phoneNumber)
        let distance = fetchDistanceToStore(for: store.id)
        let distanceString = distance != nil ? String(format: "%.2f 公里", distance! / 1000) : "距離未提供"
        
        let alertController = UIAlertController(
            title: store.name,
            message: "地址: \(store.address)\n電話: \(formattedPhoneNumber)\n今日營業時間: \(todayOpeningHours)\n距離: \(distanceString)",
            preferredStyle: .actionSheet
        )
        
        alertController.addAction(UIAlertAction(title: "撥打電話", style: .default, handler: { _ in
            // 使用 store.phoneNumber 電話號碼進行撥打
            if let phoneURL = URL(string: "tel://\(store.phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            } else {
                print("設備不支援撥打電話")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}



// MARK: - 初期測試用

/*
 import UIKit
 import MapKit

 class StoreSelectionViewController: UIViewController {

     // MARK: - Properties

     private let storeSelectionView = StoreSelectionView()
     private var stores: [Store] = []

     // MARK: - Lifecycle Methods

     override func loadView() {
         view = storeSelectionView
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupNavigationTitle()
         setupMap()
         fetchAndDisplayStores()
     }

     // MARK: - Setup Methods

     /// 設置導航欄的標題
     private func setupNavigationTitle() {
         title = "Select Store"
         navigationController?.navigationBar.prefersLargeTitles = true
         navigationItem.largeTitleDisplayMode = .always
     }
     
     // MARK: - Map Setup
     
     private func setupMap() {
         storeSelectionView.mapView.delegate = self
     }
     
     // MARK: - Fetch Stores and Display
     
     private func fetchAndDisplayStores() {
         
         // 在這裡從 Firebase 或其他數據源中獲取門市位置的數據
         // 並將其標示在地圖上，例如使用 MKPointAnnotation
         
         // 模擬店鋪資料
         stores = [
             Store(id: "1", name: "Starbucks Da'an", latitude: 25.0330, longitude: 121.5654, address: "106台北市大安區復興南路一段323號", phoneNumber: "02 2325 9473", openingHours: [
                 "Monday": "07:30–19:00",
                 "Tuesday": "07:30–19:00",
                 "Wednesday": "07:30–19:00",
                 "Thursday": "07:30–19:00",
                 "Friday": "07:30–19:00",
                 "Saturday": "08:30–17:30",
                 "Sunday": "08:30–17:30"
             ]),
             Store(id: "2", name: "Starbucks Xinyi", latitude: 25.0321, longitude: 121.5678, address: "110台北市信義區信義路五段106號", phoneNumber: "02 2723 5947", openingHours: [
                 "Monday": "07:30–19:00",
                 "Tuesday": "07:30–19:00",
                 "Wednesday": "07:30–19:00",
                 "Thursday": "07:30–19:00",
                 "Friday": "07:30–19:00",
                 "Saturday": "08:30–17:30",
                 "Sunday": "08:30–17:30"
             ])
         ]
         
         // 將店鋪標示在地圖上
         for store in stores {
             let annotation = MKPointAnnotation()
             annotation.title = store.name
             annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
             storeSelectionView.mapView.addAnnotation(annotation)
         }
         
     }
 }

 // MARK: - MKMapViewDelegate
 extension StoreSelectionViewController: MKMapViewDelegate {
     
     func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
         guard let annotation = view.annotation else { return }

         
         // 根據標記的 title 找到對應的 store
         guard let store = stores.first(where: { $0.name == annotation.title}) else {
             print("未找到對應的店鋪資料")
             return
         }
         
         // 打印店家詳細資料
         print("Selected store: \(store.name)")
         print("Address: \(store.address)")
         print("Phone: \(store.phoneNumber)")
         print("Today's Opening Hours: \(store.todayOpeningHours())")
         
         // 顯示簡單的 UIAlertController 來展示選擇的店鋪信息
         let alertController = UIAlertController(title: store.name, message: "地址: \(store.address)\n電話: \(store.phoneNumber)\n今日營業時間: \(store.todayOpeningHours())", preferredStyle: .actionSheet)

         // 添加一個動作來展示電話號碼（實際開發中可以替換為更完整的卡片式視圖）
         alertController.addAction(UIAlertAction(title: "撥打電話", style: .default, handler: { _ in
             if let phoneURL = URL(string: "tel://\(store.phoneNumber)") {
                 if UIApplication.shared.canOpenURL(phoneURL) {
                     UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                 }
             }
         }))

         alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
         present(alertController, animated: true, completion: nil)
     }
 }
 */


