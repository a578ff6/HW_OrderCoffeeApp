//
//  OrderHistorySortMenuHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - OrderHistorySortMenuHandler 筆記
/**
 
 ## OrderHistorySortMenuHandler 筆記

 `* What`

 1. 功能描述：
 
    - `OrderHistorySortMenuHandler` 是一個負責管理和處理排序選單的類別。
    - 它生成包含多個排序選項的下拉選單（`UIMenu`），並透過代理機制（`OrderHistorySortMenuDelegate`）回傳使用者的選擇。

 2. 核心職責：
 
    - 生成排序選單：
 
      - 提供包含標題和圖示的排序選項。
      - 支援按日期、金額和取件方式進行排序。
 
    - 代理回調：
 
      - 當使用者選擇排序方式時，回傳選擇的排序條件給委託對象。

 3. 應用場景：
 
    - 適用於歷史訂單或其他需要多樣化排序的功能模組。
    - 用於解耦排序選單的生成邏輯與具體的業務邏輯。

 --------

 `* Why`

 1. 模組化設計：
 
    - 將排序選單的生成與排序邏輯分離，降低視圖控制器的代碼複雜度。
    - 排序選單的邏輯集中管理，提升代碼的清晰度和可讀性。

 2. 提升擴展性：
 
    - 如果需要新增排序方式，只需修改 `OrderHistorySortMenuHandler`，不影響其他模組。
    - 新增排序選項時不需要改動視圖控制器或其他業務邏輯。

 3. 減少耦合性：
 
    - 排序選單生成的邏輯與具體的業務邏輯解耦，方便獨立測試和模組替換。

 4. 提升可重用性：
 
    - 該模組可應用於不同的排序場景，例如其他類型的資料列表。

 --------

 `* How`

 1. 初始化 `OrderHistorySortMenuHandler` 並設置代理：
 
    - 通過初始化方法傳入 `OrderHistorySortMenuDelegate`，設置代理來接收排序選擇。
 
    ```swift
    let sortMenuHandler = OrderHistorySortMenuHandler(orderHistorySortMenuDelegate: self)
    ```

 ---

 2. 生成排序選單：
 
    - 使用 `createSortMenu()` 方法生成排序選單，返回一個 `UIMenu`，並可直接添加到導航欄按鈕。
 
    ```swift
    let sortMenu = sortMenuHandler.createSortMenu()
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "排序", menu: sortMenu)
    ```

 ---

 3. 實現代理回調：
 
    - 實現 `OrderHistorySortMenuDelegate`，處理使用者選擇的排序選項。
 
    ```swift
    extension OrderHistoryViewController: OrderHistorySortMenuDelegate {
        func didSelectSortOption(_ sortOption: OrderHistorySortOption) {
            currentSortOption = sortOption
            fetchOrderHistory(sortOption: currentSortOption)
        }
    }
    ```
 
 ---

 4. 選單生成的邏輯：
 
    - 使用 `UIMenu` 和 `UIAction`，並透過 `OrderHistorySortOption` 提供標題、圖示和對應的排序邏輯。
 
    ```swift
    func createSortMenu() -> UIMenu {
        let sortOptions: [(title: String, image: String, option: OrderHistorySortOption)] = [
            ("依時間由新到舊", "calendar.badge.clock", .byDateDescending),
            ("依時間由舊到新", "calendar", .byDateAscending),
            ("依金額從高到低", "arrow.down.circle", .byAmountDescending),
            ("依金額從低到高", "arrow.up.circle", .byAmountAscending),
            ("依取件方式", "shippingbox", .byPickupMethod)
        ]
        
        let actions = sortOptions.map { option in
            UIAction(title: option.title, image: UIImage(systemName: option.image)) { _ in
                self.orderHistorySortMenuDelegate?.didSelectSortOption(option.option)
            }
        }
        return UIMenu(title: "選擇排序方式", children: actions)
    }
    ```

 --------

 `* 總結`

 - `OrderHistorySortMenuHandler` 提供了一個模組化的解決方案來處理排序選單的生成與回調，符合單一責任原則和開放封閉原則。
 - 透過清晰的分層設計，該模組易於維護、擴展和重用，是排序功能邏輯的最佳實踐之一。
 */


