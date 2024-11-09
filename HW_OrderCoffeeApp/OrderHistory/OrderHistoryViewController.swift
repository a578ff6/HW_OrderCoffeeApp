//
//  OrderHistoryViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//

/*
 使用tableView顯示歷史訂單，現階段讓 OrderHistoryViewController 專注在該使用者的總訂單orders的呈現，後續再考慮是否要在設置點擊OrderHistoryViewController會進入到下一個視圖控制器呈現該訂單的細部資訊。
 
 1.tableView的部分會呈現可以滑動刪除，以及後續會提供一個按鈕是清空該使用者的order。
 2.總訂單會依照時間日期做排序。
 3.tableView中沒有訂單的話，會呈現「無歷史訂單」
 */


// MARK: - OrderHistoryViewController 初步構想
/**
## OrderHistoryViewController 初步構想
 
`1. TableView 顯示歷史訂單`
 
 `* 滑動刪除功能：`
   - 在刪除訂單時，顯示一個確認對話框，防止用戶不小心刪除訂單。
   - 如果刪除是從 Firebase 中移除訂單，確保刪除過程有適當的錯誤處理，以防出現網路問題導致刪除失敗。

` * 清空按鈕：`
   - 清空所有訂單是一個高風險操作，顯示確認對話框來防止誤操作，例如「確定要清空所有訂單嗎？這個操作無法復原」。
   - 清空操作時，如果訂單數量比較多，可能需要顯示一個活動指示器（loading indicator），告知用戶清空過程正在進行中。
    
 `* 批量刪除：`
    - UITableView` 提供了一個內建的「編輯模式」（`Edit Mode`），在這個模式下，用戶可以選擇多個行（rows），並對其進行批量刪除操作。

 `2. 訂單依照日期排序`（`可考慮提供多種排序`）
    - 總訂單排序可以按 `timestamp` 降序排列（從最新到最舊），這樣可以確保用戶能最先看到最近的訂單。
    - 如果未來可能擴展為允許用戶按照其他方式排序（例如金額大小、取件方式等），可以事先在資料模型中保留擴展的可能性。

 `3. 無訂單顯示`
 
 `* 當沒有歷史訂單時，顯示「無歷史訂單」的做法。`
   - 可以考慮加上一些引導，例如「目前沒有歷史訂單，趕快來下一筆訂單吧！」，這樣可以更好地引導用戶使用 App。
   - 可以添加一些圖片或 icon 來增強「無訂單」狀態的視覺效果，使其看起來更有趣或富有親和力。

` ### 其他補充想法`
 
 `1. 進一步的細部資訊視圖：`
    - 目前專注於顯示總訂單是合理的，後續可以考慮在點擊某個訂單後跳轉到詳細資訊頁面，這樣可以提供更完整的訂單資訊，例如飲品項目、備註、取件方式等。
    - 可以在 `OrderHistoryViewController` 中使用 `didSelectRowAt` 方法來處理點擊事件，將用戶導航到詳細資訊的 `OrderHistoryDetailViewController`。

` 2. 資料加載與顯示：`
    - 如果訂單數量很多，可以考慮分頁加載資料（`pagination`），以減少一次性加載大量資料對 UI 和使用者體驗的影響。
    - 當訂單數據正在加載時，可以顯示一個 `loading indicator`，讓用戶知道數據正在載入，避免等待過程中的不確定性。

 `3. UI/UX 提升：`
    - 為訂單列表中的每個訂單提供一些關鍵摘要訊息，例如訂單金額、取件方式、飲品名稱等，讓用戶可以在未點擊的情況下快速了解訂單的核心內容。
    - 可以為每個歷史訂單項目增加一個 icon，根據取件方式顯示不同的圖標，讓用戶更直觀地知道該訂單是宅配還是到店取件。

 `小結`
    - 先專注於實現核心功能（例如訂單顯示、刪除、清空等），後續再逐步優化和擴展。
 */


