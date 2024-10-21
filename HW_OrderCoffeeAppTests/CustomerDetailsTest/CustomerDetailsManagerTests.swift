//
//  CustomerDetailsManagerTests.swift
//  HW_OrderCoffeeAppTests
//
//  Created by 曹家瑋 on 2024/10/10.
//

/*
 ## 重點筆記
 
    1.測試設置 (setUpWithError())：
        - 在每個測試之前清空 CustomerDetailsManager 的資料，以確保測試之間的獨立性。
 
    2.顧客資料填充測試 (testPopulateCustomerDetails())：
        - 驗證 populateCustomerDetails() 方法能否正確地將 UserDetails 中的資料填充到 CustomerDetails 中。
        - 使用 XCTAssertEqual 驗證填充後的資料是否正確。
 
    3.資料完整性驗證測試 (testValidateCustomerDetails_success())：
        - 測試資料完全填寫的情況，應該返回 .success。
    
    4.資料缺失驗證測試 (testValidateCustomerDetails_missingPhoneNumber(), testValidateCustomerDetails_missingAddress())：
        - 測試當必填資料（如 phoneNumber 或 address）缺失時，是否正確返回對應的錯誤結果。
        - 利用 XCTAssertEqual 驗證結果是否為 .failure，並且錯誤原因是否正確。
 
    5.總結
        - 在測試中，由於 phoneNumber 和 fullName 被設為必填項，因此不能為 nil，這有助於確保顧客資料的完整性。
        - 在資料填充過程中使用空字符串或 nil 來表示缺少資料，然後在 UI 中做進一步提示或補充，是更靈活的設計方式。
 */


import XCTest
@testable import HW_OrderCoffeeApp

class CustomerDetailsManagerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // 初始化 CustomerDetailsManager，清空之前的顧客資料
        CustomerDetailsManager.shared.customerDetails = nil
    }

    /// 測試從 UserDetails 填充顧客資料的功能
    func testPopulateCustomerDetails() {
        let userDetails = UserDetails(
            uid: "123",
            email: "test@example.com",
            fullName: "測試用戶",
            profileImageURL: nil,
            phoneNumber: "0987654321",
            birthday: nil,
            address: "台北市某街道",
            gender: nil,
            orders: [],
            favorites: []
        )
        
        // 使用 userDetails 填充顧客資料
        CustomerDetailsManager.shared.populateCustomerDetails(from: userDetails)
        
        let customerDetails = CustomerDetailsManager.shared.getCustomerDetails()
        
        // 驗證顧客資料是否正確填充
        XCTAssertNotNil(customerDetails)                                     // 檢查顧客資料不為空
        XCTAssertEqual(customerDetails?.fullName, "測試用戶")                 // 驗證顧客姓名
        XCTAssertEqual(customerDetails?.phoneNumber, "0987654321")          // 驗證顧客電話
        XCTAssertEqual(customerDetails?.address, "台北市某街道")              // 驗證顧客地址
    }
    
    /// 測試顧客資料完整性驗證（成功的情況）
    func testValidateCustomerDetails_success() {
        let customerDetails = CustomerDetails(
            fullName: "測試用戶",
            phoneNumber: "0987654321",
            pickupMethod: .homeDelivery,
            address: "台北市某街道",
            storeName: nil,
            notes: nil
        )
        
        CustomerDetailsManager.shared.customerDetails = customerDetails
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        
        XCTAssertEqual(validationResult, .success)           // 驗證應返回 .success 表示資料完整
    }
    
    /// 測試顧客資料驗證失敗的情況 - 缺少電話號碼
    func testValidateCustomerDetails_missingPhoneNumber() {
        let customerDetails = CustomerDetails(
            fullName: "測試用戶",
            phoneNumber: "",                    // 注意：因為 phoneNumber 是非可選，所以不能是 nil，而是空字符串
            pickupMethod: .inStore,
            address: nil,
            storeName: nil,
            notes: nil
        )
        
        CustomerDetailsManager.shared.customerDetails = customerDetails
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        
        XCTAssertEqual(validationResult, .failure(.missingPhoneNumber))          // 應返回 .failure，並指出缺少電話號碼
    }
    
    /// 測試顧客資料驗證失敗的情況 - 缺少地址（宅配運送）
    func testValidateCustomerDetails_missingAddress() {
        let customerDetails = CustomerDetails(
            fullName: "測試用戶",
            phoneNumber: "0987654321",
            pickupMethod: .homeDelivery,    // 選擇宅配運送
            address: nil,                   // 地址未填寫
            storeName: nil,
            notes: nil
        )
        
        CustomerDetailsManager.shared.customerDetails = customerDetails
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        
        XCTAssertEqual(validationResult, .failure(.missingAddress))     // 應返回 .failure，並指出缺少地址
    }
}


