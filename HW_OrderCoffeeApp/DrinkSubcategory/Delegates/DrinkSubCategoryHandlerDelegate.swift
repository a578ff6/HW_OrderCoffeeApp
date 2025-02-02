//
//  DrinkSubCategoryHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/25.
//


// MARK: - DrinkSubCategoryHandlerDelegate 筆記
/**
 
 ## DrinkSubCategoryHandlerDelegate 筆記

 `* What`
 
 - `DrinkSubCategoryHandlerDelegate` 是一個協議，負責協調 `DrinkSubCategoryHandler` 與其擁有者（例如 `DrinkSubCategoryViewController`）。
 - 提供了必要的屬性和方法，支持 `UICollectionView` 的數據來源及行為邏輯。
 
 - 主要功能：
 
   1. 提供子類別清單（`subcategoryViewModels`），作為 section 和 item 的數據來源。
   2. 獲取當前的佈局類型（`currentLayoutType`），用於動態設置 Cell 的樣式。
   3. 提供父類別 ID（`categoryId`），確保子類別與父類別的數據關聯。
   4. 定義用戶選擇飲品的行為（`didSelectDrink`），如導航至飲品詳細頁面。

 --------

 `* Why`

 1. 解耦結構
 
  - 問題：如果 `DrinkSubCategoryHandler` 直接與控制器交互，會造成高耦合，不利於測試和維護。
  - 解決方案：使用協議抽象 `DrinkSubCategoryHandler` 與控制器的交互，使邏輯模組化，增強靈活性。

 2. 高內聚低耦合
 
  - 內聚：`DrinkSubCategoryHandler` 專注於管理 `UICollectionView` 的數據邏輯與交互行為。
  - 低耦合：通過協議讓 `DrinkSubCategoryHandler` 僅依賴協議而非具體的控制器。

 3. 可讀性與可維護性
 
  - 協議清晰地定義了 `DrinkSubCategoryHandler` 與其擁有者的交互規範，責任分工明確，代碼更易於理解和維護。

 4. 支持業務需求
 
  - 提供數據來源（如 `subcategoryViewModels` 和 `categoryId`）。
  - 支持動態佈局切換（如 `currentLayoutType`）。
  - 處理點擊事件，讓控制器執行具體行為（如跳轉至詳細頁）。
 
 

 --------

 `* How `

 1. 屬性與方法設計：
 
    - `subcategoryViewModels`：子類別的數據清單，用於 `UICollectionView` 的 section 和 item。
    - `currentLayoutType`：定義當前的佈局類型，用於動態調整 Cell 的外觀（如網格與列表模式）。
    - `categoryId`：提供父類別 ID，確保子類別與父類別關聯性。
    - `didSelectDrink`：用於處理用戶點擊飲品的事件，例如導航到詳細頁。
 
 ---

 2. 使用方式：
 
    - 協議實現： 在 `DrinkSubCategoryViewController` 中實現該協議，提供具體邏輯。
    - Handler 設置：在 `DrinkSubCategoryViewController` 初始化時，將 `DrinkSubCategoryHandler` 的 `drinkSubCategoryHandlerDelegate` 設置為控制器本身。

    - 範例：
 
    ```swift
    extension DrinkSubCategoryViewController: DrinkSubCategoryHandlerDelegate {
 
        var subcategoryViewModels: [DrinkSubCategoryViewModel] {
            return drinkSubcategories
        }
 
        var currentLayoutType: DrinkSubCategoryLayoutType {
            return layoutType
        }

        var categoryId: String? {
            return parentCategoryId
        }

        func didSelectDrink(categoryId: String, subcategoryViewModel: DrinkSubCategoryViewModel, drinkViewModel: DrinkViewModel) {
            // 導航至飲品詳細頁面
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let drinkDetailVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController else {
                print("Failed to instantiate DrinkDetailViewController")
                return
            }
            drinkDetailVC.categoryId = categoryId
            drinkDetailVC.subcategoryId = subcategoryViewModel.subcategoryId
            drinkDetailVC.drinkId = drinkViewModel.id
            navigationController?.pushViewController(drinkDetailVC, animated: true)
        }
    }
    ```

 ---

 3. 交互流程：
 
    - 當用戶點擊某個飲品：
 
      1. `DrinkSubCategoryHandler` 通過 `didSelectDrink` 回調通知擁有者。
      2. 擁有者執行具體邏輯（如導航至飲品詳細頁面）。

 ---
 
 4. 協議內容：
 
    ```swift
     protocol DrinkSubCategoryHandlerDelegate: AnyObject {
         var subcategoryViewModels: [DrinkSubCategoryViewModel] { get }
         var currentLayoutType: DrinkSubCategoryLayoutType { get }
         var categoryId: String? { get }
         func didSelectDrink(categoryId: String, subcategoryViewModel: DrinkSubCategoryViewModel, drinkViewModel: DrinkViewModel)
     }
    ```

 --------

 `* 結論`

 `DrinkSubCategoryHandlerDelegate` 的設計充分體現了面向協議的設計原則：
 
 - 提升了代碼的解耦性和靈活性。
 - 簡化了 `DrinkSubCategoryHandler` 的邏輯。
 - 使 `DrinkSubCategoryViewController` 成為業務邏輯的唯一責任者，清晰了職責分工。

 */



