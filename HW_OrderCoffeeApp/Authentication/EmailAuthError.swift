//
//  EmailAuthError.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/2/7.
//

// MARK: - EmailAuthError 筆記
/**
 
 ## EmailAuthError 筆記

 `* What`
 
 - `EmailAuthError` 是一個 `enum`，用於統一管理 Email 驗證相關的錯誤。
 - 它封裝了 Firebase 驗證錯誤 (`AuthErrorCode`)，提供 可讀性更高、使用者友善的錯誤訊息，並讓 `ViewController` **不直接依賴 Firebase**，確保更好的可維護性。

 - 主要功能
 
 1. 定義常見的 Email 驗證錯誤
 
    - `emailAlreadyExists`: 信箱已被註冊
    - `invalidEmailFormat`: 無效的 Email 格式
    - `weakPassword`: 密碼太弱
    - `wrongPassword`: 密碼錯誤
    - `userNotFound`: 該 Email 尚未註冊
    - `tooManyRequests`: 過多登入嘗試，Firebase 限制
    - `unknown`: 未知錯誤

 2. 提供本地化的錯誤訊息
 
    - 透過 `errorDescription` 屬性，提供更直觀的錯誤訊息，如：
      ```swift
      case .wrongPassword:
          return "密碼錯誤，請重新輸入。"
      ```

 3. 轉換 Firebase `AuthErrorCode`
 
    - 透過 `handleFirebaseAuthError(_:)`，將 Firebase `NSError` 轉換為 `EmailAuthError`，確保 `ViewController` 不直接處理 Firebase 錯誤。

 ---------

 `* Why`
 
 1. 提高可讀性，讓錯誤資訊更直觀
 
    - Firebase 原始錯誤代碼不直觀，例如：
 
      ```swift
      AuthErrorCode.wrongPassword.rawValue // "ERROR_WRONG_PASSWORD"
      ```
 
    - 改為可讀性高的 `enum`：
 
      ```swift
      throw EmailAuthError.wrongPassword
      ```
 
    - UI 可直接顯示錯誤訊息：
 
      ```swift
      AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
      ```

 2. 符合單一責任原則（SRP）
 
    - 錯誤處理集中於 `EmailAuthError`，避免 `ViewController` 直接處理 Firebase 錯誤。
    - 讓 `EmailAuthController` 負責 API，`ViewController` 只負責 UI。

 3. 增強可維護性
 
    - 如果 Firebase API 改版，只需修改 `handleFirebaseAuthError(_:)`，不影響 UI。
    - 未來可以擴充更多錯誤類型，如 `emailBlacklisted`、`emailVerificationRequired`。

 ---------
`
 `* How
 
 1. 定義 `EmailAuthError`
 
     ```swift
     enum EmailAuthError: Error, LocalizedError {
         
         case emailAlreadyExists
         case invalidEmailFormat
         case weakPassword
         case wrongPassword
         case userNotFound
         case tooManyRequests
         case unknown(Error)
         
         /// 提供本地化錯誤訊息
         var errorDescription: String? {
             switch self {
             case .emailAlreadyExists:
                 return "電子郵件已被使用，請嘗試其他帳號。"
             case .invalidEmailFormat:
                 return "請輸入有效的電子郵件格式。"
             case .weakPassword:
                 return "密碼過於簡單，請嘗試更強的密碼。"
             case .wrongPassword:
                 return "密碼錯誤，請重新輸入。"
             case .userNotFound:
                 return "此帳號不存在，請確認電子郵件是否正確。"
             case .tooManyRequests:
                 return "您已嘗試多次登入，請稍後再試。"
             case .unknown(let error):
                 return "發生未知錯誤：\(error.localizedDescription)"
             }
         }
     }
     ```

 ---

 2. 轉換 Firebase 錯誤
 
     ```swift
     extension EmailAuthError {
         /// 根據 Firebase 的 `NSError` 轉換為 `EmailAuthError`
         static func handleFirebaseAuthError(_ error: Error) -> EmailAuthError {
             let errorCode = AuthErrorCode(_nsError: error as NSError)
             switch errorCode.code {
             case .emailAlreadyInUse:
                 return .emailAlreadyExists
             case .invalidEmail:
                 return .invalidEmailFormat
             case .weakPassword:
                 return .weakPassword
             case .wrongPassword:
                 return .wrongPassword
             case .userNotFound:
                 return .userNotFound
             case .tooManyRequests:
                 return .tooManyRequests
             default:
                 return .unknown(error)
             }
         }
     }
     ```

 ---

 3. 在 `EmailAuthController` 中使用
 
     ```swift
     func loginUser(withEmail email: String, password: String) async throws -> AuthDataResult {
         do {
             let credential = EmailAuthProvider.credential(withEmail: email, password: password)
             let authResult = try await Auth.auth().signIn(with: credential)
             return authResult
         } catch {
             throw EmailAuthError.handleFirebaseAuthError(error)
         }
     }
     ```

 ---

 4. 在 `ViewController` 中使用
 
 - 使用 `do-catch` 處理 `EmailAuthError`
 
     ```swift
     func loginViewDidTapLoginButton() {
         let email = loginView.email
         let password = loginView.password

         guard !email.isEmpty, !password.isEmpty else {
             AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
             return
         }

         Task {
             do {
                 _ = try await EmailAuthController.shared.loginUser(withEmail: email, password: password)
                 NavigationHelper.navigateToMainTabBar()
             } catch let error as EmailAuthError {
                 AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
             } catch {
                 AlertService.showAlert(withTitle: "錯誤", message: "發生未知錯誤，請稍後再試。", inViewController: self)
             }
         }
     }
     ```

 ---

 5. 其他應用
 
 - 在 `ForgotPasswordViewController` 處理重設密碼
 
     ```swift
     func forgotPasswordDidTapResetPasswordButton() {
         let email = forgotPasswordView.email

         guard !email.isEmpty else {
             AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件", inViewController: self)
             return
         }

         Task {
             do {
                 try await EmailAuthController.shared.resetPassword(forEmail: email)
                 AlertService.showAlert(withTitle: "通知", message: "如果您的信箱已註冊，我們將發送密碼重置郵件給您。", inViewController: self)
             } catch let error as EmailAuthError {
                 AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
             } catch {
                 AlertService.showAlert(withTitle: "錯誤", message: "發生未知錯誤，請稍後再試。", inViewController: self)
             }
         }
     }
     ```

 ---------

` * 結論`
 
 1.避免 `ViewController` 直接處理 Firebase 錯誤，提高可維護性
 2.提供使用者友善的錯誤訊息，提升 UX 體驗
 3.符合 iOS 設計原則（MVC、SRP），讓程式碼更乾淨、模組化
 */


