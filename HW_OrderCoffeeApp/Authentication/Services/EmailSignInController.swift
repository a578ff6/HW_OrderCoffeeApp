//
//  EmailSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/2.
//

/*
 
 A. 運作流程
    * 檢查電子郵件格式和密碼格式：
        - isEmailValid(_:)：檢查電子郵件格式是否有效。
        - isPasswordValid(_:)：檢查密碼是否符合要求（至少8位，包含小寫字母和特殊字符）。
 
    * 用電子郵件註冊：
        - registerUser(withEmail:password:fullName:completion:)：使用電子郵件註冊新用戶，先檢查該電子郵件是否已存在。
        - checkIfEmailExists(_:)：檢查電子郵件或隱藏信箱是否已存在。如果已存在，返回錯誤；如果不存在，創建新用戶並保存用戶數據。
 
    * 使用電子郵件登入：
        - loginUser(withEmail:password:completion:)：使用電子郵件和密碼進行用戶登入，首先嘗試將電子郵件憑證與現有帳號關聯。
        - linkEmailCredential(_:loginProvider:completion:)：將電子郵件憑證與現有帳號關聯，如果關聯失敗則直接登入。
        - signInWithEmailCredential(_:loginProvider:completion:)：使用電子郵件憑證進行登入，登入成功後保存用戶數據。
 
    * 發送密碼重置郵件：
        - resetPassword(forEmail:completion:)：發送密碼重置郵件到指定電子郵件地址。
 
    * 保存用戶數據到 Firestore：
        - storeUserData(authResult:fullName:loginProvider:completion:)：保存用戶數據到 Firestore，如果用戶數據已存在則更新資料，否則建立新資料。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 */


