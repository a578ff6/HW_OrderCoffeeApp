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


// MARK: - 取消使用 UIAlertAction 展示「門市資訊」，重構 StoreSelectionView 呈現 「地圖」、「門市資訊」筆記
/**
 
 ## 取消使用 UIAlertAction 展示「門市資訊」，重構 StoreSelectionView 呈現 「地圖」、「門市資訊」筆記
 
 `1. 代理和處理器整理`

    * `LocationManagerHandlerDelegate`：
        - 用於位置更新和授權狀態的通知。

    * `StoreSelectionMapHandlerDelegate`：
        - 用於處理地圖上店鋪大頭針的點擊事件，並通知控制器更新相關的店鋪資訊。
        - 方法` didSelectStore(_ store: Store)` 在用戶選擇地圖上的店鋪時，會通知控制器顯示選中的店鋪詳細資訊。

    * `StoreInfoCollectionViewHandler`：
        - 負責管理 `StoreInfoCollectionView` 的顯示內容，包括選定店鋪的資訊顯示與按鈕的回調。
        - 處理 UICollectionViewDataSource，以集中處理店鋪資料的展示邏輯。
 
 -----
 
 `2. 浮動面板 (FloatingPanel) 的使用`
    
    * `浮動面板設置`：
        - 使用 `FloatingPanelController` 來顯示選定店鋪的詳細資訊，而不是以往的 `UIAlertController`。
        - 浮動面板提供了更豐富和持久的顯示方式，使得用戶可以在選擇地圖上其他店鋪的同時查看已選店鋪的詳細資訊。

    * `顯示店鋪詳細資訊`：
        - 當用戶選中地圖上的店鋪時，通過浮動面板來顯示店鋪的詳細資訊。
        - 使用` floatingPanelController?.move(to: .half, animated: true)` 來自動彈出浮動面板。
 
 -----

 `3. StoreSelectionMapHandler 設計`

    * `單一職責原則`：
        - `StoreSelectionMapHandler` 負責處理地圖上的交互操作，例如用戶點擊某個店鋪的大頭針。
        - 在 `mapView(_:didSelect:)` 方法中，通過 `storeSelectionMapHandlerDelegate` 通知控制器已選擇的店鋪，並將控制更新和顯示交給 `StoreSelectionViewController`。
 
 -----

 `4. StoreSelectionViewController 的職責`

    * `浮動面板控制`：
        - 當地圖上店鋪被選中時，`didSelectStore(_ store: Store)` 方法會設置浮動面板中的 `StoreInfoViewController` 顯示店鋪的詳細資訊。
        - 當店鋪被取消選中時，使用 `floatingPanelController?.move(to: .tip, animated: true)` 將浮動面板收起，並重置 `StoreInfoViewController` 的內容。
    
 -----

 `5. 浮動面板使用的優勢`
    - 與原本使用的` UIAlertController` 相比，`FloatingPanel `提供更好的視覺效果，支持更多操作，不會被用戶誤解為臨時警告，而是更加一致且合適的用戶界面元素。
    - 浮動面板中的內容可以包含更多的詳細資訊，並且能持續顯示，讓用戶在地圖上進行其他操作時，也能持續查看選中店鋪的詳細資料。
 
 -----

 `6. StoreSelectionMapHandlerDelegate 更新`
    
    * `didSelectStore(_ store: Store)`：
        - 當用戶在地圖上點擊店鋪大頭針時，通知控制器更新選中的店鋪資訊，避免使用 UIAlertController 彈出提示。
 
 -----

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
 
 -----

 `&. 大頭針的選取與取消選取事件`

 `1. 地圖上大頭針的選取 (didSelectStore(_:))：`
    - 當用戶在地圖上選取某個店鋪大頭針時，透過 `StoreSelectionMapHandlerDelegate` 通知 `StoreSelectionViewController`。
    - `StoreSelectionViewController` 將呼叫` floatingPanelController?.move(to: .half, animated: true)`，自動將浮動面板從 .tip 展開至 .half，以顯示選定店鋪的詳細信息。
 
 `2. 地圖上大頭針的取消選取 (didDeselectStore())：`
    - 當用戶在地圖上取消選中大頭針（例如點擊地圖空白區域）時，`didDeselectStore()` 方法被調用。
    - `StoreSelectionViewController` 將呼叫` floatingPanelController?.move(to: .tip, animated: true)`，將面板自動收回到 .tip 狀態，顯示最小化的提示訊息。

 -----

 `&. 主要方法和委派模式`
 
 1. `StoreSelectionMapHandlerDelegate`：
    - 使用委派模式 (delegate) 來處理地圖上大頭針的選取和取消選取事件，並與 `StoreSelectionViewController` 進行通信。
    - `didSelectStore(_:)`：當大頭針被選取時調用，用來展開面板並顯示詳細信息。
    - `didDeselectStore()`：當大頭針被取消選取時調用，用來收起面板至 .tip 狀態。
 
 -----

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
 
 -----

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

 -----

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

 -----

 3. `用戶操作流程`
 
    - 用戶進入 `StoreSelectionViewController`，在地圖上查看所有店鋪的位置。
 
    * 用戶點擊某個店鋪的標記後：
      - `StoreSelectionViewController` 中的 FloatingPanel 彈出，並且內容控制器為` StoreInfoViewController`。
      - `StoreInfoViewController` 被配置以顯示選擇店鋪的詳細資訊。
 
    * 用戶點擊 `StoreInfoViewController` 中的「選擇門市」按鈕後，通知` StoreSelectionViewController`，並將該選擇回傳給上層控制器（例如 OrderCustomerDetailsViewController）。

 -----

 4. `關鍵的委託機制`
    
    * `StoreSelectionResultDelegate`：
      - 此委託 (`StoreSelectionResultDelegate`) 被用來通知上層控制器用戶最終的選擇結果。
      - 例如，用戶在 `StoreSelectionViewController` 中選擇了一個店鋪後，會透過這個委託將選擇結果回傳給` OrderCustomerDetailsViewController` 來更新 UI。
 
    - `StoreSelectionMapHandlerDelegate`：
      - 用來管理 `StoreSelectionViewController` 和 `StoreSelectionMapHandler` 的交互，以獲取所有店鋪資訊並處理地圖標記點的選擇和取消選擇。

 -----

 5. `StoreInfoViewController` 如何影響 `StoreSelectionViewController`：
 
    - `StoreInfoViewController` 並不直接與上層控制器（如 `OrderCustomerDetailsViewController`）溝通。
    - 相反，它會將操作結果傳遞給` StoreSelectionViewController`。
    - 在` setupSelectStoreAction `中，當用戶點擊「選擇門市」按鈕時，`StoreInfoViewController` 通知其父控制器` StoreSelectionViewController`，告知用戶已選擇該店鋪。
    - `StoreSelectionViewController `接收到這個通知後，會透過 `StoreSelectionResultDelegate`，將選擇結果傳回給 `OrderCustomerDetailsViewController`，以便更新 `OrderPickupMethodCell` 中的 `storeTextField`。

 ----------------

 `&. 重點理解`

 1. `FloatingPanel 作為橋梁`：
 
    - `FloatingPanel` 是介於主要地圖視圖（`StoreSelectionViewController`）和詳細資訊視圖（`StoreInfoViewController`）之間的橋梁，讓用戶能夠不離開地圖界面就能查看詳細資訊並進行選擇。

 -----

 2. `分層的責任`
 
    - 將詳細店鋪資訊顯示邏輯集中在 `StoreInfoViewController`中，使得 `StoreSelectionViewController` 更簡潔，僅需負責地圖及店鋪選擇邏輯。
    - `StoreSelectionViewController` 負責與上層控制器的溝通（如將選擇結果傳遞給 `OrderCustomerDetailsViewController`），而不是由嵌入的子控制器直接與上層控制器溝通，這樣可以減少子控制器的耦合度。

 -----

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
 
 -----
 
 `2. didSelectStore()` 方法中的代理設置 (`storeInfoVC.storeSelectionResultDelegate = self`)`
 
    - 當用戶在地圖上選擇一個門市時，浮動面板 (`floatingPanel`) 會顯示該門市的詳細資訊。這裡設置 `storeInfoVC.storeSelectionResultDelegate = self` 的目的是讓 `StoreInfoViewController` 能夠將選擇結果通知給 `StoreSelectionViewController`。
 
    - 具體來說，當使用者在 `StoreInfoViewController` 中按下 "選擇門市" 的按鈕時，可以通過此代理將選擇的門市名稱傳回給 `StoreSelectionViewController`，進一步通知主畫面或其他有關的控制器。
  
 -----

 `3. func storeSelectionDidComplete(with storeName: String)`
 
    - 當使用者在 `StoreInfoViewController` 中確認選擇某門市後，會調用 `storeSelectionDidComplete(with:)` 方法來通知委託者（通常是主畫面，如 `OrderCustomerDetailsViewController`）。
    - 這樣可以確保主畫面即時獲得使用者選擇的門市資訊，例如將選定的門市名稱顯示在訂單取件方式的表單中，從而提供更好的使用者體驗和資料一致性。

 -----

 `4. 操作流程概述`
 
    * 在 `StoreSelectionViewController` 中，當使用者點選地圖上的某店鋪標註時：
        - 設置浮動面板的內容控制器 (`StoreInfoViewController`)。
        - 設置 `storeInfoVC.storeSelectionResultDelegate = self`，以便在使用者最終確認門市後，透過 `StoreSelectionResultDelegate` 回傳結果。
        - 浮動面板會展示店鋪詳細資訊，使用者可以選擇該店鋪作為取件門市。
    
    * 在 `StoreInfoViewController` 中，當使用者選擇了某店鋪並確認後：
        - 調用 `delegate?.storeSelectionDidComplete(with: storeName)`，通知 `StoreSelectionViewController` 使用者的選擇。
        - `StoreSelectionViewController` 接收到選擇結果後，進一步將選定的門市名稱傳遞給主畫面的控制器，並關閉門市選擇視圖。
  
 -----

 `5. 設計考量`
 
    * `代理模式的優勢`
        - 代理模式使得 `StoreSelectionViewController` 和 `StoreInfoViewController` 之間保持了低耦合性。
        - 這樣的設計使得 `StoreInfoViewController` 可以靈活地用於其他場景中，只需設置不同的代理即可實現不同的業務邏輯。
    
    * `保持資料同步`
        - 通過 `storeSelectionDidComplete(with:)` 方法，可以確保選擇的店鋪名稱在主畫面中即時更新，減少使用者在不同界面之間切換時的混亂感。
    
    * `更好的用戶體驗`
        - 當使用者選擇店鋪後，立即在主畫面中顯示選擇結果，並且不需要重複導航或手動輸入，這樣的設計大大提升了整體體驗的流暢性。
 */


