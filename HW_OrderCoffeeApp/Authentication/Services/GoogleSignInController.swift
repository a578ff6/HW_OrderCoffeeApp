//
//  GoogleSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/20.
//

/*
 
 當初最一開始的寫法只有處理登入部分，沒注意到因為登入與註冊在這部分是一樣的概念，所以必須存取用戶資料到 userDetails 裡面。導致找不到使用者資料。
 於是開始思考這樣每次登入就等於再次註冊嗎？那這樣會不會影響到使用者的資料呢？
 
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
 
 * 合併數據的情境
    1. 多個身份驗證提供者：
        -  用戶可能先使用電子郵件註冊，然後再使用 Google 登錄。此時，將這兩種不同的身份驗證方式關聯到同一個 Firebase 帳戶。
    2. 避免帳戶衝突：
        - 當用戶嘗試使用 Google 憑證登錄，但該憑證已經與另一個 Firebase 帳戶關聯時，連結操作將失敗。在這種情況下，需要讓用戶登錄並合併數據，以確保用戶的數據保持一致，不會丟失。

 * 合併數據的必要性在於保持用戶數據的一致性和完整性：
    1. 用戶改變身份驗證方式：
        - 用戶可能會從使用「電子郵件和密碼註冊」轉變為使用 Google 登錄，或相反。確保無論用戶使用哪種身份驗證方式，都能訪問到相同的帳戶數據。
    2. 避免重複帳戶：
        - 如果不合併數據，用戶可能會無意中創建多個帳戶，這會導致數據分散，給用戶體驗帶來不便。
 
 * 注意部分：
    - 每次登錄時都要檢查並更新用戶資料，以確保最新的身份驗證資訊被正確存取。
    - 當用戶嘗試用新的身份驗證提供者登錄時，必須確保用戶是相同的 Firebase 帳號。
    - 如果用戶的 fullName 在 Google 和 Apple 登錄時不同，必須決定如何處理這種情況（EX: 我這邊採用保留最初註冊時的名字）。
 
 
 ------------------------- ------------------------- ------------------------- -------------------------

 C. Google 可以用相同的信箱帳號去鏈接已經由 Apple 、Email 註冊的相同信箱帳號。並且不會出現重複錯誤問題。
    - Google 可以使用相同的信箱帳號，去鏈接已經由 Apple 或 Email 註冊的相同信箱帳號。
    - 當 Google 登入檢查到相同的信箱帳號已經存在於 Firebase 中，並且與 Apple 或 Email 提供方相關聯時，Google 會嘗試將自己的憑證鏈接到該現有帳號。
    - 如果鏈接成功，該帳號將同時支持 Google、Apple、和 Email 等多種登入方式，且不會出現重複或錯誤的問題。
    
 
 ## 流程分析
    * signInWithGoogle:
        - 這是主要的方法，用於觸發 Google 的登入流程。它會從 Firebase 中取得 clientID，並設定 Google Sign-In 的配置。
        - 使用者完成登入後，系統會檢查該電子郵件是否已經存在於 Firebase 中，然後呼叫 handleExistingAccount 方法。
 
    * handleExistingAccount:
        - 負責處理 Firebase 中已經存在的帳號。它使用 fetchSignInMethods 檢查該電子郵件與哪些提供方相關聯。
        - 如果該電子郵件已經與 Google 提供方相關聯，則直接進行登入。
        - 如果該電子郵件與其他提供方（例如 Email 或 Apple）相關聯，則嘗試將 Google 憑證鏈結到現有帳號。
        - 如果該電子郵件沒有與任何提供方相關聯，則直接使用 Google 憑證進行登入。
 
    * handleSignInMethods:
        - 根據不同的提供方進行處理。如果使用者已經與 Google 提供方相關聯，直接登入。否則，嘗試將 Google 憑證鏈結到現有帳號。
 
    * linkGoogleCredentialToExistingAccount:
        - 負責將 Google 憑證鏈結到現有帳號。如果當前有使用者登入，它會嘗試將 Google 憑證鏈結到該帳號；如果鏈結失敗（例如，該提供方已經鏈結過該帳號），則直接使用 Google 憑證登入。
 
    * signInWithGoogleCredential:
        - 負責使用 Google 憑證進行登入。如果登入成功，將使用者資料存儲到 Firestore。

    * storeGoogleUserData:
        - 將 Google 使用者資料存儲到 Firestore。如果使用者已經存在於 Firestore 中，則更新其資料；否則，創建新的使用者資料。
 
 ------------------------- ------------------------- ------------------------- -------------------------

 * 測試 Google 部分：
 
 * Google 與 與 Email （a578ff6@gmail.com） or 不同的Email
    - [v] 先 Google 註冊看有無真的存到資料。
    - [v] 先使用 Email （a1202@gmail.com） 不同的帳號註冊，在使用 Google （a578ff6@gmail.com） 去註冊登入，需要無法鏈接，且能各自登入才是正確。（等同於首次使用 Google ）
    - [v] 先使用 Email （a578ff6@gmail.com） 相同的帳號註冊，在使用 Google （a578ff6@gmail.com） 去註冊登入，鏈接完成，且提供方沒被覆蓋，Email、Google 都能登入，沒有重複錯誤訊息。（鏈接）
 
 * 補充 Email > Google > Apple ：
    - [v] 都是 a578ff6@gmail.com 的帳號，先用 Email ，在用 Google 鏈接，然後 Apple 鏈接，然後 Google 登入，測試成功，每個段落都測試過，可以登入，不會出現重複錯誤，以及提供方覆蓋問題。
 
 * Google 與 Apple
    - [v] 先 Apple 不隱藏 （a578ff6@gmail.com） 註冊，在使用 Google （a578ff6@gmail.com） 去註冊登入，鏈接完成，且提供方沒被覆蓋，Apple、Google 都能登入，沒有重複錯誤訊息。（鏈接）
 
 * Google 與 Apple 隱藏
    - [v] 先使用 Apple 隱藏註冊中繼帳號，在使用 Google （a578ff6@gmail.com） 去註冊登入。基本上是不能鏈接的，只能各自登入。
 
 */

