//
//  OrderCustomerDetailsHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/19.
//

// MARK: - 關於 navigateToStoreSelection
/**
 
 ## 關於 navigateToStoreSelection
 
 * 在 OrderCustomerDetailsHandlerDelegate 中添加了 navigateToStoreSelection 方法，用於導航至店家選擇視圖控制器 (StoreSelectionViewController)。
 
 - navigateToStoreSelection 方法的設計目的是將導航的邏輯從 OrderPickupMethodCell 中抽出來，集中到 OrderCustomerDetailsViewController 進行管理，確保邏輯集中且清晰。
 - 使用此委託的好處是使得 OrderPickupMethodCell 僅需通知外部用戶操作，而不需要直接處理具體的導航行為，這符合單一責任原則。
 - 在 OrderCustomerDetailsViewController 中實作此方法來執行具體的導航邏輯，這樣做可以讓代碼更具有可維護性和可擴展性。
 
 * 具體的使用方式
 
 1. 在 OrderPickupMethodCell 中點擊：
    - 當用戶在 OrderPickupMethodCell 點擊 selectStoreButton 時，回調閉包 onStoreButtonTapped 被觸發，然後通知外部。
 
 2. 在 OrderCustomerDetailsHandler 中設置回調：
    - 使用 onStoreButtonTapped 來通知 OrderCustomerDetailsViewController。
 
 3. 在 OrderCustomerDetailsViewController 中實現導航：
    - 在 OrderCustomerDetailsViewController 中實作委託方法 navigateToStoreSelection()，該方法中可以執行推送 StoreSelectionViewController 的邏輯。
 */


// MARK: - 筆記：OrderCustomerDetailsHandlerDelegate
/**
 
 ## 筆記：OrderCustomerDetailsHandlerDelegate

 ---

 `* What`
 
 - `OrderCustomerDetailsHandlerDelegate` 是一個用於處理與訂單顧客資料變更相關的協議。
 
 它提供以下功能：
 
 1. 資料變更通知：當顧客姓名、電話號碼、取件方式、備註、門市名稱或外送地址有變更時，透過回調方法通知外部。
 2. 提交訂單操作：處理顧客提交訂單的請求。
 3. 導航操作：負責處理「選擇門市」按鈕的點擊，切換到門市選擇畫面。

 ---

 `* Why`
 
 1. 資料同步性：讓 `OrderCustomerDetailsHandler` 能即時通知外部（如 `OrderCustomerDetailsViewController`）處理資料變更，確保 UI 與業務邏輯同步。
 
 2. 責任分離：
    - 資料邏輯：由 `OrderCustomerDetailsHandler` 收集顧客的輸入資料。
    - 業務邏輯與導航：由 `OrderCustomerDetailsViewController` 負責驗證資料、提交訂單以及導航。
 
 3. 提升可維護性：透過協議明確責任範圍，降低耦合性，方便後續擴充與測試。

 ---

` * How`

 `1. 定義協議：`
 
    - 提供資料變更的通知方法，如 `didUpdateCustomerName(_:)`。
    - 提供提交訂單與導航相關的功能。

 `2. 協議方法說明：`
 
    - `didUpdateCustomerName(_ name: String)`：當顧客輸入新的姓名時，通知外部更新資料。
    - `didUpdateCustomerPhone(_ phone: String)`：更新顧客的電話資料。
    - `didUpdatePickupMethod(_ method: PickupMethod)`：當切換取件方式時，更新狀態並刷新 UI。
    - `didUpdateCustomerStoreName(_ storeName: String)`：顧客選擇門市後，更新名稱。
    - `didUpdateCustomerAddress(_ address: String)`：更新外送地址。
    - `didUpdateCustomerNotes(_ notes: String)`：儲存顧客的備註內容。
    - `didTapSubmitOrderButton()`：執行訂單提交相關的邏輯。
    - `navigateToStoreSelection()`：切換到門市選擇畫面。

` 3. 實現與使用：`
 
    - 在 `OrderCustomerDetailsViewController` 中實現 `OrderCustomerDetailsHandlerDelegate`，將協議方法與具體邏輯（如 UI 更新、資料提交）綁定。
    - 例如：
      ```swift
      func didUpdateCustomerAddress(_ address: String) {
          CustomerDetailsManager.shared.updateStoredCustomerDetails(address: address)
          updateSubmitButtonState()
      }
      ```

 `4. 應用場景：`
 
    - 取件方式切換：`didUpdatePickupMethod(_:)` 呼叫後，更新顯示相應的 UI。
    - 提交按鈕狀態變更：根據資料是否完整，通過 `updateSubmitButtonState()` 控制按鈕啟用狀態。
    - 導航至門市選擇畫面：呼叫 `navigateToStoreSelection()`，呈現 `StoreSelectionViewController`。

 ---

 `* 範例使用情境`
 
 - 當顧客在「取件方式」區域切換到「外送服務」並輸入地址：
 
 1. `OrderPickupMethodCell` 中的 `onAddressChange` 回調通知 `OrderCustomerDetailsHandler`。
 2. `OrderCustomerDetailsHandler` 通過協議方法 `didUpdateCustomerAddress(_:)` 將地址變更通知 `OrderCustomerDetailsViewController`。
 3. `OrderCustomerDetailsViewController` 更新資料並判斷是否啟用提交按鈕。

 ---

 `* 結論`
 
 - `OrderCustomerDetailsHandlerDelegate` 將顧客資料處理邏輯與業務邏輯分開，透過協議提供標準化的溝通方式，不僅提升了程式的模組化與可維護性，也讓資料更新與 UI 行為能緊密結合，提升用戶體驗。
 */



