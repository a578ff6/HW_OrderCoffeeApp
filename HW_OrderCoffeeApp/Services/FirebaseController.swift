//
//  FirebaseController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

/*
 A. addDocument 與 setData
 
 * 使用 addDocument
    - 優點：
        - addDocument 方法會自動生成一個唯一的文檔 ID，無需手動指定 ID。
        - 適用於不關心文檔 ID 的場景。
    - 缺點：
        - 無法直接使用 uid 作為文檔 ID，因為 addDocument 會生成一個隨機 ID。
        - 如果想要使用用戶的 uid 作為文檔 ID，需要在其他地方額外存取或檢索文檔ID。

 * 使用 setData
    - 優點：
        - 使用 setData 可以手動指定文檔 ID，使用用戶的 uid 最為文檔 ID。
        - 便於以後通過 uid 快速檢索用戶文檔。
    - 缺點：
        - 如果 uid 已經存在，會覆蓋原有資料（可通過 merge 參數控制是否覆蓋））。
 
 ----------------------------------- ----------------------------------- -----------------------------------

 B. 避免覆蓋現有資料並區分不同登入來源的方法：
    * 避免覆蓋現有資料：
        - 在更新資料庫中的使用者資料時，應檢查是否有必要更新每個欄位。例如，只有在該欄位為空或有特定更新需求時才更新。
    * 儲存登入來源：
        - 儲存登入來源（如 Google、Apple 等）有助於後續對使用者行為的分析和管理。
    * 資料合併：
        - 當需要更新使用者資料時，使用合併操作（如 Firebase 的 merge: true）來確保新資料不會覆蓋掉已有的重要資料。
    * 唯一識別符（UID）：
        - 使用唯一識別符（如 Firebase 的 UID）來管理使用者資料，確保每個使用者都有一個唯一的標識符。
 
 ----------------------------------- ----------------------------------- -----------------------------------

C. 確保使用者可以通過不同的身份驗證提供者（如電子郵件、Google、Apple）登入同一個 Firebase 帳戶。
    - 我這邊在電子郵件/密碼登入部分也進行憑證關聯處理。這樣用戶可以在使用不同的身份驗證方式時，仍然能夠訪問同一個帳戶和數據。
 
    * 處理流程：
        - registerUser： 創建新用戶並儲存用戶資料到 Firestore。
        - loginUser： 使用電子郵件和密碼進行用戶登入，並且處理將電子郵件憑證與現有帳號關聯。
        - linkEmailCredential： 將電子郵件憑證與現有帳號關聯，或者如果連結失敗，則使用電子郵件憑證進行登入。
        - signInWithEmailCredential： 使用電子郵件憑證進行登入。
        - storeUserData： 將用戶數據保存到 Firestore，確保用戶無論使用哪種身份驗證方式登入，都能訪問到同一個 Firebase 帳戶和數據。
 
 ----------------------------------- ----------------------------------- -----------------------------------
 
 D. 三者登入流程模式：
    * Apple 第一次登入註冊時的處理
        - 獲取 Apple 憑證：Apple 返回用戶的憑證，包括用戶的名稱和郵箱地址。
        - 鏈接憑證：使用 linkAppleCredential 方法將 Apple 憑證與當前 Firebase 用戶帳戶關聯。
        - 保存用戶數據：在 storeAppleUserData 方法中，將用戶的名稱、郵箱和其他數據保存到 Firestore。
    
    * 電子郵件註冊
        - 創建新用戶：使用 registerUser 方法創建新用戶，並獲取用戶的認證結果。
        - 保存用戶數據：使用 storeUserData 方法將用戶的名稱、郵箱和其他數據保存到 Firestore。
    
    * Google 註冊
        - Google 登入或註冊：通過 signInWithGoogle 方法進行 Google 登入或註冊。
        - 鏈接憑證：使用 linkGoogleCredential 方法將 Google 憑證與當前 Firebase 用戶帳戶關聯。
        - 保存用戶數據：在 storeGoogleUserData 方法中，將用戶的名稱、郵箱和其他數據保存到 Firestore。
    
    * 總結
        - Apple 登入註冊：在 linkAppleCredential 和 signInWithAppleCredential 中處理，用戶的名稱和郵箱在 storeAppleUserData 方法中保存。
        - 電子郵件註冊：在 registerUser 和 loginUser 中處理，用戶的名稱和郵箱在 storeUserData 方法中保存。
        - Google 登入註冊：在 signInWithGoogle 和 linkGoogleCredential 中處理，用戶的名稱和郵箱在 storeGoogleUserData 方法中保存。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 E. 不同的身份驗證提供者（Apple、Google、Email）在處理有用戶數據時：
    * 電子郵件身份驗證（Email）
        1.電子郵件註冊
            - 若用戶使用電子郵件註冊，會調用 registerUser 方法。
            - 該方法會創建新用戶並保存用戶數據（包括 fullName 和 email）到 Firestore。
            - 如果用戶數據已存在，則更新該數據。
        2. 電子郵件登入
            - 若用戶使用電子郵件登入，會調用 loginUser 方法。
            - 該方法會生成憑證並嘗試將憑證與現有帳號關聯。如果失敗，則使用憑證直接登入。
            - 登入成功後，會更新用戶數據。
 
    * Google 身份驗證
        1. Google 登入或註冊
            - 若用戶使用 Google 登入或註冊，會調用 signInWithGoogle 方法。
            - 該方法會生成 Google 憑證，並嘗試將憑證與現有帳號關聯。如果失敗，則使用憑證直接登入。
            - 登入成功後，會調用 storeGoogleUserData 方法保存或更新用戶數據（包括 fullName 和 email）。
 
    * Apple 身份驗證
        1. Apple 登入或註冊
            - 若用戶使用 Apple 登入或註冊，會調用 signInWithApple 方法。
            - 該方法會生成 Apple 憑證，並嘗試將憑證與現有帳號關聯。如果失敗，則使用憑證直接登入。
            - 登入成功後，會調用 storeAppleUserData 方法保存或更新用戶數據（包括 fullName 和 email）。
 
    * 處理有用戶數據的情況：當用戶數據已存在時，不同身份驗證提供者會按以下步驟處理：
        1. 檢查現有數據
            - 在保存用戶數據之前，會檢查 Firestore 中是否已存在用戶數據（通過 userRef.getDocument 方法）。
            - 如果已存在數據，會根據不同的身份驗證提供者更新相關欄位（如 loginProvider 和 fullName）。
        2. 更新數據
            - 如果數據已存在，且某些欄位需要更新（例如使用新的身份驗證提供者登入），則會更新這些欄位。
        3. 保存數據
            - 最後，會將更新後的數據保存到 Firestore（通過 userRef.setData 方法）。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 F. 上傳圖片到 Firebase Storage 並更新 Firestore 中的資料。

    * 上傳圖片至 Firebase Storage：
        - 使用 uploadProfileImage 方法將用戶選擇的照片上傳至 Firebase Storage。
        - 使用 updateUserProfileImageURL 方法將照片的下載 URL 更新到 Firestore 中的 UserDetails 資料結構。
 
    * 使用使用者的 uid 作為照片的檔名：
        - 每個使用者都有一個唯一的 uid，將其作為檔名可以保證每個使用者的照片檔名都是唯一的，不會與其他使用者的照片發生衝突。
        - 使用 uid 作為檔名可以很容易地將照片與特定的使用者關聯起來，方便在需要時進行管理或查找。
        - 直接使用 uid 作為檔名可以省去生成新的唯一識別碼的步驟，簡化了上傳和存儲照片的流程。
        - 這樣，上傳的照片將存儲在 profile_images 資料夾下，並以 uid.jpg 為檔名。當需要更新或替換使用者的照片時，只需覆蓋相同的檔名即可，無需再為每張新照片生成新的檔名。

 ---------------------------------------- ---------------------------------------- ----------------------------------------

 G. 登出功能相關邏輯：
 
    * 登出操作：
        - 調用 Firebase 的登出方法，並將結果以成功或失敗的方式返回給調用者。

 ---------------------------------------- ---------------------------------------- ----------------------------------------

 */


