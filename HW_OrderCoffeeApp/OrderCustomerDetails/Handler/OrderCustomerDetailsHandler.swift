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
    - 當用戶在` noteTextView `中編輯內容時，使用 `onNoteChange `回調將變更及時更新到` CustomerDetailsManager`，確保顧客的詳細資料在資料管理層中保持最新。
 
 `3. 顧客資料的一致性更新：`
    - 對於取件方式、姓名、電話、地址等其他欄位的變更，都像 `OrderCustomerNoteCell` 中的備註處理一樣，透過相應的回調及時更新到 `CustomerDetailsManager` 中，這樣可以確保資料在使用者交互和資料管理層之間保持一致。
 */


// MARK: - OrderCustomerDetailsHandler 筆記

/**
 ## OrderCustomerDetailsHandler 筆記：
 
    * `OrderCustomerDetailsHandler` 是負責管理 `OrderCustomerDetailsViewController` 中的 `UICollectionView `的資料處理與顯示邏輯的類別。
      它主要管理顧客填寫的訂單資訊，包括：
 
        1.顧客基本資料（姓名、電話）
        2.取件方式（到店自取或外送）
        3.訂單備註
        4.提交訂單的按鈕狀態

 `&. 主要功能與架構`

    * `資料源管理（UICollectionViewDataSource）`
        - 實現 UICollectionViewDataSource 來提供不同的 Section 與 Cell 的顯示。
        - 使用 Section 列舉來定義各個區段，包括顧客資訊、取件方式、備註、訂單條款等，保持代碼的可讀性和易維護性。

    * `Section 與 Cell 配置`
        - 使用 Section 列舉來管理 UICollectionView 的不同部分：
 
            1.orderTerm: 訂單條款，提供訂單相關的注意事項。
            2.customerInfo: 顧客姓名與電話。
            3.pickupMethod: 取件方式，包括到店自取與外送選擇。
            4.notes: 備註欄位，讓顧客填寫特殊需求或說明。
            5.submitAction: 提交按鈕，用於提交訂單。
 
        - 透過 cellForItemAt 方法配置每個區段的 Cell，並將具體的 Cell 配置邏輯封裝為私有方法，如 configureCustomerInfoCell() 等。
 
    * `委託模式（Delegate）`
        - 通過委託模式` OrderCustomerDetailsHandlerDelegate `來通知` OrderCustomerDetailsViewController` 當顧客資料發生變化。
        - 當用戶編輯顧客姓名、電話、地址或店家選擇時，會調用 `notifyCustomerDetailsChanged()`，通知委託方更新按鈕狀態，確保用戶資料的即時性與準確性。
 
    * `Cell 配置與回調處理`
        - 每個區段的 Cell 都有其配置與回調邏輯：
 
            1.顧客基本資料（customerInfo）: 顧客姓名與電話的變更會觸發相應的回調，進而更新顧客資料。
            2.取件方式（pickupMethod）: 使用者切換取件方式（例如從「到店自取」改為「外送」）或選擇店家時，會調用相應的回調來更新資料。
            3.備註（notes）: 用戶輸入備註時，透過回調即時更新資料。
            4.提交訂單（submitAction）: 點擊提交按鈕時，透過委託呼叫 submitOrder() 方法，將訂單提交。
 */


// MARK: - 關於 調整 OrderCustomerDetailsHandler 的邏輯，讓它能更好地管理和處理顧客詳細資料。 以及運用 collectAndUpdateCustomerDetails。

