//
//  EmailSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/2.
//

/*
 
 Email 部分：
 - [v] 先 Email 註冊，基本上要有資料。（資料修改沒問題）

 * Email 與 Apple 不隱藏
 - [v] 先使用 Apple （a578ff6@gmail.com） 不隱藏，在使用 Email （a1202@gmail.com） 不同信箱註冊，各自登入。（資料修改沒問題）
 - [v] 先使用 Apple （a578ff6@gmail.com） 不隱藏，在使用 Email （a578ff6@gmail.com） 相同的信箱不能註冊。（資料修改沒問題）

 * Email 與 Apple 隱藏
 - [v] 先使用 Apple 隱藏，在使用 Email （a578ff6@gmail.com） 與 Apple 原先的信箱註冊。（資料修改沒問題）
     - [x] 基本上是可以註冊，因為 Apple 是中繼信箱！因此不會覆蓋。（資料修改沒問題）
 - [v] 先使用 Apple 隱藏，在使用 Email 不同信箱註冊，基本上是完全可以註冊，且各自登入沒問題。（資料修改沒問題）

 * Email 與 Google
 - [v] 先使用 Google 註冊，在使用不同的 Email ，基本各自登入。（資料修改沒問題）
 - [v] 先使用 Google 註冊，在使用相同的 Email ，基本上不能註冊。（資料修改沒問題）
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 A. EmailSignInController 流程分析
    - 負責處理使用者透過電子郵件註冊和登入的邏輯。主要提供了電子郵件格式驗證、密碼檢查、新使用者註冊、使用者登入、密碼重置，以及保存使用者數據到 Firebase Firestore 的功能。
 
    1. 電子郵件與密碼檢查
        - 檢查電子郵件格式 (isEmailvalid)：驗證電子郵件地址是否符合標準格式。
        - 檢查密碼強度 (isPasswordValid)：確認密碼是否符合要求（至少 8 位字符，包含小寫字母和特殊字符）。
 
    2. 使用電子郵件註冊
        * 註冊新使用者 (registerUser)
            - 首先檢查電子郵件是否已存在於系統中 (checkIfEmailExists)。
            - 如果電子郵件已存在，返回錯誤，註冊失敗。
            - 如果電子郵件可用，則調用 Firebase 的 createUser 方法進行註冊。
            - 註冊成功後，將用戶資料儲存至 Firestore (storeUserData)。
 
    3. 使用電子郵件登入
        * 登入使用者 (loginUser)
            - 使用 Firebase 的 signIn 方法進行電子郵件和密碼的登入。
            - 登入成功後，將用戶資料更新至 Firestore (storeUserData)。
 
    4. 電子郵件存在性檢查
        * 檢查電子郵件是否已存在於 Firebase 中 (checkIfEmailExists)
            - 使用 Firestore 查詢 users 集合，檢查指定的電子郵件是否已存在。
            - 如果電子郵件已存在於資料庫中，返回 true，否則返回 false。
 
    5. 密碼重置
        * 發送密碼重置郵件 (resetPassword)
            - 調用 Firebase 的 sendPasswordReset 方法，發送重置密碼的電子郵件。
            - 若發送成功，返回成功訊息；否則，返回錯誤。
 
    6. Firebase 數據操作
        * 儲存或更新用戶數據 (storeUserData)
            - 使用者註冊或登入成功後，將其數據儲存或更新到 Firestore 的 users 集合中。
            - 如果用戶資料已存在，則更新現有資料；如果資料不存在，則創建新資料。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 B. 重構 registerUser 流程：
    
    1. 開始檢查電子郵件是否存在:
        * 當 registerUser 方法被呼叫時，首先會檢查使用者提供的電子郵件是否已經存在於 Firebase 的 users 集合中。
        * 這是透過呼叫 checkIfEmailExists 方法來完成的。
 
    2. 處理電子郵件已存在的情況:
        * 如果 checkIfEmailExists 返回 true，表示該電子郵件已被其他帳戶使用，registerUser 將呼叫 handleEmailAlreadyExistsError 方法。
        * 該方法會記錄錯誤訊息，並透過 completion 回傳一個錯誤，通知呼叫者該電子郵件無法用於註冊。
 
    3. 創建新用戶:
        * 如果 checkIfEmailExists 返回 false，表示該電子郵件尚未被使用，registerUser 會繼續呼叫 createNewUser 方法來創建一個新用戶。
        * 在這個過程中，Firebase 會嘗試使用提供的電子郵件和密碼來創建新帳戶。

    4. 處理用戶創建失敗的情況:
        * 如果在創建新用戶的過程中出現錯誤，createNewUser 方法會呼叫 handleUserCreationError 方法來記錄錯誤訊息，並將錯誤透過 completion 回傳給呼叫者。
 
    5. 處理用戶創建成功的情況:
        * 如果用戶創建成功，createNewUser 方法會呼叫 handleUserCreationSuccess 方法。
        * 該方法會將新創建的用戶數據（包括 fullName 和 loginProvider）存儲到 Firestore 中，然後將成功的結果透過 completion 回傳給呼叫者。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 C. 由於不打算讓電子郵件註冊的帳號與 Apple 或 Google 帳號進行鏈接，因此在 EmailSignInController 中不使用 fetchSignInMethods(forEmail:) 。
        - fetchSignInMethods(forEmail:) 主要用於處理多重身份驗證提供者的帳號管理。
        - 目前，已經使用了 checkIfEmailExists 方法來檢查電子郵件是否存在於 Firebase 中的 `users` 集合。這個方法已經足夠確保同一個電子郵件不會被重複註冊。

 1. 先使用 Email 註冊:
    - 如果使用者先使用 Email 註冊帳號，那麼這個帳號可以被相同的 Apple 或 Google 電子郵件信箱鏈接。

 2. 先使用 Apple 或 Google 註冊:
    - 如果使用者先使用 Apple 或 Google 註冊帳號，然後嘗試使用相同的電子郵件地址透過 Email 註冊，則會遇到錯誤，因為該電子郵件地址已經與 Apple 或 Google 登入方式鏈接到現有帳號了。
    - 在這種情況下，不能再用相同的電子郵件地址重新註冊為 Email 登入方式的帳號。

 3. 在 Apple 不隱藏電子郵件的情況下：
    - 當 Apple 提供真實電子郵件時，這些邏輯都會按照上面的描述運作。
    - 如果 Apple 隱藏了電子郵件，那麼邏輯會有所不同，因為這樣的匿名電子郵件地址不會與使用者的真實電子郵件重複。

 */



