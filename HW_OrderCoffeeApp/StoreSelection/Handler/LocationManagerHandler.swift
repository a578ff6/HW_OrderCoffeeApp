//
//  LocationManagerHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/27.
//

// MARK: -  LocationManagerHandler 重點筆記
/*
 ## LocationManagerHandler 重點筆記
 
 1. 類別簡介：
    - LocationManagerHandler 用於管理用戶的「位置更新」及「授權處理」，將位置的管理邏輯與其他應用邏輯分離。

 2. 屬性：

    * locationManager：
        - 用途：CLLocationManager 實例，用來管理和獲取用戶的地理位置信息。
 
    * delegate：
        - 用途：LocationManagerHandlerDelegate 的弱引用，用於通知代理位置的更新或授權的結果。這樣設計避免循環引用。
 
 3. 初始化：

    * 設置代理和精度：
        - 在 init() 方法中，將 locationManager 的代理設為當前類別 (self)，並設置 desiredAccuracy 為 kCLLocationAccuracyNearestTenMeters，表示希望獲取十米以內的精度。
        - 設置 activityType 為 .other，這表示定位的用途與一般使用情況不同，例如不是專門用於步行、駕駛等情境。
 
 4. Public 方法：

    * startLocationUpdates()：
        - 用途：檢查位置授權狀態並啟動位置更新。
        - 授權狀態的處理：
            - .notDetermined：如果未決定，請求用戶授權使用位置。
            - .restricted 或 .denied：通知代理授權被拒絕或受限。
            - .authorizedWhenInUse 或 .authorizedAlways：如果已授權，請求一次位置（requestLocation()），然後開始位置更新（startUpdatingLocation()），以便追蹤使用者的位置變化。
 
 5. CLLocationManagerDelegate 擴展：

    * locationManager(_:didUpdateLocations:)：
        - 用途：當位置更新時，調用此方法，並將最新的位置通過代理 (delegate) 傳遞給使用者。
 
    * locationManager(_:didChangeAuthorization:)：
        - 用途：當位置授權狀態發生變化時調用。
        - 處理授權狀態：
            - 當授權授予 (authorizedWhenInUse 或 authorizedAlways) 時，請求一次位置（requestLocation()），並開始位置更新（startUpdatingLocation()）。
            - 當授權受限或拒絕 (restricted 或 denied) 時，通知代理顯示提示訊息。
 
 6. 授權狀態處理：

    * Info.plist：
       - 在 Info.plist 中必須添加 `NSLocationWhenInUseUsageDescription` 或 `NSLocationAlwaysUsageDescription`，描述 App 為什麼需要定位資訊。

    * 授權請求：
       - 在 startLocationUpdates() 方法中，使用 locationManager.requestWhenInUseAuthorization() 請求授權，讓 App 能夠使用用戶的位置資訊。

    * 授權狀態變更：
       - 使用 locationManagerDidChangeAuthorization(_:) 方法監聽位置授權的變化。
       - 根據使用者選擇，決定是否開始位置更新或通知代理進行進一步的提示。
 
 6. 設計優勢：
    - 清晰的責任劃分：此類別的設計使得「位置管理邏輯」集中在一起，並通過代理通知授權狀態和位置變化。這樣可以將複雜的定位處理從視圖控制器中分離出來，使視圖控制器更加專注於 UI 和用戶交互。
    - 可重用性：通過代理 (delegate) 的設計，不僅可以使 StoreSelectionViewController 使用此類別，應用中的其他需要定位功能的模組也可以輕鬆使用。
    - 授權管理：通過單一類別來處理授權的請求和狀態變更，能夠更好地確保應用的定位行為符合系統的隱私要求。
 */


// MARK: - 設置 desiredAccuracy 的重點筆記

