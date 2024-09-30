//
//  AppleSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/29.
//


/*
 
 * 測試 Apple 部分

 * Apple 不隱藏與 Email
 - [v] 先 Apple 看有無真的存到資料，基本上要有資料。（資料修改沒問題）
 - [v] 先用 Email（a1202@gmail.com） 註冊登入，在用 Apple （a578ff6@gmail.com） ，基本上是兩個不同帳號。（資料修改沒問題）
 - [v] 先用 Email (a578ff6@gmail.com) 註冊登入，在用Apple （a578ff6@gmail.com） ，基本上會蓋過Email。（資料修改沒問題）
     - [v] 接著使用 Apple （a578ff6@gmail.com） ，在使用Goolge (a578ff6@gmail.com) ，基本上兩者可以互相登入。（資料修改沒問題）

 * Apple隱藏與email
 - [v] 先隱藏 Apple 看有無真的存到資料，基本上要有資料。（資料修改沒問題）
 - [v] Email（a578ff6@gmail.com） 跟隱藏 （a578ff6@gmail.com） Apple ，基本上要不能覆蓋並且可以各自登入才是正確。（資料修改沒問題）
 - [v] 先註冊 a1202@gmail.com ，在使用隱藏 Apple ，基本上不能夠覆蓋才是正確。（資料修改沒問題）
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 A. 獲取並存儲 fullName
 
    * 問題描述:
        - 在最初的測試過程中，未能成功存取使用者的fullName，導致用戶資料不完整。
        - Firebase 官方文件建議使用appleCredential(withIDToken:rawNonce:fullName:)來傳遞fullName給Firebase，以確保用戶授權時的名字能夠正確存取。
 
    * 解決方案:
        - 在authorizationController中，使用OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:)來初始化憑證，並將fullName傳遞給Firebase。
        - 更新storeAppleUserData方法，將fullName包含在使用者資料中，以便在首次註冊時正確存取用戶的名字。
 
 
    * 結論:
        - 確保在首次註冊時，使用OAuthProvider.appleCredential傳遞用戶的fullName給Firebase。
        - 在儲存用戶資料時，包括fullName，以確保用戶資料完整。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 B. Apple 登入的特性
 
    * 問題描述:
        - Apple ID 登入只在首次註冊時返回完整的用戶資訊（名字和電子郵件）。再次登入時，Apple 不會再次提供這些資訊，因此可能導致資料庫中的名字變成空白。
 
    * 解決方案:
        - 在首次註冊時，確保完整地存取和儲存用戶的fullName和電子郵件。
        - 在再次登入時，從Firebase數據庫中讀取用戶的名字和其他資料，而不是依賴於Apple再次提供。
 
    * 結論:
        - 首次註冊時完整存取用戶資料，再次登入時從Firebase中獲取資料，以避免fullName丟失。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 C. 多重登入方式下的資料覆蓋問題
    
    * 問題描述:
        - 當用戶使用相同電子郵件透過不同登入方式（如Apple和Google）登入時，會發生資料覆蓋問題，特別是fullName。
 
    * 解決方案:
        - 在儲存用戶資料時，避免覆蓋已存在的fullName，僅在fullName為空時更新。
        - 在用戶資料中加入loginProvider，記錄每次登入的方式，以便後續處理時區分不同的登入方式。
    
    * 結論:
        - 通過避免覆蓋已存在的資料和加入loginProvider，來防止用戶資料在不同登入方式之間被覆蓋。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 D. 流程分析
 
    * signInWithApple:
        - 發起Apple登入請求，並在授權完成後處理結果。

    * createAppleIDRequest:
        - 建立Apple ID請求，包含請求的範疇（如fullName和email）。
 
    * authorizationController(didCompleteWithAuthorization:):
        - 處理授權成功後的邏輯，檢查用戶的電子郵件是否已存在於Firebase中，並進行相應處理。
 
    * signInWithAppleCredential:
        - 使用Apple憑證進行登入，並在成功後儲存用戶資料。
 
    * storeAppleUserData:
        - 將用戶資料儲存到Firebase。若資料已存在，僅在fullName為空時更新fullName，並記錄loginProvider。

 ---------------------------------------- ---------------------------------------- ----------------------------------------

 F. AppleSignInController 中的 Apple ID 隱藏電子郵件處理
 
 ## Apple 提供的兩種電子郵件選擇
    
    * 公開真實電子郵件地址:
        - 用戶選擇公開真實的電子郵件地址時，應用程序將直接使用此電子郵件來創建或鏈接Firebase帳戶。

    * 隱藏的中繼信箱（Relay Email）:
        - 如果用戶選擇隱藏其真實的電子郵件地址，Apple 會為該用戶生成一個隱藏的中繼信箱 （例如：12345abcde@privaterelay.appleid.com） ，這個中繼信箱會將所有郵件轉發到用戶的真實信箱。
        - 因此，當用戶使用隱藏信箱登入時，應用接收到的將是這個隱藏的中繼信箱。
 
 ## 處理隱藏信箱的邏輯
 
    * 電子郵件檢查:
        - 當 AppleSignInController 接收到 Apple ID 的登入回應時，不論是隱藏的中繼信箱還是真實的電子郵件地址，系統都會檢查這個電子郵件是否已經存在於 Firebase 中。
 
 ## 隱藏信箱的特色
 
    * 隱私保護:
        - Apple 生成的隨機中繼信箱會自動轉發所有來自應用的郵件到用戶的真實信箱，從而保護用戶的隱私。
 
    * 唯一性:
        - 每個中繼信箱對應於單一應用，即使同一用戶在不同應用中選擇隱藏其真實郵件，生成的中繼信箱也會不同。
 */


