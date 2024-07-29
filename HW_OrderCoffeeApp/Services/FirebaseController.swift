//
//  FirebaseController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - 備份（還未修改註冊版本）
/*
 1. 使用 addDocument
    - 優點：
        - addDocument 方法會自動生成一個唯一的文檔 ID，無需手動指定 ID。
        - 適用於不關心文檔 ID 的場景。
    - 缺點：
        - 無法直接使用 uid 作為文檔 ID，因為 addDocument 會生成一個隨機 ID。
        - 如果想要使用用戶的 uid 作為文檔 ID，需要在其他地方額外存取或檢索文檔ID。

 2. 使用 setData
    - 優點：
        - 使用 setData 可以手動指定文檔 ID，使用用戶的 uid 最為文檔 ID。
        - 便於以後通過 uid 快速檢索用戶文檔。
    - 缺點：
        - 如果 uid 已經存在，會覆蓋原有資料（可通過 merge 參數控制是否覆蓋））。
 
 3. 將 loadUserOrders 與 getCurrentUserDetails 整合在一起，藉此减少重複調用。

 4. 歷史訂單由 FirebaseController 獲取。
 */


/*
 import UIKit
 import Firebase

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
                     "uid": result.user.uid
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
         Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
             if let error = error {
                 completion(.failure(error))
             } else if let result = result {
                 completion(.success(result))
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
     
 }
*/


// MARK: - 測試修改用

import UIKit
import Firebase

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
                    "uid": result.user.uid
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
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
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
