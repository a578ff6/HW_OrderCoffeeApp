//
//  DrinkDetailViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/25.
//



// MARK: - DrinkDetailViewController 筆記
/**
 
 ## DrinkDetailViewController 筆記
 
 `* What`
 
 - 由於飲品結構是鉗套是結構，因此透過 `categoryId` 和 `subcategoryId`、`drinkId`，可更精確地從 Firestore 加載飲品資料。
 - `DrinkDetailViewController` 是應用程式中負責展示飲品詳細資訊的核心控制器，包含以下功能：
 
 `1.資訊展示：`

 - 顯示飲品的圖片、描述、可選尺寸與價格資訊。
 
 `2.互動功能：`
 
 - 支援加入購物車、分享與收藏功能，並提供即時按鈕狀態更新。
 
 `3. 尺寸選擇刷新：`

 - 用戶選擇尺寸時，透過模組化方法處理尺寸狀態更新、按鈕選中狀態刷新與價格資訊更新。
 
 `3.架構模組化：`
 
 - `DrinkDetailHandler` 處理 UICollectionView 的資料來源與交互邏輯。
 - `DrinkDetailNavigationBarManager` 負責導航欄的按鈕配置與狀態更新。
 - `DrinkDetailFavoriteStateCoordinator` 集中管理收藏邏輯及其與 UI 的同步。
 
 ------------
 
 `* Why`
 
 `1.分離關注點：`

 - 清晰劃分業務邏輯、資料處理與視圖層次，避免控制器過於臃腫。
 - 確保收藏、分享、資料顯示等功能單一責任分明。
 
 `2.提升可讀性與可維護性：`

 - 各功能模組化，降低程式碼耦合，增強可測試性與擴展性。
 - 使用明確的協作方式（Delegate、Handler），使功能執行更直觀。
 
 `3.增強用戶體驗：`

 - 確保按鈕狀態即時更新，避免與用戶操作行為不一致。
 - 支援動態更新價格與資料載入進度提示，提升互動感與操作效率。
 
 ------------

 `* How`
 
 `1.依賴組件與初始化：`

 - 將主要邏輯劃分給以下組件：
    - `DrinkDetailHandler`：負責 UICollectionView 的數據與互動處理。
    - `DrinkDetailNavigationBarManager`：管理導航欄按鈕配置與狀態更新。
    - `DrinkDetailFavoriteStateCoordinator`：整合收藏邏輯與 UI 狀態更新，減少控制器內的耦合。

 - 於 viewDidLoad 初始化相關管理器並配置導航欄按鈕。
 
 `2.功能模組與核心方法：`

 - 資料載入：
    - 使用 `loadDrinkDetail()` 從 `Firebase` 獲取詳細資料。
    - 成功後調用 `handleDrinkDetailLoaded()` 更新模型與視圖。
 
 - 收藏邏輯：
    - 利用 `FavoriteStateCoordinator` 集中管理收藏狀態的檢查與切換， 使用非同步方法處理收藏邏輯，並即時同步按鈕狀態。
    - handleFavoriteToggle(for:)：處理收藏邏輯，包括 UI 即時更新與後端狀態同步。
    - refreshFavoriteState(drinkId:)：檢查後端收藏狀態並刷新按鈕。
 
 - 分享功能：
    - 使用 `didTapShareButton() `調用分享管理器 `DrinkDetailShareManager`，實現資料分享邏輯。
 
 - 加入購物車：
    - 使用 `didTapAddToCart(quantity:) `傳遞用戶選擇的飲品至購物車邏輯。
 
 `3. 尺寸選擇與刷新邏輯：`

 - `選擇尺寸邏輯：`

    - 使用 `didSelectSize(newSize:) `方法，處理用戶選擇尺寸後的狀態更新與視圖刷新。
    - `updateSelectedSize(to:)：`更新當前選中的尺寸。
    - `refreshSizeButtons(selectedSize:)：`刷新尺寸按鈕選中狀態，確保 UI 一致性。
    - `refreshPriceInfo()：`刷新價格資訊以反映最新選擇。
 
 - `刷新按鈕與價格：`

    - 使用 `performBatchUpdates` 提升效率，僅刷新受影響的按鈕，避免多餘的計算。
    - 重新載入 `priceInfo` 區段，確保價格資訊正確同步。
 
 
 `4.視圖邏輯與更新：`

 - UICollectionView 處理：
    - 使用 DrinkDetailHandler 負責數據源與用戶交互邏輯。
 
 - 擴展性設計：
    - 支援未來擴展其他功能（如更多按鈕或資料展示邏輯），不需大幅修改現有程式碼。
    - 利用模組化的組件設計，能輕鬆移植收藏與分享邏輯至其他頁面。
 
 ------------

 `* 實踐架構`
 
 ```
 [DrinkDetailViewController]
        |
        +-----------------------------+
        |                             |
 [DrinkDetailHandler]       [DrinkDetailNavigationBarManager]
                                     |
                          [FavoriteStateCoordinator]
                                     |
                    [DrinkDetailFavoritesHandler]
                                     |
                         [FavoriteManager] -> Firebase
 
 ```
 
 ------------

 `* 注意事項`
 
 `1.drinkId 必須非空：`

 - 確保執行邏輯的安全性，避免因識別碼缺失導致崩潰。
 
 `2.FavoriteStateCoordinator 的正確初始化：`

 - 確保收藏邏輯的正常運作。
 - 確保 FavoriteStateCoordinator 與 navigationBarManager 正確建立聯繫。
 
 `3.避免邏輯重複：`

 - FavoriteStateCoordinator 集中處理收藏邏輯，應避免直接操作 DrinkDetailFavoritesHandler。
 
 `4.按鈕狀態一致性：`

 - 收藏按鈕與後端資料必須保持同步，避免造成用戶誤解。
 
 `5.資料載入過程的提示：`

 - 處理網路延遲或加載錯誤，顯示進度提示與錯誤訊息。
 */