// MARK: - fetchSignInMethods 運用： Google 可以用相同的信箱帳號去鏈接已經由 Apple 、Email 註冊的相同信箱帳號。並且不會出現重複錯誤問題。（C）

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


// MARK: - 方法一：避免 Google 去鏈接 Apple 的寫法。
/*
private func handleExistingAccount(email: String, credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
    print("檢查 Firebase 中是否已存在該電子郵件：\(email)")
    Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
        if let error = error {
            print("檢查登入方法時發生錯誤：\(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        if let signInMethods = signInMethods, !signInMethods.isEmpty {
            if signInMethods.contains(GoogleAuthProviderID) {
                print("找到現有帳號，並且已經使用 Google 登入過，直接登入。")
                self.signInWithGoogleCredential(credential, completion: completion)
            } else if signInMethods.contains(EmailAuthProviderID) {
                print("找到現有帳號，該帳號與 Email 提供方鏈接。")
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
            } else {
                print("此電子郵件 \(email) 已經被其他提供方使用，無法註冊或鏈接。")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "This email is already in use by another account with a different provider."])))
            }
        } else {
            print("沒有找到現有帳號，直接使用 Google 憑證登入。")
            self.signInWithGoogleCredential(credential, completion: completion)
        }
    }
}
 */


// MARK: - 方法二：允許 Google 憑證鏈接到已經存在的帳號，只要該帳號未與 Google 提供方相關聯。(還未重構)
/*
 /// 處理已存在的帳號，決定是直接登入還是嘗試鏈結 Google 憑證（方法二：允許 Google 憑證鏈接到已經存在的帳號，只要該帳號未與 Google 提供方相關聯。）
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
             if signInMethods.contains(GoogleAuthProviderID) {
                 print("找到現有帳號，並且已經使用 Google 登入過，直接登入。")
                 self.signInWithGoogleCredential(credential, completion: completion)
             } else {
                 print("找到現有帳號，嘗試鏈結 Google 憑證。")
                 guard let currentUser = Auth.auth().currentUser else {
                     print("當前沒有已登入的使用者，無法鏈結 Google 憑證，直接嘗試使用 Google 憑證登入。")
                     self.signInWithGoogleCredential(credential, completion: completion)
                     return
                 }
                 
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
         } else {
             print("沒有找到現有帳號，直接使用 Google 憑證登入。")
             self.signInWithGoogleCredential(credential, completion: completion)
         }
     }
 }
 */
