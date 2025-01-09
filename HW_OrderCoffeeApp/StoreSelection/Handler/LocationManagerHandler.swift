//
//  LocationManagerHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/27.
//

// MARK: - LocationManagerHandler 筆記
/**
 
 ## LocationManagerHandler 筆記

 `* What`

 - `LocationManagerHandler` 是一個專用於管理用戶地理位置的工具類，提供了以下功能：
 
   1. 位置授權檢查：檢查和處理應用的地理位置授權狀態。
   2. 位置更新：使用 `CLLocationManager` 實時更新用戶位置。
   3. 結果通知：通過代理通知授權狀態和位置更新的結果給控制器。
   4. 快取位置：保存當前位置，供其他模組使用。

 ------------

 `* Why`

 1. 集中管理位置邏輯：
 
    - 將與位置相關的功能（如授權檢查、位置更新）集中到一個單一的工具類中，方便維護。

 2. 解耦業務邏輯與 UI：
 
    - 位置邏輯由 `LocationManagerHandler` 處理，具體的提示或錯誤處理通過代理交給控制器實現，實現高內聚、低耦合。

 3. 提升可讀性與重用性：
 
    - `LocationManagerHandler` 可以在多個控制器中使用，不需要重複實現位置管理邏輯。

 4. 適應多種場景：
 
    - 支援位置導航、地圖標記和距離計算等功能，為應用的地理位置需求提供統一解決方案。

 ------------

 `* How`

 1. 初始化與配置：
 
    - 在初始化方法中設置 `CLLocationManager` 的代理及所需的準確度和活動類型。
        - 將 locationManager 的代理設為當前類別 (self)，並設置 `desiredAccuracy` 為 `kCLLocationAccuracyNearestTenMeters`，表示希望獲取十米以內的精度。
        - 設置 `activityType` 為 `.other`，這表示定位的用途與一般使用情況不同，例如不是專門用於步行、駕駛等情境。
 
 
 2. 處理授權邏輯：
 
    - 在 `startLocationUpdates` 中根據授權狀態執行不同邏輯，包括請求授權、通知授權被拒絕或開始位置更新。
 
    - 用途：檢查位置授權狀態並啟動位置更新。
        - 授權狀態的處理：
            - .notDetermined：如果未決定，請求用戶授權使用位置。
            - .restricted 或 .denied：通知代理授權被拒絕或受限。
            - .authorizedWhenInUse 或 .authorizedAlways：如果已授權，請求一次位置（requestLocation()），然後開始位置更新（startUpdatingLocation()），以便追蹤使用者的位置變化。
 
 3. 代理回調：
 
    - 通過 `CLLocationManagerDelegate` 處理授權變化和位置更新，並將結果通知代理（`LocationManagerHandlerDelegate`）。

    - `locationManager(_:didUpdateLocations:)`：
        - 用途：當位置更新時，調用此方法，並將最新的位置通過代理 (delegate) 傳遞給使用者。
 
    - `locationManagerDidChangeAuthorization(_ manager: CLLocationManager)`：
        - 用途：當位置授權狀態發生變化時調用。
        - 處理授權狀態：
            - 當授權授予 (`authorizedWhenInUse` 或 `authorizedAlways`) 時，請求一次位置（`requestLocation()`），並開始位置更新（`startUpdatingLocation()`）。
            - 當授權受限或拒絕 (`restricted` 或 `denied`) 時，通知代理顯示提示訊息。
 
 4. 保存位置快取：
 
    - 在 `didUpdateLocations` 方法中更新 `currentUserLocation`，以便其他模組訪問用戶當前的位置。
 
 5.授權狀態處理：

    - Info.plist：
       - 在 Info.plist 中必須添加 `NSLocationWhenInUseUsageDescription` 或 `NSLocationAlwaysUsageDescription`，描述 App 為什麼需要定位資訊。

    - 授權請求：
       - 在 `startLocationUpdates() `方法中，使用` locationManager.requestWhenInUseAuthorization() `請求授權，讓 App 能夠使用用戶的位置資訊。

    - 授權狀態變更：
       - 使用 `locationManagerDidChangeAuthorization(_:) `方法監聽位置授權的變化。
       - 根據使用者選擇，決定是否開始位置更新或通知代理進行進一步的提示。

 ------------

 `* Code Implementation Summary`

 `1.LocationManagerHandler 核心程式碼`

 ```swift
 // MARK: - Public Methods

 /// 開始位置更新的管理流程
 func startLocationUpdates() {
     switch locationManager.authorizationStatus {
     case .notDetermined:
         locationManager.requestWhenInUseAuthorization()
     case .restricted, .denied:
         locationManagerHandlerDelegate?.didReceiveLocationAuthorizationDenied()
     case .authorizedWhenInUse, .authorizedAlways:
         locationManager.requestLocation()            // 初次獲取一次位置
         locationManager.startUpdatingLocation()      // 然後開始位置更新以追蹤用戶位置
     @unknown default:
         break
     }
 }

 // MARK: - CLLocationManagerDelegate

 /// 當位置更新時被調用
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     guard let loaction = locations.last else { return }
     currentUserLocation = loaction
 }
 
 /// 當位置授權狀態發生變化時調用
 func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
     switch manager.authorizationStatus {
     case .authorizedWhenInUse, .authorizedAlways:
         // 授權變更後請求一次當前位置，並開始位置更新
         locationManager.requestLocation()
         locationManager.startUpdatingLocation()
     case .restricted, .denied:
         locationManagerHandlerDelegate?.didReceiveLocationAuthorizationDenied()
     case .notDetermined:
         break
     @unknown default:
         break
     }
 }
 
 /// 當位置獲取失敗時被調用
 func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print("獲取位置失敗: \(error.localizedDescription)")
     locationManagerHandlerDelegate?.didFailToUpdateLocation(with: error)
 }
 ```

 ----
 
 `2.StoreSelectionViewController 使用範例`

 ```swift
 // MARK: - LocationManagerHandlerDelegate
 extension StoreSelectionViewController: LocationManagerHandlerDelegate {
     
     /// 當位置權限被拒絕時調用
     func didReceiveLocationAuthorizationDenied() {
         AlertService.showAlert(
             withTitle: "位置權限已關閉",
             message: "請前往設定開啟位置權限，以使用附近店鋪的相關功能。",
             inViewController: self,
             showCancelButton: true,
             completion: nil
         )
     }
     
     /// 當位置獲取失敗時調用
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
 ```

 ------------

 `* 優化與設計益處`

 1. 高內聚、低耦合：
 
    - 位置邏輯和 UI 行為完全分離，易於擴展和測試。

 2. 提升易用性：
 
    - 快取位置 (`currentUserLocation`) 方便其他模組直接訪問，簡化用戶位置的重用。

 3. 一致性與可維護性：
 
    - 集中處理授權和位置更新的邏輯，結構清晰，代碼易於理解和修改。

 4. 可擴展性：
 
    - 未來如需新增邏輯（如高精度定位或地理圍欄），可直接在 `LocationManagerHandler` 中擴展，對現有邏輯影響最小。
 
 */


