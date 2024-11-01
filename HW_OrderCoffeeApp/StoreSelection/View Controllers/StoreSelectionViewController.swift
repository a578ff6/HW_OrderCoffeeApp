//
//  StoreSelectionViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/25.
//

// MARK: - https://reurl.cc/0dNdzM ( MapKit / CoreLocation / CLGeocode)

// MARK: - 設計構想

/**
 ## 設計構想：
 
    - 主要是` OrderPickupMethodCell` 目前的 `selectStoreButtonTapped` 是設置「大安店」來模擬店家。
    - 而想法是搭配「星巴克」門市資訊，讓使用者可以透過地圖來定位自身位置，並且可以知道自己附近有哪些「星巴克」門市。
 
 `1. 「選擇店家視圖控制器」的設計`：
    - 使用地圖顯示門市資訊，讓用戶可以快速找到附近門市，直覺且實用。
 
 `2. 門市資訊導入方式：`
    - 在 Firebase 中儲存門市資料（座標、名稱、電話、地址等）。
    - 進入店家選擇視圖控制器時，從 Firebase 讀取資料並顯示在地圖上。
 
 `3. 定位自身位置：`
    - 使用 `CoreLocation API` 來獲取使用者位置，配合地圖顯示附近的門市。
    - 使用 `MKPointAnnotation` 來標示門市位置（使用 Apple Maps）。
 
 `4. 資料儲存位置的選擇：`
    - 若門市資訊不常變動，可考慮本地端儲存（如 plist）。
    - 若門市資訊需經常更新，建議使用 Firebase 儲存，以便隨時更新和同步。
 
 `5. 地圖 API 選擇：`
    - Apple Maps (MapKit)：適合 iOS 平台，簡單易用，與 CoreLocation 結合良好。
    - 第三方框架（如 Google Maps SDK）：適合需要自定義地圖樣式、跨平台或更豐富的功能，但增加應用的複雜性。
 
 `7. 想法：`
    - 使用 MapKit 配合 CoreLocation，足以滿足門市顯示和定位需求，且與 iOS 系統整合好。
    - 將門市資料存儲在 Firebase 中，方便更新變動資訊。
    - 先從 Apple Maps 開始設計，後續若有需求再考慮整合 Google Maps 或其他框架。
 */

// MARK: - 進一步討論且需要調整

/**
 ## 進一步討論
 
 `1. Apple Maps 是否可以實現「卡片式呈現門市資訊」：`
    - Apple Maps (MapKit) 本身不內建「卡片式」資訊展示，需要自定義實現。
    - 當用戶點擊地圖上的標記時，可以使用 mapView(_:didSelect:) 方法顯示自定義的卡片式視圖，展示門市的電話、距離、地址、營業時間等詳細資訊。
 
 `2. 門市資料如何存取：`
 
    * `Firebase 存儲`：
        - 門市的「座標、電話、地址、營業時間」等資訊應儲存在 Firebase 中，以便動態讀取並在地圖上展示。
 
    {
       "storeName": "Starbucks Da'an",
       "latitude": 25.0330,
       "longitude": 121.5654,
       "phoneNumber": "+886-2-1234-5678",
       "address": "台北市大安區信義路三段 123 號",
       "openingHours": "8:00 AM - 10:00 PM"
     }
 
    * `距離計算`：
        - 距離計算可在用戶端進行，使用 CoreLocation 的 API 來計算使用者位置與門市之間的距離。
 
 `3. 想法的正確性與常見性：`
 
    - 資料存取：將門市資訊存放在 Firebase 中是常見且靈活的做法，有助於同步變更。
    - 地圖呈現：使用 MapKit 搭配 Firebase 資料，是開發店鋪選擇功能的典型方法，符合用戶需求。
    - 卡片式視圖：自定義卡片式視圖顯示門市詳細資訊，增強了應用的互動性與可用性。
 */


// MARK: -  ## StoreSelectionViewController 重點筆記

