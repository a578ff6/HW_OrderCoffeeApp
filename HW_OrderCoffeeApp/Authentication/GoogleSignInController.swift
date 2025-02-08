//
//  GoogleSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/20.
//

// MARK: - 測試 Google 部分
/**
 
 ## 測試 Google 部分：
 
  - [v] 先 Google 看有無真的存到資料，基本上要有資料。（資料修改沒問題）

 `* Google 與 Email`
 
    - [v] 先用 Email （a1202@gmail.com） 註冊登入， 在用 Google （a578ff6@gmail.com） ，基本上是兩個不同帳號。（資料修改沒問題）
    - [v] 先用 Email (a578ff6@gmail.com) 註冊登入，在用 Google （a578ff6@gmail.com） ，基本上會蓋過 Email。（資料修改沒問題）
 
` * Google 與 Apple`
 
    - [v] 在已經有 Google（a578ff6@gmail.com） 的情況下，去使用 Apple （a578ff6@gmail.com） ，基本上兩者可以互相登入。（資料修改沒問題）

 `* Google 與 Apple 隱藏`
 
    - [v] 先使用 Apple 隱藏註冊中繼帳號，在使用 Google （a578ff6@gmail.com） 去註冊登入。基本上是不能鏈接的，只能各自登入。（資料修改沒問題）

 `* Google 與 Apple 未隱藏`
 
    - [v] 先使用 Apple （a578ff6@gmail.com） 註冊，在使用 Google （a578ff6@gmail.com） 去註冊登入。能互相登入。（資料修改沒問題）
 */


// MARK: - 登入與註冊邏輯統一
/**
 
 ## 登入與註冊邏輯統一
 
 - 原始問題:
 
    - 最初只處理了Google的登入部分，忽略了註冊和登入在Firebase中的邏輯實際上是相同的。
    - 沒有存取用戶資料到Firestore，導致「找不到使用者資料」的問題。

 - 解決方案:
 
    - 登入和註冊的核心邏輯是一致的，無論是登入還是註冊，都需要在首次登入時將用戶資料存儲到Firestore。
    - 使用merge: true來確保每次登入時新資料不會覆蓋現有資料，而是進行合併。
 */


// MARK: - Google SignIn功能的流程
/**
 
 ## Google SignIn功能的流程
 
` 1.signInWithGoogle:`
 
    - 觸發Google的登入流程，取得clientID並配置Google Sign-In。
    - 成功登入後，直接使用Google憑證進行登入。

`2.signInWithGoogleCredential:`
 
    - 使用Google憑證進行登入，並在登入成功後將用戶資料存儲到Firestore。

 `3.storeGoogleUserData:`
 
    - 將Google用戶資料存儲到Firestore。
    - 如果用戶資料已經存在，則更新其資料；否則，創建新的用戶資料。
 */