// MARK: - 訂單排序選項及 UI 設計重點筆記
/**
 
 ## 訂單排序選項及 UI 設計重點筆記

 
 `* 如何實作「訂單排序選項」`

 1. 訂單排序選項的實作概述
 
    - 在 `OrderHistoryViewController` 中，透過`OrderHistorySortMenuDelegate` 與 `OrderHistorySortMenuHandler` 配合，以提供使用者不同排序的功能。
    - 排序選項包括依據時間、金額及取件方式等進行排序，且使用下拉菜單來進行選擇。

 ---------
 
 `* 具體實作步驟`
 
 1. 設置導航欄上的排序按鈕：
 
    - `OrderHistorySortMenuHandler`管理設置導航欄的排序按鈕 (sortButton)。
 
 2. 使用 OrderHistorySortMenuHandler 創建排序選項菜單：
 
    - 透過 `OrderHistorySortMenuHandler` 創建排序選項菜單 (`createSortMenu()`)，並將 `OrderHistorySortMenuDelegate` 傳入，確保當使用者選擇選項後，能通知到 `OrderHistoryViewController`。
    - 排序選單中的每個 `UIAction` 在被選擇後，透過代理呼叫 `didSelectSortOption(_:)` 方法，通知 `ViewController` 執行相應的排序。

 3. 獲取排序後的訂單資料 (`fetchOrderHistory(sortOption:)`)：
 
    - 根據選定的排序方式，通過 `OrderHistoryManager` 從 Firebase 異步獲取歷史訂單，並進行相應的排序。
    - 使用 `Task` 非同步處理，確保使用者在資料獲取期間不會卡住 UI。
 */



// MARK: - (v)


import UIKit


/// `OrderHistorySortMenuHandler`
///
/// - 用途:
///   - 負責管理與處理歷史訂單的排序選單邏輯。
///   - 提供一個易於擴展的介面來創建排序選單，並透過 `OrderHistorySortMenuDelegate` 來回傳使用者的排序選擇。
///
/// ### 功能概述:
/// 1. 排序選單的生成
///    - 使用內建的 `UIMenu` 來呈現排序選項，並附帶對應的標題和圖示。
/// 2. 回調機制
///    - 當使用者選擇排序方式時，透過代理回傳選項，將業務邏輯與選單視圖解耦。
///
/// ### 設計目標:
/// - 模組化與擴展性
///   - 通過封裝排序選單的邏輯，使排序相關的處理簡單且易於擴展。
/// - 解耦
///   - 排序選單的生成與處理分離，確保視圖邏輯不直接依賴具體的排序邏輯實現。
class OrderHistorySortMenuHandler {
    
    // MARK: - Properties
    
    /// 排序選單的代理，用於提供排序選項的回調
    weak var orderHistorySortMenuDelegate: OrderHistorySortMenuDelegate?
    
    // MARK: - Initialization
    
    /// 初始化方法，接受一個 `OrderHistorySortMenuDelegate` 代理
    ///
    /// - Parameter delegate: 傳入的代理，用於回傳排序選擇
    init(orderHistorySortMenuDelegate: OrderHistorySortMenuDelegate?) {
        self.orderHistorySortMenuDelegate = orderHistorySortMenuDelegate
    }
    
    // MARK: - Methods
    
    /// 創建排序選單
    ///
    /// - 功能:
    ///   - 生成一個包含所有排序選項的下拉選單，提供給使用者選擇。
    ///   - 每個選項附帶標題與圖示，並在選擇後回傳對應的排序方式。
    ///
    /// - Returns: 包含不同排序選項的 `UIMenu`，提供給使用者選擇
    func createSortMenu() -> UIMenu {
        
        let sortOptions: [(title: String, image: String, option: OrderHistorySortOption)] = [
            ("依時間由新到舊", "calendar.badge.clock", .byDateDescending),
            ("依時間由舊到新", "calendar", .byDateAscending),
            ("依金額從高到低", "arrow.down.circle", .byAmountDescending),
            ("依金額從低到高", "arrow.up.circle", .byAmountAscending),
            ("依取件方式", "shippingbox", .byPickupMethod)
        ]
        
        let actions = sortOptions.map { option in
            UIAction(title: option.title, image: UIImage(systemName: option.image)) { _ in
                
                print("Selected sort option: \(option.title)")

                
                self.orderHistorySortMenuDelegate?.didSelectSortOption(option.option)
            }
        }
        return UIMenu(title: "選擇排序方式", children: actions)
    }
    
}
