//
//  OrderCustomerDetailsHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/10.
//

// MARK: - 關於 selectStoreButtonTapped 暫時不處理(完成) 以及 送出訂單後清空Order(orderItems、customerDetails)：
/**
 ## selectStoreButtonTapped 暫不處理：
 
    - 部分的功能相對較複雜，需要額外的「地圖視圖」的選取界面，因此等其他核心功能完成後再進行實作，確保主要流程能順利運行。
    - 對於 `OrderPickupMethodCell` 中的` selectStoreButtonTapped `進入「選取店家視圖控制器」。
    - 先透過 `OrderPickupMethodCell` 中的` selectStoreButtonTapped()` 回調中使用一個簡單的模擬動作（直接設定一個測試的店家名稱）幫助在後續開發中保持整體流程通暢，並能讓 UI 測試時具有更完整的體驗。
 */


// MARK: - OrderPickupMethodCell 設置
/**
 1. `取件方式相關的進一步調整`
 
    * `資料一致性`：
        - `CustomerDetailsManager`:  目前主要管理顧客資料，但也希望它能夠反映 UI 中的變更。需要確保當用戶切換取件方式或更新店家、地址等資訊時，`CustomerDetailsManager `可以同步更新相關資料。
        - `Pickup Method 配置方法`：目前 `OrderPickupMethodCell` 中的` configure` 方法應用於初始化顯示資料，這部分是必要的，應確保每次顯示時，Cell 能根據當前 `customerDetails` 正確配置顯示狀態。
 
    * `資料管理`：
        - `CustomerDetailsManager` 應繼續負責顧客資料的管理，包括顧客姓名、電話、取件方式、地址、店家等。
        - `OrderCustomerDetailsViewController` 則應負責顯示資料和處理使用者交互，例如進入店家選擇視圖。
        - 可以考慮在 `OrderCustomerDetailsHandler` 中進行回調，確保在顧客選擇地址、店家或切換取件方式時，所有這些資料都及時更新到` CustomerDetailsManager`，以保持一致。

 2. `「選取店家」視圖控制器的處理`
 
    * `模擬店家選擇`：
        - 目前在 `selectStoreButtonTapped` 中模擬選擇店家為「大安店」，這樣可以先進行基本的資料流測試，確保資料能夠正確地傳遞並顯示。將來，需要設計「選取店家」視圖控制器，讓用戶可以實際選擇店家。
        
    * `回調更新`：
        - 當用戶完成店家選擇並返回時，可以透過 `onStoreChange` 回調將選擇的店家名稱更新到 `storeTextField`，並更新 `CustomerDetailsManager `中的資料。這樣可以確保資料在用戶和系統之間保持同步。
 
 3. `外送費的處理（重要）`
 
    * `邏輯位置選擇`：
        - 將外送費 $60 的加總邏輯放在適當的位置非常重要。以下是兩個主要選擇：
            - `CustomerDetailsManager`： 應該專注於顧客資料的管理，因此添加配送費的邏輯不適合放在這裡。
            - `OrderManager / OrderItemManager`： 應該將計算外送費的邏輯放在負責訂單計算的地方，比如 `OrderItemManager` 或者` Order `的計算總金額的屬性中。在計算總金額時，根據 `CustomerDetails.pickupMethod` 檢查是否選擇了「外送服務」，如果是則加上 $60。
 
    * 可以在` OrderCustomerDetailsViewController `中監聽取件方式的變化（例如當用戶切換取件方式），然後根據選擇的方式通知` OrderItemManager `重新計算總金額。
 */


// MARK: - 取件方式 整體流程的整理

/**
 
 `1. 初始化顧客資料`：
 
    - 在` OrderCustomerDetailsViewController` 加載時，從 `UserDetails` 初始化顧客資料並填充到 `CustomerDetailsManager`。
 
 `2. 顧客資料填寫`：
 
    - 顧客可以在 `OrderCustomerInfoCell` 填寫姓名和電話。
    - 在 `OrderPickupMethodCell` 選擇取件方式，並根據選擇顯示對應的店家或地址輸入框。
    - 當取件方式切換時，確保 `CustomerDetailsManager` 的資料得到更新。
 
 `3. 外送費的處理：`
 
    - `OrderItemManager` 或 `OrderManager` 負責管理訂單項目，並計算訂單總金額。在計算總金額時，根據` pickupMethod `判斷是否需要添加外送費。
 
 `4. 提交訂單：`
 
    - 當顧客完成所有資料填寫後，`OrderCustomerSubmitCell` 會觸發提交訂單的邏輯。此時可以從 `CustomerDetailsManager` 和 `OrderItemManager` 或` OrderManager` 獲取完整的資料，並生成最終的 `Order`，然後將其提交到 Firebase 等後端服務。
 */


