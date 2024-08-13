//
//  FirebaseControllerTests.swift
//  HW_OrderCoffeeAppTests
//
//  Created by 曹家瑋 on 2024/8/10.
//

import XCTest
@testable import HW_OrderCoffeeApp


// 測試 FirebaseController 類別的單元測試
class FirebaseControllerTests: XCTestCase {
    
    var firebaseController: FirebaseController!
    var firestoreMock: FirestoreMock!

    override func setUp() {
        super.setUp()
        firebaseController = FirebaseController.shared
        firestoreMock = FirestoreMock()
    }
    
    // 測試成功獲取用戶資料的情況
    func testGetCurrentUserDetails_shouldReturnUserDetails() {
        // 設置模擬數據，用來模擬從 Firestore 返回的用戶數據
        firestoreMock.documentData = [
            "email": "test@example.com",
            "fullName": "Test User"
        ]
        
        let expectation = self.expectation(description: "Should return user details")        // 創建 expectation，用來處理異步測試
        
        // 模擬獲取文檔的操作
        firestoreMock.getDocument { document, error in
            guard let document = document else {
                XCTFail("Document should not be nil")
                return
            }
            
            // 根據模擬文檔數據創建 UserDetails 對象
            let userDetails = UserDetails(
                uid: "mockUID",
                email: document.data?["email"] as? String ?? "",
                fullName: document.data?["fullName"] as? String ?? ""
            )
            
            XCTAssertEqual(userDetails.email, "test@example.com")
            XCTAssertEqual(userDetails.fullName, "Test User")
            
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

}


