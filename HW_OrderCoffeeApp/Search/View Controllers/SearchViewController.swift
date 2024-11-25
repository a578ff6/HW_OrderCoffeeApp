//
//  SearchViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//

// https://reurl.cc/6jVkrb

// MARK: - 初步構想_搜尋視圖控制器設計與導航流程的概念筆記
/**
 ## 初步構想_搜尋視圖控制器設計與導航流程的概念筆記
 
 `1. 搜尋視圖控制器導航流程`
 
 - 在搜尋結果中，點擊項目進入 `DrinkDetailViewController` 的設計。這樣用戶可以快速找到所需飲品並查看詳細資訊，符合一般搜尋流程的用戶體驗需求。
 - 導航適合度：這樣的設計符合主導航結構 (`MainTabBarController`)，能夠保持整體流程的簡單與清晰。
 
` 2. 使用 UISearchController 搭配 UITableView 的搜尋功能`
 
 - `UISearchController` 搜尋控制器，特別適合用於列表型的頁面中（例如 `UITableView`），它能即時提供過濾功能。
 
 - `優點`：
    - `UISearchController` 提供搜尋框的顯示與隱藏動畫，以及輸入文字後的即時過濾，能提升搜尋效率。
    - 搭配 `UITableView` 來展示搜尋結果是很適合的選擇，因為 UITableView 支援可重用的單元格顯示多筆資料，且操作簡單效能高。
 
` 3. 是否建議設置搜尋視圖控制器的 Model`
 
 - 建議設置「搜尋視圖控制器的 Model」，這可以讓搜尋邏輯更清晰且便於維護。
 
 - `設置 Model 的優點`：
    - `資料分離`：透過設置 `SearchModel`，可以將資料處理和搜尋邏輯從視圖控制器中抽離，符合單一職責原則（SRP）。
    - `資料管理`：將搜尋過程中的資料管理集中在 Model，能更方便進行單元測試與驗證。
    - `擴展性`：未來如果增加例如「熱門搜尋」或「搜尋建議」等功能，Model 的設計會讓擴展更加方便。

 `4.初步程式碼的建議`
 
 - `現有設置包括`：SearchViewController、SearchCell、SearchView、SearchHandler、SearchManager、SearchResultsDelegate。
 
 - `SearchViewController`：負責顯示搜尋頁面，整合 UISearchController。
 - `SearchCell`：自定義單元格來顯示搜尋結果，可以展示飲品名稱、圖片等資訊。
 - `SearchView`：用於設計搜尋頁面的靜態視圖元素，例如標題或背景。
 - `SearchHandler`：作為 UITableView 的數據源和委託，負責處理搜尋過程中的資料管理和用戶操作。
 - `SearchManager`：負責從 Firestore 加載資料，以及處理與後端的交互。
 - `SearchResultsDelegate`：用於搜尋完成後，將選定的飲品資訊傳遞到其他視圖控制器，例如 DrinkDetailViewController。

 `5.小結`
 
 - `導航流程`：從搜尋結果進入 `DrinkDetailViewController` 。
 - `使用 UISearchController 和 UITableView`：適合用於搜尋功能的動態過濾與結果展示。
 - `設置搜尋視圖控制器的 Model`：符合單一職責原則，讓資料邏輯和視圖分離，並提升代碼的可維護性與擴展性。
 */


