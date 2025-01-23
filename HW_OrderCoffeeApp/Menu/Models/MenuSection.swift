//
//  MenuSection.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/21.
//


// MARK: - MenuSection 筆記
/**
 
 ## MenuSection 筆記


 `* What`
 
 - `MenuSection` 是用於定義菜單頁面（MenuViewController）中各個區域類型的列舉（`enum`）。每個區域類型代表菜單頁面中特定的功能模組，例如顯示網站橫幅或飲品分類。

 - 功能
 
 - 列舉成員：
 
   - `.websiteBanner`：對應菜單頁面的「網站橫幅區」。
   - `.drinkCategories`：對應菜單頁面的「飲品分類區」。
 
 - 屬性：
 
   - `title`：為每個區域提供對應的標題，用於顯示於畫面中。

 ----------

 `* Why`

 - 問題
 
    - 在菜單頁面中，有多個區域需要區分（如網站橫幅與飲品分類）。如果直接以數字（`Int`）或字串來區分區域，不僅易混淆且缺乏語意性，未來擴展也不直觀。

 - 解決方式
 
 1. 結構化的區域管理：
 
    - 使用 `MenuSection` 將區域類型結構化，能直觀地描述區域的用途，避免硬編碼的數字或字串帶來的模糊性。
    
 2. 易於擴展與維護：
 
    - 若未來需新增區域類型，只需在列舉中新增成員即可，其他程式碼可以自動適配（例如透過 `CaseIterable` 遍歷）。
    - 利用 `title` 等屬性統一管理標題邏輯，減少重複程式碼。

 3. 提升可讀性：
 
    - 將區域類型語意化（如 `.websiteBanner`），便於程式設計師理解程式碼的意圖。

 ----------

 `* How`

 1. 定義 `MenuSection`
 
    - 使用列舉定義各區域類型，並提供對應屬性。

     ```swift
     enum MenuSection: Int, CaseIterable {
         case websiteBanner // 顯示網站橫幅區
         case drinkCategories // 顯示飲品分類區
         
         /// 提供對應區域的標題，用於顯示於每個區域的標頭
         var title: String {
             switch self {
             case .websiteBanner:
                 return "最新消息"
             case .drinkCategories:
                 return "飲品選單"
             }
         }
     }
     ```

 -----

 2. 在 Collection View 中使用

 (1) 設定 Section 數量
 
    - 根據 `MenuSection` 的成員數量設定 Section：

     ```swift
     func numberOfSections(in collectionView: UICollectionView) -> Int {
         return MenuSection.allCases.count
     }
     ```

 (2) 配置 Cell
 
    - 根據 `MenuSection` 的類型配置不同區域的 Cell：

     ```swift
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let section = MenuSection(rawValue: indexPath.section) else { fatalError("無效的區域類型") }
         
         switch section {
         case .websiteBanner:
             // 配置橫幅 Cell
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuWebsiteBannerImageCell", for: indexPath)
             return cell
         case .drinkCategories:
             // 配置分類 Cell
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath)
             return cell
         }
     }
     ```

 (3) 配置 Header 標題
 
    - 使用 `MenuSection.title` 設定每個區域的標頭文字：

     ```swift
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         guard kind == UICollectionView.elementKindSectionHeader,
               let section = MenuSection(rawValue: indexPath.section),
               let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? CustomHeaderView else {
             fatalError("無效的區域或 Header 類型")
         }
         
         headerView.configure(with: section.title)
         return headerView
     }
     ```

 -----

 3. 未來擴展的範例
 
    - 如果需要新增區域（例如新增「推薦飲品」），只需添加一個新的列舉成員：

     ```swift
     enum MenuSection: Int, CaseIterable {
         case websiteBanner
         case drinkCategories
         case recommendedDrinks // 新增「推薦飲品」區域
         
         var title: String {
             switch self {
             case .websiteBanner:
                 return "最新消息"
             case .drinkCategories:
                 return "飲品選單"
             case .recommendedDrinks:
                 return "推薦飲品"
             }
         }
     }
     ```

 ----------

 `* 總結`

 - What：
 
    - `MenuSection` 是用於定義菜單頁面不同區域的類型列舉，並提供區域標題等屬性。
 
 - Why：
 
   - 結構化區域管理，減少硬編碼與錯誤。
   - 提升程式碼可讀性與易擴展性。
   - 簡化標題等相關邏輯。
 
 - How：
 
   - 使用列舉定義區域，並在 Collection View 的資料來源與標題配置中直接使用。
   - 透過擴展屬性（如 `title`）統一管理區域相關的資訊，減少重複程式碼並提升維護性。
 */



// MARK: - (v)

import Foundation


/// 定義菜單頁面中各區域的類型，對應不同的功能模組。
///
/// - websiteBanner: 顯示網站橫幅區，通常用於展示最新消息或促銷活動。
/// - drinkCategories: 顯示飲品分類區，列出可供選擇的飲品類別。
enum MenuSection: Int, CaseIterable {
    
    case websiteBanner
    case drinkCategories
    
    /// 提供對應區域的標題，用於顯示於每個區域的標頭。
    var title: String {
        switch self {
        case .websiteBanner:
            return "Latest News"
        case .drinkCategories:
            return "Drink Menu"
        }
    }
}
