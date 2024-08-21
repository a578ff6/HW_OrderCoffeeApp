//
//  FirebaseControllerTests.swift
//  HW_OrderCoffeeAppTests
//
//  Created by 曹家瑋 on 2024/8/10.
//

import XCTest
import Firebase
@testable import HW_OrderCoffeeApp

class FirebaseControllerTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        
        // 配置 Firebase 使用模擬器
        let firestoreSettings = Firestore.firestore().settings
        firestoreSettings.host = "127.0.0.1:8080"
        firestoreSettings.cacheSettings = MemoryCacheSettings()
        firestoreSettings.isSSLEnabled = false
        Firestore.firestore().settings = firestoreSettings
        
        let authSettings = Auth.auth().settings
        authSettings?.isAppVerificationDisabledForTesting = true
        Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
        
        // 初始化 Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    override func tearDown() {
        // 清理 Firebase 狀態
        try? Auth.auth().signOut()
        super.tearDown()
    }
    
    func testGetCurrentUserDetails_withLoggedInUser_shouldSucceed() {
        let email = "test@example.com"
        let password = "Test@1234"
        let fullName = "Test User"

          let expectation = self.expectation(description: "Should successfully get user details")
          
        // 登錄用戶
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let _ = authResult?.user else {
                XCTFail("Failed to sign in user")
                return
            }
            
            // 測試 FirebaseController 的 getCurrentUserDetails 方法
            FirebaseController.shared.getCurrentUserDetails { result in
                switch result {
                case .success(let userDetails):
                    XCTAssertEqual(userDetails.email, email)
                    XCTAssertEqual(userDetails.fullName, fullName)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to get user details: \(error.localizedDescription)")
                }
            }
        }
          
          waitForExpectations(timeout: 10, handler: nil)
      }
    
}