// MARK: - 還未處理與Apple隱藏帳號的關聯
/*
 import UIKit
 import Firebase


 /// 處理 Email 相關部分
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
     
     // MARK: - Email登入、註冊相關
     /// 創建新用戶，並將用戶資料儲存到 Firestore。
     func registerUser(withEmail email: String, password: String, fullName: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
         Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
             if let error = error {
                 completion(.failure(error))
             } else if let result = result {
                 // 使用 storeUserData 保存用戶數據
                 self.storeUserData(authResult: result, fullName: fullName, loginProvider: "email") { storeResult in
                     switch storeResult {
                     case .success:
                         completion(.success(result))
                     case .failure(let error):
                         completion(.failure(error))
                     }
                 }
             }
         }
     }
     
     /// 使用電子郵件和密碼進行用戶登入
     func loginUser(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
         let credential = EmailAuthProvider.credential(withEmail: email, password: password)
         self.linkEmailCredential(credential, loginProvider: "email", completion: completion)
     }
     
     /// 將電子郵件憑證與現有帳號關聯
     private func linkEmailCredential(_ credential: AuthCredential, loginProvider: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
         if let currentUser = Auth.auth().currentUser {
             currentUser.link(with: credential) { authResult, error in
                 if let error = error {
                     // 如果連結失敗，嘗試登入並合併數據
                     self.signInWithEmailCredential(credential, loginProvider: loginProvider, completion: completion)
                 } else if let authResult = authResult {
                     // 連結成功，保存用戶數據
                     self.storeUserData(authResult: authResult, loginProvider: loginProvider) { result in
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
             // 如果沒有當前用戶，則使用電子郵件憑證登入
             self.signInWithEmailCredential(credential, loginProvider: loginProvider, completion: completion)
         }
     }
     
     /// 使用電子郵件憑證登入
     private func signInWithEmailCredential(_ credential: AuthCredential, loginProvider: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
         Auth.auth().signIn(with: credential) { authResult, error in
             if let error = error {
                 completion(.failure(error))
             } else if let authResult = authResult {
                 // 登入成功，保存用戶數據
                 self.storeUserData(authResult: authResult, loginProvider: loginProvider) { result in
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
     
     /// 發送密碼重置郵件
     func resetPassword(forEmail email: String, completion: @escaping (Result<Void, Error>) -> Void) {
         Auth.auth().sendPasswordReset(withEmail: email) { error in
             if let error = error {
                 completion(.failure(error))
             } else {
                 completion(.success(()))
             }
         }
     }
     
     /// 保存用戶數據到 Firestore
     private func storeUserData(authResult: AuthDataResult, fullName: String? = nil, loginProvider: String, completion: @escaping (Result<Void, Error>) -> Void) {
         let db = Firestore.firestore()
         let user = authResult.user
         let userRef = db.collection("users").document(user.uid)
         
         userRef.getDocument { (document, error) in
             if let document = document, document.exists, var userData = document.data() {
                 // 更新現有資料
                 userData["email"] = user.email ?? ""
                 userData["loginProvider"] = loginProvider
                 if let fullName = fullName {
                     userData["fullName"] = fullName
                 }
                 userRef.setData(userData, merge: true) { error in
                     if let error = error {
                         completion(.failure(error))
                     } else {
                         completion(.success(()))
                     }
                 }
             } else {
                 // 建立新的資料
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


// MARK: - 處理與Apple隱藏帳號的關聯。並做到多方身份鏈結。（雖然可以各自登入，不會有重複登入問題，但是無法正確處理映射真實信箱跟中繼信箱的部分）
// 主要是因為無法存取真實帳號，變成存取中繼帳號與真實帳號會是相同的數據。（因此才改用輸入欄位的方式來處理，詳見以下）
// 可以讓apple隱藏帳號、email真實帳號各自註冊成功，並且不會造多重帳號的錯誤，但經過不同情境測試後，我認為有機會讓使用者產生多身份鏈結時的錯亂。


/*
import UIKit
import Firebase

/// 處理 Email 相關部分
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
    
    // MARK: - Email登入、註冊相關
    
    /// 建立使用者：當使用者使用電子郵件註冊時，先查詢是否存在隱藏信箱對應於該電子郵件，如果存在，則提示該郵箱已被使用。
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    ///   - fullName: 使用者的全名
    ///   - completion: 註冊完成的回調
    func registerUser(withEmail email: String, password: String, fullName: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        getRealEmail(forHiddenEmail: email) { result in
            switch result {
            case .success(let realEmail):
                if realEmail != nil {
                    // 如果該郵箱已被使用，顯示錯誤信息
                    print("The email address is already in use by another account.")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The email address is already in use by another account."])))
                } else {
                    // 如果該郵箱未被使用，進行註冊
                    print("The email address \(email) is available for registration.")
                    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                        if let error = error {
                            completion(.failure(error))
                        } else if let result = result {
                            // 使用 storeUserData 保存用戶數據
                            self.storeUserData(authResult: result, fullName: fullName, loginProvider: "email") { storeResult in
                                switch storeResult {
                                case .success:
                                    completion(.success(result))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Failed to get real email for \(email): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    /// 查詢真實電子郵件：當使用者使用電子郵件註冊時，查詢是否已存在對應的 Apple 隱藏信箱。
    /// - Parameters:
    ///   - hiddenEmail: 要查詢的電子郵件地址
    ///   - completion: 查詢完成的回調
    private func getRealEmail(forHiddenEmail hiddenEmail: String, completion: @escaping (Result<String?, Error>) -> Void) {
        let db = Firestore.firestore()
        let mappingRef = db.collection("emailMappings").document(hiddenEmail)
        
        // 查詢隱藏信箱是否對應於一個真實信箱
        mappingRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let realEmail = document?.data()?["realEmail"] as? String
                print("Mapped hidden email \(hiddenEmail) to real email \(String(describing: realEmail))")
                completion(.success(realEmail))
            }
        }
    }
    
    
    /// 使用電子郵件和密碼進行用戶登入
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    ///   - completion: 登入完成的回調
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        self.linkEmailCredential(credential, loginProvider: "email", completion: completion)
    }
    
    /// 將電子郵件憑證與現有帳號關聯
    /// - Parameters:
    ///   - credential: 電子郵件憑證
    ///   - loginProvider: 登入提供者
    ///   - completion: 完成的回調
    private func linkEmailCredential(_ credential: AuthCredential, loginProvider: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            currentUser.link(with: credential) { authResult, error in
                if let error = error {
                    // 如果連結失敗，嘗試登入並合併數據
                    self.signInWithEmailCredential(credential, loginProvider: loginProvider, completion: completion)
                } else if let authResult = authResult {
                    // 連結成功，保存用戶數據
                    self.storeUserData(authResult: authResult, loginProvider: loginProvider) { result in
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
            // 如果沒有當前用戶，則使用電子郵件憑證登入
            self.signInWithEmailCredential(credential, loginProvider: loginProvider, completion: completion)
        }
    }
    
    /// 使用電子郵件憑證登入
    /// - Parameters:
    ///   - credential: 電子郵件憑證
    ///   - loginProvider: 登入提供者
    ///   - completion: 完成的回調
    private func signInWithEmailCredential(_ credential: AuthCredential, loginProvider: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                // 登入成功，保存用戶數據
                self.storeUserData(authResult: authResult, loginProvider: loginProvider) { result in
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
    
    /// 發送密碼重置郵件
    /// - Parameters:
    ///   - email: 要重置密碼的電子郵件地址
    ///   - completion: 完成的回調
    func resetPassword(forEmail email: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
                userData["email"] = user.email ?? ""
                userData["loginProvider"] = loginProvider
                if let fullName = fullName {
                    userData["fullName"] = fullName
                }
                userRef.setData(userData, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                // 建立新的資料
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



// MARK: - 處理與Apple隱藏帳號的關聯。並做到多方身份鏈結。（搭配當使用隱藏登入時，讓使用者填寫輸入欄位。）

import UIKit
import Firebase

/// 處理 Email 相關部分
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

    /// 建立使用者：當使用者使用電子郵件註冊時，先查詢是否存在隱藏信箱對應於該電子郵件，如果存在，則提示該郵箱已被使用。
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    ///   - fullName: 使用者的全名
    ///   - completion: 註冊完成的回調
    func registerUser(withEmail email: String, password: String, fullName: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("開始檢查電子郵件是否存在：\(email)")
        checkIfEmailExists(email) { emailExists, hiddenEmail in
            if emailExists {
                if let hiddenEmail = hiddenEmail {
                    print("電子郵件地址已被另一個帳戶使用，對應隱藏信箱：\(hiddenEmail)")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The email address is already in use by another account."])))
                } else {
                    print("電子郵件地址已被另一個帳戶使用：\(email)")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The email address is already in use by another account."])))
                }
            } else {
                // 如果該郵箱未被使用，進行註冊
                print("電子郵件地址可用於註冊：\(email)")
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        print("註冊失敗：\(error.localizedDescription)")
                        completion(.failure(error))
                    } else if let result = result {
                        // 使用 storeUserData 保存用戶數據
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
                }
            }
        }
    }
    
    /// 查詢真實電子郵件是否已存在：查詢真實電子郵件或隱藏信箱是否已存在
    /// - Parameters:
    ///   - email: 要查詢的真實電子郵件地址
    ///   - completion: 查詢完成的回調
    private func checkIfEmailExists(_ email: String, completion: @escaping (Bool, String?) -> Void) {
        print("檢查真實電子郵件是否存在：\(email)")
        let db = Firestore.firestore()
        let userRef = db.collection("users").whereField("email", isEqualTo: email)
        
        // 查詢真實電子郵件是否已存在
        userRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("檢查電子郵件失敗：\(error.localizedDescription)")
                completion(false, nil)
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                // 真實電子郵件已存在
                print("真實電子郵件已存在：\(email)")
                completion(true, nil)
            } else {
                print("真實電子郵件不存在，檢查是否有隱藏信箱映射到這個真實電子郵件")
                // 如果真實電子郵件不存在，查詢是否有隱藏信箱映射到這個真實電子郵件
                let mappingRef = db.collection("emailMappings").whereField("realEmail", isEqualTo: email)
                mappingRef.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("檢查隱藏信箱映射失敗：\(error.localizedDescription)")
                        completion(false, nil)
                    } else if let snapshot = snapshot, !snapshot.isEmpty {
                        let hiddenEmail = snapshot.documents.first?.documentID
                        print("找到隱藏信箱映射：隱藏信箱 = \(hiddenEmail ?? ""), 真實信箱 = \(email)")
                        completion(true, hiddenEmail)
                    } else {
                        print("沒有找到隱藏信箱映射")
                        completion(false, nil)
                    }
                }
            }
        }
    }
   
    /// 使用電子郵件和密碼進行用戶登入
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    ///   - completion: 登入完成的回調
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("嘗試使用電子郵件登入：\(email)")
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        self.linkEmailCredential(credential, loginProvider: "email", completion: completion)
    }
    
    /// 將電子郵件憑證與現有帳號關聯
    /// - Parameters:
    ///   - credential: 電子郵件憑證
    ///   - loginProvider: 登入提供者
    ///   - completion: 完成的回調
    private func linkEmailCredential(_ credential: AuthCredential, loginProvider: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            print("當前用戶已登入，嘗試連結電子郵件憑證")
            currentUser.link(with: credential) { authResult, error in
                if let error = error {
                    // 如果連結失敗，嘗試登入並合併數據
                    print("連結失敗，嘗試直接登入：\(error.localizedDescription)")
                    self.signInWithEmailCredential(credential, loginProvider: loginProvider, completion: completion)
                } else if let authResult = authResult {
                    // 連結成功，保存用戶數據
                    print("連結成功，保存用戶數據")
                    self.storeUserData(authResult: authResult, loginProvider: loginProvider) { result in
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
        } else {
            // 如果沒有當前用戶，則使用電子郵件憑證登入
            print("沒有當前用戶，使用電子郵件憑證直接登入")
            self.signInWithEmailCredential(credential, loginProvider: loginProvider, completion: completion)
        }
    }
    
    /// 使用電子郵件憑證登入
    /// - Parameters:
    ///   - credential: 電子郵件憑證
    ///   - loginProvider: 登入提供者
    ///   - completion: 完成的回調
    private func signInWithEmailCredential(_ credential: AuthCredential, loginProvider: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("使用電子郵件憑證登入")
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("登入失敗：\(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                // 登入成功，保存用戶數據
                print("登入成功，保存用戶數據")
                self.storeUserData(authResult: authResult, loginProvider: loginProvider) { result in
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