/**
 ## StoreSelectionViewController 重點筆記
 
 `1. 類別說明`
    - `StoreSelectionViewController` 用來呈現地圖視圖，並顯示所有店鋪的位置，讓使用者可以選擇特定的店鋪。
    - 此類別包含地圖視圖、店鋪資料，以及與 `StoreSelectionMapHandler` 和 `LocationManagerHandler` 的交互邏輯。
    - 定位功能已抽離至` LocationManagerHandler` 中，以更好地管理和處理位置授權與更新。
 
 `2. 使用的屬性`
    - `storeSelectionMapView`：包含地圖視圖的自訂視圖。
    - `stores`：存放從 Firebase 獲取的所有店鋪資料。
    - `todayOpeningHours`：儲存每個店鋪今日的營業時間。
    - `storeSelectionMapHandler`：用於處理地圖上和店鋪相關的互動操作。
    - `locationManagerHandler`：用於管理位置更新的 Handler，負責獲取和監控使用者的位置變化，並更新店鋪距離。
    - `floatingPanelController`：用於展示店鋪詳細資訊的浮動面板，提升店鋪資訊的顯示體驗。
 
 `3. 主要方法`

    * `setupMapInteractionHandler()`：
        - 將地圖視圖的代理設置為 `StoreSelectionMapHandler`，並將 `StoreSelectionMapHandler` 的代理設置為 `StoreSelectionViewController`，以便協作處理地圖上的選擇動作及店鋪資訊的顯示。

    * `setupLocationManagerHandler()`：
        - 設置 `LocationManagerHandler` 的代理，並啟動位置更新。
        - 透過委派模式，當位置授權和更新變化時，`LocationManagerHandler` 會通知 `StoreSelectionViewController`。

    * `fetchAndDisplayStores()`：
        - 從 Firebase 獲取所有店鋪資料，並將每個店鋪以標註 (annotation) 的方式顯示在地圖上。
 
    * `setupFloatingPanel()`：
        - 使用 `FloatingPanelHelper` 設置浮動面板來顯示選定店鋪的詳細資訊，取代傳統的彈出視窗方式，提供更豐富的顯示效果。
 
 `4. StoreSelectionMapHandlerDelegate 作用`
 
    * `代理模式的使用`：
        - `StoreSelectionMapHandlerDelegate` 用於讓 `StoreSelectionMapHandler` 請求資料並顯示店鋪詳細資訊，而這些邏輯由 `StoreSelectionViewController` 實作，從而將視圖控制器和地圖交互邏輯分離。
        - 當用戶選擇店鋪標註時，通過代理通知控制器，並通過 FloatingPanel 來顯示該店鋪的詳細資訊。

    * `距離計算的整合`：
        - 新增了`fetchDistanceToStore(for:)`方法，使得在使用者點選店鋪標註時，可以顯示與該店鋪的距離。
        - 這些距離由 `StoreManager` 計算和管理，通過 `getDistanceToStore(for:)` 取得。
 
    * `didSelectStore()` 的設置：
         - 在用戶選擇某店鋪標註時，設置 `StoreInfoViewController` 為浮動面板的內容控制器，並將 `StoreSelectionResultDelegate` 的代理設置為當前控制器。
         - 通知主畫面 (`OrderCustomerDetailsViewController`) 所選擇的門市名稱，並在用戶確認後關閉浮動面板。
 
 `5. 定位與距離計算部分`
 
    * `位置獲取與更新`：
 
    - `setupLocationManagerHandler()`：
        - 設置 `LocationManagerHandler` 並啟動位置更新。

    - `didUpdateUserLocation(location:)`：
        - 當位置更新時，由 `LocationManagerHandler` 通知代理 (`StoreSelectionViewController`) 並進一步調用 `StoreManager.shared.updateUserLocationAndCalculateDistances()` 更新與店鋪的距離。

    -  `didReceiveLocationAuthorizationDenied`：
        - 當位置權限被拒絕時調用，顯示提示訊息，引導使用者前往設定頁面開啟位置權限。
 
    - `fetchDistanceToStore(for:)` 方法：
        - 使用 `StoreManager` 中的 `getDistanceToStore(for:)` 方法來查找特定店鋪與使用者之間的距離，並在店鋪詳細訊息的彈窗中顯示該距離。增強使用者對店鋪位置的感知。
 
 `6. 浮動面板的使用`

    * 使用 `FloatingPanel` 來顯示店鋪詳細資訊：
         - 取代以往的 `UIAlertController`，提供了更豐富和持久的顯示方式。
         - 浮動面板使得使用者在選擇店鋪後可以持續查看詳細資訊，而不會被臨時彈窗打斷。
         - 使用 `floatingPanelController?.move(to: .half, animated: true)` 在選中店鋪後自動展開，增強使用者體驗。
 
 `7. StoreSelectionResultDelegate 的設置`
 
    - `StoreSelectionResultDelegate` 用於通知選擇的門市結果，以保持`主畫面`和`店鋪選擇畫面`的同步。
    - 當用戶在 `StoreInfoViewController` 中確認選擇某門市後，通過 `storeSelectionDidComplete(with:)` 方法來通知主畫面，確保選擇的門市能夠即時反映在訂單中。
 
 `8. 想法`
 
    * `清晰的職責分離`：
        - `StoreSelectionViewController` 負責資料的獲取和顯示。
        - `StoreSelectionMapHandler` 負責地圖交互。
        - `LocationManagerHandler` 負責位置更新和授權處理，減少了重複的邏輯並簡化了視圖控制器的負擔。

    * `提高可重用性`：
        - 如果需要重新設計地圖交互，修改 `StoreSelectionMapHandler` 不會影響 `StoreSelectionViewController`。
        - 使用 `LocationManagerHandler` 集中處理位置邏輯，讓其他視圖控制器可以重複使用這部分的功能。
 */


// MARK: - 關於 「地區時間」轉換：