// MARK: -  負責處理與 Email 登入及註冊相關的 Controller

// 在已經先使用 Email 電子信箱註冊時，可以被相同的 Apple 、 Google 覆蓋提供者。
// 而當先使用 Apple 、 Google 信箱註冊時，則無法使用 Email 電子信箱註冊。（這是在 Apple 未隱藏的情境）
/*
import UIKit
import Firebase

/// 負責處理與 Email 登入及註冊相關的 Controller
class EmailSignInController {
    
    static let shared = EmailSignInController()

    // MARK: - 郵件、密碼檢查

    /// 檢查電子郵件格式是否有效
    static func isEmailvalid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    /// 檢查密碼是否符合要求（至少8位，包含小寫字母和特殊字符）
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    // MARK: - Email 登入、註冊相關
    
    /// 註冊新使用者
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    ///   - fullName: 使用者的全名
    ///   - completion: 註冊完成的回調，回傳成功或失敗的結果
    func registerUser(withEmail email: String, password: String, fullName: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("開始檢查電子郵件是否存在：\(email)")
        checkIfEmailExists(email) { emailExists in
            if emailExists {
                self.handleEmailAlreadyExistsError(email: email, completion: completion)
            } else {
                self.createNewUser(withEmail: email, password: password, fullName: fullName, completion: completion)
            }
        }
    }
    
    /// 處理電子郵件已存在的情況
    /// - Parameters:
    ///   - email: 已存在的電子郵件地址
    ///   - completion: 完成的回調，回傳失敗的結果
    private func handleEmailAlreadyExistsError(email: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("電子郵件地址已被另一個帳戶使用：\(email)")
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The email address is already in use by another account."])
        completion(.failure(error))
    }

    /// 創建新用戶
    /// - Parameters:
    ///   - email: 新用戶的電子郵件地址
    ///   - password: 新用戶的密碼
    ///   - fullName: 新用戶的全名
    ///   - completion: 註冊完成的回調，回傳成功或失敗的結果
    private func createNewUser(withEmail email: String, password: String, fullName: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("電子郵件地址可用於註冊：\(email)")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.handleUserCreationError(error: error, completion: completion)
            } else if let result = result {
                self.handleUserCreationSuccess(result: result, fullName: fullName, completion: completion)
            }
        }
    }
    
    /// 處理用戶創建失敗的情況
    /// - Parameters:
    ///   - error: 創建用戶過程中遇到的錯誤
    ///   - completion: 完成的回調，回傳失敗的結果
    private func handleUserCreationError(error: Error, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("註冊失敗：\(error.localizedDescription)")
        completion(.failure(error))
    }
    
    /// 處理用戶創建成功的情況
    /// - Parameters:
    ///   - result: 成功創建用戶的 Firebase 認證結果
    ///   - fullName: 使用者的全名
    ///   - completion: 完成的回調，回傳成功或失敗的結果
    private func handleUserCreationSuccess(result: AuthDataResult, fullName: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("註冊成功，保存用戶數據：\(result.user.uid)")
        self.storeUserData(authResult: result, fullName: fullName, loginProvider: "email") { storeResult in
            switch storeResult {
            case .success:
                print("用戶數據保存成功")
                completion(.success(result))
            case .failure(let error):
                print("用戶數據保存失敗：\(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /// 使用電子郵件登入
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    ///   - completion: 登入完成的回調，回傳成功或失敗的結果
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("嘗試使用電子郵件登入：\(email)")
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        // 嘗試使用電子郵件和密碼登入
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("登入失敗：\(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                // 登入成功，保存用戶數據
                print("登入成功，保存用戶數據")
                self.storeUserData(authResult: authResult, loginProvider: "email") { result in
                    switch result {
                    case .success:
                        print("用戶數據保存成功")
                        completion(.success(authResult))
                    case .failure(let error):
                        print("用戶數據保存失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    // MARK: - Firebase 數據檢查及操作

    /// 檢查電子郵件是否已經存在於 Firebase 中
    /// - Parameters:
    ///   - email: 要檢查的電子郵件地址
    ///   - completion: 檢查完成後的回調，回傳是否存在的結果
    private func checkIfEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        print("檢查真實電子郵件是否存在：\(email)")
        let db = Firestore.firestore()
        let userRef = db.collection("users").whereField("email", isEqualTo: email)
        
        userRef.getDocuments { (snapshot, error) in
            if let error = error {
                // 檢查過程中出現錯誤
                print("檢查電子郵件失敗：\(error.localizedDescription)")
                completion(false)
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                // 電子郵件已經存在
                print("真實電子郵件已存在：\(email)")
                completion(true)
            } else {
                // 電子郵件不存在
                print("真實電子郵件不存在")
                completion(false)
            }
        }
    }
    
    /// 發送密碼重置郵件
    /// - Parameters:
    ///   - email: 要重置密碼的電子郵件地址
    ///   - completion: 完成的回調
    func resetPassword(forEmail email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("發送密碼重置郵件到：\(email)")
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// 保存用戶數據到 Firestore
    /// - Parameters:
    ///   - authResult: Firebase 驗證結果
    ///   - fullName: 使用者的全名（可選）
    ///   - loginProvider: 登入提供者
    ///   - completion: 完成的回調
    private func storeUserData(authResult: AuthDataResult, fullName: String? = nil, loginProvider: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists, var userData = document.data() {
                // 更新現有資料
                print("更新現有用戶數據：\(user.uid)")
                userData["email"] = user.email ?? ""
                userData["loginProvider"] = loginProvider
                if let fullName = fullName {
                    userData["fullName"] = fullName
                }
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        print("更新失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("更新成功")
                        completion(.success(()))
                    }
                }
            } else {
                // 建立新的資料
                print("建立新用戶數據：\(user.uid)")
                var userData: [String: Any] = [
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "loginProvider": loginProvider
                ]
                
                if let fullName = fullName {
                    userData["fullName"] = fullName
                }
                
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        print("建立失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("建立成功")
                        completion(.success(()))
                    }
                }
            }
        }
    }
 
}
*/

