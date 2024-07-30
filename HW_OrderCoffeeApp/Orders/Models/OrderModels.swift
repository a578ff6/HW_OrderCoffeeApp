//
//  OrderModels.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/2.
//

/*
 ## 測試的時候發現，我如果沒有依照新添加飲品項目的順序去刪除的話，會導致無法正常刪除項目。##
 
 A. 原先沒有使用 UUID 的問題
    * 基於陣列索引：
        - 由於基於陣列索引來定位和操作訂單飲品項目。導致訂單的順序發生變化時（EX: 刪除、插入新的訂單飲品，陣列索引會改變，導致錯誤更新）
    * 操作複雜性：
        - 陣列索引的變化會使操作變複雜，尤其是在需要頻繁增刪改訂單飲品的狀況下。需要額外的邏輯處理來維護正確的索引。

 B. 使用 UUID 的改進
    * 唯一ID：
        - 每個訂單飲品項嗎度有一個 UUID，確保在增刪改時準確定位到正確的項目，不受陣列順序變化的影響。
    * 操作簡便：
        - 直接通過 UUID 查找和操作訂單飲品項目，不需要擔心索引變化帶來的問題，提高操作簡便性。
 
 C. 使用 let 定義 id，而不是var。
    * 唯一性：
        - id 通常作為唯一，一但分配後就不該更改。使用 let 確保 id 在整個生命週期中保持不變。
    * 安全性：
        - 不可變對象更容易推理、測試。使用 let 防止意外修改 id，減少淺在錯誤。
 */

import Foundation

/// 訂單部分
struct OrderItem: Codable, Equatable, Hashable {
    
    let id: UUID  // 確保訂單飲品項目方便更新、刪除
    var drink: Drink
    var size: String
    var quantity: Int
    var prepTime: Int   // 以分鐘為單位（基於飲品去設置準備時間，而不是尺寸）
    var timestamp: Date // 時間戳記使用
    var totalAmount: Int
    var price: Int
    
    // 在初始化時，UUID 會自動產生。
    init(drink: Drink, size: String, quantity: Int, prepTime: Int, timestamp: Date, totalAmount: Int, price: Int) {
        self.id = UUID()
        self.drink = drink
        self.size = size
        self.quantity = quantity
        self.prepTime = prepTime
        self.timestamp = timestamp
        self.totalAmount = totalAmount
        self.price = price
    }
    
}


