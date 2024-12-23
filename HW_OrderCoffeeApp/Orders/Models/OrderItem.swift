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

 --------------------------------------------------------------------------------------------------------
 
 B. 使用 UUID 的改進
    * 唯一ID：
        - 每個訂單飲品項嗎度有一個 UUID，確保在增刪改時準確定位到正確的項目，不受陣列順序變化的影響。
    * 操作簡便：
        - 直接通過 UUID 查找和操作訂單飲品項目，不需要擔心索引變化帶來的問題，提高操作簡便性。
 
 --------------------------------------------------------------------------------------------------------

 C. 使用 let 定義 id，而不是var。
    * 唯一性：
        - id 通常作為唯一，一但分配後就不該更改。使用 let 確保 id 在整個生命週期中保持不變。
    * 安全性：
        - 不可變對象更容易推理、測試。使用 let 防止意外修改 id，減少淺在錯誤。
 
 --------------------------------------------------------------------------------------------------------

 D. 加入 categoryId 和 subcategoryId
 
    * Firestore 路徑的依賴性：
        - 由於 Drink 資料是嵌套在 Categories > Subcategories > Drinks 這樣的層級結構中，要正確從 Firestore 檢索到某個 Drink，必須依賴 categoryId 和 subcategoryId。
        - 因此，將這兩個欄位保存在 OrderItem 中是非常重要的，這樣可以正確定位到飲品在 Firestore 的存放路徑。
        -
 
    * 保留 drink 物件的理由：
        - drink 物件保留了飲品的詳細資料，如名稱、描述、價格等，這些資料在顯示訂單時直接可用，避免每次都查詢 Firestore。
        - drink 的 id 也可用來進行查詢或識別，但需要搭配 categoryId 和 subcategoryId 才能正確取得完整路徑。
 
    * 方便訂單管理和資料查詢：
        - 透過保留 categoryId 和 subcategoryId，訂單管理時可以更方便地對訂單進行分類和統計，例如根據子類別進行篩選。
 
 --------------------------------------------------------------------------------------------------------

 ## 筆記：
 
    - OrderItem 用於記錄單個飲品的資訊，如飲品種類、尺寸、數量、準備時間、價格等。
    - totalAmount 是單項飲品的總價（即 price * quantity），方便在訂單中計算總額。
    - timestamp 用於追蹤這個飲品項目加入訂單的時間，不過考慮到這個屬性可能與整體訂單時間戳記重複，目前先移除掉。
 
 */


import Foundation

/// 訂單`項目`結構，描述訂單中的單個飲品項目
struct OrderItem: Codable, Equatable, Hashable {
    let id: UUID                          // 唯一標識符，用於區分每個訂單項目（方便更新、刪除等操作）
    var drink: Drink                      // 飲品詳細資料
    var size: String                      // 飲品的尺寸（例如小杯、中杯、大杯）
    var quantity: Int                     // 飲品的數量
    var prepTime: Int                     // 以分鐘為單位（基於飲品去設置準備時間，而不是尺寸）
    var totalAmount: Int                  // 單項飲品的總金額（單價乘以數量）               
    var price: Int                        // 單項飲品的價格
    var categoryId: String?
    var subcategoryId: String?

    // 在初始化時，UUID 會自動產生。
    init(drink: Drink, size: String, quantity: Int, prepTime: Int, totalAmount: Int, price: Int, categoryId: String?, subcategoryId: String?) {
        self.id = UUID()
        self.drink = drink
        self.size = size
        self.quantity = quantity
        self.prepTime = prepTime
        self.totalAmount = totalAmount
        self.price = price
        self.categoryId = categoryId   // 設置值
        self.subcategoryId = subcategoryId // 設置值
    }
}