// MARK: - 定位與店面距離處理
/**
 
 ## 定位與店面距離處理

 `* What`

 - 定位與店面距離處理部分的核心功能：

 1. 用戶定位管理：
 
    - 使用 `LocationManagerHandler` 獲取用戶當前位置，包括檢查授權狀態、請求位置更新，以及處理定位失敗情況。

 2. 距離計算：
 
    - 計算用戶位置與每個店面的距離。
    - 提供距離的格式化結果（例如公里數）供 UI 使用。

 3. 整合與交互：
 
    - 將定位邏輯與店面資料（`Store` 模型）整合，生成與視圖顯示相關的 `StoreInfoViewModel`，以便在浮動面板中顯示距離資訊。

 ---

 `* Why`

 1. 提升用戶體驗：
 
    - 顯示用戶與店面的距離有助於幫助用戶快速篩選和選擇適合的店面，例如最近的店面。

 2. 分離職責：
 
    - `LocationManagerHandler` 專注於處理定位邏輯。
    - 距離計算被封裝在 `Store` 模型的擴展方法中，保持邏輯的高內聚性。
    - 視圖層只需關注距離的顯示格式，而非計算細節。

 3. 靈活與可重用性：
 
    - 定位邏輯與距離計算可重用於其他場景（如外送範圍計算或地圖篩選功能）。
    - 與 `ViewModel` 的結合使顯示邏輯與數據邏輯解耦，方便擴展或修改。

 4. 高可測試性：
 
    - `LocationManagerHandler` 和距離計算方法可以單獨測試，而無需依賴視圖邏輯。

 ---

 `* How`

 `1. 定位管理 - LocationManagerHandler：`

    - 功能：
 
      - 使用 `CLLocationManager` 管理用戶授權和位置更新。
      - 提供當前用戶位置的快取，供距離計算或其他模組訪問。

    - 實作細節：
 
      ```swift
      class LocationManagerHandler: NSObject, CLLocationManagerDelegate {
          private let locationManager = CLLocationManager()
          private(set) var currentUserLocation: CLLocation?

          func startLocationUpdates() {
              switch locationManager.authorizationStatus {
              case .authorizedWhenInUse, .authorizedAlways:
                  locationManager.requestLocation()
              case .notDetermined:
                  locationManager.requestWhenInUseAuthorization()
              case .restricted, .denied:
                  locationManagerHandlerDelegate?.didReceiveLocationAuthorizationDenied()
              default:
                  break
              }
          }

          func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
              guard let location = locations.last else { return }
              currentUserLocation = location
          }

          func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
              locationManagerHandlerDelegate?.didFailToUpdateLocation(with: error)
          }
      }
      ```

 ---

 `2. 距離計算 - Store 模型擴展方法：`

    - 功能：
 
      - 在 `Store` 模型中封裝距離計算邏輯，使用 `CLLocation` 的 `distance(from:)` 方法計算兩點之間的直線距離。
      - 提供清晰的計算 API，方便其他模組使用。

    - 實作細節：
 
      ```swift
      extension Store {
          func distance(from userLocation: CLLocation) -> CLLocationDistance {
              let storeLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
              return userLocation.distance(from: storeLocation)
          }
      }
      ```

 ---

 `3. 視圖整合 - StoreInfoViewModel：`

    - 功能：
 
      - 在 `ViewModel` 中整合距離計算與顯示邏輯，將距離轉換為可讀的格式（如公里）。
      - 將定位與店面資料的結合從視圖層抽離，提升視圖邏輯的簡潔性。

    - 實作細節：
 
      ```swift
      struct StoreInfoViewModel {
          private let store: Store
          private let userLocation: CLLocation?

          var formattedDistance: String {
              guard let location = userLocation else { return "Not available" }
              let distance = store.distance(from: location)
              return String(format: "%.2f km", distance / 1000)
          }
      }
      ```

 ---

 `4. 與 StoreSelectionViewController 集成：`

    - 功能：
 
      - 在 `StoreSelectionViewController` 中調用定位與距離邏輯，將結果顯示在浮動面板中。

    - 集成方式：
 
      ```swift
      func didSelectStore(_ store: Store) {
          guard let storeInfoVC = floatingPanelController?.contentViewController as? StoreInfoViewController else { return }
          
          let userLocation = locationManagerHandler.currentUserLocation
          let viewModel = StoreInfoViewModel(store: store, userLocation: userLocation)
          
          storeInfoVC.setState(.details(viewModel: viewModel))
          floatingPanelController?.move(to: .half, animated: true)
      }
      ```

 ---

 `* 優化效益`

 1. 高內聚性與低耦合性：
 
    - 定位、距離計算、與顯示邏輯各司其職，提升模組間的獨立性。

 2. 靈活性與擴展性：
 
    - 未來可輕鬆擴展定位或距離功能（如支援篩選最近的店面）。

 3. 測試友好性：
 
    - 可針對距離計算、定位授權進行單元測試，確保邏輯正確性。
 */


