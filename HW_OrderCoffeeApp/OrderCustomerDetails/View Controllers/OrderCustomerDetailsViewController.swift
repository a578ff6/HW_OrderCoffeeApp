//
//  OrderCustomerDetailsViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/8.
//

// MARK: - ## 關於我的設計需求跟角度，分析來理解和設計 OrderCustomerDetailsViewController 以及 CustomerDetailsManager：

/**
 ## 關於我的設計需求跟角度，分析來理解和設計 OrderCustomerDetailsViewController 以及 CustomerDetailsManager：

` &. 關於 OrderCustomerDetailsViewController 的資料填入設計：`
    
    - 主要的問題是在顯示使用者資料（如姓名、電話、地址等）時，是否要事先將這些資料填入對應的輸入欄位，還是給使用者一個選項去決定是否使用 `UserDetails` 中的資料。

 `* 方案 1：自動填入資料`
 
    - 在加載 `OrderCustomerDetailsViewController` 時，如果 `UserDetails` 中有相關的資料（如姓名、電話、地址），可以直接填入到對應的輸入欄位中，這樣可以簡化使用者的操作。
    - 使用者可以自由地修改這些預填的資料，以適應訂單不一定是本人下的情境。
 
 `* 方案 2：提供選項讓使用者選擇`
 
    - 可以在每個對應欄位旁設置一個開關（例如勾選框或按鈕），讓使用者選擇是否使用 `UserDetails` 中的資料。
    - 如果使用者勾選了使用 `UserDetails` 中的資料，但該資料為空，則提示使用者前往「編輯使用者視圖控制器」補充資料。
 
 ## PS: 根據使用者體驗（UX）來決定。通常，預先填入資料能提升便利性，除非用戶特別偏好選擇自己是否要使用原資料。
 */


// MARK: - 各個元件佈局的設計方向

/**
 * 在建立了 `CustomerDetailsManager` 來管理顧客資料，後會使 `OrderCustomerDetailsViewController` 變得更簡潔，專注於 UI 和與使用者的交互部分。

 `1. OrderCustomerDetailsViewController：`
    - 負責顯示和處理與顧客資料的交互，例如讓使用者輸入姓名、電話號碼等資訊。
    - 可以使用 `CustomerDetailsManager` 來初始填入顧客的相關資料。

 `2. OrderCustomerDetailsView：`
    - 可以設置表單的 UI 元件，比如姓名、電話、取件方式等的輸入框。
    - 將 UI 部分和邏輯部分分開，這樣能夠保持程式碼的清晰度和可維護性。

 `3. OrderCustomerDetailsLayoutProvider：`
    - 負責提供元件的佈局，包括各個 UI 元件的位置與間距，保持頁面的整齊和一致性。

 `4. OrderCustomerDetailsHandler：`
    - 可以用來處理用戶操作和事件，比如當用戶選擇宅配時自動顯示地址欄位，或當用戶選擇店取時顯示選店的按鈕。

 `5. 元件佈局 Cell：`
    - 可以將不同輸入框的邏輯拆分到各自的 Cell 中，這樣可以減少每個 Cell 的複雜度，並且更容易重複使用。
 */


// MARK: - 結構處理順序（重要）

/**
` 1. 填充初始顧客資料 (CustomerDetailsManager)
`
    - 當進入 `OrderCustomerDetailsViewController` 時，首先透過 Firebase 獲取當前的 `UserDetails`，然後使用 `CustomerDetailsManager.populateCustomerDetails(from:)` 方法來填充初始顧客資料。
    - 這樣可以確保在 `UICollectionView` 中的各個 Cell 會顯示用戶之前已經填寫好的資料（如果有的話），例如姓名、電話、取件方式等。

` 2. 配置各個 Cell

    - 在 `OrderCustomerDetailsHandler` 的 `cellForItemAt` 方法中配置各個 Cell。每個 Cell 的主要目的是收集顧客資料中的不同部分，並將這些資料透過 `CustomerDetailsManager` 進行集中管理。
    - 在每個 Cell 中根據 `CustomerDetailsManager.getCustomerDetails()` 來設置 UI，確保每個 Cell 顯示正確的資料。例如：
      - `OrderCustomerInfoCell`：顯示姓名和電話號碼。
      - `OrderPickupMethodCell`：顯示取件方式和相關的輸入欄位（例如地址或店家名稱）。
      - `OrderCustomerNoteCell`：顯示備註欄位，讓用戶填寫額外的需求。
      - `OrderCustomerSubmitCell`：提供提交訂單的按鈕。

` 3. 處理資料變更`
    - 在每個 Cell 內部監聽輸入變更，例如使用者編輯電話號碼或更改取件方式時，透過 Callbacks 更新 `CustomerDetailsManager` 的資料。
    - 這樣可以確保每當用戶在 UI 中修改資料時，`CustomerDetailsManager` 都會立即同步更新對應的資料。
    - 例如，在 `OrderPickupMethodCell` 中選擇店家名稱後，更新 `CustomerDetailsManager` 中的 `storeName`。

` 4. 驗證顧客資料的完整性`
    - 在用戶點擊提交訂單按鈕時，透過 `CustomerDetailsManager.validateCustomerDetails()` 方法來檢查資料是否完整。
    - 若資料不完整，例如缺少姓名或地址，應該顯示提示訊息並阻止提交。（測試用）
    - `OrderCustomerSubmitCell` 可以在按鈕被點擊時執行這個驗證過程。如果驗證通過，則進一步提交訂單到 Firebase。（測試用）
 
`    （實作上是當資料不完整時，會禁用按鈕。等到必填資料完成後，才會啟用。）`
 
 `5. 提交訂單`
    - 如果顧客資料通過了驗證，可以開始建立 `Order` 物件。
    - 使用 `CustomerDetailsManager.getCustomerDetails()` 來獲取最新的顧客資料，並與當前的 `orderItems` 組合，創建一個完整的 `Order`。
    - 將這個 `Order` 傳遞給 Firebase，完成訂單的提交。

 
` ### 各個元件的角色和處理流程`

 1. `CustomerDetailsManager`
    - 負責存儲和管理顧客資料。
    - 提供填充初始資料、獲取當前資料和驗證資料完整性的功能。
    - 是顧客資料的唯一數據來源，所有的 Cell 都與它交互。

 2. `OrderCustomerDetailsHandler`
    - 作為 `UICollectionViewDataSource`，負責管理各個 Cell。
    - 在每個 Cell 初始化時，從 `CustomerDetailsManager` 獲取資料進行設置。
    - 在各個 Cell 內的回調中，更新 `CustomerDetailsManager` 的資料。

 3. 各個 Cell (`OrderCustomerInfoCell`, `OrderPickupMethodCell`, `OrderCustomerNoteCell`, `OrderCustomerSubmitCell`)
    - 每個 Cell 對應不同的顧客資料輸入部分。
    - 利用回調機制將資料的變更回傳給 `CustomerDetailsManager`，確保每個資料的輸入部分都能及時更新。

 4. `OrderCustomerDetailsViewController`
    - 負責管理頁面的整體邏輯，包括顯示初始資料、處理提交訂單的操作等。
    - 對於提交按鈕的操作，可以利用 `CustomerDetailsManager.validateCustomerDetails()` 來確保所有資料完整。

 5. `OrderManager`
    - 提交整個訂單，因為這涉及將顧客資料 (`CustomerDetails`) 和訂單項目 (`OrderItem`) 整合到一個訂單 (`Order`) 結構中，並完成提交過程。
    - `OrderManager` 可以負責與 Firebase 的交互，例如創建新訂單等。
 
 
 `### 步驟`

 `1. 填充初始資料：`
        - `CustomerDetailsManager` 從 `UserDetails` 中填充資料。
 
` 2. 配置 `UICollectionView` 的 Cell：`
        - 通過 `OrderCustomerDetailsHandler` 根據 `CustomerDetailsManager` 填充資料。
 
 `3. 監聽資料變更：`
        - 各個 Cell 使用回調方式更新 `CustomerDetailsManager`。
 
 `4. 提交訂單：`
        - `OrderCustomerSubmitCell` 點擊後驗證資料完整性，成功後將訂單提交至 Firebase。
*/


