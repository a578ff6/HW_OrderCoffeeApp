//
//  CustomerDetailsManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/9.
//

/*
 
 ## CustomerDetailsManager 的設計思路：

    - CustomerDetailsManager 負責處理和 CustomerDetails 相關的業務邏輯。

 * 用途
    - CustomerDetailsManager 的主要職責是將 UserDetails 中的資料和 CustomerDetails 的需求相結合，以便在生成訂單時，能夠獲得合適的顧客資料。
    - 它還可以提供一些檢查方法，比如判斷 UserDetails 是否有足夠的資料可以使用。

 * 功能
    - 從 UserDetails 中獲取已填寫的資料並設置到 CustomerDetails。
    - 驗證 CustomerDetails 的完整性，確保訂單中需要的資料已填寫完整。
    - 提供接口讓 OrderCustomerDetailsViewController 可以取得 UserDetails 中的預設資料。
    - 這樣設計可以減少 OrderCustomerDetailsViewController 的負擔，讓資料管理邏輯集中在 CustomerDetailsManager，提高程式碼的可維護性。
 
 
 &. 與 FirebaseController 的作用：
    
    - FirebaseController 的 getCurrentUserDetails() 可以幫助 CustomerDetailsManager 獲取最新的 UserDetails 資料，這對於初始填入資料或同步資料是非常有幫助的。

    * CustomerDetailsManager 使用 getCurrentUserDetails() 的場景
        - 當加載 OrderCustomerDetailsViewController 時，可以使用 CustomerDetailsManager 通過 FirebaseController 獲取當前用戶的資料並填入到 CustomerDetails 中。
        - 如果用戶需要手動補充資料，也可以通過此接口來同步最新的資料。
 
 
 &. 如何在 OrderCustomerDetailsViewController 中使用 CustomerDetailsManager：
 
    - 當 OrderCustomerDetailsViewController 加載時，可以使用 CustomerDetailsManager 來預填資料。
    - 當使用者完成填寫顧客資料時，可以將這些資料更新回 CustomerDetailsManager，以便後續在提交訂單時使用。
 
 
 &. 最後想法：
 
    - CustomerDetailsManager 應該主要負責管理和提供 CustomerDetails，它應該與 OrderCustomerDetailsViewController 一起工作以完成顧客資料的填寫。
    - OrderCustomerDetailsViewController 則專注於顯示和收集資料，並通過 CustomerDetailsManager 來操作顧客詳細資料。
    - FirebaseController 的 getCurrentUserDetails() 方法對於初始資料獲取非常有幫助，在 OrderCustomerDetailsViewController 加載時通過 CustomerDetailsManager 使用它來填入初始的顧客資料。
 
 
 &. 重點觀察測試：

    - 畢竟 OrderCustomerDetailsViewController 是採用 push的方式，必須考慮到屆時 Tab Order 是停留在 OrderCustomerDetailsViewController，同時使用者點擊 Tab UserProfile 並進入到 EditProfileViewController 去修改使用者個人資料時，是否會反映在 OrderCustomerDetailsViewController。
 
    - 屆時要觀察測試店取的選取部分。
 */


// MARK: - 設置 updatePickupMethod 的原因