// MARK: - UITableView vs UICollectionView 場景選擇
/**
 ## UITableView vs UICollectionView 場景選擇
 
 `1. 多種排序方式的實現`
 
 `* UITableView vs UICollectionView:`
   - `UITableView` 和 `UICollectionView` 在排序上其實沒有太大的差異，因為排序的邏輯大部分是在資料層處理（例如重新排列數組並重新加載視圖），兩者的視圖更新流程也相似。
   - `UITableView` 更傳統地用於線性、單欄垂直滾動的數據展示，特別適合於顯示列表形式的歷史訂單。
   - `UICollectionView` 則更靈活，尤其是當你需要做網格布局或是其他非線性排列的時候，它的可配置性更強。
   - 如果未來的需求只是簡單的排序（例如按日期、金額大小等），`UITableView` 已經足夠應付這些場景。如果考慮到未來可能有更複雜的視圖布局需求，例如以卡片形式展示訂單、分段顯示不同狀態的訂單（如進行中、已完成），那麼 UICollectionView 會更靈活。

 `2. 多選刪除功能的實現`
 
 `* 多選刪除場景的便利性：`
   - `UITableView` 提供了一個內建的「編輯模式」（`Edit Mode`），在這個模式下，用戶可以選擇多個行（rows），並對其進行批量刪除操作。
   - 這使得實現多選刪除非常方便，尤其在歷史訂單列表中，可以輕鬆地啟動編輯模式，顯示刪除按鈕。
   - `UICollectionView` 本身並不內建類似的編輯模式，因此你需要自行設計多選功能的 UI 和邏輯，這可能需要額外的工作，例如在選擇訂單時改變背景顏色或顯示一個勾選圖示。
   - 如果只是單純希望用戶可以選擇多個訂單並進行刪除，`UITableView` 會更簡單和快捷；如果視覺效果和交互設計上希望更有創意，`UICollectionView` 提供了更多自由度。

` ### 總結`
 - `UITableView` 更加簡單且足夠應付你當前提到的需求，包括訂單的排序和多選刪除的實現。特別是已經提到的歷史訂單功能是基於「列表」的概念，UITableView 更符合這種垂直結構的呈現。
 - `UICollectionView` 如果未來可能有更複雜的布局需求，或需要更高的自定義自由度，那麼可以考慮轉換到 `UICollectionView`。

 如果目標是快速實現功能並保持代碼簡單，先使用 UITableView，然後在需要更多的視圖靈活性時再考慮使用 UICollectionView。
 */


// MARK: - Firebase 登入與歷史訂單查詢指南
/**
 ### Firebase 登入與歷史訂單查詢指南

 `1. Firebase 登入與訂單查詢`
    - 使用 `Firebase Authentication` 提供的登入功能，取得當前登入的使用者資訊。
    - 透過 `Auth.auth().currentUser` 獲取已登入使用者的 `uid`，作為查詢歷史訂單的依據。

 `2. 為何這樣做：`
 
    `* 唯一標識符 uid：`
      - 每個 Firebase 使用者都有一個唯一的 `uid`，可用來區分使用者，確保查詢 Firestore 訂單時只取得當前登入使用者的資料。
    
    `* 避免未登入的狀態：`
      - 通過 `Auth.auth().currentUser`，確保只有在已登入的情況下進行訂單資料查詢，未登入則進行相應的處理。
 
    `- 提高資料安全性：`
      - 透過 `uid` 來查詢訂單集合，可以避免用戶誤讀或修改其他用戶的資料，確保每個用戶只能管理自己的訂單。

` 3. Firestore 中的數據結構：`
    
    `* 數據結構設計：`
    
    users (collection)
    └── {userId} (document)
          └── orders (subcollection)
              └── {orderId} (document)
    
   ` * 使用目前使用者的 `uid` 查詢其下的 `orders` 子集合，能精準定位該使用者的所有訂單。`
        - db.collection("users").document(userId).collection("orders").getDocuments()

 `4. 小結`
    - 利用 Firebase 的帳號登入功能，確保取得的訂單數據是屬於當前登入使用者的。
    - 使用 `Auth.auth().currentUser` 來取得使用者的 `uid`，並作為查詢依據，增強資料的安全性與精確性。
    - 只顯示與當前使用者相關的資料，有效防止用戶之間的資料誤取，提供安全的使用體驗。
 */