// MARK: - GoogleSignInController 筆記
/**
 
 ## GoogleSignInController 筆記

 - https://reurl.cc/eG4X9R
 
 `* What: `

 1. 主要功能
 
 - GoogleSignInController 負責處理與 Google 登入相關的邏輯，包括：
 
    - 與 Google Sign-In SDK 交互：負責調用 Google 登入 SDK 來進行身份驗證。
    - 獲取 Google 身份驗證憑證：從 Google SDK 取得 `idToken` 和 `accessToken`。
    - 登入 Firebase：透過 Google 憑證進行 Firebase 身份驗證。
    - 存儲用戶資訊至 Firestore：將成功登入的使用者資料存入 Firestore。

 2. 設計原則
 
    - 單例模式 (`shared`)：確保 `GoogleSignInController` 只有一個實例，避免重複初始化。
    - 非同步 (`async/await`)：採用 Swift Concurrency (`async/await`) 確保執行流程不阻塞 UI。
    - 錯誤處理 (`GoogleSignInError`)：定義清晰的錯誤類型，讓 UI 可根據錯誤類型提供適當提示。
    - 確保 UI 相關操作在主執行緒進行：透過 `DispatchQueue.main.async`，避免 UI 操作發生在非主執行緒，防止 `Main Thread Checker` 錯誤。

 -------

 `* Why: `

 1. 角色清晰，提升可維護性
 
    - 若不抽出 `GoogleSignInController`，登入邏輯可能分散在 `LoginViewController` 或 `SignUpViewController`，導致程式碼耦合度高，不易維護。
    - 將 Google 登入邏輯集中到 `GoogleSignInController`，可提升程式碼的清晰度與模組化。

 2. 確保 Google 登入 SDK 的正確使用

    - Google Sign-In 需要透過 `GIDSignIn.sharedInstance.signIn` 進行授權，並透過 `idToken` 進行 Firebase 身份驗證。若 SDK 調用方式錯誤，可能導致無法登入或安全性問題。

 3. 提供統一的錯誤處理機制
 
    - 若登入過程發生錯誤（例如用戶取消授權、網路錯誤），透過 `GoogleSignInError` 提供統一錯誤處理，使 UI 可適當處理不同錯誤情境。

 4. 非同步登入確保流暢度
 
    - Google Sign-In 需要與 Google 伺服器進行網路請求，因此使用 `async/await` 確保登入流程不會阻塞 UI，提升使用者體驗。

 5. 確保 UI 操作執行在主執行緒
 
    - Google Sign-In SDK 會調用 UIKit 相關 API，因此必須確保 UI 操作在主執行緒執行，避免 `Main Thread Checker` 錯誤。

 -------

 `* How: `

 1. 透過單例管理 GoogleSignInController
 
     ```swift
     class GoogleSignInController {
         static let shared = GoogleSignInController()
     }
     ```

 ---
 
 2. 主要登入流程 (signInWithGoogle)
 
     ```swift
     @MainActor
     func signInWithGoogle(presentingViewController: UIViewController) async throws -> AuthDataResult {
         guard let clientID = FirebaseApp.app()?.options.clientID else {
             throw GoogleSignInError.missingClientID
         }
         
         let config = GIDConfiguration(clientID: clientID)
         GIDSignIn.sharedInstance.configuration = config
         
         let result = try await signInWithGoogleSDK(presentingViewController: presentingViewController)
         
         let credential = GoogleAuthProvider.credential(
             withIDToken: result.idToken,
             accessToken: result.accessToken
         )
         
         return try await signInWithGoogleCredential(credential)
     }
     ```

 ---

 3. 確保 Google Sign-In SDK 在主執行緒執行
 
     ```swift
     private func signInWithGoogleSDK(presentingViewController: UIViewController) async throws -> (idToken: String, accessToken: String) {
         return try await withCheckedThrowingContinuation { continuation in
             DispatchQueue.main.async {
                 GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                     if let error = self.parseGoogleSignInError(error) {
                         continuation.resume(throwing: error)
                         return
                     }
                     
                     guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                         continuation.resume(throwing: GoogleSignInError.invalidGoogleUser)
                         return
                     }
                     
                     continuation.resume(returning: (idToken, user.accessToken.tokenString))
                 }
             }
         }
     }
     ```

 ---

 4. 錯誤處理 (GoogleSignInError)
 
     ```swift
     enum GoogleSignInError: Error, LocalizedError {
         case userCancelled
         case accessDenied
         case missingClientID
         case invalidGoogleUser
         case firebaseSignInFailed(Error)
         
         var localizedDescription: String? {
             switch self {
             case .userCancelled, .accessDenied:
                 return nil   // 使用者取消或拒絕授權不需要顯示錯誤
             case .missingClientID:
                 return "無法取得 Firebase Client ID。"
             case .invalidGoogleUser:
                 return "Google 使用者驗證失敗。"
             case .firebaseSignInFailed(let error):
                 return "Google 登入 Firebase 失敗：\(error.localizedDescription)"
             }
         }
     }
     ```

 ---

 5. 存儲登入使用者資訊至 Firestore
 
     ```swift
     private func storeGoogleUserData(authResult: AuthDataResult) async throws {
         let db = Firestore.firestore()
         let user = authResult.user
         let userRef = db.collection("users").document(user.uid)
         
         let document = try await userRef.getDocument()
         if document.exists, var userData = document.data() {
             if let displayName = user.displayName, userData["fullName"] as? String == "" {
                 userData["fullName"] = displayName
             }
             userData["loginProvider"] = "google"
             try await userRef.setData(userData, merge: true)
         } else {
             var userData: [String: Any] = [
                 "uid": user.uid,
                 "email": user.email ?? "",
                 "loginProvider": "google"
             ]
             
             if let displayName = user.displayName {
                 userData["fullName"] = displayName
             }
             
             try await userRef.setData(userData, merge: true)
         }
     }
     ```

 -------

 `* 總結`
 
 1. `GoogleSignInController` 負責 Google 登入、Firebase 身份驗證及用戶資料存儲。
 2. 提升程式碼可讀性與模組化，避免 UI 阻塞，確保 Google Sign-In SDK 正確執行。
 3. 透過 `async/await`、`DispatchQueue.main.async`、錯誤處理 (`GoogleSignInError`) 來實作高效、穩定的 Google 登入功能。

 */


