//
//  AppleSignInError.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/2/7.
//


// MARK: - AppleSignInError 筆記
/**
 
 ### AppleSignInError 筆記

 `* What:`
 
 - `AppleSignInError` 是一個 `enum`，負責管理 Apple 登入過程中可能發生的錯誤。

 - 它涵蓋 Apple 身分驗證 (`ASAuthorizationController`) 和 Firebase 登入 (`Auth.auth().signIn`) 相關的錯誤，確保錯誤分類清晰，易於維護。

 --------
 
` * Why:`
 
 1. 統一錯誤處理：
 
    - Apple 登入涉及多個階段，可能出現不同類型的錯誤，透過 `enum` 明確分類。
    
 2. 提升可讀性與維護性：
 
    - 讓開發人員可以快速理解錯誤類型，方便除錯。
    
 3. 避免不必要的錯誤提示：
 
    - 使用者取消 (`userCancelled`) 或未登入 Apple ID (`appleIDNotSignedIn`) 屬於正常行為，不應顯示錯誤訊息，以提升使用者體驗。
    
 4. 提供適當的錯誤回應：
 
    - 例如 `missingIdentityToken` 或 `firebaseSignInFailed`，需要通知使用者發生錯誤，並提供適當的引導。

 --------

 `* How: `

 1. 錯誤訊息處理 (`localizedDescription`)
 
     ```swift
     var localizedDescription: String? {
         switch self {
         case .userCancelled, .appleIDNotSignedIn:
             return nil  // 這些錯誤不需顯示
         case .missingIdentityToken:
             return "無法取得 Apple 身分驗證令牌，請稍後再試。"
         case .firebaseSignInFailed(let error):
             return "Apple 登入 Firebase 失敗：\(error.localizedDescription)"
         }
     }
     ```

 ---
 
 2. 與 `authorizationController(controller:didCompleteWithError:)` 搭配使用
 
     ```swift
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
     ```

 --------

 `* 總結`
 
 1. `AppleSignInError` 統一管理 Apple 登入相關錯誤，使程式碼更易讀、易維護。
 2. 針對 `userCancelled` 和 `appleIDNotSignedIn`，只記錄 Log，不彈出錯誤，以提升使用者體驗。
 3. 確保 `missingIdentityToken`、 和 `firebaseSignInFailed` 會適當通知使用者，提供錯誤訊息。
 4. `authorizationController(controller:didCompleteWithError:)` 內部使用 `AppleSignInError`，統一錯誤處理邏輯，避免重複代碼。

 */


// MARK: - (v)

import Foundation

/// Apple 登入錯誤類型
///
/// - `userCancelled`：使用者手動取消 Apple 登入
/// - `appleIDNotSignedIn`：使用者未登入 Apple ID，導致 Apple 登入請求失敗
/// - `missingIdentityToken`：Apple 身分驗證令牌 (`identityToken`) 遺失
/// - `firebaseSignInFailed(Error)`：Apple 登入 Firebase 失敗，包含 Firebase 內部錯誤
enum AppleSignInError: Error, LocalizedError {
    case userCancelled
    case appleIDNotSignedIn
    case missingIdentityToken
    case firebaseSignInFailed(Error)

    /// 根據錯誤類型返回適當的錯誤描述
    var localizedDescription: String? {
        switch self {
        case .userCancelled, .appleIDNotSignedIn:
            return nil  // 使用者取消、未登入 Apple ID，不顯示錯誤
        case .missingIdentityToken:
            return "無法取得 Apple 身分驗證令牌。"
        case .firebaseSignInFailed(let error):
            return "Apple 登入 Firebase 失敗：\(error.localizedDescription)"
        }
    }
}
