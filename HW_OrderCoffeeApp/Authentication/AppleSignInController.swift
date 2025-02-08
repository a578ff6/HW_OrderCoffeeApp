//
//  AppleSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/29.
//

// MARK: - 測試 Apple 部分
/**
 
 ## 測試 Apple 部分
 
` * Apple 不隱藏與 Email`
 
    - [v] 先 Apple 看有無真的存到資料，基本上要有資料。（資料修改沒問題）
    - [v] 先用 Email（a1202@gmail.com） 註冊登入，在用 Apple （a578ff6@gmail.com） ，基本上是兩個不同帳號。（資料修改沒問題）
    - [v] 先用 Email (a578ff6@gmail.com) 註冊登入，在用Apple （a578ff6@gmail.com） ，基本上會蓋過Email。（資料修改沒問題）
     - [v] 接著使用 Apple （a578ff6@gmail.com） ，在使用Goolge (a578ff6@gmail.com) ，基本上兩者可以互相登入。（資料修改沒問題）

 `* Apple隱藏與email`
 
    - [v] 先隱藏 Apple 看有無真的存到資料，基本上要有資料。（資料修改沒問題）
    - [v] Email（a578ff6@gmail.com） 跟隱藏 （a578ff6@gmail.com） Apple ，基本上要不能覆蓋並且可以各自登入才是正確。（資料修改沒問題）
    - [v] 先註冊 a1202@gmail.com ，在使用隱藏 Apple ，基本上不能夠覆蓋才是正確。（資料修改沒問題）
 */


// MARK: - 獲取並存儲 fullName
/**
 
 ## 獲取並存儲 fullName
 
` * 問題描述:`
 
    - 在最初的測試過程中，未能成功存取使用者的`fullName`，導致用戶資料不完整。
    - `Firebase` 官方文件建議使用`appleCredential(withIDToken:rawNonce:fullName:)來`傳遞`fullName`給`Firebase`，以確保用戶授權時的名字能夠正確存取。

 `* 解決方案:`
 
    - 在`authorizationController`中，使用`OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:)`來初始化憑證，並將`fullName`傳遞給`Firebase`。
    - 更新`storeAppleUserData`方法，將`fullName`包含在使用者資料中，以便在首次註冊時正確存取用戶的名字。


 `* 結論:`
 
    - 確保在首次註冊時，使用`OAuthProvider.appleCredential`傳遞用戶的fullName給Firebase。
    - 在儲存用戶資料時，包括`fullName`，以確保用戶資料完整。
 */


// MARK: - Apple 登入的特性
/**
 
 ## Apple 登入的特性
 
 `* 問題描述:`
 
    - Apple ID 登入只在首次註冊時返回完整的用戶資訊（名字和電子郵件）。再次登入時，Apple 不會再次提供這些資訊，因此可能導致資料庫中的名字變成空白。

 `* 解決方案:`
 
    - 在`首次註冊`時，確保完整地存取和儲存用戶的`fullName`和`電子郵件`。
    - 在再次登入時，從Firebase數據庫中讀取用戶的名字和其他資料，而不是依賴於Apple再次提供。

 `* 結論:`
 
    - 首次註冊時完整存取用戶資料，再次登入時從Firebase中獲取資料，以避免fullName丟失。
 */


// MARK: - 多重登入方式下的資料覆蓋問題
/**
 
 ## 多重登入方式下的資料覆蓋問題
 
 `* 問題描述:`
 
    - 當用戶使用相同電子郵件透過不同登入方式（如`Apple`和`Google`）登入時，會發生資料覆蓋問題，特別是`fullName`。

` * 解決方案:`
 
    - 在儲存用戶資料時，避免覆蓋已存在的`fullName`，僅在`fullName`為空時更新。
    - 在用戶資料中加入`loginProvider`，記錄每次登入的方式，以便後續處理時區分不同的登入方式。
 
 `* 結論:`
 
    - 通過避免覆蓋已存在的資料和加入`loginProvider`，來防止用戶資料在不同登入方式之間被覆蓋。
 */


