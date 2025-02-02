//
//  DrinkSubCategoryNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/25.
//



// MARK: - DrinkSubCategoryNavigationBarManager 筆記
/**
 
 ### DrinkSubCategoryNavigationBarManager 筆記

 `* What`
 
 - `DrinkSubCategoryNavigationBarManager` 是一個專門管理 `DrinkSubCategoryViewController` 導航欄的類別，負責：
 
    1. 設定導航欄的標題（支援大標題模式）。
    2. 配置切換佈局的按鈕，並根據當前狀態更新按鈕圖示。
    3. 透過代理模式，將按鈕點擊事件通知控制器，實現功能分離。

 --------

 `* Why`
 
 1. 分離關注點：
 
    - 控制器應專注於業務邏輯，導航欄的配置邏輯應抽離到專門的管理類別，提升可讀性與維護性。
    
 2. 降低耦合性：
 
    - 透過代理模式，`DrinkSubCategoryNavigationBarManager` 與控制器之間的聯繫僅限於協議，減少彼此的依賴性，方便未來擴展或測試。
    
 3. 增強可測試性：
 
    - 使用代理模式模擬按鈕點擊行為，有助於單元測試按鈕邏輯是否正確觸發。

 4. 靈活擴展：
 
    - 未來如果需要新增其他導航欄按鈕，例如「篩選」或「排序」，可以輕鬆擴充此類別而不影響控制器。

 --------

` * How`
 
 1. 設置標題：
 
    - 使用 `configureNavigationBarTitle` 設定標題文字和是否啟用大標題模式。
 
    - 例如：
 
      ```swift
      navigationManager.configureNavigationBarTitle(title: "Drink Subcategory", prefersLargeTitles: true)
      ```

 ---
 
 2. 配置按鈕：
 
    - 使用 `configureSwitchLayoutButton` 方法在右側添加切換佈局按鈕，按鈕圖示會根據當前佈局（網格或列表）進行設定。
 
    - 例如：
 
      ```swift
      navigationManager.configureSwitchLayoutButton(isGridLayout: layoutType == .grid)
      ```

 ---

 3. 更新按鈕圖示：
 
    - 當切換佈局時，調用 `updateSwitchLayoutButton` 更新按鈕圖示，確保用戶操作直觀。
 
    - 例如：
 
      ```swift
      navigationManager.updateSwitchLayoutButton(isGridLayout: false)
      ```

 ---

 4. 處理按鈕點擊事件：
 
    - 當用戶點擊按鈕時，管理器會調用代理方法 `didTapSwitchLayoutButton`，將點擊事件通知控制器進行具體邏輯處理。
 
    - 實現範例：
 
      ```swift
     func didTapSwitchLayoutButton() {
         layoutType = (layoutType == .grid) ? .column : .grid
         drinkSubCategoryViewManager?.updateCollectionViewLayout(to: layoutType, totalSections: drinkSubcategoryViewModels.count)
         drinkSubCategoryNavigationBarManager?.updateSwitchLayoutButton(isGridLayout: layoutType == .grid)
     }
      ```

 ---

 5. 代理模式：
 
    - 在 `DrinkSubCategoryViewController` 中實現 `DrinkSubCategoryNavigationBarDelegate`，接收按鈕點擊事件並執行切換邏輯。

 */



// MARK: - (v)

import UIKit


/// `DrinkSubCategoryNavigationBarManager`
///
/// ### 功能概述
/// `DrinkSubCategoryNavigationBarManager` 負責管理導航欄的配置，專注於標題設置與按鈕行為管理，
/// 並透過代理模式將按鈕點擊事件傳遞給控制器，實現高內聚與低耦合的設計。
///
/// ### 設計目標
/// 1. 單一責任：僅專注於導航欄相關的邏輯，包括標題和按鈕的配置。
/// 2. 分離關注點：通過代理模式將按鈕點擊事件與控制器的業務邏輯分離。
/// 3. 增強可維護性：簡化控制器的導航欄邏輯，使其更專注於業務處理。
/// 4. 靈活擴展：未來可輕鬆新增或修改導航欄按鈕的行為，而不影響控制器。
///
/// ### 職責
/// - 設置導航欄標題：包括大標題模式的支持。
/// - 配置與更新切換佈局按鈕：基於佈局狀態更新按鈕圖示。
/// - 按鈕事件處理：通過代理通知控制器處理按鈕點擊行為。
///
/// ### 使用場景
/// - `DrinkSubCategoryViewController` 利用此類配置導航欄，
///   包括設置標題與切換佈局按鈕，按鈕的點擊事件由控制器處理。
class DrinkSubCategoryNavigationBarManager {
    
    // MARK: - Properties
    
    /// 切換佈局按鈕：用於在導航欄右側顯示切換佈局圖示
    private var switchLayoutButton: UIBarButtonItem?
    
    /// 導航欄項目：用於設置導航欄的內容（例如標題與按鈕）
    private weak var navigationItem: UINavigationItem?
    
    /// 代理：負責處理按鈕點擊事件
    weak var drinkSubCategoryNavigationBarDelegate: DrinkSubCategoryNavigationBarDelegate?
    
    // MARK: - Initialization
    
    /// 初始化方法
    ///
    /// ### 功能
    /// 初始化導航欄管理器並關聯導航欄項目。
    ///
    /// - Parameter navigationItem: `UINavigationItem`，用於配置導航欄內容。
    init(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
    }
    
    // MARK: - Setup Methods
    
    /// 配置導航欄標題
    ///
    /// ### 功能
    /// 設置導航欄的標題文字，並支持大標題模式。
    ///
    /// - Parameters:
    ///   - title: 標題文字
    ///   - prefersLargeTitles: 是否顯示大標題，預設為 `true`
    func configureNavigationBarTitle(title: String, prefersLargeTitles: Bool = true) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
    }
    
    /// 配置切換佈局按鈕
    ///
    /// ### 功能
    /// 在導航欄右側添加切換佈局按鈕，根據當前佈局狀態設置按鈕圖示。
    ///
    /// - Parameters:
    ///   - isGridLayout: 是否為網格佈局，影響按鈕圖示。
    func configureSwitchLayoutButton(isGridLayout: Bool) {
        let buttonImage = UIImage(systemName: isGridLayout ? "rectangle.grid.1x2" : "square.grid.2x2")
        switchLayoutButton = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(switchLayoutButtonTapped))
        navigationItem?.rightBarButtonItem = switchLayoutButton
    }
    
    /// 更新切換佈局按鈕的圖示
    ///
    /// ### 功能
    /// 根據當前佈局狀態更新按鈕圖示，確保用戶操作直觀。
    ///
    /// - Parameter isGridLayout: 是否為網格佈局，影響按鈕圖示。
    func updateSwitchLayoutButton(isGridLayout: Bool) {
        switchLayoutButton?.image = UIImage(systemName: isGridLayout ? "rectangle.grid.1x2" : "square.grid.2x2")
    }
    
    // MARK: - Private Methods
    
    /// 切換佈局按鈕點擊事件
    ///
    /// ### 功能
    /// 當用戶點擊切換佈局按鈕時，通知代理執行對應的邏輯處理。
    @objc private func switchLayoutButtonTapped() {
        drinkSubCategoryNavigationBarDelegate?.didTapSwitchLayoutButton()
    }
    
}
