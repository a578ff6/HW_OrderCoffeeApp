//
//  GoogleSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/20.
//

/*

 * 測試 Google 部分：
 
  - [v] 先 Google 看有無真的存到資料，基本上要有資料。（資料修改沒問題）

 * Google 與 Email
 - [v] 先用 Email （a1202@gmail.com） 註冊登入， 在用 Google （a578ff6@gmail.com） ，基本上是兩個不同帳號。（資料修改沒問題）
 - [v] 先用 Email (a578ff6@gmail.com) 註冊登入，在用 Google （a578ff6@gmail.com） ，基本上會蓋過 Email。（資料修改沒問題）
 
 * Google 與 Apple
 - [v] 在已經有 Google（a578ff6@gmail.com） 的情況下，去使用 Apple （a578ff6@gmail.com） ，基本上兩者可以互相登入。（資料修改沒問題）

 * Google 與 Apple 隱藏
 - [v] 先使用 Apple 隱藏註冊中繼帳號，在使用 Google （a578ff6@gmail.com） 去註冊登入。基本上是不能鏈接的，只能各自登入。（資料修改沒問題）

 * Google 與 Apple 未隱藏
 - [v] 先使用 Apple （a578ff6@gmail.com） 註冊，在使用 Google （a578ff6@gmail.com） 去註冊登入。能互相登入。（資料修改沒問題）
 
 ------------------------- ------------------------- ------------------------- -------------------------
 
 A. 登入與註冊邏輯統一
 
    * 原始問題:
        - 最初只處理了Google的登入部分，忽略了註冊和登入在Firebase中的邏輯實際上是相同的。
        - 沒有存取用戶資料到Firestore，導致「找不到使用者資料」的問題。
 
    * 解決方案:
        - 登入和註冊的核心邏輯是一致的，無論是登入還是註冊，都需要在首次登入時將用戶資料存儲到Firestore。
        - 使用merge: true來確保每次登入時新資料不會覆蓋現有資料，而是進行合併。
 
 ------------------------- ------------------------- ------------------------- -------------------------

 B. Google SignIn功能的流程
    
    * signInWithGoogle:
        - 觸發Google的登入流程，取得clientID並配置Google Sign-In。
        - 成功登入後，直接使用Google憑證進行登入。

    * signInWithGoogleCredential:
        - 使用Google憑證進行登入，並在登入成功後將用戶資料存儲到Firestore。
 
    * storeGoogleUserData:
        - 將Google用戶資料存儲到Firestore。
        - 如果用戶資料已經存在，則更新其資料；否則，創建新的用戶資料。
 ------------------------- ------------------------- ------------------------- -------------------------

 */

// MARK: - 直接使用Google憑證登入
/*
import UIKit
import Firebase
import GoogleSignIn

/// 處理 Google 相關登入和註冊邏輯的 Controller
class GoogleSignInController {
    
    static let shared = GoogleSignInController()
    
    // MARK: - Public Methods
    
    /// 使用 Google 進行登入或註冊
    /// - Parameters:
    ///   - presentingViewController: 進行 Google 登入的視圖控制器
    ///   - completion: 完成時的回調，返回結果為成功的 AuthDataResult 或錯誤
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "GoogleSignInController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID is missing."])))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("Google 登入錯誤：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "GoogleSignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Google user or ID token."])))
                return
            }
            
            print("Google 登入成功，用戶：\(user.profile?.name ?? "未知"), 電子郵件：\(user.profile?.email ?? "未知")")
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            // 直接使用 Google 憑證進行登入
            self.signInWithGoogleCredential(credential, completion: completion)
        }
    }
    
    // MARK: - Private Methods
    
    /// 使用 Google 憑證進行登入
    /// - Parameters:
    ///   - credential: Google 的認證憑證
    ///   - completion: 完成時的回調，返回結果為成功的 AuthDataResult 或錯誤
    private func signInWithGoogleCredential(_ credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("使用 Google 憑證登入失敗：\(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                print("使用 Google 憑證登入成功")
                self.storeGoogleUserData(authResult: authResult) { result in
                    switch result {
                    case .success:
                        completion(.success(authResult))
                    case .failure(let error):
                        print("儲存 Google 使用者資料時發生錯誤：\(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    /// 將 Google 使用者資料存儲到 Firestore
    /// - Parameters:
    ///   - authResult: Firebase 認證結果
    ///   - completion: 完成時的回調，返回結果為成功或錯誤
    private func storeGoogleUserData(authResult: AuthDataResult, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists, var userData = document.data() {
                // 如果 document 已存在，則僅在 fullName 欄位為空時更新全名
                if let displayName = user.displayName, userData["fullName"] as? String == "" {
                    print("更新已存在的使用者資料，Google 顯示名稱：\(displayName)")
                    userData["fullName"] = displayName
                }
                userData["loginProvider"] = "google"
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        print("更新使用者資料失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("使用者資料更新成功")
                        completion(.success(()))
                    }
                }
            } else {
                // 如果 document 不存在，則建立新的資料
                var userData: [String: Any] = [
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "loginProvider": "google"
                ]
                
                if let displayName = user.displayName {
                    print("創建新使用者資料，Google 顯示名稱：\(displayName)")
                    userData["fullName"] = displayName
                }
                
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        print("創建使用者資料失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("創建使用者資料成功")
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
*/