/**
 ### 重點筆記

 * `關於 "Today's Opening Hours: 營業時間未提供" 的問題：`
 
    - 雖然已經在 Cloud Firestore 設定好營業時間了。但因為我是設置「星期一、星期二」，而非「Monday等」。
    - print("Today's Opening Hours: \(todayHours)") 出現 「Today's Opening Hours: 營業時間未提供」。
 
 * `問題原因：`
 
   - 出現「營業時間未提供」是因為在尋找今天的營業時間時，無法匹配到相應的資料。
   - 這與 DateFormatter 設定的地區 (Locale) 有關，或是與 dateFormat 格式不正確導致日期轉換錯誤。
 
 - `解決方式：`
 
   - 確保 DateFormatter 使用正確的地區（台灣應設為 "zh_TW"）。
   - 使用與 Firebase 資料中的日期鍵值相符的格式，例如 Firebase 中使用「星期一、星期二」，那 DateFormatter 應設為「EEEE」並設定為台灣的語系。
 */



// MARK: -  StoreSelectionMapHandler vs. LocationManagerHandler 的責任劃分

/**
 ## StoreSelectionMapHandler vs. LocationManagerHandler 的責任劃分
 
 `&. StoreSelectionMapHandler`：

    * `職責`：
        - 處理「地圖視圖上的交互邏輯」。
    
    * `主要任務`：
        - 管理使用者與地圖之間的互動，例如選取地圖上的標註（annotation）以顯示店鋪詳細資訊。
        - 簡單來說，`StoreSelectionMapHandler` 專注於地圖上的點選與標註的互動，因此它的職責應聚焦於處理使用者如何與地圖進行交互。
 
    * `責任劃分`：
        - 確保與地圖標註相關的所有操作都集中在這裡，減少視圖控制器的複雜度，便於管理地圖交互的相關邏輯。
 
` &. LocationManagerHandler：`

    * `職責`：
        - 處理「定位和位置更新」。

    * `主要任務`：
        - 管理位置權限的請求，例如首次請求定位權限以及監聽權限變更。
        - 追蹤用戶的實時位置，並在位置更新時通知代理，以便其他模組根據位置變化執行相應邏輯。

    * `責任劃分`：
        - 所有與位置權限、位置更新相關的邏輯都應集中在 `LocationManagerHandler` 中，使得位置管理的邏輯與其他應用邏輯分離，保持職責單一。

    * `設計優勢`
        - 透過使用代理 (`delegate`) 通知位置更新或權限變更，這樣可以讓 `LocationManagerHandler` 易於與不同的視圖控制器進行整合，提高代碼的可重用性
 */

// MARK: - 定位與店面距離處理步驟總結

/**
 ## 定位與店面距離處理步驟總結
 
    - 在 App 中設置「與門市的距離」功能，能夠提升使用者體驗，幫助他們找到最適合的店鋪。

 `1. 先處理定位`
 
    - 定位是整個流程的第一步，需要獲取使用者的當前位置才能計算與門市的距離。這部分由 `LocationManagerHandler` 來實現，使用 `Core Location` 框架來管理位置更新。

    * `請求定位權限`：
        - 在 `LocationManagerHandler` 中使用 CLLocationManager 請求和獲取使用者的定位權限。
        - 在初始化時（init() 方法），設定 CLLocationManager 的代理，並設置精度（desiredAccuracy）。
        - 使用` startLocationUpdates()` 方法請求權限，並根據授權狀態來決定是否啟動位置更新。

    * `獲取使用者的當前位置`：
        - 當 CLLocationManager 更新到使用者的位置時，`LocationManagerHandler` 會通過代理（`LocationManagerHandlerDelegate`）通知 `StoreSelectionViewController`，將最新的位置信息傳遞過去。
 
 `2. 計算與每個門市的距離`
 
    - 當定位獲取成功後，可以進行距離計算，這部分由 `StoreManager` 負責處理。

    * `在 StoreManager 中集中處理距離計算`：
        - 使用 `updateUserLocationAndCalculateDistances(userLocation: stores:)` ，計算使用者當前位置到每個店鋪的距離，並將結果保存起來。
        - 使用者的當前位置通過 `LocationManagerHandler` 傳遞給 `StoreSelectionViewController`，再傳遞給 `StoreManager` 進行距離計算，這樣能保持位置和店鋪數據的一致性。
 
 `3. 顯示距離資訊`
    
    * `地圖上的互動與詳細資訊顯示`：
        - 在地圖上顯示店鋪位置，並標註每個店鋪的距離。使用 `StoreSelectionMapHandler` 處理地圖視圖的互動，當使用者選取地圖上的標註時，顯示店鋪的詳細資訊，包括與使用者的距離。
        - 使用 `StoreSelectionMapHandlerDelegate` 取得店鋪距離，並在顯示店鋪詳細訊息的彈窗中顯示，例如「距離：2.5 公里」。
 
 `4. 設計思路與建議`

    * `定位與距離計算的順序`：
        - 先處理定位，再計算距離。定位是距離計算的基礎，只有獲取到使用者位置後，才能計算與店鋪的距離。
 
    * `集中管理距離計算的邏輯`：
        - 距離計算邏輯應放置在` StoreManager `中，這樣能統一處理與店鋪數據相關的操作，保持代碼的可維護性和邏輯的一致性。
 
    * `保持視圖控制器的簡潔`：
        - `StoreSelectionViewController` 應該專注於視圖展示和用戶互動，避免混合太多數據處理的邏輯。
        - 因此，將距離計算集中在 `StoreManager` 和定位邏輯集中在` LocationManagerHandler `中，是一個較好的設計選擇。
 
 `5. 總結`
    - `先處理定位`：使用 `LocationManagerHandler` 獲取使用者的位置，並通過代理通知 `StoreSelectionViewController`。
    - `再計算距離`：使用 `StoreManager` 計算每個店鋪到使用者之間的距離，並保存結果。
    - `最佳化使用者體驗`：當定位成功後，根據計算的距離顯示最接近的店鋪，或標示距離遠近，讓使用者可以方便地選擇合適的店鋪。
 */