// MARK: - Note  整體流程的整理
/**
 
 `1. 初始化顧客資料：`
 
    - 當從 Firebase 獲取 `UserDetails` 後，已經通過 `CustomerDetailsManager.populateCustomerDetails(from:)` 初始化了顧客的詳細資料。
    - 由於 `UserDetails` 沒有 `notes` 屬性，因此初始化時設置 `notes` 為 nil，表示備註欄位最初是空的。
 
 `2. 處理 OrderCustomerNoteCell：`
 
    - 當 `OrderCustomerNoteCell` 被加載時，透過` configure` 方法來設定初始的備註值，這樣可以顯示用戶在先前訂單中可能已經填寫的備註。
    - 當用戶在` noteTextView `中編輯內容時，使用 `onNoteUpdated `回調將變更及時更新到` CustomerDetailsManager`，確保顧客的詳細資料在資料管理層中保持最新。
 
 `3. 顧客資料的一致性更新：`
 
    - 對於取件方式、姓名、電話、地址等其他欄位的變更，都像 `OrderCustomerNoteCell` 中的備註處理一樣，透過相應的回調及時更新到 `CustomerDetailsManager` 中，這樣可以確保資料在使用者交互和資料管理層之間保持一致。
 */


// MARK: - 筆記主題：取件方式變更導致的 UI 同步問題與解決方案（重構）
/**
 
 ## 筆記主題：取件方式變更導致的 UI 同步問題與解決方案

 `* What`
 
 - 在切換取件方式（例如從 "`In-Store Pickup`" 切換到 `"Home Delivery`"）後，如果` storeName` 或 `address` 有值則清空對方。
 - 但 UI 中的 `deliveryAddressTextField` 或` storeTextField` 並未正確同步更新，導致顯示內容與資料管理層不一致。
 - 例如，當切換到 `"Home Delivery"` 後，`deliveryAddressTextField` 仍顯示之前輸入的地址。
 
 1.在`「Home Delivery」` 的`deliveryAddressTextField` 輸入地址「新北市三重區」
 2.接著切換「取件方式」到`「In-Store Pickup」`
 3.點擊`selectStoreButton`，給`storeTextField `賦值「大安店」，這時候就會清空` address` 的值。
 4.接著在切換「取件方式」到`「Home Delivery」`，雖然` address` 被清空，但是` addressText` 卻還有「新北市三重區」

 --------------

 `* Why`
 
 `1. 資料更新未同步至 UI：`
 
    - 在切換取件方式後，資料層的 `address` 或 `storeName` 已正確更新，但沒有通知相關的 UI（例如 `OrderPickupMethodCell`）重新渲染，導致顯示錯誤。

` 2. 責任未明確分離：`
 
    - 過去在 `onPickupMethodChanged` 中直接處理資料更新和 UI 更新，導致程式邏輯混亂，且責任分離不清晰。

 `3.為什麼需要解決這個問題？`

 - 使用者體驗：資料與 UI 不一致會讓使用者困惑，降低應用的可靠性。
 - 系統維護性：如果邏輯不清晰，未來可能難以擴展或調整功能。

 --------------

 `* How`
 
 `1. 改進責任分離`

 - 將 `資料更新` 和 `UI 更新` 的責任分離：
   - Handler：負責資料層變更的處理，並通知外部（如 ViewController）。
   - ViewController：負責根據資料變更進行 UI 更新。

 ---

 `2. 實作委託方法`

 - 在 `OrderCustomerDetailsHandler` 的 `onPickupMethodChanged` 回調中，改為通知委託（`OrderCustomerDetailsHandlerDelegate`），而不是直接更新 UI。

 ```swift
 cell.onPickupMethodChanged = { [weak self] newMethod in
     print("[OrderCustomerDetailsHandler] Pickup method changed to: \(newMethod)")
     self?.orderCustomerDetailsHandlerDelegate?.didUpdatePickupMethod(newMethod)
 }
 ```

 ---

` 3. 精準更新 UI`

 - 在 `ViewController` 中實作 `didUpdatePickupMethod`，確保資料更新後，透過精準刷新相關 UI 元件來同步畫面。

 ```swift
 func didUpdatePickupMethod(_ method: PickupMethod) {
     // 更新資料層
     CustomerDetailsManager.shared.updatePickupMethod(method)
     
     // 精準刷新取件方式的相關 UI
     reloadPickupMethodCell()
     
     // 檢查提交按鈕狀態
     updateSubmitButtonState()
 }
 ```

 ---

 `4. 實現 reloadPickupMethodCell 方法`

 - 使用 `cellForItem(at:)` 鎖定需要刷新的 Cell，並呼叫其 `configure(with:)` 方法，確保資料與顯示內容同步。

 ```swift
 private func reloadPickupMethodCell() {
     let pickupMethodIndexPath = IndexPath(item: 0, section: OrderCustomerDetailsHandler.Section.pickupMethod.rawValue)
     guard let pickupCell = orderCustomerDetailsView.orderCustomerDetailsCollectionView.cellForItem(at: pickupMethodIndexPath) as? OrderPickupMethodCell else { return }
     guard let updatedCustomerDetails = CustomerDetailsManager.shared.getCustomerDetails() else { return }
     
     // 重新配置 Cell
     pickupCell.configure(with: updatedCustomerDetails)
 }
 ```

 --------------

 `* 重構後的流程圖`

 `1. 使用者切換取件方式：`
 
    - `OrderCustomerDetailsHandler` 捕捉變更，通知 `didUpdatePickupMethod`。
 
 `2. 資料層更新：`
 
    - `CustomerDetailsManager` 更新 `pickupMethod`。
 
 `3. UI 同步更新：`
 
    - 呼叫 `reloadPickupMethodCell()` 精準刷新畫面。
 
 `4. 提交按鈕狀態檢查：`
 
    - 更新按鈕的啟用狀態，確保資料完整性。

 --------------

 `* 重點筆記`
 
 `1.在取件方式變更 (onPickupMethodChanged)：`

 - 透過 `onPickupMethodChanged` 通知資料變更，並搭配 `reloadPickupMethodCell() `重新配置 UI，確保畫面與使用者的選擇一致。
 - 原因是取件方式的變更會直接影響 UI 的顯示邏輯（例如顯示或隱藏地址欄位或門市選擇按鈕）。
 
 `2.在店家或地址變更 (onStoreChange, onAddressChange)：`

 - 僅更新資料層，不需重新配置 UI，從而提高性能。
 - 原因是這些變更僅涉及資料本身（例如 `storeName` 或 `address`），不會改變 UI 的欄位結構或可見性，僅需要在顯示資料時進行更新。
 
 `3.保持 UI 與資料一致性：`

 - 確保畫面顯示內容始終反映最新資料，是良好使用者體驗的關鍵。根據不同情境決定是否需要更新 UI，可以提升應用效能並避免不必要的畫面重繪。
 
 --------------

 `* 小結`
 
 `1.為何需要呼叫 reloadPickupMethodCell()？`

 - onPickupMethodChanged 中需要搭配 reloadPickupMethodCell()，因為取件方式的變更直接影響 UI 的顯示邏輯（例如地址欄位是否可見），需要即時更新畫面來反映新的取件方式。
 
 `2.為何不在 onStoreChange 和 onAddressChange 呼叫 reloadPickupMethodCell()？`

 - 這些變更僅更新資料層，不會改變 UI 的欄位結構或可見性，因此無需重新配置整個 Cell。這樣可以避免不必要的性能開銷。
 
 */


