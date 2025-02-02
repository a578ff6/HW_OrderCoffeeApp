//
//  DrinkSubCategoryNavigationBarDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/26.
//


// MARK: - DrinkSubCategoryNavigationBarDelegate 筆記
/**
 
 ## DrinkSubCategoryNavigationBarDelegate 筆記

 `* What`
 
 - `DrinkSubCategoryNavigationBarDelegate` 是一個定義代理方法的協議，專注於處理導航欄中「切換佈局按鈕」的點擊事件。

 - 功能範疇：
 
   - 將按鈕點擊事件從 `DrinkSubCategoryNavigationBarManager` 中分離。
   - 通知代理（如 `DrinkSubCategoryViewController`）執行具體的業務邏輯。

 - 協議方法：
 
   - `didTapSwitchLayoutButton()`：當用戶點擊「切換佈局按鈕」時調用，觸發對應的處理邏輯。

 -----------

 `* Why:`

 1. 分離關注點：
 
    - 將導航欄按鈕的交互邏輯與具體業務邏輯解耦，`DrinkSubCategoryNavigationBarManager` 專注於導航欄配置，按鈕的點擊處理交由代理負責。

 2. 降低耦合性：
 
    - `DrinkSubCategoryNavigationBarManager` 不直接依賴具體的控制器，只需依賴協議，提升靈活性與可測試性。

 3. 增強可測試性：
 
    - 使用協議模式，允許在測試環境中模擬按鈕點擊，驗證代理實現的業務邏輯是否正確。

 4. 易於擴展：
 
    - 未來若需要增加其他導航欄按鈕的行為（如篩選、刷新），可以通過協議方法擴展，而不影響現有的架構。

 -----------

 `* How:`

 1. 定義協議
 
    - 協議包含一個方法 `didTapSwitchLayoutButton()`，由代理在按鈕被點擊時觸發：

     ```swift
     protocol DrinkSubCategoryNavigationBarDelegate: AnyObject {
         /// 當用戶點擊切換佈局按鈕時調用
         func didTapSwitchLayoutButton()
     }
     ```

 ---

 2. 在管理器中設置代理
 
    - `DrinkSubCategoryNavigationBarManager` 中包含一個弱引用的代理屬性：

     ```swift
     class DrinkSubCategoryNavigationBarManager {
         weak var drinkSubCategoryNavigationBarDelegate: DrinkSubCategoryNavigationBarDelegate?
     }
     ```

    - 當按鈕被點擊時，調用代理方法通知代理執行具體邏輯：

     ```swift
     @objc private func switchLayoutButtonTapped() {
         drinkSubCategoryNavigationBarDelegate?.didTapSwitchLayoutButton()
     }
     ```

 ---

 3. 在控制器中實現代理
 
    - `DrinkSubCategoryViewController` 遵循協議並實現方法，處理具體的業務邏輯：

     ```swift
     extension DrinkSubCategoryViewController: DrinkSubCategoryNavigationBarDelegate {
         func didTapSwitchLayoutButton() {
             layoutType = (layoutType == .grid) ? .column : .grid
             drinkSubCategoryViewManager?.updateCollectionViewLayout(to: layoutType, totalSections: drinkSubcategoryViewModels.count)
             drinkSubCategoryNavigationBarManager?.updateSwitchLayoutButton(isGridLayout: layoutType == .grid)
         }
     }
     ```

 ---

 4. 配置代理
 
 - 在 `setupNavigationBar()` 方法中配置 `DrinkSubCategoryNavigationBarManager` 並設置代理：

 ```swift
 private func setupNavigationBar() {
     let navigationManager = DrinkSubCategoryNavigationBarManager(navigationItem: navigationItem)
     navigationManager.drinkSubCategoryNavigationBarDelegate = self
     drinkSubCategoryNavigationBarManager = navigationManager
     
     // 設定導航欄標題
     let title = parentCategoryTitle ?? "Drink Category"
     navigationManager.configureNavigationBarTitle(title: title, prefersLargeTitles: true)
     
     // 配置切換佈局按鈕
     navigationManager.configureSwitchLayoutButton(isGridLayout: layoutType == .grid)
 }
 ```

 -----------

 `* 總結`

 - 職責分工：
 
   - `DrinkSubCategoryNavigationBarManager`：負責導航欄的配置（標題與按鈕）。
   - `DrinkSubCategoryNavigationBarDelegate`：負責按鈕點擊後的業務邏輯處理。

 - 設計優點：
 
   - 高內聚：每個類和協議專注於各自的責任。
   - 低耦合：管理器與控制器通過協議通信，便於維護與測試。
   - 靈活性：未來可以輕鬆增加其他按鈕行為或替換代理對象。
 */




// MARK: - (v)

import Foundation

/// `DrinkSubCategoryNavigationBarDelegate`
///
/// ### 功能概述
/// `DrinkSubCategoryNavigationBarDelegate` 定義了與導航欄交互相關的代理協議，
/// 專注於處理切換佈局按鈕的點擊事件。
///
/// ### 設計目標
/// - 分離關注點：將導航欄按鈕的交互行為與具體的業務邏輯分離，確保 `DrinkSubCategoryNavigationBarManager` 的專注性。
/// - 降低耦合性：透過代理模式，避免 `DrinkSubCategoryNavigationBarManager` 與具體控制器的直接耦合。
/// - 增強可測試性：利用協議模式模擬按鈕點擊事件，方便進行單元測試。
///
/// ### 職責
/// - 當用戶點擊導航欄的切換佈局按鈕時，透過協議方法將事件傳遞給 `DrinkSubCategoryViewController` 或其他代理對象進行處理。
///
/// ### 使用場景
/// - `DrinkSubCategoryNavigationBarManager` 負責導航欄的配置，
///   按鈕的點擊事件通過此協議通知 `DrinkSubCategoryViewController`。
///
/// ### 功能說明
/// 1. `didTapSwitchLayoutButton`:
///    - 當切換佈局按鈕被點擊時，代理會觸發此方法，
///      控制器根據當前佈局狀態執行相應的切換邏輯。
protocol DrinkSubCategoryNavigationBarDelegate: AnyObject {
    
    /// 切換佈局按鈕點擊事件
    ///
    /// ### 功能
    /// 當導航欄上的切換佈局按鈕被點擊時，通知代理處理切換邏輯。
    ///
    /// ### 使用情境
    /// - 控制器切換佈局類型，例如從網格視圖切換到列表視圖或反之。
    ///
    /// ### 實現建議
    /// - 在代理方法內，更新當前的佈局類型，並刷新 `UICollectionView` 的佈局。
    func didTapSwitchLayoutButton()
    
}