// MARK: - 設置 desiredAccuracy 的重點筆記
/**
 
 ## 設置 desiredAccuracy 的重點筆記
 
 `1. 功能說明`
 
    - desiredAccuracy 屬性用於控制 CLLocationManager 提供的位置精度要求。
    - 設置該屬性可以影響應用的定位精度、獲取位置的速度，以及電池的消耗程度。
 
 `2. 使用情境`
 
    - 根據應用場景的需求來設置不同的精度要求。
    - 如果應用需要高精度的位置（例如導航），可以選擇最高精度 kCLLocationAccuracyBest。
    - 如果僅需大概的使用者位置（例如找出附近的店鋪），可選擇 kCLLocationAccuracyNearestTenMeters 或 kCLLocationAccuracyHundredMeters，這樣能有效降低電池消耗。
 
 `3. 精度設置的影響`

    * 高精度 (kCLLocationAccuracyBest)：
        - 適用於需要精確到幾米內的應用場景，例如步行導航。
        - 提供高精度的位置資訊，但會耗費較多的電量。

    * 較低精度 (kCLLocationAccuracyNearestTenMeters 或 kCLLocationAccuracyHundredMeters)：
        - 適合對精度要求不高的應用，例如顯示附近的店鋪或大概位置。
        - 減少電池消耗，尤其是在需要長時間持續定位的情況下。

 `4. 設置的建議`
 
    - 對於顯示店鋪距離的應用，不需要最高精度，使用 kCLLocationAccuracyNearestTenMeters 就能滿足需求，並且能有效節省電池。
    - 需根據應用的實際需求選擇合適的精度，以平衡精確度和能源消耗。
 */