// MARK: - 「submit」按鈕的邏輯判斷，與 CustomerDetailsManager 設計方向。（重要）

/**
 - 當初在建構 `CustomerDetailsManager` 的時候，是想說透過點擊 `submit` 按鈕後來透過「警告訊息」得知「資料」是否有填寫完成。並且也是方便去做 Test。
 - 因此原邏輯適合在「按鈕沒有啟用禁用的邏輯，並顯示警告訊息」的情況下，因為初始狀態下按鈕始終處於可點擊狀態，直到提交訂單時才會根據驗證結果顯示警告。
 - 然而，我後來決定將 `OrderCustomerDetailsViewController` 與 `OrderItemViewController` 的按鈕風格進行統一，希望按鈕能根據欄位的「填寫狀態」啟用或禁用時，要在畫面初始載入時應進行檢查。
 
` &. 選擇設計：`

    * `按鈕沒有啟用禁用的邏輯，並顯示警告訊息（方案1）`：
        - 如果希望用戶可以隨時嘗試提交訂單，即便某些必填欄位未填寫，這樣的設計會更合適。
        - 當用戶點擊提交按鈕時，可以顯示一個警告或提示，用戶需完成某些欄位才能繼續。這樣能夠讓用戶有更多的控制權，也更能吸引注意力到需要修正的部分。
        - 此方式較適合那些希望給用戶更多靈活性、避免用戶在填寫時感到受限的應用場景。
 
    * `按鈕會有啟用禁用的邏輯（方案2）`：
        - 如果想要強制用戶在所有必填欄位都完成後才能提交訂單，這種方式會更合適。
        - 禁用提交按鈕直到所有必填欄位都正確填寫，可以減少用戶的錯誤操作，從而提升用戶體驗和資料正確性。
        - 這種方式特別適合那些必須保證每個提交操作都正確無誤的應用場景，例如在外送或支付相關流程中，這樣做可以降低出現錯誤的機會。
 
    * `依照構想情境`：
        - 如果用戶在沒有填寫必填欄位的情況下仍可點擊按鈕並提交訂單，且會顯示錯誤訊息，那麼方案1適合原本的邏輯。
        - 然而，如果我改成想更積極地防止用戶提交錯誤資料，方案2會更好，特別是當這些資料對於訂單的完整性非常重要時。

 `&. 建議`：
    - 如果要保持方案1的邏輯，可以加入詳細的錯誤提示，讓用戶知道哪些欄位需要完成。
    - 如果想改成方案2，需要注意按鈕的初始狀態及欄位狀態變更時即時更新，避免一開始按鈕就被誤啟用。
 */


// MARK: - 關於 OrderCustomerDetailsViewController 的 updateSubmitButtonState() 和 cellForItemAt 中的按鈕狀態設置
/**
 
 ## 關於 OrderCustomerDetailsViewController 的 updateSubmitButtonState() 和 cellForItemAt 中的按鈕狀態設置：
 
 - `OrderCustomerDetailsViewController` 的 `updateSubmitButtonState() `和 `OrderCustomerDetailsHandler` 中 `cellForItemAt` 的按鈕狀態設置有相似的邏輯，但它們在不同的時機被調用，因此它們在功能上還是有所區分的：

 
    `1. cellForItemAt 中的按鈕狀態設置：`
        - 這部分負責在每次創建 `SubmitCell` 時進行按鈕狀態的初始設置。也就是當 `SubmitCell` 在畫面中被展示時，能根據當前的資料狀態初始化按鈕的可用性。
        - 在第一次進入畫面、`reloadData() `之後或當 `Collection View` 滑動而需要重新加載 Cell 時會被調用。
 
    `2. OrderCustomerDetailsViewController 的 updateSubmitButtonState()`：
        - 這個方法在資料變更時被調用，例如顧客在輸入姓名、電話或選擇取件方式時，以確保資料變更後按鈕狀態即時更新。
        - 它適用於動態資料更新的情境，尤其是當用戶對資料進行修改時，即時判斷表單是否已填滿。

    `3. 因此，這兩部分可以保持分開使用`：
        - `cellForItemAt` 負責初始化狀態，確保在 Cell 創建時狀態正確。
        - `updateSubmitButtonState() `負責在資料變更時動態更新，保持按鈕狀態即時響應。
 */


// MARK: -  navigateToStoreSelection 的功能和設計
/**
 ## navigateToStoreSelection 的功能和設計
 
 * `功能目的`：
    - `navigateToStoreSelection` 方法主要用於導航至 `StoreSelectionViewController`，讓用戶可以選擇取件門市。這對於支持多門市取件選擇的應用程式非常重要。

 * `設計重點`：
    - 利用 `UINavigationController` 包裝 `StoreSelectionViewController` 並進行全螢幕呈現，確保使用者擁有完整的操作體驗，同時保持標準的導航欄功能。
    - 使用委託模式 (delegate) 來確保用戶選擇門市後，返回 `OrderCustomerDetailsViewController` 時，可以即時接收和更新門市選擇結果。
 
 * `錯誤處理`：
    -  若無法找到 ID 為 `storeSelectionViewController` 的視圖控制器，則會輸出錯誤訊息以便於調試和避免應用崩潰。
 */


// MARK: -  storeSelectionDidComplete 的功能和設計