// MARK: - 直接使用 Apple 憑證登入
/*
import UIKit
import Firebase
import AuthenticationServices
import CryptoKit

/// 處理 Apple 登入相關的 Controller
class AppleSignInController: NSObject {
    
    static let shared = AppleSignInController()
    
    // MARK: - Property

    private var currentNonce: String?
    private var signInCompletion: ((Result<AuthDataResult, Error>) -> Void)?

    
    // MARK: - Public Methods

    /// 使用 Apple 進行登入
    /// - Parameters:
    ///   - presentingViewController: 執行 Apple 登入的視圖控制器
    ///   - completion: 登入完成後的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    func signInWithApple(presentingViewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("開始 Apple 登入流程")
        self.signInCompletion = completion
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Private Methods

    /// 建立 Apple ID 請求
    /// - Returns: 已配置好的 Apple ID 請求
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        print("建立 Apple ID 請求")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        return request
    }
 
    /// 使用 Apple 憑證進行登入
    /// - Parameters:
    ///   - credential: Apple 的認證憑證
    ///   - fullName: 使用者的全名（可選）
    ///   - completion: 完成後的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    private func signInWithAppleCredential(_ credential: AuthCredential, fullName: PersonNameComponents?, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("使用 Apple 憑證登入。")
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("使用 Apple 憑證登入時發生錯誤：\(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                print("Apple 登入成功，UID：\(authResult.user.uid)")
                self.storeAppleUserData(authResult: authResult, fullName: fullName, completion: { result in
                    switch result {
                    case .success:
                        print("成功儲存用戶資料。")
                        completion(.success(authResult))
                    case .failure(let error):
                        print("儲存用戶資料時發生錯誤：\(error.localizedDescription)")
                        completion(.failure(error))
                    }
                })
            }
        }
    }
 
    /// 儲存 Apple 使用者資料到 Firestore
    /// - Parameters:
    ///   - authResult: Firebase 認證結果
    ///   - fullName: 使用者的全名（可選）
    ///   - completion: 完成後的回調，返回結果為成功或錯誤
    private func storeAppleUserData(authResult: AuthDataResult, fullName: PersonNameComponents?, completion: @escaping (Result<Void, Error>) -> Void) {
         print("開始儲存用戶資料到 Firestore。")
         let db = Firestore.firestore()
         let user = authResult.user
         let userRef = db.collection("users").document(user.uid)
         
         userRef.getDocument { (document, error) in
             if let document = document, document.exists, var userData = document.data() {
                 print("用戶資料已存在，更新資料。")
                 if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                     if userData["fullName"] as? String == "" {
                         userData["fullName"] = "\(familyName) \(givenName)"
                     }
                 }
                 userData["loginProvider"] = "apple"
                 userRef.setData(userData, merge: true) { error in
                     if let error = error {
                         print("更新用戶資料時發生錯誤：\(error.localizedDescription)")
                         completion(.failure(error))
                     } else {
                         print("成功更新用戶資料。")
                         completion(.success(()))
                     }
                 }
                 
             } else {
                 print("用戶資料不存在，創建新資料。")
                 var userData: [String: Any] = [
                     "uid": user.uid,
                     "email": user.email ?? "",
                     "loginProvider": "apple"
                 ]
                 
                 if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                     userData["fullName"] = "\(familyName) \(givenName)"
                 }
                 
                 userRef.setData(userData, merge: true) { error in
                     if let error = error {
                         print("創建用戶資料時發生錯誤：\(error.localizedDescription)")
                         completion(.failure(error))
                     } else {
                         print("成功創建用戶資料。")
                         completion(.success(()))
                     }
                 }
             }
         }
     }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInController: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供 Apple 登入的展示視窗
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    // MARK: - Private Helper Methods

    /// 生成隨機的 nonce 字串
    /// - Parameter length: nonce 字串的長度，預設為 32
    /// - Returns: 隨機的 nonce 字串
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    /// 對輸入字串進行 SHA256 編碼
    /// - Parameter input: 要編碼的字串
    /// - Returns: 編碼後的字串
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInController: ASAuthorizationControllerDelegate {
    
    /// Apple 登入成功時的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
                         
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // 直接使用 Apple 憑證進行登入
            self.signInWithAppleCredential(credential, fullName: appleIDCredential.fullName, completion: self.signInCompletion!)
        }
    }
    
    /// Apple 登入失敗時的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("Sign in with Apple errored: \(error)")
        self.signInCompletion?(.failure(error))
    }
}
*/