// MARK: - SearchViewController 筆記
/**
 
 ## SearchViewController 筆記
  
` 1.設計目的`

 - `SearchViewController` 是搜尋頁面的核心，負責顯示搜尋結果，並管理與使用者的交互。
 - 在設計過程中，將搜尋的顯示、控制器的設置、導航欄設置，以及數據加載等職責分開來處理，以減少耦合度並提升代碼的可讀性和可維護性。

 `2.屬性與責任分配`

 - `searchView`：自定義的主視圖，包含了展示搜尋結果的 UITableView。在 loadView 階段設定，確保在視圖加載前即設置好正確的視圖。
 - `searchHandler`：處理搜尋結果的顯示和用戶操作，使用延遲初始化以便在需要時才進行設置，確保其他初始化已完成。
 - `searchManager`：負責從 Firebase 獲取搜尋數據。提供了搜尋資料的加載和過濾功能，是數據層的核心。
 - `searchControllerManager`：管理 UISearchController 的設置和交互，使用委託來通知 SearchViewController 關於搜尋行為的變化。
 - `searchNavigationBarManager`：負責設置導航欄標題和相關的按鈕，將與導航欄相關的邏輯集中管理，以保持 SearchViewController 的簡潔。
 - `searchResults`：儲存目前的搜尋結果，並透過 `didSet` 更新 UITableView 的顯示和搜尋視圖的狀態 (`updateViewStateBasedOnSearchResults`)。

 `3.分離關心點的實踐`

 - UI 部分 (`SearchView`) 與資料部分（如 `SearchManager` 和 `SearchHandler`）分離，避免一個類過多的職責，使代碼更容易管理。
 - `SearchControllerManager`：專門處理與 UISearchController 相關的邏輯，例如搜尋欄文字更新和取消搜尋的回應。這樣可以避免 SearchViewController 因為搜尋交互邏輯而過於臃腫。
 - `SearchNavigationBarManager`：專門處理與導航欄相關的配置，例如標題設置和按鈕配置，避免將導航欄邏輯直接寫入 SearchViewController，以保持代碼模組化。

 `4.使用委託的設計`

 - `使用 SearchResultsDelegate 和 SearchControllerInteractionDelegate 兩個委託`：
    - `SearchResultsDelegate`：主要負責管理搜尋結果數據和與 SearchHandler 的交互，例如返回目前的搜尋結果和處理用戶選擇。
    - `SearchControllerInteractionDelegate`：負責 UISearchController 的交互行為，例如當使用者輸入搜尋字串或取消搜尋時的回應。
    - 通過這些委託， SearchViewController 可以有效地將資料層和交互層分開，減少代碼的耦合性，提升可維護性。
 
 `5.狀態管理與更新`
 
 `* updateViewStateBasedOnSearchResults()：`
 
    - 根據 searchResults 的內容更新搜尋視圖的狀態。
    - 當 searchResults 為空時，設置為 .noResults 狀態，否則設置為 .results 狀態。
    - 更新狀態的同時，調用` reloadTableViewIfNeeded()`，確保 UITableView 的顯示與最新資料同步。
 
 `* reloadTableViewIfNeeded()：`

    - 使用此方法來刷新 UITableView，只在需要時才進行刷新，以提升性能。
    - 將 reloadData() 從 didSet 中移出，使資料變更與視圖更新的責任更清晰。
 
 `6.搜尋控制器的設置`
 
 `* setupSearchController() 和 setupNavigationBar()：`
 
    - 在 `setupSearchController() `中，利用 `SearchControllerManager` 來管理 UISearchController 的設置，避免將這些配置邏輯直接寫在 SearchViewController 中，保持控制器的簡潔。
    - `SearchControllerManager` 的設計讓搜尋行為的管理與頁面控制器分開，使得代碼更具模組化和可重用性。
    - 在 `setupNavigationBar() `中，利用 `SearchNavigationBarManager` 來設置導航欄的標題和大標題顯示模式，讓與導航欄相關的邏輯更具模組化和可重用性。
 
 `7. 搜尋流程與使用者控制權`

 - 原本設置為「飲品快取資料無效」時，進入到「搜尋視圖控制器」會立刻進行自動載入「飲品快取資料到本地」，讓使用者可以方便搜尋。
 - 但並不是每個使用者都會使用到搜尋功能，且有時候只是誤觸切換到「搜尋視圖控制器」，如果這樣就去自動載入「飲品快取資料到本地」，會讓使用者在操作上不順，並且因為使用者沒有使用到搜尋的功能，會對於這個自動載入的行為感到困惑。
 - 因此將「飲品快取資料有效與否」的檢查移到「搜尋」時才進行，這樣可以更確定使用者是有意要使用搜尋功能時，才執行資料加載操作。
 - 當「飲品資料無效」時，跳出「資料無效的 Alert」來提示使用者，並給予選擇是否「重新加載飲品資料」的機會，並且檢查網路狀態。
 - 若選擇取消，則不進行重新載入。
 - 此外，將「重新加載飲品資料」的控制權交給使用者，讓使用者在更了解自己操作環境的情況下決定何時加載資料，避免自動加載帶來的困惑。
 - 當網路狀態不可用時，會顯示「無網路的 Alert」，提醒使用者需要穩定的網路連線。
 - 只有在進行搜尋操作時才會檢查「飲品快取資料有效與否」，以減少不必要的資料加載。
 
 `8. 搜尋文字和搜尋狀態的處理`
 
 `* didUpdateSearchText 和 didCancelSearch和 didSelectSearchResult 的處理`

 - `didUpdateSearchText(_:)`：當搜尋文字更新時，調用此方法過濾目前的搜尋結果，這使得搜尋功能對用戶的操作反應更即時。
 - `didCancelSearch()`：當取消搜尋時，調用此方法以立即清空搜尋結果，並且更新提示文字。
 - `didSelectSearchResult(_:)`：當使用者選擇某個搜尋結果時，會導航至 `DrinkDetailViewController` 顯示飲品的詳細資訊。

 `9.總結`
 
 - 職責分離 是本設計的核心，將視圖、資料處理和交互管理劃分開來，利用各種管理器（如 `SearchHandler` 和 `SearchControllerManager`）來降低耦合，讓每個部分只專注於自身的職責。
 - 使用 委託模式 來處理搜尋過程中的數據變化和用戶交互，這樣可以確保 `SearchViewController` 專注於頁面邏輯，並將其他操作交由專門的模組處理。
 - SearchControllerManager 的引入使得 UISearchController 的相關邏輯能夠集中管理，避免過多地污染主要控制器的代碼，提升可維護性。
 -  updateViewStateBasedOnSearchResults 與 reloadTableViewIfNeeded() 的改進 使得視圖更新和資料變更的管理更加清晰。
 */


// MARK: - 搜尋狀態設計與提示訊息顯示（重要）
/**
 
 ## 搜尋狀態設計與提示訊息顯示

 `* 在設計搜尋頁面的提示訊息顯示時，有兩種主要的考量方式：`

` 1. 初始進入搜尋頁面時顯示提示訊息：`
    - 當使用者剛進入搜尋頁面時，顯示「Please enter search keywords」這樣的提示訊息，可以引導使用者進行下一步操作。

 `2. 根據與 UISearchController 的互動來顯示提示訊息：`
    - 當使用者與搜尋框有互動（如點擊、輸入或取消）時，根據不同狀態顯示不同的提示。例如：
        - 使用者點擊搜尋框但未輸入文字時，顯示「Please enter search keywords」。
        - 當使用者開始輸入但無符合結果時，顯示「No Results」。
        - 當使用者按下取消按鈕 (`cancel`) 結束搜尋時，回到初始狀態，再次顯示「Please enter search keywords」。
        - 當「飲品快取資料無效時」顯示 Alert 提示「資料無效」，並將searchResults設置為[]，使視圖畫面呈現「NO Result」，確保畫面沒有殘留的資料。

 `* 設計方式`

 - 基於以上考量，較直觀的做法是根據`使用者是否進行搜尋操作`來顯示對應的提示訊息，具體邏輯如下：

 `1. 初始進入頁面`：顯示「Please enter search keywords」引導使用者。
 
 `2. 使用者點擊搜尋框`：保持顯示「Please enter search keywords」，直到使用者開始輸入文字。
 
 `3. 使用者開始輸入`：
    - 如果搜尋結果為空，顯示「No Results」。
    - 如果有符合結果，顯示搜尋結果。
 
 `4. 使用者按下取消`：清空搜尋結果，再次顯示「Please enter search keywords」。

 
 `* 這樣設計的好處在於：`
 
 - 每個狀態的提示訊息都是基於使用者操作，符合一般使用者的直覺，能更好地引導使用者完成搜尋。
 - 初始狀態與取消搜尋的狀態保持一致，顯示「Please enter search keywords」，使介面顯得簡潔且容易理解。
 */