// MARK: - 頁面初始化與即時狀態更新的分工：loadDrinkDetail 與 updateFavoriteButtonState 的設計）
/**
 
 ## 頁面初始化與即時狀態更新的分工：loadDrinkDetail 與 updateFavoriteButtonState 的設計
 
 `* What`
 
 - `loadDrinkDetail` 負責從後端載入飲品詳細資料，並在首次進入 DrinkDetailViewController 時執行。
 - `updateFavoriteButtonState` 用於檢查當前飲品的收藏狀態，並在頁面每次顯示時更新收藏按鈕。
 
 ------------------

 `* Why`
 
 - 為什麼不將 loadDrinkDetail 放在 viewWillAppear？
 
 `1.避免重複資料請求：`

 - `viewWillAppear` 每次頁面顯示時都會被調用，而 `loadDrinkDetail` 通常只需要在進入頁面時執行一次即可。
 - 重複從後端請求飲品詳細資料會浪費資源並降低效能。
 
` 2.資料更新頻率不同：`

 - 飲品詳細資料在頁面首次載入時應完成，不需要在每次顯示時重新載入。
 - 收藏狀態可能會因為其他頁面的操作（例如 `FavoritesViewController` 的刪除或添加收藏）發生變化，因此需要在每次顯示時進行檢查。
 
 `3.用戶體驗考量：`

 - 在 `viewWillAppear` 中多次調用 loadDrinkDetail 可能導致用戶頻繁看到加載指示（HUD），影響體驗。
 - 收藏狀態更新是一個輕量操作，適合在每次顯示時執行。
 
 ------------------
 
 `* How`
 
 `1.loadDrinkDetail 放在 viewDidLoad：`

 - 飲品詳細資料通常不會頻繁更新，應在頁面初始化時載入。
 - 避免重複請求資料，提升效能。
 
 `2.updateFavoriteButtonState 放在 viewWillAppear：`

 - 收藏狀態與其他頁面（例如 `FavoritesViewController`）互動緊密，適合在每次顯示時更新。
 - 更新收藏按鈕是輕量操作，執行效率高，適合在 viewWillAppear 中執行。
 
 ------------------

 `* 總結`
 
 - `loadDrinkDetail`： 放在 viewDidLoad，僅在頁面初始化時執行，避免重複資料請求。
 - `updateFavoriteButtonState`： 放在 viewWillAppear，在頁面每次顯示時更新收藏狀態。
 
 */


