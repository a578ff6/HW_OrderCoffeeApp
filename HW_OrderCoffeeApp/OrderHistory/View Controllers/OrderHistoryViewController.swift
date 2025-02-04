//
//  OrderHistoryViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//



// MARK: - OrderHistoryViewController 筆記
/**
 
 ### OrderHistoryViewController 筆記

 `* What`
 
 - `OrderHistoryViewController` 是一個負責顯示歷史訂單的視圖控制器，其主要功能包括：
 
 1. 訂單顯示與操作：
 
    - 通過 `UITableView` 顯示歷史訂單列表。
    - 支援排序、編輯模式、多選刪除、滑動刪除等功能。
 
 2. 數據交互：
 
    - 與 Firebase 通訊以讀取、刪除歷史訂單資料。
 
 3. 用戶體驗：
 
    - 提供排序選單，讓用戶選擇不同的排序方式。
    - 當訂單數據為空時顯示空狀態提示視圖。
 
 4. 模組化設計：
 
    - 使用多個 Handler 和 Manager 將導航、編輯、排序等邏輯從控制器中拆分出來。

 ---

 `* Why`
 
 1. 數據驅動設計：
 
    - 確保 UI 僅在數據完全加載後更新，避免用戶看到部分或錯誤的數據。
 
 2. 模組化與責任分離：
 
    - 減少控制器的邏輯負擔，提升代碼的可讀性和可維護性。
    - 各 Handler 負責獨立的功能（如編輯模式、導航邏輯、排序選單）。
 
 3. 用戶體驗優化：
 
    - 提供靈活的操作功能，例如排序和多選刪除。
    - 當無訂單數據時顯示空狀態，提升視覺反饋的一致性。
 
 ---

 * How
 
 1. 主要元件：
 
    - `OrderHistoryView`：自定義主視圖，包含 `UITableView`。
    - `OrderHistoryManager`：負責與 Firebase 通訊處理數據。
    - `OrderHistoryHandler`：管理表格視圖的數據源與委託邏輯。
    - `OrderHistoryNavigationBarManager`：管理導航欄按鈕的狀態與切換。
    - `OrderHistoryEditingHandler`：管理編輯模式、多選與刪除操作。
    - `OrderHistorySortMenuHandler`：生成排序選單並處理用戶選擇。

 2. 初始化流程：
 
    - 在 `viewDidLoad` 中調用 `setupNavigationHandlers` 初始化各處理器，負責排序、編輯和導航欄按鈕。
    - 設定導航標題，並初始化導航欄按鈕的狀態。
    - 在頁面首次加載時，根據預設的排序方式加載歷史訂單數據。

 3. 數據加載與顯示：
 
    - 在 `viewDidLoad` 中調用 `fetchOrderHistory`，根據用戶選擇的排序方式獲取訂單資料。
    - 加載完成後，調用 `setupOrderHistoryHandler` 配置表格數據源與委託，並更新空狀態提示。

 4. 交互與處理：
 
    - 用戶點擊排序選單時，調用 `didSelectSortOption` 更新排序方式並重新加載數據。
    - 在編輯模式中，通過 `OrderHistoryEditingHandler` 支持多選刪除功能。
    - 用戶選取某筆訂單時，通過 `OrderHistoryNavigationDelegate` 導航至詳細頁面。

 5. 模組化處理：
 
    - 每個處理器負責單一功能：
 
      - 排序邏輯：`OrderHistorySortMenuHandler`
      - 編輯模式：`OrderHistoryEditingHandler`
      - 導航邏輯：`OrderHistoryNavigationBarManager`

 6. 空狀態管理：
 
    - 當訂單列表為空時，通過 `updateEmptyStateView` 顯示空狀態提示。
    - 空狀態提示在訂單資料改變時自動更新。

 ---

 `* 結論`
 
 - `OrderHistoryViewController` 結合模組化設計與數據驅動的交互邏輯，提供了高效、靈活的歷史訂單管理功能，能滿足用戶查看、排序和操作訂單的需求，並為未來擴展功能提供良好的基礎。
 */