// MARK: - 流程分析
/**
 
 ## 流程分析
 
 `* signInWithApple:`
 
    - 發起Apple登入請求，並在授權完成後處理結果。

 `* createAppleIDRequest:`
 
    - 建立Apple ID請求，包含請求的範疇（如fullName和email）。

 `* authorizationController(didCompleteWithAuthorization:):`
 
    - 處理授權成功後的邏輯，檢查用戶的電子郵件是否已存在於Firebase中，並進行相應處理。

 `* signInWithAppleCredential:`
 
    - 使用Apple憑證進行登入，並在成功後儲存用戶資料。

` * storeAppleUserData:`
 
    - 將用戶資料儲存到Firebase。若資料已存在，僅在fullName為空時更新fullName，並記錄loginProvider。
 */


// MARK: - AppleSignInController 中的 Apple ID 隱藏電子郵件處理
/**
 

 ## AppleSignInController 中的 Apple ID 隱藏電子郵件處理
 

` 1. Apple 提供的兩種電子郵件選擇`
    
 - 公開真實電子郵件地址:
 
    - 用戶選擇公開真實的電子郵件地址時，應用程序將直接使用此電子郵件來創建或鏈接Firebase帳戶。

 - 隱藏的中繼信箱（Relay Email）:
 
    - 如果用戶選擇隱藏其真實的電子郵件地址，Apple 會為該用戶生成一個隱藏的中繼信箱 （ 例如：12345abcde@privaterelay.appleid.com  ）。
    - 這個中繼信箱會將所有郵件轉發到用戶的真實信箱。因此，當用戶使用隱藏信箱登入時，應用接收到的將是這個隱藏的中繼信箱。
 
 ---
 
` 2. 處理隱藏信箱的邏輯`
 
 - 電子郵件檢查:
 
    - 當 `AppleSignInController` 接收到 `Apple ID` 的登入回應時，不論是隱藏的中繼信箱還是真實的電子郵件地址，系統都會檢查這個電子郵件是否已經存在於 Firebase 中。
 
 ---

 `3. 隱藏信箱的特色`
 
 - 隱私保護:
 
    - Apple 生成的隨機中繼信箱會自動轉發所有來自應用的郵件到用戶的真實信箱，從而保護用戶的隱私。
 
 - 唯一性:
 
    - 每個中繼信箱對應於單一應用，即使同一用戶在不同應用中選擇隱藏其真實郵件，生成的中繼信箱也會不同。
 */


// MARK: - randomNonceString(length: Int = 32)` 筆記
/**
 
 ### randomNonceString(length: Int = 32)` 筆記


 `* What`
 
 - `randomNonceString(length: Int = 32)` 是一個**用來生成隨機 Nonce (Number used once) 字串**的函式。這個函式：
 
    - 預設產生 32 個字元長度的**隨機字串**。
    - 使用 `SecRandomCopyBytes` 來確保隨機性。
    - 產出的字串包含**英數字元**與 `-._`，符合 Apple 登入安全規範。
    - 產生的 `nonce` 主要用於 Apple 登入，確保驗證請求的安全性。

 ---

 `* Why`
 
 - 在 Apple 登入時，**Nonce 的用途是防止重放攻擊**，確保登入請求的安全性：
 
 1. 驗證登入請求的唯一性
 
    - `nonce` 是「一次性隨機字串」，用於識別該次登入請求，避免駭客惡意重送舊的登入請求來偽造身分。
    
 2. 防止中間人攻擊（Man-in-the-Middle, MITM）
 
    - 在登入過程中，駭客可能會攔截請求並修改登入資訊。但 `nonce` 在登入時會透過 **SHA-256 雜湊**加密並送到 Apple 伺服器，讓攻擊者無法偽造登入。

 3. 符合 Firebase 與 Apple 登入安全標準
 
    - Firebase **要求 Apple 身分驗證需使用 SHA-256 雜湊過的 `nonce`**，因此 `randomNonceString()` 會搭配 `sha256(nonce)`，確保登入流程符合 Firebase 規範。

 ---

 `* How`
 
 1. 產生隨機 `nonce`
 
    ```swift
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("無法產生 nonce。SecRandomCopyBytes 失敗，錯誤代碼: \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    ```
 
    - 使用 `SecRandomCopyBytes` 來產生**高品質隨機數據**，確保 nonce 不會重複。
    - 轉換成 `charset` 字元集，確保字串符合 Firebase/Apple 的登入規範（大小寫字母、數字、`-._`）。

 ---
 
 2. 將 `nonce` 轉換為 SHA-256 雜湊格式
 
    ```swift
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
    ```
 
    - **使用 `CryptoKit.SHA256` 進行雜湊**，確保 Apple 伺服器無法解開 `nonce`，但仍可驗證該值是否正確。

 ---

 3. 應用於 Apple 登入
 
    ```swift
    let nonce = randomNonceString()
    currentNonce = nonce
    request.nonce = sha256(nonce)
    ```
 
    - **先生成 `nonce`**，並記錄起來（稍後驗證用）。
    - **傳送 SHA-256 加密後的 `nonce` 給 Apple**，確保登入流程安全。

 ---

 `* 總結`
 
 - `randomNonceString()` 主要用途：
 
    - 產生隨機 `nonce` 來**確保 Apple 登入請求的安全性**。
    - **防止中間人攻擊**，避免舊的登入請求被惡意重送。
    - **符合 Firebase 與 Apple 的安全規範**，確保驗證請求的唯一性。
 */