/**
 ## OrderCustomerDetailsHandler 調整邏輯的具體步驟
 
    - 在 `OrderCustomerDetailsHandler` 中，需要進行一些邏輯上的調整，主要是讓它能夠正確地管理和處理` OrderPickupMethodCell` 的交互，並更新 `CustomerDetailsManager` 中的顧客資料。

 1. `完善 configurePickupMethodCell`
 
    - 首先，在 `configurePickupMethodCell` 方法中，需要根據 `CustomerDetails` 初始化` OrderPickupMethodCell`，並設置相關的回調。
 
 2. `通知顧客資料變更`

    - 在顧客資料發生變更時，需要通知外部的 `OrderCustomerDetailsViewController`來更新提交按鈕的狀態，這樣可以確保只有當資料完整時才允許提交訂單。
 
 3. `設置顧客資料變更回調`

    - 對於 `OrderPickupMethodCell` 中的其他回調，例如地址變更和店家選擇變更，都應該調用` collectAndUpdateCustomerDetails()` 來更新資料並且通知外部的變更。

    - 以下是如何為 `OrderPickupMethodCell `設置這些回調：
        - `取件方式變更`： 當用戶切換取件方式時，更新顧客資料中的` pickupMethod` 並通知` OrderCustomerDetailsViewController `更新提交按鈕狀態。
        - `地址變更和店家選擇變更`： 當地址或店家名稱發生變更時，調用` collectAndUpdateCustomerDetails()` 更新資料，並通知外部變更。
 
 4. `修改 OrderCustomerDetailsHandler 中的 cellForItemAt`
 
    - 在 `collectionView(_:cellForItemAt:)` 方法中，對每個 section 的 cell 進行配置，其中` pickupMethod` 的部分應使用前面調整過的 `configurePickupMethodCell` 方法。
 
 5.` 調整後的 OrderCustomerDetailsHandler`
 
    - 這些調整能夠幫助` OrderCustomerDetailsHandler` 更加有效地管理表單內部的邏輯，確保顧客資料的變更能夠即時反映到表單的提交按鈕上。

    - `調整後的回調和邏輯的好處`
        - `更清晰的責任劃分`：`OrderPickupMethodCell` 負責 UI 和與用戶交互的回調，具體的資料更新則由 `CustomerDetailsManager` 處理。
        - `易於擴展和維護`：如果未來需要更改資料處理邏輯，這樣的設計便於集中在` CustomerDetailsManager` 內進行修改，而不需要深入到 UI 元件內部。
        - `確保資料一致性`：所有資料變更都統一通過` CustomerDetailsManager` 處理，可以減少資料不一致的問題。
 */


// MARK: - 筆記主題：取件方式變更導致的 UI 同步問題與解決方案（重要）

/**
 ## 筆記主題：取件方式變更導致的 UI 同步問題與解決方案

 `&. 問題描述`
 
    - 在切換取件方式（例如從 "`In-Store Pickup`" 切換到 `"Home Delivery`"）後，如果` storeName` 或 `address` 有值則清空對方，但 UI 中的 `addressTextField` 或` storeTextField` 並未正確同步更新，導致顯示內容與資料管理層不一致。
    - 例如，當切換到 `"Home Delivery"` 後，`addressTextField` 仍顯示之前輸入的地址。
    
    1.在`「Home Delivery」` 的`addressTextField` 輸入地址「新北市三重區」
    2.接著切換「取件方式」到`「In-Store Pickup」`
    3.點擊`selectStoreButton`，給`storeTextField `賦值「大安店」，這時候就會清空` address` 的值。
    4.接著在切換「取件方式」到`「Home Delivery」`，雖然` address` 被清空，但是` addressText` 卻還有「新北市三重區」
 
 &. `問題原因`
 
    - 資料更新後，UI 未同步更新，導致畫面顯示和資料不一致。
 
 &. `解決方案`
 
    1. `在取件方式變更後重新配置 Cell`：
        - 透過呼叫` configure(with:) `方法來重新配置相關的 Cell，確保 UI 和資料保持一致。

    2. `在 onPickupMethodChanged 回調中進行 UI 更新`：
        - 在更新資料後，重新呼叫 `configure(with:)`，以便同步更新 UI，確保畫面顯示符合最新的取件方式。
 
 `&. 詳細說明`
 
    1. 為何在` onPickupMethodChanged `呼叫` configure(with:)`
        -` onPickupMethodChanged `的目的是處理使用者切換取件方式，這會影響 UI 中顯示的欄位。
        - 例如，切換為 "Home Delivery" 應顯示地址輸入框，而隱藏選擇店家的欄位。呼叫 `configure(with:)` 可以確保 UI 及時根據使用者的選擇進行更新。
    
    2. 是否應在 `onStoreChange` 或 `onAddressChange` 中呼叫` configure(with:)`
        - 可以考慮，但不一定必要。這些變更通常不會影響 UI 中其他欄位的顯示狀況，因此只需更新相應的資料即可，無需重新配置整個 Cell。這樣可以減少不必要的重新渲染，提高性能。
 
 `&. 小結`
 
    - `onPickupMethodChanged` 中呼叫` configure(with:)` 是因為取件方式的變更會直接影響到 UI 的顯示邏輯，需要根據選擇的取件方式來顯示或隱藏相應的欄位。
    - `onStoreChange` 和 `onAddressChange` 不呼叫` configure(with:)`，因為這些變更僅涉及資料更新，不會改變 UI 的欄位顯示狀況。
 
 `&. 重點筆記`

    1.在取件方式變更` (onPickupMethodChanged)` 時，呼叫` configure(with:)` 以確保 UI 的顯示符合使用者的選擇。
    2.在店家或地址變更` (onStoreChange, onAddressChange)` 時，僅更新資料層，不需重新配置 UI，從而提高性能。
    3.保持 UI 與資料的一致性是確保良好使用者體驗的重要環節，應根據情境決定是否需要更新 UI。
    4.這樣的設計考慮可以確保程式邏輯簡潔，提高效能，避免不必要的 UI 更新。
 */


