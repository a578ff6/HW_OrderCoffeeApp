//
//  FavoritesViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//

/*
 透過 FavoritesViewController 練習 UICollectionViewDiffableDataSource，即使資料變動較少，藉此可以熟悉 DiffableDataSource 的運作方式。

 使用 UICollectionViewDiffableDataSource 可以有效地處理資料的新增和刪除。
 因為 DiffableDataSource 會自動處理資料變動的動畫效果。這種方法對於將來處理更複雜的資料結構或需要進行批量更新的情況也很有幫助。
 所以利用這個機會來熟悉 DiffableDataSource，即便需求相對簡單。這將提升對於 UICollectionView 和資料更新的掌握度。
 */

/*
 ## FavoritesViewController：

    & 功能：
        - 顯示使用者收藏的飲品列表，允許使用者查看收藏的飲品詳細資料。

    & 視圖設置：
        - 透過 FavoritesView 設置主要視圖，並使用 FavoritesHandler 處理 UICollectionView 的資料顯示和用戶互動。

    & 資料加載：
        - 使用者從 UserProfileViewController 傳遞過來的 userDetails，其中包含 favorites，這些資料包括了飲品的 categoryId、subcategoryId 和 drinkId，用來加載飲品的詳細資料。
        - 當資料加載完成後，使用 handler.updateSnapshot(with:) 更新收藏飲品的顯示。
 
    & 數據處理：
        - FavoritesHandler： 負責 UICollectionView 的 dataSource 和 delegate 方法，包括顯示收藏的飲品列表，並處理點擊事件。

    & 主要流程：
        - 資料接收： 從 UserProfileViewController 傳遞的 userDetails 中提取收藏的飲品清單。
        - 資料加載與顯示： 透過 fetchDrinks 方法，使用 categoryId、subcategoryId 和 drinkId 加載收藏飲品的詳細資料，並將結果顯示在 UICollectionView 中。
        - 數據快照更新： 當資料加載完成後，透過 handler.updateSnapshot 更新 UI。
 
    & 主要功能概述：
        - 資料來源： FavoritesViewController 的收藏清單資料來源於 UserProfileViewController 傳遞的 userDetails，確保資料同步且減少重複請求。
        - 飲品資料查詢： 透過收藏清單中的 categoryId、subcategoryId 和 drinkId，直接從 MenuController 請求對應的飲品詳細資料，避免冗餘的資料遍歷。
        - 視圖與資料分離：FavoritesView 負責視圖的顯示，FavoritesHandler 負責資料處理，清楚劃分業務邏輯與 UI。
 */


// MARK: - 藉此練習 UICollectionViewDiffableDataSource（調整成三個參數、 處理User頁面傳遞的部分）
// https://reurl.cc/6dGbxk

import UIKit
import FirebaseAuth

/// 顯示使用者收藏的飲品清單
///
/// `FavoritesViewController` 使用從 `UserProfileViewController` 傳遞過來的 `userDetails`，並透過 `MenuController` 加載對應的飲品詳細資料。
class FavoritesViewController: UIViewController {

    // MARK: - Properties
    
    private let favoritesView = FavoritesView()
    private var handler: FavoritesHandler!
    
    /// 接收從 UserProfileViewController 傳遞過來的使用者詳細資訊
    var userDetails: UserDetails?
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        view = favoritesView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handler = FavoritesHandler(collectionView: favoritesView.collectionView)
        // 確保有 userDetails 資料，然後加載飲品
        if let userDetails = userDetails {
            fetchDrinks(for: userDetails.favorites)
        }
    }

    // MARK: - Data Loading
    
    /// 透過 `categoryId`、`subcategoryId` 和 `drinkId` 加載收藏的飲品資料
    ///
    /// 會使用 `MenuController` 來加載每個收藏飲品的詳細資訊，並更新到 UI。
    private func fetchDrinks(for favoriteDrinks: [FavoriteDrink]) {
        Task {
            var drinks: [Drink] = []
            
            // 依照每個收藏飲品的 ID 加載飲品詳細資料（categoryId, subcategoryId 和 drinkId 加載飲品詳細資料）
            for favoriteDrink in favoriteDrinks {
                print("Loading drink details for: \(favoriteDrink.drinkId)")
                if let drink = try? await MenuController.shared.loadDrinkById(
                    categoryId: favoriteDrink.categoryId,
                    subcategoryId: favoriteDrink.subcategoryId,
                    drinkId: favoriteDrink.drinkId
                ) {
                    drinks.append(drink)
                }
            }
            print("Loaded drinks: \(drinks.map { $0.name })") // 打印加載到的飲品
            // 更新 UICollectionView 的數據快照，顯示收藏的飲品清單
            handler.updateSnapshot(with: drinks)
        }
    }
    
}