// MARK: - storeGoogleUserData(authResult:) 筆記
/**
 
 ### storeGoogleUserData(authResult:) 筆記

 ---

 `* What：`
 
 - `storeGoogleUserData(authResult:)` 是 **用來將 Google 登入成功後的使用者資料存入 Firestore** 的方法。

 - 主要職責
 
 1. 檢查使用者是否已存在於 Firestore：
 
    - 透過 `uid` 查詢 `users` collection 中的 `document`。
 
 2. 避免覆蓋已存在的使用者資料：
 
    - 若 `fullName` 為空，才會填入 Google `displayName`，避免覆蓋其他登入方式（如 Email、Apple）提供的名稱。
 
 3. 更新登入方式：
 
    - 設定 `loginProvider = "google"` 來標記該用戶最新的登入方式。

 -------

 `* Why：`
 
 1. 確保 Firestore 擁有最新的使用者資訊
 
    - 登入成功後，應該確保 Firestore 記錄該使用者的 `email`、`uid` 和 `登入來源`，以利未來驗證。
   
 2. 防止不同登入方式（Google、Apple、Email）之間互相覆蓋使用者資料
 
    - 若使用者 **先使用 Email 註冊**，後來又用 **Google 登入（相同 Email）**，此方法可以避免 `fullName` 被 Google `displayName` 覆蓋。
    - 若使用者 **先用 Google 註冊**，再用 **Apple 登入（相同 Email）**，則不會因為 Apple 沒有提供 `fullName` 而清空 `fullName`。

 3. 維持資料一致性
 
    - 記錄 `loginProvider`，確保後續登入時可以識別使用者最後一次使用的登入方式（例如讓使用者知道他先前是用 Google 登入的）。

 -------

 `* How：`
 
 - 主要步驟
 
 1. 取得 Firestore `users` collection 的對應 `document`
 
    ```swift
    let db = Firestore.firestore()
    let user = authResult.user
    let userRef = db.collection("users").document(user.uid)
    ```
 
    - `authResult.user.uid` 作為 Firestore 的 `document ID`。

 ---
 
 2. 檢查 `document` 是否已存在
 
    ```swift
    let document = try await userRef.getDocument()
 
    ```
    - 如果該 `uid` 已經存在，則不會覆蓋關鍵資料（如 `fullName`）。

 ---

 3. 如果使用者已存在，則僅更新 `loginProvider`，避免覆蓋其他登入方式的名稱
 
    ```swift
    if document.exists, var userData = document.data() {
        if let displayName = user.displayName, userData["fullName"] as? String == "" {
            userData["fullName"] = displayName
        }
        userData["loginProvider"] = "google"
        try await userRef.setData(userData, merge: true)
    }
    ```
 
    - 只有在 `fullName` 為空時，才會填入 Google `displayName`，避免覆蓋 Apple 或 Email 註冊的名稱。
    - **確保 `loginProvider = "google"`**，即使 `fullName` 沒有變更，也能記錄最新的登入方式。

 ---

 4. 如果使用者不存在，則建立新 `document`
 
    ```swift
    else {
        var userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "loginProvider": "google"
        ]
        
        if let displayName = user.displayName {
            userData["fullName"] = displayName
        }
        
        try await userRef.setData(userData, merge: true)
    }
    ```
 
    - 確保新的使用者有基本資訊（uid、email、loginProvider、fullName）。

 -------

`* 步驟`

 1.檢查使用者是否存在
 
    - 邏輯：`document.exists`
    - 目的：確保不覆蓋現有使用者資料

 2.避免覆蓋姓名
 
    - 邏輯：只在 `fullName` 為空時，才更新 `displayName`
    - 目的：避免不同登入方式（Google、Apple、Email）覆蓋資料

 3.更新登入方式
 
    - 邏輯：`loginProvider = "google"`
    - 目的：紀錄最新登入來源，避免後續登入混亂

 4.建立新用戶
 
    - 邏輯：`setData(userData, merge: true)`
    - 目的：確保 Firestore 存有 Google 註冊的使用者資訊

 -------

` * 結論`
 
 1. 透過 Firestore 確保 Google 登入成功後的使用者資料完整性
 2. 避免不同登入方式（Google、Apple、Email）互相覆蓋 `fullName`
 3. 記錄 `loginProvider`，確保未來登入方式的一致性
 4. 若 `fullName` 為空才更新 `displayName`，避免覆蓋 Email 或 Apple 註冊的名稱
 5. 新增用戶時確保 `uid`、`email`、`loginProvider` 不會遺漏

 */


