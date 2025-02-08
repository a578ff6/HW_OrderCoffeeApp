//
//  EmailAuthController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/2.
//


// MARK: - Email 部分測試
/**
 
 ## Email 部分測試
 
 - [v] 先 Email 註冊，基本上要有資料。（資料修改沒問題）

 - `Email 與 Apple 不隱藏`
 
    - [v] 先使用 Apple （a578ff6@gmail.com） 不隱藏，在使用 Email （a1202@gmail.com） 不同信箱註冊，各自登入。（資料修改沒問題）
    - [v] 先使用 Apple （a578ff6@gmail.com） 不隱藏，在使用 Email （a578ff6@gmail.com） 相同的信箱不能註冊。（資料修改沒問題）

 - `Email 與 Apple 隱藏`
 
    - [v] 先使用 Apple 隱藏，在使用 Email （a578ff6@gmail.com） 與 Apple 原先的信箱註冊。（資料修改沒問題）
     - [x] 基本上是可以註冊，因為 Apple 是中繼信箱！因此不會覆蓋。（資料修改沒問題）
 
    - [v] 先使用 Apple 隱藏，在使用 Email 不同信箱註冊，基本上是完全可以註冊，且各自登入沒問題。（資料修改沒問題）

` - Email 與 Google`
 
    - [v] 先使用 Google 註冊，在使用不同的 Email ，基本各自登入。（資料修改沒問題）
    - [v] 先使用 Google 註冊，在使用相同的 Email ，基本上不能註冊。（資料修改沒問題）
 */


// MARK: - EmailAuthController 筆記
/**
 
 ## EmailAuthController 筆記

 
 `* What:`
 
 - `EmailAuthController` 是負責處理 Email 相關的 Firebase 身份驗證的類別，提供註冊、登入、密碼重置等功能。

 -------
 
 `* Why`
 
 1. 封裝 Firebase 認證邏輯
 
    - 避免 `ViewController` 直接操作 Firebase，確保架構的清晰度與可維護性。
 
 2. 統一錯誤處理機制
 
    - 使用 `EmailAuthError` 來簡化錯誤管理，提升可讀性。
 
 3. 增強可讀性與可測試性
 
    - `LoginViewController`、`SignUpViewController`、`ForgotPasswordViewController` 無需直接執行業務邏輯，遵循單一職責原則。
 
 4. 避免重複代碼
 
    - 將 Firebase 操作集中於一處，減少多個 ViewController 重複相同邏輯的情況。

 -------

 `* How:`
 
 1. 註冊新使用者 (`registerUser`)
 
 - 步驟
 
   1. 先透過 `checkIfEmailExists` 檢查該 Email 是否已註冊。
   2. 若 Email 已存在，則拋出 `EmailAuthError.emailAlreadyExists`。
   3. 若 Email 可用，則調用 `createNewUser` 創建新帳戶。
   4. 註冊成功後，將使用者資料存入 Firestore。

 - 關鍵方法
 
   - `checkIfEmailExists(email: String)`: 查詢 Firestore `users` 集合，確認 Email 是否已存在。
   - `createNewUser(email: String, password: String, fullName: String)`: 使用 `Auth.auth().createUser` 創建 Firebase 用戶。

 ---
 
 2. 使用 Email 登入 (`loginUser`)
 
 - 步驟
 
   1. 透過 `EmailAuthProvider.credential(email, password)` 取得憑證。
   2. 調用 `Auth.auth().signIn(with: credential)` 進行登入。
   3. 若登入成功，則調用 `storeUserData`，確保 Firebase `users` 集合內有該使用者的資訊。
   4. 若發生錯誤，透過 `EmailAuthError.handleFirebaseAuthError(error)` 進行轉換。

 - 錯誤處理
 
   - 若 Firebase 返回 `emailAlreadyInUse`、`wrongPassword`、`userNotFound` 等錯誤，會轉換為對應的 `EmailAuthError`，提供清晰的錯誤訊息。

 ---

 3. 發送密碼重置郵件 (`resetPassword`)
 
 - 步驟
 
   1. 調用 `Auth.auth().sendPasswordReset(withEmail: email)`。
   2. 若發送成功，前端可顯示提示訊息，告知使用者檢查電子郵件。
   3. 若發生錯誤，則透過 `EmailAuthError.handleFirebaseAuthError(error)` 轉換為適當的錯誤訊息。

 ---

 4. 錯誤管理 (`EmailAuthError`)
 
 - 統一錯誤處理方式
 
   - `EmailAuthError` 將 `FirebaseAuth` 可能返回的 `NSError` 轉換為 `enum`，提升錯誤處理的一致性。
   - `errorDescription` 屬性提供給 UI 層，以便顯示適當的錯誤訊息。

 - 錯誤類型

 `.emailAlreadyExists` | 電子郵件已被使用
 `.invalidEmailFormat` | 輸入的 Email 格式無效
 `.weakPassword` | 密碼強度不足
 `.wrongPassword` | 密碼錯誤
 `.userNotFound` | 使用者帳戶不存在
 `.tooManyRequests` | 登入嘗試過多，請稍後再試
 `.unknown(error)` | 其他未知錯誤

 ---

 5. Firestore 數據操作 (`storeUserData`)
 
 - 功能
 
   - 確保使用者登入後，Firestore `users` 集合內有對應的使用者資料。
   - 若 `users` 集合內已存在該 UID，則更新 `loginProvider` 等資訊。
   - 若該 UID 不存在，則新增一筆記錄，包含 `email`、`uid`、`fullName` (若有提供)。

 - Firestore 設計考量
 
   - 合併 (`merge: true`)
 
     - 若使用者已存在，則只更新部分欄位，而不覆蓋整份資料。
 
   - 存取設計
 
     - `users` 集合使用 UID 作為 `document ID`，方便後續存取與更新。

 -------

 `* 總結`
 
    1.`EmailAuthController` 將 Email 身份驗證與 Firebase 操作封裝成模組化邏輯，
    2.確保 `ViewController` 只需專注於 UI，提升了可讀性、可維護性，
    3.同時透過 `EmailAuthError` 統一錯誤管理，讓 UI 層能清楚地呈現錯誤訊息。
 
 */



