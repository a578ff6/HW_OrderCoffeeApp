//
//  LocationManagerHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/27.
//


// MARK: - LocationManagerHandlerDelegate 筆記
/**

 ## LocationManagerHandlerDelegate 筆記

 `* What`

 - `LocationManagerHandlerDelegate` 是一個用於處理位置相關交互的協議。
 
 - 定義了兩個方法，幫助控制器處理不同的情況：
 
 1.`didReceiveLocationAuthorizationDenied`：當用戶拒絕位置授權時調用。
 2.`didFailToUpdateLocation`：當位置獲取失敗時調用。
 
 --------

 `* Why`
 
 1. 分離職責：
 
    - 協議確保 `LocationManagerHandler` 專注於位置管理邏輯，而具體的提示訊息或介面行為由控制器實現。
    
 2. 增強可測試性：
 
    - 將授權拒絕的處理邏輯交由控制器實現，便於進行單元測試或界面驗證。

 3. 提升靈活性：
 
    - 控制器可以根據具體需求自定義用戶授權拒絕後的行為，例如顯示彈窗或記錄日誌。

 --------

 `* How`

 1. 定義協議
 
 - `didReceiveLocationAuthorizationDenied`，用於位置授權拒絕時的通知。
 - `didFailToUpdateLocation` 用於位置定位錯誤時的通知。
 
 2. 設置代理
 
 - 在 `LocationManagerHandler` 中，通過 `locationManagerHandlerDelegate` 傳遞事件。

 3. 控制器實現協議
 
 - 在控制器中實現 `LocationManagerHandlerDelegate`，顯示提示訊息或執行其他操作。

 4. 通知授權狀態
 
 - 當授權被拒絕時，調用 `locationManagerHandlerDelegate?.didReceiveLocationAuthorizationDenied()`，將事件傳遞給控制器。

 --------

 `* Code Implementation Summary`

 - `LocationManagerHandler`

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
         locationManager.requestLocation()
         locationManager.startUpdatingLocation()
     @unknown default:
         break
     }
 }
 
 extension LocationManagerHandler: CLLocationManagerDelegate {
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("獲取位置失敗: \(error.localizedDescription)")
         locationManagerHandlerDelegate?.didFailToUpdateLocation(with: error)
     }
 }

 ```

 ---

 `- StoreSelectionViewController`

 ```swift
 // MARK: - LocationManagerHandlerDelegate
 extension StoreSelectionViewController: LocationManagerHandlerDelegate {
     
     /// 當位置權限被拒絕時調用
     ///
     /// ### 功能說明：
     /// - 彈出警告提示用戶啟用位置權限。
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
      ///
      /// ### 功能說明：
      /// - 彈出警告提示，通知用戶位置獲取過程中出現錯誤。
      /// - 包含錯誤信息以便用戶理解問題。
      ///
      /// - Parameter error: 獲取位置時的錯誤。
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

 --------

 `* 優化與設計益處`

 1. 高內聚、低耦合：
 
    - 協議的設計強調位置授權邏輯與視圖行為分離，避免 `LocationManagerHandler` 涉及 UI 邏輯。
    
 2. 易擴展性：
 
    - 未來若需新增授權處理行為（如記錄日誌、觸發特定事件），僅需調整實現協議的控制器即可。

 3. 一致性與可維護性：
 
    - 授權拒絕的處理集中在協議方法內，代碼結構清晰，易於定位相關邏輯。
 */


// MARK: - (v)

import UIKit

/// LocationManagerHandlerDelegate 協議
///
/// 此協議用於處理與 `LocationManagerHandler` 的互動，
/// 提供用戶拒絕授權位置時、位置獲取失敗的回調方法。
///
/// ### 功能說明：
/// - 通知使用此協議的控制器，當用戶拒絕位置授權時、位置獲取失敗進行適當處理，例如顯示提示訊息引導用戶開啟授權。
protocol LocationManagerHandlerDelegate: AnyObject {
    
    /// 當用戶拒絕位置授權時調用
    ///
    /// ### 功能說明：
    /// - 提示控制器顯示相關訊息，引導用戶前往系統設定開啟位置授權。
    func didReceiveLocationAuthorizationDenied()
    
    /// 當位置獲取失敗時調用
    ///
    /// ### 功能說明：
    /// - 通知控制器位置獲取過程中出現的錯誤。
    /// - 控制器可以選擇性地處理錯誤，例如彈出提示框。
    ///
    /// - Parameter error: 獲取位置時的錯誤
    func didFailToUpdateLocation(with error: Error)
    
}