// MARK: - 筆記：是否需要為 `GoogleSignInError`、`AppleSignInError` 設置 extension
/**
 
 ### 筆記：是否需要為 `GoogleSignInError`、`AppleSignInError` 設置 extension
 
 
 `* What`
 
 - 目前 `EmailAuthError` 透過 `handleFirebaseAuthError(_:)` 方法，將 `FirebaseAuth` 的 `AuthErrorCode` 轉換為可讀性更高的錯誤類型：
 
     ```swift
     static func handleFirebaseAuthError(_ error: Error) -> EmailAuthError
     ```
 
 - 問題是，是否應該為 `GoogleSignInError`、`AppleSignInError` 也提供類似的 extension，來統一處理 Firebase 錯誤？

 ---------

 `* Why`
 
 
 1. `EmailAuthError` 需要轉換 Firebase 錯誤
 
    - `EmailAuthError` 主要處理 FirebaseAuth (`Auth.auth().signIn`) 的 `NSError`，所以需要轉換 `AuthErrorCode` 來對應錯誤類型。
   
 2. `GoogleSignInError` 和 `AppleSignInError` 主要處理 OAuth 錯誤
 
    - `GoogleSignInError` 和 `AppleSignInError` 的錯誤來自 **Google/Apple API**，並不是 FirebaseAuth `AuthErrorCode`。
    - Firebase 只在 **OAuth 認證成功後** 進行登入 (`signIn(with: credential)`)，這部分的錯誤已經被 `.firebaseSignInFailed(error)` 處理。

 3. 目前 `GoogleSignInError` 和 `AppleSignInError` 已經包含 Firebase 錯誤處理
 
    - 它們的 `localizedDescription` 會直接返回錯誤訊息：
 
      ```swift
      case .firebaseSignInFailed(let error):
          return "Google 登入 Firebase 失敗：\(error.localizedDescription)"
      ```
 
    - 沒有 Firebase `AuthErrorCode` 的轉換需求，因此 **不需要 `handleFirebaseAuthError(_:)` 方法**。

 ---------

 `* How`
 
 - 不需要為 `GoogleSignInError` 和 `AppleSignInError` 添加 extension，因為：
 
    - 它們的錯誤來源主要來自 Google 和 Apple API，而非 Firebase `AuthErrorCode`。
    - 目前的 `localizedDescription` 已經能處理 Firebase 錯誤，沒有額外的轉換需求。

 ---------
 
` * 結論`
 
    - `GoogleSignInError` 和 `AppleSignInError` 不需要提供 `handleFirebaseAuthError(_:)`，目前的錯誤處理方式已經足夠清楚，不需要額外的 extension。
  */


