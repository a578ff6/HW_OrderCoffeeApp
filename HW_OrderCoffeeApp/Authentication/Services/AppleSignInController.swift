//
//  AppleSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/29.
//


/*
 A. 我在測試過程中，發現即使不隱藏資訊也只能獲取電子郵件而無法獲取使用者名字。結果是未將 fullName 包含在存儲使用者資料的部分。
    - firebase 官方文件中使用 appleCredential(withIDToken:rawNonce:fullName:)，將 fullName 傳遞給 OAuthProvider.credential 。
    - 官方文件的做法確保了在使用者授權時獲取到的 fullName 能夠傳遞給 Firebase。
    
 * 解決方式：
    - 在 authorizationController 中，使用 OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:) 來初始化憑證，將 fullName 傳遞給 Firebase。
    - 更新 storeAppleUserData 方法，將 fullName 包含在使用者資料中。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 B. 在使用者不隱藏個人Apple資訊時，首次註冊、登入的情況下，可以存取使用者的名字。但是當再次登入時，firebase資料庫中的名字資訊就會變成""。
    - 首次註冊：當使用者首次使用 Apple 登入時，可以獲取完整的用戶資料（名字和電子郵件）。
    - 再次登入：當用戶再次登入時，Apple 不會再次提供名字和電子郵件，因此需要從 firebase 數據庫中獲取這些資料。
 
 * Apple ID 登入的特性：
    - Apple ID 登入只在首次註冊時返回用戶的完整資訊（例如名字和電子郵件）。在後續的登入中，只會返回用戶的 Apple ID 和基本驗證資料。
     
 * 解決方式：
    - 首次註冊時存儲完整資料：確保在首次註冊時，完整地存儲用戶的資料（名字和電子郵件）。
    - 再次登入時從數據庫獲取資料：在用戶再次登入時，從數據庫中讀取用戶的資料（包括名字和電子郵件）。
    - 在 storeAppleUserData 方法中，先嘗試獲取現有的使用者資料。如果資料已經存在，則只更新非空白的全名。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 C. 當使用者用相同的電子郵件透過不同的登入方式（如 Apple 和 Google）登入時，發生覆蓋 FullName問題 。
    - 因為 Firebase 會根據電子郵件地址將這些不同的登入方式識別為相同的帳戶。
    - UID 一致：不論使用者透過哪種方式登入，Firebase 都會為同一個電子郵件地址的使用者分配相同的 UID。
    - 資料覆蓋：由於 Firebase 使用 UID 作為唯一標識符，後一次登入（例如 Google）會覆蓋前一次登入（例如 Apple）儲存的使用者資料。

 * 解決方式：
    - 避免資料覆蓋：在儲存使用者資料時，不要覆蓋已有的 fullName。
    - 區分登入來源：在使用者資料中儲存登入來源，設置 loginProvider，以便在後續操作中區分不同的登入方式。
    - 修改了 storeAppleUserData 和 storeGoogleUserData ，以避免覆蓋已有的 fullName，並在資料中加入 loginProvider 以記錄登入方式。
    - 當使用者透過不同方式登入時，只更新 fullName 欄位為空的情況，避免覆蓋之前已儲存的全名。
    - 這樣可以避免使用者的全名在不同登入方式間被覆蓋，同時保留每次登入時的唯一識別資訊。
 
 */


// MARK: - 首次登入可以存取姓名資訊，再次登入也可行備用

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
         let request = creatAppleIDRequest()
         let authorizationController = ASAuthorizationController(authorizationRequests: [request])
         authorizationController.delegate = self
         authorizationController.presentationContextProvider = self
         authorizationController.performRequests()
     }
     
     /// 建立 Apple ID 請求
     private func creatAppleIDRequest() -> ASAuthorizationAppleIDRequest {
         let appleIDProvider = ASAuthorizationAppleIDProvider()
         let request = appleIDProvider.createRequest()
         request.requestedScopes = [.fullName, .email]
         let nonce = randomNonceString()
         currentNonce = nonce
         request.nonce = sha256(nonce)
         return request
     }

     
     /// 儲存 Apple 使用者資料
     /// - Parameters:
     ///   - authResult: Firebase 驗證結果
     ///   - fullName: 使用者的全名
     ///   - completion: 資料儲存結果的回調
     private func storeAppleUserData(authResult: AuthDataResult,fullName: PersonNameComponents?, completion: @escaping (Result<Void, Error>) -> Void) {
         let db = Firestore.firestore()
         let user = authResult.user
         let userRef = db.collection("users").document(user.uid)
         
         userRef.getDocument { (document, error) in
             if let document = document, document.exists, var userData = document.data() {
                 // 如果 document 已存在，則更新非空白的全名
                 if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                     if !givenName.isEmpty && !familyName.isEmpty {
                         userData["fullName"] = "\(givenName) \(familyName)"
                     }
                 }
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
                     "email": user.email ?? ""
                 ]
                 
                 if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                     userData["fullName"] = "\(givenName) \(familyName)"
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
             
             let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
             Auth.auth().signIn(with: credential) { authResult, error in
                 if let error = error {
                     self.signInCompletion?(.failure(error))
                 } else if let authResult = authResult {
                     self.storeAppleUserData(authResult: authResult, fullName: appleIDCredential.fullName) { result in
                         switch result {
                         case .success:
                             self.signInCompletion?(.success(authResult))
                         case .failure(let error):
                             self.signInCompletion?(.failure(error))
                         }
                     }
                 }
             }
         }
     }
     
     /// Apple 登入失敗的回調
     func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
         print("Sign in with Apple errored: \(error)")
     }
     
 }
*/


// MARK: - 測試用
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
        let request = creatAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    /// 建立 Apple ID 請求
    private func creatAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        return request
    }

    
    /// 儲存 Apple 使用者資料
    /// - Parameters:
    ///   - authResult: Firebase 驗證結果
    ///   - fullName: 使用者的全名
    ///   - completion: 資料儲存結果的回調
    private func storeAppleUserData(authResult: AuthDataResult,fullName: PersonNameComponents?, completion: @escaping (Result<Void, Error>) -> Void) {
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
            
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.signInCompletion?(.failure(error))
                } else if let authResult = authResult {
                    self.storeAppleUserData(authResult: authResult, fullName: appleIDCredential.fullName) { result in
                        switch result {
                        case .success:
                            self.signInCompletion?(.success(authResult))
                        case .failure(let error):
                            self.signInCompletion?(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    
    /// Apple 登入失敗的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
}