// MARK: - 為什麼在 `didTapAddToCart` 中需要重新構建 `Drink` 基礎模型
/**
 
 ## 為什麼在 `didTapAddToCart` 中需要重新構建 `Drink` 基礎模型

 ---

 `* What`

 - `didTapAddToCart` 是 `DrinkDetailViewController` 中的一個方法，當用戶點擊「加入購物車」按鈕時被觸發，其主要功能包括：

 `1. 飲品數據轉換：`
 
 - 使用當前的 `DrinkDetailModel` 和 `selectedSize`，生成適合訂單使用的基礎模型 `Drink`。

 `2. 新增訂單項目：`
 
 - 通過 `OrderItemManager`，將飲品、尺寸與數量封裝成 `OrderItem`，並添加到當前訂單中。

 `3. 記錄行為：`
 
 - 輸出調試訊息，顯示添加的飲品名稱、尺寸和數量，便於追蹤操作。

 ---

 `* Why`

 `1. 飲品數據處理的必要性：`
 
 - `DrinkDetailModel` 是展示模型，專注於視圖層使用。轉換為基礎模型 `Drink` 後，能夠保證與 `OrderItem` 中飲品數據結構的一致性，減少模型層次的耦合。
 - 使用 `Drink` 作為基礎數據來源，讓訂單管理邏輯更清晰。

 `2. 分離責任：`
 
 - 新增訂單的邏輯完全委託給 `OrderItemManager`，符合單一責任原則，避免控制器直接處理訂單邏輯。

 `3. 提升使用者體驗：`

 - 便於在後續顯示訂單數據或同步訂單至後端數據庫，並為用戶提供清晰的操作反饋。

 ---

 `* How`

 `1. 數據檢查：`
 
    - 確保當前的 `drinkDetailModel` 與 `selectedSize` 已正確設置，避免出現空數據或崩潰。

 `2. 飲品模型轉換：`
 
 - 根據 `DrinkDetailModel` 的內容創建一個新的 `Drink` 對象，確保數據結構符合訂單的要求。

    ```swift
    let drink = Drink(
        id: drinkId,
        name: drinkDetailModel.name,
        subName: drinkDetailModel.subName,
        description: drinkDetailModel.description,
        imageUrl: drinkDetailModel.imageUrl,
        sizes: drinkDetailModel.sizeDetails,
        prepTime: drinkDetailModel.prepTime
    )
    ```

 `3. 添加訂單項目：`
        
 - 使用 `OrderItemManager` 將轉換後的飲品數據與尺寸、數量等封裝為 `OrderItem`，添加至當前訂單。

    ```swift
    OrderItemManager.shared.addOrderItem(
        drink: drink,
        size: selectedSize,
        quantity: quantity
    )
    ```

 ---

 `* 設計考量`

 `1. 模型轉換與結構一致性：`
 
    - 雖然 `DrinkDetailModel` 是專用於詳細頁的展示模型，但它與 `Drink` 的轉換過程簡單直觀，避免了重複代碼。
    - 如果未來需要更大的靈活性，可以考慮設置單獨的訂單飲品模型（如 `OrderDrink`）。

 `2. 邏輯抽象與模組化：`
 
    - 新增訂單邏輯由 `OrderItemManager` 處理，控制器不直接操作訂單項目，符合高內聚低耦合原則。

 `3. 後續優化空間：`
 
    - 如果邏輯複雜度增加，可以進一步抽出 `func createDrink()` 或 `func addOrderItem()` 以提升可讀性。
 */


// MARK: - 筆記：`selectedSize` 的型別設計與使用方式
/**
 ## 筆記：`selectedSize` 的型別設計與使用方式


 `* What：`
 
 - `selectedSize` 是 `DrinkDetailViewController` 中用來記錄使用者目前選擇的飲品尺寸，並影響 UI 顯示和業務邏輯的屬性。

 - 相關背景：
 
   - `DrinkDetailModel` 提供了一個 `sortedSizes` 屬性（已排序的飲品尺寸）。
   - `selectedSize` 是從 `sortedSizes` 初始化後的狀態，並用於操作相關功能，例如計算價格或加入購物車。

 -------------------------------

` * Why：selectedSize 應該是非可選型別還是可選型別？`
 
 - `非可選型別的適用情境：`
 
   - 如果可以 **100% 確保畫面初始化後，`selectedSize` 一定會有值**（例如，`sortedSizes` 一定有內容）。
   - 使用非可選型別可以減少程式碼中 `nil` 檢查的需求，讓程式邏輯更清晰。

 - `可選型別的適用情境：`
 
   - 如果在某些情況下，`selectedSize` 可能沒有值（例如資料尚未準備完成，或使用者尚未選擇尺寸），使用可選型別更能反映真實的資料狀態。

 - `目前情境：`
 
   - 模型層的 `sortedSizes` 保證一定至少有一個值，因此畫面載入後 `selectedSize` 理論上也應有值，適合設計為 **非可選型別**。
   - 然而，`selectedSize` 和 `sizeDetails[selectedSize]` 的關聯需要額外檢查，避免出現資料異常導致錯誤。

 -------------------------------

 `* How：`

 - 設計 `selectedSize` 為非可選型別
 
 1. 宣告為非可選型別，並在初始化時立即設置：
 
    ```swift
    private var selectedSize: String = ""
    ```

 2. 在 `updateModel` 時，從模型中安全初始化：
 
    ```swift
    private func updateModel(with drinkDetail: DrinkDetailModel) {
        self.drinkDetailModel = drinkDetail
        guard let firstSize = drinkDetail.sortedSizes.first else {
            fatalError("DrinkDetailModel.sortedSizes 必須至少有一個值")
        }
        self.selectedSize = firstSize
    }
    ```

 3. 使用時不需要檢查 `selectedSize` 是否為 `nil`，但仍需檢查 `sizeDetails` 是否有對應的值：
 
    ```swift
    case .priceInfo:
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? DrinkPriceInfoCollectionViewCell else {
            fatalError("Cannot dequeue DrinkPriceInfoCollectionViewCell")
        }

        // 檢查 `sizeDetails` 是否包含對應尺寸的資料
        guard let sizeInfo = drinkDetailModel.sizeDetails[selectedSize] else {
            fatalError("DrinkDetailModel.sizeDetails 中缺少選中的尺寸資訊")
        }
        cell.configure(with: sizeInfo)
        return cell
    ```

 ------------------
 
 `- 使用可選型別的情境（不建議）`
 
 若決定使用可選型別，需在每次使用 `selectedSize` 時進行檢查：
 
 1. 宣告為可選型別：
 
    ```swift
    private var selectedSize: String?
    ```

 2. 在使用時檢查：
 
    ```swift
    guard let selectedSize = selectedSize else {
        fatalError("selectedSize 尚未設置")
    }
    guard let sizeInfo = drinkDetailModel.sizeDetails[selectedSize] else {
        fatalError("DrinkDetailModel.sizeDetails 中缺少選中的尺寸資訊")
    }
    cell.configure(with: sizeInfo)
    ```

 ---

 `* 結論`
 
 - 設計 `selectedSize` 為 **非可選型別**，並在初始化時確保有值（例如取 `sortedSizes.first!`）。
 - 仍需對 `sizeDetails[selectedSize]` 進行檢查，確保資料完整性，這是與 `selectedSize` 型別無關的安全措施。
 - 若使用可選型別，程式會需要額外的 `nil` 檢查，反而增加複雜性，通常不建議。

 ---

 `* 小結`
 
 - `非可選型別的好處：`
 
   - 減少程式邏輯中 `nil` 檢查，讓程式碼更簡潔。
   - 符合畫面初始化後 `selectedSize` 必有值的預期。

 - `關鍵提示：`
 
   - `selectedSize` 是 UI 狀態的一部分，應根據畫面需求選擇型別。
   - 模型層的資料保證（例如 `sortedSizes`）不一定能完全覆蓋 UI 層的狀態需求，仍需在程式中進行適當的檢查與保護。
 */