// MARK: - 取消使用UIAlertAction展示「門市資訊」，重構 StoreSelectionMapView 呈現 「地圖」、「門市資訊」筆記

/**
 ## StoreSelectionViewController 重點筆記
 
 `1. 代理和處理器整理`

    * `LocationManagerHandlerDelegate`：
        - 用於位置更新和授權狀態的通知。

    * `StoreSelectionMapHandlerDelegate`：
        - 用於處理地圖上店鋪大頭針的點擊事件，並通知控制器更新相關的店鋪資訊。
        - 方法` didSelectStore(_ store: Store)` 在用戶選擇地圖上的店鋪時，會通知控制器顯示選中的店鋪詳細資訊。

    * `StoreInfoCollectionViewHandler`：
        - 負責管理 `StoreInfoCollectionView` 的顯示內容，包括選定店鋪的資訊顯示與按鈕的回調。
        - 處理 UICollectionViewDataSource，以集中處理店鋪資料的展示邏輯。
 
 `2. 浮動面板 (FloatingPanel) 的使用`
    
    * `浮動面板設置`：
        - 使用 `FloatingPanelController` 來顯示選定店鋪的詳細資訊，而不是以往的 `UIAlertController`。
        - 浮動面板提供了更豐富和持久的顯示方式，使得用戶可以在選擇地圖上其他店鋪的同時查看已選店鋪的詳細資訊。

    * `顯示店鋪詳細資訊`：
        - 當用戶選中地圖上的店鋪時，通過浮動面板來顯示店鋪的詳細資訊。
        - 使用` floatingPanelController?.move(to: .half, animated: true)` 來自動彈出浮動面板。
 
 `3. StoreSelectionMapHandler 設計`

    * `單一職責原則`：
        - `StoreSelectionMapHandler` 負責處理地圖上的交互操作，例如用戶點擊某個店鋪的大頭針。
        - 在 `mapView(_:didSelect:)` 方法中，通過 delegate 通知控制器已選擇的店鋪，並將控制更新和顯示交給 `StoreSelectionViewController`。
 
 `4. StoreSelectionViewController 的職責`

    * `浮動面板控制`：
        - 當地圖上店鋪被選中時，`didSelectStore(_ store: Store)` 方法會設置浮動面板中的 `StoreInfoViewController` 顯示店鋪的詳細資訊。
        - 當店鋪被取消選中時，使用 `floatingPanelController?.move(to: .tip, animated: true)` 將浮動面板收起，並重置 `StoreInfoViewController` 的內容。
    
 `5. 浮動面板使用的優勢`
    - 與原本使用的` UIAlertController` 相比，`FloatingPanel `提供更好的視覺效果，支持更多操作，不會被用戶誤解為臨時警告，而是更加一致且合適的用戶界面元素。
    - 浮動面板中的內容可以包含更多的詳細資訊，並且能持續顯示，讓用戶在地圖上進行其他操作時，也能持續查看選中店鋪的詳細資料。
 
 `6. StoreSelectionMapHandlerDelegate 更新`
    
    * `方法didSelectStore(_ store: Store)`：
        - 當用戶在地圖上點擊店鋪大頭針時，通知控制器更新選中的店鋪資訊，避免使用 UIAlertController 彈出提示。
 
 `7. StoreSelectionMapHandler 設計`
 
    * `單一職責原則：`
        - `StoreSelectionMapHandler` 負責處理地圖上的交互操作，例如用戶點擊某個店鋪的大頭針。
        - 在 `mapView(_:didSelect:) `方法中，通過 delegate 通知控制器已選擇的店鋪。
 */


// MARK: - FloatingPanelController 彈起與收起的重點筆記

