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
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 （ 該部分的 linkAppleCredential 已被廢除，commit 為 1410254 ）
 
 D. Apple Sign-In 也需要處理將身份驗證提供者（如 Apple、Google、電子郵件和密碼等）憑證與現有的 Firebase 使用者帳號進行關聯。
    - 使用戶可以通過任何已關聯的身份驗證方式登入同一個 Firebase 帳號。這樣可以確保用戶在切換身份驗證方式時，仍然能夠訪問同一個帳號和數據。
    - 這樣可以確保用戶無論使用哪種身份驗證方式登入，都能訪問到同一個 Firebase 帳戶和數據。
 
 * 流程：（雖然我解決完 Google 憑證處理的時候，就發現 apple 登入也沒問題。但是卻無法處理 loginProvider 的部分，因此決定完善。）
    -  signInWithApple： 發起 Apple 登入請求。
    -  linkAppleCredential： 將 Apple 憑證與現有帳戶關聯，或者如果連結失敗，則使用 Apple 憑證進行登入。
    -  signInWithAppleCredential： 使用 Apple 憑證進行登入。
    -  storeAppleUserData： 將 Apple 使用者資料儲存到 Firestore 中，並且僅在需要時更新全名。
 
 （新的解決方案，可參考 E 部分）
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 E. Apple 可以用相同的信箱帳號去鏈接已經由 Google 、Email 註冊的相同信箱帳號。並且不會出現重複錯誤問題。
        - 在 AppleSignInController 中，當使用者使用 Apple 登入且該電子郵件地址已經由 Google 或 Email 註冊過時，系統會嘗試將 Apple 的憑證與現有帳號進行鏈接。
        - 如果鏈接成功，則可以避免出現重複的帳號問題，並且不會出現錯誤。這樣，使用者可以透過 Apple、Google 或 Email 使用相同的電子郵件地址來登入同一個帳號，而不會出現重複的帳號或登入錯誤。
        - 這樣的處理方式使得不同登入方式的憑證可以整合到一個帳號中，提供了更好的用戶體驗。
 
 * AppleSignInController 流程分析：
 
 1. 開始 Apple 登入流程
    - 當使用者點擊 Apple 登入按鈕時，呼叫 signInWithApple(presentingViewController:completion:)。
    - 會初始化 Apple 登入流程，並設置一個回調 signInCompletion 來處理登入完成後的結果。
 
 2. 建立 Apple ID 請求
    - createAppleIDRequest() 方法會建立並配置 Apple ID 請求，包含請求的範疇（如取得使用者的全名和電子郵件）。
    - 使用 randomNonceString() 生成一個隨機的 nonce，並用 sha256 進行編碼，設置為請求的 nonce 以提高安全性。
 
 3. 處理登入授權
    - 當使用者授權後，authorizationController(didCompleteWithAuthorization:) 會被觸發。
    - 此方法中，若 Apple 提供了電子郵件，會檢查該電子郵件是否已存在於 Firebase 中 (handleExistingAccount)。
    - 若沒有提供電子郵件，則直接使用 Apple 憑證進行登入 (signInWithAppleCredential)。
 
 4. 檢查並處理已存在的帳號
    - handleExistingAccount(email:credential:fullName:completion:) 會檢查 Firebase 中是否已有該電子郵件的帳號。
    - 使用 fetchSignInMethods(forEmail:) 來檢查現有的登入方法。
    - 若該電子郵件已被使用，則嘗試將 Apple 憑證鏈結到現有帳號 (linkAppleCredentialToExistingAccount)。
    - 若該電子郵件未被使用，則直接使用 Apple 憑證登入 (signInWithAppleCredential)。
 
 5. 鏈結 Apple 憑證到現有帳號
    - linkAppleCredentialToExistingAccount(email:credential:completion:) 會將 Apple 憑證鏈結到已登入的 Firebase 使用者帳號。
    - 若鏈結成功，則更新 Firebase 中的使用者資料，並將 loginProvider 設為 apple。
 
 6. 儲存使用者資料
    - storeAppleUserData(authResult:fullName:completion:) 會將 Apple 使用者的資料儲存到 Firestore。
    - 若該使用者已經存在，則更新現有資料；若不存在，則創建新資料。
 
 7. 登入與錯誤處理
    - signInWithAppleCredential 方法會直接使用 Apple 憑證登入 Firebase。
    - 若登入或鏈結過程中出現錯誤，則呼叫 signInCompletion 回調，並傳遞錯誤資訊。
 
 8. 輔助方法
    - randomNonceString 和 sha256 方法用於生成並編碼 nonce，以提高登入過程的安全性。
    - presentationAnchor(for:) 方法提供了 Apple 登入視窗的展示視圖，通常是當前的應用視窗。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

