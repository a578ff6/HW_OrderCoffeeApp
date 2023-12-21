//
//  FirebaseController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

import UIKit
import Firebase


class FirebaseController {
    
    static let shared = FirebaseController()
    
    
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
    
    
    
    /// 創建新用戶，並將用戶資料儲存到 Firestore。
    func registerUser(withEmail email: String, password: String, fullName: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                let db = Firestore.firestore()
                db.collection("users").addDocument(data: ["email": email, "fullname": fullName, "uid": result.user.uid]) { error in
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
                // 登入失敗，返回錯誤
                completion(.failure(error))
            } else if let result = result {
                // 登入成功，返回結果
                completion(.success(result))
            }
        }
    }
    
    
    /// 發送密碼重置郵件
    func resetPassword(forEmail email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // 發送失敗，返回錯誤
                completion(.failure(error))
            } else {
                // 發送成功
                completion(.success(()))
            }
        }
    }
    
    
    
    /// 讀取飲品類別和子類別的資料。
    func loadDrinksForCategory(categoryId: String, completion: @escaping (Result<[SubcategoryDrinks], Error>) -> Void) {
        let db = Firestore.firestore()
        
        var subcategoryDrinksList: [SubcategoryDrinks] = []
        
        db.collection("Categories").document(categoryId)
            .collection("Subcategories").getDocuments { subcategorySnapshot, error in
                guard let subcategoryDocuments = subcategorySnapshot?.documents else {
                    if let error = error {
                        completion(.failure(error))
                    }
                    return
                }
                
                let group = DispatchGroup()
                
                for subcategoryDocument in subcategoryDocuments {
                    let subcategoryId = subcategoryDocument.documentID
                    let subcategory = try? subcategoryDocument.data(as: Subcategory.self)
                    
                    group.enter()
                    db.collection("Categories").document(categoryId)
                        .collection("Subcategories").document(subcategoryId)
                        .collection("Drinks").getDocuments { (drinkSnapshot, error) in
                            if let drinkDocuments = drinkSnapshot?.documents {
                                let drinks = drinkDocuments.compactMap { document -> Drink? in
                                    return try? document.data(as: Drink.self)
                                }
                                if let subcategory = subcategory {
                                    subcategoryDrinksList.append(SubcategoryDrinks(subcategory: subcategory, drinks: drinks))
                                }
                            }
                            group.leave()
                        }
                }
                
                group.notify(queue: .main) {
                    completion(.success(subcategoryDrinksList))
                }
            }
    }
    
}