// MARK: - OrderHistoryViewController 重點筆記
/**
 ## OrderHistoryViewController 重點筆記

 `* 概述`
 
    - `功能`：負責顯示使用者的歷史訂單資料，並透過 Firebase 與資料庫進行通訊。
    - `資料驅動方式`：採用資料驅動配置方式，確保 UI 在資料完全加載後再進行顯示，提升使用者體驗和顯示準確性。
    - `滑動刪除與多選刪除`：支持滑動刪除以及在編輯模式下的多選刪除功能，確保本地 UI 和 Firebase 資料庫同步更新。
    - `訂單排序選項`：提供多種訂單排序方式，讓使用者能依據不同的需求對訂單進行排序。

 `* 結構`
 
 `1. Properties：`
    - `orderHistoryManager`：訂單資料管理器，負責與 Firebase 互動。
    - `orderHistoryView`：自定義的視圖，內含 UITableView 用於顯示訂單。
    - `orderHistoryHandler`：表格視圖的數據和委託處理器，負責管理表格數據和行為。
    -  `editingHandler`：專門管理編輯模式和多選刪除的處理器。
    -  `sortMenuHandler`：負責管理排序選單。
    -  `navigationBarManager`：管理導航欄的按鈕配置和狀態變化。
    - `orders`：從 Firebase 獲取的歷史訂單資料，並根據數據的變化自動更新導航欄按鈕的狀態。
 
` 2.Lifecycle Methods：`
    - `loadView()：`設置自定義的主視圖 (orderHistoryView)。
    - `viewDidLoad()`：設置相關處理器（例如排序、編輯、導航欄），並在視圖加載後調用 `fetchOrderHistory()` 來開始獲取資料。

 `3. Navigation Bar Setup：`
     - `setupNavigationBar()：`使用 `navigationBarManager` 來設置導航欄按鈕，包括排序和編輯按鈕。
     - 在 `viewDidLoad()` 中初次設置導航欄，並在 `orders` 更新時重新設置導航欄，以根據訂單數據動態更新編輯按鈕的狀態。`（雖然我是採用資料驅動UI）`
 
 `4. Fetch Order History：`
     - `fetchOrderHistory(sortOption:)`：非同步方法，用於從 Firebase 獲取當前使用者的訂單資料，並根據選擇的排序方式進行排序。
     - 當獲取資料成功時，將資料傳遞給 `handleFetchedOrders(_:)` 進行後續處理。
 
 `5.Setup Methods：`
    - `handleFetchedOrders(_:)：`處理從 Firebase 獲取的訂單資料，儲存在 orders 中，並初始化 OrderHistoryHandler。
    - `setupHandlers()`：設置排序選單、編輯模式和導航欄管理器，將不同的職責分配給專門的處理器類別。
    - `setupOrderHistoryHandler()：`
        - 初始化 `OrderHistoryHandler`，並將 delegate 設置為當前控制器，從而可以提供訂單資料。
        - 設置表格視圖的數據源 (dataSource) 和委託 (delegate) 為 OrderHistoryHandler。
        - 在設置完成後重新載入表格數據。
 
 `6.Navigation Bar State Management：`
    - 每次更新 `orders` 時，自動通過 `didSet` 調用 `setupNavigationBar()` 方法，以根據當前訂單數量設置編輯按鈕的狀態。
    - 當沒有訂單時，編輯按鈕處於禁用狀態，確保在無可編輯內容時，使用者無法進入編輯模式。
    - 在 `viewDidLoad()` 中初次設置導航欄按鈕，確保在首次進入視圖時按鈕狀態正確。
 
 `7.OrderHistoryDelegate：`
    - `getOrders()`：此方法實作了 OrderHistoryDelegate 協定，用於提供訂單資料給 OrderHistoryHandler，讓它能取得需要顯示的訂單。
    - `deleteOrder(at:)`：當使用者滑動刪除訂單時，從本地 `orders` 中移除訂單，並呼叫 `OrderHistoryManager` 刪除 `Firebase` 中的資料，確保資料同步性。
 
 `8.OrderHistorySortMenuDelegate：`
    - `didSelectSortOption(_:)`：用於響應使用者選擇排序選項的操作，重新獲取並顯示訂單資料。
 */


