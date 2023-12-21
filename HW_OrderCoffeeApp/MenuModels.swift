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
    
    @DocumentID var id: String?     // Firestore 文件ID
    var title: String               // 分類的標題，例如 "咖啡飲品"
    var imageUrl: URL               // 圖片 URL
    
}


/// Subcategory 用於存儲子類別的基本訊息
struct Subcategory: Codable, Identifiable {
    
    @DocumentID var id: String?      // 子分類的 Firestore 文件ID
    var title: String                // 子分類的標題，例如 "熱濃縮咖啡飲料"
//    var drinks: [Drink]              // 該子分類下的飲品列表
    
}


/// SubcategoryDrinks 用於表示特定子類別及其對應的飲品列表。
struct SubcategoryDrinks {
    var subcategory: Subcategory
    var drinks: [Drink]
}



/// Drink  具體的飲品（如「CaffèAmericano」）。
/// 用於在 DrinksCategoryCollectionViewController、DrinksDetailTableViewController 中運用
struct Drink: Codable, Identifiable {
    
    @DocumentID var id: String?         // 飲品的 Firestore 文件ID
    var name: String                    // 飲品的名稱，例如 "美式咖啡"
    var subName: String                 // 飲品的子名稱
    var description: String             // 飲品的描述
    var imageUrl: URL                   // 飲品的圖片 URL
    var sizes: [String: SizeInfo]       // 飲品不同尺寸的資訊，例如 "特大杯"
    
}


/// SizeInfo 表示飲品的不同尺寸（如「Small」、「Medium」、「Large」等）。
struct SizeInfo: Codable {
    
    var price: Int          // 價格
    var caffeine: Int       // 咖啡因含量
    var calories: Int       // 熱量
    var sugar: Double       // 糖分含量
    
}




