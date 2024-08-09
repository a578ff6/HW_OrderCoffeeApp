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
 
 （ 該部分的 linkAppleCredential、signInWithAppleCredential 已被廢除，commit 為 1410254 ）
 
 D. Apple Sign-In 也需要處理將身份驗證提供者（如 Apple、Google、電子郵件和密碼等）憑證與現有的 Firebase 使用者帳號進行關聯。
    - 使用戶可以通過任何已關聯的身份驗證方式登入同一個 Firebase 帳號。這樣可以確保用戶在切換身份驗證方式時，仍然能夠訪問同一個帳號和數據。
    - 這樣可以確保用戶無論使用哪種身份驗證方式登入，都能訪問到同一個 Firebase 帳戶和數據。
 
 * 流程：（雖然我解決完 Google 憑證處理的時候，就發現 apple 登入也沒問題。但是卻無法處理 loginProvider 的部分，因此決定完善。）
    -  signInWithApple： 發起 Apple 登入請求。
    -  linkAppleCredential： 將 Apple 憑證與現有帳戶關聯，或者如果連結失敗，則使用 Apple 憑證進行登入。
    -  signInWithAppleCredential： 使用 Apple 憑證進行登入。
    -  storeAppleUserData： 將 Apple 使用者資料儲存到 Firestore 中，並且僅在需要時更新全名。
 
 （原因）### 關於 D部分，在處理 Apple 隱藏帳號後，發現這部分的處理邏輯會與接續使用 電子信箱註冊 發生衝突 ###
    - 因為它沒有處理隱藏信箱與真實信箱之間的映射關係，導致當用戶使用相同的真實電子郵件地址註冊或登入時，會出現帳號重複的問題。
 
    * 隱藏信箱的第一次登入：
        - 當用戶第一次使用 Apple 隱藏信箱登入時，Firebase 會創建一個新的帳戶，並使用 Apple 提供的中繼信箱（ 5zs4z7fs2v@privaterelay.appleid.com ）作為該帳戶的電子郵件地址。
 
    * 真實信箱的後續註冊：
        - 如果該用戶之後使用其真實電子郵件地址（ a12345@gmail.com ）進行註冊，由於 Firebase 並不知道這兩個電子郵件地址屬於同一個用戶，它會創建一個新的帳戶。這會導致用戶擁有兩個不同的帳戶，並且無法鏈接在一起。
 
    * 隱藏信箱與真實信箱的衝突：
        - 當用戶再次使用 Apple 隱藏信箱登入時，Firebase 會檢查該中繼信箱是否已存在於另一個帳戶中。如果存在，會出現 Duplicate credential received 錯誤。也因此導致bug。
 
 （解決方案，可參考 E 部分）
    - 通過將隱藏信箱與真實信箱之間的映射存儲在 Firestore 中，以便在用戶使用真實電子郵件地址進行註冊或登入時，可以正確地將這些帳戶鏈接在一起。
    
    * 隱藏信箱與真實信箱映射（存取中繼電子郵件地址）：
        - 當用戶第一次使用 Apple 隱藏信箱登入時，會將隱藏信箱與真實信箱的映射存儲在 Firestore 中。 這樣，在用戶使用真實電子郵件註冊或登入時，可以正確地識別和鏈接這些帳戶。
    
    * 統一管理多個身份驗證提供者：
        - 確保了在使用不同身份驗證提供者（如 Apple、Google、電子郵件/密碼）時，能夠正確地管理和鏈接用戶帳戶，避免了重複創建帳戶的問題。
 
    * 總結：
        - D 寫法 在處理 Apple 隱藏信箱時確實可能會產生衝突，因為它沒有考慮到隱藏信箱與真實信箱之間的映射關係。
        - E 寫法 通過在 Firestore 中儲存隱藏信箱與真實信箱的映射，解決了這個問題，確保用戶能夠順利地使用不同的身份驗證提供者進行登入和註冊。
 
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 E. Apple 隱藏信箱處理流程：
 
    * 發起 Apple 登入請求：
        - 當用戶點擊 Apple 登入按鈕時， App 會創建一個 Apple ID 請求，請求用戶的全名和電子郵件。

    * 進行身份驗證：
        - 使用 ASAuthorizationController 進行身份驗證，驗證成功後返回 Apple ID 憑證。

    * 處理身份驗證結果：
        - 如果是首次登入（Apple ID 憑證包含電子郵件），則提示用戶輸入真實電子郵件，並進行隱藏信箱和真實信箱的映射。
        - 如果不是首次登入，則直接使用返回的隱藏信箱進行操作。
 
    * 儲存用戶數據：
        - 將用戶的相關數據（包括隱藏信箱和真實信箱的映射）儲存到 Firebase Firestore 中。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 E_1. 中繼信箱特色說明：
 
    * 使用 Apple 隱藏信箱：
        - 當用戶使用 Apple 隱藏信箱功能來註冊或登入 App 時，Apple 會生成一個唯一的中繼電子郵件，該郵件會轉發到用戶的真實電子郵件地址。
        - 同一個 Apple ID 和 App ，每次使用 Apple 隱藏信箱功能都會得到相同的中繼電子郵件。
 
    * 為什麼會這樣：
        - 唯一性：確保每個 App 和用戶的中繼電子郵件是唯一的，以便 App 能夠識別同一用戶的多次登入。
        - 隱私保護：中繼電子郵件會轉發到用戶的真實電子郵件，但 App 無法直接訪問用戶的真實電子郵件地址。
        - 一致性：對於同一個用戶來說，保持中繼電子郵件地址的一致性可以確保 App 能夠正確識別和管理用戶的帳號。
 
    * 處理方式：
        - 在 App 中，利用中繼電子郵件與真實電子郵件的映射來處理不同的身份驗證提供者。
        - 當用戶使用 Apple 隱藏信箱註冊後，可以將中繼電子郵件地址和真實電子郵件地址映射起來，避免重複註冊的問題。
 
    * EX:
        - 假設用戶的真實電子郵件地址是 user@example.com ，在使用 Apple 隱藏信箱功能時，App 可能會得到一個類似於 12345abcde@privaterelay.appleid.com 的中繼電子郵件地址。
        - 每次該用戶使用 Apple 隱藏信箱功能來登入 App 時，都會得到這個相同的中繼電子郵件地址 12345abcde@privaterelay.appleid.com。
 
    * 這邊利用這一特性：
        - 在 App 中，利用這一特性來處理不同的身份驗證提供者。（因為我有設置email、google、apple註冊登入）
        - 例如，可以在用戶使用 Apple 隱藏信箱註冊後，將中繼電子郵件地址和用戶的真實電子郵件地址映射起來，這樣在用戶後續使用真實電子郵件地址註冊時，可以識別出這個電子郵件已經被註冊過，從而避免重複註冊的問題。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 E_2.實際測試：
    - 這邊我的真實信箱為 a123456@gmail.com
    - 當使用 Apple 隱藏信箱時，得到的 email 是像 12345abcde@privaterelay.appleid.com 這樣的中繼信箱。
    - 這時候跳出「輸入框」請使用者填寫真實信箱，並存取這個隱藏信箱與真實電子郵件的映射關係，以便後續識別。
 
    1. 當使用 Apple 隱藏信箱註冊時，儲存隱藏信箱與真實信箱的映射關係：
        - 當使用者首次使用 Apple 隱藏信箱註冊時，Firebase 會返回一個中繼信箱。此時，如果 Apple 傳回了使用者的真實信箱（僅在首次註冊時會傳回），這邊會將中繼信箱與真實信箱儲存在 Firestore 的映射表中。
 
    2. 當使用真實信箱註冊時，檢查是否已存在對應的中繼信箱：
        - 當使用者使用真實信箱註冊時，我們先查詢 Firestore 中是否有與此信箱對應的中繼信箱。如果有，表示此信箱已經被使用過，註冊會失敗並提示使用者該信箱已被註冊。

 ---------------------------------------- ---------------------------------------- ----------------------------------------

 E_3. 情境觀察 Authentication 與Cloud Firestore
    
    **** 隱藏 Apple，跳出輸入框請使用者輸入真實信箱 ****

 * 情境 A_1
    - Apple隱藏（曹家瑋）> Email註冊（金城武，找到隱藏信箱時填寫的真實信箱的映射，因此無法註冊）> Apple隱藏（曹家瑋）> Google註冊（曹家瑋，鏈結到 Apple 隱藏中繼帳號）> Apple隱藏（曹家瑋）> Google登入（曹家瑋）

 * 情境 A_2
    - Apple隱藏（曹家瑋）> Email註冊 （金城武，找到隱藏信箱時填寫的真實信箱的映射，因此無法註冊）> Apple隱藏（曹家瑋） > Google註冊（曹家瑋，鏈結到 Apple 隱藏中繼帳號）> Apple隱藏（曹家瑋）> google登入（曹家瑋）> email直接登入鏈接（a578ff6）使中繼帳號變成 a578ff6 >  email / apple / google (曹家瑋，都為a578ff6)
 
 * 情境 A_3
    - Apple隱藏（曹家瑋） > Email 直接登入鏈接（a578ff6）使中繼帳號變成 a578ff6 > Apple（曹家瑋，a578ff6）> Google（曹家瑋，a578ff6） > Email/Apple/Googl (曹家瑋，都為a578ff6)

 * 情境 B
    - Email註冊（金城武）> Apple隱藏（曹家瑋，中繼帳號） > Email(金城武) > Apple（曹家瑋） > Google註冊（金城武，鏈接 Email）> Email（金城武）> Google（金城武） > Email(金城武 )> Apple（曹家瑋）> Google（金城武）

 * 情境 C_1
    - Google註冊登入（wei Tony）> Apple隱藏（曹家瑋，中繼帳號）> Apple（曹家瑋，中繼帳號）> Google（wei Tony）各自可以登入 > Email（無法註冊，wei Tony，但可以直接登入鏈接Google）> Apple隱藏（曹家瑋，中繼帳號）> Google（wei Tony） > Email（wei Tony。鏈接google）

 * 情境 C_2
    - Google註冊登入（wei Tony）> Email不能註冊（但是直接登入鏈接 Google， wei Tony）> Email/Google（都是wei Tony） > Apple隱藏（中繼帳號，曹家瑋）> Apple隱藏（中繼帳號，曹家瑋）> Email/Google（都是wei Tony）
 
 
 
    **** 沒隱藏 Apple，跳出輸入框請使用者輸入真實信箱 ****

 * 情境 D
    - Apple（曹家瑋）> Email（曹家瑋，因為無法註冊，直接登入設置密碼鏈接Apple）> Email / Apple(都是曹家瑋) > Google（鏈接Apple曹家瑋) > Email/Apple/Google ( 都曹家瑋 )

 * 情境 E
    - Apple（曹家瑋） > Google (鏈接 Apple 曹家瑋 )> Apple/Google(曹家瑋) > Email（無法註冊，登入鏈接 Apple 曹家瑋）> Apple/Google/Email(曹家瑋)

 * 情境 F
    - Email註冊（金城武）> Apple（鏈接 Email 金城武） > Email/Apple（金城武） > Google（鏈接 Email 金城武）> Apple/Google/Email（金城武）

 * 情境 G
    - Email註冊（金城武） > Google(鏈接 Email 金城武) > Email/Google（金城武） > Apple（鏈接 Email 金城武）> Apple/Google/Email（金城武）

 * 情境 H
    - Google(wei Tony) > Apple(鏈接 Google，wei Tony) > Apple/Google (wei Tony) > Email（wei Tony，因為無法註冊，直接登入鏈結Google） > Apple/Google/Email(wei Tony)

 * 情境 I
    - Google(wei Tony)>  Email（wei Tony，因為無法註冊，直接登入鏈結Google） >  email/google (wei Tony) > Apple(鏈接 Google，wei Tony) > Apple/Google/Email(wei Tony)
 
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