// MARK: - OrderHistoryViewController - fetchOrderHistory 的設置位置調整（重要）
/**
 
 ## OrderHistoryViewController - fetchOrderHistory 的設置位置調整

 
 `* What`
 
 - 因為完成訂單後對於導航流程處理的特性，因此`OrderHistoryViewController`與 `FavoritesViewController` 對於資料的處裡方式不同。
 - 調整 `fetchOrderHistory` 的設置位置，將其從 `viewWillAppear` 移動到 `viewDidLoad`，以減少不必要的重複數據加載，並優化數據更新的觸發條件。
 
 - 原因：
 
    1. 在完成新增訂單後，應用會重置導航層級，返回 `MainTabBarController`，因此不會讓用戶停留在 `OrderHistoryViewController`。
    2. 基於此，不需要在 `viewWillAppear` 中依賴每次視圖顯示來重新加載數據，因為當用戶重新導航至該頁面時，`viewDidLoad` 內的數據加載邏輯已足夠確保數據的準確性。
    4. 這樣就不會有完成新增訂單的時候，還停留在`OrderHistoryViewController`，需要透過 `viewWillAppear` 來重新抓取資料。
    3. 如此調整可以避免在非必要情況下重複執行數據抓取邏輯，提升應用性能與用戶體驗。

 ------------

 `* Why`
 
 1. 導航流程的特性：
 
    - 完成訂單後， App 會自動退出當前視圖層，回到 `MainTabBarController`，因此用戶不會在完成訂單後直接回到 `OrderHistoryViewController`。
    - 只有用戶重新導航到該頁面時，才需要加載數據，這使得在 `viewWillAppear` 中加載數據顯得多餘。

 2. 歷史訂單數據的特性：
 
    - 歷史訂單數據通常為靜態，僅在用戶刪除或切換排序時需要更新。
    - 用戶無法在 `OrderHistoryDetailViewController` 修改訂單，因此從詳細頁返回時數據不會改變，無需重新加載。

 3. 用戶體驗與性能優化：
 
    - 避免在每次視圖顯示時進行重複的數據加載，減少不必要的網絡請求，提高應用性能。
    - 提供更明確的數據更新觸發條件，例如排序切換或手動刷新。

 ------------

 * How

 1. 將 `fetchOrderHistory` 移動到 `viewDidLoad`：
 
    - 在控制器首次加載時執行數據加載，確保用戶進入頁面時即可查看數據。
 
    - 修改 `viewDidLoad`：
 
      ```swift
      override func viewDidLoad() {
          super.viewDidLoad()
          setupNavigationHandlers()
          setupNavigationBar()
          configureNavigationTitle()
          fetchOrderHistory(sortOption: currentSortOption)
      }
      ```

 ---
 
 2. 保留排序邏輯的數據加載：
 
    - 當用戶在排序選單中切換選項時，仍然通過 `didSelectSortOption` 方法加載新的數據：
 
      ```swift
      func didSelectSortOption(_ sortOption: OrderHistorySortOption) {
          currentSortOption = sortOption
          fetchOrderHistory(sortOption: currentSortOption)
      }
      ```

 ---

 3. 移除 `viewWillAppear` 中的數據加載邏輯：
 
    - 簡化 `viewWillAppear`，避免重複執行數據加載：
 
      ```swift
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          // 此處不再調用 fetchOrderHistory
      }
      ```

 ---

 4. 考慮未來需求：
 
    - 若需要用戶手動刷新數據，可增加下拉刷新功能或提供一個按鈕，讓用戶自行觸發數據更新。

 ------------

 `* 結論`
 
 - 核心調整：
 
    - 將 `fetchOrderHistory` 從 `viewWillAppear` 移動到 `viewDidLoad`。
 
 - 主要優勢：
 
   - 減少不必要的數據加載，提升應用性能。
   - 保留排序邏輯的靈活性，確保用戶操作能立即反映在數據中。
   - 提供更清晰的數據加載觸發條件，提升代碼可讀性和維護性。
 */


// MARK: - OrderHistoryViewController 的「刪除功能」及 UI 設計考量重點筆記（重要）
/**
 
 ## OrderHistoryViewController 的「刪除功能」及 UI 設計考量重點筆記
 
` 1.滑動刪除的現有設計：`
 
    - 目前已經在 `OrderHistoryViewController` 中實現了「`滑動刪除`」的功能，允許用戶快速刪除單筆訂單。
 
 ----
 
` 2.navigationBar 的按鈕佈局考量：`
 
    - navigationBar 上目前已經設置了「排序」按鈕。如果再加入「編輯」或「刪除」等其他按鈕，會顯得過於擁擠且 UI 較為臃腫，增加使用者的操作負擔。
 
 ----

 `3.使用 ToolBar 來處理 UITableView 的編輯模式：`
 
    - 另一個選項是採用 `ToolBar` 來提供「多選並刪除」的功能，類似於 Mail App 的設計，使用者可以在進入編輯模式後進行多選和批量刪除操作。
    - 但是目前 `OrderHistoryViewController` 已經包含了 `TabBar`，如果再加入底部的 `ToolBar`，可能會導致畫面過於擁擠且佈局不夠清晰，尤其在小螢幕設備上使用時對體驗不友善。
    - https://reurl.cc/g69EjX （參考）
 
 ----

 `4.切換到「Full Screen」展示 OrderHistoryViewController 的考慮：`
 
    - 一個潛在的設計選擇是讓 `OrderHistoryViewController` 以「全螢幕」的方式顯示，而不是現階段的 Push Navigation，這樣就可以使用 ToolBar 來提供更多操作按鈕。
    - 然而，這樣的設計可能會讓整體的導航流程變得不一致，對於用戶從其他頁面返回的操作流暢度不夠友好。
 
 ----

 `5.結論：`
 
    - 不建議在現有的 navigationBar 中加入過多的按鈕，應保持簡潔，避免臃腫。
    - 不適合在已有 TabBar 的情況下再加入 ToolBar 來處理編輯模式，避免導致畫面過於擁擠。
    - 記錄可能的選擇：雖然可能不會採用，但這些設計選擇還是記錄下來，以備未來需求變化或功能迭代時作參考。
 */


