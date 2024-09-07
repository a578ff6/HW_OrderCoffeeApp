//
//  WebsiteManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/1.
//


// MARK: - async/await 重構筆記
/*
 ## WebsiteManager：
    
    - 專門處理從 Firebase Firestore 獲取網站橫幅資料的邏輯。

    * 初始化：
        - private init() 使得外部無法直接初始化這個類別，強制使用單例。
        - https://reurl.cc/GpjreA
 
    * 主要方法：
        - loadWebsites() 方法使用 async/await 來從 Firestore 的 websites 集合中獲取所有文件，並將這些文件轉換為 Website 物件陣列。
        -  若獲取過程中發生錯誤，會自動拋出錯誤；成功時則直接回傳包含 Website 物件的陣列。
 */


// MARK: - async/await

import Foundation
import FirebaseFirestore

/// 處理網站橫幅資料加載的單例管理類別
class WebsiteManager {
    
    static let shared = WebsiteManager()
    
    private init() {}
    
    /// 從 Firestore 獲取「網站橫幅資料」的邏輯。
    func loadWebsites() async throws -> [Website] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("websites").getDocuments()
        let websites = snapshot.documents.compactMap { try? $0.data(as: Website.self) }
        return websites
    }
    
}



// MARK: - completion Handler 原版筆記
/*
 ## WebsiteManager：
    
    - 專門處理從 Firebase Firestore 獲取網站橫幅資料的邏輯。

    * 初始化：
        - private init() 使得外部無法直接初始化這個類別，強制使用單例。
        - https://reurl.cc/GpjreA
 
    * 主要方法：
        - loadWebsites(completion:) 方法從 Firestore 的 websites 集合中獲取所有文件，並將這些文件轉換為 Website 物件陣列。
        - 若獲取過程中發生錯誤，將錯誤回傳；若成功獲取，則回傳包含 Website 物件的陣列。
 */

// MARK: - 已完善

/*
import Foundation
import FirebaseFirestore

/// 處理網站橫幅資料加載的單例管理類別
class WebsiteManager {
    
    static let shared = WebsiteManager()
    
    private init() {}

    /// 從 Firestore 獲取「網站橫幅資料」的邏輯。
    func loadWebsites(completion: @escaping (Result<[Website], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("websites").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let websites = snapshot?.documents.compactMap { try? $0.data(as: Website.self) } ?? []
                completion(.success(websites))
            }
        }
    }
    
}
*/
