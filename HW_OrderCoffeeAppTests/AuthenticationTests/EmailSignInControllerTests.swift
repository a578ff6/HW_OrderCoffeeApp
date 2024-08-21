//
//  EmailSignInControllerTests.swift
//  HW_OrderCoffeeAppTests
//
//  Created by 曹家瑋 on 2024/8/19.
//

import XCTest
import Firebase
@testable import HW_OrderCoffeeApp

class EmailSignInControllerTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        // 配置 Firebase 並使用模擬器
        let firestoreSettings = Firestore.firestore().settings
        firestoreSettings.host = "127.0.0.1:8080"
        firestoreSettings.cacheSettings = MemoryCacheSettings()
        firestoreSettings.isSSLEnabled = false
        Firestore.firestore().settings = firestoreSettings
        
        // 配置 Auth 並使用模擬器
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

    // MARK: - 測試範例
    
    func testRegisterUser_withNewEmail_shouldSucceed() {
        let email = "test@example.com"
        let password = "Test@1234"
        let fullName = "Test User"
        
        let expectation = self.expectation(description: "Should successfully register user")
        
        EmailSignInController.shared.registerUser(withEmail: email, password: password, fullName: fullName) { result in
            switch result {
            case .success(let authResult):
                XCTAssertEqual(authResult.user.email, email)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Registration should succeed, but failed with error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoginUser_withValidCredentials_shouldSucceed() {
        let email = "test@example.com"
        let password = "Test@1234"
        
        // 先註冊一個用戶
        let registerExpectation = self.expectation(description: "Should register user for login test")
        EmailSignInController.shared.registerUser(withEmail: email, password: password, fullName: "Test User") { _ in
            registerExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        // 測試登入
        let loginExpectation = self.expectation(description: "Should succeed with valid credentials")
        EmailSignInController.shared.loginUser(withEmail: email, password: password) { result in
            switch result {
            case .success(let authResult):
                XCTAssertEqual(authResult.user.email, email)
                loginExpectation.fulfill()
            case .failure(let error):
                XCTFail("Login should succeed with valid credentials, but failed with error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoginUser_withInvalidCredentials_shouldFail() {
        let email = "invalid@example.com"
        let password = "WrongPassword"
        
        let expectation = self.expectation(description: "Should fail with invalid credentials")
        
        EmailSignInController.shared.loginUser(withEmail: email, password: password) { result in
            switch result {
            case .success:
                XCTFail("Login should fail with invalid credentials, but succeeded")
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, AuthErrorCode.userNotFound.rawValue)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}