// MARK: - 存取中繼電子郵件地址、可以管理多個身份驗證提供者（雖然可以各自登入，不會有重複登入問題，但是無法正確處理映射真實信箱跟中繼信箱的部分）
// 主要是因為無法存取真實帳號，變成存取中繼帳號與真實帳號會是相同的數據。（因此才改用輸入欄位的方式來處理，詳見以下）
// 可以讓apple隱藏帳號、email真實帳號各自註冊成功，並且不會造多重帳號的錯誤，但經過不同情境測試後，我認為有機會讓使用者產生多身份鏈結時的錯亂。

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


    /// 使用 Apple 登入或註冊：處理 Apple 登入請求的建立和執行。
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
    
    /// 建立 Apple ID 請求：請求範圍包括用戶的全名和電子郵件。
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
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
                        print("更新用戶數據失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("更新用戶數據成功：\(user.uid)")
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
                        print("建立用戶數據失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("建立用戶數據成功：\(user.uid)")
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
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Apple SignIn Error: \(error.localizedDescription)")
                    self.signInCompletion?(.failure(error))
                } else if let authResult = authResult {
                    // 當使用者使用 Apple 隱藏信箱註冊時，儲存隱藏信箱與真實信箱的映射。
                    if let email = appleIDCredential.email {
                        print("Apple ID 註冊使用隱藏信箱：\(authResult.user.email ?? "")，真實信箱：\(email)")
                        self.mapHiddenEmailToRealEmail(hiddenEmail: authResult.user.email ?? "", realEmail: email) { result in
                            switch result {
                            case .success:
                                self.storeAppleUserData(authResult: authResult, fullName: appleIDCredential.fullName) { result in
                                    switch result {
                                    case .success:
                                        self.signInCompletion?(.success(authResult))
                                    case .failure(let error):
                                        print("Error storing user data: \(error.localizedDescription)")
                                        self.signInCompletion?(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                print("Error mapping hidden email: \(error.localizedDescription)")
                                self.signInCompletion?(.failure(error))
                            }
                        }
                    } else {
                        print("Apple SignIn Success without email: \(authResult.user.uid)")
                        self.storeAppleUserData(authResult: authResult, fullName: appleIDCredential.fullName) { result in
                            switch result {
                            case .success:
                                self.signInCompletion?(.success(authResult))
                            case .failure(let error):
                                print("Error storing user data: \(error.localizedDescription)")
                                self.signInCompletion?(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 儲存隱藏信箱與真實信箱的映射：當使用者第一次使用 Apple 隱藏信箱註冊時，這邊會儲存隱藏信箱和真實信箱之間的映射關係。
    private func mapHiddenEmailToRealEmail(hiddenEmail: String, realEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let mappingRef = db.collection("emailMappings").document(hiddenEmail)
        print("儲存隱藏信箱與真實信箱的映射：隱藏信箱=\(hiddenEmail)，真實信箱=\(realEmail)")

        // 將隱藏信箱和真實信箱之間的映射關係存入 Firestore
        mappingRef.setData(["realEmail": realEmail], merge: true) { error in
            if let error = error {
                print("儲存映射失敗：\(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("儲存映射成功：隱藏信箱=\(hiddenEmail)，真實信箱=\(realEmail)")
                completion(.success(()))
            }
        }
    }
  
    /// Apple 登入失敗的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("Sign in with Apple errored: \(error)")
        self.signInCompletion?(.failure(error))
    }
    
}
*/




// MARK: - 搭配當使用隱藏登入時，讓使用者填寫輸入欄位。(E)
// 藉此方式處理中繼帳號、真實帳號的映射，避免在使用apple隱藏登入時，還能使用 email 註冊導致出現雙重帳號問題。

import UIKit
import Firebase
import AuthenticationServices
import CryptoKit

/// 處理 Apple 相關部分
class AppleSignInController: NSObject {
    
    static let shared = AppleSignInController()
    
    private var currentNonce: String?
    private var signInCompletion: ((Result<AuthDataResult, Error>) -> Void)?

    // MARK: - Apple SignIn

    /// 使用 Apple 登入或註冊：處理 Apple 登入請求的建立和執行。
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
    
    /// 建立 Apple ID 請求：請求範圍包括用戶的全名和電子郵件。
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
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
                        print("更新用戶數據失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("更新用戶數據成功：\(user.uid)")
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
                        print("建立用戶數據失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("建立用戶數據成功：\(user.uid)")
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
    
    // MARK: - Helper Methods

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
    
    /// 進行身份驗證
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
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Apple SignIn Error: \(error.localizedDescription)")
                    self.signInCompletion?(.failure(error))
                } else if let authResult = authResult {
                    print("Apple SignIn Success: \(authResult.user.uid)")
                    // 如果 appleIDCredential.email 不為空，表示這是首次登入，提示輸入真實電子郵件
                    if let email = appleIDCredential.email {
                        print("Apple SignIn with Hidden Email: \(authResult.user.email ?? "")")
                        self.promptForRealEmail(hiddenEmail: authResult.user.email ?? "", fullName: appleIDCredential.fullName) { realEmail in
                            print("User entered real email: \(realEmail)")
                            self.mapHiddenEmailToRealEmail(hiddenEmail: authResult.user.email ?? "", realEmail: realEmail) { result in
                                switch result {
                                case .success:
                                    print("Mapping hidden email to real email success")
                                    self.storeAppleUserData(authResult: authResult, fullName: appleIDCredential.fullName) { result in
                                        switch result {
                                        case .success:
                                            print("Storing user data success")
                                            self.signInCompletion?(.success(authResult))
                                        case .failure(let error):
                                            print("Error storing user data: \(error.localizedDescription)")
                                            self.signInCompletion?(.failure(error))
                                        }
                                    }
                                case .failure(let error):
                                    print("Error mapping hidden email: \(error.localizedDescription)")
                                    self.signInCompletion?(.failure(error))
                                }
                            }
                        }
                    } else {
                        print("Apple SignIn without email: \(authResult.user.uid)")
                        self.storeAppleUserData(authResult: authResult, fullName: appleIDCredential.fullName) { result in
                            switch result {
                            case .success:
                                print("Storing user data success")
                                self.signInCompletion?(.success(authResult))
                            case .failure(let error):
                                print("Error storing user data: \(error.localizedDescription)")
                                self.signInCompletion?(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 提示使用者輸入真實電子郵件
    private func promptForRealEmail(hiddenEmail: String, fullName: PersonNameComponents?, completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "輸入真實電子郵件", message: "請輸入您的真實電子郵件地址，以便我們可以更好地為您提供服務。", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "真實電子郵件"
            textField.keyboardType = .emailAddress
            textField.addTarget(self, action: #selector(self.emailTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            if let textField = alertController.textFields?.first, let realEmail = textField.text, !realEmail.isEmpty {
                print("User entered real email: \(realEmail)")
                completion(realEmail)
            } else {
                print("User did not enter a real email")
            }
        }
        
        confirmAction.isEnabled = false // 初始時禁用確認按鈕
        alertController.addAction(confirmAction)
        
        // 設置確認按鈕的外觀
        alertController.view.tintColor = .systemBlue
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }

    /// 監聽電子郵件輸入框變化，並根據電子郵件格式啟用或禁用確認按鈕
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        guard let alertController = findAlertController(for: textField) else {
            print("未能找到UIAlertController")
            return
        }

        let email = textField.text ?? ""
        let isValidEmail = isEmailValid(email)
        let isConfirmButtonEnabled = alertController.actions[0].isEnabled

        if isValidEmail && !isConfirmButtonEnabled {
            alertController.actions[0].isEnabled = true // 啟用確認按鈕
            print("確認按鈕已啟用")
        } else if !isValidEmail && isConfirmButtonEnabled {
            alertController.actions[0].isEnabled = false // 禁用確認按鈕
            print("確認按鈕已禁用")
        }
    }
    
    /// 查找包含指定視圖的 UIAlertController
    private func findAlertController(for view: UIView) -> UIAlertController? {
        var responder: UIResponder? = view
        while responder != nil {
            if let alertController = responder as? UIAlertController {
                return alertController
            }
            responder = responder?.next
        }
        return nil
    }

    /// 檢查電子郵件格式是否有效
    private func isEmailValid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    /// 儲存隱藏信箱與真實信箱的映射
    private func mapHiddenEmailToRealEmail(hiddenEmail: String, realEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let mappingRef = db.collection("emailMappings").document(hiddenEmail)
        print("儲存隱藏信箱與真實信箱的映射：隱藏信箱=\(hiddenEmail)，真實信箱=\(realEmail)")

        mappingRef.setData(["realEmail": realEmail], merge: true) { error in
            if let error = error {
                print("儲存映射失敗：\(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("儲存映射成功：隱藏信箱=\(hiddenEmail)，真實信箱=\(realEmail)")
                completion(.success(()))
            }
        }
    }
  
    /// Apple 登入失敗的回調
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("Sign in with Apple errored: \(error)")
        self.signInCompletion?(.failure(error))
    }
    
}