// MARK: - 直接使用 Apple 憑證登入（async/await）
import UIKit
import Firebase
import AuthenticationServices
import CryptoKit

/// 處理 Apple 登入相關的 Controller
class AppleSignInController: NSObject {
    
    static let shared = AppleSignInController()
    
    // MARK: - Property
    
    private var currentNonce: String?
    private var continuation: CheckedContinuation<AuthDataResult, Error>?

    
    // MARK: - Public Methods
    
    /// 使用 Apple 進行登入
    /// - Parameters:
    ///   - presentingViewController: 目前的視圖控制器，Apple 登入畫面會顯示於此視窗上
    /// - Throws: 如果登入過程中發生錯誤，會拋出對應的錯誤
    /// - Returns: 登入成功的 `AuthDataResult`，包含用戶資料
    func signInWithApple(presentingViewController: UIViewController) async throws -> AuthDataResult {
        print("開始 Apple 登入流程")
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        /// 使用 `withCheckedThrowingContinuation` 將 ASAuthorizationController 登入流程轉換為 async 形式
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            authorizationController.performRequests()
        }
    }

    // MARK: - Private Methods
    
    /// 建立 Apple ID 請求，生成 nonce 並加密以便後續登入驗證
    /// - Returns: 已配置好的 Apple ID 請求
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        print("建立 Apple ID 請求")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        return request
    }
    
    /// 使用 Apple 憑證進行 Firebase 登入
    /// - Parameters:
    ///   - credential: Apple 的認證憑證
    ///   - fullName: 使用者的全名（可選）
    /// - Throws: 登入過程中的任何錯誤
    /// - Returns: 登入成功的 `AuthDataResult`
    private func signInWithAppleCredential(_ credential: AuthCredential, fullName: PersonNameComponents?) async throws -> AuthDataResult {
        print("使用 Apple 憑證登入。")
        
        let authResult = try await Auth.auth().signIn(with: credential)
        
        // 成功登入後，將使用者數據保存到 Firestore
        print("Apple 登入成功，UID：\(authResult.user.uid)")
        try await storeAppleUserData(authResult: authResult, fullName: fullName)
        
        return authResult
    }

    /// 將 Apple 使用者的數據儲存到 Firestore
    /// - Parameters:
    ///   - authResult: Firebase 認證結果
    ///   - fullName: 使用者的全名（可選）
    /// - Throws: 儲存過程中的任何錯誤
    private func storeAppleUserData(authResult: AuthDataResult, fullName: PersonNameComponents?) async throws {
        print("開始儲存用戶資料到 Firestore。")
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        let document = try await userRef.getDocument()
        if document.exists, var userData = document.data() {
            print("用戶資料已存在，更新資料。")
            if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                if userData["fullName"] as? String == "" {
                    userData["fullName"] = "\(familyName) \(givenName)"
                }
            }
            userData["loginProvider"] = "apple"
            try await userRef.setData(userData, merge: true)
            
        } else {
            print("用戶資料不存在，創建新資料。")
            var userData: [String: Any] = [
                "uid": user.uid,
                "email": user.email ?? "",
                "loginProvider": "apple"
            ]
            
            if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                userData["fullName"] = "\(familyName) \(givenName)"
            }
            
            try await userRef.setData(userData, merge: true)
        }
    }
    
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInController: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供 Apple 登入的展示視窗
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }

    // MARK: - Private Helper Methods

    /// 生成隨機的 nonce 字串
    /// - Parameter length: nonce 字串的長度，預設為 32
    /// - Returns: 隨機的 nonce 字串
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    /// 對輸入字串進行 SHA256 編碼
    /// - Parameter input: 要編碼的字串
    /// - Returns: 編碼後的字串
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInController: ASAuthorizationControllerDelegate {
    
    /// Apple 登入成功時的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                continuation?.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"]))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                continuation?.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string"]))
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Task {
                do {
                    let authResult = try await self.signInWithAppleCredential(credential, fullName: appleIDCredential.fullName)
                    continuation?.resume(returning: authResult)
                } catch {
                    continuation?.resume(throwing: error)
                }
            }
        }
    }
    
    /// Apple 登入失敗時的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
        continuation?.resume(throwing: error)
    }
    
}






