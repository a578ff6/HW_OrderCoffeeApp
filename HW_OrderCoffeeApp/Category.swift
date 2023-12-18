//
//  Category.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

import Foundation
import FirebaseFirestoreSwift

struct Category: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var imageUrl: URL
}