// MARK: - TableView 編輯模式與多選刪除功能的設計重點筆記
/**
 
 ## TableView 編輯模式與多選刪除功能的設計重點筆記

 
` 1. TableView 的「編輯模式」是否適合用於多選並刪除？`
 
 - 概述：
 
    - UITableView 提供了「編輯模式」的功能，使得多選並刪除行變得更加容易。
    - 編輯模式可以允許使用者選取多個行，並在一次操作中刪除多筆資料。
 
 - 適用場景：
 
    - 當需要允許使用者在大量訂單或項目中批量刪除時，編輯模式非常合適。
    - 它提供了一種簡單且直觀的方式讓使用者選擇多個條目，然後在一次操作中進行處理。
 
 - 設計注意：
 
    - 編輯模式可以通過為 UITableView 調用 `setEditing(_:animated:) `來啟動或退出。
    - 通常會有一個「編輯」按鈕放置在 navigationBar 中，使用者點擊後進入編輯狀態。
 
 -------
 
 `2. 「滑動刪除」和「編輯模式」的共存：優劣分析`
 
 - 滑動刪除的優點：
 
    - 直觀：只需滑動單個項目即可刪除，對於刪除少量或單個條目來說非常方便。
    - 快速：不需要進入編輯模式，直接在滑動時完成刪除。
 
 - 編輯模式的優點：
 
    - 批量操作：可以選擇多個項目，同時刪除或執行其他操作。
    - 顯式操作：進入編輯模式後，操作的目標更加明確，減少誤操作的風險。
 
 - 共存考量：
 
    - 操作複雜性：同時提供滑動刪除和編輯模式可能會增加 UI 的複雜性。
    - 互補性：兩者可以同時存在但在不同情境下提供服務。滑動刪除適合快速處理單個項目，而編輯模式適合批量操作。
    - 設計建議：當啟用「編輯模式」時，可以禁用滑動刪除功能，以減少重複的功能和混淆；當退出編輯模式後，再恢復滑動刪除的功能。
 
 -------
 
 `3. 編輯模式下顯的 navigationBar 的設計考量`
 
 - navigationBar 的設計考量：
 
    - 避免臃腫：navigationBar 的空間有限，放置排序按鈕和編輯按鈕。如果再增加過多按鈕，會導致 UI 變得擁擠且操作不直觀。
    - 動態更新：在進入編輯模式時，可以隱藏排序按鈕，只顯示刪除、完成的按鈕，這樣可以避免按鈕過多帶來的混亂。
 
 */


// MARK: - OrderHistoryViewController 編輯功能與批量刪除的重點筆記（解決方式）
/**
 
 ## OrderHistoryViewController 編輯功能與批量刪除的重點筆記
 
 `* 編輯按鈕與編輯模式`
 
 `1.概述：`
 
    - 點擊「編輯按鈕」進入編輯模式，會呈現「完成按鈕」、「刪除按鈕」，以避免按鈕過多導致界面混亂，從而保持導航欄的整潔性。
 
 `2.設計目的：`
 
    - 避免導航欄過於擁擠，保持界面簡潔，提升使用者體驗。
 
 `3.功能細節：`
 
    - 初始狀態下，導航欄包含「排序按鈕」和「編輯按鈕」。
 
 `4. 當點擊「編輯按鈕」進入編輯模式後：`
 
    - 隱藏「排序按鈕」、「編輯按鈕」，顯示「完成按鈕」和「刪除按鈕」。
    - 用戶可以在「編輯模式」的表格中選擇多行進行批量刪除。
 
 `5. 當離開編輯模式後：`
 
    - 恢復「排序按鈕」和「編輯按鈕」，隱藏「完成按鈕」和「刪除按鈕」。

 ---------

 `* 實作細節：`
 
 - OrderHistoryNavigationBarManager 處理導航欄的狀態變更：
 
    - 採用`OrderHistoryNavigationBarManager`的`updateNavigationBar(for state: OrderHistoryEditingState)`，根據`OrderHistoryEditingState`的不同狀態設置導航按鈕。
   
 - 批量刪除功能：
 
 1. 概述：

    - 在進入編輯模式後，提供用戶批量選擇訂單並進行刪除的功能。
    - 為用戶提供更靈活且便捷的操作，減少逐行滑動刪除的繁瑣過程。
 
 2. 功能細節：

    - 當進入編輯模式後，表格進入可選擇狀態，用戶可以點擊多個行來選擇要刪除的訂單。
    - 確認選中項目後，點擊導航欄中的「刪除」按鈕執行批量刪除操作。
 
 3. 刪除操作的步驟：
 
    - 從 `UITableView` 中獲取選擇的行。
    - 通知 `OrderHistoryDataDelegate` 刪除本地和遠端的訂單資料。
    - 從 `UITableView` 中刪除相應的行，更新表格視圖。
 
 4. 實作細節：

 - `OrderHistoryEditingHandler` 負責管理編輯模式和批量刪除的具體操作：
 
    - `toggleEditingMode() `用於切換編輯模式。
    - `deleteSelectedRows() `處理選中的多個行，並透過 `OrderHistoryDataDelegate` 刪除相應的訂單資料。
 
 - `OrderHistoryNavigationBarManager` 在編輯模式下顯示「刪除」按鈕，並呼叫 `deleteButtonTapped() `來執行刪除操作。
 
 ---------

` * 重點設計考量`
 
 `1.分離職責：`
 
    - `OrderHistoryNavigationBarManager`：專門負責導航欄的按鈕配置與狀態更新。
    - `OrderHistoryEditingHandler`：負責管理「編輯模式」及「多選刪除操作」的邏輯。
 
 `2.批量操作設計：`

    - `批量刪除的便利性`：與逐行滑動刪除相比，批量刪除更能有效提高操作效率，特別是當用戶有多筆訂單需要同時刪除時。
    - `用戶體驗`：在進入編輯模式後，隱藏「排序按鈕」並顯示「刪除按鈕」，使界面操作更直觀和簡潔，減少了按鈕混亂的情況。
 
 */