// MARK: - signInWithGoogleSDK 筆記
/**
 
 ## signInWithGoogleSDK 筆記
 
 - `signInWithGoogleSDK` 為何將「解析 Google 登入錯誤」與「確保 `idToken` 和 `accessToken` 存在」分開處理。
 

 `* What`
 
 在 `GoogleSignInController` 的 `signInWithGoogleSDK` 方法中，錯誤處理被拆分成兩個獨立部分：

 1. 解析 Google 登入錯誤 (`parseGoogleSignInError`)
 
    - 負責解析 Google Sign-In SDK 回傳的錯誤，轉換為 `GoogleSignInError`，確保 UI 能正確顯示對應的錯誤訊息。

 2. 確保 `idToken` 和 `accessToken` 存在
 
    - 驗證 `result?.user` 是否為 `nil`，確保 `idToken` 和 `accessToken` 存在，若缺少則拋出 `invalidGoogleUser` 錯誤，防止 Firebase 登入失敗。

 -----------

 `* Why`
 
 1. 區分「SDK 錯誤」與「Google 資料完整性錯誤」
 
    - `parseGoogleSignInError` 處理**Google SDK 層級**的錯誤：
 
      - 使用者取消登入 (`userCancelled`)
      - 使用者拒絕授權 (`accessDenied`)
      - 其他 SDK 內部錯誤
 
    - `idToken` 與 `accessToken` 驗證是**Firebase 所需的驗證步驟**，確保 Google 回傳的資訊完整，而非 SDK 本身的錯誤。

 2. 符合「單一職責原則（SRP）」
 
    - `parseGoogleSignInError` **只負責解析錯誤**，不會涉及額外的邏輯，讓程式碼更清晰。
    - `idToken` 驗證只關心**確保登入資料完整**，與 SDK 本身錯誤無關。

 3. 錯誤處理語義更清楚
 
    - 若 `error != nil`，代表 SDK 本身發生錯誤，因此應該轉換為 `GoogleSignInError`。
    - 若 `idToken` 缺失，代表 Google 回傳的使用者資訊有問題，應該回傳 `invalidGoogleUser`。

 4. 增強可讀性與維護性
 
    - 若將錯誤解析與 `idToken` 檢查寫在一起，會讓程式碼變得**冗長且難以理解**。
    - 分開處理能者**更清楚知道不同錯誤的來源與處理方式**。

 ---

 `* How`
 
 -  `signInWithGoogleSDK` 的完整實作：

     ```swift
     private func signInWithGoogleSDK(presentingViewController: UIViewController) async throws -> (idToken: String, accessToken: String) {
         return try await withCheckedThrowingContinuation { continuation in
             DispatchQueue.main.async {
                 GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                     
                     /// 解析 Google 登入錯誤
                     if let error = self.parseGoogleSignInError(error) {
                         continuation.resume(throwing: error)
                         return
                     }
                     
                     /// 確保 `idToken` 和 `accessToken` 存在
                     guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                         continuation.resume(throwing: GoogleSignInError.invalidGoogleUser)
                         return
                     }
                     
                     continuation.resume(returning: (idToken, user.accessToken.tokenString))
                 }
             }
         }
     }
     ```

 ---
 
 - 解析錯誤的 `parseGoogleSignInError` 方法
 
     ```swift
     private func parseGoogleSignInError(_ error: Error?) -> GoogleSignInError? {
         guard let error = error as NSError? else { return nil }
         
         let errorDescription = error.localizedDescription.lowercased()
         
         if error.code == -5 {
             return .userCancelled
         } else if errorDescription.contains("access_denied") {
             return .accessDenied
         } else {
             return .firebaseSignInFailed(error)
         }
     }
     ```

 ---

 `* 總結`
 
 1. 解析 Google SDK 錯誤 (`parseGoogleSignInError`) 處理 SDK 本身的錯誤。
 2. 驗證 `idToken` 和 `accessToken` 是否存在 確保 Google 使用者登入資料完整性。
 3. 這種拆分符合「單一職責原則」與「清晰的錯誤語義」，讓程式碼更清楚、可讀性更好。
 */


