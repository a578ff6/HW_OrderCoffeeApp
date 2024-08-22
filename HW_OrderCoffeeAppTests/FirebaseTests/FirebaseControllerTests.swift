//
//  FirebaseControllerTests.swift
//  HW_OrderCoffeeAppTests
//
//  Created by 曹家瑋 on 2024/8/10.
//

import XCTest
import Firebase
import FirebaseStorage
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
        
        // 使用 Storage 模擬器
        let storageSettings = Storage.storage().useEmulator(withHost: "127.0.0.1", port: 9199)

        
        
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
    
    /// 取得當前使用者登入資訊的測試
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
    
    /// 針對大頭照上傳和 URL 更新的測試
    func testUpdateUserProfileImageURL_shouldUpdateFirestore() {
        let expectation = self.expectation(description: "Should update Firestore with image URL")
        let testURL = "http://example.com/test-uid.jpg"
        let uid = "B5yXvl9sZMDfu4yk1bMBKQsiIQLA" // 使用從 testRegisterUser_withNewEmail_shouldSucceed 測試中獲得的 UID（會變動）
        
        FirebaseController.shared.updateUserProfileImageURL(testURL, for: uid) { result in
            switch result {
            case .success():
                // 確認 Firestore 是否更新了 URL
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(uid)
                userRef.getDocument { document, error in
                    if let document = document, document.exists {
                        let url = document.data()?["profileImageURL"] as? String
                        XCTAssertEqual(url, testURL)
                        expectation.fulfill()
                    } else {
                        XCTFail("Failed to retrieve document or document does not exist")
                    }
                }
            case .failure(let error):
                XCTFail("Failed to update Firestore: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