// MARK: - 關於「尺寸按鈕」在 `DrinkDetailHandler` 與 `DrinkDetailViewController` 的職責與處理邏輯
/**
 
 ## 關於「`尺寸按鈕`」在 `DrinkDetailHandler` 與 `DrinkDetailViewController` 的職責與處理邏輯


 * What：
 
 1. `DrinkDetailHandler`
 
    - 處理 `UICollectionView` 的資料來源與使用者互動邏輯。
    - 初始化每個尺寸按鈕的狀態（例如是否選中）。
    - 當使用者選擇尺寸時，透過 Delegate 通知 `DrinkDetailViewController`。

 2. `DrinkDetailViewController`
 
    - 處理使用者交互後的業務邏輯，例如更新 `selectedSize`。
    - 負責刷新所有尺寸按鈕的選中狀態，並更新相關的價格資訊。
    - 保證業務邏輯與 UI 同步。

 -------------------

 * Why：
 
 `1.職責清晰`
 
    - `DrinkDetailHandler` 專注於單個 Cell 的生成與基本配置，降低耦合度。
    - `DrinkDetailViewController` 負責業務邏輯的處理與全局 UI 的刷新，確保使用者操作後的整體狀態一致。

 `2. 易於維護`
 
    - 分開處理單個 Cell 的渲染邏輯與整體界面的更新，減少程式碼重複與責任模糊的風險。

 `3. 靈活性`
 
    - `DrinkDetailHandler` 提供一個基礎的 Cell 配置方式，能在不同情境下進行擴展。
    - `DrinkDetailViewController` 負責處理特定場景（如按鈕點擊後）的業務需求，增強控制能力。

 -------------------

` * How：`

 1. `DrinkDetailHandler` 的邏輯
 
    - 位置：`cellForItemAt` 方法中。
 
    - 實現：
 
      ```swift
      let size = drinkDetailModel.sortedSizes[indexPath.item]
      cell.configure(with: size, isSelected: size == selectedSize)
      cell.sizeSelected = { selectedSize in
          delegate.didSelectSize(selectedSize)
      }
      ```
 
    - 作用：
 
      - 初始化每個尺寸按鈕的外觀。
      - 設置點擊後的回調，將選中的尺寸傳遞給 Controller。

 -----
 
 2. `DrinkDetailViewController` 的邏輯
 
    - 位置：`didSelectSize(_ newSize: String)` 方法中。
 
    - 實現：
 
      ```swift
      drinkDetailView.drinkDetailCollectionView.performBatchUpdates({
          guard let sizes = drinkDetailModel?.sortedSizes else { return }
          for (index, size) in sizes.enumerated() {
              let indexPath = IndexPath(item: index, section: DrinkDetailSection.sizeSelection.rawValue)
              guard let cell = drinkDetailView.drinkDetailCollectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell else { continue }
              cell.configure(with: size, isSelected: size == newSize)
          }
      }, completion: nil)

      // 更新價格資訊
      drinkDetailView.drinkDetailCollectionView.reloadSections(IndexSet(integer: DrinkDetailSection.priceInfo.rawValue))
      ```
 
    - 作用：
 
      - 遍歷並更新所有尺寸按鈕的選中狀態，確保視圖與使用者選擇保持同步。
      - 刷新價格資訊，提供最新的業務結果。

 -------------------

 * 總結：
 
 - `DrinkDetailHandler`：專注於處理單個 Cell 的生成與渲染。
 - `DrinkDetailViewController`：專注於業務邏輯處理，並控制整體 UI 的一致性。

 */