/**
 ## FloatingPanelController 彈起與收起的重點筆記
 
 `&. Floating Panel 的狀態控制類型：`

 `1. FloatingPanelController 支持三種主要狀態：`
    - .tip：面板收起狀態，僅顯示面板的一部分，通常用來展示面板的標題或抓手 (grabber)。
    - .half：面板半展開狀態，用於顯示部分的詳細內容。
    - .full：面板完全展開狀態，用於顯示全部內容。
 
 `2. 面板的狀態變化：`
    - 可以使用 `FloatingPanelController` 的` move(to:animated:)` 方法來控制面板的狀態變化。
    - 例如，從 .tip 狀態移動到 .half 或 .full，用來根據用戶交互自動調整面板高度。
 
 `&. 大頭針的選取與取消選取事件`

 `1. 地圖上大頭針的選取 (didSelectStore(_:))：`
    - 當用戶在地圖上選取某個店鋪大頭針時，透過 `StoreSelectionMapHandlerDelegate` 通知 `StoreSelectionViewController`。
    - `StoreSelectionViewController` 將呼叫` floatingPanelController?.move(to: .half, animated: true)`，自動將浮動面板從 .tip 展開至 .half，以顯示選定店鋪的詳細信息。
 
 `2. 地圖上大頭針的取消選取 (didDeselectStore())：`
    - 當用戶在地圖上取消選中大頭針（例如點擊地圖空白區域）時，`didDeselectStore()` 方法被調用。
    - `StoreSelectionViewController` 將呼叫` floatingPanelController?.move(to: .tip, animated: true)`，將面板自動收回到 .tip 狀態，顯示最小化的提示訊息。

 `&. 主要方法和委派模式`
 
 1. `StoreSelectionMapHandlerDelegate`：
    - 使用委派模式 (delegate) 來處理地圖上大頭針的選取和取消選取事件，並與 `StoreSelectionViewController` 進行通信。
    - `didSelectStore(_:)`：當大頭針被選取時調用，用來展開面板並顯示詳細信息。
    - `didDeselectStore()`：當大頭針被取消選取時調用，用來收起面板至 .tip 狀態。
 
 `&. 彈起與收起面板的交互流程`
 
 1. `初始化與顯示面板`：
    - 在 viewDidLoad() 中，初始化浮動面板 (FloatingPanelController)，設置外觀、內容控制器，並添加到父控制器中。
 
 2. `用戶與地圖的交互：`

 * `大頭針選取：當用戶點擊某個店鋪的大頭針時`：
    - 透過` mapView(_:didSelect:) `方法，通知`StoreSelectionViewController`，進而調用 `didSelectStore(_:)`。
    - 在` didSelectStore(_:)` 方法中，將浮動面板狀態設置為 .half，展開面板以顯示店鋪詳細信息。
 
 * `大頭針取消選取：當用戶取消選中大頭針時`：
    - 透過 `mapView(_:didDeselect:)` 方法，通知 `StoreSelectionViewController`，進而調用 `didDeselectStore()`。
    - 在 `didDeselectStore()` 方法中，將浮動面板狀態設置為 .tip，將面板收回到最小狀態。
 
 `&. 重點結論`
 
 1.`自動調整面板狀態以適應用戶交互`：
    - 使用` floatingPanelController?.move(to:animated:)` 方法根據用戶操作來調整浮動面板的狀態，達到更加自然的使用者體驗。
 
 2.`委派模式的靈活應用`：
    - 利用委派 (delegate) 來處理地圖上大頭針的選取與取消選取事件，將地圖和浮動面板的行為有效地聯繫起來，增強了代碼的可維護性和可擴展性。
 
 3.`提供更好的用戶體驗`：
    - 當用戶點擊某個店鋪時，浮動面板會自動展開，以顯示店鋪的詳細信息。
    - 當用戶取消選擇時，浮動面板會自動收回至 .tip，避免佔用過多的螢幕空間，提升整體App的可用性。
 */

// MARK: - StoreSelectionViewController 與 StoreInfoViewController 之間的關係及 FloatingPanel 使用重點解析 (重要)