/**
 ## storeSelectionDidComplete 的功能和設計

 * `功能目的`：
   
    - `storeSelectionDidComplete` 方法在用戶選擇完門市後被調用，主要負責將選擇的門市資訊更新到 `CustomerDetails`，並刷新 UI 以顯示最新選擇的結果。

 * `設計重點`：
    - 通過委託模式來接收 `StoreSelectionViewController` 返回的門市名稱，並更新顯示在 `OrderCustomerDetailsViewController` 的 UI 上。
    - 使用 `CustomerDetailsManager` 來管理和存儲顧客資料，確保選擇的門市資訊能正確同步。
    - 在更新門市名稱後，刷新取件方式的區域，確保顯示的門市資訊始終與用戶選擇一致。

 * `錯誤處理`：
    - 若在更新過程中出現錯誤，可以考慮加入錯誤提示，提醒用戶重新選擇或檢查網路狀況。
 */


// MARK: - 門市選擇流程（重要）

/**
 * # 門市選擇流程
 * 本流程涉及 `StoreSelectionViewController`, `StoreInfoViewController`, `StoreSelectionResultDelegate` 的設置，
 * 以及 `OrderCustomerDetailsViewController`, `OrderPickupMethodCell`, `OrderCustomerDetailsHandler` 的調整設置。
 *
 * 1. 使用者在 `OrderCustomerDetailsViewController` 中選擇取件方式為「到店自取」，並點擊選擇店家按鈕。
 * 2. `navigateToStoreSelection` 方法被調用，導航至 `StoreSelectionViewController`。
 * 3. 使用者選擇店家，並通過 `StoreSelectionResultDelegate` 的 `storeSelectionDidComplete` 回傳結果至 `OrderCustomerDetailsViewController`。
 * 4. 在返回時，`OrderCustomerDetailsViewController` 通知 `OrderPickupMethodCell` 更新選擇的門市名稱，以確保顯示同步。
 */


// MARK: - 筆記: 門市選擇流程與顧客資料視圖間的整合
/**
 ## 筆記: 門市選擇流程與顧客資料視圖間的整合
 
 `1. StoreSelectionViewController 與 StoreInfoViewController 的設置`：

 * `StoreSelectionViewController`:
    - 用於顯示所有可供選擇的門市，並讓使用者選擇一個門市。該視圖控制器負責顯示店家列表或地圖，讓使用者進行選擇。

 * `StoreInfoViewController`:
    - 提供門市的詳細資訊，例如門市名稱、地址、營業時間等。當使用者選擇特定門市後，這些資訊會顯示在此視圖控制器中。

 * `StoreSelectionResultDelegate`:
    - 定義了一個協議，用於通知門市選擇完成的結果。當使用者選擇門市後，`storeSelectionDidComplete(with storeName: String) `方法會被調用來通知結果。
 
 `2. OrderCustomerDetailsViewController 的調整`:

 * `StoreSelectionResultDelegate 的使用`：

    * `設置代理`:
        - 在 `OrderCustomerDetailsViewController` 中設置 `StoreSelectionViewController` 的代理為 self，以便在使用者完成選擇後接收通知。
 
    * `storeSelectionDidComplete 方法`:
        - 當使用者選擇門市後，此方法被調用來更新 `CustomerDetailsManager` 中的 `storeName`。接著透過重新載入取件方式的 `section`，來保證最新的門市名稱顯示於視圖中。
 
 `3. OrderPickupMethodCell 的設置與調整`:

    * `選擇門市按鈕 (selectStoreButton)`
        - 在 `selectStoreButtonTapped() `方法中，透過 `onStoreButtonTapped` 回調來觸發外部動作，進而導航至 `StoreSelectionViewController`。

    * `更新門市顯示`
        - 在選擇完門市後，會使用 `onStoreChange` 回調來更新顯示於 storeTextField 的門市名稱。
        - 在` configure(with:) `方法中根據 `CustomerDetails` 的值來初始化 `storeTextField`，以確保顯示內容正確。
 
 `4. OrderCustomerDetailsHandler 的設置與調整`:

    * `configurePickupMethodCell 方法`
        - 在配置 `OrderPickupMethodCell` 時，使用來自 `CustomerDetailsManager` 的最新資料來更新 cell 的顯示。
        - 當 `onStoreButtonTapped` 回調被觸發時，會通知代理 ( `OrderCustomerDetailsViewController`) 來進行店鋪選擇的導航。
        - 當店家選擇完成後，使用 `onStoreChange` 來更新顧客資料並通知外部變更，以便同步更新 UI 和資料。

 `5. 重要的調整點`:

    * `重新載入 Section`:
        - 為了確保 `storeTextField` 能及時更新，需要在 `storeSelectionDidComplete` 中重新載入 `OrderPickupMethodCell` 所在的 `section`，這樣才能保證最新的店鋪選擇結果能立即顯示在 UI 上。

    * `資料與 UI 的同步`:
        - 在 `CustomerDetailsManager` 中更新資料後，務必確保對應的 UI 也能及時更新，例如透過回調或重新載入 collection view 的特定區域。
 */


// MARK: - 資料驅動的 UI 配置重點筆記（重要）
/**
 ## 資料驅動的 UI 配置重點筆記

 `1. 問題描述：`
    - 在初次進入 "`OrderCustomerDetailsViewController`" 時，顯示的 UI 欄位（例如姓名、電話、取件方式）先呈現空值或必填紅框，再過一瞬間資料才被填入。
    - 再次進入時，UI 顯示是正確的，沒有顯示空值或閃爍的情況。

 `2. 解決方法：`
    - 延遲初始化 `OrderCustomerDetailsHandler`：
      - 將 `OrderCustomerDetailsHandler` 的初始化移至資料加載完成之後進行，而不是在 `viewDidLoad()` 中。
      - 在 `fetchAndPopulateUserDetails()` 方法的 `do` 區塊中，待資料加載成功後再初始化 `OrderCustomerDetailsHandler` 並設置 `CollectionView`。

` 3. 優點：`
    - `確保資料完整性`：確保 `CollectionView` 初始化時有完整且正確的顧客資料，避免顯示不完整或閃爍的情況。
    - `提高用戶體驗`：減少頁面初次載入時顯示的異常狀況，例如紅框提示或空白欄位，使得 UI 在用戶看到時已經是最終狀態。

 4. `實作步驟`：
    - 先在 `fetchAndPopulateUserDetails()` 中獲取資料。
    - 當資料獲取成功後，再初始化 `OrderCustomerDetailsHandler` 並設置 `CollectionView` 的數據源和代理。

 `5. 應用場景：
    - `遠端資料加載`：特別適合需要從遠端獲取資料並進行顯示的場景，能有效避免 UI 與資料不同步的問題。
    - `減少 UI 異常顯示`：用於希望避免 UI 因為資料尚未加載完成而顯示異常的情況，例如空白或錯誤提示。

 `6. 結論：`
    - 這種方式屬於 "`資料驅動的 UI 配置`"，即 UI 的配置依賴於資料的準備狀態。這可以提高頁面載入的穩定性，讓用戶在初次看到界面時就能獲得良好的體驗。
 */