// MARK: - 調整尺寸按鈕刷新邏輯與職責架構的探討
/**
 
 ## 調整尺寸按鈕刷新邏輯與職責架構的探討

 ---

 `1. 調整是否更好？（將 `updateSelectedSize` 移至 `DrinkDetailViewController` 的 `performBatchUpdates`）`

 `* What`
 
 - 原先在 `DrinkDetailHandler` 使用手動方法 `updateSelectedSize`，逐一更新 Cell 的選中狀態。
 - 現在改為在 `DrinkDetailViewController` 的 `didSelectSize` 中，透過 `performBatchUpdates` 刷新所有尺寸按鈕。

 ------------------

 `* Why`
 
 - 職責更明確：將業務邏輯（更新選中尺寸狀態）集中在 `DrinkDetailViewController`，符合業務邏輯應由 Controller 處理的原則。
 
 - 效能與一致性：
 
   - `performBatchUpdates` 可一次性更新多個 Cell，避免多次執行單個 Cell 的刷新，對效能有幫助。
   - 集中處理 UI 更新，確保整體狀態一致，避免手動刷新可能帶來的漏刷或邏輯錯誤。
 
 - 易於擴展與維護：
 
   - Controller 作為唯一管理業務邏輯的層級，易於進行後續擴展與除錯。
   - 減少 `DrinkDetailHandler` 的責任，讓它專注於 Cell 的初始化和用戶操作的即時回傳。

 ------------------

 `* How`
 
 - 調整後的程式碼實現：
 
 ```swift
 func didSelectSize(_ newSize: String) {
     selectedSize = newSize
     print("尺寸已更新：\(newSize)")
     
     // 刷新所有尺寸按鈕
     drinkDetailView.drinkDetailCollectionView.performBatchUpdates({
         guard let sizes = drinkDetailModel?.sortedSizes else { return }
         for (index, size) in sizes.enumerated() {
             let indexPath = IndexPath(item: index, section: DrinkDetailSection.sizeSelection.rawValue)
             guard let cell = drinkDetailView.drinkDetailCollectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell else { continue }
             cell.configure(with: size, isSelected: size == newSize)
         }
     }, completion: nil)
     
     // 更新價格資訊
     drinkDetailView.drinkDetailCollectionView.reloadSections(IndexSet(integer: DrinkDetailSection.priceInfo.rawValue))
 }
 ```

 ------------------

 `2. 職責架構是否明確？是否符合 iOS 面向物件設計？`

 `* What`
 
 - `DrinkDetailHandler`
 
   - 專注於處理 `UICollectionView` 的資料來源與用戶交互。
   - 初始化 Cell 的狀態並回傳用戶操作。
 
 - `DrinkDetailViewController`
   - 管理業務邏輯與整體 UI 更新，包括選中尺寸狀態與價格資訊的刷新。

 ------------------

 
 `* Why`
 
 - `符合 MVC 架構原則：`
 
   - Model 管理資料結構（`DrinkDetailModel` 提供飲品與尺寸資訊）。
   - ViewController 處理業務邏輯（例如尺寸切換與價格更新）。
   - Handler 作為 `View` 的輔助，專注於單一 Cell 的生成與操作邏輯。
 
 - `低耦合性：`
   - Handler 和 Controller 之間透過 Delegate 進行通訊，維持清晰的責任分離，避免相互依賴。
 
 - `可測試性：`
   - 將業務邏輯集中在 Controller，有助於單元測試覆蓋關鍵功能。
   - Handler 專注於 UI 邏輯，可單獨測試 Cell 初始化的正確性。

 ------------------
 
`* How`
 
 - 目前的職責劃分：
 
 - `DrinkDetailHandler`
 
   ```swift
   let size = drinkDetailModel.sortedSizes[indexPath.item]
   cell.configure(with: size, isSelected: size == selectedSize)
   cell.sizeSelected = { selectedSize in
       delegate.didSelectSize(selectedSize)
   }
   ```
   - 單一責任：初始化尺寸 Cell 並設置選中狀態。
   - 使用 Delegate 將用戶操作回傳給 Controller。

 -----
 
 - `DrinkDetailViewController`
 
   ```swift
   func didSelectSize(_ newSize: String) {
       selectedSize = newSize
       // 刷新尺寸按鈕與價格資訊
   }
   ```
   - 集中管理業務邏輯，刷新 UI 狀態並處理業務需求（如價格更新）。

 ----------------------

 `* 結論`

 - `調整後的設計更符合 iOS 面向物件設計原則：`
 
   - 職責劃分清晰：`DrinkDetailHandler` 負責 Cell 初始化，`DrinkDetailViewController` 負責業務邏輯與全局 UI 更新。
   - 減少耦合度，增強可測試性與維護性。
 
 - `調整效果更優：`
 
   - 提升效能，集中處理尺寸按鈕的刷新。
   - 確保整體 UI 與邏輯的同步性，避免狀態不一致問題。
 */



