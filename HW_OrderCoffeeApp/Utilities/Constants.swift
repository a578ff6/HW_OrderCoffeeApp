//
//  Constants.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/15.
//


// MARK: - struct Constants 筆記
/**
 
 ### struct Constants 筆記

 
 EX：在 Main.storyboard 中，為 MenuCollectionViewController 設置ID:
    - 在 "Storyboard ID" 中輸入相對應的名稱。例如："MenuCollectionViewController"。
 
 
` * What：`
 
 - `Constants` 是一個結構 (`struct`)，負責統一管理應用程式中與 `Storyboard`、`Segue`相關的 識別符號 (`Identifiers`)。這些識別符常用於：
 
 1. 視圖控制器識別 (`Storyboard ID`)：確保在 `instantiateViewController(withIdentifier:)` 時可以直接調用，避免硬編碼字串。
 2. Segue 識別符（如果有的話）：讓程式碼中的 `performSegue(withIdentifier:)` 可以直接引用，減少拼寫錯誤。

 此外，`Constants` 也對應應用程式的 **導航架構 (Navigation Flow)**，使開發者在讀取程式碼時，可以快速理解 **各個視圖之間的關聯**。

 ---

` * Why：`
 
 - 如果散落在程式碼中，會造成 可讀性差、易拼錯、難以維護的問題。透過 `Constants` 集中管理，可以解決以下問題：

 1. 避免硬編碼 (`Magic Strings`)
 
    - 若識別符散落在程式碼中，每次修改時都要到處查找並修正，容易遺漏。
    - 透過 `Constants`，開發者 **只需修改一個地方**，整個應用程式就會同步更新。

 2. 減少拼字錯誤 (`Typos`)
 
    - 若識別符寫錯，應用程式運行時可能會 `crash` 或無法找到目標視圖控制器。
    - 使用 `Constants` 能避免手動輸入錯誤，提升開發效率與穩定性。

 3. 提升可讀性與導航結構清晰度
 
    - `Constants` 內部的分區 (`MARK:`) 清楚劃分 **首頁、訂單、使用者設定、搜尋** 等模組，讓開發者一目了然。
    - 透過 **註解說明**，可以清楚知道每個識別符在哪個視圖控制器中被使用，減少理解成本。

 4. 方便擴展 (`Scalability`)
 
    - 當應用程式增長、新增新的視圖時，只需在 `Constants` 內新增對應的識別符，而無需逐一修改各個檔案。

 ---

` * How`

 1. 使用巢狀結構 (`Nested Struct`)
 
 　- `Constants` 底下有 `struct Storyboard` 來專門管理與 **Storyboard** 相關的識別符，使結構更清晰。
 　- 如果未來有 **Segue 識別符**，可再新增 `struct Segue`，避免所有常數混在一起。

 ---
 
 2. 清楚標註 `MARK:` 分類
 
 　- 透過 `// MARK:` 區分 **首頁、登入、訂單、個人設定** 等不同模組，開發者能迅速找到對應的識別符。

 ---

 3. 避免拼字錯誤 (`Typos`)，統一命名規則
 
 　- 視圖控制器識別符 (`Storyboard ID`) 應與 `ViewController` 名稱一致，方便查找，例如：
 　　`static let drinkDetailViewController = "DrinkDetailViewController"`
 　　
 　- 統一識別符名稱格式，如：
 　　- `homePageViewController` ✅（統一 `ViewController` 結尾）
 　　- `homepage_vc` ❌（名稱不統一，難以維護）

 ---

 4. 未來擴展時，可加入 Segue、Cell 識別符
 
    - 如果未來有 `Segue Identifiers`，可以加入：
 　
     ```swift
     　struct Segue {
     　    static let toDrinkDetail = "ToDrinkDetailSegue"
     　}
     ```
 
 -

    - 若要加入 Cell 識別符，可以加入：
     　
     ```swift
     　struct TableViewCell {
     　    static let drinkCategoryCell = "DrinkCategoryCell"
     　}
    　```
*/



import UIKit


/// `Constants` 結構用來統一管理應用程式中的 **識別符號**，主要用於：
///
/// 1. Storyboard 識別符號 (`Storyboard Identifier`) - 方便在程式碼中透過 `instantiateViewController(withIdentifier:)` 來初始化視圖控制器。
/// 2. Segue 識別符號（如果有的話） - 讓開發者在程式碼中使用固定的 Segue 名稱，而不需手動輸入字串，避免拼字錯誤。
///
/// 設計目標
/// - 集中管理：所有與 Storyboard 相關的識別符號皆在此處定義，提升維護性與可讀性。
/// - 避免硬編碼：透過常數引用來減少字串錯誤，並統一識別符號的命名規則。
/// - 方便擴充：當新增視圖控制器時，只需在此處補充識別符號，避免分散管理造成遺漏。
struct Constants {
    
    /// 定義結構 `Storyboard`，用於存放與 Storyboard 相關的常數
    ///
    /// 表示在 Storyboard 中設定的視圖控制器的 Identifier，方便引用。
    struct Storyboard {
        
        // MARK: - 主頁面、登入、註冊、忘記密碼相關
        
        static let homePageViewController = "HomePageViewController"
        static let loginViewController = "LoginViewController"
        static let signUpViewController = "SignUpViewController"
        static let forgotPasswordViewController = "ForgotPasswordViewController"
        
        // MARK: - MainTabBar
        
        static let mainTabBarController = "MainTabBarController"

        // MARK: - 菜單主頁、飲品資訊相關_(Menu)
        
        static let menuViewController = "MenuViewController"
        static let drinkSubCategoryViewController = "DrinkSubCategoryViewController"
        static let drinkDetailViewController = "DrinkDetailViewController"
        
        // MARK: - 編輯個人資料、我的最愛、歷史訂單、歷史訂單項目詳細資訊_(UserProfile)
        
        static let editProfileViewController = "EditProfileViewController"
        static let favoritesViewController = "FavoritesViewController"
        static let orderHistoryViewController = "OrderHistoryViewController"
        static let orderHistoryDetailViewController = "OrderHistoryDetailViewController"

        // MARK: - 編輯訂單、訂單使用者資訊、選取店家、訂單確認_(Order)
        
        static let editOrderItemViewController = "EditOrderItemViewController"
        static let orderCustomerDetailsViewController = "OrderCustomerDetailsViewController"
        static let storeSelectionViewController = "StoreSelectionViewController"
        static let orderConfirmationViewController = "OrderConfirmationViewController"
    }
    
}
