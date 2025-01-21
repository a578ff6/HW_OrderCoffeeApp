//
//  SearchResult.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//

// MARK: - 搜尋結果結構設計：SearchResult
/**
 ## 搜尋結果結構設計：SearchResult

 `* What`
 
 - `SearchResult`：表示搜尋結果中的單一飲品資料結構。
 
    - 包含飲品所屬的類別 ID（categoryId）、子類別 ID（subcategoryId）、飲品 ID（drinkId）、飲品名稱（name）、副標題（subName）、以及圖片 URL（imageUrl）。

 ------

 `* Why`
 
 `1.資料定位`：
 
    - 需要 `categoryId`、`subcategoryId` 和 `drinkId` 是為了能夠從 `Firestore` 精準地查找到飲品的詳細資料。
    - 搜尋結果中的這些 ID 有助於用戶點擊結果後正確進入飲品詳細頁面，不會出現資料錯誤或找不到的問題。
 
 `2.良好的用戶體驗`：
 
    - 當用戶搜尋飲品後，必須能夠從結果中選擇，並進一步查看該飲品的詳細資訊。
    - 為此，`SearchResult` 必須包含足夠的訊息來支持這個導航流程，提供良好的資料連貫性。
 
 `3.方便擴展和維護`：
 
    - 設計 `SearchResult` 作為一個獨立結構，可以簡化搜尋結果的資料管理，並提高代碼的可讀性和可維護性。未來如需擴展其他資訊，只需在 SearchResult 中添加屬性即可。

 ------

` * How`
 
 `1.設計 SearchResult 結構`：
 
    - 這是搜尋結果的資料結構，每個搜尋結果代表一個飲品。
 
 `2.屬性解釋`：
 
    - `categoryId`、`subcategoryId`、`drinkId`：用來定位飲品的唯一位置，這樣可以在 `DrinkDetailViewController` 中正確加載飲品詳細資料。
    - `name`、`subName`：用於展示搜尋結果中的飲品名稱及副標題，讓用戶清楚識別飲品。
    - `imageUrl`：顯示飲品的圖片，增加搜尋結果的可視化效果，使搜尋體驗更加直觀。
 
 `3.資料傳遞到 DrinkDetailViewController`：
 
    - 當用戶從搜尋結果中點擊進入詳細頁面時，應傳遞 categoryId、subcategoryId 和 drinkId。
    - 這樣可以確保 DrinkDetailViewController 能夠正確加載資料並顯示給用戶。
 */


import UIKit

/// `SearchResult` 表示搜尋結果中的單一飲品資訊。
///
/// 它包含了類別 ID、子類別 ID 及飲品 ID，便於後續加載詳細資訊。
struct SearchResult: Codable, Hashable {
    var categoryId: String?            // 飲品所屬的類別 ID
    var subcategoryId: String?         // 飲品所屬的子類別 ID
    var drinkId: String?               // 飲品的唯一標識 ID
    var name: String                   // 飲品的名稱
    var subName: String                // 飲品的副標題
    var imageUrl: URL                  // 飲品圖片的 URL
}