// MARK: - didSelectDrink 方法與協議中 categoryId 設置的原因與必要性
/**
 
 ## didSelectDrink 方法與協議中 categoryId 設置的原因與必要性
 
    - 原本設置`didSelectDrink`時只有`subcategoryViewModel`、`drinkViewModel`兩個參數，然後`categoryId`的部分直接使用`DrinkSubCategoryViewController`的`parentCategoryId`，畢竟`DrinkDetailViewController`需要三個層級的id。
    - 後來覺得didSelectDrink只設置兩個參數在可讀性上很差，畢竟實際上是傳遞三個參數，而`parentCategoryId`是直接使用`DrinkSubCategoryViewController`。
    
 
 - 解決方式：
  
    - `func didSelectDrink(categoryId: String, subcategoryViewModel: DrinkSubCategoryViewModel, drinkViewModel: DrinkViewModel)` 會設置 `categoryId: String` 參數。
    - 以及協議中定義 `var categoryId: String? { get }`
 
 ---------

 `* What`

 1. `categoryId: String` 參數
 
    - 此參數是在 `didSelectDrink` 方法中傳遞父類別的唯一識別碼，代表當前子類別的父層分類。
    - 該值用於處理與當前飲品相關的父類別邏輯，例如：
      - 將 `categoryId` 傳遞給下一個畫面（ `DrinkDetailViewController`）。
      - 幫助數據層進行數據查詢或篩選。

 2. `var categoryId: String? { get }` 屬性
 
    - 協議中定義的只讀屬性，提供 `DrinkSubCategoryHandler` 獲取父類別 ID 的途徑。
    - 在具體實現中（ `DrinkSubCategoryViewController`），此屬性通常綁定到控制器中的 `parentCategoryId`，用於標識當前的父分類。

 ---------

 `* Why`

 1. `categoryId: String` 的必要性：
 
 - 資料關聯性：
 
    - 每個子類別和飲品都與其父類別相關聯，父類別 ID 是進行數據篩選與導航的必要信息。
    - 在 `DrinkDetailViewController` 中，需要知道父類別 ID 來正確加載和展示數據。
 
 - 跨層級數據傳遞：
 
    - 當需要導航到更深層次的頁面（如飲品詳細頁）時，父類別 ID 是不可或缺的數據，應直接通過參數傳遞以確保完整性。
 
 - 減少隱式依賴：
 
    - 雖然可以直接從其他上下文（如全局變量或 handler）中取得 `categoryId`，但這樣會增加耦合。使用參數傳遞可避免隱式依賴，提升可維護性與測試性。

 ---
 
 2. `var categoryId: String?` 的必要性：
 
 - 協議標準化：
 
    - 定義在協議中，確保所有實現該協議的類別都必須提供該屬性，統一數據獲取方式。
 
 - Handler 與控制器解耦：
 
    - `DrinkSubCategoryHandler` 並不知道具體的父類別 ID，因此需要通過協議向控制器請求此數據。
 
 - 靈活的數據來源：
 
    - 協議的屬性可以由不同的實現類返回具體值。
    - 從控制器內部的屬性直接返回（如 `parentCategoryId`）。
    - 從網路請求或本地數據庫獲取後動態設置。

 --------

 `* How`

 1. 協議定義：
 
    ```swift
    protocol DrinkSubCategoryHandlerDelegate: AnyObject {
        /// 獲取當前的父類別 ID
        var categoryId: String? { get }
        
        /// 用戶選擇飲品時的回調
        func didSelectDrink(categoryId: String, subcategoryViewModel: DrinkSubCategoryViewModel, drinkViewModel: DrinkViewModel)
    }
    ```

 ---

 2. 協議實現（例子：`DrinkSubCategoryViewController`）：
 
    ```swift
    extension DrinkSubCategoryViewController: DrinkSubCategoryHandlerDelegate {
        var categoryId: String? {
            return parentCategoryId // 從控制器內部屬性返回
        }
        
        func didSelectDrink(categoryId: String, subcategoryViewModel: DrinkSubCategoryViewModel, drinkViewModel: DrinkViewModel) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let drinkDetailVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController else {
                print("Failed to instantiate DrinkDetailViewController")
                return
            }
            // 傳遞必要數據
            drinkDetailVC.categoryId = categoryId
            drinkDetailVC.subcategoryId = subcategoryViewModel.subcategoryId
            drinkDetailVC.drinkId = drinkViewModel.id
            navigationController?.pushViewController(drinkDetailVC, animated: true)
        }
    }
    ```

 ---

 3. 在 Handler 中使用：
 
    ```swift
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         // 通過代理獲取 categoryId 和 subcategoryViewModels
         guard let categoryId = drinkSubCategoryHandlerDelegate?.categoryId,
               let subcategoryViewModel = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section],
               let drinkViewModel = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section].drinks[indexPath.item] else {
             return
         }
         
         guard let cell = collectionView.cellForItem(at: indexPath) else { return }
         cell.addScaleAnimation(duration: 0.15, scale: 0.85) {
             self.drinkSubCategoryHandlerDelegate?.didSelectDrink(
                 categoryId: categoryId,
                 subcategoryViewModel: subcategoryViewModel,
                 drinkViewModel: drinkViewModel
             )
         }
     }
    ```

 4. 交互流程：
 
    - `DrinkSubCategoryHandler` 請求協議實現類別的 `categoryId`。
    - 當用戶選擇某飲品時，`Handler` 通過 `didSelectDrink` 回調通知協議實現類別，並將 `categoryId` 與其他數據一併傳遞。

 --------

 `* 結論`

 - 在 `didSelectDrink` 中設置 `categoryId` 參數，並在協議中定義 `categoryId` 屬性，是為了解耦和數據傳遞的必要手段：
 
   1. 確保父類別 ID 的來源明確且統一。
   2. 通過參數明確傳遞數據，避免依賴隱式上下文。
   3. 協議統一了數據請求與回調邏輯，實現靈活的數據傳遞與邏輯分離。
 
 - 這樣的設計符合單一職責原則（SRP）與依賴倒置原則（DIP），是一種合適且清晰的實現方式。
 */