// MARK: - 首次登入可以存取姓名資訊，再次登入也可行備用，並且完善身份驗證提供者（如 Apple、Google、電子郵件和密碼等）憑證與現有的 Firebase 使用者帳號進行關聯，以便用戶可以通過任何已關聯的身份驗證方式登入同一個 Firebase 帳號。（但還未處理隱藏帳號資訊部分）(D)

/*
 import UIKit
 import Firebase
 import AuthenticationServices
 import CryptoKit

 /// 處理 Apple 相關部分
 class AppleSignInController: NSObject {
     
     static let shared = AppleSignInController()
     
     private var currentNonce: String?
     private var signInCompletion: ((Result<AuthDataResult, Error>) -> Void)?


     /// 使用 Apple 登入或註冊
     /// - Parameters:
     ///   - presentingViewController: 觸發登入流程的 ViewController
     ///   - completion: 登入或註冊結果的回調
     func signInWithApple(presentingViewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
         self.signInCompletion = completion
         let request = createAppleIDRequest()
         let authorizationController = ASAuthorizationController(authorizationRequests: [request])
         authorizationController.delegate = self
         authorizationController.presentationContextProvider = self
         authorizationController.performRequests()
     }
     
     /// 建立 Apple ID 請求
     private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
         let appleIDProvider = ASAuthorizationAppleIDProvider()
         let request = appleIDProvider.createRequest()
         request.requestedScopes = [.fullName, .email]
         let nonce = randomNonceString()
         currentNonce = nonce
         request.nonce = sha256(nonce)
         return request
     }
     
     /// 將 Apple 憑證與現有帳號關聯
     private func linkAppleCredential(_ credential: AuthCredential, fullName: PersonNameComponents?, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
         if let currentUser = Auth.auth().currentUser {
             currentUser.link(with: credential) { authResult, error in
                 if let error = error {
                     // 如果連結失敗，嘗試登入並合併數據
                     self.signInWithAppleCredential(credential, fullName: fullName, completion: completion)
                 } else if let authResult = authResult {
                     self.storeAppleUserData(authResult: authResult, fullName: fullName) { result in
                         switch result {
                         case .success:
                             completion(.success(authResult))
                         case .failure(let error):
                             completion(.failure(error))
                         }
                     }
                 }
             }
         } else {
             // 如果不存在相同電子郵件的帳戶，則透過 signInWithAppleCredential 建立一個新的 Apple 憑證帳戶。
             self.signInWithAppleCredential(credential, fullName: fullName, completion: completion)
         }
     }
     
     /// 使用 Apple 憑證登入
     private func signInWithAppleCredential(_ credential: AuthCredential, fullName: PersonNameComponents?, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
         Auth.auth().signIn(with: credential) { authResult, error in
             if let error = error {
                 completion(.failure(error))
             } else if let authResult = authResult {
                 self.storeAppleUserData(authResult: authResult, fullName: fullName) { result in
                     switch result {
                     case .success:
                         completion(.success(authResult))
                     case .failure(let error):
                         completion(.failure(error))
                     }
                 }
             }
         }
     }
     
     /// 儲存 Apple 使用者資料
     /// - Parameters:
     ///   - authResult: Firebase 驗證結果
     ///   - fullName: 使用者的全名
     ///   - completion: 資料儲存結果的回調
     private func storeAppleUserData(authResult: AuthDataResult, fullName: PersonNameComponents?, completion: @escaping (Result<Void, Error>) -> Void) {
         let db = Firestore.firestore()
         let user = authResult.user
         let userRef = db.collection("users").document(user.uid)
         
         userRef.getDocument { (document, error) in
             if let document = document, document.exists, var userData = document.data() {
                 // 如果 document 已存在，則僅在 fullName 欄位為空時更新全名
                 if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                     if userData["fullName"] as? String == "" {
                         userData["fullName"] = "\(familyName) \(givenName)"
                     }
                 }
                 userData["loginProvider"] = "apple"
                 userRef.setData(userData, merge: true) { error in
                     if let error = error {
                         completion(.failure(error))
                     } else {
                         completion(.success(()))
                     }
                 }
                 
             } else {
                 // 如果 document 不存在，則建立新的資料
                 var userData: [String: Any] = [
                     "uid": user.uid,
                     "email": user.email ?? "",
                     "loginProvider": "apple"
                 ]
                 
                 if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                     userData["fullName"] = "\(familyName) \(givenName)"
                 }
                 
                 userRef.setData(userData, merge: true) { error in
                     if let error = error {
                         completion(.failure(error))
                     } else {
                         completion(.success(()))
                     }
                 }

             }
         }
     }
     
     
 }

 // MARK: - ASAuthorizationControllerPresentationContextProviding
 extension AppleSignInController: ASAuthorizationControllerPresentationContextProviding {
     
     /// 返回當前的 Presentation Anchor
     func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
         return UIApplication.shared.windows.first!
     }
     
     /// 產生隨機字串
     /// - Parameter length: 字串長度
     /// - Returns: 隨機字串
     private func randomNonceString(length: Int = 32) -> String {
         precondition(length > 0)
         var randomBytes = [UInt8](repeating: 0, count: length)
         let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
         if errorCode != errSecSuccess {
             fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
         }
         
         let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
         let nonce = randomBytes.map { byte in
             // 從字符集中隨機挑選字符
             charset[Int(byte) % charset.count]
         }
         return String(nonce)
     }

     /// SHA256 加密
     /// - Parameter input: 要加密的字串
     /// - Returns: 加密後的字串
     private func sha256(_ input: String) -> String {
         let inputData = Data(input.utf8)
         let hashedData = SHA256.hash(data: inputData)
         let hashString = hashedData.compactMap {
             String(format: "%02x", $0)
         }.joined()
         
         return hashString
     }
     
 }

 // MARK: - ASAuthorizationControllerDelegate
 extension AppleSignInController: ASAuthorizationControllerDelegate {
     
     /// Apple 登入成功的回調
     func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
         if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
             guard let nonce = currentNonce else {
                 fatalError("Invalid state: A login callback was received, but no login request was sent.")
             }
             guard let appleIDToken = appleIDCredential.identityToken else {
                 print("Unable to fetch identity token")
                 return
             }
             guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                 print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                 return
             }
                         
             let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
             self.linkAppleCredential(credential, fullName: appleIDCredential.fullName, completion: self.signInCompletion!)
         }
     }
     
     /// Apple 登入失敗的回調
     func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
         print("Sign in with Apple errored: \(error)")
         self.signInCompletion?(.failure(error))
     }
     
 }
*/