// MARK: - 直接使用Google憑證登入（async/await）

import UIKit
import Firebase
import GoogleSignIn

/// 處理 Google 相關登入和註冊邏輯的 Controller
class GoogleSignInController {
    
    static let shared = GoogleSignInController()
    
    // MARK: - Public Methods
    
    /// 使用 Google 進行登入或註冊
    /// - Parameters:
    ///   - presentingViewController: 進行 Google 登入的視圖控制器
    /// - Throws: 如果登入過程中發生錯誤，會拋出對應的錯誤
    /// - Returns: 登入成功的 `AuthDataResult`，包含用戶資料
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> AuthDataResult {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "GoogleSignInController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID is missing."])
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 使用 `withCheckedThrowingContinuation` 來將 Google Sign-In 轉換為 async/await 模式
        let result: (GIDGoogleUser, String) = try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = result?.user, let idToken = user.idToken?.tokenString {
                    continuation.resume(returning: (user, idToken))
                } else {
                    continuation.resume(throwing: NSError(domain: "GoogleSignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Google user or ID token."]))
                }
            }
        }
        
        // 解構獲取的結果，並創建 Google 憑證
        let (user, idToken) = result
        
        print("Google 登入成功，用戶：\(user.profile?.name ?? "未知"), 電子郵件：\(user.profile?.email ?? "未知")")
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        // 使用 Google 憑證進行 Firebase 登入
        return try await signInWithGoogleCredential(credential)
    }
    
    // MARK: - Private Methods
    
    /// 使用 Google 憑證進行 Firebase 登入
    /// - Parameter credential: Google 的認證憑證
    /// - Throws: 登入過程中的任何錯誤
    /// - Returns: 登入成功的 `AuthDataResult`
    private func signInWithGoogleCredential(_ credential: AuthCredential) async throws -> AuthDataResult {
        
        let authResult = try await Auth.auth().signIn(with: credential)
        
        // 保存 Google 用戶數據到 Firestore
        print("使用 Google 憑證登入成功")
        try await storeGoogleUserData(authResult: authResult)
        
        return authResult
    }
    
    /// 將 Google 使用者資料存儲到 Firestore
    /// - Parameter authResult: Firebase 認證結果
    /// - Throws: 儲存過程中的任何錯誤
    private func storeGoogleUserData(authResult: AuthDataResult) async throws {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        let document = try await userRef.getDocument()
        if document.exists, var userData = document.data() {
            // 如果 document 已存在，則僅在 fullName 欄位為空時更新全名
            if let displayName = user.displayName, userData["fullName"] as? String == "" {
                print("更新已存在的使用者資料，Google 顯示名稱：\(displayName)")
                userData["fullName"] = displayName
            }
            userData["loginProvider"] = "google"
            try await userRef.setData(userData, merge: true)
            
        } else {
            // 如果 document 不存在，則建立新的資料
            var userData: [String: Any] = [
                "uid": user.uid,
                "email": user.email ?? "",
                "loginProvider": "google"
            ]
            
            if let displayName = user.displayName {
                print("創建新使用者資料，Google 顯示名稱：\(displayName)")
                userData["fullName"] = displayName
            }
            
            try await userRef.setData(userData, merge: true)
        }
    }
    
}