// MARK: -  負責處理與 Email 登入及註冊相關的 Controller（async/await）

import UIKit
import Firebase

/// 負責處理與 Email 登入及註冊相關的 Controller
class EmailSignInController {
    
    static let shared = EmailSignInController()
    
    // MARK: - 郵件、密碼檢查
    
    /// 檢查電子郵件格式是否有效
    static func isEmailvalid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    /// 檢查密碼是否符合要求（至少8位，包含小寫字母和特殊字符）
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    // MARK: - Email 登入、註冊相關
    
    /// 註冊新使用者
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    ///   - fullName: 使用者的全名
    func registerUser(withEmail email: String, password: String, fullName: String) async throws -> AuthDataResult {
        print("開始檢查電子郵件是否存在：\(email)")

        /// 檢查電子郵件是否已經存在
        let emailExists = try await checkIfEmailExists(email)
        if emailExists {
            print("電子郵件地址已被另一個帳戶使用：\(email)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "電子郵件地址已被另一個帳戶使用。"])
        }
        
        // 創建新用戶
        return try await createNewUser(withEmail: email, password: password, fullName: fullName)
    }
    
    /// 創建新用戶
    /// - Parameters:
    ///   - email: 新用戶的電子郵件地址
    ///   - password: 新用戶的密碼
    ///   - fullName: 新用戶的全名
    private func createNewUser(withEmail email: String, password: String, fullName: String) async throws -> AuthDataResult {
        print("電子郵件地址可用於註冊：\(email)")
        
        // 創建新用戶
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // 保存用戶數據到 Firestore
        print("註冊成功，保存用戶數據：\(authResult.user.uid)")
        try await storeUserData(authResult: authResult, fullName: fullName, loginProvider: "email")
        
        return authResult
    }
    
    /// 使用電子郵件登入
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    func loginUser(withEmail email: String, password: String) async throws -> AuthDataResult {
        print("嘗試使用電子郵件登入：\(email)")
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        /// 使用電子郵件和密碼進行登入
        let authResult = try await Auth.auth().signIn(with: credential)
        
        // 保存用戶數據
        print("登入成功，保存用戶數據")
        try await storeUserData(authResult: authResult, loginProvider: "email")
        
        return authResult
    }
    
    // MARK: - 密碼重置郵件
    
    /// 發送密碼重置郵件
    /// - Parameters:
    ///   - email: 要重置密碼的電子郵件地址
    func resetPassword(forEmail email: String) async throws {
        print("發送密碼重置郵件到：\(email)")
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    // MARK: - Firebase 數據檢查及操作
    
    /// 檢查電子郵件是否已經存在於 Firebase 中
    /// - Parameters:
    ///   - email: 要檢查的電子郵件地址
    /// - Returns: 是否存在的結果
    private func checkIfEmailExists(_ email: String) async throws -> Bool {
        print("檢查電子郵件是否存在：\(email)")
        
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").whereField("email", isEqualTo: email).getDocuments()
        
        return !snapshot.isEmpty
    }
    
    /// 保存用戶數據到 Firestore
    /// - Parameters:
    ///   - authResult: Firebase 驗證結果
    ///   - fullName: 使用者的全名（可選）
    ///   - loginProvider: 登入提供者
    private func storeUserData(authResult: AuthDataResult, fullName: String? = nil, loginProvider: String) async throws {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        // 檢查用戶數據是否存在，若存在則更新，若不存在則創建
        let document = try await userRef.getDocument()
        
        if document.exists, var userData = document.data() {
            // 更新現有資料
            print("更新現有用戶數據：\(user.uid)")
            userData["email"] = user.email ?? ""
            userData["loginProvider"] = loginProvider
            if let fullName = fullName {
                userData["fullName"] = fullName
            }
            try await userRef.setData(userData, merge: true)
        } else {
            // 建立新的資料
            print("建立新用戶數據：\(user.uid)")
            var userData: [String: Any] = [
                "uid": user.uid,
                "email": user.email ?? "",
                "loginProvider": loginProvider
            ]
            
            if let fullName = fullName {
                userData["fullName"] = fullName
            }
            
            try await userRef.setData(userData, merge: true)
        }
    }
    
}