// MARK: - (v)

import Foundation
import FirebaseAuth


/// `EmailAuthError` 用於管理 Email 登入、註冊、密碼相關的錯誤
///
/// - 目的:
///   1. 統一錯誤處理，避免直接返回 `NSError` 或 `Firebase` 的 `AuthErrorCode`
///   2. 提高可讀性與維護性，讓 UI 層可以根據錯誤類型提供適當的回應
///   3. 提升使用者體驗，針對不同錯誤提供更直觀的訊息
enum EmailAuthError: Error, LocalizedError {
    
    case emailAlreadyExists
    case invalidEmailFormat
    case weakPassword
    case wrongPassword
    case userNotFound
    case tooManyRequests
    case unknown(Error)
    
    /// 提供錯誤描述給 UI 顯示
    var errorDescription: String? {
        switch self {
        case .emailAlreadyExists:
            return "電子郵件已被使用，請嘗試其他帳號。"
        case .invalidEmailFormat:
            return "請輸入有效的電子郵件格式。"
        case .weakPassword:
            return "密碼過於簡單，請嘗試更強的密碼。"
        case .wrongPassword:
            return "密碼錯誤，請重新輸入。"
        case .userNotFound:
            return "此帳號不存在，請確認電子郵件是否正確。"
        case .tooManyRequests:
            return "您已嘗試多次登入，請稍後再試。"
        case .unknown(let error):
            return "發生未知錯誤：\(error.localizedDescription)"
        }
    }
    
}

// MARK: - extension

/// 錯誤轉換方法
///
/// 透過 `handleFirebaseAuthError(_:)`，將 Firebase 錯誤轉換為 `EmailAuthError`
extension EmailAuthError {
    
    static func handleFirebaseAuthError(_ error: Error) -> EmailAuthError {
        let errorCode = AuthErrorCode(_nsError: error as NSError)
        switch errorCode.code {
        case .emailAlreadyInUse:
            print("[EmailAuthError]: 電子郵件已被使用，請嘗試其他帳號。")
            return .emailAlreadyExists
        case .invalidEmail:
            print("[EmailAuthError]: 請輸入有效的電子郵件格式。")
            return .invalidEmailFormat
        case .weakPassword:
            print("[EmailAuthError]: 密碼過於簡單，請嘗試更強的密碼。")
            return .weakPassword
        case .wrongPassword:
            print("[EmailAuthError]: 密碼錯誤，請重新輸入。")
            return .wrongPassword
        case .userNotFound:
            print("[EmailAuthError]: 此帳號不存在，請確認電子郵件是否正確。")
            return .userNotFound
        case .tooManyRequests:
            print("[EmailAuthError]: 您已嘗試多次登入，請稍後再試。")
            return .tooManyRequests
        default:
            print("[EmailAuthError]: 發生未知錯誤：\(error.localizedDescription)")
            return .unknown(error)
        }
    }
    
}