// MARK: - 資料驅動的 UI 配置（重要）

/**
 ## 資料驅動的 UI 配置
    
 * 意思是 UI 的初始化和配置是由資料是否準備好來決定的。這種做法特別適合以下情況：

1. 需要從`遠端`獲取資料，且資料獲取有一定的`延遲`。
2. 顯示的內容高度依賴於資料的完整性。
3. 希望避免用戶在資料還未加載完成之前看到不完整或錯誤的 UI。
4. 雖然這會導致頁面初次載入時稍有延遲，但大部分用戶更能接受的是一個稍微晚一點但已經準備好的界面，而不是一個閃爍或者顯示錯誤提示的界面。

- 這種做法也不是必須的，取決於具體的需求和應用場景。
 - 在 App 中，如果 UI 需要即時顯示而且對資料的即時性要求不高，開發者可能會先顯示一個佔位符界面或是加載動畫，再逐步填充資料。
 */


// MARK: - 訂單提交結果設計
/**
 ## 訂單提交結果設計

 `## What：處理訂單提交成功與提交失敗的設計`
    - 在 `OrderCustomerDetailsViewController` 中設計提交訂單後的行為，包括如何處理提交成功和提交失敗的情境。

 `## Why：提供用戶清晰的反饋並確保訂單流程順暢`
    - `提交成功`：讓用戶能夠確認訂單是否成功被處理，並展示相關訂單資訊，以增強用戶的信心和體驗。
    - `提交失敗`：迅速告知用戶錯誤原因，避免因不明錯誤導致用戶困惑，並提供簡單操作讓用戶重試提交。

 `## How：提交成功與失敗的設計`

` ### 提交成功`
 
` 1. OrderConfirmationViewController：`
    - 在提交成功後，導航到 `OrderConfirmationViewController`，顯示提交成功的訊息和訂單詳細資訊。
    - 在該視圖中設置「關閉」按鈕，讓用戶可以手動確認完成訂單流程。
    - 按下「關閉」按鈕後，清空使用者的填寫資料與訂單飲品項目，並返回上一層視圖控制器，準備新的訂單流程。

` ### 提交失敗`
 
` 1. 使用 Alert 通知用戶：`
    - 在提交失敗時，彈出 Alert，告知錯誤訊息並提供可選操作（例如「重試」或「取消」）。
    - Alert 是一個簡單且即時的解決方案，適合大多數的提交失敗情況，讓用戶能快速理解問題並做出下一步行動。

` ### 做法`
 
 - `提交成功`：使用 `OrderConfirmationViewController` 讓用戶確認訂單資訊，提供完整的提交確認體驗。
 - `提交失敗`：使用 Alert 簡單有效地通知用戶並提供重試選項，以減少流程摩擦。
 */


// MARK: - 訂單提交失敗的情況設計
/**
 ## 訂單提交失敗的情況設計
 
    - 在訂單提交失敗的情況下，通常使用 Alert 是比較適合的方式。原因是提交失敗的情況下，用戶可能只需要了解錯誤原因，然後重新提交或檢查表單內容。

 `以下是兩種選擇的考量：`

 `1. 使用 Alert`
 
    * `Why：`

    - `簡潔且即時`：Alert 能迅速吸引用戶的注意，告知錯誤原因並提供簡單的選項（如「重試」或「取消」）。
    - `不需要額外畫面`：提交失敗通常是臨時性狀況，不需要用戶長時間停留或查看更多詳情。
 
    * `How：`

    - 在提交失敗後彈出 Alert，包含錯誤訊息，以及可供用戶選擇重試的按鈕。例如：
    - 標題：訂單提交失敗
    - 訊息：訂單提交過程中出現錯誤，請稍後再試。
    - 按鈕：「重試」或「取消」
 
 `2. 使用專門的視圖控制器`
 
    * `Why`：

    - `提供更豐富的反饋`：如果想要對失敗的情況提供更多的反饋和解決方案，例如更多的錯誤詳細描述、建議操作，或是希望用戶填寫更多的資訊。
    - `設計統一體驗`：有時在某些應用中，設計一致的成功和失敗頁面可能會讓整體體驗看起來更專業。
 
    * `How`：

    - 在訂單提交失敗後，導航到專門的錯誤視圖控制器，該視圖會詳細顯示錯誤訊息，並提供重新提交的選項。
 
  `3. 推薦做法：`

    - 對於大多數 App，使用 Alert 足以解決提交失敗的情況，因為這樣可以簡單且有效地通知用戶，並減少用戶在流程中的摩擦。如果只是一些網路不穩定或表單不完整的錯誤，Alert 會比較簡便。
    - 若是提交失敗的原因非常重要且需要用戶進行較多操作，或是你希望有更多設計統一的反饋視圖，那麼使用專門的視圖控制器會是更好的選擇。
 */