// MARK: - 加入 distanceFilter 的考量點（先不設置）
/**
 
 ##  加入 distanceFilter 的考量點
 
 * 在設置「篩選距離範圍內的店鋪」時考量到性能。
    - 設定一個最小的距離變化閾值 (distanceFilter)，只有當位置變化超過這個閾值時，才更新最近的店鋪。

 `1. 性能考量：`
 
    - 如果 App 場景中使用者會頻繁地移動（例如騎車或開車），且地圖上的標註更新非常頻繁，那麼加入 distanceFilter 可以有效減少位置更新的次數，進而提高應用的性能，減少電量消耗。
    - 通常，distanceFilter 可以設定為 50 到 100 米之間，這樣只有在使用者移動超過一定距離時，才進行地圖標註的更新，從而減少不必要的計算和地圖刷新。
 
 `2. 用戶體驗：`
 
    - 如果使用者的移動速度比較慢，例如步行或是在店內移動，那麼即時更新位置並不會對性能造成太大壓力，這樣可以保持地圖上標註的準確性。
    - 但如果更新過於頻繁（例如每幾米就更新一次），這可能會干擾用戶體驗，因為不斷的地圖改變可能會讓用戶感到困惑或不安。
 
 `3. 場景需求：`
 
    - 如果場景是比較精確的位置需求，例如導航或即時位置追蹤，那麼可以保持較小的 distanceFilter 甚至不設置。
    - 但如果只是需要大概知道使用者的位置和附近的店鋪，不需要過於精確，那麼設置 distanceFilter 可以有效避免不必要的更新和地圖刷新。
 
 `4. 總結`
 
    - 加入 distanceFilter 的好處：減少頻繁的更新，提升性能，節省電量，改善使用者體驗。
    - 可能的缺點：如果 distanceFilter 設得過大，可能會導致位置更新不及時，尤其是使用者在步行或緩慢移動時，地圖上店鋪的標註更新不夠精確。
 */


// MARK: - 位置管理器設定及距離過濾應用重點筆記（可選的考慮方向）
/**
 
 ## 位置管理器設定及距離過濾應用重點筆記

 `1. 初始位置獲取：`
 
    - 在 App 啟動時，一般會立即啟動位置管理器來獲取用戶的當前位置，以確保用戶能夠立刻看到與他們當前位置相關的內容，例如附近的店鋪或服務。
    - 可以使用 startUpdatingLocation() 或 requestLocation() 來強制更新一次位置。
    - 初始位置的精度可以設置為較高（如 kCLLocationAccuracyBest）以快速獲取精確的位置。
 
 `2. 設置 distanceFilter（重要）：`
 
    - distanceFilter 用來控制位置更新的頻率，以減少不必要的更新，降低電池消耗。
 
    * 常見設置方式：
        - 初次位置獲取後調整 distanceFilter：
            - 在首次獲取到用戶的位置後，可以設置 distanceFilter（如 50 米），這樣可確保用戶初次打開應用時能立刻獲得位置，隨後的更新則根據移動距離來進行。
            - 這種做法可以達到位置更新與性能之間的平衡。
 
    * 直接設置 distanceFilter：
        - 在啟動位置更新前就設置 distanceFilter（如 50 米或 100 米），這樣應用只在用戶移動超過設定的閾值時更新位置，以達到節省功耗的目的。
        - 這樣的設置可能導致初次進入應用時無法立刻更新位置，需等待用戶移動達到設定閾值。（問題的發生！！）
 
 `3. 典型使用場景建議：`
 
    * 高精度即時應用（如導航）：
        - 初次啟動並持續高精度更新，可能不設 distanceFilter，以確保即時獲取用戶位置，但會增加電池消耗。
 
    * 附近店鋪或服務查找應用：
        - 初次啟動時獲取當前位置，然後設置 distanceFilter 以減少隨後的頻繁更新，節省電池，同時仍能根據用戶的實際移動調整顯示的店鋪信息。

 `4. 建議的實現方式：`
 
    - 先獲取初始位置：啟動位置管理器，使用高精度來獲取用戶當前位置，確保初次進入應用時能立即顯示相關內容。
    - 再設置 distanceFilter：在獲取初次位置後，設置適當的 distanceFilter，如 50 米，以減少不必要的頻繁更新，平衡應用的性能與電池消耗。
    - 根據應用需求靈活調整：根據應用的具體場景，對精度和 distanceFilter 的設置進行調整，以提供最佳的用戶體驗和性能。
 */