// MARK: - (v)

import UIKit
import Firebase
import GoogleSignIn

/// `GoogleSignInController` 負責處理 Google 登入與 Firebase 驗證邏輯
///
/// - 主要職責:
///   1. 與 Google Sign-In SDK 交互: 呼叫 Google Sign-In SDK 來處理使用者登入流程
///   2. 取得 Google 登入憑證* 取得 `ID Token` 和 `Access Token` 以進行 Firebase 驗證
///   3. 與 Firebase 進行身份驗證: 使用 Google 憑證登入 Firebase
///   4. 將登入的使用者資料存入 Firestore
///
/// - 設計考量:
///   - 單例模式 (`shared`): 確保 `GoogleSignInController` 只有一個實例，避免重複初始化
///   - 非同步 (`async/await`): 以非同步方式處理登入流程，確保 UI 不會被阻塞
///   - 錯誤處理 (`GoogleSignInError`): 定義明確的錯誤類型，讓 UI 可以根據不同錯誤顯示適當訊息
class GoogleSignInController {
    
    /// 單例模式:  確保 `GoogleSignInController` 只有一個實例
    static let shared = GoogleSignInController()
    
    // MARK: - Public Methods
    
    /// 使用 Google 進行登入
    ///
    /// - 這個方法會調用 `GoogleSignInController` 來執行 Google 登入流程，並且使用 Firebase 進行身份驗證。
    ///
    /// - Parameters:
    ///   - presentingViewController: 呼叫 Google Sign-In UI 的視圖控制器
    ///
    /// - Returns: 登入成功的 `AuthDataResult`，包含 Firebase 用戶資料
    /// - Throws: 若登入過程中發生錯誤，拋出 `GoogleSignInError`
    @MainActor
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> AuthDataResult {
        
        /// 確保 Firebase `clientID` 存在
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleSignInError.missingClientID
        }
        
        /// 設定 Google Sign-In SDK
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        /// 呼叫 Google Sign-In SDK，取得 `idToken` 和 `accessToken`
        let result = try await signInWithGoogleSDK(presentingViewController: presentingViewController)
        