/**
 ## StoreSelectionViewController 與 StoreInfoViewController 之間的關係及 FloatingPanel 使用重點解析
 
 `&. StoreSelectionViewController 與 StoreInfoViewController 的重點關係筆記`

 1. `FloatingPanel 的結構`：
 
    - `FloatingPanel` 是一個可拖動的浮動面板，用於顯示輔助資訊而不佔用主界面過多的空間。
    - 在這個案例中，`StoreSelectionViewController` 是一個包含地圖視圖的主要控制器，而 `FloatingPanel` 中嵌入的是 `StoreInfoViewController`。

 2. `各控制器的責任分離`
 
    * `StoreSelectionViewController`：
      - 主要控制器，負責顯示地圖並呈現所有可選的店鋪位置。
      - 這裡有地圖、店鋪標記的交互、以及用戶位置的更新等功能。
      - 當用戶選擇某一個店鋪後，會透過 FloatingPanel 彈出一個視圖，顯示該店鋪的詳細資訊。
      - `StoreSelectionViewController` 也是一個整體門市選擇流程的管理者，負責將用戶的最終選擇回傳給上層控制器（例如 `OrderCustomerDetailsViewController`）。

    * `StoreInfoViewController`：
      - 嵌入在 FloatingPanel 中的子控制器，專門用來顯示門市的詳細資訊。
      - 當用戶在地圖上點擊某個店鋪標記後，`StoreInfoViewController` 會被配置以顯示該店鋪的具體資訊，如門市名稱、地址、營業時間等。
      - 這個控制器還包含操作按鈕，如撥打電話和選擇該門市作為取件門市。

 3. `用戶操作流程`
 
    - 用戶進入 `StoreSelectionViewController`，在地圖上查看所有店鋪的位置。
 
    * 用戶點擊某個店鋪的標記後：
      - `StoreSelectionViewController` 中的 FloatingPanel 彈出，並且內容控制器為` StoreInfoViewController`。
      - `StoreInfoViewController` 被配置以顯示選擇店鋪的詳細資訊。
 
    * 用戶點擊 `StoreInfoViewController` 中的「選擇門市」按鈕後，通知` StoreSelectionViewController`，並將該選擇回傳給上層控制器（例如 OrderCustomerDetailsViewController）。

 4. `關鍵的委託機制`
    
    * `StoreSelectionResultDelegate`：
      - 此委託 (`StoreSelectionResultDelegate`) 被用來通知上層控制器用戶最終的選擇結果。
      - 例如，用戶在 `StoreSelectionViewController` 中選擇了一個店鋪後，會透過這個委託將選擇結果回傳給` OrderCustomerDetailsViewController` 來更新 UI。
 
    - `StoreSelectionMapHandlerDelegate`：
      - 用來管理 `StoreSelectionViewController` 和 `StoreSelectionMapHandler` 的交互，以獲取所有店鋪資訊並處理地圖標記點的選擇和取消選擇。

 5. `StoreInfoViewController` 如何影響 `StoreSelectionViewController`：
 
    - `StoreInfoViewController` 並不直接與上層控制器（如 `OrderCustomerDetailsViewController`）溝通。
    - 相反，它會將操作結果傳遞給` StoreSelectionViewController`。
    - 在` setupSelectStoreAction `中，當用戶點擊「選擇門市」按鈕時，`StoreInfoViewController` 通知其父控制器` StoreSelectionViewController`，告知用戶已選擇該店鋪。
    - `StoreSelectionViewController `接收到這個通知後，會透過 `StoreSelectionResultDelegate`，將選擇結果傳回給 `OrderCustomerDetailsViewController`，以便更新 `OrderPickupMethodCell` 中的 `storeTextField`。

 `&. 重點理解`

 1. `FloatingPanel 作為橋梁`：
 
    - `FloatingPanel` 是介於主要地圖視圖（`StoreSelectionViewController`）和詳細資訊視圖（`StoreInfoViewController`）之間的橋梁，讓用戶能夠不離開地圖界面就能查看詳細資訊並進行選擇。

 2. `分層的責任`
 
    - 將詳細店鋪資訊顯示邏輯集中在 `StoreInfoViewController`中，使得 `StoreSelectionViewController` 更簡潔，僅需負責地圖及店鋪選擇邏輯。
    - `StoreSelectionViewController` 負責與上層控制器的溝通（如將選擇結果傳遞給 `OrderCustomerDetailsViewController`），而不是由嵌入的子控制器直接與上層控制器溝通，這樣可以減少子控制器的耦合度。

 3. `訊息傳遞的順序`
 
    - 用戶在 `StoreSelectionViewController`點擊地圖標記 -> 彈出 `FloatingPanel`，顯示 `StoreInfoViewController`。
    - 用戶在 `StoreInfoViewController` 中選擇門市 -> 通知 `StoreSelectionViewController` -> `StoreSelectionViewController` 通知上層控制器。

 透過這樣的責任分層與委託機制，可以更好地保持代碼的可讀性和可維護性，同時確保每個控制器只負責與其視圖和功能相關的邏輯。
 */


// MARK: - StoreSelectionResultDelegate 重點筆記

