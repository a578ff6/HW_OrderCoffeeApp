//
//  MenuDrinkCategoryViewModel.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/22.
//

// MARK: - 筆記：調整 `MenuDrinkCategoryViewModel` 與 `MenuDrinkCategoryManager` 設計的比較與原因 (重要)
/**
 
 ### 筆記：調整 `MenuDrinkCategoryViewModel` 與 `MenuDrinkCategoryManager` 設計的比較與原因

 - 原本直接使用 `MenuModels`.swift，但由於飲品在`Firebase`中是`鉗套式結構`，因此 `MenuModels.swift` 中還養其他的資料模型。
 - 導致 `Menu` 、 `DrinkCategord`、 `DrinkDetail` 都在使用`MenuModels.swift`，整體職責非常模糊。
 - 此外當在對結構進行調整時，也會導致其他使用 `MenuModels.swift` 的部分出現問題。
 - 因此才將其抽出成`MenuDrinkCategoryViewModel`、`MenuDrinkCategoryManager`來使用。達到職責單一。

` * What（調整內容）`
 
 1. 原始設計：
 
    - 直接使用資料層模型（`MenuModels.swift` 中的 `Category`、`Subcategory`、`Drink` 等）和資料請求層（`MenuController`）處理所有邏輯。
    - 控制器（如 `MenuViewController`）直接與 `MenuController` 交互，並將資料層模型傳遞到界面。

 ---
 
 2. 調整後設計：
 
    - 新增 `MenuDrinkCategoryViewModel`：專為 UI 展示設計的輕量模型，只包含 UI 需要的字段（如 `title`、`imageUrl`、`subtitle`）。
    - 新增 `MenuDrinkCategoryManager`：負責將資料層模型（如 `Category`）轉換為展示層模型（如 `MenuDrinkCategoryViewModel`）並管理資料邏輯。

 ----------

 `* Why（為何進行調整）`
 
 1. 遵循單一原則（SRP，Single Responsibility Principle）：
 
    - 原始設計問題：
 
      - 控制器同時負責資料請求、資料轉換和 UI 顯示，導致控制器職責過多，難以維護。
      - 控制器直接處理原始資料層模型，未來如果數據結構變更（如 Firebase 的資料格式更新），控制器需同步修改，耦合度過高。
 
    - 調整後優勢：
 
      - 資料請求與展示邏輯分離：`MenuController` 負責資料請求，`MenuDrinkCategoryManager` 負責轉換與組織。
      - 控制器專注於界面邏輯，減少耦合，職責更加明確。

 ---
 
 2. 提升可擴展性：
 
    - 原始設計問題：
 
      - 控制器與資料層模型高度耦合，當不同界面需要不同的展示數據時，控制器需手動處理篩選與轉換邏輯。
 
    - 調整後優勢：
 
      - 引入 `MenuDrinkCategoryViewModel` 為界面量身設計，未來如果需要新增字段或調整展示邏輯，只需修改 `MenuDrinkCategoryManager` 而無需影響控制器。
      - 支援不同頁面需求：`MenuDrinkCategoryViewModel` 可以根據需求調整為不同的 ViewModel，如詳細頁面或其他特殊需求。

 ---

 3. 易於測試與維護：
 
    - 原始設計問題：
 
      - 測試時需模擬完整的資料層模型，且控制器邏輯不易單獨測試。
 
    - 調整後優勢：
 
      - 測試 `MenuDrinkCategoryManager` 時可以隔離資料層邏輯，專注於資料轉換是否正確。
      - 控制器更專注於 UI，測試時也可以專注於界面交互而非資料處理。

 ----------

 `* How（具體調整方式與比較）`

 1. 建立 ViewModel：
 
    - 原始設計： 直接使用 `Category`。
 
    - 調整後：
 
      - 新增 `MenuDrinkCategoryViewModel`，僅包含 UI 所需字段：
        ```swift
        struct MenuDrinkCategoryViewModel {
            let title: String
            let imageUrl: URL
            let subtitle: String
        }
        ```

 ---
 
 2. 新增 Manager 負責邏輯：
 
    - 原始設計：
 
      - 控制器直接使用 `MenuController` 請求資料並處理。
 
    - 調整後：
 
      - 新增 `MenuDrinkCategoryManager`，負責轉換資料層模型為展示層模型：
        ```swift
        class MenuDrinkCategoryManager {
            private let menuController = MenuController.shared
            
            func fetchMenuDrinkCategories() async throws -> [MenuDrinkCategoryViewModel] {
                let categories = try await menuController.loadCategories()
                return categories.map {
                    MenuDrinkCategoryViewModel(
                        title: $0.title,
                        imageUrl: $0.imageUrl,
                        subtitle: $0.subtitle
                    )
                }
            }
        }
        ```
 
 ---
 
 3. 更新控制器：
 
    - 原始設計：
 
      - `MenuViewController` 直接處理資料請求、資料轉換與展示邏輯。
 
    - 調整後：
 
      - 控制器僅處理界面展示，從 `MenuDrinkCategoryManager` 獲取已處理好的展示模型：
        ```swift
        private func loadMenuDrinkCategories() async {
            do {
                let menuCategories = try await menuDrinkCategoryManager.fetchMenuDrinkCategories()
                self.collectionHandler.categories = menuCategories
                self.menuView.menuCollectionView.reloadData()
            } catch {
                print("Error loading menu categories: \(error)")
            }
        }
        ```

 ----------

 `* 結論`
 
 - 調整後設計優勢：
 
   1. 遵循職責分離與單一原則，控制器更輕量，業務邏輯更清晰。
   2. 提升代碼的可讀性與可擴展性，易於應對需求變更。
   3. 支援更高效的測試，能夠對 Manager 和 ViewModel 單獨測試。

 - 是否維持原設計：
 
   - 如果應用規模很小，且未來需求變更不大，原設計能快速完成開發。
   - 若應用具有增長潛力，且資料結構複雜，調整後設計更合適。
 */