// MARK: - 重點筆記：實現滑動刪除功能的步驟與設計
/**
 ## 重點筆記：實現滑動刪除功能的步驟與設計

 `1. 擴展 OrderHistoryHandler 支持滑動刪除`
    - 在 `OrderHistoryHandler` 中擴展 UITableViewDelegate，並實作 `tableView(_:commit:forRowAt:) `方法來支援滑動刪除功能。
    - 使用 `UITableViewCell.EditingStyle.delete` 判斷是否是刪除操作。
    - 通過 `delegate` 通知控制器去刪除對應的訂單資料。
 
 `2. 擴展 OrderHistoryDelegate 添加刪除訂單的方法`
    - 在 `OrderHistoryDelegate` 中新增 `deleteOrder(at:) `方法，讓 `OrderHistoryHandler` 可以通知控制器去刪除訂單。
    - 此方法用於管理訂單資料的刪除，包括更新本地的訂單陣列和通知 Firebase。

 `3. 實作刪除邏輯 (OrderHistoryViewController)`
    - 當 `OrderHistoryHandler` 通知刪除請求時，`OrderHistoryViewController` 中負責刪除訂單的資料。
    - 先更新本地存儲的 `orders` 陣列，然後非同步地從 `Firebase` 中刪除對應的訂單資料。
    - 使用 Firebase 提供的非同步 API 確保刪除資料的成功。
 
 `4. 設計概述`
 
 `* 資料同步：`
    - 滑動刪除訂單時，首先從本地陣列中刪除相應資料，然後非同步刪除 Firebase 中的資料，確保資料同步性。
 
 `* 分離關心點：`
    - `OrderHistoryHandler` 負責表格視圖的數據顯示及操作邏輯（如刪除）。
    - `OrderHistoryViewController` 負責數據的管理，包括與 Firebase 的互動和處理刪除的邏輯。
 
 `* 使用委託 (Delegate) 進行溝通：`
    - 利用 `OrderHistoryDelegate` 協議來將數據處理與 UI 操作分離，減少耦合性，使代碼更具可維護性和可擴展性。
 */


// MARK: - 訂單排序選項及 UI 設計重點筆記
/**
 ## 訂單排序選項及 UI 設計重點筆記

 `## 如何實作「訂單排序選項」`

 `* 訂單排序選項的實作概述`
    - 在 `OrderHistoryViewController` 中，透過代理 (`OrderHistorySortMenuDelegate`) 與 `OrderHistorySortMenuHandler` 配合，以提供使用者不同排序的功能。
    - 排序選項包括依據時間、金額及取件方式等進行排序，且使用下拉菜單來進行選擇。

 `* 具體實作步驟`
 
 `1.設置導航欄上的排序按鈕：`
    - 在 `viewDidLoad()` 中設置導航欄的排序按鈕 (sortButton)，但邏輯已提取到 `OrderHistorySortMenuHandler` 中進行管理。
 
 `2.使用 OrderHistorySortMenuHandler 創建排序選項菜單：`
    - 透過 `OrderHistorySortMenuHandler` 創建排序選項菜單 (`createSortMenu()`)，並將 `OrderHistorySortMenuDelegate` 傳入，確保當使用者選擇選項後，能通知到 `OrderHistoryViewController`。
    - 排序選單中的每個 `UIAction` 在被選擇後，透過代理呼叫 `didSelectSortOption(_:)` 方法，通知 `ViewController` 執行相應的排序。

 `3.獲取排序後的訂單資料 (fetchOrderHistory(sortOption:))：`
    - 根據選定的排序方式，通過 `OrderHistoryManager` 從 Firebase 異步獲取歷史訂單，並進行相應的排序。
    - 使用 `Task` 非同步處理，確保使用者在資料獲取期間不會卡住 UI。
 */


// MARK: - UI 設計方式的選擇（重要）
/**
 `##多種 UI 設計方式的選擇分析`
 
    - 因為一開始我使用 UIAlertAction，雖然效果也不錯，但想說測試一些沒嘗試過的功能。
    - https://reurl.cc/kym91x 參考來源
    - 在設計訂單的排序選項時，有多種 UI 呈現方式可以考慮。

` 1.Pull Down Button（iOS 14+）：`

 `* 優點：`
    - 可以直接集成在 `navigationBar` 的按鈕上。
    - 以下拉菜單的形式顯示選項，方便且不影響主畫面視覺。
    - 提供了一種現代且符合 iOS 設計規範的方式，減少多餘的操作。
 
 `* 適用場景：`
    - 當需要在不跳出額外視窗的情況下，快速為使用者提供多種選擇時，Pull Down Button 是非常合適的。
 
` 2.UIAlertController 形式的 Alert 選單：`

 `* 優點：`
    - 當希望以彈窗的形式強調選擇時，UIAlertController 是一個好的選擇。
    - 提供更靈活的內容配置（例如標題和描述的詳細解釋）。
 
 `* 缺點：`
    - 需要額外的點擊來彈出和選擇，操作步驟比 Pull Down Button 多。
 
 `* 適用場景：`
    - 適合當需要給使用者更多額外的說明或需要強調選擇的重要性時。
 
 `3.Toolbar 或 Segmented Control：`

 `* 優點：`
    - Toolbar 可以固定在螢幕底部，適合在頁面上需要多個操作選項時。
    - Segmented Control 可以讓使用者直接在視圖頂部做出選擇，且不需要額外的彈窗。
 
 `* 缺點`：
    - Toolbar 的佔用空間較大，Segmented Control 選項有限，適合少數幾個選擇的情境。
 
 `* 適用場景：`
    - Toolbar 適合當頁面需要多個固定操作選項（例如：新增、刪除、編輯等）。
    - Segmented Control 適合當選項非常少（例如兩三個），並且不希望用戶跳出當前操作。
 
 `4.為何選擇「Pull Down Button」`
    - `符合設計趨勢`：在 iOS 14 引入之後，Pull Down Button 成為一種推薦的標準做法，特別是處理工具或導航功能。
    - `無縫的操作體驗`：與用戶習慣的 navigationBar 完全融合，減少了使用者選擇時的認知負擔。
    - `直觀且省步驟`：點擊後直接顯示選項，並且選擇之後不會跳轉或彈出其他窗口，讓操作顯得更加簡單流暢。
 */