/**
 ## StoreSelectionResultDelegate 在 StoreSelectionViewController 中的設置重點筆記
 
 `1. StoreSelectionResultDelegate 的用途`
 
    - `StoreSelectionResultDelegate` 的主要目的是將門市選擇的結果傳遞給其他相關的視圖控制器，以確保使用者在選擇門市後，這一選擇能夠即時反映在`主訂單頁面`或其他需要顯示門市資訊的地方。
    - 它使用委派模式來保持 `StoreSelectionViewController` 和 `OrderCustomerDetailsViewController` 等其他控制器之間的同步。
 
 `2. didSelectStore()` 方法中的代理設置 (`storeInfoVC.delegate = self`)`
 
    - 當用戶在地圖上選擇一個門市時，浮動面板 (`floatingPanel`) 會顯示該門市的詳細資訊。這裡設置 `storeInfoVC.delegate = self` 的目的是讓 `StoreInfoViewController` 能夠將選擇結果通知給 `StoreSelectionViewController`。
    - 具體來說，當使用者在 `StoreInfoViewController` 中按下 "選擇門市" 的按鈕時，可以通過此代理將選擇的門市名稱傳回給 `StoreSelectionViewController`，進一步通知主畫面或其他有關的控制器。
  
 `3. func storeSelectionDidComplete(with storeName: String)`
 
    - 當使用者在 `StoreInfoViewController` 中確認選擇某門市後，會調用 `storeSelectionDidComplete(with:)` 方法來通知委託者（通常是主畫面，如 `OrderCustomerDetailsViewController`）。
    - 這樣可以確保主畫面即時獲得使用者選擇的門市資訊，例如將選定的門市名稱顯示在訂單取件方式的表單中，從而提供更好的使用者體驗和資料一致性。

 `4. 操作流程概述`
 
    * 在 `StoreSelectionViewController` 中，當使用者點選地圖上的某店鋪標註時：
        - 設置浮動面板的內容控制器 (`StoreInfoViewController`)。
        - 設置 `storeInfoVC.delegate = self`，以便在使用者最終確認門市後，透過 `StoreSelectionResultDelegate` 回傳結果。
        - 浮動面板會展示店鋪詳細資訊，使用者可以選擇該店鋪作為取件門市。
    
    * 在 `StoreInfoViewController` 中，當使用者選擇了某店鋪並確認後：
        - 調用 `delegate?.storeSelectionDidComplete(with: storeName)`，通知 `StoreSelectionViewController` 使用者的選擇。
        - `StoreSelectionViewController` 接收到選擇結果後，進一步將選定的門市名稱傳遞給主畫面的控制器，並關閉門市選擇視圖。
  
 `5. 設計考量`
 
    * `代理模式的優勢`
        - 代理模式使得 `StoreSelectionViewController` 和 `StoreInfoViewController` 之間保持了低耦合性。
        - 這樣的設計使得 `StoreInfoViewController` 可以靈活地用於其他場景中，只需設置不同的代理即可實現不同的業務邏輯。
    
    * `保持資料同步`
        - 通過 `storeSelectionDidComplete(with:)` 方法，可以確保選擇的店鋪名稱在主畫面中即時更新，減少使用者在不同界面之間切換時的混亂感。
    
    * `更好的用戶體驗`
        - 當使用者選擇店鋪後，立即在主畫面中顯示選擇結果，並且不需要重複導航或手動輸入，這樣的設計大大提升了整體體驗的流暢性。
 */


// MARK: - FloatingPanel

import UIKit
import MapKit
import FloatingPanel

/// StoreSelectionViewController 用來呈現地圖視圖，並顯示所有店鋪的位置，讓使用者可以選擇特定的店鋪。
class StoreSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 顯示店家選擇地圖的主要視圖
    private let storeSelectionMapView = StoreSelectionMapView()
    /// 所有店鋪資料的陣列
    private var stores: [Store] = []
    /// 保存每個店鋪的今日營業時間
    private var todayOpeningHours: [String: String] = [:]
    /// 處理地圖上相關互動的 handler
    private let storeSelectionMapHandler = StoreSelectionMapHandler()
    /// 處理定位距離的 handler
    private let locationManagerHandler = LocationManagerHandler()
    /// 用於管理門市訊息展示
    private var floatingPanelController: FloatingPanelController?
    
    // MARK: - Delegate
    
    /// StoreSelectionResultDelegate 用於通知主畫面（OrderCustomerDetailsViewController）選擇店鋪的結果
    weak var delegate: StoreSelectionResultDelegate?
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        view = storeSelectionMapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapInteractionHandler()
        setupLocationManagerHandler()
        fetchAndDisplayStores()
        setupFloatingPanel()
        setupNavigationBar()
    }
    
    // MARK: - Setup Map Interaction

    /// 設置 setupMapInteractionHandler 的代理
    private func setupMapInteractionHandler() {
        storeSelectionMapView.mapView.delegate = storeSelectionMapHandler
        storeSelectionMapHandler.delegate = self
    }
    
    // MARK: - Setup Location Manager
    
    /// 設置 LocationManagerHandler 的代理
    private func setupLocationManagerHandler() {
        locationManagerHandler.delegate = self
        locationManagerHandler.startLocationUpdates()
    }
    
    // MARK: - Setup Floating Panel

    /// 設置浮動面板
    private func setupFloatingPanel() {
        floatingPanelController = FloatingPanelHelper.setupFloatingPanel(for: self)
    }
    
    // MARK: - Setup Navigation Bar

    /// 設置導航欄
    private func setupNavigationBar() {
        self.title = "All Stores"
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        self.navigationItem.leftBarButtonItem = closeButton
        view.backgroundColor = .white
    }
    
    // MARK: - Navigation Actions
    
    // 關閉當前的模態視圖控制器
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Fetch Stores & Add Stores to Map

    /// 從 Firestore 中拉取店鋪資料並顯示在地圖上
    private func fetchAndDisplayStores() {
        Task {
            do {
                stores = try await StoreManager.shared.fetchStores()
                todayOpeningHours = StoreManager.shared.getTodayOpeningHours(for: stores)
                addStoresToMap(stores)
            } catch {
                print("Failed to fetch stores: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: "無法載入店鋪資訊，請稍後再試。", inViewController: self, showCancelButton: false, completion: nil)
            }
        }
    }
    
    /// 在地圖上顯示所有門市
    /// - Parameter stores: 店鋪的陣列
    private func addStoresToMap(_ stores: [Store]) {
        for store in stores {
            let annotation = MKPointAnnotation()
            annotation.title = store.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: store.location.latitude, longitude: store.location.longitude)
            storeSelectionMapView.mapView.addAnnotation(annotation)
        }
    }
    
}