// MARK: - 搜尋視圖的返回狀態處理想法（補充想法）
/**
 
 ## 搜尋視圖的返回狀態處理想法

 `1. What: 搜尋視圖返回的狀態處理`
 
 - 主要是在操作像是Podcast、ig等搜尋功能時所觀察到的部分。
 - 當用戶從搜尋視圖導航至其他頁面（飲品詳細頁面）並返回時，需要決定搜尋視圖應保持原有的狀態還是重置為初始狀態。
 - 這包括搜尋框中的文字、搜尋結果列表的顯示狀態，以及 UI 的其他相關元素。

 `2. Why: 保持狀態與重置狀態的考量`
 
 `* 保持狀態的理由`
    - `提升用戶體驗`：保持搜尋視圖的狀態能提升用戶體驗，因為用戶可能希望繼續查看之前的搜尋結果，或者選擇其他結果。
    - `減少操作重複性`：如果用戶多次來回切換，保持狀態可以避免用戶重新輸入搜尋文字並再次查找。
    - `一致性`：保持狀態與許多應用程序的行為一致，例如使用搜尋功能後返回列表，大多數應用都會保持搜尋框的內容和結果。
 
 `* 重置狀態的理由`
    - `清爽的界面`：在某些應用場景下，用戶可能希望在返回搜尋頁面時看到一個乾淨的界面，避免被之前的搜尋干擾。
    - `頁面刷新考慮`：有時候，搜尋結果可能因數據變更而過時，重置狀態可以確保用戶看到最新的內容。
    - `特定場景需求`：在特定場景下，重置狀態可能符合業務邏輯需求，例如用戶每次返回應看到最新的推薦內容。
 
 `3. How: 如何實現搜尋視圖的返回狀態管理`
 
 `* 保持狀態的方式`
    - 狀態保存：在用戶離開搜尋視圖時，將搜尋框的文字和結果保存在一個變數或模型中。當用戶返回時，根據保存的狀態重新配置視圖（例如恢復搜尋文字和結果列表）。
    - 頁面暫留：如果視圖控制器並未被釋放（例如使用 navigationController 推入下一個控制器），則其狀態會自然保留，用戶返回時可直接看到先前的狀態。
 
 `* 重置狀態的方式`
    - 清空狀態：在 viewWillAppear 或 viewDidAppear 中，重置搜尋框的文字、清空結果列表，將界面恢復到初始狀態。
    - 條件重置：可以根據具體情境來決定是否重置，例如檢查用戶返回的時間間隔，如果間隔過長則進行重置。
 
 `4. 想法`
 
 - 保持狀態：
    - 大多數情況下，建議保持搜尋視圖的狀態，這樣可以提高用戶體驗，讓用戶方便地返回並繼續操作，尤其是當搜尋結果涉及多個步驟或者用戶可能需要查看多個結果時。
 
 - 重置狀態：
    - 在一些特定情境下（例如應用性能受影響，或用戶習慣需要更清爽的界面），可以考慮重置狀態。可以根據用戶反饋或業務需求來決定具體的策略。
 */


// MARK: - 筆記：實例化 SearchNetworkMonitor 的選擇與影響（重要）
/**
 
 ## 筆記：實例化 SearchNetworkMonitor 的選擇與影響
 
 `* 「飲品資料」的背景：`
 
 `1.飲品資料的預加載：`
    - 在 App 啟動時，AppDelegate 中會進行「預加載飲品資料」的操作，但這個過程可能會失敗，或由於快取資料是有時效性的，也可能在使用者操作時快取已經過期。

 `2.避免自動加載資料：`
    - 在使用者進入搜尋視圖控制器時，不希望直接自動加載飲品資料，因為使用者可能只是誤觸「搜尋視圖控制器」，並不打算進行搜尋操作。
    - 因此，只有當使用者真正開始搜尋時，才檢查飲品資料的有效性。

 `3.當資料無效時的處理`：
    - 如果飲品快取資料無效，會顯示一個提示 Alert (`showDataUnavailableAlert`) 讓使用者選擇是否加載資料。
    - 當使用者點擊「加載」時，會檢查網路狀態並從 Firebase 請求重新加載飲品資料。
 
 ----------------------------------------------------------------------
 
 `* 關於「內部或外部實例化 SearchNetworkMonitor」的討論`
 
 `1, 內部實例化 (reloadDrinkData 中的本地變數)：`
 
 - 每次呼叫 `reloadDrinkData() `方法時，都會建立一個新的 `SearchNetworkMonitor` 實例，這樣可以確保每次都有一個獨立的監控器開始監控網路狀態。
 - 每次呼叫後，新的實例會立刻啟動網路監控，並且監控網路狀態的變化。
 - 這樣的設計在呼叫` reloadDrinkData() `多次時，能確保網路監控器的狀態總是最新的，並且不會受到之前監控狀態的影響。
 
 `2.外部實例化 (SearchViewController 中的屬性)：`
 
 - 當 `searchNetworkMonitor` 作為外部的屬性並在 `reloadDrinkData() `中多次使用時，會遇到如下問題：
    - 如果在上次監控結束後（例如調用`了 stopMonitoring()`），沒有重新初始化或重啟監控器，onStatusChange 的回調會無效。
    - 因為同一個實例在之前的操作中已經停止監控，導致再次調用` startMonitoring() `時監控器無法正常運作，因此看不到網路狀態變化的完整打印。
 
 ----------------------------------------------------------------------

 `* What:`

 - `SearchNetworkMonitor` 是一個用於監控網路狀態的類別，可以實例化為`本地變數`或作為`控制器的屬性`來使用。
 
 `* Why:`

 `1.內部實例化（本地變數）：`
 
 - 適合在特定操作（例如重新加載資料）中確保網路狀態監控器總是「全新且有效」的情境。
 - 每次呼叫 reloadDrinkData() 都會有一個新的 SearchNetworkMonitor 實例，這樣監控器不會受到前一次操作的影響，可以保證每次加載時的網路狀態檢查都是完整和正確的。
 
 `2.外部實例化（作為屬性）：`
 
 - 適合在多個地方需要共享同一個網路監控器的情境。
 - 但是需要特別注意監控器的生命周期管理，尤其是在停止監控後，如何再次正確啟動監控，避免因為之前監控被取消而導致無法正常使用的情況。
 
 `* How:`

 `1.內部實例化的方式：`

 - 在 `reloadDrinkData() `方法中，直接實例化 `SearchNetworkMonitor`，這樣每次重新加載時，會建立一個新的監控器並開始監控網路狀態，確保每次的監控器都是新鮮的，不受先前狀態影響。
 
 `2.外部實例化的方式（若選擇外部屬性）：`

 - 在 `SearchViewController` 中作為屬性使用時，需特別注意每次調用之前要確保監控器是處於啟動狀態，並且避免重複啟動已停止的監控器。
 
 `* 小結：`

 - 在這種情況下，由於每次重新加載資料都需要確保網路狀態的準確性且不受先前監控器的影響，內部實例化（本地變數）會更合適，這樣可以保證每次重新加載資料時，都有一個新鮮的監控器來檢查網路狀態，確保用戶的操作體驗順暢。

 */


