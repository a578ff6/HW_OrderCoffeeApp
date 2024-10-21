//
//  OrderCustomerDetailsHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/10.
//

// MARK: - 關於 selectStoreButtonTapped 暫時不處理：
/*
 ## selectStoreButtonTapped 暫不處理：
 
    - 部分的功能相對較複雜，需要額外的「地圖視圖」的選取界面，因此等其他核心功能完成後再進行實作，確保主要流程能順利運行。
    - 對於 OrderPickupMethodCell 中的 selectStoreButtonTapped 進入「選取店家視圖控制器」。
    - 先透過 OrderPickupMethodCell 中的 selectStoreButtonTapped() 回調中使用一個簡單的模擬動作（直接設定一個測試的店家名稱）幫助在後續開發中保持整體流程通暢，並能讓 UI 測試時具有更完整的體驗。
 */


// MARK: - OrderPickupMethodCell 設置
/*
 1. 取件方式相關的進一步調整
 
    * 資料一致性：
        - CustomerDetailsManager 目前主要管理顧客資料，但也希望它能夠反映 UI 中的變更。需要確保當用戶切換取件方式或更新店家、地址等資訊時，CustomerDetailsManager 可以同步更新相關資料。
        - Pickup Method 配置方法：目前 OrderPickupMethodCell 中的 configure 方法應用於初始化顯示資料，這部分是必要的，應確保每次顯示時，Cell 能根據當前 customerDetails 正確配置顯示狀態。
 
    * 資料管理：
        - CustomerDetailsManager 應繼續負責顧客資料的管理，包括顧客姓名、電話、取件方式、地址、店家等。
        - OrderCustomerDetailsViewController 則應負責顯示資料和處理使用者交互，例如進入店家選擇視圖。
        - 可以考慮在 OrderCustomerDetailsHandler 中進行回調，確保在顧客選擇地址、店家或切換取件方式時，所有這些資料都及時更新到 CustomerDetailsManager，以保持一致。

 2. 「選取店家」視圖控制器的處理
 
    * 模擬店家選擇：
        - 目前在 selectStoreButtonTapped 中模擬選擇店家為「大安店」，這樣可以先進行基本的資料流測試，確保資料能夠正確地傳遞並顯示。將來，需要設計「選取店家」視圖控制器，讓用戶可以實際選擇店家。
        
    * 回調更新：
        - 當用戶完成店家選擇並返回時，可以透過 onStoreChange 回調將選擇的店家名稱更新到 storeTextField，並更新 CustomerDetailsManager 中的資料。這樣可以確保資料在用戶和系統之間保持同步。
 
 3. 外送費的處理（重要）
 
    * 邏輯位置選擇：
        - 將外送費 $60 的加總邏輯放在適當的位置非常重要。以下是兩個主要選擇：
 
            CustomerDetailsManager： 應該專注於顧客資料的管理，因此添加配送費的邏輯不適合放在這裡。
            OrderManager / OrderItemManager： 應該將計算外送費的邏輯放在負責訂單計算的地方，比如 OrderItemManager 或者 Order 的計算總金額的屬性中。在計算總金額時，根據 CustomerDetails.pickupMethod 檢查是否選擇了「外送服務」，如果是則加上 $60。
 
    * 可以在 OrderCustomerDetailsViewController 中監聽取件方式的變化（例如當用戶切換取件方式），然後根據選擇的方式通知 OrderItemManager 重新計算總金額。
 */


// MARK: - 取件方式 整體流程的整理

/*
 1. 初始化顧客資料：
    - 在 OrderCustomerDetailsViewController 加載時，從 UserDetails 初始化顧客資料並填充到 CustomerDetailsManager。
 
 2. 顧客資料填寫：
    - 顧客可以在 OrderCustomerInfoCell 填寫姓名和電話。
    - 在 OrderPickupMethodCell 選擇取件方式，並根據選擇顯示對應的店家或地址輸入框。
    - 當取件方式切換時，確保 CustomerDetailsManager 的資料得到更新。
 
 3. 外送費的處理：
    - OrderItemManager 或 OrderManager 負責管理訂單項目，並計算訂單總金額。在計算總金額時，根據 pickupMethod 判斷是否需要添加外送費。
 
 4. 提交訂單：
    - 當顧客完成所有資料填寫後，OrderCustomerSubmitCell 會觸發提交訂單的邏輯。此時可以從 CustomerDetailsManager 和 OrderItemManager 或 OrderManager 獲取完整的資料，並生成最終的 Order，然後將其提交到 Firebase 等後端服務。
 */


// MARK: - Note  整體流程的整理

/*
 1. 初始化顧客資料：
    - 當從 Firebase 獲取 UserDetails 後，已經通過 CustomerDetailsManager.populateCustomerDetails(from:) 初始化了顧客的詳細資料。
    - 由於 UserDetails 沒有 notes 屬性，因此初始化時設置 notes 為 nil，表示備註欄位最初是空的。
 
 2. 處理 OrderCustomerNoteCell：
    - 當 OrderCustomerNoteCell 被加載時，透過 configure 方法來設定初始的備註值，這樣可以顯示用戶在先前訂單中可能已經填寫的備註。
    - 當用戶在 noteTextView 中編輯內容時，使用 onNoteChange 回調將變更及時更新到 CustomerDetailsManager，確保顧客的詳細資料在資料管理層中保持最新。
 
 3. 顧客資料的一致性更新：
    - 對於取件方式、姓名、電話、地址等其他欄位的變更，都像 OrderCustomerNoteCell 中的備註處理一樣，透過相應的回調及時更新到 CustomerDetailsManager 中，這樣可以確保資料在使用者交互和資料管理層之間保持一致。
 */