// MARK: - 備用
/*
 import UIKit
 import Firebase
 import FirebaseStorage

 /// 處理 Firebase 資料庫相關
 class FirebaseController {
     
     static let shared = FirebaseController()
     
     /// 獲取當前用戶的詳細資料
     func getCurrentUserDetails(completion: @escaping (Result<UserDetails, Error>) -> Void) {
         guard let user = Auth.auth().currentUser else {
             completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
             return
         }
         
         let db = Firestore.firestore()
         let userRef = db.collection("users").document(user.uid)
         
         userRef.getDocument { (document, error) in
             if let error = error {
                 completion(.failure(error))
                 return
             }
             
             guard let document = document, document.exists, let userData = document.data() else {
                 completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
                 return
             }
             
             let email = userData["email"] as? String ?? ""
             let fullName = userData["fullName"] as? String ?? ""
             let profileImageURL = userData["profileImageURL"] as? String
             
             let userDetails = UserDetails(uid: user.uid, email: email, fullName: fullName, profileImageURL: profileImageURL, orders: nil)
             completion(.success(userDetails))
         }
     }
     
     /// 上傳圖片到 Firebase Storage 並獲取下載 URL
     func uploadProfileImage(_ image: UIImage, for uid: String, completion: @escaping (Result<String, Error>) -> Void) {
         let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
         guard let imageData = image.jpegData(compressionQuality: 0.8) else {
             completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image conversion failed"])))
             return
         }
         
         let metadata = StorageMetadata()
         metadata.contentType = "image/jpeg"
         
         storageRef.putData(imageData, metadata: metadata) { _, error in
             guard error == nil else {
                 completion(.failure(error!))
                 return
             }
             
             storageRef.downloadURL { url, error in
                 guard let downloadURL = url else {
                     completion(.failure(error!))
                     return
                 }
                 completion(.success(downloadURL.absoluteString))
             }
         }
     }
     
     /// 更新 Firestore 中的用戶圖片 URL
     func updateUserProfileImageURL(_ url: String, for uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
         let db = Firestore.firestore()
         db.collection("users").document(uid).updateData(["profileImageURL": url]) { error in
             if let error = error {
                 completion(.failure(error))
             } else {
                 completion(.success(()))
             }
         }
     }

     /// 執行登出操作
     func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
         do {
             try Auth.auth().signOut()
             completion(.success(()))
         } catch let signOutError as NSError {
             completion(.failure(signOutError))
         }
     }
     
 }
*/


// MARK: - 測試修改用
import UIKit
import Firebase
import FirebaseStorage

/// 處理 Firebase 資料庫相關
class FirebaseController {
    
    static let shared = FirebaseController()
    
    /// 獲取當前用戶的詳細資料
    func getCurrentUserDetails(completion: @escaping (Result<UserDetails, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let userData = document.data() else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
                return
            }
            
            let email = userData["email"] as? String ?? ""
            let fullName = userData["fullName"] as? String ?? ""
            let profileImageURL = userData["profileImageURL"] as? String
            
            let userDetails = UserDetails(uid: user.uid, email: email, fullName: fullName, profileImageURL: profileImageURL, orders: nil)
            completion(.success(userDetails))
        }
    }
    
    /// 上傳圖片到 Firebase Storage 並獲取下載 URL
    func uploadProfileImage(_ image: UIImage, for uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image conversion failed"])))
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    /// 更新 Firestore 中的用戶圖片 URL
    func updateUserProfileImageURL(_ url: String, for uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData(["profileImageURL": url]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    /// 執行登出操作
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }
    
}