/*
 ## 設置 desiredAccuracy 的重點筆記
 
 1. 功能說明
    - desiredAccuracy 屬性用於控制 CLLocationManager 提供的位置精度要求。
    - 設置該屬性可以影響應用的定位精度、獲取位置的速度，以及電池的消耗程度。
 
 2. 使用情境
    - 根據應用場景的需求來設置不同的精度要求。
    - 如果應用需要高精度的位置（例如導航），可以選擇最高精度 kCLLocationAccuracyBest。
    - 如果僅需大概的使用者位置（例如找出附近的店鋪），可選擇 kCLLocationAccuracyNearestTenMeters 或 kCLLocationAccuracyHundredMeters，這樣能有效降低電池消耗。
 
 3. 精度設置的影響

    * 高精度 (kCLLocationAccuracyBest)：
        - 適用於需要精確到幾米內的應用場景，例如步行導航。
        - 提供高精度的位置資訊，但會耗費較多的電量。

    * 較低精度 (kCLLocationAccuracyNearestTenMeters 或 kCLLocationAccuracyHundredMeters)：
        - 適合對精度要求不高的應用，例如顯示附近的店鋪或大概位置。
        - 減少電池消耗，尤其是在需要長時間持續定位的情況下。

 4. 設置的建議
    - 對於顯示店鋪距離的應用，不需要最高精度，使用 kCLLocationAccuracyNearestTenMeters 就能滿足需求，並且能有效節省電池。
    - 需根據應用的實際需求選擇合適的精度，以平衡精確度和能源消耗。
 */

// MARK: - 加入 distanceFilter 的考量點（先不設置）

/*
 ##  加入 distanceFilter 的考量點
 
 * 在設置「篩選距離範圍內的店鋪」時考量到性能。
    - 設定一個最小的距離變化閾值 (distanceFilter)，只有當位置變化超過這個閾值時，才更新最近的店鋪。

 1. 性能考量：
    - 如果 App 場景中使用者會頻繁地移動（例如騎車或開車），且地圖上的標註更新非常頻繁，那麼加入 distanceFilter 可以有效減少位置更新的次數，進而提高應用的性能，減少電量消耗。
    - 通常，distanceFilter 可以設定為 50 到 100 米之間，這樣只有在使用者移動超過一定距離時，才進行地圖標註的更新，從而減少不必要的計算和地圖刷新。
 
 2. 用戶體驗：
    - 如果使用者的移動速度比較慢，例如步行或是在店內移動，那麼即時更新位置並不會對性能造成太大壓力，這樣可以保持地圖上標註的準確性。
    - 但如果更新過於頻繁（例如每幾米就更新一次），這可能會干擾用戶體驗，因為不斷的地圖改變可能會讓用戶感到困惑或不安。
 
 3. 場景需求：
    - 如果場景是比較精確的位置需求，例如導航或即時位置追蹤，那麼可以保持較小的 distanceFilter 甚至不設置。
    - 但如果只是需要大概知道使用者的位置和附近的店鋪，不需要過於精確，那麼設置 distanceFilter 可以有效避免不必要的更新和地圖刷新。
 
 4. 總結
    - 加入 distanceFilter 的好處：減少頻繁的更新，提升性能，節省電量，改善使用者體驗。
    - 可能的缺點：如果 distanceFilter 設得過大，可能會導致位置更新不及時，尤其是使用者在步行或緩慢移動時，地圖上店鋪的標註更新不夠精確。
 */

// MARK: - 位置管理器設定及距離過濾應用重點筆記（可選的考慮方向）

/*
 ## 位置管理器設定及距離過濾應用重點筆記

 1. 初始位置獲取：
    - 在 App 啟動時，一般會立即啟動位置管理器來獲取用戶的當前位置，以確保用戶能夠立刻看到與他們當前位置相關的內容，例如附近的店鋪或服務。
    - 可以使用 startUpdatingLocation() 或 requestLocation() 來強制更新一次位置。
    - 初始位置的精度可以設置為較高（如 kCLLocationAccuracyBest）以快速獲取精確的位置。
 
 2. 設置 distanceFilter（重要）：
    - distanceFilter 用來控制位置更新的頻率，以減少不必要的更新，降低電池消耗。
 
    * 常見設置方式：
        - 初次位置獲取後調整 distanceFilter：
            - 在首次獲取到用戶的位置後，可以設置 distanceFilter（如 50 米），這樣可確保用戶初次打開應用時能立刻獲得位置，隨後的更新則根據移動距離來進行。
            - 這種做法可以達到位置更新與性能之間的平衡。
 
    * 直接設置 distanceFilter：
        - 在啟動位置更新前就設置 distanceFilter（如 50 米或 100 米），這樣應用只在用戶移動超過設定的閾值時更新位置，以達到節省功耗的目的。
        - 這樣的設置可能導致初次進入應用時無法立刻更新位置，需等待用戶移動達到設定閾值。（問題的發生！！）
 
 3. 典型使用場景建議：
 
    * 高精度即時應用（如導航）：
        - 初次啟動並持續高精度更新，可能不設 distanceFilter，以確保即時獲取用戶位置，但會增加電池消耗。
 
    * 附近店鋪或服務查找應用：
        - 初次啟動時獲取當前位置，然後設置 distanceFilter 以減少隨後的頻繁更新，節省電池，同時仍能根據用戶的實際移動調整顯示的店鋪信息。

 4. 建議的實現方式：
    - 先獲取初始位置：啟動位置管理器，使用高精度來獲取用戶當前位置，確保初次進入應用時能立即顯示相關內容。
    - 再設置 distanceFilter：在獲取初次位置後，設置適當的 distanceFilter，如 50 米，以減少不必要的頻繁更新，平衡應用的性能與電池消耗。
    - 根據應用需求靈活調整：根據應用的具體場景，對精度和 distanceFilter 的設置進行調整，以提供最佳的用戶體驗和性能。
 */