// MARK: - StoreSelectionViewController 筆記
/**
 
 ## StoreSelectionViewController 筆記

 ---

 * What
 
 - `StoreSelectionViewController` 是一個管理地圖和店鋪互動的視圖控制器，其核心功能包括：

 1. 店鋪資料管理與顯示：
 
    - 從 Firebase 中獲取店鋪資料，並顯示於地圖上，讓用戶可視化門市位置。
 
 2. 浮動面板功能：
 
    - 使用浮動面板展示選定店鋪的詳細資訊，例如距離、營業時間等。
 
 3. 位置管理：
 
    - 管理用戶授權位置權限及更新用戶位置，供距離計算使用。
 
 4. 地圖互動：
 
    - 處理地圖上的點選行為，讓用戶可選擇特定門市並查看其資訊。

 ---

 * Why

 1. 提升用戶體驗：
 
    - 提供地圖視圖及互動式浮動面板，讓用戶快速找到附近店鋪並查看相關資訊。
 
 2. 模組化設計：
 
    - 職責分離（SRP），例如位置管理由 `LocationManagerHandler` 處理，地圖交互由 `StoreSelectionMapHandler` 處理。
 
 3. 可維護性與擴展性：
 
    - 使用清晰的委派模式（`Delegate`）和視圖模型（`ViewModel`）進行數據傳遞與展示，易於調整與新增功能。
 
 4. 適配多場景需求：
 
    - 支援多種操作（選擇門市、查看資訊、取消選擇），同時保持邏輯清晰、易於測試。

 ---

 * How

 1. 店鋪資料顯示：
 
    - 使用 `StoreManager` 從 Firebase 獲取店鋪資料，並解析為 `Store` 模型。
    - 將資料轉換為地圖標註（`MKPointAnnotation`），並添加至地圖視圖。

 2. 浮動面板管理：
 
    - 初始化浮動面板（`FloatingPanelController`），用於顯示店鋪資訊。
    - 點選地圖標註後，更新浮動面板內容並展開。

 3. 位置管理：
 
    - 使用 `LocationManagerHandler` 管理用戶位置：
      - 授權檢查：通知用戶開啟權限。
      - 位置更新：快取當前位置，供距離計算使用。

 4. 地圖交互：
 
    - 使用 `StoreSelectionMapHandler` 處理點選交互，選中或取消選中門市時，分別更新浮動面板內容。

 5. 結構設計：
 
    - 將邏輯模組化：
      - 店鋪資料管理：`StoreManager` 負責數據交互。
      - 地圖互動處理：`StoreSelectionMapHandler` 處理地圖相關操作。
      - 位置管理：`LocationManagerHandler` 提供用戶位置相關數據。
    - 將視圖更新與數據處理分離，例如使用 `StoreInfoViewModel` 處理距離計算和格式化。

 ---

 `* 結構重點`

 1. 位置授權與錯誤處理：
 
    - 當用戶拒絕授權，顯示彈窗通知。
    - 當位置更新失敗，提示檢查網路或定位設定。

 2. 地圖點選與浮動面板：
 
    - 點選地圖標註時，更新浮動面板內容：
      - `使用者當前位置 → 計算距離 → 格式化顯示。`
 
    - 取消選擇時，重置浮動面板至初始狀態。

 3. 地圖數據添加：
 
    - 使用 Firebase 獲取店鋪資料並解析。
    - 將資料轉換為地圖標註，並逐一添加至地圖。

 ---

 `* 優化與設計益處`

 1. 高內聚性：
 
    - 每個模組（如 `StoreManager`、`LocationManagerHandler`）專注於單一職責，降低代碼耦合性。

 2. 易測試性：
 
    - 使用 `Delegate` 傳遞事件，例如位置更新、地圖點選等，便於模擬測試各種場景。

 3. 可擴展性：
 
    - 支援未來新增功能，例如過濾店鋪類型、基於用戶位置排序等。

 4. 用戶體驗友好：
 
    - 浮動面板提供詳細的店鋪資訊，直觀且交互性強。
 */