// MARK: - 筆記：`didUpdatePickupMethod`、`didUpdateCustomerStoreName` 與 `didUpdateCustomerAddress` 的行為差異
/**
 
 ## 筆記：`didUpdatePickupMethod`、`didUpdateCustomerStoreName` 與 `didUpdateCustomerAddress` 的行為差異

` * What`
 
 1. `didUpdatePickupMethod`：
 
    - 當使用者切換取件方式（例如從 "外送" 切換到 "到店自取"）時，觸發此方法。
    - 此方法負責：
      - 更新顧客資料中的取件方式（`PickupMethod`）。
      - 根據新的取件方式刷新 `OrderPickupMethodCell` 的 UI。
      - 更新提交按鈕的狀態。

 2. `didUpdateCustomerStoreName` 和 `didUpdateCustomerAddress`：
 
    - 當使用者更新店家名稱或外送地址時，觸發這些方法。
    - 此方法負責：
      - 更新顧客資料中的店家名稱或地址。
      - 檢查資料是否完整並更新提交按鈕的狀態。
      - 不涉及刷新整個 Cell，因為 TextField 的輸入框會即時更新。

 ---

 `* Why`
 
 1. `didUpdatePickupMethod` 需要刷新 Cell：
 
    - 切換取件方式會影響整個 Cell 的 UI，例如：
      - 切換為 "外送" 時需要顯示地址輸入框並隱藏選擇店家的按鈕。
      - 切換為 "到店自取" 時需要顯示選擇店家的按鈕並隱藏地址輸入框。
    - 因此，需要呼叫 `reloadPickupMethodCell` 確保 Cell 的顯示內容與新的取件方式一致。

 2. `didUpdateCustomerStoreName` 和 `didUpdateCustomerAddress` 不需要刷新 Cell：
 
    - 這些方法僅更新單個輸入框（如店家名稱或地址），TextField 本身的回調已處理 UI 的即時更新。
    - 不需要重新載入整個 Cell，避免額外的資源浪費與閃爍。

 ---

 `* How`

 1. `didUpdatePickupMethod` 的實現：
 
    - 更新資料模型。
    - 檢查提交按鈕的狀態。
    - 呼叫 `reloadPickupMethodCell` 刷新取件方式相關的 UI。

    ```swift
    func didUpdatePickupMethod(_ method: PickupMethod) {
        CustomerDetailsManager.shared.updatePickupMethod(method)
        updateSubmitButtonState()
        reloadPickupMethodCell() // 重新載入 UI
    }
    ```

 2. `didUpdateCustomerStoreName` 的實現：
 
    - 僅更新資料模型與提交按鈕狀態，讓 TextField 即時更新內容。

    ```swift
    func didUpdateCustomerStoreName(_ storeName: String) {
        CustomerDetailsManager.shared.updateStoredCustomerDetails(storeName: storeName)
        updateSubmitButtonState() // 僅更新提交按鈕狀態
    }
    ```

 3. `didUpdateCustomerAddress` 的實現：
 
    - 同樣僅更新資料模型與提交按鈕狀態。

    ```swift
    func didUpdateCustomerAddress(_ address: String) {
        CustomerDetailsManager.shared.updateStoredCustomerDetails(address: address)
        updateSubmitButtonState() // 僅更新提交按鈕狀態
    }
    ```

 4. 確認邏輯正確性：
 
    - 在方法內添加 `print` 確認回調被正確觸發。
    - 測試切換取件方式時，檢查 Cell 的 UI 是否正確更新。
    - 測試修改地址與店家名稱時，確認輸入框即時更新且無閃爍。

 ---

 `* 總結`
 
 - What：針對取件方式、店家名稱與地址的更新，處理方式因 UI 影響範圍不同而有所區別。
 - Why：取件方式影響整體 UI，需刷新 Cell；地址與店家名稱僅影響局部，不需刷新 Cell。
 - How：
   - `didUpdatePickupMethod`：更新資料並刷新 Cell。
   - `didUpdateCustomerStoreName` 和 `didUpdateCustomerAddress`：僅更新資料與提交按鈕狀態，避免不必要的 Cell 刷新。
 */




// MARK: - 筆記：OrderCustomerDetailsHandler 與 OrderCustomerDetailsViewController 中 PickupMethodCell 責任分工
/**
 
 ## 筆記：OrderCustomerDetailsHandler 與 OrderCustomerDetailsViewController 中 PickupMethodCell 責任分工

 ---

` * What`
 
 - `OrderCustomerDetailsHandler` 和 `OrderCustomerDetailsViewController` 都使用了 `OrderPickupMethodCell` 的 `configure` 方法，但其目的和適用場景不同：
 
 1. `configurePickupMethodCell`：由 Handler 負責，初始化或重建整個 Cell 的顯示。
 2. `reloadPickupMethodCell`：由 ViewController 負責，用於局部刷新，更新特定 Cell 的內容。

 ---

 `* Why`
 
 - 避免重疊功能導致責任模糊，提升程式架構的清晰度與可維護性。
 
 `1. 清晰的責任分工：`
 
    - Handler 專注於初次配置 Cell（靜態場景）。
    - ViewController 負責局部數據更新（動態場景）。
 
 `2. 性能優化：`
 
    - 初始化場景中，`Handler` 通過 `cellForItemAt` 配置所有 Cell。
    - 在用戶交互後，`ViewController` 只更新必要的 `Cell`，避免整體重繪。
 
 `3. 統一數據源：`
 
    - 確保所有顯示數據來自 `CustomerDetailsManager`，避免不同部分直接操作 Cell，導致邏輯分散。

 ---

 `* How`
 
 `1. 清晰責任劃分`
 
 - `OrderCustomerDetailsHandler`：
 
   - 負責 Cell 的初始化與配置。
   - 實現所有表單的初次加載邏輯。
 
 - `OrderCustomerDetailsViewController`：
 
   - 負責數據更新後的局部刷新。
   - 僅在特定用戶交互後，更新指定 Cell。

 `2.. 確保數據源統一`
 
 - 所有 Cell 的數據來源應統一為 `CustomerDetailsManager`。
 - 避免 Handler 或 ViewController 中直接操作 Cell 的屬性。

 `3. 整理責任界線`
 
 - `Handler：`
   - 初次加載 CollectionView 時配置所有 Cell。
   - 維持靜態的資料與 UI 映射邏輯。
 
 - `ViewController：`
   - 用戶交互後處理數據變更。
   - 精準更新局部 UI（特定 Cell）。

 ---

 `* 總結`
 
 1. Handler 初始化，ViewController 更新：確保功能分工清晰，降低耦合。
 2. 性能與可維護性：局部刷新避免整體重繪，提升用戶體驗。
 3. 統一數據來源：所有 UI 操作統一來自 `CustomerDetailsManager`，避免分散邏輯。
 */