/*
 
 ## 在 CustomerDetailsManager 中設置 updatePickupMethod，並在 OrderPickupMethodCell 的 segmentedControlValueChanged 中使用，主要是為了保持資料的一致性和便於管理。
 
 1. 資料一致性

    - CustomerDetailsManager 作為顧客資料的中心管理器，負責維護顧客的所有資料，包括姓名、電話、取件方式、地址、備註等。
    - 當用戶在界面上更改取件方式（例如從「到店自取」改為「外送服務」），確保這些變更反映到中央的資料管理中。
    - 如果不在 CustomerDetailsManager 中更新取件方式，那麼當之後需要使用這些資料（例如計算總金額或提交訂單）時，取件方式無法反映用戶的實際選擇，從而導致資料不一致。
 
 2. 維護和擴展的便利性

    - 使用 CustomerDetailsManager 的 updatePickupMethod 可以確保所有取件方式的變更都經過同一個地方進行。
    - 這樣如果未來需要對取件方式的變更進行額外的處理（例如驗證或額外的邏輯），可以在一個地方集中管理，減少重複程式碼並提高擴展性。
    - 例如，可能在未來需要在取件方式變更時觸發其他的操作，比如清空或重置某些資料，在 CustomerDetailsManager 中集中管理這些邏輯可以使得代碼更加可控。
 
 3. 跨界面傳遞資料

    - 如果用戶在 OrderPickupMethodCell 中更改取件方式，但卻不更新到 CustomerDetailsManager，那麼當其他的 view 或 controller 需要獲取顧客資料時，它們會得到舊的資料，而不是最新的資料。
    - 例如，OrderSubmit 時，需要根據 pickupMethod 來計算訂單金額（外送服務需加 $60），如果取件方式未更新到 CustomerDetailsManager，提交時可能會使用錯誤的金額。
 
 4. 總結
 
    - 在 CustomerDetailsManager 中設置 updatePickupMethod 是為了保持資料的一致性和便於管理。
    - 如果不設置這個方法，資料管理會變得更加分散且難以維護，增加了出錯的機會。
    - 通過統一的管理器來處理顧客資料，可以確保在整個 App 中，所有相關的資料更新都保持同步，提升代碼的整潔性和擴展性。
 
 */
 

// MARK: - 不設置 updatePickupMethod 的影響

/*

 1. 資料更新不同步

    - 如果用戶在 UI 中更改取件方式，但你沒有將這個變更反映到 CustomerDetailsManager，那麼 CustomerDetailsManager 仍然持有舊的取件方式資料。
    - 在之後的流程（例如計算訂單金額或生成訂單時），這些資料可能會導致錯誤或與用戶實際選擇不符。

 2. 跨界面溝通困難
 
    - CustomerDetailsManager 的設計目的是作為顧客資料的共享來源，這樣不同的 view 或 controller 可以隨時獲取顧客的最新資料。
    - 如果不通過 CustomerDetailsManager 更新取件方式，那麼每次當其他界面需要獲取這些資料時，都可能需要額外的步驟來同步更新，增加了溝通的成本和代碼的複雜性。
 
 3. 增加額外的處理邏輯
 
    - 如果不集中管理更新取件方式的邏輯，需要在多個地方（例如在 OrderPickupMethodCell 和 OrderCustomerDetailsHandler 中）都進行取件方式的更新和資料處理。
    - 這樣會造成邏輯分散且難以維護。未來如果有需求變更，可能需要在多處修改，導致容易出現漏改或錯誤。
 
 
 ## 在 segmentedControlValueChanged 設置 CustomerDetailsManager.shared.updatePickupMethod 運用：
 
    - 這樣的做法在取件方式改變的時候，直接同步到 CustomerDetailsManager，確保所有的資料都保持一致，也方便之後對訂單的操作或計算。
 
 1. 用於更新顧客的取件方式，以確保顧客資料的統一管理和資料同步。這樣不論在哪裡更改取件方式，都能保持資料的一致性。
 
 2. 資料同步更新
    - 在 segmentedControlValueChanged() 方法中直接使用 CustomerDetailsManager.shared.updatePickupMethod(selectedMethod) 是為了保持取件方式的資料一致性，確保顧客的所有資料都經過統一的資料管理器更新。

 3. 維護方便性
    - 集中管理資料更新，方便未來如有新需求，只需要修改 CustomerDetailsManager 即可，減少重複代碼並提高可維護性。
 
 4. 未來改進方向
    - 可以考慮在 updatePickupMethod 方法中添加其他的業務邏輯，比如當切換為「外送服務」時，更新訂單的總金額以包含額外的運費。這樣可以使邏輯更集中，並減少界面層級中的複雜性。（可以即時反應，但我要的是送出訂單後才反應）

 */


// MARK: - 設計考量：外送服務費用的計算位置