// MARK: - fetchSignInMethods 運用： Google 可以用相同的信箱帳號去鏈接已經由 Apple 、Email 註冊的相同信箱帳號。並且不會出現重複錯誤問題。（鏈接問題）
/*
import UIKit
import Firebase
import GoogleSignIn

/// 處理 Google 相關登入和註冊邏輯的 Controller
class GoogleSignInController {
    
    static let shared = GoogleSignInController()
    
    // MARK: - Public Methods
    
    /// 使用 Google 進行登入或註冊
    /// - Parameters:
    ///   - presentingViewController: 進行 Google 登入的視圖控制器
    ///   - completion: 完成時的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "GoogleSignInController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID is missing."])))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("Google 登入錯誤：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "GoogleSignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Google user or ID token."])))
                return
            }
            
            print("Google 登入成功，用戶：\(user.profile?.name ?? "未知"), 電子郵件：\(user.profile?.email ?? "未知")")
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            // 檢查該電子郵件是否已經存在於 Firebase 中
            self.handleExistingAccount(email: user.profile?.email ?? "", credential: credential, completion: completion)
        }
    }
    
    
    // MARK: - Private Methods
    
    /// 處理已存在的帳號，決定是直接登入還是嘗試鏈結 Google 憑證
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - credential: Google 的認證憑證
    ///   - completion: 完成時的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    private func handleExistingAccount(email: String, credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("檢查 Firebase 中是否已存在該電子郵件：\(email)")
        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
            if let error = error {
                print("檢查登入方法時發生錯誤：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let signInMethods = signInMethods, !signInMethods.isEmpty {
                self.handleSignInMethods(signInMethods, email: email, credential: credential, completion: completion)
            } else {
                print("沒有找到現有帳號，直接使用 Google 憑證登入。")
                self.signInWithGoogleCredential(credential, completion: completion)
            }
        }
    }

    /// 根據不同的登入方法進行處理
    /// - Parameters:
    ///   - signInMethods: 使用者的登入方法
    ///   - email: 使用者的電子郵件地址
    ///   - credential: Google 的認證憑證
    ///   - completion: 完成時的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    private func handleSignInMethods(_ signInMethods: [String], email: String, credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        if signInMethods.contains(GoogleAuthProviderID) {
            print("找到現有帳號，並且已經使用 Google 登入過，直接登入。")
            self.signInWithGoogleCredential(credential, completion: completion)
        } else {
            print("找到現有帳號，嘗試鏈結 Google 憑證。")
            self.linkGoogleCredentialToExistingAccount(email: email, credential: credential, completion: completion)
        }
    }
    
    /// 將 Google 憑證鏈接到現有帳號
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - credential: Google 的認證憑證
    ///   - completion: 完成時的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    private func linkGoogleCredentialToExistingAccount(email: String, credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("當前沒有已登入的使用者，無法鏈結 Google 憑證，直接嘗試使用 Google 憑證登入。")
            self.signInWithGoogleCredential(credential, completion: completion)
            return
        }
        
        print("嘗試將 Google 憑證鏈結到現有帳號：\(email)")
        currentUser.link(with: credential) { authResult, error in
            if let error = error as NSError?, error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                print("鏈接 Google 憑證失敗：提供方已經鏈接過該帳號，嘗試直接登入。")
                self.signInWithGoogleCredential(credential, completion: completion)
            } else if let authResult = authResult {
                print("鏈接 Google 憑證成功")
                self.storeGoogleUserData(authResult: authResult) { result in
                    switch result {
                    case .success:
                        completion(.success(authResult))
                    case .failure(let error):
                        print("儲存 Google 使用者資料時發生錯誤：\(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    /// 使用 Google 憑證進行登入
    /// - Parameters:
    ///   - credential: Google 的認證憑證
    ///   - completion: 完成時的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    private func signInWithGoogleCredential(_ credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("使用 Google 憑證登入失敗：\(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                print("使用 Google 憑證登入成功")
                self.storeGoogleUserData(authResult: authResult) { result in
                    switch result {
                    case .success:
                        completion(.success(authResult))
                    case .failure(let error):
                        print("儲存 Google 使用者資料時發生錯誤：\(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    /// 將 Google 使用者資料存儲到 Firestore
    /// - Parameters:
    ///   - authResult: Firebase 認證結果
    ///   - completion: 完成時的回調，返回結果為成功或錯誤
    private func storeGoogleUserData(authResult: AuthDataResult, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists, var userData = document.data() {
                // 如果 document 已存在，則僅在 fullName 欄位為空時更新全名
                if let displayName = user.displayName, userData["fullName"] as? String == "" {
                    print("更新已存在的使用者資料，Google 顯示名稱：\(displayName)")
                    userData["fullName"] = displayName
                }
                userData["loginProvider"] = "google"
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        print("更新使用者資料失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("使用者資料更新成功")
                        completion(.success(()))
                    }
                }
            } else {
                // 如果 document 不存在，則建立新的資料
                var userData: [String: Any] = [
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "loginProvider": "google"
                ]
                
                if let displayName = user.displayName {
                    print("創建新使用者資料，Google 顯示名稱：\(displayName)")
                    userData["fullName"] = displayName
                }
                
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        print("創建使用者資料失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("創建使用者資料成功")
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
*/