// MARK: - OrderHistoryViewController 的「刪除功能」及 UI 設計考量重點筆記（重要）
/**
` 1.滑動刪除的現有設計：`
    - 目前已經在 `OrderHistoryViewController` 中實現了「`滑動刪除`」的功能，允許用戶快速刪除單筆訂單。
 
` 2.navigationBar 的按鈕佈局考量：`
    - navigationBar 上目前已經設置了「排序」按鈕。如果再加入「編輯」或「刪除」等其他按鈕，會顯得過於擁擠且 UI 較為臃腫，增加使用者的操作負擔。
 
 `3.使用 ToolBar 來處理 UITableView 的編輯模式：`
    - 另一個選項是採用 `ToolBar` 來提供「多選並刪除」的功能，類似於 Mail App 的設計，使用者可以在進入編輯模式後進行多選和批量刪除操作。
    - 但是目前 `OrderHistoryViewController` 已經包含了 `TabBar`，如果再加入底部的 `ToolBar`，可能會導致畫面過於擁擠且佈局不夠清晰，尤其在小螢幕設備上使用時對體驗不友善。
    - https://reurl.cc/g69EjX （參考）
 
 `4.切換到「Full Screen」展示 OrderHistoryViewController 的考慮：`
    - 一個潛在的設計選擇是讓 `OrderHistoryViewController` 以「全螢幕」的方式顯示，而不是現階段的 Push Navigation，這樣就可以使用 ToolBar 來提供更多操作按鈕。
    - 然而，這樣的設計可能會讓整體的導航流程變得不一致，對於用戶從其他頁面返回的操作流暢度不夠友好。
 
 `5.結論：`
    - 不建議在現有的 navigationBar 中加入過多的按鈕，應保持簡潔，避免臃腫。
    - 不適合在已有 TabBar 的情況下再加入 ToolBar 來處理編輯模式，避免導致畫面過於擁擠。
    - 記錄可能的選擇：雖然可能不會採用，但這些設計選擇還是記錄下來，以備未來需求變化或功能迭代時作參考。
 */