// MARK: - 刪除按鈕的啟用狀態設計
/**
 
 ## 刪除按鈕的啟用狀態設計
 
` * What`
 
    - 當進入到「編輯模式」並選取某些項目後，「刪除按鈕」未啟用，導致用戶無法進行刪除操作。
    - 原因是導航欄按鈕的`啟用狀態`沒有根據項目的`選取狀態`即時更新。
 
 ------

 `* Why`
 
    - `didSelectRowAt` 和 `didDeselectRowAt` 這兩個方法是 `UITableViewDelegate` 的委託方法，負責處理用戶選取行的操作。
    - 但 `OrderHistoryHandler` 無法直接存取 `OrderHistoryViewController` 中的 `navigationBarManager`，因此無法通知導航欄來啟用/禁用「刪除按鈕」。
    - 這導致在用戶選取或取消選取行後，導航欄按鈕的狀態沒有更新。
 
 ------

 `* How`
 
 - 通過`OrderHistorySelectionDelegate`模式來實現按鈕狀態的更新：
 
    -  `OrderHistorySelectionDelegate` 的 `didChangeSelectionState(hasSelection: Bool)`，用來通知 `OrderHistoryViewController` 當選取狀態發生變化時進行處理。
 
    - 在 `OrderHistoryHandler` 中，於 `didSelectRowAt` 和 `didDeselectRowAt` 方法內呼叫 `handleSelectionStateChange`，將行選取狀態的變更傳遞給控制器。
 
    - 在 `OrderHistoryViewController` 中，透過 `didChangeSelectionState(hasSelection: Bool) `通知 `orderHistoryNavigationBarManager`，更新`編輯狀態`下的導航欄的按鈕狀態（特別是「刪除按鈕」）。
 
 ------
 
 `* 總結`
 
    - `didChangeSelectionState(hasSelection: Bool)` 的引入，讓導航欄在`編輯模式`下的狀態能夠及時根據用戶的選擇更新，這樣可以顯著改善用戶的操作體驗。
    - 這個方法的主要作用是保持編輯模式下導航欄按鈕的同步性，特別是「刪除」按鈕的啟用狀態。當用戶選中或取消選中行時，可以即時地反映在 UI 中。
 */


// MARK: - 關於「歷史訂單頁面」的空狀態顯示與狀態更新方式（重要）
/**
 
 ### 關於「歷史訂單頁面」的空狀態顯示與狀態更新方式

 `* What`
 
    - 在歷史訂單頁面中，如果沒有歷史訂單，使用者介面應顯示一段「無訂單項目」的提示文字，以向使用者表達目前的資料狀態。
    - 這可以讓使用者清楚理解目前沒有可用的訂單，提供更友善的使用者體驗。

 --------
 
 `* Why`
 
 `1. 在 UITableView 的 numberOfRowsInSection 中`
 
    - 起初在 `UITableView` 的 `numberOfRowsInSection` 中根據訂單的數量來動態更新是否顯示空狀態提示。
    - 但考量到 `numberOfRowsInSection` 是 `UITableViewDataSource` 的方法，其主要職責應該是返回行的數量。
    - 這個方法的核心目標是用來給 `UITableView` 提供行數，而不是去負責處理空狀態視圖的更新。
    - 因此，當這個方法被用來更新 UI 狀態時，其職責就有些模糊，這可能會讓日後維護代碼變得複雜。
 
    - 目前的實作中，`OrderHistoryHandler` 作為數據源的管理者，它負責處理表格數據的顯示和數據源的回應。
    - 然而，`numberOfRowsInSection` 被用來調用 `updateEmptyState`，這讓 `UITableViewDataSource` 的職責超出了預期，參與了界面上的視圖管理（即顯示或隱藏「無訂單項目」的視圖）。這就造成了視圖層次的混淆。
 
`2. 在多個地方重複手動呼叫 updateEmptyState，導致代碼冗餘。`（改到`OrderHistoryViewController`）
 
    - 在原始設計中，空狀態提示的更新被多次手動呼叫，如在 `handleFetchedOrders`、`deleteOrder`、`deleteOrders` 等多個函數中。
    - 這導致代碼變得冗餘，並且每次涉及訂單資料變動時都需要手動更新空狀態，增加了未來維護的複雜度與出錯的機會。
 
 --------

 `* How`
 
 `1.在 OrderHistoryView 中設置 updateEmptyState 方法：
 
    - `updateEmptyState(isEmpty:) `根據訂單是否存在來顯示或移除空狀態提示文字。
    - 例如，當訂單為空時，顯示一個 UILabel 提示「無訂單項目」，並將其設置為 `tableView` 的 `backgroundView`。

` 2.在 OrderHistoryViewController 中統一管理空狀態更新`：
 
    - 將空狀態的更新邏輯集中在 `orders` 的 `didSet` 中。這樣可以確保每次訂單資料發生變化（如新資料載入、刪除等）時，自動觸發 UI 更新，減少手動管理的步驟。
    - 這樣可以確保訂單資料一有變動就更新空狀態提示，不再需要手動管理多次更新邏輯。

 `3.減少重複代碼`：
 
    - 透過將 `updateEmptyState` 的呼叫移至 `didSet`，可以避免在多個地方（如 `handleFetchedOrders`、`deleteOrder`、`deleteOrders`）重複手動呼叫。
 
 --------

 `* 總結`
 
 1.問題：
 
    - 當沒有歷史訂單時，需要顯示「無訂單項目」的提示，且原始的實作方式在多個地方重複手動呼叫 `updateEmptyState`，導致代碼冗餘。
 
 2.解決方法：
 
    - 將 `updateEmptyState` 的呼叫統一移至 `orders` 的 `didSet`，以減少重複代碼並確保每次訂單資料改變時都能自動更新 UI。
 
 */


