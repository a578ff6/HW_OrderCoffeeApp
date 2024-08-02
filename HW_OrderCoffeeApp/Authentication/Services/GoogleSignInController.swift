//
//  GoogleSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/20.
//

/*
 
 當初最一開始的寫法只有處理登入部分，沒注意到因為登入與註冊在這部分是一樣的概念，所以必須存取用戶資料到 userDetails 裡面。導致找不到使用者資料。
 那這樣每次登入就等於再次註冊嗎？那這樣會不會影響到使用者的資料呢？
 
 
 A. 原先的寫法只處理了登入部分，沒注意到對於 Google 登入，註冊和登入實際上是使用相同的邏輯。
    - 由於 Google 登入後，Firebase 會自動建立用戶帳號，因此需要確保在首次登入時將用戶資料存取到 Firestore 中，這樣在之後獲取用戶資料時就不會出現「User data not found」。
    - 已經使用了 merge: true，代表在用戶每次登入時，新的用戶資料會被合併到現有的資料中，而不是整個覆蓋。因此，這不會影響到用戶的現有資料，除非明確的在 setData 中覆蓋。
 
 * 結論：
    - 登入、註冊基本上是相同的邏輯。
    - 需要確保在首次登入時將用戶資料存取到 Firestore 中。
    - 使用 merge: true 可以防止每次登入覆蓋現有的用戶資料。
    - 這樣就能確保用戶資料在首次登入時被正確存取，並且不會在每次登入時被覆蓋，從而不會影響用戶的現有資料。
 
 
 ------------------------- ------------------------- ------------------------- -------------------------

 B. 處理「電子郵件/密碼登入」與「Google 登入」的部分
    - 主要是因為當使用者使用「電子郵件/密碼」註冊登入之後，接著使用帶有相同 email 的 「Google」 註冊登入，就會發生先前的「電子郵件/密碼」無法使用的問題。
 
 * 解決方式：
    -  將不同的身份驗證提供者（如 Google、Facebook、電子郵件和密碼等）憑證與現有的 Firebase 使用者帳號進行關聯，以便用戶可以通過任何已關聯的身份驗證方式登入同一個 Firebase 帳號。

    1. 用任意身份驗證提供方登入:
        - 首先，用戶使用任意身份驗證方式登入，例如電子郵件和密碼、Google 或 Facebook。
    2. 開始新的身份驗證提供方登入流程：
        - 按照新身份驗證提供方的登入流程逐步進行，直到需要調用 signInWith 方法時停止。例如，獲取用戶的 Google ID 令牌或電子郵件地址和密碼。
    3. 獲取新身份驗證提供方的憑證：
        - 根據不同的身份驗證提供方，獲取相應的 AuthCredential 對象。
    4. 將新身份驗證提供方的憑證與已登入用戶的帳號關聯：
        - 使用當前已登入用戶的 link(with:completion:) 方法將新身份驗證提供方的憑證與該帳號關聯。
 
 * 流程：
    1. Google 登入或註冊：
        - signInWithGoogle 負責處理 Google 登入流程。它會使用 Google SDK 來發起登入請求，並在登入成功後獲取 idToken 和 accessToken。
    2. 將 Google 憑證與現有帳號關聯：
        - linkGoogleCredential 會檢查當前是否有已登入的使用者。如果有，它會嘗試將 Google 憑證與該使用者帳號關聯。
        - 如果關聯失敗（因為該憑證已經與另一個帳號關聯），它會改用 Google 憑證進行登入。
    3. 使用 Google 憑證登入：
        - signInWithGoogleCredential 負責使用 Google 憑證進行登入，並在登入成功後存取使用者資料。
    4. 存取 Google 使用者資料：
        - storeGoogleUserData 方法會檢查 Firestore 中是否已經存在該使用者的資料。如果存在，它會更新資料，否則會創建新資料。
 
 * 合併數據的情境
    1. 多個身份驗證提供者：
        -  用戶可能先使用電子郵件註冊，然後再使用 Google 登錄。此時，將這兩種不同的身份驗證方式關聯到同一個 Firebase 帳戶。
    2. 避免帳戶衝突：
        - 當用戶嘗試使用 Google 憑證登錄，但該憑證已經與另一個 Firebase 帳戶關聯時，連結操作將失敗。在這種情況下，需要讓用戶登錄並合併數據，以確保用戶的數據保持一致，不會丟失。

 * 合併數據的必要性在於保持用戶數據的一致性和完整性：
    1. 用戶改變身份驗證方式：
        - 用戶可能會從使用電子郵件和密碼註冊轉變為使用 Google 登錄，或相反。確保無論用戶使用哪種身份驗證方式，都能訪問到相同的帳戶數據。
    2. 避免重複帳戶：
        - 如果不合併數據，用戶可能會無意中創建多個帳戶，這會導致數據分散，給用戶體驗帶來不便。
 
 * 注意部分：
    - 每次登錄時都要檢查並更新用戶資料，以確保最新的身份驗證信息被正確存儲。
    - 當用戶嘗試用新的身份驗證提供者登錄時，必須確保用戶是相同的 Firebase 帳號。
    - 如果用戶的 fullName 在 Google 和 Apple 登錄時不同，必須決定如何處理這種情況（EX: 保留最初註冊時的名字或者詢問用戶希望使用哪一個名字）。
 
 ------------------------- ------------------------- ------------------------- -------------------------


 */