// MARK: - AppleSignInController 筆記
/**
 
 ### AppleSignInController 筆記

 - https://reurl.cc/WAZq9D

 `* What:`
 
 - `AppleSignInController` 是負責處理 Apple 登入流程的 Singleton 類別。
 - 它負責管理 `ASAuthorizationController` 來進行 Apple 登入，並將驗證結果與 Firebase 整合。

 - 主要功能包括：
 
    - 建立 Apple 登入請求 (`ASAuthorizationController`)
    - 驗證 Apple 身分憑證 (`ASAuthorizationAppleIDCredential`)
    - 與 Firebase 進行身份驗證 (`Auth.auth().signIn`)
    - 將 Apple 使用者資訊儲存到 Firestore

 -------
 
 `* Why:`
 
 1. 集中管理 Apple 登入邏輯
 
    - Apple 登入流程涉及多個步驟，包括請求、驗證、錯誤處理等。
    - 透過 `AppleSignInController` 來統一管理，確保程式碼的可維護性。

 2. 支援 `async/await` 的非同步登入
 
    - Apple 登入 API 為 Delegate-based，透過 `CheckedContinuation` 來支援 `async/await`，提升可讀性。

 3. 減少 ViewController 負責的業務邏輯
 
    - `LoginViewController` 只需呼叫 `AppleSignInController.shared.signInWithApple()`，而不需管理 Apple 登入的內部細節。

 4. 統一錯誤處理
 
    - 透過 `AppleSignInError` 封裝 Apple 登入的錯誤類型，確保不同錯誤有一致的處理方式。

 -------

 `* How: `

 - 登入流程概覽：
 
    1. 建立 `ASAuthorizationAppleIDRequest`，並設定 `nonce`。
    2. `ASAuthorizationController` 執行 Apple 登入請求。
    3. Apple 登入成功後，取得 `identityToken` 並轉換為 Firebase 認證憑證。
    4. Firebase 進行登入 (`Auth.auth().signIn(with:)`)。
    5. 儲存或更新 Firestore 中的使用者資料。

 ---

 - 程式碼架構：
 
    - `signInWithApple(presentingViewController:)`發送 Apple 登入請求
    - `createAppleIDRequest()`:建立 Apple 登入請求，並生成 `nonce
    - `signInWithAppleCredential(_:, fullName:)` 使用 Apple 憑證登入 Firebase
    - `storeAppleUserData(authResult:, fullName:)`  將 Apple 使用者資訊存入 Firestore
    - `authorizationController(controller:didCompleteWithAuthorization:)` Apple 登入成功的回調
    - `authorizationController(controller:didCompleteWithError:)` Apple 登入失敗的回調

 ---

 - 關鍵程式碼
 
     ```swift
     func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
         guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let nonce = currentNonce,
               let appleIDToken = appleIDCredential.identityToken,
               let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
             continuation?.resume(throwing: AppleSignInError.missingIdentityToken)
             return
         }
         
         let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
         
         Task {
             do {
                 let authResult = try await self.signInWithAppleCredential(credential, fullName: appleIDCredential.fullName)
                 continuation?.resume(returning: authResult)
             } catch {
                 continuation?.resume(throwing: AppleSignInError.firebaseSignInFailed(error))
             }
         }
     }
     ```

 -------

 `* 總結`
 
 1.`AppleSignInController` 將 Apple 登入相關邏輯封裝為單一類別，使程式碼更易讀、易維護。
 2. 透過 `async/await` 提供更直覺的登入流程，減少 `delegate` 帶來的複雜性。
 3. `AppleSignInError` 提供統一的錯誤分類與處理，避免不必要的錯誤訊息干擾使用者。
 4. `authorizationController(controller:didCompleteWithError:)` 可針對不同錯誤進行適當處理，提升使用者體驗。

 */