// MARK: - TableView 編輯模式與多選刪除功能的設計重點筆記
/**
 ## TableView 編輯模式與多選刪除功能的設計重點筆記

` 1. TableView 的「編輯模式」是否適合用於多選並刪除？`
 
 `* 概述：`
    - UITableView 提供了「編輯模式」的功能，使得多選並刪除行變得更加容易。
    - 編輯模式可以允許使用者選取多個行，並在一次操作中刪除多筆資料。
 
 `* 適用場景：`
    - 當需要允許使用者在大量訂單或項目中批量刪除時，編輯模式非常合適。
    - 它提供了一種簡單且直觀的方式讓使用者選擇多個條目，然後在一次操作中進行處理。
 
 `* 設計注意：`
    - 編輯模式可以通過為 UITableView 調用 `setEditing(_:animated:) `來啟動或退出，並在畫面底部（例如 toolbar）提供額外的操作選項，如「批量刪除」。
    - 通常會有一個「編輯」按鈕放置在 navigationBar 中，使用者點擊後進入編輯狀態。
 
 `2. 「滑動刪除」和「編輯模式」的共存：優劣分析`
 
 `* 滑動刪除的優點：`
    - 直觀：只需滑動單個項目即可刪除，對於刪除少量或單個條目來說非常方便。
    - 快速：不需要進入編輯模式，直接在滑動時完成刪除。
 
 `* 編輯模式的優點：`
    - 批量操作：可以選擇多個項目，同時刪除或執行其他操作。
    - 顯式操作：進入編輯模式後，操作的目標更加明確，減少誤操作的風險。
 
 `* 共存考量：`
    - 操作複雜性：同時提供滑動刪除和編輯模式可能會增加 UI 的複雜性，尤其是對於新手使用者來說可能會造成混淆。
    - 互補性：兩者可以同時存在但在不同情境下提供服務。滑動刪除適合快速處理單個項目，而編輯模式適合批量操作。
    - 設計建議：當啟用「編輯模式」時，可以禁用滑動刪除功能，以減少重複的功能和混淆；當退出編輯模式後，再恢復滑動刪除的功能。
 
 
 `3. 編輯模式下顯示 toolbar 以及 navigationBar 和 tabBar 的設計考量`
 
` * toolbar 在編輯模式中的作用：`
    - 在進入編輯模式後，可以顯示畫面底部的 toolbar，提供如「批量刪除」等操作選項。
    - toolbar 的出現與隱藏可以在進入和退出編輯模式時自動處理，提供更加靈活的操作界面。
 
` * navigationBar 的設計考量：`
    - 避免臃腫：navigationBar 的空間有限，通常可以放置排序按鈕和編輯按鈕。如果再增加過多按鈕，會導致 UI 變得擁擠且操作不直觀。
    - 動態更新：在進入編輯模式時，可以隱藏排序按鈕，只顯示完成編輯或取消的按鈕，這樣可以避免按鈕過多帶來的混亂。
 
 `* tabBar 的設計考量：`
    - 靈活使用：如果 tabBar 已經有其他功能按鈕，例如不同頁面之間的切換，那麼不建議將編輯功能集成到 tabBar 中，這會導致功能定位不清晰。
    - 不建議添加與編輯模式相關的功能：tabBar 通常是用於應用的頁面導航，而不是進行特定的操作，因此「編輯」這類操作應更多考慮放置於 toolbar 或 navigationBar 中。
 
` * 設計建議：`

 在進入「編輯模式」時，可以：
    - 隱藏 navigationBar 中的排序按鈕，僅顯示與編輯相關的按鈕，保持界面整潔。
    - 使用 toolbar 來放置與批量刪除相關的操作，確保操作按鈕在適當的位置出現，而不擠壓導航欄空間。
    - 保持 tabBar 不變，以免混淆使用者對頁面導航的理解。
 */


// MARK: - OrderHistoryViewController 編輯功能與批量刪除的重點筆記（解決方式）
/**
 ## OrderHistoryViewController 編輯功能與批量刪除的重點筆記
 
 `## 編輯按鈕與編輯模式`
 
 `1.概述：`
 
 - 點擊「編輯按鈕」進入編輯模式，會隱藏導航欄中的「排序按鈕」，以避免按鈕過多導致界面混亂，從而保持導航欄的整潔性。
 - 在進入編輯模式後，原本的「編輯」按鈕會變成「完成」按鈕，以便用戶能在編輯完成後退出編輯模式。
 
 `2.設計目的：`
 
 - 避免導航欄過於擁擠，保持界面簡潔，提升使用者體驗。
 
 `3.功能細節：`
 
 - 初始狀態下，導航欄包含「排序按鈕」和「編輯按鈕」。
 
 `4. 當點擊「編輯按鈕」進入編輯模式後：`
 
 - 隱藏「排序按鈕」，顯示「完成」按鈕和「刪除」按鈕。
 - 用戶可以在表格中選擇多行進行批量刪除。
 
 `5. 當完成編輯模式後：`
 
 - 恢復「排序按鈕」和「編輯按鈕」，隱藏「完成」按鈕和「刪除」按鈕。

 `6. 實作細節：`

 `* OrderHistoryNavigationBarManager` 處理導航欄的狀態變更：
 
 - 進入編輯模式後使用 `setupEditingNavigationBar() `設置「完成」和「刪除」按鈕。
 - 完成編輯模式後，回復至初始狀態，使用` setupInitialNavigationBar() `恢復「排序」和「編輯」按鈕。
 
 
 `## 批量刪除功能`
 
 `1.概述：`

 - 在進入編輯模式後，提供用戶批量選擇訂單並進行刪除的功能。
 - `設計目的`：為用戶提供更靈活且便捷的操作，減少逐行滑動刪除的繁瑣過程。
 
 `2.功能細節：`

 - 當進入編輯模式後，表格進入可選擇狀態，用戶可以點擊多個行來選擇要刪除的訂單。
 - 確認選中項目後，點擊導航欄中的「刪除」按鈕執行批量刪除操作。
 
 `3.刪除操作的步驟：`
 
 - 從 `UITableView` 中獲取選擇的行。
 - 通知 `OrderHistoryDelegate` 刪除本地和遠端的訂單資料。
 - 從 `UITableView` 中刪除相應的行，更新表格視圖。
 
 `4.實作細節：`

 `* OrderHistoryEditingHandler 負責管理編輯模式和批量刪除的具體操作：`
 
 - `toggleEditingMode() `用於切換編輯模式。
 - `deleteSelectedRows() `處理選中的多個行，並透過 `OrderHistoryDelegate` 刪除相應的訂單資料。
 - `OrderHistoryNavigationBarManager` 在編輯模式下顯示「刪除」按鈕，並呼叫 `deleteButtonTapped() `來執行刪除操作。
 
 
` ## 重點設計考量`
 
 `1.分離職責：`

 - `OrderHistoryNavigationBarManager`：專門負責導航欄按鈕的顯示和狀態管理，例如進入編輯模式隱藏排序按鈕。
 - `OrderHistoryEditingHandler`：專注於編輯模式的操作邏輯，包括切換編輯狀態和刪除選中的訂單。
 - 這樣的設計有助於維持代碼的簡潔與可維護性，將不同功能邏輯分開，使每個管理器的職責更為單一且明確。
 
 `2.批量操作設計：`

 - `批量刪除的便利性`：與逐行滑動刪除相比，批量刪除更能有效提高操作效率，特別是當用戶有多筆訂單需要同時刪除時。
 - `用戶體驗`：在進入編輯模式後，隱藏「排序」按鈕並顯示「刪除」按鈕，使界面操作更直觀和簡潔，減少了按鈕混亂的情況。
 */



