//
//  FavoritesRepository.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/14.
//


// MARK: - 筆記: FavoritesRepository
/**
 
 ## 筆記: FavoritesRepository
 
 `* What`
 
 - `FavoritesRepository` 是專注於處理 `Firebase Firestore` 中「我的最愛」數據的資料層。
 - 提供與 `Firestore` 的數據交互功能，例如獲取使用者的收藏飲品清單，並將數據轉換為應用內的模型。
 - 支持「`按添加時間升序排列`」的排序邏輯，確保用戶的收藏順序在顯示時保持一致。
 
 ---------------
 
 `* Why`
 
 `1.分離關注點 (Separation of Concerns):`

 - 將數據存取邏輯與業務邏輯分離，確保更清晰的架構。
 - 提高代碼的可維護性，減少不同層級之間的耦合。
 
` 2.提高效率與準確性:`
 
 - 使用 `Firestore` 的 `order(by:) `方法，直接在後端進行「`按添加時間升序排列`」操作，減少客戶端的排序負擔。
 - 搭配 `Firestore` 的 `document.data(as:) 提供`的 `Codable` 支援，減少手動編碼錯誤並簡化映射過程。

 `3.保持用戶體驗一致：`
 
 - 透過按時間升序排列，確保 UI 顯示的收藏順序與用戶的添加順序一致，符合用戶直覺。
 
 `4.統一數據來源:`

 - 提供單一入口操作「我的最愛」，便於管理數據交互，避免重複代碼。
 
 ---------------

 `* How`
 
 `1.設計架構:`
 
 - 使用 `FavoritesRepository` 作為資料層，負責與 `Firestore` 的交互，專注於數據操作，避免干擾業務邏輯和 UI 層。
 - 與 `Firestore` 集成時，直接按 `timestamp` 屬性進行排序，確保數據返回的順序即符合業務需求。
 - 結合 `Codable` 支援，提高數據映射的效率和可讀性。
 
 
 `2.實現邏輯:`

 - 提供方法如 `getFavorites(for userId: String)`，實現與 Firestore 的交互。
 - 使用 `async/await` 寫法，確保代碼異步執行並保持簡潔。
 
 `3.時間排序`
  
 - 在 `Firestore` 查詢中使用 `.order(by: "timestamp", descending: false)`，以升序排序收藏項目。
 - 返回經過排序的 `FavoriteDrink` 陣列，供業務層直接使用。
 
 `4.最佳實踐:`

 - 定義數據模型 `FavoriteDrink`，並符合 `Codable` 協議以支持與 Firestore 的自動映射。
 - 使用泛型方法 `document.data(as:)` 進行數據轉換，減少硬編碼。
 
 - `timestamp`
    - 定義數據模型 `FavoriteDrink`，新增 `timestamp` 屬性作為時間排序依據。
    - 在數據庫中，利用 `FieldValue.serverTimestamp() `確保數據添加時自動生成時間戳，減少手動設置的潛在錯誤。
 
 ---------------

 `* 實現細節與考量`
 
 1. 為何使用 `Firestore` 的排序功能？
 
 - 在數據存取時直接完成排序，避免客戶端額外的排序計算，提高性能。
 - `Firestore` 支持多層排序，後續可擴展按其他字段進行二次排序。
 
` 2. timestamp 的必要性：`
 
 - 使用時間戳作為排序依據，能準確反映用戶的收藏行為，特別適用於需要「按時間順序」顯示的功能。
 - 使用 `Firebase` 的內建時間戳 FieldValue.serverTimestamp()，確保時間的一致性與準確性。
 
 `3. 可測試性與重用性：`
 
 - `getFavorites` 方法僅依賴 `userId` 和 `Firestore` 提供的數據，無需關注其他層的邏輯，便於獨立測試。
 - 返回結果已經排序，業務層和 UI 層可直接使用。
 
 ---------------

 `* 總結`
 
 `1.設置「按添加時間升序排列」的優點：`

 - 提高用戶體驗，收藏列表顯示順序符合用戶直覺。
 - 減少客戶端處理負擔，將排序邏輯交由 Firestore 處理。
 - 提供清晰且一致的數據結構，方便後續擴展和維護。
 
 `2.FavoritesRepository 的職責：`

 - 集中管理數據存取邏輯，確保數據準確性和一致性。
 - 提供排序和過濾功能，為業務邏輯提供便利的數據操作入口。
 */


// MARK: - FieldValue.serverTimestamp 的意義
/**
 
 ## FieldValue.serverTimestamp 的意義
 
 - `FieldValue.serverTimestamp() `是 Firebase Firestore 提供的一個方法，用來生成由 Firebase 伺服器時間 確定的時間戳。這個時間戳有以下特點和用處：

` * 主要功能`
 
 `1.自動生成時間戳：`
 
 - 當在 Firestore 中創建或更新文檔時，使用 FieldValue.serverTimestamp()，Firestore 會自動填入伺服器的當前時間。

 `2.確保時間一致性：`
 
 - 與客戶端生成的時間（如 Date()）相比，FieldValue.serverTimestamp() 是基於伺服器的時間，因此可以避免用戶設備時間不準確的問題。
 
 `3.適用場景：`

 - 添加數據時生成「創建時間」。
 - 更新數據時生成「最後更新時間」。
 
 ----------------

 `* 使用 FieldValue.serverTimestamp() 的好處`
 
 `1.一致性：`

 - 保證所有數據的時間基於 Firebase 的伺服器，而非用戶設備的本地時間。
 - 避免因用戶設備時間不準確（如手動更改系統時間）導致數據錯亂。
 
 `2.簡化邏輯：`

 - 添加數據時不需要自己生成 Date，也不用擔心時區問題，Firebase 會自動處理。
 
 `3.自動排序：`

 - 如果數據中有 timestamp 欄位，可以利用 Firestore 的 order(by:) 方法直接按時間排序，方便實現像「按添加時間升序排列」的功能。
 */



// MARK: - (v)

import UIKit
import Firebase

/// 負責處理與 Firebase Firestore 中「我的最愛」相關的數據交互。
/// - 提供與 Firestore 的數據交互功能，例如獲取收藏飲品並按時間排序。
/// - 支持以 Codable 方式與 Firestore 進行高效交互，簡化數據映射。
///
/// 功能:
/// 1. 從 Firestore 獲取指定使用者的收藏列表，按添加時間升序排列。
/// 2. 使用 Codable 支援將 Firestore 數據直接轉換為應用內的數據模型。
///
/// 注意事項:
/// - Firestore 操作為異步操作，需處理可能的錯誤。
/// - 使用 `document.data(as:)` 方法進行數據映射，減少手動編碼。
class FavoritesRepository {
    
    /// 從 Firestore 獲取指定使用者的所有收藏飲品
    /// - Parameter userId: Firebase 認證的使用者 ID。
    /// - Returns: 包含按時間升序排列的 `FavoriteDrink` 陣列。
    /// - Throws: 如果獲取數據或數據轉換失敗，將拋出相應錯誤。
    func getFavorites(for userId: String) async throws -> [FavoriteDrink] {
        let favoritesCollectionRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("favorites")
            .order(by: "timestamp", descending: false) // 按添加時間升序排列
        
        let querySnapshot = try await favoritesCollectionRef.getDocuments()
        let favorites = try querySnapshot.documents.map { document in
            try document.data(as: FavoriteDrink.self)
        }
        print("從 Firestore 獲取的原始收藏數據: \(favorites)")
        return favorites
    }
    
}