// MARK: - 筆記：`reloadPickupMethodCell` 更新取件方式與地址顯示
/**
 
 ### 筆記：`reloadPickupMethodCell` 更新取件方式與地址顯示

 ---

 `* What`
 
 - `reloadPickupMethodCell` 是一個用於精確更新取件方式（`PickupMethod`）相關顯示內容的功能方法。
 - 當用戶在 `PickupMethodCell` 中切換取件方式或修改地址時，會透過此方法重新配置對應的 Cell 顯示。

 - 主要功能：
 
 1. 根據當前的顧客資料（`CustomerDetails`）更新取件方式相關的顯示內容。
 2. 當地址或店家名稱更新時，自動清空互斥的欄位（如地址有值時清空店家名稱）。

 - 適用場景：
 
 - 用戶切換取件方式（如「外送服務」到「到店自取」）。
 - 用戶輸入或修改地址、選擇店家名稱。

 -----------------

 `* Why`
 
 - 此功能的目的在於提升用戶體驗並確保資料一致性。

 `1. 即時同步資料與顯示：`
 
    - 在用戶更新資料後，UI 需要即時反映變更，以減少用戶的操作疑惑。
    - 精確定位目標 Cell 進行更新，避免刷新整個畫面，提升性能。

 `2. 資料完整性與邏輯清晰：`
 
    - 地址與店家名稱互斥的邏輯由資料管理器（`CustomerDetailsManager`）統一處理，避免混亂。
    - 確保用戶選擇的取件方式符合顯示內容，例如「外送服務」必須填寫地址、「到店自取」需要店家名稱。

` 3. 提升代碼可維護性：`
 
    - 責任清晰：資料更新由 `CustomerDetailsManager` 負責，UI 更新由 `reloadPickupMethodCell` 處理。
    - 降低刷新範圍：僅更新與用戶操作相關的區域，避免對其他內容造成影響。

 -----------------

 `* How`
 
 以下是 `reloadPickupMethodCell` 的設計與使用方式：

 `1. 資料更新邏輯：`
 
    - 當用戶切換取件方式或更新地址時，`CustomerDetailsManager` 會負責更新相關資料並清空互斥欄位。
 
      ```swift
      if let address = address {
          details.address = address
          details.storeName = nil // 當地址有值時，清空店家名稱
      }
      ```

 `2. 精確更新 UI：`
 
    - 使用 `IndexPath` 精確定位目標 Cell，並重新配置顯示內容。

 ```swift
      private func reloadPickupMethodCell() {
          let pickupMethodIndexPath = IndexPath(item: 0, section: OrderCustomerDetailsHandler.Section.pickupMethod.rawValue)
          guard let pickupCell = orderCustomerDetailsView.orderCustomerDetailsCollectionView.cellForItem(at: pickupMethodIndexPath) as? OrderPickupMethodCell else { return }
          guard let updatedCustomerDetails = CustomerDetailsManager.shared.getCustomerDetails() else { return }
          pickupCell.configure(with: updatedCustomerDetails)
      }
      ```

 `3. 觸發條件：`
 
    - 在相關的回調方法中觸發，例如 `didUpdatePickupMethod``。

 ```swift
      func didUpdatePickupMethod(_ method: PickupMethod) {
          CustomerDetailsManager.shared.updatePickupMethod(method)
          reloadPickupMethodCell()
          updateSubmitButtonState()
      }
      ```

 `4. 測試場景：`
 
    - 測試以下行為是否符合預期：
      - 切換取件方式時，UI 是否即時切換並顯示正確內容。
      - 地址輸入後，店家名稱是否被清空，且反映到 UI。
      - 店家名稱選擇後，地址是否被清空，且反映到 UI。

 -----------------

 `* 總結`
 
 - `reloadPickupMethodCell` 是實現取件方式相關更新的核心方法，通過與資料管理的緊密配合，確保用戶操作的即時性與邏輯一致性。
 - 透過精確更新，既提升了性能又提高了代碼的可維護性。
 */



// MARK: - 筆記：OrderCustomerDetailsViewController
/**
 
 ## 筆記：OrderCustomerDetailsViewController

 `* What`
 
 - `OrderCustomerDetailsViewController` 是負責顯示與處理顧客詳細資料的視圖控制器。它的主要職責包括：
 
 1. 顯示表單：提供填寫顧客姓名、電話、取件方式、備註等信息的界面。
 2. 資料管理：透過 `CustomerDetailsManager` 獲取或更新顧客詳細資料。
 3. 行為處理：通過 `OrderCustomerDetailsHandler` 代理，用於監控表單內的用戶交互，觸發對應邏輯。
 4. 導航功能：處理選擇店家（`StoreSelectionViewController`）和提交訂單（`OrderConfirmationViewController`）的導航行為。

 ------------

 `* Why`
 
 `1. 責任分離：`
 
 - `OrderCustomerDetailsViewController` 負責用戶交互和業務邏輯。
 - `OrderCustomerDetailsHandler` 處理表單的數據源、委託回調和內部交互。
 - 這樣的架構清晰，便於維護和測試。
    
 `2. 資料一致性：`
 
 - 透過 `CustomerDetailsManager` 集中管理資料，確保各部件同步更新。

 `3. 提高用戶體驗：`
 
 - 表單驗證：用戶僅能在資料完整時提交，減少誤操作。
 - 即時更新：當資料變更時自動刷新表單相關區域，避免手動刷新。

 ------------

 `* How`

 `1. 主界面設置：`
 
 - 覆寫 `loadView()` 將 `OrderCustomerDetailsView` 設為主視圖，確保與表單展示一致。
 - 初始化 `OrderCustomerDetailsHandler`，並設置其為表單的 `dataSource` 和 `delegate`。

` 2. 資料處理：`
 
 - 使用 `fetchAndPopulateUserDetails` 從 Firebase 獲取用戶資料，填充 `CustomerDetailsManager`。
 - 當資料變更時，透過委託方法更新資料和提交按鈕狀態，例如 `didUpdatePickupMethod`。

 `3. UI 更新：`
 
 - 使用精準刷新（如 `reloadPickupMethodCell`）避免不必要的整體刷新，確保性能和用戶體驗。
 - 使用 `updateSubmitButtonState` 根據資料驗證結果更新提交按鈕狀態。

 `4. 導航操作：`
 
 - `navigateToStoreSelection`：進入門市選擇界面，並通過委託回傳選擇結果。
 - `presentOrderConfirmationViewController`：提交訂單後進入確認界面。

 `5. 關鍵程式碼：`

    - 資料填充：
 
      ```swift
      private func fetchAndPopulateUserDetails() {
          HUDManager.shared.showLoading(text: "CustomerDetails...")
          Task {
              do {
                  let userDetails = try await FirebaseController.shared.getCurrentUserDetails()
                  CustomerDetailsManager.shared.populateCustomerDetails(from: userDetails)
                  setupOrderDetailsHandler()
              } catch {
                  print("獲取用戶資料時發生錯誤：\(error)")
              }
              HUDManager.shared.dismiss()
          }
      }
      ```

    - 重新加載 PickupMethod Cell：
 
      ```swift
      private func reloadPickupMethodCell() {
          let pickupMethodIndexPath = IndexPath(item: 0, section: OrderCustomerDetailsHandler.Section.pickupMethod.rawValue)
          guard let pickupCell = orderCustomerDetailsView.orderCustomerDetailsCollectionView.cellForItem(at: pickupMethodIndexPath) as? OrderPickupMethodCell else { return }
          guard let updatedCustomerDetails = CustomerDetailsManager.shared.getCustomerDetails() else { return }
          print("[OrderCustomerDetailsViewController] Reloading PickupMethodCell with updated details: \(updatedCustomerDetails)")
          pickupCell.configure(with: updatedCustomerDetails)
      }
      ```

    - 更新提交按鈕狀態：
 
      ```swift
      func updateSubmitButtonState() {
          let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
          let isFormValid = (validationResult == .success)
          let submitIndexPath = IndexPath(item: 0, section: OrderCustomerDetailsHandler.Section.submitAction.rawValue)
          guard let submitCell = orderCustomerDetailsView.orderCustomerDetailsCollectionView.cellForItem(at: submitIndexPath) as? OrderCustomerSubmitCell else { return }
          submitCell.configureSubmitButton(isEnabled: isFormValid)
      }
      ```

 `6. 委託方法：`
 
    - 更新資料：
 
      ```swift
      func didUpdateCustomerName(_ name: String) {
          CustomerDetailsManager.shared.updateStoredCustomerDetails(fullName: name)
          updateSubmitButtonState()
      }
      ```

    - 導航到店家選擇：
 
      ```swift
      func navigateToStoreSelection() {
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          guard let storeSelectionVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.storeSelectionViewController) as? StoreSelectionViewController else {
              return
          }
          storeSelectionVC.delegate = self
          let navigationController = UINavigationController(rootViewController: storeSelectionVC)
          present(navigationController, animated: true, completion: nil)
      }
      ```

 ------------

 `* 總結`

 - 目的：`OrderCustomerDetailsViewController` 提供用戶資料填寫與表單提交功能，確保資料完整性並提升用戶體驗。
 - 優點：責任分離清晰、資料更新即時、架構靈活，適合擴展與測試。
 */