// MARK: - 是否需要設置 activityType
/**
 
 ## 是否需要設置 activityType
 
    * `activityType` 是 `CLLocationManager` 的屬性，用於告訴系統應用程序的定位活動類型，以便系統可以優化位置更新的頻率和精度，從而節省電量。

 1. 根據應用的用途來看，activityType 可以選擇以下幾種：
 
    - .automotiveNavigation：適合導航類應用，定位精度較高，適用於駕車的場景。
    - .fitness：適合需要跟蹤用戶健身活動的應用，比如跑步、步行等，定位會更頻繁。
    - .other：這是一個通用選項，適用於沒有明確活動類型的應用。
    - .otherNavigation：適合通用的導航應用，但不一定是在開車。
 
 2. 因為場景是要根據用戶的當前位置來篩選附近的店鋪，因此可以設置 activityType 為 .other 或 .otherNavigation，這樣可以達到合理的定位更新頻率，而不會過於頻繁影響電量。
 
 */


// MARK: - 是否需要設置 requestLocation
/**
 
 ## 是否需要設置 requestLocation

 - `requestLocation() `用於請求一次性的位置更新，非常適合初次需要定位的情況的方法。當希望獲取用戶的當前位置但不需要持續追蹤時，這個方法可以發揮作用。
 - 在 App 場景下，如果想在 App 啟動後立即獲取一次當前位置（`而不僅僅依賴 startUpdatingLocation() 的初始觸發`），可以考慮在初次授權成功後調用 `requestLocation()`，這樣可以保證初次能快速獲取位置。
 
 * 這樣做的好處是：
 
    - `保證初次位置獲取的即時性`：`requestLocation() `保證了可以馬上獲取一次位置，而不需要等待位置更新的觸發。
    - `之後的持續更新：`設置 `startUpdatingLocation()` 來持續追蹤用戶位置，保持店鋪篩選結果的更新。
 
 */


// MARK: - LocationManagerHandler 授權變化方法的選擇
/**
 
 ## LocationManagerHandler 授權變化方法的選擇

 ---

 * What

 `CLLocationManager` 提供了兩種方法來處理位置授權狀態的變化：
 
 1. `locationManagerDidChangeAuthorization(_:)`：
    - iOS 14 引入的新方法，適用於所有授權狀態變化。
    - 使用 `authorizationStatus` 來獲取最新的授權狀態。
 
 2. `didChangeAuthorization(_:status:)`：
    - iOS 13 及更早版本的回調方法。
    - 需要檢查傳遞的 `CLAuthorizationStatus` 參數。

 這兩個方法都可用於監控用戶位置授權的變化，但需要根據應用的最低支援版本選擇適合的方案。

 ---

 * Why

 1. 支持 iOS 14 的最佳實踐：
 
    - 自 iOS 14 起，`locationManagerDidChangeAuthorization(_:)` 是官方推薦的方法，能更好地處理新授權 API。

 2. 兼容舊版 iOS：
 
    - 如果應用需要支持 iOS 13 或更低版本，仍需保留 `didChangeAuthorization(_:status:)`。

 3. 統一授權邏輯：
 
    - 將授權變化的處理封裝在方法內，可減少代碼重複，提升代碼可讀性和維護性。

 4. 未來擴展性：
 
    - 使用新方法能適應未來的 API 變化，避免因系統更新而帶來的不兼容問題。

 ---

 * How

 1. 單純支持 iOS 14 及更高版本：
 
    - 如果最低支援版本為 iOS 14，可以完全切換到 `locationManagerDidChangeAuthorization(_:)`。

 2. 向後兼容 iOS 13 或更低版本：
 
    - 同時實現兩個方法（`locationManagerDidChangeAuthorization` 和 `didChangeAuthorization`），保證不同系統版本的行為一致。

 3. 共用授權邏輯：
 
    - 將授權邏輯封裝成私有方法，兩個回調共用處理邏輯，避免重複代碼。

 4. 示例：

 以下代碼展示如何同時支持舊版和新版授權方法：

 ```swift
 extension LocationManagerHandler: CLLocationManagerDelegate {
     
     // iOS 14+ 的授權變化回調
     func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
         handleAuthorizationChange(status: manager.authorizationStatus)
     }
     
     // iOS 13 及以下的授權變化回調
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         handleAuthorizationChange(status: status)
     }
     
     // 封裝授權變化邏輯
     private func handleAuthorizationChange(status: CLAuthorizationStatus) {
         switch status {
         case .authorizedWhenInUse, .authorizedAlways:
             locationManager.requestLocation()
             locationManager.startUpdatingLocation()
         case .restricted, .denied:
             locationManagerHandlerDelegate?.didReceiveLocationAuthorizationDenied()
         case .notDetermined:
             break
         @unknown default:
             break
         }
     }
 }
 ```

 ---

 * 優化與設計益處

 1. 一致性與可維護性：
 
    - 授權處理邏輯集中管理，兩個方法共用同一處理函數，減少冗餘。

 2. 高內聚、低耦合：
 
    - 邏輯封裝在 `LocationManagerHandler`，而具體的提示行為交由代理處理，提升模組化設計。

 3. 靈活性：
    - 無論用戶使用的是舊版還是新版 iOS，都能正確處理授權變化，適應更多場景需求。

 4. 可擴展性：
    - 新增行為（如記錄日誌或觸發分析事件）時，只需在 `handleAuthorizationChange` 方法中進行調整即可。
 */