// MARK: - (v)


import UIKit
import Firebase

/// `EmailAuthController` 負責 Email 登入、註冊、密碼管理
///
/// - 目的:
///   1. 封裝 Firebase 認證邏輯，確保 `ViewController` 不直接操作 Firebase
///   2. 提供統一錯誤處理，透過 `EmailAuthError` 簡化錯誤管理
///   3. 提升可讀性，避免 `LoginViewController`、`SignUpViewController` 、`ForgotPasswordViewController`直接寫業務邏輯
class EmailAuthController {
    
    /// Singleton 實例，確保 Email 登入/註冊的處理方式統一
    static let shared = EmailAuthController()
  
    // MARK: - 註冊新使用者
    
    /// 註冊新使用者
    ///
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    ///   - fullName: 使用者的全名
    func registerUser(withEmail email: String, password: String, fullName: String) async throws -> AuthDataResult {
        
        /// 1.檢查 Email 是否已存在
        let emailExists = try await checkIfEmailExists(email)
        if emailExists {
            print("[EmailAuthController]: 電子郵件地址已被另一個帳戶使用：\(email)")
            throw EmailAuthError.emailAlreadyExists
        }
        
        /// 2.創建新用戶
        return try await createNewUser(withEmail: email, password: password, fullName: fullName)
    }
    
    // MARK: - 使用 Email 登入
    
    /// 使用電子郵件登入
    ///
    /// - Parameters:
    ///   - email: 使用者的電子郵件地址
    ///   - password: 使用者的密碼
    func loginUser(withEmail email: String, password: String) async throws -> AuthDataResult {
        print("[EmailAuthController]: 嘗試登入，Email：\(email)")
        
        do {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            let authResult = try await Auth.auth().signIn(with: credential)
            print("[EmailAuthController]: 登入成功，保存用戶數據")
            try await storeUserData(authResult: authResult, loginProvider: "email")
            return authResult
        } catch {
            throw EmailAuthError.handleFirebaseAuthError(error)
        }
    }
    
    // MARK: - 密碼重置郵件
    
    /// 發送密碼重置郵件
    ///
    /// - Parameters:
    ///   - email: 要重置密碼的電子郵件地址
    func resetPassword(forEmail email: String) async throws {
        print("[EmailAuthController]: 發送密碼重置郵件到：\(email)")
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw EmailAuthError.handleFirebaseAuthError(error)
        }
    }
    
    // MARK: - Firebase 數據檢查及操作
    
    /// 創建新用戶
    ///
    /// - Parameters:
    ///   - email: 新用戶的電子郵件地址
    ///   - password: 新用戶的密碼
    ///   - fullName: 新用戶的全名
    private func createNewUser(withEmail email: String, password: String, fullName: String) async throws -> AuthDataResult {
        print("[EmailAuthController]: 電子郵件地址可用於註冊：\(email)")
        
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            print("[EmailAuthController]: 註冊成功，保存用戶數據：\(authResult.user.uid)")
            try await storeUserData(authResult: authResult, fullName: fullName, loginProvider: "email")
            return authResult
        } catch {
            throw EmailAuthError.handleFirebaseAuthError(error)
        }
    }
    
    /// 檢查電子郵件是否已經存在於 Firebase 中
    ///
    /// - Parameters:
    ///   - email: 要檢查的電子郵件地址
    /// - Returns: 是否存在的結果
    private func checkIfEmailExists(_ email: String) async throws -> Bool {
        print("[EmailAuthController]: 檢查 Email 是否已存在：\(email)")
        
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").whereField("email", isEqualTo: email).getDocuments()
        
        return !snapshot.isEmpty
    }
    
    /// 保存用戶數據到 Firestore
    ///
    /// - Parameters:
    ///   - authResult: Firebase 驗證結果
    ///   - fullName: 使用者的全名（可選）
    ///   - loginProvider: 登入提供者
    private func storeUserData(authResult: AuthDataResult, fullName: String? = nil, loginProvider: String) async throws {
        print("[EmailAuthController]: 儲存用戶資料，UID：\(authResult.user.uid)")
        
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        let document = try await userRef.getDocument()
        
        /// 檢查用戶數據是否存在，若存在則更新，若不存在則創建
        if document.exists {
            // 更新現有資料
            print("[EmailAuthController]: 更新現有用戶資料")
            try await userRef.setData([
                "email": user.email ?? "",
                "loginProvider": loginProvider
            ], merge: true)
        } else {
            // 建立新的資料
            print("[EmailAuthController]: 創建新用戶資料")
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