// MARK: - (v)


import UIKit


/// 定義 `DrinkSubCategoryHandlerDelegate`，用於協調 `DrinkSubCategoryHandler` 與其擁有者（通常是 `DrinkSubCategoryViewController`）。
///
/// ### 設計目標
/// 1. 解耦：將 `DrinkSubCategoryHandler` 與具體的視圖控制器實現解耦，使邏輯更加模組化與易於測試。
/// 2. 數據提供：提供 `DrinkSubCategoryHandler` 執行 UICollectionView 的數據來源與行為邏輯所需的屬性和方法。
/// 3. 行為協調：將使用者的交互事件，例如選擇飲品，傳遞給控制器進一步處理。
///
/// ### 職責
/// - 提供子類別數據（`subcategoryViewModels`）：作為 `UICollectionView` section 和 item 的數據來源。
/// - 提供當前佈局類型：幫助 `DrinkSubCategoryHandler` 動態選擇適合的 Cell 樣式。
/// - 提供當前父類別 ID：在需要時進行數據傳遞或篩選操作。
/// - 回調用戶選擇行為：處理用戶點擊飲品項目時的邏輯，如導航至詳細頁面。
///
/// ### 使用場景
/// - `DrinkSubCategoryViewController` 作為 `DrinkSubCategoryHandler` 的擁有者，實現此協議，並提供必要的數據與行為處理邏輯。
/// - 當用戶與 `UICollectionView` 交互時，`DrinkSubCategoryHandler` 可透過此協議取得數據與執行相關邏輯。
protocol DrinkSubCategoryHandlerDelegate: AnyObject {
    
    
    /// 取得當前的子類別清單
    ///
    /// ### 功能
    /// 提供 UICollectionView 的 section 和 item 資料來源。
    ///
    /// ### 屬性說明
    /// - 每個子類別由 `DrinkSubCategoryViewModel` 表示，包含子類別標題與對應的飲品清單。
    ///
    /// ### 使用情境
    /// - 用於 `UICollectionViewDataSource` 中設定 section 數量與 item 數量。
    /// - 配置每個 section 的標題與飲品項目。
    ///
    /// ### 回傳
    /// - `[DrinkSubCategoryViewModel]`：子類別的展示模型清單。
    var subcategoryViewModels: [DrinkSubCategoryViewModel] { get }
    
    
    /// 獲取當前的佈局類型（用於配置 Cell 的樣式）。
    ///
    /// ### 功能
    /// 提供當前的佈局類型，幫助 `DrinkSubCategoryHandler` 動態設置 UICollectionViewCell 的樣式。
    ///
    /// ### 使用情境
    /// - 在網格佈局與列表佈局之間切換時，根據佈局類型配置對應的 Cell 樣式。
    ///
    /// ### 回傳
    /// - `DrinkSubCategoryLayoutType`：表示當前佈局類型的枚舉值。
    var currentLayoutType: DrinkSubCategoryLayoutType { get }
    
    
    /// 獲取當前的父類別 ID。
    ///
    /// ### 功能
    /// 提供當前子類別的父類別 ID，通常在導航或數據篩選時需要使用。
    ///
    /// ### 使用情境
    /// - 當用戶點擊某個飲品時，將父類別 ID 傳遞至下一個場景（如詳細頁面）。
    ///
    /// ### 回傳
    /// - `String?`：父類別的唯一識別碼，若無法獲取則返回 `nil`。
    var categoryId: String? { get }
    
    
    /// 當用戶選擇某個飲品時觸發的回調。
    ///
    /// ### 功能
    /// 當用戶點擊某個飲品時，觸發此方法以處理相關邏輯，例如導航至飲品詳細頁面。
    ///
    /// ### 使用情境
    /// - 配合 `UICollectionViewDelegate` 的 didSelectItemAt 方法，處理點擊事件。
    ///
    /// ### 參數
    /// - `categoryId`：當前父類別的唯一識別碼。
    /// - `subcategoryViewModel`：被選中飲品所屬的子類別展示模型。
    /// - `drinkViewModel`：被選中飲品的展示模型。
    func didSelectDrink(categoryId: String, subcategoryViewModel: DrinkSubCategoryViewModel, drinkViewModel: DrinkViewModel)
    
}