// MARK: - StoreSelectionMapHandlerDelegate
extension StoreSelectionViewController: StoreSelectionMapHandlerDelegate {

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
    
    /// 當地圖上某個店鋪被選取時調用
    ///
    /// - Parameters:
    ///   - store: 被選取的店鋪資料
    ///
    /// ### 功能說明：
    /// - 當使用者在地圖上選擇一個門市時，展示該門市的詳細資訊。
    /// - 設置 `StoreInfoViewController` 為浮動面板的內容控制器，並將 `StoreSelectionResultDelegate` 設置為當前的 `StoreSelectionViewController`。
    func didSelectStore(_ store: Store) {
        let distance = StoreManager.shared.getDistanceToStore(for: store.id)
        let todayHours = todayOpeningHours[store.id] ?? "營業時間未提供"

        if let storeInfoVC = floatingPanelController?.contentViewController as? StoreInfoViewController {
            
            // 設置 StoreSelectionResultDelegate 以便選擇店鋪後通知主畫面（OrderCustomerDetailsViewController）
            storeInfoVC.delegate = self
    
            // 使用 StoreInfoViewController 配置所選門市的詳細資訊
            storeInfoVC.configure(with: store, distance: distance, todayHours: todayHours)
        }
        
        // 自動彈出浮動面板
        floatingPanelController?.move(to: .half, animated: true)
    }
    
    /// 當地圖上某個門市被取消選取時調用
    ///
    /// ### 功能說明：
    /// - 當用戶取消選擇門市標註時，重置浮動面板內容至初始狀態。
    /// - 收起浮動面板並顯示預設的提示資訊。
    func didDeselectStore() {
        // 收起浮動面板到 .tip 狀態
        floatingPanelController?.move(to: .tip, animated: true)
        
        if let storeInfoVC = floatingPanelController?.contentViewController as? StoreInfoViewController {
            storeInfoVC.configureInitialState(with: "請點選門市地圖取得詳細資訊")
        }
    }
    
}

// MARK: - LocationManagerHandlerDelegate
extension StoreSelectionViewController: LocationManagerHandlerDelegate {
    
    /// 當位置更新時調用
    func didUpdateUserLocation(location: CLLocation) {
        StoreManager.shared.updateUserLocationAndCalculateDistances(userLocation: location, stores: stores)
    }
    
    /// 當位置權限被拒絕時調用
    func didReceiveLocationAuthorizationDenied() {
        AlertService.showAlert(withTitle: "位置權限已關閉", message: "請前往設定開啟位置權限，以使用附近店鋪的相關功能。", inViewController: self, showCancelButton: true, completion: nil)
    }
}

// MARK: - StoreSelectionResultDelegate Implementation
extension StoreSelectionViewController: StoreSelectionResultDelegate {
    
    /// 當店鋪選擇完成後調用此方法
    ///
    /// - Parameter storeName: 使用者選擇的店鋪名稱
    ///
    /// ### 功能說明：
    /// - 當使用者在 `StoreInfoViewController` 中選擇並確認某個門市後，此方法將被調用。
    /// - 通過委託 (`delegate?.storeSelectionDidComplete(with: storeName)`)，將選擇的店鋪名稱傳遞給設置該委託的其他控制器（如 `OrderCustomerDetailsViewController`），以確保選擇的結果能夠即時反映到主畫面中。
    func storeSelectionDidComplete(with storeName: String) {
        // 通知主畫面的 OrderCustomerDetailsViewController，將選擇的店鋪名稱回傳
        delegate?.storeSelectionDidComplete(with: storeName)
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Floating Panel Delegate Methods
extension StoreSelectionViewController: FloatingPanelControllerDelegate {
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


