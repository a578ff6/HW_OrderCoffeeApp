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
            pickupMethod: .inStore,                                       // 預設取件方式為 "到店取件"，可根據需求調整
            address: userDetails.address,                                 // 若未填寫，設置為 nil
            storeName: nil,                                               // 店家名稱會根據取件方式選擇
            notes: nil                                                    // 備註欄位為選填
        )
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
        }
        if let phoneNumber = phoneNumber {
            customerDetails?.phoneNumber = phoneNumber
        }
        if let address = address {
            customerDetails?.address = address
        }
        if let storeName = storeName {
            customerDetails?.storeName = storeName
        }
        if let notes = notes {
            customerDetails?.notes = notes
        }
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
}