// MARK: - 重點筆記：在「Tab」切換與編輯模式中處理 UI 不一致問題（重要）
/**
 
 ## 重點筆記：在「Tab」切換與編輯模式中處理 UI 不一致問題
 
 
 - 主要是因為`OrderHistoryViewController`是以`push`的方式呈現，因此可以點擊`不同的Tab`切換到其他視圖層。

 - 原因：

    - 但在`OrderHistoryViewController`呈現「`編輯模式`」時，並且去切換`不同的Tab`。
    - 這樣的做法會導致位於「`UserProfileTab`上層的`OrderHistoryViewController`」會呈現`編輯模式導航欄位`的UI會有錯亂問題。
 
 - 觀察：
 
    - 後來去試用一些App，發現採用`TableViewController`蠻多都是呈現「`全畫面`」的方式來處理。
    - 觀察到`PodCast`以及`Clock`的App時，我發現這兩個App在`TableViewController`呈現「編輯模式」時，並不是「全畫面」。
    - 而是一樣維持「`push`」的方式，但是在點擊`Tab`切換視圖的時候，會離開編輯模式。
    - 考量到整體導航流程的一致性，我決定採用「維持「`push`」的方式，但是在點擊Tab切換視圖的時候，會離開編輯模式。」
 
 -------
 
 `1.背景說明：`

    - `OrderHistoryViewController` 是一個包含 `UITableView` 的視圖控制器，且`push`的導航方式會設置於 `UserProfileTab` 的最上層。
    - 用戶在 `OrderHistoryViewController` 進入編輯模式後，仍能夠點擊 Tab 切換到其他視圖控制器。
 
 -------

 `2.遇到的問題：`

    - 當 `OrderHistoryViewController` 處於`編輯模式`時，用戶切換到其他 Tab，再回到原本的 `OrderHistoryViewController` 時，導航欄仍顯示在編輯模式，導致 UI 顯示錯亂。

 -------

 `3.解決方式：`

 - `自動退出編輯模式`：
 
    - 在` viewWillDisappear(_:) `方法中，檢查是否處於編輯模式，若是則結束編輯模式，以保持界面一致。
 
 - `觀察其他App的行為`：
 
    - 試用一些其他的 App，例如 `PodCast` 和 `Clock`，發現它們在 `TableViewController` 進入編輯模式時，當用戶切換 Tab 時會自動退出編輯模式，這避免了 UI 不一致的問題。
 
 -------

 `4.最佳實踐觀察：`

    - 有些 App 在處理 `UITableViewController` 的編輯模式時，採用了「`全畫面顯示`」的方式來避免混淆和誤操作。
    - 其他如 PodCast 和 Clock，則保持 push 的導航方式，但透過在用戶切換 Tab 時自動退出編輯模式來確保 UI 一致性。
 
 -------

 `5.實作方式：`

  - 在` viewWillDisappear(_:) `方法中，檢查是否目前處於編輯模式，若是，則呼叫對應方法退出編輯模式。
  - 同時調用 `orderHistoryNavigationBarManager?.updateNavigationBar(for: newState)`，確保導航欄回到初始狀態。
 
 -------

 `6.結論：`
 
 -  在 viewWillDisappear(_:) 中設置退出編輯模式是一個適當的做法：
 
    -  `自動化退出編輯`：用戶在離開 OrderHistoryViewController 時，編輯模式會自動結束，避免進入其他視圖時依然處於編輯狀態，防止 UI 錯亂。
    -  `維持 UI 一致性`：確保在不同視圖之間切換時，界面保持一致，不會出現編輯模式誤開啟的情況。
    -  `職責劃分適當`：將退出編輯模式的邏輯設置在 viewWillDisappear(_:) 中，而不交由 Manager 或 Handler 處理，是合理的設計。因為編輯狀態與視圖控制器的顯示狀態直接相關，應由 ViewController 本身來管理。
 */



