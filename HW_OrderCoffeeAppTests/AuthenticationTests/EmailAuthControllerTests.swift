//
//  EmailAuthControllerTests.swift
//  HW_OrderCoffeeAppTests
//
//  Created by 曹家瑋 on 2024/8/19.
//

// MARK: - async/await

 import XCTest
 import Firebase
 @testable import HW_OrderCoffeeApp

class EmailAuthControllerTests: XCTestCase {
    
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
    /*
    func testRegisterUser_withNewEmail_shouldSucceed() async {
        let email = "test@example.com"
        let password = "Test@1234"
        let fullName = "Test User"
        
        do {
            let authResult = try await EmailAuthController.shared.registerUser(withEmail: email, password: password, fullName: fullName)
            XCTAssertEqual(authResult.user.email, email)
        } catch {
            XCTFail("Registration should succeed, but failed with error: \(error.localizedDescription)")
        }
    }
    */
    
    /*
    func testLoginUser_withValidCredentials_shouldSucceed() async {
        let email = "test@example.com"
        let password = "Test@1234"
        
        // 先註冊一個用戶
        do {
            _ = try await EmailAuthController.shared.registerUser(withEmail: email, password: password, fullName: "Test User")
        } catch {
            XCTFail("Failed to register user for login test: \(error.localizedDescription)")
            return
        }
        
        // 測試登入
        do {
            let authResult = try await EmailAuthController.shared.loginUser(withEmail: email, password: password)
            XCTAssertEqual(authResult.user.email, email)
        } catch {
            XCTFail("Login should succeed with valid credentials, but failed with error: \(error.localizedDescription)")
        }
    }
     */

    func testLoginUser_withInvalidCredentials_shouldFail() async {
        let email = "invalid@example.com"
        let password = "WrongPassword"
        
        do {
            _ = try await EmailAuthController.shared.loginUser(withEmail: email, password: password)
            XCTFail("Login should fail with invalid credentials, but succeeded")
        } catch let error as NSError {
            XCTAssertEqual(error.code, AuthErrorCode.userNotFound.rawValue)
        } catch {
            XCTFail("Unexpected error occurred: \(error.localizedDescription)")
        }
    }
    
}