// MARK: - authorizationController(controller:didCompleteWithAuthorization:) 筆記
/**
 
 ### authorizationController(controller:didCompleteWithAuthorization:) 筆記

 
 `* What`
 
 - `authorizationController(controller:didCompleteWithAuthorization:)` 是 `ASAuthorizationControllerDelegate` 的回調方法。

    - 當 Apple 登入成功時，系統會透過此方法回傳 `ASAuthorization` 物件，
    - 開發者需要解析 Apple 身分驗證憑證 (`ASAuthorizationAppleIDCredential`)，
    - 並將其轉換為 Firebase 可用的登入憑證 (`AuthCredential`) 以完成 Firebase 身分驗證。

 ---------

 `* Why`
 
 1. 負責 Apple 登入後的憑證處理
 
    - 解析 `ASAuthorizationAppleIDCredential`，取得 `identityToken` 和 `nonce`。
    - 驗證 `nonce`，確保安全性。
    
 2. 將 Apple 憑證轉換為 Firebase OAuth 憑證
 
    - Apple 身分驗證不會直接連結 Firebase，因此需要使用 `OAuthProvider.credential` 來建立 Firebase 憑證。
    
 3. 異步處理 Firebase 登入
 
    - 透過 `Task {}` 來確保 Firebase 登入與 Firestore 操作不會影響 UI 反應速度。
    
 4. 錯誤處理與安全性
 
    - 若 Apple 未提供 `identityToken`，則無法進行 Firebase 登入，需要拋出 `.missingIdentityToken` 錯誤。
    - 若 Firebase 登入失敗，則應該明確拋出 `.firebaseSignInFailed(error)` 以便後續處理。
    
 ---------

 `* How `

 - 流程概述
 
    1. 確保 `authorization.credential` 是 `ASAuthorizationAppleIDCredential`。
    2. 取得 `nonce`，確保安全性。
    3. 從 Apple 憑證 (`ASAuthorizationAppleIDCredential`) 取得 `identityToken`。
    4. 將 `identityToken` 轉換為 Firebase `OAuthCredential`。
    5. 使用 Firebase 登入 (`signInWithAppleCredential`)。
    6. 若登入成功，回傳 `AuthDataResult`，否則拋出錯誤。

 - 程式碼實作
 
     ```swift
     /// Apple 登入成功時的回調
     ///
     /// - 解析 Apple 身分驗證憑證 (`ASAuthorizationAppleIDCredential`)
     /// - 轉換 `identityToken` 為 Firebase OAuth 憑證
     /// - 透過 Firebase 進行 Apple 登入
     ///
     /// - Parameter controller: `ASAuthorizationController` 實例
     /// - Parameter authorization: Apple 登入成功後的 `ASAuthorization` 物件
     func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
         
         // 取得 Apple 登入憑證
         guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let nonce = currentNonce, // 驗證 `nonce` 以確保請求安全性
               let appleIDToken = appleIDCredential.identityToken, // 取得 Apple 身分驗證令牌
               let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
             
             // 若 `identityToken` 缺失，拋出 `missingIdentityToken` 錯誤
             continuation?.resume(throwing: AppleSignInError.missingIdentityToken)
             return
         }
         
         // 建立 Firebase OAuth 憑證
         let credential = OAuthProvider.credential(
             withProviderID: "apple.com",
             idToken: idTokenString,
             rawNonce: nonce
         )
         
         // 執行 Firebase 登入
         Task {
             do {
                 // 透過 Firebase 進行 Apple 登入
                 let authResult = try await self.signInWithAppleCredential(credential, fullName: appleIDCredential.fullName)
                 
                 // 登入成功後，回傳 `AuthDataResult`
                 continuation?.resume(returning: authResult)
             } catch {
                 // 若 Firebase 登入失敗，拋出 `.firebaseSignInFailed(error)`
                 continuation?.resume(throwing: AppleSignInError.firebaseSignInFailed(error))
             }
         }
     }
     ```

 ---------

 `* 總結`
 
 1. `authorizationController(controller:didCompleteWithAuthorization:)` 是 Apple 登入成功後的回調，負責驗證憑證並登入 Firebase。
 2. 確保 `nonce` 與 `identityToken` 存在，以防止登入失敗。
 3. 使用 Firebase 進行登入，並處理潛在錯誤，以提升使用者體驗。
 4. 異步執行 (`Task {}`) 確保流暢的使用者體驗，避免 UI 卡頓。
 */