// MARK: - (v)

import UIKit

/// `OrderHistoryViewController`
///
/// 負責顯示歷史訂單的列表，並提供與訂單數據的交互功能。
///
/// ### 功能概述
/// - 訂單顯示與操作
///   - 通過表格視圖展示訂單列表，支持排序、編輯、多選刪除、滑動刪除等操作。
///   - 與 Firebase 通訊以獲取、刪除和更新訂單資料。
/// - 用戶體驗
///   - 提供排序選單、導航邏輯和編輯模式切換功能，增強用戶操作的便捷性。
///   - 當數據為空時顯示空狀態提示，確保用戶了解當前情況。
/// - 模組化設計
///   - 採用多個處理器（Handler 和 Manager）分離數據管理、導航、排序和編輯邏輯，提升代碼的可讀性和可維護性。
///
/// ### 設計目標
/// - 數據驅動
///   - 確保 UI 與數據狀態保持同步，避免用戶看到不完整的畫面或錯誤數據。
/// - 模組化
///   - 通過獨立的處理器來處理特定功能，減少控制器的邏輯負擔。
/// - 可擴展性
///   - 支持未來的功能擴展，如添加新排序選項、修改導航行為等。
class OrderHistoryViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 負責與 Firebase 交互的訂單資料管理器
    private let orderHistoryManager = OrderHistoryManager()
    
    /// 自定義視圖，包含顯示訂單的表格視圖
    private let orderHistoryView = OrderHistoryView()
    
    /// 負責處理表格視圖數據源與交互邏輯
    private var orderHistoryHandler: OrderHistoryHandler?
    
    /// 導航欄按鈕的管理器
    private var orderHistoryNavigationBarManager: OrderHistoryNavigationBarManager?
    
    /// 編輯模式的處理器，負責管理多選與刪除功能
    private var orderHistoryEditingHandler: OrderHistoryEditingHandler?
    
    /// 排序選單處理器，負責生成排序選單
    private var orderHistorySortMenuHandler: OrderHistorySortMenuHandler?
    
    /// 當前的排序選項，預設為「按日期由新到舊」
    private var currentSortOption: OrderHistorySortOption = .byDateDescending
    
    /// 保存從 Firebase 獲取的訂單資料
    ///
    /// - 當訂單資料更新時，更新導航欄按鈕狀態與空狀態視圖
    private var orders: [OrderHistory] = [] {
        didSet {
            setupNavigationBar()
            updateEmptyStateView()
        }
    }
    
    // MARK: - Lifecycle Methods
    
    /// 設置主視圖
    override func loadView() {
        view = orderHistoryView
    }
    
    /// 當視圖加載完成時，初始化導航邏輯與相關處理器
    ///
    /// - 說明：
    ///    - setupNavigationHandlers：初始化排序、編輯和導航欄處理器。
    ///    - setupNavigationBar：設置導航欄按鈕（初始化按鈕狀態）
    ///    - configureNavigationTitle：設定大標題 (初始化)
    ///    - fetchOrderHistory：在頁面首次加載時，根據預設的排序方式加載歷史訂單數據。
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationHandlers()
        setupNavigationBar()
        configureNavigationTitle()
        fetchOrderHistory(sortOption: currentSortOption)
    }
    
    /// 當視圖即將消失時，退出編輯模式並重置導航欄按鈕
    ///
    /// - 說明：
    ///     - 如果當前處於編輯模式，則退出編輯模式，並重置導航欄按鈕至初始狀態。
    ///
    /// - 目的：
    ///     - 避免在用戶切換到其他視圖時仍保持在編輯模式，確保狀態一致性。
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let editingHandler = orderHistoryEditingHandler, editingHandler.isTableEditing else { return }
        let newState = editingHandler.toggleEditingMode()
        orderHistoryNavigationBarManager?.updateNavigationBar(for: newState)
    }
    
    // MARK: - Data Management
    
    /// 從 Firebase 獲取歷史訂單資料
    ///
    /// - Parameter sortOption: 用戶選擇的排序方式
    private func fetchOrderHistory(sortOption: OrderHistorySortOption) {
        
        HUDManager.shared.showLoading(text: "History...")

        Task {
            do {
                let fetchedOrders = try await orderHistoryManager.fetchOrderHistory(sortOption: sortOption)
                print("[OrderHistoryViewController]: Fetched Orders: \(fetchedOrders)")
                self.orders = fetchedOrders
                setupOrderHistoryHandler()
            } catch {
                print("[OrderHistoryViewController]: Failed to fetch orders: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: "Failed to fetch orders: \(error.localizedDescription)", inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Order History Setup
    
    /// 初始化並設置 `OrderHistoryHandler`，配置表格視圖的數據源和委託
    ///
    /// - 功能：
    ///   - 該方法負責初始化 `OrderHistoryHandler` 實例，並將其設置為表格視圖的數據源和委託。
    ///   - 使表格視圖能正確顯示歷史訂單資料，並處理相關用戶交互（如行選取、刪除和導航等）。
    ///
    /// - 背景：
    ///   - 該方法在訂單資料成功加載後調用，確保 `OrderHistoryHandler` 在獲得完整數據後進行配置。
    ///   - 避免表格視圖在數據未準備好時進行更新，導致顯示異常。
    ///
    /// - 處理邏輯：
    ///   1. 初始化 `OrderHistoryHandler`，並傳遞三個代理以處理數據、選取狀態和導航邏輯：
    ///      - `orderHistoryDataDelegate`: 提供訂單數據。
    ///      - `orderHistorySelectionDelegate`: 處理選取狀態變更（例如刪除按鈕狀態更新）。
    ///      - `orderHistoryNavigationDelegate`: 處理行選取時的導航邏輯。
    ///   2. 設置表格視圖的數據源 (`dataSource`) 和委託 (`delegate`)。
    ///   3. 調用 `reloadData()` 確保表格視圖立即更新以顯示最新數據。
    ///
    /// - 使用場景：
    ///   - 該方法適用於訂單資料
    private func setupOrderHistoryHandler() {
        let handler = OrderHistoryHandler(
            orderHistoryDataDelegate: self,
            orderHistorySelectionDelegate: self,
            orderHistoryNavigationDelegate: self
        )
        self.orderHistoryHandler = handler
        orderHistoryView.orderHistoryTableView.dataSource = handler
        orderHistoryView.orderHistoryTableView.delegate = handler
        orderHistoryView.orderHistoryTableView.reloadData()
    }
    
    // MARK: - Navigation Handler Setup
    
    /// 設置排序選單、編輯模式、導航欄管理器等的處理器
    ///
    /// - 功能：
    ///   - 負責初始化與導航相關的處理器，包括排序選單、編輯模式和導航欄管理器。
    ///
    /// - 處理邏輯：
    ///   1. 初始化編輯模式的處理器，用於管理表格的編輯和多選邏輯。
    ///   2. 初始化排序選單的處理器，用於提供排序選單的選項和回調。
    ///   3. 初始化導航欄管理器，用於動態更新導航欄按鈕和狀態。
    private func setupNavigationHandlers() {
        setupEditingHandler()
        setupSortMenuHandler()
        setupNavigationBarManager()
    }
    
    // MARK: - Editing Handler Setup
    
    /// 初始化編輯模式處理器 (`OrderHistoryEditingHandler`)
    ///
    /// - 功能：
    ///   - 負責管理表格視圖的編輯模式，包括切換編輯狀態和多選刪除功能。
    ///
    /// - 處理邏輯：
    ///   1. 傳遞表格視圖作為參數，使處理器能夠直接操作表格的編輯狀態。
    ///   2. 傳遞符合 `OrderHistoryDataDelegate` 協議的代理，用於處理數據刪除操作。
    private func setupEditingHandler() {
        let tableView = orderHistoryView.orderHistoryTableView
        orderHistoryEditingHandler = OrderHistoryEditingHandler(tableView: tableView, orderHistoryDataDelegate: self)
    }
    
    // MARK: - Sort Menu Handler Setup
    
    /// 初始化排序選單處理器 (`OrderHistorySortMenuHandler`)
    ///
    /// - 功能：
    ///   - 負責生成排序選單，並通過代理回傳用戶選擇的排序選項。
    ///
    /// - 處理邏輯：
    ///   1. 傳遞符合 `OrderHistorySortMenuDelegate` 協議的代理，用於接收用戶的排序選擇。
    ///   2. 提供方法生成包含多個排序選項的下拉選單。
    private func setupSortMenuHandler() {
        orderHistorySortMenuHandler = OrderHistorySortMenuHandler(orderHistorySortMenuDelegate: self)
    }
    
    // MARK: - Navigation Bar Manager Setup
    
    /// 初始化導航欄管理器 (`OrderHistoryNavigationBarManager`)
    ///
    /// - 功能：
    ///   - 負責管理導航欄的按鈕配置與狀態更新，根據當前模式（例如編輯模式）動態切換按鈕。
    ///
    /// - 背景：
    ///   - 將導航欄相關的邏輯抽離至 `OrderHistoryNavigationBarManager`，減少控制器代碼的負擔。
    ///   - 增強導航邏輯的可維護性和模組化。
    ///
    /// -*處理邏輯：
    ///   1. 檢查依賴是否已正確初始化（如 `OrderHistoryEditingHandler` 和 `OrderHistorySortMenuHandler`）。
    ///   2. 傳遞導航欄按鈕需要的依賴，例如 `UINavigationItem` 和處理器。
    ///   3. 初始化後，導航欄按鈕可根據狀態動態更新（如切換排序或編輯按鈕）。
    private func setupNavigationBarManager() {
        guard let editingHandler = orderHistoryEditingHandler,
              let sortMenuHandler = orderHistorySortMenuHandler,
              let navigationController = navigationController else {
            return
        }
        
        orderHistoryNavigationBarManager = OrderHistoryNavigationBarManager(
            navigationItem: navigationItem,
            navigationController: navigationController,
            orderHistoryEditingHandler: editingHandler,
            orderHistorySortMenuHandler: sortMenuHandler
        )
    }
    
    // MARK: - Navigation Setup
    
    /// 設置導航欄上的按鈕
    ///
    /// - 說明：
    ///    - 此方法負責初始化導航欄按鈕的狀態，通常在訂單資料加載完成後調用。
    ///    - 包含「排序」和「編輯」按鈕的初始設置，適合非編輯模式下的情境。
    ///    - 在每次訂單資料 (`orders`) 更新後，都會調用此方法以確保導航欄按鈕的狀態符合當前訂單情況。
    private func setupNavigationBar() {
        orderHistoryNavigationBarManager?.updateNavigationBar(for: .normal)
    }
    
    /// 設定大標題及顯示模式
    private func configureNavigationTitle() {
        orderHistoryNavigationBarManager?.configureNavigationBarTitle(title: "Order History")
    }
    
    // MARK: - Empty State Management
    
    /// 更新空狀態視圖的顯示
    ///
    /// - 說明：
    ///    - 當訂單資料改變後，根據當前訂單是否為空來顯示或隱藏空狀態提示視圖。
    ///    - 如果 orders 為空，則顯示「無訂單項目」的提示文字，提示使用者目前沒有任何歷史訂單。
    ///    - 否則移除提示文字以顯示訂單列表。
    private func updateEmptyStateView() {
        orderHistoryView.updateEmptyState(isEmpty: orders.isEmpty)
    }
    
}


// MARK: - OrderHistoryDataDelegate
extension OrderHistoryViewController: OrderHistoryDataDelegate {
    
    /// 返回訂單資料
    ///
    /// - 說明：
    ///    - 用於讓 `OrderHistoryHandler` 獲取需要顯示的訂單資料
    func getOrders() -> [OrderHistory] {
        return orders
    }
    
    /// 刪除指定索引的訂單
    ///
    /// - Parameter index: 要刪除的訂單在 `orders` 陣列中的索引位置
    ///
    /// - 說明：
    ///    - 從 `orders` 中移除訂單，並呼叫 `OrderHistoryManager` 刪除 Firebase 中的資料
    func deleteOrder(at index: Int) {
        let orderId = orders[index].id
        orders.remove(at: index)
        
        Task {
            do {
                try await orderHistoryManager.deleteOrder(orderId: orderId)
                print("[OrderHistoryViewController]: Order deleted successfully: \(orderId)")
            } catch {
                print("[OrderHistoryViewController]: Failed to delete order: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: "Failed to delete order: \(error.localizedDescription)", inViewController: self)
            }
        }
    }
    
    /// 刪除指定的多筆訂單
    ///
    /// - Parameter indices: 要刪除的訂單在陣列中的索引列表
    ///
    /// - 說明：
    ///    - 從 `orders` 中移除多筆訂單，並呼叫 `OrderHistoryManager` 刪除 Firebase 中的資料
    func deleteOrders(at indices: [Int]) {
        let orderIdsToDelete = indices.map { orders[$0].id }
        orders.removeAll { orderIdsToDelete.contains($0.id) }
        
        Task {
            do {
                try await orderHistoryManager.deleteMultipleOrders(orderIds: orderIdsToDelete)
                print("[OrderHistoryViewController]: Orders deleted successfully")
            } catch {
                print("[OrderHistoryViewController]: Failed to delete orders: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: "Failed to delete orders: \(error.localizedDescription)", inViewController: self)
            }
        }
    }
    
}


// MARK: - OrderHistorySortMenuDelegate
extension OrderHistoryViewController: OrderHistorySortMenuDelegate {
    
    /// 當使用者選擇排序選項後執行的方法
    ///
    /// - Parameter sortOption: 選擇的排序選項
    ///
    /// - 說明：
    ///    - 更新當前的排序選項，並重新獲取訂單資料以反映選擇
    func didSelectSortOption(_ sortOption: OrderHistorySortOption) {
        currentSortOption = sortOption
        fetchOrderHistory(sortOption: currentSortOption)
    }
    
}


// MARK: - OrderHistorySelectionDelegate
extension OrderHistoryViewController: OrderHistorySelectionDelegate {
    
    /// 更新導航欄的按鈕狀態
    ///
    /// - 說明：
    ///    - 當表格中行的選取狀態改變時，通知 `orderHistoryNavigationBarManager` 更新導航欄的按鈕狀態（如「刪除」按鈕的啟用狀態）
    func didChangeSelectionState(hasSelection: Bool) {
        orderHistoryNavigationBarManager?.updateNavigationBar(for: .editing(hasSelection: hasSelection))
    }
    
}

// MARK: - OrderHistoryNavigationDelegate
extension OrderHistoryViewController: OrderHistoryNavigationDelegate {
    
    /// 導航至指定的歷史訂單詳細頁面
    ///
    /// - Parameter order: 要查看詳細的歷史訂單資料
    ///
    /// - 說明：
    ///    - 負責在用戶點選特定歷史訂單時，導航至該歷史訂單的詳細資訊頁面。
    ///
    /// - 主要目的：
    ///    - 提供用戶查看歷史訂單的詳細資訊，並確保詳細頁面可以正確顯示特定訂單的資料。
    func navigateToOrderHistoryDetail(with order: OrderHistory) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.orderHistoryDetailViewController) as? OrderHistoryDetailViewController else { return }
        detailVC.orderId = order.id
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