// MARK: - 處理職責


import UIKit


/// `OrderCustomerDetailsViewController` 是用於顯示與處理顧客詳細資料的視圖控制器。
///
/// ### 功能說明
/// - 提供用戶填寫顧客姓名、電話、取件方式、備註等訂單相關資料的功能，確保訂單資料完整性。
/// - 使用自定義的 `OrderCustomerDetailsView` 作為主視圖，負責顯示所有表單項目。
/// - 透過 `OrderCustomerDetailsHandler` 處理表單資料的邏輯，確保資料流轉一致性。
/// - 使用委託模式接收 `OrderCustomerDetailsHandler` 的通知，處理顧客資料變更並更新相關 UI。
///
/// ### 架構亮點
/// - 責任分離:
///   - 視圖控制器: 負責處理用戶交互（例如導航、提交按鈕狀態更新）與業務邏輯。
///   - Handler: 集中處理資料源與表單項目交互邏輯，保持結構清晰。
/// - 用戶體驗優化:
///   - 透過表單驗證確保用戶只能在資料完整後提交訂單，減少誤操作。
///   - 異步資料加載與實時更新，提高使用流暢度與反應速度。
class OrderCustomerDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 管理導航欄的輔助類，負責配置導航欄標題和樣式。
    private var navigationBarManager: OrderCustomerDetailsNavigationBarManager?
    
    /// 負責處理顧客詳細資料的數據源和交互邏輯。
    private var ordercustomerDetailsHandler: OrderCustomerDetailsHandler?
    
    /// 自定義的視圖，展示顧客詳細資料的填寫項目。
    private let orderCustomerDetailsView = OrderCustomerDetailsView()
    
    
    // MARK: - Lifecycle Methods
    
    /// 設置 OrderCustomerDetailsView 作為主視圖
    override func loadView() {
        view = orderCustomerDetailsView
    }
    
    /// 配置視圖控制器的初始設置，例如導航欄、數據加載等。
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        fetchAndPopulateUserDetails()
    }
    
    // MARK: - Setup Methods
    
    /// 初始化並配置導航欄，包括標題和樣式。
    private func setupNavigationBar() {
        navigationBarManager = OrderCustomerDetailsNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        navigationBarManager?.configureNavigationBarTitle(title: "Customer Details", prefersLargeTitles: true)
    }
    
    /// 初始化並設置 `OrderCustomerDetailsHandler`，負責表單的數據源和交互邏輯。
    private func setupOrderDetailsHandler() {
        let handler = OrderCustomerDetailsHandler(orderCustomerDetailsHandlerDelegate: self)
        self.ordercustomerDetailsHandler = handler
        
        // 設置 collectionView 的 dataSource 和 delegate
        let collectionView = orderCustomerDetailsView.orderCustomerDetailsCollectionView
        collectionView.dataSource = handler
        collectionView.delegate = handler
        collectionView.reloadData()
    }
    
    // MARK: - Data Handling
    
    /// 從 Firebase 獲取當前用戶的詳細資料並填充 CustomerDetails
    ///
    /// 該方法異步從 Firebase 中獲取用戶詳細資料，並將其填充到 `CustomerDetailsManager` 中。
    /// 當資料填充完成後，初始化 `OrderCustomerDetailsHandler`，以確保表單配置正確顯示資料，最後刷新 collection view 來顯示填入的顧客資訊。
    private func fetchAndPopulateUserDetails() {
        HUDManager.shared.showLoading(text: "CustomerDetails...")
        Task {
            do {
                let userDetails = try await FirebaseController.shared.getCurrentUserDetails()
                print("[OrderCustomerDetailsViewController]: Fetched user details: \(userDetails)")
                CustomerDetailsManager.shared.populateCustomerDetails(from: userDetails)
                
                // 在資料填充完成後初始化 OrderCustomerDetailsHandler
                setupOrderDetailsHandler()
                
            } catch {
                print("[OrderCustomerDetailsViewController]: 獲取用戶資料時發生錯誤：\(error)")
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - UI Updates
    
    /// 重新加載 `PickupMethod` 相關的 cell，確保 UI 與資料同步。
    ///
    /// ### 功能說明
    /// - 透過獲取當前顧客資料 (`CustomerDetailsManager.getCustomerDetails()`)，更新 `PickupMethodCell` 的顯示內容。
    /// - 使用 `cellForItem(at:)` 精準定位 `PickupMethodCell`，避免整體刷新 `CollectionView`。
    ///
    /// ### 適用場景
    /// - 當顧客的取件方式（如到店取件或外送服務）變更時，需即時更新該區域的顯示。
    /// - 當相關數據（如地址或門市名稱）發生變更，需同步顯示最新資料。
    private func reloadPickupMethodCell() {
        let pickupMethodIndexPath = IndexPath(item: 0, section: OrderCustomerDetailsHandler.Section.pickupMethod.rawValue)
        guard let pickupCell = orderCustomerDetailsView.orderCustomerDetailsCollectionView.cellForItem(at: pickupMethodIndexPath) as? OrderPickupMethodCell else { return }
        guard let updatedCustomerDetails = CustomerDetailsManager.shared.getCustomerDetails() else { return }
        print("[OrderCustomerDetailsViewController] Reloading PickupMethodCell with updated details: \(updatedCustomerDetails)")
        pickupCell.configure(with: updatedCustomerDetails)
    }
    
    /// 在每次顧客資料變更（例如姓名、電話、地址等變更）時，調用 updateSubmitButtonState() 方法來檢查資料是否完整
    ///
    /// - 根據顧客資料的驗證結果來啟用或禁用提交按鈕。這樣可以確保用戶在所有必要資料未完整前無法提交訂單。
    func updateSubmitButtonState() {
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        let isFormValid = (validationResult == .success)
        print("[OrderCustomerDetailsViewController]:更新提交按鈕狀態: \(isFormValid ? "啟用" : "禁用") - 由於：\(validationResult)")
        
        let submitIndexPath = IndexPath(item: 0, section: OrderCustomerDetailsHandler.Section.submitAction.rawValue)
        guard let submitCell = orderCustomerDetailsView.orderCustomerDetailsCollectionView.cellForItem(at: submitIndexPath) as? OrderCustomerSubmitCell else { return }
        submitCell.configureSubmitButton(isEnabled: isFormValid)
    }
    
}

// MARK: - OrderCustomerDetailsHandlerDelegate
extension OrderCustomerDetailsViewController: OrderCustomerDetailsHandlerDelegate {
    
    /// 當顧客姓名變更時觸發
    ///
    /// - Parameter name: 更新後的顧客姓名
    /// - 功能：將新的姓名更新至 `CustomerDetailsManager`，並重新檢查提交按鈕的啟用狀態。
    func didUpdateCustomerName(_ name: String) {
        CustomerDetailsManager.shared.updateStoredCustomerDetails(fullName: name)
        updateSubmitButtonState()
    }
    
    /// 當顧客電話號碼變更時觸發
    ///
    /// - Parameter phone: 更新後的顧客電話號碼
    /// - 功能：將新的電話號碼更新至 `CustomerDetailsManager`，並重新檢查提交按鈕的啟用狀態。
    func didUpdateCustomerPhone(_ phone: String) {
        CustomerDetailsManager.shared.updateStoredCustomerDetails(phoneNumber: phone)
        updateSubmitButtonState()
    }
    
    /// 當顧客取件方式變更時觸發
    ///
    /// - Parameter method: 更新後的取件方式（例如：到店取件或外送服務）
    /// - 功能：
    ///   - 更新取件方式至 `CustomerDetailsManager`。
    ///   - 刷新 `PickupMethodCell` 的顯示，以確保 UI 與資料同步。
    ///   - 檢查提交按鈕的啟用狀態。
    func didUpdatePickupMethod(_ method: PickupMethod) {
        CustomerDetailsManager.shared.updatePickupMethod(method)
        reloadPickupMethodCell()
        updateSubmitButtonState()
    }
    
    /// 當顧客選擇的門市名稱變更時觸發
    ///
    /// - Parameter storeName: 更新後的門市名稱
    /// - 功能：更新門市名稱至 `CustomerDetailsManager`，並重新檢查提交按鈕的啟用狀態。
    func didUpdateCustomerStoreName(_ storeName: String) {
        CustomerDetailsManager.shared.updateStoredCustomerDetails(storeName: storeName)
        updateSubmitButtonState()
    }
    
    /// 當顧客外送地址變更時觸發
    ///
    /// - Parameter address: 更新後的外送地址
    /// - 功能：更新外送地址至 `CustomerDetailsManager`，並重新檢查提交按鈕的啟用狀態。
    func didUpdateCustomerAddress(_ address: String) {
        CustomerDetailsManager.shared.updateStoredCustomerDetails(address: address)
        updateSubmitButtonState()
    }
    
    /// 當顧客備註內容變更時觸發
    ///
    /// - Parameter notes: 更新後的備註內容
    /// - 功能：更新備註內容至 `CustomerDetailsManager`。
    func didUpdateCustomerNotes(_ notes: String) {
        CustomerDetailsManager.shared.updateStoredCustomerDetails(notes: notes)
    }
    
    /// 用於處理提交訂單的操作
    ///
    /// 當用戶點擊提交按鈕時調用，這裡會調用 `OrderManager` 來`提交訂單`並在成功或失敗後給予回應。
    func didTapSubmitOrderButton() {
        AlertService.showAlert(withTitle: "確認提交訂單", message: "您確定要提交訂單嗎？", inViewController: self, showCancelButton: true) { [weak self] in
            guard let self = self else { return }
            
            Task {
                do {
                    try await OrderManager.shared.submitOrder()
                    print("[OrderCustomerDetailsViewController]: 訂單已成功提交")
                    self.presentOrderConfirmationViewController()
                } catch {
                    print("[OrderCustomerDetailsViewController]: 訂單提交失敗：\(error.localizedDescription)")
                    // 顯示錯誤提示(或者改成跳出一個失敗的畫面)
                    AlertService.showAlert(withTitle: "提交失敗", message: "訂單提交過程中出現錯誤，請稍後再試。", inViewController: self, showCancelButton: false, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    /// 呈現 `OrderConfirmationViewController` ( 訂單確認頁面 ) 的方法
    private func presentOrderConfirmationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let orderConfirmationVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.orderConfirmationViewController) as? OrderConfirmationViewController else {
            print("無法找到 ID 為 OrderConfirmationViewController 的視圖控制器")
            return
        }
        orderConfirmationVC.modalPresentationStyle = .fullScreen
        self.present(orderConfirmationVC, animated: true, completion: nil)
    }
    
    /// 導航至 `StoreSelectionViewController` 來選擇取件門市
    ///
    /// 用於顯示一個 `fullScreen` 的 `StoreSelectionViewController`，讓用戶可以瀏覽和選擇可用的取件門市。
    /// 它同時設置了 `StoreSelectionViewController` 的委託為當前控制器，以便用戶選擇門市後能夠即時更新顧客資料。
    func navigateToStoreSelection() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let storeSelectionVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.storeSelectionViewController) as? StoreSelectionViewController else {
            print("無法找到 ID 為 StoreSelectionViewControllerID 的視圖控制器")
            return
        }
        storeSelectionVC.storeSelectionResultDelegate = self // 設置代理以便返回時接收選擇結果
        
        let navigationController = UINavigationController(rootViewController: storeSelectionVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
}

// MARK: - StoreSelectionResultDelegate
extension OrderCustomerDetailsViewController: StoreSelectionResultDelegate {
    
    /// 當用戶選擇完門市後調用
    ///
    /// 這個方法負責處理用戶選擇的門市結果。它會更新 `CustomerDetailsManager` 中的 `storeName`，並刷新取件方式的區域顯示。
    /// 最後，根據新的門市選擇來更新提交按鈕的狀態，確保所有必填項目都已完成。
    func storeSelectionDidComplete(with storeName: String) {
        
        // 更新 CustomerDetailsManager 中的 storeName
        CustomerDetailsManager.shared.updateStoredCustomerDetails(storeName: storeName)
        print("[OrderCustomerDetailsViewController]: Store selected: \(storeName)")
        
        // 刷新取件方式區域的 Cell
        let pickupSectionIndex = OrderCustomerDetailsHandler.Section.pickupMethod.rawValue
        orderCustomerDetailsView.orderCustomerDetailsCollectionView.reloadSections(IndexSet(integer: pickupSectionIndex))
        print("[OrderCustomerDetailsViewController]: Pickup method section reloaded after store selection")
        
        // 更新提交按鈕狀態
        updateSubmitButtonState()
    }
    
}