// MARK: - storeAppleUserData 筆記

/**
 
 ### storeAppleUserData 筆記

 `* What:`
 
 - `storeAppleUserData(authResult:fullName:)` 是一個負責將 Apple 登入成功後的使用者資訊儲存至 Firestore 的方法。

    - 透過 Firebase Authentication 取得 `AuthDataResult`，包含 UID 和使用者基本資訊。
    - 根據 `fullName` 參數，更新 Firestore 使用者文件。
    - 確保 Apple 使用者的登入方式 (`loginProvider`) 被標記為 `apple`。
    - 若使用者首次登入，則建立新文件；若已存在，則合併資料。

 --------------
 
` * Why:`
 
 1. 確保使用者資料完整性
 
    - Apple 登入可能只提供 `email` 和 `fullName`（且僅首次登入可獲取全名），需妥善保存這些資訊。
    
 2. 支援新舊使用者
 
    - 新使用者：建立 Firebase 文件，確保首次登入時有完整的紀錄。
    - 舊使用者：若 `fullName` 為空，則不覆蓋原有資料。
    
 3. 標記登入方式
 
    - Firestore 內的 `loginProvider` 記錄為 `apple`，以支援多種登入方式（如 Google、Email）。
    
 4. 減少不必要的寫入操作
 
    - 透過 `merge: true` 更新 Firestore，確保不會覆蓋其他登入方式的資料。

 --------------

 `* How: `

 - 資料儲存邏輯
 
     ```swift
     private func storeAppleUserData(authResult: AuthDataResult, fullName: PersonNameComponents?) async throws {
         print("[AppleSignInController]: 開始儲存用戶資料到 Firestore。")
         let db = Firestore.firestore()
         let user = authResult.user
         let userRef = db.collection("users").document(user.uid)
         
         let document = try await userRef.getDocument()
         
         if document.exists, var userData = document.data() {
             print("[AppleSignInController]: 用戶資料已存在，更新資料。")
             
             // 如果全名存在且當前資料中 fullName 為空，則更新 fullName
             if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                 if userData["fullName"] as? String == "" {
                     userData["fullName"] = "\(familyName) \(givenName)"
                 }
             }
             userData["loginProvider"] = "apple"
             try await userRef.setData(userData, merge: true)
             
         } else {
             print("[AppleSignInController]: 用戶資料不存在，創建新資料。")
             
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
     ```


 --------------

 `* 流程圖`
 
    1. 取得 `AuthDataResult`
    2. 嘗試獲取 Firestore 內是否已有使用者資料
    3. 若資料已存在，則檢查 `fullName` 並更新 `loginProvider`
    4. 若資料不存在，則建立新文件，包含 `uid`、`email`、`fullName`（若有）
    5. 使用 `merge: true` 確保不覆蓋其他登入方式的資料

 --------------

 `* 總結`
 
    1. `storeAppleUserData` 確保 Apple 登入的使用者資訊被正確儲存或更新至 Firestore。
    2. 若使用者已存在，僅更新 `fullName`（若適用）與 `loginProvider`，避免覆蓋其他重要資料。
    3. 透過 `merge: true` 確保 Firestore 內的其他資料不會被覆寫，確保資料完整性。
    4. 使用 `async/await` 處理 Firebase 非同步寫入，提高可讀性與錯誤處理能力。

 */