// MARK: - 調整 `searchView.tableView.reloadData()` 的位置筆記
/**
 ## 調整 `searchView.tableView.reloadData()` 的位置筆記

 - 我原先在 `SearchViewController` 中，`searchResults` 的 `didSet` 包含 `searchView.tableView.reloadData()` 用於自動更新表格視圖，這樣的設計確保了當 `searchResults` 變更時，UI 與資料能保持一致性。
 - 這種設置對於保持資料與視圖的即時同步有其合理性，尤其是當有資料變更時即時呈現更新。

 但是考慮到更細緻的控制與提升程式碼的可讀性，對此進行一些調整：

 `* 移動 reloadData() 以更精細地控制表格刷新`

 - 將 `searchView.tableView.reloadData()` 從 `didSet` 中移出，並將其放入更新視圖狀態的方法 `updateViewStateBasedOnSearchResults()`，這樣可以更明確地知道何時需要刷新表格資料。
 - 例如，當 `searchResults` 的變更僅僅是清空結果時，可以根據實際需要決定是否刷新表格，從而減少不必要的刷新操作，提升性能。

 `* 新設 reloadTableViewIfNeeded() 方法`

 - 用於判斷是否有必要刷新表格資料。這樣的設計可以進一步減少冗餘的刷新操作，特別是在清空結果或資料未變更的情況下，這對於提升應用效能有顯著幫助。

 `* 保持在 didSet 設計的好處`

 - 如果維持在 `didSet` 的設計相對直觀，當 `searchResults` 發生變化時，`didSet` 會立即更新 UI，這確保了資料的變更能即時反映到使用者界面中。
 - 特別是當進行資料加載操作（例如 `reloadDrinkData`）時，即使表格視圖可能會多次刷新，但這樣的做法可以確保任何新的資料都能被即時呈現，從而提高使用者體驗的即時性與一致性。

`* 調整總結`

 - 將 `searchView.tableView.reloadData()` 從 `didSet` 移至 `updateViewStateBasedOnSearchResults()` 可以更精確地控制表格的更新，確保只有在需要時才進行刷新操作。
 - 這樣的調整使程式碼更具可讀性，也讓更新邏輯更加集中，方便日後的維護和擴展。
 */