// MARK: - (v)

import UIKit
import CoreLocation

/// `LocationManagerHandler` 用於處理用戶位置的管理
///
/// ### 核心功能：
/// - 負責檢查並處理位置授權狀態。
/// - 管理用戶位置的更新，並將結果通知代理。
/// - 提供當前用戶位置的快取，方便其他模組訪問。
///
/// ### 適用場景：
/// - 當應用需要使用用戶的地理位置，例如地圖導航或距離計算時。
///
/// ### 特性：
/// - 使用 `CLLocationManager` 進行位置管理。
/// - 採用代理模式，將授權和位置更新事件回傳至實現 `LocationManagerHandlerDelegate` 的對象。
class LocationManagerHandler: NSObject {
    
    // MARK: - Properties
    
    /// 位置管理器，用於管理和獲取用戶的地理位置
    private let locationManager = CLLocationManager()
    
    /// 當前用戶的位置（快取）
    private(set) var currentUserLocation: CLLocation?
    
    /// 代理，用於通知授權和位置更新的結果
    weak var locationManagerHandlerDelegate: LocationManagerHandlerDelegate?
    
    // MARK: - Initialization
    
    /// 初始化方法，設置 `CLLocationManager` 的代理和相關配置
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .other
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters   // 設置定位精度，這裡為最近十米
    }
    
    // MARK: - Public Methods
    
    /// 開始位置更新的管理流程
    ///
    /// - 根據授權狀態執行相應邏輯：
    ///   - 若授權未決，請求使用者授權。
    ///   - 若授權被拒絕或受限，通知代理進行提示。
    ///   - 若授權已授予，請求位置並開始位置追蹤。
    func startLocationUpdates() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationManagerHandlerDelegate?.didReceiveLocationAuthorizationDenied()
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
    
    /// 當位置更新時被調用
    ///
    /// ### 功能：
    /// - 實時更新 `currentUserLocation`，供其他模組訪問。
    ///
    /// ### 注意：
    /// - 該方法間接為 `StoreSelectionViewController` 的 `didSelectStore` 提供用戶位置數據。
    ///
    /// - Parameters:
    ///   - manager: 位置管理器 (`CLLocationManager`) 的實例
    ///   - locations: 更新的位置陣列，包含最新的用戶位置信息
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loaction = locations.last else { return }
        
        // 更新快取
        currentUserLocation = loaction
    }
    
    /// 當位置授權狀態發生變化時調用 (適用於 iOS 14+)
    ///
    /// ### 功能：
    /// - 實時檢查用戶的授權狀態，並執行相應邏輯。
    ///
    /// ### 注意：
    /// - 此方法取代了舊版的 `didChangeAuthorization(_:status:)`，適用於 iOS 14 及以上版本。
    ///
    /// - Parameters:
    ///   - manager: 位置管理器 (`CLLocationManager`) 的實例
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 授權變更後請求一次當前位置，並開始位置更新
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            locationManagerHandlerDelegate?.didReceiveLocationAuthorizationDenied()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    /// 當位置獲取失敗時被調用
    ///
    /// ### 功能：
    /// - 通知代理位置獲取失敗的錯誤，便於顯示提示或進行其他處理。
    ///
    /// - Parameters:
    ///   - manager: 位置管理器 (`CLLocationManager`) 的實例
    ///   - error: 獲取位置時遇到的錯誤
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("獲取位置失敗: \(error.localizedDescription)")
        locationManagerHandlerDelegate?.didFailToUpdateLocation(with: error)
    }
    
}
