//
//  GoogleSignInError.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/2/7.
//

// MARK: - GoogleSignInError 筆記
/**
 
 ### GoogleSignInError 筆記
 
 - 當初在點擊Google按鈕後，接著點擊cancel，使用者取消 Google 登入、拒絕授權 Google 提供帳戶資訊時，會出現錯誤訊息。
 - 但這個錯誤訊息並不是需要呈現給使用者，畢竟這是出自使用者自身的行為選擇。
 
 ------

 `* What`
 
 - `GoogleSignInError` 是一個 `Error` 類型的列舉 (`enum`)，用於標示 Google 登入過程中可能發生的錯誤情況。

 - 這個錯誤類別的目標是：
 
    1. 統一處理 Google 登入相關錯誤，避免錯誤訊息分散在不同地方，使程式碼更易讀。
    2. 提供清楚的錯誤類型，讓開發者能夠透過 `catch` 判斷不同的錯誤情境，進行適當的 UI 回應。
    3. 提升可維護性，若未來需要新增或調整錯誤處理邏輯，只需變更 `GoogleSignInError`，而不需修改整個登入流程。

 - 目前 `GoogleSignInError` 包含：
 
    - `.userCancelled`：使用者取消 Google 登入。
    - `.accessDenied`：使用者拒絕授權 Google 提供帳戶資訊。
    - `.missingClientID`：找不到 Firebase 的 `Client ID`，導致無法啟動 Google 登入。
    - `.invalidGoogleUser`：Google 登入成功但無法獲取 `idToken`，表示登入資訊不完整或無效。
    - `.firebaseSignInFailed(Error)`：Google 登入成功，但 Firebase 身份驗證失敗。

 ------

 `* Why`
 
 1. 清楚定義錯誤類型，避免混亂
 
 - 在 Google 登入過程中，有多種可能的錯誤來源，例如：
 
    - 使用者行為（如取消登入、拒絕授權）
    - 開發環境設定錯誤（如 Firebase `Client ID` 缺失）
    - 登入流程問題（如 `idToken` 缺失、Firebase 身份驗證失敗）

 - 若不封裝錯誤類型，而直接依賴 `Error.localizedDescription`，會讓 `catch` 區塊變得難以維護，因為不同的錯誤類型可能有相似的 `localizedDescription`。

---
 
 2. 提供適當的 UI 處理
 
 - 不同的錯誤類型，適合採取不同的 UI 回應：
 
    - `.userCancelled` 和 `.accessDenied`：這些錯誤來自使用者的決定，因此 **不需要彈出 Alert**，避免影響使用者體驗，只需記錄日誌或 `print()` 訊息即可。
    - 其他錯誤：應該顯示 Alert 通知使用者，以便採取適當的行動。

 ---

 3. 統一錯誤處理邏輯
 
 - 透過 `GoogleSignInError`，可以在 `catch` 區塊內透過 `switch` 來統一錯誤處理，讓程式碼更具可讀性，且避免不必要的錯誤訊息彈出。

 ------

 `* How`
 
 1. 定義 `GoogleSignInError`
 
     ```swift
     /// `GoogleSignInError`：Google 登入錯誤類型
     enum GoogleSignInError: Error, LocalizedError {
         case userCancelled            // 使用者取消登入
         case accessDenied             // 使用者拒絕授權
         case missingClientID          // Firebase 設定錯誤，找不到 Client ID
         case invalidGoogleUser        // Google 使用者驗證失敗
         case firebaseSignInFailed(Error) // Google 登入 Firebase 失敗

         /// 回傳錯誤訊息
         var errorDescription: String? {
             switch self {
             case .userCancelled, .accessDenied:
                 return nil  // 這些錯誤不需顯示 Alert
             case .missingClientID:
                 return "無法取得 Firebase Client ID。請檢查 Firebase 設定。"
             case .invalidGoogleUser:
                 return "Google 使用者驗證失敗，請稍後再試。"
             case .firebaseSignInFailed(let error):
                 return "Google 登入 Firebase 失敗：\(error.localizedDescription)"
             }
         }
     }
     ```

 ---

 2. 在 Google 登入流程中拋出 `GoogleSignInError`
 
 - 在 `signInWithGoogleSDK()` 方法內，當 Google SDK 回傳錯誤時，根據錯誤類型轉換為 `GoogleSignInError`：
 
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

 3. 在 `LoginViewController` 內處理 `GoogleSignInError`
 
 - 當使用者點擊 Google 登入按鈕時，統一處理 `GoogleSignInError`：
 
     ```swift
     func loginViewDidTapGoogleLoginButton() {
         dismissKeyboard()
         Task {
             HUDManager.shared.showLoading(text: "Logging in...")
             do {
                 _ = try await GoogleSignInController.shared.signInWithGoogle(presentingViewController: self)
                 NavigationHelper.navigateToMainTabBar()
             } catch let error as GoogleSignInError {
                 handleGoogleSignInError(error)
             } catch {
                 AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
             }
             HUDManager.shared.dismiss()
         }
     }

     /// 統一處理 Google 登入錯誤
     private func handleGoogleSignInError(_ error: GoogleSignInError) {
         switch error {
         case .userCancelled, .accessDenied:
             print("使用者取消或拒絕授權 Google 登入，無需顯示錯誤訊息。")
         default:
             AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription ?? "發生未知錯誤", inViewController: self)
         }
     }
     ```

 ------

 `* 為何 GoogleSignInError 需要 .userCancelled 與 .accessDenied？`
 
 1.區分「使用者行為」與「系統錯誤」
 
    - `.userCancelled` 和 `.accessDenied` 來自 **使用者的操作**，這些情境通常 **不應該彈出 Alert**，避免影響使用者體驗。
    - 其他錯誤（如 `.firebaseSignInFailed`）則應該通知使用者，以便他們了解發生了問題。

 ---
 
 2. 減少不必要的錯誤提示
 
    - 假設沒有 `.userCancelled` 和 `.accessDenied`，當使用者按下「取消」或拒絕授權時，系統會彈出錯誤訊息：
    
    - 「發生錯誤，請稍後再試。」
    - 這樣的提示 **是不必要的**，因為使用者 **已經知道自己取消了登入**，彈出 Alert 只會造成干擾。

 3. 改善使用者體驗
 
    - 當使用者主動取消登入時，只需記錄 `print()` 訊息，而不需要影響 UI。
    - 這樣可以讓使用者在 **未來想登入時**，不會因為過多的錯誤彈窗而產生不好的體驗。

 ------

 `* 總結`
 
 1.`GoogleSignInError` 主要用於統一錯誤處理，確保程式碼結構清晰且易於維護。
 
 2. `.userCancelled` 和 `.accessDenied` 用於 **避免不必要的 Alert**，提升使用者體驗。
 
 3. 透過 `switch` 判斷錯誤類型，可以讓 UI 反應更直覺，例如：
 
    - 使用者主動取消登入時 **不顯示錯誤**
    - 其他錯誤則適當顯示 Alert 提醒使用者。
 */


// MARK: - (v)

import Foundation

// `GoogleSignInError`：Google 登入錯誤類型
///
/// - `userCancelled`：使用者取消登入
/// - `accessDenied`：使用者拒絕授權
/// - `missingClientID`：Firebase 設定錯誤，找不到 Client ID
/// - `invalidGoogleUser`：Google 使用者驗證失敗
/// - `firebaseSignInFailed(Error)`： Google 登入 Firebase 失敗
enum GoogleSignInError: Error, LocalizedError {
    case userCancelled
    case accessDenied
    case missingClientID
    case invalidGoogleUser
    case firebaseSignInFailed(Error)
    
    var localizedDescription: String? {
        switch self {
        case .userCancelled, .accessDenied:
            return nil   // 取消登入、拒絕授權不需要顯示錯誤
        case .missingClientID:
            return "無法取得 Firebase Client ID。"
        case .invalidGoogleUser:
            return "Google 使用者驗證失敗。"
        case .firebaseSignInFailed(let error):
            return "Google 登入 Firebase 失敗：\(error.localizedDescription)"
        }
    }
}