// MARK: - 為何重構 SearchViewController 筆記
/**

 ## 為何重構 SearchViewController 筆記
 
`* 更新後的流程圖`

 ```
 搜尋 —— 有資料 ——> 可搜尋
    |
    +--- 飲品資料無效 --> showDataUnavailableAlert --------> 點擊重試 ---- 有網路 ----> 資料加載成功有資料 --> 可搜尋
                              |                    |
                              +---> 點擊取消         +-- 無網路 --> 顯示 Alert，請確認網路連接
 ```
 
 ------------------------------------------------------------------

 `1. What: SearchViewController 的設計與運作`

 - `SearchViewController` 是負責搜尋頁面管理的核心控制器，負責顯示搜尋結果、管理搜尋行為，以及處理使用者的互動。
 - 此控制器內部使用了多個管理器來達成不同的功能，分別是 SearchHandler、SearchManager、SearchControllerManager、以及 SearchNavigationBarManager。

 ------------------------------------------------------------------

 `2. Why: 設計的考量與變更的目的`

 `* 原始設計`

 - `原本設計`：進入 `SearchViewController` 後，若發現「飲品快取資料無效」，系統會自動嘗試加載飲品資料到本地，這樣可以讓使用者進行即時的搜尋。
 - `問題點`：並非所有使用者在進入搜尋頁面後都會立即使用搜尋功能，有些可能只是誤觸或短暫切換。而每次自動進行資料加載，可能會導致不必要的等待時間，讓使用者感到操作「不順」，且會對這樣的自動行為感到困惑。

 `* 改進設計`

 - `延遲資料加載的時機`：將「快取資料是否有效」的判斷延遲到使用者進行「實際搜尋」時。這樣的改進避免了進入搜尋頁面時就進行不必要的資料加載，只有使用者真的需要搜尋時才進行資料的有效性檢查。
 
 - `提升使用者的控制權`：當「飲品資料無效」時，系統會跳出 `Alert` 提示「資料無效」，讓使用者決定是否重新加載飲品資料，並同時檢查網路狀態。
      - `使用者選擇「取消」`：不進行資料加載，保持當前狀態。
      - `使用者選擇「載入」`：系統檢查網路狀況，若無網路則跳出 `Alert` 提醒網路不可用，若網路正常則開始加載資料。
 
 - `使用者掌握資料加載控制`：將「重新加載資料的控制權」交給使用者，畢竟使用者最清楚自己的使用環境與需求。相比原本自動加載資料的方式，這樣的設計能有效降低使用者的困惑，並提供更好的使用體驗。

 ------------------------------------------------------------------

 `3. How: 實作方式`

 `- 搜尋流程改進：`
 
   - `延遲資料有效性檢查`：
        - 在搜尋觸發 (`didUpdateSearchText`) 時，檢查飲品資料的有效性。如果快取無效則顯示 `Alert`，詢問使用者是否要加載資料。
 
   - `顯示資料無效的提示`：
      - 使用 `showDataUnavailableAlert()` 方法，讓使用者選擇是否重新加載資料。
 
   - `控制資料加載`：
      - 當使用者選擇重新加載時，通過 `reloadDrinkData()` 方法進行資料加載，並在加載前使用 `SearchNetworkMonitor` 檢查網路狀態。
        - `網路狀態良好時 (.satisfied)`：開始加載飲品資料。
        - `無網路時 (.unsatisfied)`：顯示 `Alert` 提示使用者網路不可用，避免無效的資料加載請求。

 ------------------------------------------------------------------

 `4. 具體程式碼改進重點`

 - `didUpdateSearchText(_:)` 方法：
   - 當使用者開始輸入搜尋關鍵字時，會根據當前飲品資料快取的狀態來決定如何執行：
     - 若快取資料有效，則直接進行搜尋操作。
     - 若快取資料無效，則彈出提示框讓使用者選擇是否要重新加載資料。

 - `reloadDrinkData()` 方法：
   - 改進後的資料加載流程更加清晰，會先檢查網路狀態，只有在確認網路可用的情況下才開始加載，避免無效操作。
   
 ------------------------------------------------------------------

 `5. 總結`

 - 提高使用者體驗：透過延遲資料有效性檢查及讓使用者決定是否加載資料，降低了不必要的等待時間，並避免使用者在無意使用搜尋功能時被強制加載資料。
 - 提升代碼可維護性：將飲品資料的加載邏輯與使用者的搜尋行為更精準地結合，並使用 `Alert` 來處理資料加載的控制權，使得整個流程更加明確，減少耦合。
 - 增加使用者的掌控感：使用者可以自己決定是否要進行資料加載，系統也會在網路不可用時進行適當的提示，這樣的改進能夠有效提升使用者對應用的滿意度。
 
 */


// MARK: - SearchViewController 程式碼運作流程

/**

 ## SearchViewController 程式碼運作流程

 `1. 初始化與設置`

 `* loadView()`
    - 設定 `searchView` 為主要視圖，以展示搜尋頁面。

 `* viewDidLoad()`
    - 執行初始設置，呼叫以下方法：
      - `setupHandler()`: 初始化 `SearchHandler` 並設置表格數據源和委託。
      - `setupSearchController()`: 初始化 `SearchControllerManager` 並設置 `UISearchController` 的行為。
      - `setupNavigationBar()`: 初始化 `SearchNavigationBarManager` 並配置導航欄標題和大標題模式。
    - 設置搜尋視圖初始狀態為 `.initial`。

 ------------------------------------------------------------------

 `2. 搜尋結果的處理與顯示`

 `* setupHandler()`
    - 初始化 `SearchHandler`，並將 `searchView.tableView` 的 `dataSource` 和 `delegate` 指定給 `SearchHandler`，以處理搜尋結果的顯示和使用者互動。

 `* searchResults 的 didSet`
    - 當 `searchResults` 被設置或更新時，會觸發 `updateViewStateBasedOnSearchResults()` 方法：
      - 判斷 `searchResults` 是否為空，更新 `searchView` 的顯示狀態。
      - 確保資料同步，呼叫 `reloadTableViewIfNeeded()` 重新載入表格資料。

 `* updateViewStateBasedOnSearchResults()`
    - 根據 `searchResults` 的狀態進行更新：
      - 如果搜尋結果為空，顯示「無搜尋結果」的提示。
      - 否則，顯示搜尋結果列表。

 `* reloadTableViewIfNeeded()`
    - 重新載入 `UITableView` 以顯示更新後的搜尋結果。

 ------------------------------------------------------------------

 `3. 搜尋控制器與互動`

 `* setupSearchController()`
    - 初始化 `SearchControllerManager` 並設置 `UISearchController` 的管理行為。

 `* SearchControllerInteractionDelegate`
    - `didUpdateSearchText(_:)`:
      - 當使用者在搜尋框中輸入文字時，如果文字不為空，調用 `filterSearchData(with:)` 以篩選符合的飲品資料。
      - 若文字為空，清空 `searchResults` 並恢復初始狀態。
    - `didCancelSearch()`:
      - 當使用者取消搜尋時，清空 `searchResults` 並恢復搜尋視圖初始狀態。

 ------------------------------------------------------------------

 `4. 資料載入與網路狀態監控`

 `* reloadDrinkData()`
    - 當需要載入飲品資料時，會先顯示 `HUDManager` 的加載指示器。
    - 使用 `SearchNetworkMonitor` 監控網路狀態：
      - 若網路狀態為 `.satisfied`，調用 `startLoadingDrinkData()` 進行資料加載。
      - 若網路狀態為 `.unsatisfied`，調用 `handleNetworkUnavailable()` 顯示無網路連接的提示。

 `* startLoadingDrinkData()`
    - 呼叫 `SearchDrinkDataLoader` 以加載飲品資料。
    - 成功載入後，調用 `handleDataLoadSuccess()` 停止網路監控並隱藏 HUD。
    - 若載入失敗，則呼叫 `handleDataLoadFailure()` 顯示錯誤訊息並停止監控。

 `* handleNetworkUnavailable()`
    - 當網路不可用時，顯示提示並停止網路監控，提醒使用者檢查網路連接。

 ------------------------------------------------------------------

 `5. 使用者操作的搜尋過程`

 `* filterSearchData(with:)`
    - 當使用者輸入搜尋關鍵字後，調用此方法以篩選符合條件的飲品資料。
    - `SearchManager` 會根據關鍵字進行搜尋並將結果賦值給 `searchResults`。

 `* handleSearchResults(results:keyword:)`
    - 將搜尋結果保存至 `searchResults` 並更新視圖狀態。
    - 若沒有符合的結果，打印提示訊息。

 `* handleSearchError(error:)`
    - 處理搜尋過程中的錯誤，顯示「資料無效」的警示，並將 `searchResults` 設置為空以更新視圖。

 ------------------------------------------------------------------

 `6. 使用者選擇搜尋結果`

 `* SearchResultsDelegate`
    - `getSearchResults()`: 返回目前的搜尋結果供 `SearchHandler` 使用。
    - `didSelectSearchResult(_:)`:
      - 當使用者選擇某個搜尋結果時，導航至 `DrinkDetailViewController`，並將選擇的飲品詳細資訊傳遞過去。

 ------------------------------------------------------------------

 `7.總結`
 
 - `流程概覽`
   1. 使用者進入搜尋頁面，初始化各管理器並設置界面。
   2. 使用者輸入關鍵字，觸發搜尋功能，顯示搜尋結果。
   3. 根據網路狀態，進行資料的重新載入與提示。
   4. 使用者選擇搜尋結果，導航至詳細資訊頁面。

 - `重點設計`
   - 職責分離：每個功能模組（如搜尋、導航欄、網路監控）都有獨立管理器，降低耦合度。
   - 使用者控制權：資料重新加載由使用者決定，避免自動操作帶來的困擾。
   - 網路狀態監控：確保資料加載在網路狀態允許的情況下進行，提升使用者體驗。
*/


