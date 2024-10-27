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
 
 4. Public 方法：

    * startLocationUpdates()：
        - 用途：檢查位置授權狀態並啟動位置更新。
        - 授權狀態的處理：
            - .notDetermined：如果未決定，請求用戶授權使用位置。
            - .restricted 或 .denied：通知代理授權被拒絕或受限。
            - .authorizedWhenInUse 或 .authorizedAlways：如果已授權，開始位置更新。
    
 5. CLLocationManagerDelegate 擴展：

    * locationManager(_:didUpdateLocations:)：
        - 用途：當位置更新時，調用此方法，並將最新的位置通過代理 (delegate) 傳遞給使用者。
 
    * locationManager(_:didChangeAuthorization:)：
        - 用途：當位置授權狀態發生變化時調用。
        - 處理授權狀態：
            - 當授權授予 (authorizedWhenInUse 或 authorizedAlways) 時，啟動位置更新。
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
            locationManager.startUpdatingLocation()
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
            locationManager.startUpdatingLocation()
        } else if status == .restricted || status == .denied {
            delegate?.didReceiveLocationAuthorizationDenied()
        }
    }
    
}