// MARK: - (v)

import UIKit
import FloatingPanel

/// `StoreSelectionViewController`
///
/// ### 主要功能：
/// - 提供地圖視圖，展示所有店鋪位置，支持用戶點選查看詳細資訊。
/// - 整合地圖互動、位置更新及浮動面板顯示功能。
///
/// ### 功能詳細說明：
/// 1. 店鋪資料管理與顯示
///     - 從 Firebase 拉取店鋪資料，並在地圖上顯示為標註點（`MKPointAnnotation`）。
/// 2. 浮動面板功能
///     - 使用浮動面板展示店鋪的詳細資訊，包括距離、營業時間等，與 `StoreInfoViewController` 交互。
/// 3. 位置管理
///     - 使用 `LocationManagerHandler` 管理用戶位置授權與更新，提供距離計算的基礎數據。
/// 4. 地圖互動
///     - 使用 `StoreSelectionMapHandler` 處理地圖點選行為，與 `StoreSelectionMapHandlerDelegate` 進行通信。
///
/// ### 與其他模組的交互：
/// - `StoreManager`
///     - 從 Firebase 獲取店鋪資料，並解析為 `Store` 模型。
/// - `FloatingPanelController`
///     - 用於展示店鋪的詳細資訊，支持半屏及全屏狀態切換。
/// - `LocationManagerHandler`
///     - 提供用戶當前位置，支持距離計算及授權狀態管理。
/// - `StoreSelectionMapHandler`
///     - 處理地圖點選交互，將用戶操作回傳至控制器。
class StoreSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 顯示店家選擇地圖的主要視圖
    private let storeSelectionView = StoreSelectionView()
    
    /// 所有店鋪資料的陣列
    private var stores: [Store] = []
    
    /// 處理地圖上相關互動的 handler
    private let storeSelectionMapHandler = StoreSelectionMapHandler()
    
    /// 處理定位距離的 handler
    private let locationManagerHandler = LocationManagerHandler()
    
    /// 用於管理門市訊息展示的浮動面板
    private var floatingPanelController: FloatingPanelController?
    
    /// 用於管理導航欄的管理器
    private var storeSelectionNavigationBarManager: StoreSelectionNavigationBarManager?
    
    // MARK: - Delegate
    
    /// 用於通知主畫面（`OrderCustomerDetailsViewController`）選擇店鋪的結果
    weak var storeSelectionResultDelegate: StoreSelectionResultDelegate?
    
    // MARK: - Lifecycle Methods
    
    /// 加載視圖
    override func loadView() {
        view = storeSelectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarManager()
        setupMapInteractionHandler()
        setupLocationManagerHandler()
        fetchAndDisplayStores()
        setupFloatingPanel()
    }
    
    // MARK: - Setup Map Interaction
    
    /// 配置地圖互動處理器
    ///
    /// - 設置地圖視圖的 `delegate` 為 `StoreSelectionMapHandler`。
    /// - 設置 `StoreSelectionMapHandlerDelegate` 為當前 `ViewController`。
    private func setupMapInteractionHandler() {
        storeSelectionView.storeSelectionMapView.delegate = storeSelectionMapHandler
        storeSelectionMapHandler.storeSelectionMapHandlerDelegate = self
    }
    
    // MARK: - Setup Location Manager
    
    /// 配置位置管理器處理器
    ///
    /// 設置位置管理器的代理為當前 ViewController，並啟動位置更新。
    private func setupLocationManagerHandler() {
        locationManagerHandler.locationManagerHandlerDelegate = self
        locationManagerHandler.startLocationUpdates()
    }
    
    // MARK: - Setup Floating Panel
    
    /// 初始化浮動面板
    ///
    /// 使用 `FloatingPanelHelper` 配置浮動面板，用於展示店鋪的詳細資訊。
    private func setupFloatingPanel() {
        floatingPanelController = FloatingPanelHelper.setupFloatingPanel(for: self)
    }
    
    // MARK: - Setup Navigation Bar Manager
    
    /// 配置導航欄
    ///
    /// 使用 `StoreSelectionNavigationBarManager` 設置標題和關閉按鈕。
    private func setupNavigationBarManager() {
        storeSelectionNavigationBarManager = StoreSelectionNavigationBarManager(navigationItem: navigationItem)
        storeSelectionNavigationBarManager?.configureTitle("All Stores")
        storeSelectionNavigationBarManager?.configureCloseButton(target: self, action: #selector(closeButtonTapped))
    }
    
    // MARK: - Navigation Actions
    
    // 關閉當前的模態視圖控制器
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Fetch Stores & Add Stores to Map
    
    /// 從 Firestore 獲取店鋪資料並顯示在地圖上
    ///
    /// 通過 `StoreManager` 拉取店鋪數據，並將店鋪標記添加到地圖上。
    private func fetchAndDisplayStores() {
        Task {
            do {
                stores = try await StoreManager.shared.fetchStores()
                storeSelectionMapHandler.addAnnotations(for: stores, to: storeSelectionView.storeSelectionMapView)
            } catch {
                print("Failed to fetch stores: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: "無法載入店鋪資訊，請稍後再試。", inViewController: self, showCancelButton: false, completion: nil)
            }
        }
    }
    
}

// MARK: - StoreSelectionMapHandlerDelegate
extension StoreSelectionViewController: StoreSelectionMapHandlerDelegate {
    
    /// 獲取所有店鋪資料
    ///
    /// - Returns: 所有店鋪的陣列
    func getStores() -> [Store] {
        return stores
    }
    
    /// 當地圖上某個店鋪被選取時調用
    ///
    /// ### 功能說明：
    /// - 通過 `LocationManagerHandler.currentUserLocation` 獲取用戶最新位置。
    /// - 建立 `StoreInfoViewModel`，包括用戶與店鋪的距離資訊。
    /// - 當使用者在地圖上選擇一個門市時，展示該門市的詳細資訊。
    /// - 設置 `StoreInfoViewController` 為浮動面板的內容控制器，並將 `StoreSelectionResultDelegate` 設置為當前的 `StoreSelectionViewController`。
    ///
    /// - Parameters:
    ///   - store: 被選取的店鋪資料
    func didSelectStore(_ store: Store) {
        guard let storeInfoVC = floatingPanelController?.contentViewController as? StoreInfoViewController else { return }
        
        // 從 LocationManagerHandler 獲取用戶當前位置
        let userLocation = locationManagerHandler.currentUserLocation
        
        // 建立 ViewModel
        let viewModel = StoreInfoViewModel(store: store, userLocation: userLocation)
        
        // 傳遞 ViewModel 到浮動面板
        storeInfoVC.storeSelectionResultDelegate = self
        storeInfoVC.setState(.details(viewModel: viewModel))
        
        // 展開浮動面板
        floatingPanelController?.move(to: .half, animated: true)
    }
    
    /// 當地圖上某個門市被取消選取時調用
    ///
    /// ### 功能說明：
    /// - 當用戶取消選擇門市標註時，重置浮動面板內容至初始狀態。
    /// - 收起浮動面板並顯示預設的提示資訊。
    func didDeselectStore() {
        
        guard let storeInfoVC = floatingPanelController?.contentViewController as? StoreInfoViewController else { return }
        storeInfoVC.setState(.initial(message: "請點選門市地圖取得詳細資訊"))
    
        // 收起浮動面板到 .tip 狀態
        floatingPanelController?.move(to: .tip, animated: true)
    }
    
}

// MARK: - LocationManagerHandlerDelegate
extension StoreSelectionViewController: LocationManagerHandlerDelegate {
    
    /// 當位置權限被拒絕時調用
    ///
    /// ### 功能說明：
    /// 彈出警告提示用戶啟用位置權限。
    func didReceiveLocationAuthorizationDenied() {
        AlertService.showAlert(
            withTitle: "位置權限已關閉",
            message: "請前往設定開啟位置權限，以使用附近店鋪的相關功能。",
            inViewController: self,
            showCancelButton: true,
            completion: nil
        )
    }
    
    /// 當位置更新失敗時調用
    ///
    /// ### 功能說明：
    /// - 提示用戶檢查網路或定位設定。
    func didFailToUpdateLocation(with error: Error) {
        AlertService.showAlert(
            withTitle: "位置獲取失敗",
            message: "無法獲取您的位置，請檢查網路或定位設定。\n錯誤：\(error.localizedDescription)",
            inViewController: self,
            showCancelButton: false,
            completion: nil
        )
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
    /// - 通過委託，將選擇的店鋪名稱傳遞給設置該委託的其他控制器（ `OrderCustomerDetailsViewController`），以確保選擇的結果能夠即時反映到主畫面中。
    func storeSelectionDidComplete(with storeName: String) {
        
        // 通知主畫面的 OrderCustomerDetailsViewController，將選擇的店鋪名稱回傳
        storeSelectionResultDelegate?.storeSelectionDidComplete(with: storeName)
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Floating Panel Delegate Methods
extension StoreSelectionViewController: FloatingPanelControllerDelegate {
}
