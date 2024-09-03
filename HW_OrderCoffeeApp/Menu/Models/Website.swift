//
//  Website.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/1.
//

import Foundation
import FirebaseFirestoreSwift

/// 處理網站頁面相關
struct Website: Codable, Identifiable {
    @DocumentID var id: String?
    var imagePath: String
    var url: String
}