// MARK: - 筆記：OrderCustomerDetailsHandler
/**
 
 ## 筆記：OrderCustomerDetailsHandler

 `* What`

 - `OrderCustomerDetailsHandler` 是一個負責管理顧客詳細資料表單邏輯的類，主要功能包括：

 `1. 表單區域管理：`
 
 - 定義表單的各個區域（如訂單條款、顧客資訊、取件方式、備註等）。
 - 每個區域對應不同的 `UICollectionView` section。

` 2. 數據源與交互邏輯：`
 
 - 作為 `UICollectionView` 的 `dataSource` 和 `delegate`，處理數據展示與用戶交互。
 - 通過委託模式（`OrderCustomerDetailsHandlerDelegate`）將交互事件（如更新姓名、電話、取件方式）回傳給外部。

 `3. Cell 配置：`
 
 - 根據顧客詳細資料，配置每個 Cell 的顯示內容（如顧客姓名、地址、備註等）。
 - 動態更新 UI 並觸發相應的回調事件。

 ---

 `* Why`

 `1. 責任分離：`
 
 - 將數據源和交互邏輯從視圖控制器中分離，保持 `OrderCustomerDetailsViewController` 集中處理業務邏輯與導航操作。
 - 增加代碼清晰度與可維護性。

 `2. 提高可測性：`
 
 - 集中處理數據與 UI 映射，便於單元測試。
 - 使 `OrderCustomerDetailsHandler` 成為獨立、可測的組件。

 `3. 動態表單支持：`
 
 - 支持動態區域和內容配置（如根據取件方式更新地址或店家區域）。
 - 減少對整體 `UICollectionView` 刷新的依賴，提高性能。

 `4. 用戶體驗優化：`
 
 - 交互即時更新：用戶變更表單內容時，通過回調即時更新相關數據和 UI。
 - 具體區域刷新：避免整體刷新，保持界面流暢。

 ---

 `* How`

 `1. 表單區域管理：`
 
    - 定義表單結構：
 
      ```swift
      enum Section: Int, CaseIterable {
          case orderTerm
          case customerInfo
          case pickupMethod
          case notes
          case submitAction
      }
      ```
 
    - 實現 `UICollectionViewDataSource` 方法，根據 `Section` 提供區域數量和內容：
 
      ```swift
      func numberOfSections(in collectionView: UICollectionView) -> Int {
          return Section.allCases.count
      }
      ```
 
------
 
 `2. Cell 配置與回調：`
 
    - 配置 `PickupMethodCell`：
 
      ```swift
      private func configurePickupMethodCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderPickupMethodCell.reuseIdentifier, for: indexPath) as? OrderPickupMethodCell else {
              fatalError("Cannot create OrderPickupMethodCell")
          }
          
          guard let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() else { return cell }
          cell.configure(with: customerDetails)
          
          cell.onPickupMethodChanged = { [weak self] newMethod in
              self?.orderCustomerDetailsHandlerDelegate?.didUpdatePickupMethod(newMethod)
          }
          cell.onAddressChange = { [weak self] address in
              self?.orderCustomerDetailsHandlerDelegate?.didUpdateCustomerAddress(address)
          }
          
          return cell
      }
      ```

    - 處理提交按鈕點：
 
      ```swift
      private func configureSubmitActionCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCustomerSubmitCell.reuseIdentifier, for: indexPath) as? OrderCustomerSubmitCell else {
              fatalError("Cannot create OrderCustomerSubmitCell")
          }
          
          cell.onSubmitTapped = { [weak self] in
              self?.orderCustomerDetailsHandlerDelegate?.submitOrder()
          }
          
          return cell
      }
      ```
 
 ------

 `3. 數據更新與同步：`
 
    - 透過委託將用戶操作回傳給視圖控制器：
 
      ```swift
      cell.onNameChange = { [weak self] newName in
          self?.orderCustomerDetailsHandlerDelegate?.didUpdateCustomerName(newName)
      }
      ```
 ---

 `* 總結`

` 1.目的：`
 
 - `OrderCustomerDetailsHandler` 是顧客詳細資料表單的數據與交互核心，負責配置和管理表單各區域的顯示與回調。

 `2.優點：`
 
 - 責任分離清晰，保持視圖控制器專注於業務邏輯。
 - 支持動態配置，便於擴展表單結構。
 
 */



