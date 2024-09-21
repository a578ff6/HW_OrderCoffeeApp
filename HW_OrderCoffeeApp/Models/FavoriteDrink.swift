//
//  FavoriteDrink.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/20.
//


/*
 
 ## FavoriteDrink：
    
    - 優化從 Firebase Firestore 查詢資料的效率，直接保存 `categoryId`、`subcategoryId` 和 `drinkId` 可以避免在查詢飲品時需要遍歷多層次結構。

 &. 為何要做這樣的調整？
 
    - 在 Firestore 中，飲品資料位於較深的層級，包含不同的類別和子類別。如果只保存 `drinkId`，每次需要遍歷大量類別和子類別去查找對應的飲品資料，這會增加資料查詢的複雜度與耗時。

 &. 調整後的結構
 
    * 將 favorites 從原本的僅存 String (drinkId) 改成儲存以下三個屬性：
        - categoryId: 飲品所屬的類別 ID
        - subcategoryId: 飲品所屬的子類別 ID
        - drinkId: 飲品 ID

 &. 調整後的好處
 
    * 查詢效率提升：
        - 在收藏飲品時儲存 `categoryId` 和 `subcategoryId`，能夠直接根據這些資訊快速查詢到 Firestore 中對應的飲品資料，避免遍歷整個類別結構。
    
    * 資料結構更清晰：
        - 這樣的資料結構更符合 Firestore 的查詢邏輯，不僅在查詢時減少運算量，也讓未來擴展功能時更加方便。

    * 與現有查詢方法兼容：
        - 可以繼續使用目前在 `DrinkDetailViewController` 中使用的 `loadDrinkById` 。
        - 因為這個方法已經支持以 `categoryId`、`subcategoryId` 和 `drinkId` 查找飲品資料，不會造成邏輯錯亂。
 */


import UIKit

/// 添加我的最愛時，要添加categoryId、subcategoryId、drinkId。
///
/// 以便能夠直接查找到對應的飲品資料。這會讓查詢更加直接，避免每次都需要遍歷整個結構。
struct FavoriteDrink: Codable {
    var categoryId: String
    var subcategoryId: String
    var drinkId: String
}



