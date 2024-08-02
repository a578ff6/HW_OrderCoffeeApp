//
//  EmailSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/2.
//

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