/*
 
 ## 目前在設計上，有兩個主要方案來設置外送服務費用，分別是放在 OrderManager 的 submitOrder() 中，或放在 CustomerDetailsManager 的 updatePickupMethod() 中。以下是比較與重點建議。
 
 1. 在 OrderManager 的 submitOrder() 中設置外送服務費用（採用的）
 
    * 優點：

        - 集中管理： 所有與訂單計算、提交相關的邏輯都集中在 OrderManager，便於追蹤和維護。
        - 一致性： 外送費用只在訂單提交時進行計算，確保最終提交時的金額是最新且正確的。
    
    * 缺點：

        - 擴展性： 無法在 UI 上即時看到訂單金額（包括外送費），使用者在訂單提交前無法知道總費用。
        - 邏輯重複： 如果在其他地方需要重新計算訂單費用，這段邏輯可能需要多次重複。

 2. 在 CustomerDetailsManager 的 updatePickupMethod() 中設置外送服務費用
 
    * 優點：

        - 動態更新： 使用者在選擇外送服務時，外送費用可以即時反映在 UI 上，提升使用者體驗。
        - 責任分離： 顧客選擇取件方式的邏輯和對應的費用可以在一處集中處理。

    * 缺點：

        - 責任邊界模糊： 外送費用的計算本應該屬於訂單管理的一部分，但將其放在 CustomerDetailsManager 中可能導致職責模糊。
        - 多處更新風險： 如果之後外送費用的邏輯有所變更，可能需要更新多個地方，導致維護上的困難。
 
 3. 目前設計重點
 
    - 外送費用的計算是在 OrderManager 的 submitOrder() 中完成的，這意味著外送費用僅在訂單最終提交到 Firestore 時才會被加入。
    - UI 中不會即時反映外送費用，而是在按下提交按鈕後才會顯示。（因為在 OrderPickupMethodCell 當選擇 「外送服務」 會有 收費Label）
    - 不需要調整 CustomerDetailsManager 的 updatePickupMethod() 來處理外送費用，這樣可以保持資料結構簡單且減少不必要的複雜性。
 
 4. 比較與想法
 
    - 目前方式適合運費變化不大且需求較為簡單的情況，只在提交訂單時計算外送費用，減少了即時更新 UI 的負擔，便於維護。
    - 如果在 updatePickupMethod() 中設置運費，則可以即時顯示訂單的總金額變化，提高使用者的透明度，但也會帶來更多的開發與維護成本。
 
 5. 建議：
 
    - 如果不需要在 UI 中即時顯示外送費用，則保持目前的設計是簡潔且有效的。
    - 在訂單提交時計算費用不僅能簡化邏輯，也能減少維護工作量，因此不建議額外在 CustomerDetailsManager 中處理外送費用。

 */

import Foundation
import Firebase

/// 用於管理與驗證顧客資料
class CustomerDetailsManager {
    
    static let shared = CustomerDetailsManager()
    
    // MARK: - Properties
    
    var customerDetails: CustomerDetails?
    
    // MARK: - Methods

    /// 從 UserDetails 中填充初始的顧客資料
    /// - Parameter userDetails: 當前用戶的詳細資料
    ///
    /// 此方法根據當前使用者的資料（如姓名、電話等）來建立初始顧客資料，方便後續在訂單頁面自動填入欄位。
    func populateCustomerDetails(from userDetails: UserDetails) {
        self.customerDetails = CustomerDetails(
            fullName: userDetails.fullName,                               // 使用 UserDetails 的姓名作為預設顧客姓名
            phoneNumber: userDetails.phoneNumber ?? "",                   // 若未填寫，設置為空字符串，讓 UI 去處理提示
            pickupMethod: .homeDelivery,                                  // 預設取件方式為 "外送服務"，可根據需求調整
            address: userDetails.address,                                 // 若未填寫，設置為 nil
            storeName: nil,                                               // 店家名稱會根據取件方式選擇
            notes: nil                                                    // 備註欄位為選填
        )
        
        print("Populating customer details:")  // 增加觀察 populateCustomerDetails
        print("Full Name: \(userDetails.fullName)")
        print("Phone Number: \(userDetails.phoneNumber ?? "")")
        print("Address: \(userDetails.address ?? "")")
        print("Store Name: \(self.customerDetails?.storeName ?? "No Store Name Set")")
    }
    