// MARK: - 筆記：關於 SearchRetryManager 的移除與流程調整，只需要 SearchNetworkMonitor 的運用即可

/**

 ## 筆記：關於 SearchRetryManager 的移除與流程優化

 - SearchRetryManager 的移除與流程調整，只需要 SearchNetworkMonitor 單純監控網路狀態運用即可
 
 `1. 遇到的問題與改進原因 (What & Why)`

 - `原本的問題`：
   - 原先設計中，當「飲品資料無效」時，使用 `SearchRetryManager` 進行資料加載的重試，這包括了「網路正常但資料無效」的情境。
   - 這導致了過度使用網路監控，即使網路狀態是正常的，仍會啟動監控並進行不必要的重試操作，從而增加程序複雜度，影響使用者體驗。

 - `問題的原因`：
   - `SearchRetryManager` 的主要職責是處理「網路不可用或不穩定」的情境，並在網路恢復後進行重試。
   - 但是我錯誤地認為可以使用 `SearchRetryManager` 處理「網路正常但資料無效」的情境，結果導致邏輯混亂和流程不順暢。

 ------------------------------------------------------------------

 `2. 改進的正確流程 (How)`

 - `目前正確流程`：
 
   - 搜尋行為的邏輯分支：
     - 當使用者觸發搜尋功能時，檢查飲品資料是否有效。
       - 若資料有效，則立即進行搜尋。
       - 若資料無效，則顯示 `showDataUnavailableAlert`，提示使用者進行重試或取消操作。
         - 若點擊重試，則檢查網路狀態：
           - 網路正常：重新加載飲品資料，並在成功後開始搜尋。
           - 無網路：顯示警示視窗，告知使用者需要網路連接。

 - `改進的重點`：
 
   `1. 移除 SearchRetryManager：`
      - 移除不必要的網路監控邏輯，因為在資料無效但網路正常的情況下，不應該進行網路狀態監控。
   
   `2. 只在資料無效時提醒使用者：`
      - 當飲品資料無效時，透過 `showDataUnavailableAlert` 提醒使用者是否要重試資料加載。
      - 使用者可以自主決定是否進行資料加載，避免強制自動重試帶來的不便。

   `3. 網路狀態提示：`
      - 當使用者決定重試時，如果網路不可用，顯示「網路不可用」的警示，讓使用者確保連接穩定後再行動。

 ------------------------------------------------------------------

 `3. 具體實現與最佳實踐 (Implementation Details)`

 - `showDataUnavailableAlert`：
   - 當資料無效時，呼叫此方法提示使用者。
   - 提供兩個選擇：「載入資料」或「取消」。
   - 若選擇載入資料，則執行 `reloadDrinkData()` 方法，進行資料加載。

 - `reloadDrinkData`：
   - 呼叫 `SearchNetworkMonitor` 檢查網路狀態。
   - 網路正常：開始資料加載。
   - 無網路：顯示無網路的警示，讓使用者知道需要先連接網路。

 ------------------------------------------------------------------

 `4. 具體優化與新流程總結`

 `#### 原本錯誤流程：`
 
 搜尋 —— 有資料 ——> 可搜尋
    |
    +--- 飲品資料無效 --> showRetryAlert --------> 點擊重試 ---- 有網路 ----> 資料加載成功有資料 --> 可搜尋
                        |                                   |
                        +---> 點擊取消             +-- 無網路 --> 自動重試 --> 直到重試上限 --> 顯示 Alert，請確認網路連接

 `#### 現在正確流程：`
 
 搜尋 —— 有資料 ——> 可搜尋
    |
    +--- 飲品資料無效 --> showDataUnavailableAlert --------> 點擊重試 ---- 有網路 ----> 資料加載成功有資料 --> 可搜尋
                              |                                     |
                              +---> 點擊取消              +-- 無網路 --> 顯示 Alert，請確認網路連接

 ------------------------------------------------------------------

 `5. 總結 (Summary)`

 - `移除 SearchRetryManager 的原因：`
   - `SearchRetryManager` 的設計初衷是為了解決網路不穩定的情況，但不適用於「網路正常但資料無效」的場景。
   - 因此，將其移除能簡化邏輯，使程式碼更加清晰，避免使用者對自動重試的混淆。

 - `新流程的改進點`：
   - 資料加載由使用者決定，強調使用者主導的交互方式，避免自動行為帶來的困擾。
   - 在網路正常的情況下，直接重新加載資料，不再進行不必要的網路狀態監控，提高效能和使用者體驗。
 */