// 備用
/*
import UIKit
import Firebase
import GoogleSignIn

/// 處理 Google 相關部分
class GoogleSignInController {
    
    static let shared = GoogleSignInController()
    
    /// 使用google 登入 或 註冊
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "GoogleSignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google sign-in failed."])))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let authResult = authResult {
                    self.storeGoogleUserData(authResult: authResult) { result in
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
    }
    
    
    /// 存取 Google 使用者資料
    private func storeGoogleUserData(authResult: AuthDataResult, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists, var userData = document.data() {
                // 如果 document 已存在，則僅在 fullName 欄位為空時更新全名
                if let displayName = user.displayName, userData["fullName"] as? String == "" {
                    userData["fullName"] = displayName
                }
                userData["loginProvider"] = "google"
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
                    "loginProvider": "google"
                ]
                
                if let displayName = user.displayName {
                    userData["fullName"] = displayName
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
*/


// MARK: -測試（不同的身份驗證提供方（如 Google、Facebook、電子郵件和密碼等）憑證與現有的 Firebase 使用者帳號進行關聯）

import UIKit
import Firebase
import GoogleSignIn

/// 處理 Google 相關部分
class GoogleSignInController {
    
    static let shared = GoogleSignInController()
    
    /// 使用google 登入 或 註冊
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("Google Sign-In failed to get user or idToken")
                completion(.failure(NSError(domain: "GoogleSignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google sign-in failed."])))
                return
            }
            
            print("Google Sign-In successful. User: \(user.profile?.name ?? "Unknown"), Email: \(user.profile?.email ?? "Unknown")")

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            self.linkGoogleCredential(credential, completion: completion)
        }
    }
    
    
    /// 將 Google 憑證與現有帳號關聯
    private func linkGoogleCredential(_ credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            print("Current user is signed in. Linking Google credential...")
            currentUser.link(with: credential) { authResult, error in
                if let error = error {
                    // 如果連結失敗，嘗試登入並合併數據
                    print("Linking Google credential failed: \(error.localizedDescription). Trying to sign in instead.")
                    self.signInWithGoogleCredential(credential, completion: completion)
                } else if let authResult = authResult {
                    // 連結成功，調用 storeGoogleUserData 保存用戶數據。
                    print("Linking Google credential successful")
                    self.storeGoogleUserData(authResult: authResult) { result in
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
            // 如果不存在相同電子郵件的帳戶，則透過 signInWithGoogleCredential 建立一個新的 Google 憑證帳戶。
            print("No current user. Signing in with Google credential...")
            self.signInWithGoogleCredential(credential, completion: completion)
        }
    }
    
    /// 使用 Google 憑證登入
    private func signInWithGoogleCredential(_ credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Sign in with Google credential failed: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                print("Sign in with Google credential successful")
                self.storeGoogleUserData(authResult: authResult) { result in
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
    
    /// 存取 Google 使用者資料
    private func storeGoogleUserData(authResult: AuthDataResult, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists, var userData = document.data() {
                // 如果 document 已存在，則僅在 fullName 欄位為空時更新全名
                if let displayName = user.displayName, userData["fullName"] as? String == "" {
                    print("Updating existing user data with Google display name: \(displayName)")
                    userData["fullName"] = displayName
                }
                userData["loginProvider"] = "google"
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        print("Failed to update user data: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("User data updated successfully")
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
                    print("Creating new user data with Google display name: \(displayName)")
                    userData["fullName"] = displayName
                }
                
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        print("Failed to create user data: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("User data created successfully")
                        completion(.success(()))
                    }
                }
            }
        }
    }

}