    /// 獲取當前的顧客詳細資料
    /// - Returns: 顧客詳細資料
    ///
    /// 此方法用於從 manager 中取得當前的顧客詳細資料。
    func getCustomerDetails() -> CustomerDetails? {
        return customerDetails
    }
    
    /// 驗證顧客資料是否完整
    /// - Returns: 若資料完整返回 .success，否則返回具體的錯誤原因
    ///
    /// 驗證顧客資料是否已填寫必填項目，例如姓名、電話，以及若選擇 "宅配運送" 時需要填寫地址。
    func validateCustomerDetails() -> ValidationResult {
        guard let details = customerDetails else {
            return .failure(.missingDetails)
        }
        
        // 確保姓名和電話都有填寫
        if details.fullName.isEmpty {
            return .failure(.missingFullName)
        }
        
        if details.phoneNumber.isEmpty {
            return .failure(.missingPhoneNumber)
        }
        
        // 如果選擇宅配運送，需驗證地址是否有填寫
        if details.pickupMethod == .homeDelivery && (details.address?.isEmpty ?? true) {
            return .failure(.missingAddress)
        }
        
        // 如果選擇到店取件，需驗證店家名稱是否有填寫
        if details.pickupMethod == .inStore && (details.storeName?.isEmpty ?? true) {
            return .failure(.missingStoreName)
        }
        
        return .success
    }
    
    /// 更新顧客資料
    /// - Parameters:
    ///   - fullName: 新的顧客姓名
    ///   - phoneNumber: 新的顧客電話號碼
    ///   - address: 新的配送地址
    ///   - storeName: 新的取件店家名稱
    ///   - notes: 額外備註
    ///
    /// 此方法用於更新當前顧客的詳細資料，以便在下訂單之前能保持資料的最新狀態。
    func updateCustomerDetails(fullName: String?, phoneNumber: String?, address: String?, storeName: String?, notes: String?) {
        if let fullName = fullName {
            customerDetails?.fullName = fullName
            print("CustomerDetails 已更新姓名：\(fullName)")
        }
        if let phoneNumber = phoneNumber {
            customerDetails?.phoneNumber = phoneNumber
            print("CustomerDetails 已更新電話號碼：\(phoneNumber)")
        }
        if let address = address {
            customerDetails?.address = address
            print("CustomerDetails 已更新地址：\(address)")
        }
        if let storeName = storeName {
            customerDetails?.storeName = storeName
            print("CustomerDetails 已更新店家名稱：\(storeName)")
        }
        if let notes = notes {
            customerDetails?.notes = notes
            print("CustomerDetails 已更新備註內容：\(notes)")        // 觀察 note
        }
    }

    /// 更新取件方式
    ///
    /// 用於`更新顧客`的`取件方式`，以確保顧客資料的統一管理和資料同步。這樣不論在哪裡更改取件方式，都能保持資料的一致性。
    func updatePickupMethod(_ method: PickupMethod) {
        customerDetails?.pickupMethod = method
        print("CustomerDetails 已更新取件方式：\(method.rawValue)")         // 觀察取件方式
    }

}

// MARK: - Error

/// 驗證結果的 enum，用於描述顧客詳細資料的驗證結果
enum ValidationResult: Equatable {
    case success
    case failure(ValidationError)
}

/// 顧客資料驗證錯誤的 enum
enum ValidationError: String, Error, Equatable {
    case missingDetails = "顧客詳細資料缺失"
    case missingFullName = "顧客姓名未填寫"
    case missingPhoneNumber = "顧客電話號碼未填寫"
    case missingAddress = "宅配運送需要填寫配送地址"
    case missingStoreName = "到店取件需要選擇店家"
}