* 測試 Apple 部分

 * Apple 隱藏與 Email （a578ff6@gmail.com） or 不同的Email
    - [v] 先 隱藏Apple 看有無真的存到資料，基本上要有資料。
    - [v] Email （a578ff6@gmail.com） 跟 隱藏Apple （a578ff6@gmail.com） ，基本上要不能鏈結並且可以各自登入才是正確。
    - [v] 先 Email註冊 （a1202@gmail.com） 不同信箱，在使用 隱藏Apple （a578ff6@gmail.com） ，基本上不能夠鏈接才是正確。

 * Apple不隱藏 與 Email （a578ff6@gmail.com）
    - [v] 先 Apple 看有無真的存到資料，基本上要有資料。
    - [v] 先 Email註冊 （a1202@gmail.com） 不同信箱，在使用（ a578ff6@gmail.com ）Apple ，信箱不同，不能鏈接。
    - [v] 先 Email （a578ff6@gmail.com） 註冊，在使用（ a578ff6@gmail.com ）Apple ，信箱相同，基本上提供方跟資料都不會被覆蓋，以及都能夠登入，並且鏈接。（鏈接）
 
 * 補充 Email > Apple > Google 鏈接：
    - [v] 先 Email （a578ff6@gmail.com） 註冊，在使用（ a578ff6@gmail.com ）Apple，之後在用 Google（ a578ff6@gmail.com ），基本上可以鏈接，以及都能夠登入，並且不會有錯誤。
 
 * Apple不隱藏 與 Google (a578ff6@gmail.com)
    - [v] 先 Google (a578ff6@gmail.com) 註冊，在使用（ a578ff6@gmail.com ）Apple 鏈接。基本上要可以鏈接成功，並且不覆蓋，以及不會有重複錯誤，且都可以登入。
 
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 F. 在 AppleSignInController 中，針對使用 Apple ID 登入時，Apple 提供了兩種電子郵件選擇：公開真實電子郵件地址或使用隱藏的中繼信箱（relay email）。以下是關於這部分處理的說明：
 
 ### 隱藏 Apple ID 的處理
    * Apple 提供的隱藏信箱：
        - 如果使用者選擇隱藏其真實的電子郵件地址，Apple 會為該使用者生成一個隱藏的中繼信箱，這個中繼信箱會將所有郵件轉發到使用者的真實信箱。
        - 因此，當使用者使用隱藏信箱登入時， App 接收到的將是這個隱藏的中繼信箱。

    * 處理隱藏信箱的邏輯：
        - 當 AppleSignInController 接收到 Apple ID 的登入回應時，如果 Apple 提供了電子郵件地址（無論是隱藏的還是真實的），控制器會檢查這個電子郵件是否已經存在於 Firebase 中。
        - 如果該電子郵件已經存在，系統會嘗試將 Apple 的憑證鏈接到現有的帳號。這樣，不論是隱藏信箱還是真實信箱，都可以與現有的帳號進行整合，避免重複帳號的問題。
        - 如果 Apple 沒有提供電子郵件（例如，使用者在已經存在的 Apple ID 基礎上再次登入），系統會直接使用憑證進行登入，而不進行額外的電子郵件檢查。

    * 中繼信箱的特色：
        - 隱私保護：Apple 會生成一個隨機的電子郵件地址來代替使用者的真實郵件。這個中繼信箱會自動轉發所有來自 App 的郵件到使用者的真實信箱，從而保護使用者的隱私。
        - 唯一性：每個中繼信箱對應於 單一App，即使同一個使用者在不同 App 中選擇隱藏其真實郵件，生成的中繼信箱也會不同。
        - 鏈接問題：由於中繼信箱是唯一且專屬於某個 App 的，因此在 APp中使用隱藏信箱進行登入和鏈接時，會遇到一些特殊情況。
                  (例如，如果使用者先使用 Google 登入，然後再使用隱藏信箱的 Apple ID 登入，會出現無法正確鏈接帳號的情況，因為這兩者的電子郵件地址不同。)
 
    * EX:
        - 假設用戶的真實電子郵件地址是 user@example.com ，在使用 Apple 隱藏信箱功能時，App 會得到一個類似於 12345abcde@privaterelay.appleid.com 的中繼電子郵件地址。
        - 每次該用戶使用 Apple 隱藏信箱功能來登入 App 時，都會得到這個相同的中繼電子郵件地址 12345abcde@privaterelay.appleid.com。

    * 結論
        - 在 AppleSignInController 中，已經處理了 Apple ID 的隱藏信箱登入。
        - 系統會根據 Apple 提供的電子郵件（隱藏或真實）來進行帳號鏈接或直接登入，確保使用者可以使用不同的提供方（Google、Email、Apple）來安全地登入同一個帳號。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------


 */




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




// MARK: - fetchSignInMethods運用： Apple 可以用相同的信箱帳號去鏈接已經由 Google 、Email 註冊的相同信箱帳號。並且不會出現重複錯誤問題。（E）

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