        /// 使用 Google 憑證建立 Firebase 登入資訊
        let credential = GoogleAuthProvider.credential(
            withIDToken: result.idToken,
            accessToken: result.accessToken
        )
        
        /// 執行 Firebase 登入
        return try await signInWithGoogleCredential(credential)
    }
    
    // MARK: - Private Methods
    
    /// 呼叫 Google Sign-In SDK 並取得登入資訊
    ///
    /// - 這個方法會調用 `GIDSignIn.sharedInstance.signIn` 來讓使用者登入 Google 帳號。
    /// - UIKit API 需要在主執行緒執行，因此 `DispatchQueue.main.async` 來確保 UI 相關操作發生在主執行緒。
    ///
    /// - Parameters:
    ///   - presentingViewController: 顯示 Google 登入 UI 的視圖控制器
    ///
    /// - Returns: Google 登入憑證 (`idToken` & `accessToken`)
    /// - Throws: 若登入失敗，拋出 `GoogleSignInError`
    private func signInWithGoogleSDK(presentingViewController: UIViewController) async throws -> (idToken: String, accessToken: String) {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                    
                    /// 解析 Google 登入錯誤
                    if let error = self.parseGoogleSignInError(error) {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    /// 確保 `idToken` 和 `accessToken` 存在
                    guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                        continuation.resume(throwing: GoogleSignInError.invalidGoogleUser)
                        return
                    }
                    
                    continuation.resume(returning: (idToken, user.accessToken.tokenString))
                }
            }
        }
    }
    
    /// 解析 Google 登入錯誤
    ///
    /// - Parameter error: Google Sign-In 回傳的錯誤
    /// - Returns: 對應的 `GoogleSignInError`，如果沒有錯誤則回傳 `nil`
    private func parseGoogleSignInError(_ error: Error?) -> GoogleSignInError? {
        guard let error = error as NSError? else { return nil }
        
        let errorDescription = error.localizedDescription.lowercased()
        
        if error.code == -5 {
            return .userCancelled
        } else if errorDescription.contains("access_denied") {
            return .accessDenied
        } else {
            return .firebaseSignInFailed(error)
        }
    }
    
    /// 使用 Google 憑證登入 Firebase
    ///
    /// - Parameters:
    ///   - credential: Google 提供的 Firebase 認證憑證
    ///
    /// - Returns: 登入成功的 `AuthDataResult`
    /// - Throws: 若 Firebase 登入失敗，拋出錯誤
    private func signInWithGoogleCredential(_ credential: AuthCredential) async throws -> AuthDataResult {
        let authResult = try await Auth.auth().signIn(with: credential)
        print("[GoogleSignInController]: 使用 Google 憑證登入成功")
        
        /// 存儲使用者資訊至 Firestore
        try await storeGoogleUserData(authResult: authResult)
        return authResult
    }
    
    /// 將 Google 使用者資料存入 Firestore
    ///
    /// - Parameters:
    ///   - authResult: Firebase 認證結果
    ///
    /// - Throws: 若存儲過程中發生錯誤，則拋出
    private func storeGoogleUserData(authResult: AuthDataResult) async throws {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        let document = try await userRef.getDocument()
        
        if document.exists, var userData = document.data() {
            /// 如果 `document 已存在`，則僅在 `fullName` 欄位為空時更新全名
            if let displayName = user.displayName, userData["fullName"] as? String == "" {
                print("[GoogleSignInController]: 更新已存在的使用者資料，Google 顯示名稱：\(displayName)")
                userData["fullName"] = displayName
            }
            userData["loginProvider"] = "google"
            try await userRef.setData(userData, merge: true)
            
        } else {
            /// 如果 `document 不存在`，則建立新的資料
            var userData: [String: Any] = [
                "uid": user.uid,
                "email": user.email ?? "",
                "loginProvider": "google"
            ]
            
            if let displayName = user.displayName {
                print("[GoogleSignInController]: 創建新使用者資料，Google 顯示名稱：\(displayName)")
                userData["fullName"] = displayName
            }
            
            try await userRef.setData(userData, merge: true)
        }
    }
    
}