// MARK: - 處理職責

import UIKit

/// `OrderCustomerDetailsHandler` 負責管理顧客詳細資料的 UICollectionView 數據源和交互邏輯。
///
/// ### 功能
/// 1. 表單區域定義：將表單拆分為多個區域（例如：訂單條款、顧客資訊、取件方式等）。
/// 2. Cell 配置：根據顧客詳細資料 (`CustomerDetailsManager`) 配置每個 Cell 的顯示內容。
/// 3. 用戶交互回傳：通過委託模式（`OrderCustomerDetailsHandlerDelegate`），將用戶的操作通知給外部（通常是 ViewController）。
/// 4. 負責區域 Header 的設置：動態配置每個表單區域的標題。
///
/// ### 架構
/// - 責任分離：
///   - `OrderCustomerDetailsHandler` 負責數據與 UI 的映射，確保表單顯示邏輯內聚且可測試。
///   - 外部（如 `OrderCustomerDetailsViewController`）專注於業務邏輯與導航操作。
/// - 靈活擴展：採用 `enum Section` 定義表單區域，新增或調整表單結構時僅需更新 `Section` 定義和對應的配置方法。
///
/// ### 使用場景
/// - 作為 UICollectionView 的 DataSource 和 Delegate 實例，用於顯示顧客詳細資料的表單。
class OrderCustomerDetailsHandler: NSObject {
    