// MARK: - 是否需要設置 activityType

/*
 ## 是否需要設置 activityType
 
    * activityType 是 CLLocationManager 的屬性，用於告訴系統應用程序的定位活動類型，以便系統可以優化位置更新的頻率和精度，從而節省電量。

 1. 根據應用的用途來看，activityType 可以選擇以下幾種：
    - .automotiveNavigation：適合導航類應用，定位精度較高，適用於駕車的場景。
    - .fitness：適合需要跟蹤用戶健身活動的應用，比如跑步、步行等，定位會更頻繁。
    - .other：這是一個通用選項，適用於沒有明確活動類型的應用。
    - .otherNavigation：適合通用的導航應用，但不一定是在開車。
 
 2. 因為場景是要根據用戶的當前位置來篩選附近的店鋪，因此可以設置 activityType 為 .other 或 .otherNavigation，這樣可以達到合理的定位更新頻率，而不會過於頻繁影響電量。
 */

// MARK: - 是否需要設置 requestLocation

/*
 ## 是否需要設置 requestLocation

 - requestLocation() 用於請求一次性的位置更新，非常適合初次需要定位的情況的方法。當希望獲取用戶的當前位置但不需要持續追蹤時，這個方法可以發揮作用。
 - 在 App 場景下，如果想在 App 啟動後立即獲取一次當前位置（而不僅僅依賴 startUpdatingLocation() 的初始觸發），可以考慮在初次授權成功後調用 requestLocation()，這樣可以保證初次能快速獲取位置。
 
 * 這樣做的好處是：
    - 保證初次位置獲取的即時性：requestLocation() 保證了可以馬上獲取一次位置，而不需要等待位置更新的觸發。
    - 之後的持續更新：設置 startUpdatingLocation() 來持續追蹤用戶位置，保持店鋪篩選結果的更新。
 */

import UIKit
import CoreLocation

/// LocationManagerHandler 負責處理用戶位置的管理，包括`位置授權的檢查`和`位置更新的通知`
class LocationManagerHandler: NSObject {
    
    // MARK: - Properties

    /// 位置管理器，用於管理和獲取用戶的地理位置
    private let locationManager = CLLocationManager()
    /// 代理，用於通知授權和位置更新的結果
    weak var delegate: LocationManagerHandlerDelegate?
    
    // MARK: - Initialization

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .other
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters   // 設置定位精度，這裡為最近十米
    }
    
    // MARK: - Public Methods

    /// 開始位置更新的管理流程
    func startLocationUpdates() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            delegate?.didReceiveLocationAuthorizationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()            // 初次獲取一次位置
            locationManager.startUpdatingLocation()      // 然後開始位置更新以追蹤用戶位置
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManagerHandler: CLLocationManagerDelegate {
    
    /// 當位置更新時被調用，通知代理位置已更新
    /// - Parameters:
    ///   - manager: 位置管理器 (`CLLocationManager`) 的實例
    ///   - locations: 更新的位置陣列，包含最新的用戶位置信息
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            delegate?.didUpdateUserLocation(location: location)
        }
    }
    
    /// 當位置授權狀態發生變化時調用
    /// - Parameters:
    ///   - manager: 位置管理器 (`CLLocationManager`) 的實例
    ///   - status: 更新後的位置授權狀態
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // 授權變更後請求一次當前位置，並開始位置更新
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        } else if status == .restricted || status == .denied {
            delegate?.didReceiveLocationAuthorizationDenied()
        }
    }
    
    /// 當位置獲取失敗時被調用
    /// - Parameters:
    ///   - manager: 位置管理器 (`CLLocationManager`) 的實例
    ///   - error: 獲取位置時遇到的錯誤
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("獲取位置失敗: \(error.localizedDescription)")
    }
    
}