// MARK: - (v)

import UIKit

/// `DrinkDetailViewController`
///
/// ### 功能描述
/// 此控制器負責顯示飲品的詳細資訊，並提供以下功能：
/// - 顯示飲品圖片、描述、尺寸選擇與價格資訊。
/// - 支援用戶選擇飲品尺寸並動態更新價格資訊。
/// - 加入購物車功能，將所選飲品及數量傳遞至購物車管理邏輯。
/// - 支援分享與收藏功能，並確保收藏按鈕狀態即時更新。
///
/// ### 設計目標
///  - 模組化設計：
///    - 使用 `DrinkDetailHandler` 處理 `UICollectionView` 的資料來源與交互邏輯。
///    - 使用 `DrinkDetailNavigationBarManager` 管理導航欄邏輯。
///    - 使用 `DrinkDetailShareManager` 處理分享邏輯。
///    - 使用 `DrinkDetailFavoriteStateCoordinator` 集中處理收藏邏輯與 UI 狀態更新，減少控制器負擔。
///    - 使用 `DrinkDetailHandlerDelegate` 與控制器進行通信。
///  - 確保 UI 與後端資料一致性：
///    - 透過 `DrinkDetailFavoriteStateCoordinator` 同步收藏按鈕狀態與後端資料。
///
/// ### 注意事項
/// - 確保 `drinkId` 在操作過程中非空，避免崩潰。
/// - 確保 `DrinkDetailFavoriteStateCoordinator` 與相關邏輯處理器正確初始化，避免狀態不同步的問題。
class DrinkDetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 主視圖：包含顯示飲品詳細資訊的 UI 元件。
    private let drinkDetailView = DrinkDetailView()
    
    // MARK: - Handlers and Managers
    
    /// 處理 `UICollectionView` 的資料與使用者互動邏輯。
    private var handler: DrinkDetailHandler?
    
    /// 管理導航欄按鈕與標題的邏輯。
    private var navigationBarManager: DrinkDetailNavigationBarManager?
    
    /// 分享管理器：處理飲品分享的邏輯。
    private var shareManager: DrinkDetailShareManager?
    
    /// 收藏狀態協調器：集中管理收藏邏輯與 UI 更新。
    private var favoriteCoordinator: DrinkDetailFavoriteStateCoordinator?
    
    // MARK: - Model and State
    
    /// 飲品詳細資料：從 Firebase 加載的資料模型。
    private var drinkDetailModel: DrinkDetailModel?
    
    /// 當前選擇的飲品尺寸，用於全局狀態管理。
    private var selectedSize: String = ""
    
    // MARK: - Identifier Properties
    
    /// 飲品的分類 ID
    var categoryId: String?
    
    /// 飲品的子分類 ID
    var subcategoryId: String?
    
    /// 飲品的唯一 ID
    var drinkId: String?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = drinkDetailView
    }
    
    /// 初始化控制器時加載資料並設置導航欄。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        initializeFavoriteCoordinator()
        loadDrinkDetail()
    }
    
    /// 當頁面即將顯示時更新收藏按鈕狀態。
    ///
    /// - 確保收藏按鈕的圖示能正確反映後端的收藏狀態。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButtonState()
    }
    
    // MARK: - Setup Methods
    
    /// 配置導航欄樣式與功能按鈕。
    ///
    /// 此方法使用 `DrinkDetailNavigationBarManager`：
    /// 1. 設置導航欄標題的顯示模式。
    /// 2. 添加功能按鈕，包括「分享」與「收藏」按鈕。
    /// 3. 設置當按鈕被點擊時的回調代理。
    private func configureNavigationBar() {
        navigationBarManager = DrinkDetailNavigationBarManager(navigationItem: navigationItem)
        navigationBarManager?.delegate = self
        navigationBarManager?.configureNavigationBarTitle(largeTitleDisplayMode: false)
        navigationBarManager?.addNavigationButtons()
    }
    
    /// 初始化 `DrinkDetailFavoriteStateCoordinator` 並設置相關邏輯處理器。
    ///
    /// 透過協調器管理收藏邏輯，確保狀態更新與後端同步。
    private func initializeFavoriteCoordinator() {
        guard let navigationBarManager else { return }
        let favoritesHandler = DrinkDetailFavoritesHandler()
        favoriteCoordinator = DrinkDetailFavoriteStateCoordinator(navigationBarManager: navigationBarManager, favoritesHandler: favoritesHandler)
    }
    
    /// 更新收藏按鈕的狀態。
    ///
    /// 使用 `DrinkDetailFavoriteStateCoordinator` 刷新按鈕圖示，確保 UI 與後端資料一致。
    private func updateFavoriteButtonState() {
        favoriteCoordinator?.refreshFavoriteState(drinkId: drinkId)
    }
    
    // MARK: - Data Loading
    
    /// 從 Firebase 加載飲品詳細資訊。
    /// - 確保分類與飲品 ID 已設置。
    private func loadDrinkDetail() {
        guard let categoryId, let subcategoryId, let drinkId else { return }
        print("[DrinkDetailViewController] 開始加載飲品詳細資料 - categoryId: \(categoryId), subcategoryId: \(subcategoryId), drinkId: \(drinkId)")
        HUDManager.shared.showLoading(text: "載入中...")
        
        Task {
            do {
                let drinkDetail = try await DrinkDetailManager().fetchDrinkDetail(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
                print("[DrinkDetailViewController] 加載成功 - 飲品名稱: \(drinkDetail.name)")
                handleDrinkDetailLoaded(drinkDetail)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - View Updates

    /// 加載飲品詳細資料後的處理邏輯。
    /// - Parameter drinkDetail: 已加載的飲品詳細資料模型。
    private func handleDrinkDetailLoaded(_ drinkDetail: DrinkDetailModel) {
        updateModel(with: drinkDetail)
        setupCollectionView()
        drinkDetailView.drinkDetailCollectionView.reloadData()
    }
    
    /// 更新模型資料。
    /// - Parameter drinkDetail: 飲品詳細資料模型。
    private func updateModel(with drinkDetail: DrinkDetailModel) {
        self.drinkDetailModel = drinkDetail
        guard let firstSize = drinkDetail.sortedSizes.first else {
            fatalError("DrinkDetailModel.sortedSizes 必須至少有一個值")
        }
        self.selectedSize = firstSize
    }
    
    /// 配置 `UICollectionView` 的資料來源與委派。
    private func setupCollectionView() {
        let collectionView = drinkDetailView.drinkDetailCollectionView
        handler = DrinkDetailHandler(drinkDetailHandlerDelegate: self)
        collectionView.dataSource = handler
        collectionView.delegate = handler
    }
    
}

// MARK: - DrinkDetailHandlerDelegate

extension DrinkDetailViewController: DrinkDetailHandlerDelegate {
    
    // MARK: - Size Selection Methods

    /// 提供飲品詳細資料模型
    func getDrinkDetailModel() -> DrinkDetailModel {
        guard let drinkDetailModel else {
            fatalError("DrinkDetailModel 尚未加載")
        }
        return drinkDetailModel
    }
    
    /// 提供當前選中的飲品尺寸
    func getSelectedSize() -> String {
        return selectedSize
    }
    
    /// 使用者選擇了新尺寸時觸發
    ///
    /// ### 功能描述：
    /// - 更新 `selectedSize` 為新選中的尺寸。
    /// - 使用 `performBatchUpdates` 刷新所有尺寸按鈕的選中狀態，確保 UI 狀態一致。
    /// - 根據新尺寸刷新價格資訊。
    ///
    /// - Parameter newSize: 使用者選中的新尺寸。
    func didSelectSize(_ newSize: String) {
        updateSelectedSize(to: newSize)
        refreshSizeButtons(selectedSize: newSize)
        refreshPriceInfo()
    }

    /// 更新選中的尺寸狀態
    private func updateSelectedSize(to newSize: String) {
        selectedSize = newSize
        print("尺寸已更新：\(newSize)")
    }

    /// 刷新所有尺寸按鈕的選中狀態
    private func refreshSizeButtons(selectedSize: String) {
        drinkDetailView.drinkDetailCollectionView.performBatchUpdates({
            guard let sizes = drinkDetailModel?.sortedSizes else { return }
            for (index, size) in sizes.enumerated() {
                let indexPath = IndexPath(item: index, section: DrinkDetailSection.sizeSelection.rawValue)
                guard let cell = drinkDetailView.drinkDetailCollectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell else { continue }
                cell.configure(with: size, isSelected: size == selectedSize)
            }
        }, completion: nil)
    }

    /// 刷新價格資訊
    private func refreshPriceInfo() {
        drinkDetailView.drinkDetailCollectionView.reloadSections(IndexSet(integer: DrinkDetailSection.priceInfo.rawValue))
    }

    // MARK: - Cart Management Methods

    /// 當點擊加入購物車按鈕時觸發
    ///
    /// ### 功能描述：
    /// - 使用當前選中的飲品詳細資料模型（`DrinkDetailModel`）與尺寸（`selectedSize`）構建基礎飲品模型（`Drink`）。
    /// - 通過 `OrderItemManager` 新增訂單項目，並傳遞飲品數據、尺寸與數量。
    ///
    /// ### 注意事項：
    /// - 確保 `drinkDetailModel` 與 `selectedSize` 已正確設置。
    /// - 使用基礎模型 `Drink`，保證數據結構一致性。
    ///
    /// - Parameter quantity: 飲品的數量
    func didTapAddToCart(quantity: Int) {
        guard let drinkDetailModel else { return } // 檢查 drinkDetailModel 是否為 nil
        print("加入購物車 - 飲品：\(drinkDetailModel.name)，尺寸：\(selectedSize)，數量：\(quantity)")
        
        /// 根據當前的 `DrinkDetailModel` 創建基礎模型 `Drink`
        let drink = Drink(
            name: drinkDetailModel.name,
            subName: drinkDetailModel.subName,
            description: drinkDetailModel.description,
            imageUrl: drinkDetailModel.imageUrl,
            sizes: drinkDetailModel.sizeDetails,
            prepTime: drinkDetailModel.prepTime
        )
        
        /// 添加訂單項目至 `OrderItemManager`
        OrderItemManager.shared.addOrderItem(
            drink: drink,
            size: selectedSize,
            quantity: quantity
        )
    }
    
}

// MARK: - DrinkDetailNavigationBarDelegate

extension DrinkDetailViewController: DrinkDetailNavigationBarDelegate {
    
    // MARK: - Share Methods

    /// 處理分享按鈕點擊事件
    ///
    /// 當使用者點擊分享按鈕時，觸發此方法。
    /// 使用 `DrinkDetailShareManager` 執行分享邏輯。
    func didTapShareButton() {
        guard let drinkDetailModel else { return }
        let shareManager = DrinkDetailShareManager()
        shareManager.share(drinkDetailModel: drinkDetailModel, selectedSize: selectedSize, from: self)
    }

    // MARK: - Favorite Methods

    /// 處理收藏按鈕點擊事件
    ///
    /// ### 功能描述
    /// 當使用者點擊收藏按鈕時，觸發此方法。
    /// - 透過 `createFavoriteDrink` 建立 `FavoriteDrink` 資料模型，將飲品資訊轉換為收藏所需的格式。
    /// - 使用 `DrinkDetailFavoriteStateCoordinator` 的 `handleFavoriteToggle` 方法集中處理收藏狀態邏輯，
    ///   包括即時 UI 切換與後端同步，減少控制器的邏輯負擔。
    ///
    /// ### 注意事項
    /// - 確保 `categoryId`、`subcategoryId`、`drinkId` 和 `drinkDetailModel` 均非空，否則不執行任何操作。
    /// - 此方法僅負責觸發收藏狀態的處理邏輯，具體的 UI 和後端同步由 `DrinkDetailFavoriteStateCoordinator` 完成。
    func didTapFavoriteButton() {
        guard let categoryId, let subcategoryId, let drinkId, let drinkDetailModel else { return }
        let favoriteDrink = createFavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId, drinkDetailModel: drinkDetailModel)
        favoriteCoordinator?.handleFavoriteToggle(for: favoriteDrink) 
    }
        
    /// 建立 `FavoriteDrink` 資料模型
    ///
    /// - Parameters:
    ///   - categoryId: 飲品的分類 ID
    ///   - subcategoryId: 飲品的次分類 ID
    ///   - drinkId: 飲品的唯一識別碼
    ///   - drinkDetailModel: 飲品的詳細資料模型
    /// - Returns: 一個新的 `FavoriteDrink` 實例
    private func createFavoriteDrink(categoryId: String, subcategoryId: String, drinkId: String, drinkDetailModel: DrinkDetailModel) -> FavoriteDrink {
        return FavoriteDrink(
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            drinkId: drinkId,
            name: drinkDetailModel.name,
            subName: drinkDetailModel.subName,
            imageUrlString: drinkDetailModel.imageUrl.absoluteString,
            timestamp: Date()
        )
    }
    
}