// MARK: - 啟動 App 時加載搜尋資料 & 設置載入功能（避免飲品資料快取無效）

import UIKit

/// `SearchViewController` 負責管理搜尋頁面，包括顯示搜尋結果以及處理使用者的操作
class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 自定義的 `SearchView`，包含搜尋結果列表的 UI 元素
    private let searchView = SearchView()
    
    /// `SearchHandler` 用於處理搜尋結果的顯示及使用者的互動，設置為可選類型以便延遲初始化
    private var searchHandler: SearchHandler?
    
    ///`SearchManager` 提供飲品搜尋功能
    private let searchManager = SearchManager()
    
    /// `SearchControllerManager` 負責管理 `UISearchController` 的設置和交互
    private var searchControllerManager: SearchControllerManager?
    
    /// `SearchNavigationBarManager` 導航欄管理器，用於設置導航欄按鈕和標題
    private var searchNavigationBarManager: SearchNavigationBarManager?
    
    /// 搜尋結果資料
    /// - 當搜尋結果資料變更時，自動更新表格視圖以顯示最新的搜尋結果
    private var searchResults: [SearchResult] = [] {
        didSet {
            updateViewStateBasedOnSearchResults()
        }
    }
    
    // MARK: - Lifecycle Methods
    
    /// 設置主視圖為自定義的 `SearchView`
    override func loadView() {
        view = searchView
    }
    
    /// 視圖加載完成後，設置處理器和搜尋控制器
    /// - 初始化 `SearchHandler`、`SearchControllerManager` 以及 `SearchNavigationBarManager`，以便管理搜尋行為、顯示結果和設置導航欄
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandler()
        setupSearchController()
        setupNavigationBar()
        updateView(for: .initial)
    }
    
    // MARK: - Setup Methods
    
    /// 初始化 `SearchHandler` 並設置表格的數據源與委託，以便處理搜尋結果的顯示和用戶操作
    private func setupHandler() {
        searchHandler = SearchHandler(delegate: self)
        guard let  searchHandler = searchHandler else { return }
        searchView.tableView.dataSource = searchHandler
        searchView.tableView.delegate = searchHandler
    }
    
    /// 初始化 `SearchControllerManager` 並將搜尋控制器附加到視圖控制器上
    private func setupSearchController() {
        searchControllerManager = SearchControllerManager(delegate: self)
        searchControllerManager?.attach(to: self)
    }
    
    /// 設置導航欄
    /// - 使用 `SearchNavigationBarManager` 來設置導航欄標題及大標題顯示模式
    private func setupNavigationBar() {
        searchNavigationBarManager = SearchNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        searchNavigationBarManager?.configureNavigationBarTitle(title: "Search Drinks", prefersLargeTitles: true)
    }
    
    // MARK: - Search
    
    /// 根據關鍵字過濾本地飲品資料
    /// - Parameter keyword: 搜尋的關鍵字
    /// - 使用 `SearchManager` 中的`快取資料`來進行本地過濾，以提升搜尋的速度
    private func filterSearchData(with keyword: String) {
        Task {
            do {
                /// 透過搜尋管理器以關鍵字進行搜尋，並將結果賦值給搜尋結果變數
                let results = try await searchManager.searchDrinks(with: keyword)
                handleSearchResults(results: results, keyword: keyword)
            } catch {
                handleSearchError(error: error)
            }
        }
    }
    
    /// 處理搜尋結果
    /// - Parameters:
    ///   - results: 搜尋結果
    ///   - keyword: 使用者搜尋的關鍵字（觀察用）
    private func handleSearchResults(results: [SearchResult], keyword: String) {
        searchResults = results
        if results.isEmpty {
            print("沒有找到符合 '\(keyword)' 的結果")
        }
    }
    
    /// 處理搜尋過程中的錯誤
    /// - Parameter error: 錯誤訊息
    private func handleSearchError(error: Error) {
        print("搜尋資料時出錯：\(error.localizedDescription)")
        // 有在資料加載失敗時，才顯示 Alert 提示「資料無效」，並將searchResults設置為[]，使視圖畫面呈現「NO Result」，確保畫面沒有殘留的資料。
        showDataUnavailableAlert()
        searchResults = []
    }
    
    // MARK: - View State Updates
    
    /// 根據搜尋結果資料更新搜尋視圖的狀態
    /// - 當沒有搜尋結果時，顯示「無搜尋結果」的提示
    /// - 當有搜尋結果時，顯示搜尋結果列表
    private func updateViewStateBasedOnSearchResults() {
        if searchResults.isEmpty {
            updateView(for: .noResults)
        } else {
            updateView(for: .results)
        }
        reloadTableViewIfNeeded()
    }
    
    /// 更新搜尋視圖的狀態
    /// - 根據不同的狀態 (`initial`、`noResults`、`results` 等) 進行視圖的適當顯示
    private func updateView(for state: SearchViewState) {
        searchView.updateView(for: state)
    }
    
    /// 檢查是否需要重新載入表格資料
    /// - 每當搜尋結果更新時，重新載入表格以確保最新結果顯示
    private func reloadTableViewIfNeeded() {
        searchView.tableView.reloadData()
    }
    
    // MARK: - Alert Handling

    /// 顯示資料不可用的警示，提示使用者決定是否重新加載資料
    private func showDataUnavailableAlert() {
        AlertService.showAlert(
            withTitle: "資料無效",
            message: "目前資料無法使用，您可以點擊「載入」按鈕重新載入資料或取消操作。",
            inViewController: self,
            confirmButtonTitle: "載入",
            cancelButtonTitle: "取消",
            showCancelButton: true
        ) { [weak self] in
            self?.reloadDrinkData()
        }
    }
    
    /// 顯示資料載入失敗的警示，告知使用者可以稍後重試
    private func showLoadFailureAlert(message: String) {
        AlertService.showAlert(
            withTitle: "載入失敗",
            message: message,
            inViewController: self,
            confirmButtonTitle: "確定",
            showCancelButton: false
        )
    }
    
    // MARK: - Network Monitoring

    /// 加載飲品資料，並處理網路狀態監控和 HUD 顯示
    /// - 使用網路狀態監控器來確保在網路可用時才進行資料加載，避免無效的請求
    private func reloadDrinkData() {
        let searchNetworkMonitor = SearchNetworkMonitor()
        HUDManager.shared.showLoading(text: "加載中...")
        searchNetworkMonitor.onStatusChange = { [weak self] status in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch status {
                case .satisfied:
                    self.startLoadingDrinkData(with: searchNetworkMonitor)
                case .unsatisfied:
                    self.handleNetworkUnavailable(searchNetworkMonitor: searchNetworkMonitor)
                default:
                    break
                }
            }
        }
        searchNetworkMonitor.startMonitoring()
    }
    
    // MARK: - Data Loading

    /// 開始加載飲品資料
    /// - 這裡負責資料加載邏輯，並處理成功或失敗的結果
    private func startLoadingDrinkData(with searchNetworkMonitor: SearchNetworkMonitor) {
        Task {
            do {
                print("[網路狀態: 正常] 開始加載飲品資料...")
                try await SearchDrinkDataLoader.shared.loadOrRefreshDrinksData()
                print("[網路狀態: 正常] 成功加載飲品資料，並存入本地快取")
                self.handleDataLoadSuccess(searchNetworkMonitor: searchNetworkMonitor)
            } catch {
                self.handleDataLoadFailure(error: error, searchNetworkMonitor: searchNetworkMonitor)
            }
        }
    }
    
    /// 處理資料加載成功的邏輯
    /// - 當資料成功加載後，停止網路監控並隱藏載入指示器
    private func handleDataLoadSuccess(searchNetworkMonitor: SearchNetworkMonitor) {
        HUDManager.shared.dismiss()
        searchNetworkMonitor.stopMonitoring()
    }
    
    /// 處理資料加載失敗的邏輯
    /// - 當資料加載失敗時，顯示錯誤訊息並停止網路監控
    private func handleDataLoadFailure(error: Error, searchNetworkMonitor: SearchNetworkMonitor) {
        print("[網路正常] 資料加載失敗，錯誤原因：\(error.localizedDescription)")
        HUDManager.shared.dismiss()
        showLoadFailureAlert(message: "資料加載失敗，請稍後再試。")
        searchNetworkMonitor.stopMonitoring()
    }
    
    /// 處理網路不可用的情況
    /// - 當網路連接不可用時，顯示警示並停止網路監控
    private func handleNetworkUnavailable(searchNetworkMonitor: SearchNetworkMonitor) {
        print("[網路狀態: 不可用] 網路連接不可用，請檢查網路")
        HUDManager.shared.dismiss()
        showLoadFailureAlert(message: "網路不可用，請檢查網路連接後再試。")
        searchNetworkMonitor.stopMonitoring()
    }

}