// MARK: - fetchSignInMethods運用： Apple 可以用相同的信箱帳號去鏈接已經由 Google 、Email 註冊的相同信箱帳號。並且不會出現重複錯誤問題。（E鏈接問題）

/*
import UIKit
import Firebase
import AuthenticationServices
import CryptoKit

/// 處理 Apple 登入相關的 Controller
class AppleSignInController: NSObject {
    
    static let shared = AppleSignInController()
    
    // MARK: - Property

    private var currentNonce: String?
    private var signInCompletion: ((Result<AuthDataResult, Error>) -> Void)?

    
    // MARK: - Public Methods

    /// 使用 Apple 進行登入
    /// - Parameters:
    ///   - presentingViewController: 執行 Apple 登入的視圖控制器
    ///   - completion: 登入完成後的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    func signInWithApple(presentingViewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("開始 Apple 登入流程")
        self.signInCompletion = completion
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Private Methods

    /// 建立 Apple ID 請求
    /// - Returns: 已配置好的 Apple ID 請求
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        print("建立 Apple ID 請求")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        return request
    }
    
    /// 處理已存在的帳號，判斷是鏈結憑證或直接登入
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - credential: Apple 的認證憑證
    ///   - fullName: 使用者的全名（可選）
    ///   - completion: 完成後的回調，返回結果為成功的 `AuthDataResult` 或錯誤
     private func handleExistingAccount(email: String, credential: AuthCredential, fullName: PersonNameComponents?, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
         print("檢查 Firebase 中是否已存在該電子郵件：\(email)")
         // 已到 Authentication > 使用者動作 > 關閉「電子郵件列舉防護」測試用。
         // 因為啟用 「電子郵件列舉防護」 後，會返回空的列表，導致當使用相同電子郵件進行 Apple 登入時，Firebase 無法識別到已存在的帳號。
         Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
             if let error = error {
                 print("檢查登入方法時發生錯誤：\(error.localizedDescription)")
                 completion(.failure(error))
                 return
             }
             if let signInMethods = signInMethods, !signInMethods.isEmpty {
                 print("找到現有帳號，直接嘗試鏈結 Apple 憑證。")
                 self.linkAppleCredentialToExistingAccount(email: email, credential: credential, completion: completion)
             } else {
                 print("沒有找到現有帳號，直接使用 Apple 憑證登入。")
                 self.signInWithAppleCredential(credential, fullName: fullName, completion: completion)
             }
         }
     }

    /// 將 Apple 憑證鏈結到現有帳號
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - credential: Apple 的認證憑證
    ///   - completion: 完成後的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    private func linkAppleCredentialToExistingAccount(email: String, credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        // 假設當前用戶已經登入
        if let currentUser = Auth.auth().currentUser {
            print("嘗試將 Apple 憑證鏈結到現有帳號：\(email)")
            currentUser.link(with: credential) { result, error in
                if let error = error {
                    print("鏈結 Apple 憑證時發生錯誤：\(error.localizedDescription)")
                    completion(.failure(error))
                } else if let result = result {
                    print("成功鏈結 Apple 憑證。")
                    completion(.success(result))
                }
            }
        } else {
            print("當前沒有已登入的使用者，無法鏈結 Apple 憑證。")
            completion(.failure(NSError(domain: "AppleSignInController", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current user to link the Apple credential to."])))
        }
    }
 
    /// 使用 Apple 憑證進行登入
    /// - Parameters:
    ///   - credential: Apple 的認證憑證
    ///   - fullName: 使用者的全名（可選）
    ///   - completion: 完成後的回調，返回結果為成功的 `AuthDataResult` 或錯誤
    private func signInWithAppleCredential(_ credential: AuthCredential, fullName: PersonNameComponents?, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("使用 Apple 憑證登入。")
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("使用 Apple 憑證登入時發生錯誤：\(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                print("Apple 登入成功，UID：\(authResult.user.uid)")
                self.storeAppleUserData(authResult: authResult, fullName: fullName, completion: { result in
                    switch result {
                    case .success:
                        print("成功儲存用戶資料。")
                        completion(.success(authResult))
                    case .failure(let error):
                        print("儲存用戶資料時發生錯誤：\(error.localizedDescription)")
                        completion(.failure(error))
                    }
                })
            }
        }
    }
 
    /// 儲存 Apple 使用者資料到 Firestore
    /// - Parameters:
    ///   - authResult: Firebase 認證結果
    ///   - fullName: 使用者的全名（可選）
    ///   - completion: 完成後的回調，返回結果為成功或錯誤
    private func storeAppleUserData(authResult: AuthDataResult, fullName: PersonNameComponents?, completion: @escaping (Result<Void, Error>) -> Void) {
         print("開始儲存用戶資料到 Firestore。")
         let db = Firestore.firestore()
         let user = authResult.user
         let userRef = db.collection("users").document(user.uid)
         
         userRef.getDocument { (document, error) in
             if let document = document, document.exists, var userData = document.data() {
                 print("用戶資料已存在，更新資料。")
                 if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                     if userData["fullName"] as? String == "" {
                         userData["fullName"] = "\(familyName) \(givenName)"
                     }
                 }
                 userData["loginProvider"] = "apple"
                 userRef.setData(userData, merge: true) { error in
                     if let error = error {
                         print("更新用戶資料時發生錯誤：\(error.localizedDescription)")
                         completion(.failure(error))
                     } else {
                         print("成功更新用戶資料。")
                         completion(.success(()))
                     }
                 }
                 
             } else {
                 print("用戶資料不存在，創建新資料。")
                 var userData: [String: Any] = [
                     "uid": user.uid,
                     "email": user.email ?? "",
                     "loginProvider": "apple"
                 ]
                 
                 if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                     userData["fullName"] = "\(familyName) \(givenName)"
                 }
                 
                 userRef.setData(userData, merge: true) { error in
                     if let error = error {
                         print("創建用戶資料時發生錯誤：\(error.localizedDescription)")
                         completion(.failure(error))
                     } else {
                         print("成功創建用戶資料。")
                         completion(.success(()))
                     }
                 }
             }
         }
     }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInController: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供 Apple 登入的展示視窗
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    // MARK: - Private Helper Methods

    /// 生成隨機的 nonce 字串
    /// - Parameter length: nonce 字串的長度，預設為 32
    /// - Returns: 隨機的 nonce 字串
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    /// 對輸入字串進行 SHA256 編碼
    /// - Parameter input: 要編碼的字串
    /// - Returns: 編碼後的字串
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInController: ASAuthorizationControllerDelegate {
    
    /// Apple 登入成功時的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
                         
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            if let email = appleIDCredential.email {
                print("Apple 提供了電子郵件：\(email)")
                self.handleExistingAccount(email: email, credential: credential, fullName: appleIDCredential.fullName, completion: self.signInCompletion!)
            } else {
                // 如果 Apple 不提供電子郵件，直接使用憑證進行登入
                print("Apple 未提供電子郵件，直接使用憑證進行登入。")
                self.signInWithAppleCredential(credential, fullName: appleIDCredential.fullName, completion: self.signInCompletion!)
            }
        }
    }
    
    /// Apple 登入失敗時的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("Sign in with Apple errored: \(error)")
        self.signInCompletion?(.failure(error))
    }
}
*/
