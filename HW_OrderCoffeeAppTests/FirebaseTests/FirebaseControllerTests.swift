//
//  FirebaseControllerTests.swift
//  HW_OrderCoffeeAppTests
//
//  Created by 曹家瑋 on 2024/8/10.
//


// MARK: - async/await

/*
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
        let _ = Storage.storage().useEmulator(withHost: "127.0.0.1", port: 9199)
        
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
    
    /*
    /// 建立新用戶的測試
    func testCreateUser_withEmailAndPassword_shouldSucceed() async {
        let email = "test_create@example.com"
        let password = "Test@1234"

        do {
            // 創建新用戶
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            XCTAssertNotNil(authResult.user, "Failed to create user")
            
            // 在 Firestore 中設置新用戶的初始資料
            let fullName = "Test Create User"
            let userRef = Firestore.firestore().collection("users").document(authResult.user.uid)
            try await userRef.setData([
                "email": email,
                "fullName": fullName,
                "phoneNumber": "123456789",
                "address": "Test Address"
            ])
            
        } catch {
            XCTFail("Failed to create user: \(error.localizedDescription)")
        }
    }
    */
    
    
    /// 取得當前使用者登入資訊的測試
    func testGetCurrentUserDetails_withCreatedUser_shouldSucceed() async {
        let email = "test_create@example.com"
        let password = "Test@1234"
        let fullName = "Test Create User"
        
        do {
            // 登錄用戶
            let _ = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // 測試 FirebaseController 的 getCurrentUserDetails 方法
            let userDetails = try await FirebaseController.shared.getCurrentUserDetails()
            XCTAssertEqual(userDetails.email, email)
            XCTAssertEqual(userDetails.fullName, fullName)
        } catch {
            XCTFail("Failed to get user details: \(error.localizedDescription)")
        }
    }
    
    /// 針對大頭照上傳和 URL 更新的測試
    func testUpdateUserProfileImageURL_shouldUpdateFirestore() async {
        let testURL = "http://example.com/test-uid.jpg"
        let uid = "RgnhI9WEKdkN4jo21Cn0aosqjkkc" // 使用從測試中獲得的 UID（會變動）
        
        do {
            // 更新 Firestore 中的用戶圖片 URL
            try await FirebaseController.shared.updateUserProfileImageURL(testURL, for: uid)
            
            // 確認 Firestore 是否更新了 URL
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(uid)
            let document = try await userRef.getDocument()
            let url = document.data()?["profileImageURL"] as? String
            XCTAssertEqual(url, testURL)
        } catch {
            XCTFail("Failed to update Firestore: \(error.localizedDescription)")
        }
    }
    
}
*/