// MARK: - 職責

import Foundation

/// 用於通知 `OrderCustomerDetailsHandler` 的相關變更
///
/// `OrderCustomerDetailsHandlerDelegate` 是一個協議，主要負責處理顧客詳細資料的變更、提交訂單操作，以及導航至門市選擇畫面的相關需求。
///
/// ### 功能說明
/// - 與 `OrderCustomerDetailsHandler` 搭配使用，用於透過委託模式將顧客資料的更新通知到外部（例如 `OrderCustomerDetailsViewController`）。
/// - 提供對應方法以處理各種顧客資料的更新，包括姓名、電話、取件方式、地址、備註等。
/// - 確保顧客資料的雙向流轉及 UI 同步更新。
protocol OrderCustomerDetailsHandlerDelegate: AnyObject {
    
    /// 當顧客姓名變更時觸發
    ///
    /// - Parameter name: 更新後的顧客姓名
    func didUpdateCustomerName(_ name: String)
    
    /// 當顧客電話號碼變更時觸發
    ///
    /// - Parameter phone: 更新後的顧客電話號碼
    func didUpdateCustomerPhone(_ phone: String)
    
    /// 當取件方式變更時觸發
    ///
    /// - Parameter method: 更新後的取件方式（例如：到店取件或外送服務）
    func didUpdatePickupMethod(_ method: PickupMethod)
    
    /// 當顧客備註內容變更時觸發
    ///
    /// - Parameter notes: 更新後的備註內容
    func didUpdateCustomerNotes(_ notes: String)
    
    /// 當顧客選擇的門市名稱變更時觸發
    ///
    /// - Parameter storeName: 更新後的門市名稱
    func didUpdateCustomerStoreName(_ storeName: String)
    
    /// 當外送地址變更時觸發
    ///
    /// - Parameter address: 更新後的外送地址
    func didUpdateCustomerAddress(_ address: String)
    
    /// 提交訂單操作
    ///
    /// - 當使用者點擊「提交訂單」按鈕時觸發。
    /// - 通常此方法會處理訂單驗證、提交，以及提交成功或失敗後的相關操作。
    func didTapSubmitOrderButton()
    
    /// 導航至門市選擇畫面
    ///
    /// - 當使用者在 OrderPickupMethodCell 中點擊選擇店家的按鈕時調用。
    /// - 通過此方法，OrderCustomerDetailsViewController 負責推進至 StoreSelectionViewController，進行店鋪的選擇。
    func navigateToStoreSelection()
    
}