// MARK: - SearchResultsDelegate
extension SearchViewController: SearchResultsDelegate {
    
    /// 返回目前的搜尋結果
    /// - `SearchHandler` 使用此方法來獲取顯示資料
    func getSearchResults() -> [SearchResult] {
        return searchResults
    }
    
    /// 當使用者選擇某個搜尋結果時觸發
    /// - Parameter result: 被選中的 `SearchResult`
    /// - 說明：導航至 `DrinkDetailViewController`，顯示飲品的詳細資訊
    func didSelectSearchResult(_ result: SearchResult) {
        print("Selected: \(result.name)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let drinkDetailVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController else {
            return
        }
        // 將選中的 `SearchResult` 資料傳遞給 `DrinkDetailViewController`
        drinkDetailVC.categoryId = result.categoryId
        drinkDetailVC.subcategoryId = result.subcategoryId
        drinkDetailVC.drinkId = result.drinkId
        navigationController?.pushViewController(drinkDetailVC, animated: true)
    }
    
}

// MARK: - SearchControllerInteractionDelegate
extension SearchViewController: SearchControllerInteractionDelegate {
    
    /// 當使用者在搜尋框中更新文字時觸發
    /// - Parameter searchText: 使用者輸入的搜尋文字
    /// - 根據輸入的文字進行即時搜尋，若為空則恢復初始狀態
    func didUpdateSearchText(_ searchText: String) {
        if searchText.isEmpty {
            print("搜尋文字被清空，恢復初始狀態")
            searchResults = []
            updateView(for: .initial)
            return
        }
        // 當資料已加載且搜尋文字不為空時，進行搜尋操作
        print("正在過濾搜尋資料，關鍵字為：'\(searchText)'")
        filterSearchData(with: searchText)
    }
    
    /// 當使用者取消搜尋時觸發，清空搜尋結果並恢復初始狀態
    func didCancelSearch() {
        searchResults = []
        print("使用者取消了搜尋，恢復初始狀態")
        updateView(for: .initial)
    }
    
}
