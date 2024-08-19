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

 
 
 F. 將 loadUserOrders 與 getCurrentUserDetails 整合在一起，藉此减少重複調用。(暫時改掉)

 */


// MARK: - 備用
/*
 import UIKit
 import Firebase

 /// 處理 Firebase 資料庫相關
 class FirebaseController {
     
     static let shared = FirebaseController()
     
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
                 let db = Firestore.firestore()
                 db.collection("users").document(result.user.uid).setData([
                     "email": email,
                     "fullName": fullName,
                     "uid": result.user.uid,
                     "loginProvider": "email"
                 ], merge: true) { error in
                     if let error = error {
                         completion(.failure(error))
                     } else {
                         completion(.success(result))
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
             
             let userDetails = UserDetails(uid: user.uid, email: email, fullName: fullName)
             completion(.success(userDetails))
         }
     }
     
     /// 保存用戶數據到 Firestore
     private func storeUserData(authResult: AuthDataResult, loginProvider: String, completion: @escaping (Result<Void, Error>) -> Void) {
         let db = Firestore.firestore()
         let user = authResult.user
         let userRef = db.collection("users").document(user.uid)
         
         userRef.getDocument { (document, error) in
             if let document = document, document.exists, var userData = document.data() {
                 // 更新現有資料
                 userData["email"] = user.email ?? ""
                 userData["loginProvider"] = loginProvider
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
                 
                 if let displayName = user.displayName {
                     userData["fullName"] = displayName
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


// MARK: - 測試修改用
import UIKit
import Firebase

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

            
            //let userDetails = UserDetails(uid: user.uid, email: email, fullName: fullName)
            
            let userDetails = UserDetails(uid: user.uid, email: email, fullName: fullName, profileImageURL: profileImageURL, orders: nil)
            completion(.success(userDetails))
        }
    }
    
}





// MARK: - 先移除掉（目前用不到）
/// 獲取當前用戶的詳細資料和訂單歷史（將歷史訂單給移除掉，給從歷史訂單單例模式去處理）
/*
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
        
        userRef.collection("orders").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let orders = snapshot?.documents.compactMap { document -> OrderItem? in
                    return try? document.data(as: OrderItem.self)
                } ?? []
                let userDetails = UserDetails(uid: user.uid, email: email, fullName: fullName, orders: orders.isEmpty ? nil : orders)
                completion(.success(userDetails))
            }
        }
        
    }
}
 */


// MARK: - 歷史訂單的視圖控制器（先移除，要更改流程）
/*
 // 單獨設置一個歷史訂單的視圖控制器來顯示歷史訂單：
 

 import UIKit

 class HistoryOrderViewController: UIViewController {

     @IBOutlet weak var historyOrderCollectionView: UICollectionView!
     
     var historyOrders: [OrderItem] = []
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupCollectionView()
         loadHistoryOrders()
     }
     
     private func setupCollectionView() {
         historyOrderCollectionView.delegate = self
         historyOrderCollectionView.dataSource = self
         historyOrderCollectionView.register(OrderItemCollectionViewCell.self, forCellWithReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier)
     }
     
     private func loadHistoryOrders() {
         FirebaseController.shared.getUserOrderHistory { [weak self] result in
             switch result {
             case .success(let orders):
                 self?.historyOrders = orders
                 self?.historyOrderCollectionView.reloadData()
             case .failure(let error):
                 print("Error loading history orders: \(error)")
                 AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
             }
         }
     }
 }

 // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
 extension HistoryOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return historyOrders.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell else {
             fatalError("Cannot create OrderItemCollectionViewCell")
         }
         
         let orderItem = historyOrders[indexPath.row]
         cell.configure(with: orderItem)
         return cell
     }
 }

 // FirebaseController 中添加獲取歷史訂單的方法

 import Foundation
 import FirebaseFirestore
 import FirebaseAuth

 class FirebaseController {
     
     static let shared = FirebaseController()
     
     /// 獲取用戶歷史訂單
     func getUserOrderHistory(completion: @escaping (Result<[OrderItem], Error>) -> Void) {
         guard let user = Auth.auth().currentUser else {
             completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
             return
         }
         
         let db = Firestore.firestore()
         let ordersRef = db.collection("users").document(user.uid).collection("orders")
         
         ordersRef.getDocuments { snapshot, error in
             if let error = error {
                 completion(.failure(error))
             } else {
                 let orders = snapshot?.documents.compactMap { document -> OrderItem? in
                     return try? document.data(as: OrderItem.self)
                 } ?? []
                 completion(.success(orders))
             }
         }
     }
 }

 */