import UIKit

/// OrderCustomerDetailsHandler 是用於處理顧客詳細資料 CollectionView 的資料源和互動邏輯的類別。
///
/// 它負責配置顯示訂單相關資訊的各種 Cell，並處理用戶在表單填寫過程中的各種互動。
class OrderCustomerDetailsHandler: NSObject {
    
    // MARK: - Properties
    
    /// CollectionView，顯示顧客詳細資料
    private var collectionView: UICollectionView
    
    /// 用於通知顧客資料變更或提交訂單的事件
    weak var delegate: OrderCustomerDetailsHandlerDelegate?
    
    // MARK: - Section
    
    /// 定義表單中各個區域（訂單條款、顧客姓名和電話、取件方式、備註、提交訂單按鈕）
    enum Section: Int, CaseIterable {
        case orderTerm
        case customerInfo
        case pickupMethod
        case notes
        case submitAction
    }
    
    // MARK: - Initializer
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = self
    }
    
    // MARK: - Customer Details Notification Method

    /// 當顧客資料發生變更時，通知委託
    private func notifyCustomerDetailsChanged() {
        delegate?.customerDetailsDidChange()
    }
    
    /// 更新顧客資料並通知委託變更
    private func collectAndUpdateCustomerDetails(fullName: String? = nil, phoneNumber: String? = nil, address: String? = nil, storeName: String? = nil, notes: String? = nil) {
        CustomerDetailsManager.shared.updateStoredCustomerDetails(fullName: fullName, phoneNumber: phoneNumber, address: address, storeName: storeName, notes: notes)
        notifyCustomerDetailsChanged()
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
    
    // MARK: - Private Cell Configuration Methods

    /// 配置 OrderTermsMessageCell
    private func configureOrderTermsMessageCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderTermsMessageCell.reuseIdentifier, for: indexPath) as? OrderTermsMessageCell else {
            fatalError("Cannot create OrderTermsMessageCell")
        }
        return cell
    }
    
    /// 配置 OrderCustomerInfoCell
    private func configureCustomerInfoCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCustomerInfoCell.reuseIdentifier, for: indexPath) as? OrderCustomerInfoCell else {
            fatalError("Cannot create OrderCustomerInfoCell")
        }
        
        /// 從 CustomerDetailsManager 獲取顧客資料，然後配置 cell，設置初始值
        if let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() {
            print("[OrderCustomerDetailsHandler] Configuring CustomerInfoCell with FullName: \(customerDetails.fullName), PhoneNumber: \(customerDetails.phoneNumber)")
            cell.configure(with: customerDetails)
        }
        
        // 更新姓名並通知變更
        cell.onNameChange = { [weak self] newName in
            self?.collectAndUpdateCustomerDetails(fullName: newName)
        }
    
        // 更新電話並通知變更
        cell.onPhoneChange = { [weak self] newPhoneNumber in
            self?.collectAndUpdateCustomerDetails(phoneNumber: newPhoneNumber)
        }
        
        return cell
    }
    
    /// 配置 OrderPickupMethodCell
    private func configurePickupMethodCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderPickupMethodCell.reuseIdentifier, for: indexPath) as? OrderPickupMethodCell else {
            fatalError("Cannot create OrderPickupMethodCell")
        }
        
        // 從 CustomerDetailsManager 中獲取顧客資料
        if let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() {
            print("[OrderCustomerDetailsHandler] Configuring PickupMethodCell with Pickup Method: \(customerDetails.pickupMethod.rawValue)")
            // 配置 Cell 的顯示，根據顧客的取件方式、地址和店家名稱
            cell.configure(with: customerDetails)
        }
        
        // 設置回調，當取件方式變更時通知外部處理
        cell.onPickupMethodChanged = { [weak self] newMethod in
            // 更新取件方式
            CustomerDetailsManager.shared.updatePickupMethod(newMethod)
            // 通知外部（OrderCustomerDetailsViewController）更新提交按鈕狀態
            self?.notifyCustomerDetailsChanged()
            
            // 重新配置 Cell，使得 UI 同步更新
            if let updatedCustomerDetails = CustomerDetailsManager.shared.getCustomerDetails() {
                print("[OrderCustomerDetailsHandler] PickupMethod changed to: \(updatedCustomerDetails.pickupMethod.rawValue), re-configuring PickupMethodCell")
                cell.configure(with: updatedCustomerDetails)
            }
        }

        // 更新店家名稱並通知變更
        cell.onStoreChange = { [weak self] storeName in
            self?.collectAndUpdateCustomerDetails(storeName: storeName)
            print("[OrderCustomerDetailsHandler] Store name updated to: \(storeName)")
        }
        
        // 更新外送地址並通知變更
        cell.onAddressChange = { [weak self] address in
            self?.collectAndUpdateCustomerDetails(address: address)
            print("[OrderCustomerDetailsHandler] Address updated to: \(address)")
        }
        
        // 處理店家選擇按鈕點擊
        cell.onStoreButtonTapped = { [weak self] in
            // 顯示店家選擇視圖控制器（StoreSelectionViewController）的邏輯，然後返回時更新店家名稱
            self?.delegate?.navigateToStoreSelection()
        }
        
        return cell
    }
    
    /// 配置 OrderCustomerNoteCell
    private func configureNoteCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCustomerNoteCell.reuseIdentifier, for: indexPath) as? OrderCustomerNoteCell else {
            fatalError("Cannot create OrderCustomerNoteCell")
        }

        /// 配置 notes 欄位
        if let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() {
            print("[OrderCustomerDetailsHandler] Configuring NoteCell with Notes: \(customerDetails.notes ?? "No Notes")")
            cell.configure(with: customerDetails.notes)
        }

        // 更新備註並通知變更
        cell.onNoteChange = { [weak self] note in
            self?.collectAndUpdateCustomerDetails(notes: note)
            print("[OrderCustomerDetailsHandler] Notes updated to: \(note)")
        }

        return cell
    }
    
    /// 配置 OrderCustomerSubmitCell
    private func configureSubmitActionCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCustomerSubmitCell.reuseIdentifier, for: indexPath) as? OrderCustomerSubmitCell else {
            fatalError("Cannot create OrderCustomerSubmitCell")
        }

        // 配置提交按鈕的初始狀態
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        let isFormValid = (validationResult == .success)
        
        // 觀察驗證結果及是否啟用提交按鈕
        print("[OrderCustomerDetailsHandler] Configuring SubmitButton: isFormValid = \(isFormValid), ValidationResult = \(validationResult)")
        cell.configureSubmitButton(isEnabled: isFormValid)

        // 提交按鈕被點擊的處理
        cell.onSubmitTapped = { [weak self] in
            print("[OrderCustomerDetailsHandler] Submit button tapped.")
            self?.delegate?.submitOrder()
        }

        return cell
    }
    
}
