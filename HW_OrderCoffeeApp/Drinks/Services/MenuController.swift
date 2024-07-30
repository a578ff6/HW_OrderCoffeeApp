//
//  MenuController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/1.
//

// MARK: - 原版
/*
import UIKit
import FirebaseFirestore

/// 用於處理所有菜單的單例模式
class MenuController {
    
    static let shared = MenuController()
    
    /// 從 Firestore 的 "Categories" 集合中獲取所有類別資料。
    /// - Parameter completion: 當數據加載完成時執行的閉包，返回結果，包含類別陣列或錯誤。
    func loadCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("Categories").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let categories = snapshot?.documents.compactMap({ document -> Category? in
                    return try? document.data(as: Category.self)
                }) ?? []
                completion(.success(categories))
            }
        }
    }
    
    
    
    /// 首先從指定類別的 "Subcategories" 子集合中讀取所有子類別，
    /// 然後對於每個子類別，從其 "Drinks" 子集合中獲取相關飲品數據。
    /// - Parameters:
    ///   - categoryId: 要查詢的類別 ID。
    ///   - completion: 當數據加載完成時執行的閉包，返回一個結果，包含 SubcategoryDrinks 陣列或錯誤。
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
                
                // 使用 DispatchGroup 確保所有數據加載完成後再調用完成閉包。
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
                
                // 所有子類別和飲品加載完成後，調用完成閉包。
                group.notify(queue: .main) {
                    completion(.success(subcategoryDrinksList))
                }
            }
    }
}
*/



// MARK: - 添加錯誤
import UIKit
import FirebaseFirestore

/// 用於處理所有菜單的單例模式
class MenuController {
    
    static let shared = MenuController()
        
    /// 從 Firestore 的 "Categories" 集合中獲取所有類別資料。
    /// - Parameter completion: 當數據加載完成時執行的閉包，返回結果，包含類別陣列或錯誤。
    func loadCategories(completion: @escaping (Result<[Category], MenuControllerError>) -> Void) {
        let db = Firestore.firestore()
        db.collection("Categories").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(.from(error)))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.failure(.categoriesNotFound))
                return
            }
            
            let categories = documents.compactMap { document -> Category? in
                return try? document.data(as: Category.self)
            }
            
            if categories.isEmpty {
                completion(.failure(.categoriesNotFound))
            } else {
                completion(.success(categories))
            }
        }
    }
    
    
    /// 首先從指定類別的 "Subcategories" 子集合中讀取所有子類別，
    /// 然後對於每個子類別，從其 "Drinks" 子集合中獲取相關飲品數據。
    /// - Parameters:
    ///   - categoryId: 要查詢的類別 ID。
    ///   - completion: 當數據加載完成時執行的閉包，返回一個結果，包含 SubcategoryDrinks 陣列或錯誤。
    func loadDrinksForCategory(categoryId: String, completion: @escaping (Result<[SubcategoryDrinks], MenuControllerError>) -> Void) {
        let db = Firestore.firestore()
        var subcategoryDrinksList: [SubcategoryDrinks] = []
        
        db.collection("Categories").document(categoryId).collection("Subcategories").getDocuments { subcategorySnapshot, error in
            
            if let error = error {
                completion(.failure(.from(error)))
                return
            }
            
            guard let subcategoryDocuments = subcategorySnapshot?.documents else {
                completion(.failure(.menuItemsNotFound))
                return
            }
            
            // 使用 DispatchGroup 確保所有數據加載完成後再調用完成閉包。
            let group = DispatchGroup()
            
            for subcategoryDocument in subcategoryDocuments {
                let subcategoryId = subcategoryDocument.documentID
                let subcategory = try? subcategoryDocument.data(as: Subcategory.self)
                
                group.enter()
                db.collection("Categories").document(categoryId).collection("Subcategories").document(subcategoryId).collection("Drinks").getDocuments { (drinkSnapshot, error) in
                    if let error = error {
                        group.leave()
                        completion(.failure(.from(error)))
                        return
                    }
                    
                    guard let drinkDocuments = drinkSnapshot?.documents else {
                        group.leave()
                        completion(.failure(.menuItemsNotFound))
                        return
                    }
                    
                    let drinks = drinkDocuments.compactMap { document -> Drink? in
                        return try? document.data(as: Drink.self)
                    }
                    
                    if let subcategory = subcategory {
                        subcategoryDrinksList.append(SubcategoryDrinks(subcategory: subcategory, drinks: drinks))
                    }
                    
                    group.leave()
                }
            }
            
            // 所有子類別和飲品加載完成後，調用完成閉包。
            group.notify(queue: .main) {
                if subcategoryDrinksList.isEmpty {
                    completion(.failure(.menuItemsNotFound))
                } else {
                    completion(.success(subcategoryDrinksList))
                }
            }
        }
    }
}


// MARK: - Error

enum MenuControllerError: Error, LocalizedError {
    case categoriesNotFound
    case menuItemsNotFound
    case unknownError
    case firebaseError(Error)
    
    // 將 Firebase 錯誤轉為 MenuControllerError，使得錯誤處理相對一致
    static func from(_ error: Error) -> MenuControllerError {
        return .firebaseError(error)
    }
    
    var errorDescription: String? {
        switch self {
        case .categoriesNotFound:
            return NSLocalizedString("Categories not found", comment: "Categories Not Found")
        case .menuItemsNotFound:
            return NSLocalizedString("Menu items not found", comment: "Menu items not found")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "Unknown Error")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}
