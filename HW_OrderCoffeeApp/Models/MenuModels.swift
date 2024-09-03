//
//  MenuModels.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//


import Foundation
import FirebaseFirestoreSwift


/// Category 最頂層的類別（如「CoffeeBeverages」、「Teavana」等）。
/// 用於在 MenuCollectionViewController 中展示不同的飲品類別。
struct Category: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var imageUrl: URL
    var subtitle: String
}


/// Subcategory 用於存儲子類別的基本訊息
struct Subcategory: Codable, Identifiable {
    @DocumentID var id: String?      
    var title: String
}


/// SubcategoryDrinks 用於表示特定子類別及其對應的飲品列表。
struct SubcategoryDrinks {
    var subcategory: Subcategory
    var drinks: [Drink]
}


/// Drink  具體的飲品（如「CaffèAmericano」）。
/// 用於在 DrinksCategoryCollectionViewController、DrinksDetailTableViewController 中運用
struct Drink: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var subName: String
    var description: String
    var imageUrl: URL
    var sizes: [String: SizeInfo]
    var prepTime: Int   // 以分鐘為準備時間
}


/// SizeInfo 表示飲品的不同尺寸（如「Small」、「Medium」、「Large」等）。
struct SizeInfo: Codable, Hashable {
    var price: Int
    var caffeine: Int
    var calories: Int
    var sugar: Double
}