// MARK: - (v)

import UIKit
import Firebase
import AuthenticationServices
import CryptoKit

/// 負責 Apple 登入流程的 Controller，使用 Singleton 模式提供統一管理
///
/// 主要功能：
/// - 建立 Apple 登入請求，處理 `ASAuthorizationController`
/// - 使用 Apple 身分驗證憑證與 Firebase 進行登入
/// - 儲存或更新 Apple 使用者資料至 Firestore
class AppleSignInController: NSObject {
    
    /// Singleton 實例，確保 Apple 登入的處理方式統一
    static let shared = AppleSignInController()
    
    // MARK: - Property
    
    /// Apple 登入請求使用的 `nonce`（用於防止中間人攻擊）
    private var currentNonce: String?
    
    /// 用於將非同步 Apple 登入流程與 Swift `async/await` 兼容
    private var continuation: CheckedContinuation<AuthDataResult, Error>?
    
    
    // MARK: - Public Methods
    
    /// 開始 Apple 登入流程
    ///
    /// - Parameter presentingViewController: 觸發 Apple 登入的視圖控制器，Apple 彈出視窗將顯示於此
    /// - Throws: 若登入過程發生錯誤，拋出相應的 `Error`
    /// - Returns: 登入成功的 `AuthDataResult`，包含用戶資訊
    func signInWithApple(presentingViewController: UIViewController) async throws -> AuthDataResult {
        print("[AppleSignInController]: 開始 Apple 登入流程")
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        /// 使用 `withCheckedThrowingContinuation` 來封裝 `ASAuthorizationController` 非同步行為
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Private Methods
    
    /// 建立 Apple ID 登入請求，並生成 `nonce` 進行加密處理
    ///
    /// - Returns: 設定好的 `ASAuthorizationAppleIDRequest` 物件
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        print("[AppleSignInController]: 建立 Apple ID 請求")
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        /// 請求獲取使用者的 `fullName` 和 `email`
        request.requestedScopes = [.fullName, .email]
        
        /// 生成 nonce 並進行 SHA256 加密
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        return request
    }
    
    /// 使用 Apple 憑證登入 Firebase
    ///
    /// - Parameters:
    ///   - credential: Apple 身分驗證憑證 (`AuthCredential`)
    ///   - fullName: Apple 提供的使用者全名（可能為 `nil`）
    /// - Throws: Firebase 登入過程中發生的任何錯誤
    /// - Returns: 成功登入後的 `AuthDataResult`
    private func signInWithAppleCredential(_ credential: AuthCredential, fullName: PersonNameComponents?) async throws -> AuthDataResult {
        let authResult = try await Auth.auth().signIn(with: credential)
        print("[AppleSignInController]: Apple 登入成功，UID：\(authResult.user.uid)")
        try await storeAppleUserData(authResult: authResult, fullName: fullName)
        return authResult
    }
    