import UIKit
import Firebase

/// 負責顯示歷史訂單的視圖控制器。
/// - `OrderHistoryViewController` 透過與 Firebase 通訊來獲取訂單資料，並且將這些資料顯示在表格視圖中。
/// - 使用資料驅動的方式來確保 UI 在資料完全加載後再進行配置。
class OrderHistoryViewController: UIViewController {

    // MARK: - Properties

    /// 管理訂單資料的管理器，負責與 Firebase 互動以獲取訂單資料
    private let orderHistoryManager = OrderHistoryManager()
    
    /// 自訂的 `OrderHistoryView`，包含顯示訂單的 `UITableView`
    private let orderHistoryView = OrderHistoryView()
    
    /// 處理表格視圖的數據和委託邏輯的 `OrderHistoryHandler`
    private var orderHistoryHandler: OrderHistoryHandler?

    /// 編輯處理器，負責管理編輯模式和多選刪除功能
    private var editingHandler: OrderHistoryEditingHandler?
    
    /// 排序選單處理器，用於管理排序選單邏輯
    private var sortMenuHandler: OrderHistorySortMenuHandler?
    
    /// 導航欄管理器，用於管理導航欄按鈕的配置
    private var navigationBarManager: OrderHistoryNavigationBarManager?
    
    /// 用於存放從 Firebase 獲取的訂單資料
    private var orders: [OrderHistory] = [] {
        didSet {
            setupNavigationBar()                    // 每次更新 orders 後都檢查按鈕狀態
        }
    }

    // MARK: - Lifecycle Methods

    override func loadView() {
        view = orderHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandlers()                                     // 初始化排序、編輯和導航欄處理器
        setupNavigationBar()                                // 設置導航欄按鈕（初始化按鈕狀態）
        fetchOrderHistory(sortOption: .byDateDescending)    // 從 Firebase 獲取歷史訂單資料，預設按照時間倒序
    }
    
    // MARK: - Data Fetching

    /// 從 Firebase 獲取歷史訂單資料
    /// - 說明：使用非同步的方式從 Firebase 取得當前使用者的訂單資料，獲取到資料後進行處理
    private func fetchOrderHistory(sortOption: OrderHistoryManager.OrderHistorySortOption) {
        HUDManager.shared.showLoadingInView(self.view, text: "Loading OrderHistory...")
        Task {
            guard let currentUser = Auth.auth().currentUser else {
                print("No user is currently logged in")
                return
            }
            
            let userId = currentUser.uid
            do {
                // 獲取訂單資料並print出來檢查
                let fetchedOrders = try await orderHistoryManager.fetchOrderHistory(for: userId, sortOption: sortOption)
                print("Fetched Orders: \(fetchedOrders)") // 測試資料
                handleFetchedOrders(fetchedOrders)
            } catch {
                // 處理錯誤，例如顯示一個提示框告訴用戶加載失敗
                print("Failed to fetch orders: \(error.localizedDescription)")
            }
            HUDManager.shared.dismiss()
        }
    }
    