// MARK: - MenuDrinkCategoryViewModel 筆記
/**
 
 ### MenuDrinkCategoryViewModel 筆記


`* What `

 - `MenuDrinkCategoryViewModel` 是一個專為菜單頁面設計的展示模型，用於表示每個飲品分類的核心資訊，方便在 `MenuViewController` 中顯示。

 - 功能：
 
   1. 提供菜單頁面所需的輕量化數據結構。
   2. 包含分類的基本字段：`id`、`title`、`imageUrl`、`subtitle`。
   3. 將資料層模型轉換為適合展示層使用的結構。

 ----------

 `* Why `

 1. 降低耦合度：
 
    - 原始資料結構（`Category`）位於`MenuModels.swift`中，包含菜單頁面不需要的字段，直接操作會讓視圖與資料層耦合過高，降低維護性。
    - 使用 `MenuDrinkCategoryViewModel` 將資料層與展示層分離，使代碼更易測試與擴展。

 2. 提升可讀性與清晰度：
 
    - 展示層只處理必要的字段，讓邏輯更加簡潔清晰，降低誤用或修改原始資料結構的風險。

 3. 專注於展示邏輯：
 
    - 簡化視圖控制器的責任，使其僅需關注與 UI 相關的數據，減少對完整數據模型的處理。

 4. 易於擴展：
 
    - 當需要為不同頁面定制展示模型時，通過 `MenuDrinkCategoryViewModel` 可快速調整顯示內容，而不影響資料層。

 ----------

 `* How `

 1. 設計輕量化的展示模型：
 
    - 從資料層模型（如 `Category`）中提取核心字段，去除不必要的細節。
    - 定義屬性如 `id`、`title`、`imageUrl` 和 `subtitle`，滿足菜單頁面的展示需求。

    ```swift
    struct MenuDrinkCategoryViewModel {
        let id: String
        let title: String
        let imageUrl: URL
        let subtitle: String
    }
    ```

 ----
 
 2. 在 `MenuDrinkCategoryManager` 中負責轉換：
 
    - 在 `MenuDrinkCategoryManager` 中，將資料層的 `Category` 轉換為 `MenuDrinkCategoryViewModel`。

    ```swift
    func fetchMenuDrinkCategories() async throws -> [MenuDrinkCategoryViewModel] {
        let categories = try await menuController.loadCategories()
        return categories.map {
            MenuDrinkCategoryViewModel(
                id: $0.id ?? "",
                title: $0.title,
                imageUrl: $0.imageUrl,
                subtitle: $0.subtitle
            )
        }
    }
    ```

 ----

 3. 視圖控制器中使用展示模型：
 
    - `MenuViewController` 通過 `MenuDrinkCategoryManager` 加載 `MenuDrinkCategoryViewModel`，並傳遞給 `MenuCollectionHandler` 以更新 UI。

    ```swift
    private func loadMenuDrinkCategories() async {
        do {
            let menuCategories = try await menuDrinkCategoryManager.fetchMenuDrinkCategories()
            self.collectionHandler.categories = menuCategories
            self.menuView.menuCollectionView.reloadData()
        } catch {
            print("Error loading menu categories: \(error)")
        }
    }
    ```

 ----------

 `* 結論`

 - `MenuDrinkCategoryViewModel` 的設計符合以下原則：
 
 1. 職責單一：專注於展示層，避免與資料層耦合。
 2. 簡化邏輯：減少視圖控制器對完整數據結構的依賴，提升代碼可讀性。
 3. 面向擴展：易於根據不同頁面的需求調整字段，提升靈活性與維護性。

 透過 `MenuDrinkCategoryViewModel`，實現了資料層與展示層的分離，讓菜單頁面的開發與維護更加清晰有序。
 */



// MARK: - (v)

import Foundation

/// 用於表示菜單頁面中飲品分類的展示模型。
///
/// 此模型專為 UI 設計，簡化了原始資料結構，
/// 只包含菜單頁面所需的核心字段，避免直接操作完整資料層模型。
///
/// - 功能:
///   1. 將原始 `Category` 資料轉換為僅包含顯示需求的輕量模型。
///   2. 提高代碼可讀性與可維護性，降低控制器與資料層的耦合度。
///   3. 支援菜單頁面顯示每個分類的標題、圖片與描述等基本信息。
///   4. 提供 UI 層所需的輕量化數據結構，用於顯示分類標題、圖片與子標題。
///
/// - 使用場景:
///   適用於 `MenuViewController` 的 `UICollectionView`，
///   作為 `MenuDrinkCategoryManager` 處理後提供給視圖的展示數據。
///
/// - 屬性:
///   - id: 飲品分類的唯一識別符。
///   - title: 飲品分類的名稱。
///   - imageUrl: 飲品分類對應的圖片 URL。
///   - subtitle: 飲品分類的簡短描述。
struct MenuDrinkCategoryViewModel {
    let id: String
    let title: String
    let imageUrl: URL
    let subtitle: String
}