// MARK: - OrderCustomerDetailsHandler 筆記

/*
 
 ## OrderCustomerDetailsHandler 筆記：
 
    * OrderCustomerDetailsHandler 是負責管理 OrderCustomerDetailsViewController 中的 UICollectionView 的資料處理與顯示邏輯的類別。
      它主要管理顧客填寫的訂單資訊，包括：
 
        1.顧客基本資料（姓名、電話）
        2.取件方式（到店自取或外送）
        3.訂單備註
        4.提交訂單的按鈕狀態

 &. 主要功能與架構

    * 資料源管理（UICollectionViewDataSource）
 
        - 實現 UICollectionViewDataSource 來提供不同的 Section 與 Cell 的顯示。
        - 使用 Section 列舉來定義各個區段，包括顧客資訊、取件方式、備註、訂單條款等，保持代碼的可讀性和易維護性。

    * Section 與 Cell 配置
            
        - 使用 Section 列舉來管理 UICollectionView 的不同部分：
 
            1.orderTerm: 訂單條款，提供訂單相關的注意事項。
            2.customerInfo: 顧客姓名與電話。
            3.pickupMethod: 取件方式，包括到店自取與外送選擇。
            4.notes: 備註欄位，讓顧客填寫特殊需求或說明。
            5.submitAction: 提交按鈕，用於提交訂單。
 
        - 透過 cellForItemAt 方法配置每個區段的 Cell，並將具體的 Cell 配置邏輯封裝為私有方法，如 configureCustomerInfoCell() 等。
 
    * 委託模式（Delegate）

        - 通過委託模式 OrderCustomerDetailsHandlerDelegate 來通知 OrderCustomerDetailsViewController 當顧客資料發生變化。
        - 當用戶編輯顧客姓名、電話、地址或店家選擇時，會調用 notifyCustomerDetailsChanged()，通知委託方更新按鈕狀態，確保用戶資料的即時性與準確性。
 
    * Cell 配置與回調處理

        - 每個區段的 Cell 都有其配置與回調邏輯：
 
            1.顧客基本資料（customerInfo）: 顧客姓名與電話的變更會觸發相應的回調，進而更新顧客資料。
            2.取件方式（pickupMethod）: 使用者切換取件方式（例如從「到店自取」改為「外送」）或選擇店家時，會調用相應的回調來更新資料。
            3.備註（notes）: 用戶輸入備註時，透過回調即時更新資料。
            4.提交訂單（submitAction）: 點擊提交按鈕時，透過委託呼叫 submitOrder() 方法，將訂單提交。

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
    private func updateCustomerDetails(fullName: String? = nil, phoneNumber: String? = nil, address: String? = nil, storeName: String? = nil, notes: String? = nil) {
        CustomerDetailsManager.shared.updateCustomerDetails(fullName: fullName, phoneNumber: phoneNumber, address: address, storeName: storeName, notes: notes)
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
            cell.configure(with: customerDetails)
        }
        
        // 更新姓名並通知變更
        cell.onNameChange = { [weak self] newName in
            self?.updateCustomerDetails(fullName: newName)
        }
    
        // 更新電話並通知變更
        cell.onPhoneChange = { [weak self] newPhoneNumber in
            self?.updateCustomerDetails(phoneNumber: newPhoneNumber)
        }
        
        return cell
    }
    
    /// 配置 OrderPickupMethodCell
    private func configurePickupMethodCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderPickupMethodCell.reuseIdentifier, for: indexPath) as? OrderPickupMethodCell else {
            fatalError("Cannot create OrderPickupMethodCell")
        }
        
        if let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() {
            cell.configure(with: customerDetails)
        }
        
        /// 設置回調，當取件方式變更時通知外部
        cell.onPickupMethodChanged = { [weak self] newMethod in
            CustomerDetailsManager.shared.updatePickupMethod(newMethod)              // 更新取件方式
            self?.notifyCustomerDetailsChanged()                                     // 通知變更，更新提交按鈕狀態
        }

        /// 處理店家選擇按鈕點擊
        cell.onStoreButtonTapped = { [weak self] in
            // 顯示店家選擇視圖控制器的邏輯
        }
        
        // 更新店家名稱並通知變更
        cell.onStoreChange = { [weak self] storeName in
            self?.updateCustomerDetails(storeName: storeName)
            print("Store name updated to: \(storeName)") // 添加觀察店家名稱變更的 print
        }
        
        // 更新外送地址並通知變更
        cell.onAddressChange = { [weak self] address in
            self?.updateCustomerDetails(address: address)
            print("Address updated to: \(address)") // 添加觀察地址變更的 print
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
            cell.configure(with: customerDetails.notes)
        }

        // 更新備註並通知變更
        cell.onNoteChange = { [weak self] note in
            self?.updateCustomerDetails(notes: note)
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
        cell.configureSubmitButton(isEnabled: isFormValid)

        // 提交按鈕被點擊的處理
        cell.onSubmitTapped = { [weak self] in
            self?.delegate?.submitOrder()
        }

        return cell
    }
    
}