    /// 處理獲取到的訂單資料
    /// - 將獲取到的訂單資料儲存在 `orders` 中，並初始化表格視圖的 Handler
    private func handleFetchedOrders(_ fetchedOrders: [OrderHistory]) {
        self.orders = fetchedOrders
        setupOrderHistoryHandler()
    }
    
    // MARK: - Setup Handlers & Navigation

    /// 初始化 `OrderHistoryHandler`，並設置表格視圖的數據源和委託
    /// - 說明：在成功獲取資料後初始化 Handler，確保表格視圖在資料齊全時再進行配置
    private func setupOrderHistoryHandler() {
        
        // 初始化 Handler，將自己作為 `delegate` 傳入
        let handler = OrderHistoryHandler(delegate: self)
        self.orderHistoryHandler = handler
        
        let tableView = orderHistoryView.tableView
        // 設置表格視圖的數據源、委託為 Handler
        tableView.dataSource = handler
        tableView.delegate = handler
        
        tableView.reloadData()
    }
    
    /// 設置排序選單、編輯模式、導航欄管理器等的處理器
    private func setupHandlers() {
        let tableView = orderHistoryView.tableView
        editingHandler = OrderHistoryEditingHandler(tableView: tableView, delegate: self)
        sortMenuHandler = OrderHistorySortMenuHandler(delegate: self)
        if let editingHandler = editingHandler, let sortMenuHandler = sortMenuHandler {
            navigationBarManager = OrderHistoryNavigationBarManager(
                navigationItem: navigationItem,
                editingHandler: editingHandler,
                sortMenuHandler: sortMenuHandler
            )
        }
    }
    
    /// 設置導航欄上的按鈕
    private func setupNavigationBar() {
        navigationBarManager?.setupInitialNavigationBar()
    }

}

// MARK: - OrderHistoryDelegate
extension OrderHistoryViewController: OrderHistoryDelegate {
    
    // MARK: - Fetch Orders

    /// 返回訂單資料
    /// - 用於讓 `OrderHistoryHandler` 獲取需要顯示的訂單資料
    func getOrders() -> [OrderHistory] {
        return orders
    }
    
    // MARK: - Delete Orders

    /// 刪除指定索引的訂單
    /// - Parameter index: 要刪除的訂單在 `orders` 陣列中的索引位置
    /// - 從 `orders` 中移除訂單，並呼叫 `OrderHistoryManager` 刪除 Firebase 中的資料
    func deleteOrder(at index: Int) {
        
        /// 獲取要刪除的訂單 ID
        let orderId = orders[index].id
        
        /// 刪除本地資料
        orders.remove(at: index)
        
        /// 刪除 Firebase 資料
        Task {
            guard let currentUser = Auth.auth().currentUser else { return }
            let userId = currentUser.uid
            do {
                try await orderHistoryManager.deleteOrder(userId: userId, orderId: orderId)
                print("Order deleted successfully: \(orderId)")
            } catch {
                print("Failed to delete order: \(error.localizedDescription)")
            }
        }
    }
    
    /// 刪除指定的多筆訂單
    /// - Parameter indices: 要刪除的訂單在陣列中的索引列表
    func deleteOrders(at indices: [Int]) {
        let orderIdsToDelete = indices.map { orders[$0].id }
        orders.removeAll { order in
            orderIdsToDelete.contains(order.id)
        }
        
        Task {
            guard let currentUser = Auth.auth().currentUser else { return }
            let userId = currentUser.uid
            do {
                try await orderHistoryManager.deleteMultipleOrders(userId: userId, orderIds: orderIdsToDelete)
                print("Orders deleted successfully")
            } catch {
                print("Failed to delete orders: \(error.localizedDescription)")
            }
        }
    }
    
}

// MARK: - OrderHistorySortMenuDelegate
extension OrderHistoryViewController: OrderHistorySortMenuDelegate {
    
    /// 當使用者選擇排序選項後執行的方法
    /// - Parameter sortOption: 選擇的排序選項
    func didSelectSortOption(_ sortOption: OrderHistoryManager.OrderHistorySortOption) {
        fetchOrderHistory(sortOption: sortOption)    // 重新根據選定排序方式獲取訂單
    }
}