    /// 儲存 Apple 使用者資訊至 Firestore
    ///
    /// - Parameters:
    ///   - authResult: Firebase 登入結果
    ///   - fullName: Apple 提供的使用者全名（可選）
    /// - Throws: Firestore 資料存取過程中可能發生的錯誤
    private func storeAppleUserData(authResult: AuthDataResult, fullName: PersonNameComponents?) async throws {
        print("[AppleSignInController]: 開始儲存用戶資料到 Firestore。")
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        let document = try await userRef.getDocument()
        
        if document.exists, var userData = document.data() {
            print("[AppleSignInController]: 用戶資料已存在，更新資料。")
            if let fullName = fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
                if userData["fullName"] as? String == "" {
                    userData["fullName"] = "\(familyName) \(givenName)"
                }
            }
            userData["loginProvider"] = "apple"
            try await userRef.setData(userData, merge: true)
            
        } else {
            print("[AppleSignInController]: 用戶資料不存在，創建新資料。")
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
    
    /// 指定 Apple 登入彈出視窗的顯示視窗
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }

    // MARK: - Private Helper Methods

    /// 生成隨機的 nonce 字串
    ///
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
    ///
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
    
    /// Apple 登入成功時的回調方法
    ///
    /// 當 Apple 登入成功後，會透過此方法取得 `ASAuthorizationAppleIDCredential`，
    /// 並將其轉換為 Firebase 可用的憑證 (`AuthCredential`) 進行登入。
    ///
    /// - 主要流程：
    ///   1. 取得 Apple 驗證憑證 (`ASAuthorizationAppleIDCredential`)
    ///   2. 檢查 `nonce` 是否有效，確保安全性
    ///   3. 取得並解析 Apple 提供的 `identityToken`
    ///   4. 轉換為 Firebase `OAuthCredential`
    ///   5. 使用 Firebase 進行登入 (`signInWithAppleCredential`)
    ///   6. 儲存使用者資訊至 Firestore
    ///   7. 如果登入成功，回傳 `AuthDataResult`，否則拋出錯誤
    ///
    /// - Parameter controller: Apple 登入的 `ASAuthorizationController` 實例。
    /// - Parameter authorization: Apple 登入成功後返回的 `ASAuthorization` 物件，包含驗證憑證。
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        /// 嘗試從 Apple 驗證回應中取得 Apple ID 憑證
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            continuation?.resume(throwing: AppleSignInError.missingIdentityToken)
            return
        }
        
        /// 使用 Apple 登入提供的 Token 與 `nonce` 建立 Firebase OAuth 憑證
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        /// 啟動 Firebase 登入流程
        Task {
            do {
                let authResult = try await self.signInWithAppleCredential(credential, fullName: appleIDCredential.fullName)
                continuation?.resume(returning: authResult)
            } catch {
                continuation?.resume(throwing: AppleSignInError.firebaseSignInFailed(error))
            }
        }
    }
    
    /// 當 Apple 登入失敗時的回調方法
    ///
    /// 這個方法會捕捉 `ASAuthorizationController` 在 Apple 登入過程中的錯誤，並進行適當的錯誤分類與處理。
    ///
    /// - 主要處理錯誤類型:
    ///   - `.canceled`: 使用者手動取消登入，記錄 Log，不顯示錯誤訊息。
    ///   - `.unknown`: 使用者未登入 Apple ID，記錄 Log，不顯示錯誤訊息。
    ///   - 其他錯誤: 將錯誤上拋，以便進一步處理。
    ///
    /// - Parameter controller: Apple 登入的 `ASAuthorizationController` 實例。
    /// - Parameter error: Apple 登入過程中發生的錯誤。
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("[AppleSignInController]: Apple 登入失敗: \(error)")
        
        if let appleError = error as? ASAuthorizationError {
            switch appleError.code {
            case .canceled:
                print("[AppleSignInController]: 使用者取消 Apple 登入，無需顯示錯誤訊息。")
                continuation?.resume(throwing: AppleSignInError.userCancelled)
                return
            case .unknown:
                print("[AppleSignInController]: 使用者未登入 Apple ID，無需顯示錯誤訊息。")
                continuation?.resume(throwing: AppleSignInError.appleIDNotSignedIn)
                return
            default:
                break
            }
        }
        
        continuation?.resume(throwing: error)
    }
    
}