    // MARK: - Properties
    
    /// 用於通知顧客資料變更或提交訂單事件的委託
    weak var orderCustomerDetailsHandlerDelegate: OrderCustomerDetailsHandlerDelegate?
    
    // MARK: - Initializer
    /// 初始化方法，設置委託以處理顧客資料變更或其他事件。
    /// - Parameter orderCustomerDetailsHandlerDelegate: 用於處理交互事件的委託實例。
    init(orderCustomerDetailsHandlerDelegate: OrderCustomerDetailsHandlerDelegate) {
        self.orderCustomerDetailsHandlerDelegate = orderCustomerDetailsHandlerDelegate
        super.init()
    }
    
    // MARK: - Section Definition
    
    /// 定義表單中各個區域（訂單條款、顧客姓名和電話、取件方式、備註、提交訂單按鈕）
    enum Section: Int, CaseIterable {
        case orderTerm
        case customerInfo
        case pickupMethod
        case notes
        case submitAction
    }
    
}

// MARK: - UICollectionViewDataSource
extension OrderCustomerDetailsHandler: UICollectionViewDataSource {
    
    // MARK: - Number of Sections and Items

    /// 返回區域的數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    /// 返回每個區域中的項目數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .orderTerm, .customerInfo, .pickupMethod, .notes, .submitAction:
            return 1
        }
    }
    
    // MARK: - Header Configuration

    /// 返回區域的 Header 視圖
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = OrderCustomerDetailsHandler.Section(rawValue: indexPath.section),
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderCustomerDetailsSectionHeaderView.headerIdentifier, for: indexPath) as? OrderCustomerDetailsSectionHeaderView else {
            fatalError("Could not create header view")
        }
        
        switch sectionType {
        case .orderTerm:
            return UICollectionReusableView()
        case .customerInfo:
            headerView.configure(with: "Name & Phone")
        case .pickupMethod:
            headerView.configure(with: "Pickup Method")
        case .notes:
            headerView.configure(with: "Note")
        case .submitAction:
            return UICollectionReusableView()
        }
        
        return headerView
    }
    
    // MARK: - Cell Configuration
    
    /// 根據區域配置相應的 Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section")
        }
        
        switch sectionType {
        case .orderTerm:
            return configureOrderTermsMessageCell(for: collectionView, at: indexPath)

        case .customerInfo:
            return configureCustomerInfoCell(for: collectionView, at: indexPath)
            
        case .pickupMethod:
            return configurePickupMethodCell(for: collectionView, at: indexPath)
            
        case .notes:
            return configureNoteCell(for: collectionView, at: indexPath)
            
        case .submitAction:
            return configureSubmitActionCell(for: collectionView, at: indexPath)
        }
    }

    // MARK: - Private Cell Configuration Methods

    /// 配置 `OrderTermsMessageCell`
    private func configureOrderTermsMessageCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderTermsMessageCell.reuseIdentifier, for: indexPath) as? OrderTermsMessageCell else {
            fatalError("Cannot create OrderTermsMessageCell")
        }
        return cell
    }

    /// 配置 `OrderCustomerInfoCell`
    private func configureCustomerInfoCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCustomerInfoCell.reuseIdentifier, for: indexPath) as? OrderCustomerInfoCell else {
            fatalError("Cannot create OrderCustomerInfoCell")
        }
        
        // 從 CustomerDetailsManager 中獲取顧客資料，並配置cell
        guard let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() else { return cell }
        print("[OrderCustomerDetailsHandler] Configuring CustomerInfoCell - Name: \(customerDetails.fullName), Phone: \(customerDetails.phoneNumber)")

        cell.configure(with: customerDetails)
        
        // 回傳用戶姓名更新
        cell.onNameChange = { [weak self] newName in
            print("[OrderCustomerDetailsHandler] Name changed to: \(newName)")
            self?.orderCustomerDetailsHandlerDelegate?.didUpdateCustomerName(newName)
        }
        
        // 回傳用戶電話更新
        cell.onPhoneChange = { [weak self] newPhone in
            print("[OrderCustomerDetailsHandler] Phone changed to: \(newPhone)")
            self?.orderCustomerDetailsHandlerDelegate?.didUpdateCustomerPhone(newPhone)
        }
        
        return cell
    }
    
    /// 配置 `OrderPickupMethodCell`
    private func configurePickupMethodCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderPickupMethodCell.reuseIdentifier, for: indexPath) as? OrderPickupMethodCell else {
            fatalError("Cannot create OrderPickupMethodCell")
        }
        
        // 從 CustomerDetailsManager 中獲取顧客資料，並配置cell，根據顧客的取件方式、地址和店家名稱
        guard let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() else { return cell }
        print("[OrderCustomerDetailsHandler] Configuring PickupMethodCell - Method: \(customerDetails.pickupMethod), Address: \(customerDetails.address ?? "N/A"), Store: \(customerDetails.storeName ?? "N/A")")

        cell.configure(with: customerDetails)
        
        // 更新取件方式並通知變更
        cell.onPickupMethodChanged = { [weak self] newMethod in
            print("[OrderCustomerDetailsHandler] Pickup method changed to: \(newMethod)")
            self?.orderCustomerDetailsHandlerDelegate?.didUpdatePickupMethod(newMethod)
        }

        // 更新店家名稱並通知變更
        cell.onStoreChange = { [weak self] storeName in
            print("[OrderCustomerDetailsHandler] Store name changed to: \(storeName)")
            self?.orderCustomerDetailsHandlerDelegate?.didUpdateCustomerStoreName(storeName)
        }
        
        // 更新外送地址並通知變更
        cell.onAddressChange = { [weak self] address in
            print("[OrderCustomerDetailsHandler] Address changed to: \(address)")
            self?.orderCustomerDetailsHandlerDelegate?.didUpdateCustomerAddress(address)
        }
        
        // 處理店家選擇按鈕點擊
        cell.onStoreButtonTapped = { [weak self] in
            // 顯示店家選擇視圖控制器（StoreSelectionViewController）的邏輯，然後返回時更新店家名稱
            self?.orderCustomerDetailsHandlerDelegate?.navigateToStoreSelection()
        }
    
        return cell
    }
    
    /// 配置 `OrderCustomerNoteCell`
    private func configureNoteCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCustomerNoteCell.reuseIdentifier, for: indexPath) as? OrderCustomerNoteCell else {
            fatalError("Cannot create OrderCustomerNoteCell")
        }
        
        // 從 CustomerDetailsManager 中獲取顧客資料
        guard let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() else { return cell }
        print("[OrderCustomerDetailsHandler] Configuring NoteCell - Notes: \(customerDetails.notes ?? "No Notes")")

        cell.configure(with: customerDetails.notes)
        
        // 更新備註並通知變更
        cell.onNoteUpdated = { [weak self] note in
            print("[OrderCustomerDetailsHandler] Notes updated to: \(note)")
            self?.orderCustomerDetailsHandlerDelegate?.didUpdateCustomerNotes(note)
        }
        
        return cell
    }
        
    /// 配置 `OrderCustomerSubmitCell`
    private func configureSubmitActionCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCustomerSubmitCell.reuseIdentifier, for: indexPath) as? OrderCustomerSubmitCell else {
            fatalError("Cannot create OrderCustomerSubmitCell")
        }

        // 配置提交按鈕的初始狀態
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        let isFormValid = (validationResult == .success)
        
        // 觀察驗證結果及是否啟用提交按鈕
        print("[OrderCustomerDetailsHandler] Configuring SubmitButton - isFormValid: \(isFormValid), ValidationResult: \(validationResult)")

        cell.configureSubmitButton(isEnabled: isFormValid)

        // 提交按鈕被點擊的處理
        cell.onSubmitTapped = { [weak self] in
            self?.orderCustomerDetailsHandlerDelegate?.didTapSubmitOrderButton()
        }

        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension OrderCustomerDetailsHandler: UICollectionViewDelegate {
    
}
