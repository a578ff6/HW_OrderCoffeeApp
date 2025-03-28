//
//  OrderConfirmationViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/1.
//

// MARK: - 訂單提交確認設計方向
/**
 ## 訂單提交確認設計方向
 
 * `What`：
 
    - 在訂單提交成功後，導引用戶進入一個專門的 `OrderConfirmationViewController`，讓用戶看到訂單的確認訊息和成功圖示。
    - 在確認畫面上設置一個「關閉」按鈕，供用戶手動返回到上一層頁面，並在此時清空使用者填寫的訂單資料和飲品項目。

 * `Why`：
 
    - 這樣的設計能提供用戶一個完整的訂單確認體驗，讓他們確定訂單已成功提交，且可以查看所有相關訊息。
    - 當用戶點擊「關閉」按鈕後，才進行資料的清空，避免用戶誤返回而導致訂單資料遺失，並且確保訂單資料只在用戶明確確認後才清空，以防止重複提交或其他錯誤。

 * `How`：
 
   ` 1. 提交成功後導航到 OrderConfirmationViewController：`
        - 在訂單提交成功後，將用戶引導至 `OrderConfirmationViewController`，顯示訂單確認的訊息及成功圖示。
 
    `2. 設置「關閉」按鈕：`
        - 在 `OrderConfirmationViewController` 中設置「關閉」按鈕，當用戶點擊此按鈕時，執行清空操作。
 
    `3. 清空資料並返回上一層：`
        - 用戶點擊「關閉」後，清空訂單資料及使用者填寫的資料，然後返回到其他的視圖（例如首頁），以準備新的訂單流程。
 */


// MARK: - 訂單提交流程設計
/**
 
 ## 訂單提交流程設計

 `What`
 
    * 在 `OrderCustomerDetailsViewController` 中，當用戶提交訂單後，會進入 `OrderConfirmationViewController` 來呈現訂單確認結果。

    - `OrderCustomerDetailsViewController` 用於填寫訂單的顧客資料及相關資訊。
    - 當用戶點擊提交訂單按鈕後，若提交成功，會轉跳到 `OrderConfirmationViewController` 顯示確認訊息。

 ---------

 `Why`
 
    * 此流程的設計目的在於提供用戶清晰的訂單提交反饋，讓用戶可以確認自己的訂單已成功完成：

    - 在 `OrderConfirmationViewController` 顯示訂單確認圖示及詳情，可以給予用戶視覺上的確認，增強使用體驗。
    - 在用戶手動點擊「關閉」按鈕後返回，這樣用戶可以決定何時結束確認流程，增加使用的自主性。

 ---------

 `How`
 
    1. 用戶在 `OrderCustomerDetailsViewController` 填寫完成訂單資料後，點擊「提交訂單」按鈕。
    2. 系統會嘗試提交訂單至後端，若成功，將使用 `present` 方法顯示 `OrderConfirmationViewController`。
    3. `OrderConfirmationViewController` 中顯示訂單成功的圖示及訂單資訊，並設有「關閉」按鈕。
    4. 用戶點擊「關閉」按鈕後，系統會清空訂單資料及顧客填寫資訊，並返回到適當的視圖控制器。

    這樣的流程可以確保用戶在提交訂單後有清楚的確認和結束操作，提升整體訂單體驗。
 */


// MARK: - 訂單確認視圖設計構想
/**
 
 ## 訂單確認視圖設計構想
 
 `* What: 顯示訂單確認頁面（OrderConfirmationViewController）`

    - 在顯示訂單確認的頁面中，應顯示顧客姓名、電話、取件方式（包含外送地址或取件店家）、訂單項目列表、總金額、準備時間、訂單成立時間，以及備註。

 ---------

 `* Why: 提供完整清晰的訂單確認資訊，增強用戶體驗`

    - 顧客在提交訂單後，能夠查看詳細的訂單資訊，確認所有內容無誤，以避免因填寫錯誤而產生的問題。這不僅能增加顧客的信心，還能提供更好的使用體驗。
 
 ---------

 `* How: 設計與調整想法`

    1. `顯示顧客資訊`：
        - 顯示姓名和電話，讓顧客可以確保個人資訊正確。

    2. `根據取件方式顯示相應內容`：
        - 對於 pickupMethod 的值做一些更友好的呈現，例如將 "Home Delivery" 顯示為「外送服務」，或 "In-Store Pickup" 顯示為「到店自取」，這樣更符合本地用戶的閱讀習慣。
        - 如果取件方式為「外送服務」，顯示「外送地址」。
        - 如果取件方式為「到店自取」，顯示「取件店名」。

    3. `顯示訂單詳情`：
        - 包含總金額、準備時間、訂單編號、訂單成立時間。
        - 時間顯示轉換為用戶的本地時區，例如「2024年11月2日 上午10:28」。
        - 總金額建議加上幣別符號，如「NT$465」。

    4. `訂單飲品項目詳情`：
        - 顯示飲品的名稱、子名稱、圖片、數量、單價和尺寸。
        - 可以考慮加上單價和數量的乘積顯示，以提供顧客更清楚的訂單金額明細。
        - 圖片可以設置成圓角或陰影效果，提升視覺效果。

    5. `處理缺少資料的情況`：
        - 如果取件方式為「外送服務」（Home Delivery），那麼界面上應該顯示「外送地址」，並且不顯示「取件店名」。
        - 如果取件方式為「到店自取」（In-Store Pickup），則界面上應該顯示「取件店名」，而不顯示「外送地址」。
 
    6.` 用戶體驗提升`：
        - 在訂單確認頁面添加「聯繫客服」按鈕，以便顧客在有問題時能夠直接聯繫到相關人員。（可選）
        - 設置「關閉」按鈕，讓用戶在確認訂單後手動返回，同時清空訂單資料，保持界面整潔，給予完整的確認和結束流程的體驗。
 
    7. `資料顯示範例`：
 
         ---
         **顧客姓名**：測試名字async
         **顧客電話**：0939728282
         **取件方式**：外送服務
         **外送地址**：新北市三重區碧華街

         **訂單項目**：
         1. 冰每日精選咖啡（Iced Coffee）
            - 數量：3
            - 單價：NT$95
            - 尺寸：大杯
         2. 卡布奇諾（Cappuccino）
            - 數量：1
            - 單價：NT$120
            - 尺寸：中杯

         **總金額**：NT$465
         **準備時間**：13 分鐘
         **訂單成立時間**：2024年11月2日 上午10:28
         **備註**：不要加糖
 */


// MARK: - 設計筆記：OrderConfirmationViewController 的管理與資料來源
/**
 
## 設計筆記：OrderConfirmationViewController 的管理與資料來源
 
    - 一開始嘗試使用 `OrderCustomerDetailsViewController` 傳遞 `Order` 到 `OrderConfirmationViewController`，由於結構很複雜，且不符合處理流程，因為點擊`submit`並確認的時候，基本上就是將訂單上傳到 Firebase中了。
    - 以及由於上傳到 Firebase 的資料結構是比較精簡的，所以就另外設置獨立的 `OrderConfirmation` 來處理，將職責給專一化。

`### 新的設計概念`

`1. OrderConfirmationViewController 的資料獲取：`
    - `OrderConfirmationViewController` 不再依賴於 `OrderCustomerDetailsViewController` 傳遞 `Order` 對象，而是直接從 Firebase 獲取已成功提交的訂單資料。
    - 這樣的設計可以確保顯示資料時直接從資料庫中獲取最終版本，減少中間傳遞過程中的可能錯誤或資料不一致。

`2. 獨立的 Manager 與模型：`
    - 設置 `OrderConfirmationManager` 來負責從 Firebase 獲取訂單資料，使 `OrderConfirmationViewController` 僅專注於顯示訂單資訊。
    - `OrderConfirmationManager` 使用 `async/await` 簡化異步請求流程，增加程式碼可讀性並減少錯誤處理的複雜性。

`3. 專屬的 OrderConfirmation 模型：`
    - 由於 `OrderConfirmationViewController` 只需展示簡化的訂單資料，因此建立了專屬的 `OrderConfirmation` 模型。
    - 這個專屬模型只包含展示所需的字段，減少過多的資料解析，符合單一職責原則。

 ---------

`### 改進後的設計優勢`

`1. 職責單一，減少耦合：`
    - `OrderCustomerDetailsViewController` 負責處理訂單的提交，而 `OrderConfirmationViewController` 負責顯示訂單確認資料。
    - 將資料獲取功能抽離到 `OrderConfirmationManager`，避免不同控制器之間的依賴，使各個控制器專注於自身的職責，增加程式碼的清晰度和維護性。

`2. 數據一致性和完整性：`
    - 直接從 Firebase 獲取訂單資料，避免因跨控制器傳遞資料而導致的數據不一致或遺漏的問題。
    - 保證顯示的訂單資料和已儲存於 Firebase 的資料相符，提高數據的完整性和可靠性。

`3. 易於測試和維護：`
    - `OrderConfirmationViewController` 可以獨立從 Firebase 獲取所需資料，而不需要與其他控制器的邏輯耦合，這使得控制器更容易進行單獨測試和維護。
    - 減少因修改控制器間的資料傳遞而引起的潛在問題，提高程式碼的穩定性。

 ---------

`### 流程簡述`

`1. 提交訂單：`
    - 當使用者在 `OrderCustomerDetailsViewController` 提交訂單時，該控制器負責將訂單數據上傳至 Firebase。

`2. 顯示訂單確認：`
    - 提交成功後，畫面轉場到 `OrderConfirmationViewController`，此時不再需要傳遞 `Order` 對象。
    - `OrderConfirmationViewController` 在 `viewDidLoad` 中使用 `OrderConfirmationManager` 獲取最近提交的訂單並顯示。

 ---------

`### 為何使用專屬的 OrderConfirmation 模型`

- `OrderConfirmationViewController` 只需要展示訂單的一部分簡化資訊，因此設計了一個專屬的 `OrderConfirmation` 模型。
- 該模型只包含顯示所需的必要字段（例如訂單 ID、顧客資訊、飲品資訊等），使得資料獲取和解析更簡單，減少不必要的數據負擔。

 ---------

`### 總結`

這樣的設計使得每個控制器的職責更加清晰，符合單一職責原則（Single Responsibility Principle, SRP），減少控制器之間的耦合，提升程式碼的可讀性和可維護性。
*/


// MARK: - OrderConfirmationViewController 設計的資料獲取方式解釋
/**
 
 ## OrderConfirmationViewController 設計的資料獲取方式解釋

 - 在 `OrderConfirmationViewController` 中，`var orderConfirmation: OrderConfirmation?` 並不是由前一個頁面 (`OrderCustomerDetailsViewController`) 傳遞的，而是透過 `OrderConfirmationManager` 從 `Firebase` 中重新獲取最近提交的訂單資料。

 `* 為何採用這樣的設計？`

` 1. 資料一致性`
 
    - 一旦訂單成功提交，通過從 Firebase 獲取訂單資料來顯示，可以保證資料的最新狀態，而不僅依賴本地變數傳遞訂單資料。
    - 這樣，即使訂單提交後有所更新（如同步錯誤或其他原因），我們也能確保顯示的資料與 Firebase 完全同步。

 `2. 降低頁面之間的耦合`
    - 如果 `OrderConfirmationViewController` 需要直接從 `OrderCustomerDetailsViewController` 接收資料，這將導致兩個頁面之間的緊密耦合。
    - 使用 `Firebase` 來拉取資料可以避免這種直接依賴，使得 `OrderConfirmationViewController` 可以獨立於前一個頁面，專注於顯示資料，而不需知道訂單資料是從哪個頁面來的。
 
` 3.增加可重用性和靈活性`
    - 透過讓 `OrderConfirmationViewController` 自行從 Firebase 獲取訂單，它不再依賴於特定的前置頁面。
    - 因此，不論是從哪個頁面進入 `OrderConfirmationViewController`（例如應用中任何地方提供的“查看最近訂單”功能），它都能獨立地抓取到需要的訂單資料。
 
 ---------
 
 `* 設計總結`
    - 當訂單在 `OrderCustomerDetailsViewController` 中成功提交後，訂單資料會被上傳到 `Firebase`。
    - 在 `OrderConfirmationViewController` 中，透過 `OrderConfirmationManager` 來從 Firebase 獲取最近提交的訂單資料，而不是依賴於前一個頁面直接傳遞 Order 對象。
 
 ---------

 `* 這樣做的好處`
 
    `1. 資料的即時性和一致性`
        - 確保顯示的訂單資料來自後端，是最新的資料狀態。
 
    `2.降低頁面之間的耦合`
        - `OrderConfirmationViewController` 不再依賴於特定的前置頁面，能夠靈活地在應用程式中不同地方使用，而不受到上下文的限制。
 
    `3. 提高可維護性`
        - 將資料的獲取責任集中於 `OrderConfirmationManager`，而不是在每個控制器中手動管理訂單資料，使得代碼結構更清晰、更具可維護性。
 */


// MARK: - 訂單完成後的資料清除與頁面返回操作 - 重點筆記（重要）
/**
 
 ## 訂單完成後的資料清除與頁面返回操作 - 重點筆記

 `1. 問題背景`
 
    - `訂單完成後的處理`：當用戶完成訂單並確認後，應對訂單資料進行清理，確保下一次訂單開始於一個乾淨的狀態。並返回主菜單頁面。
    - `視覺體驗需求`：返回頁面的過程應當流暢，避免多重動畫干擾帶來的跳動或不自然感。
 
 ------

 `2. 訂單完成後的資料清除`
  
 `* 清空 OrderItem：`
 
    - 使用` OrderItemManager.shared.clearOrder()` 清空所有訂單項目。
    - 這樣設計的原因在於每個訂單都是獨立的，完成後應清空舊訂單項目，為下一次訂單做好準備。
 
 `* 重置 CustomerDetails：`
 
    - 使用 `CustomerDetailsManager.shared.resetCustomerDetails() `方法重置顧客詳細資料。
    - 清除的資料包含顧客的姓名、電話、地址等，以防止這些資料影響下一次訂單。
    - 這樣可以確保顧客每次下訂單時都從新開始，尤其是當顧客的資料在本次訂單中有修改時。
 
 ------
 
 `3. 頁面返回操作的步驟`
 
 `* 先清理資料，再返回主菜單：`
 
    - 執行 `resetCustomerDetails()` 和 `clearOrder()`，確保返回主畫面前的資料清理完畢。
    
 `* 透過 presentingViewController 返回主畫面：`
 
    - 使用 `self.presentingViewController` 獲取當前頁面的呈現者，確認其類型為 `UITabBarController`。
    - 確保返回主畫面操作的上下文清晰，不受其他全局狀態干擾。
    
 `* 解散視圖控制器：`
 
    - 使用 `dismiss(animated: false)` 關閉當前頁面，避免動畫干擾。
    
 `* 重置導航堆疊並切換 Tab：`
 
    - 使用 `OrderConfirmationNavigationHandler.resetNavigationStacks` 方法，重置導航堆疊並切換到 `.menu`。
    - 透過淡入動畫改善返回過程的流暢度。
 
 ------

 `4. 實作細節說明`
  
 `* 透過 presentingViewController 尋找 TabBarController：`
 
    - `guard let presentingViewController = self.presentingViewController as? UITabBarController` 確保安全類型轉換。
    - 此方法避免多餘的全局查找，提升導航邏輯的封裝性與精確性。
  
 `* 資料清理與返回同步執行：`
 
    - 使用完成閉包，確保 `resetNavigationStacks` 在資料清理後執行。
     
 `* 淡入動畫的應用：`
 
    - 在 `resetNavigationStacks` 方法中，使用 `UIView.transition`，將過渡效果集中在主頁面，提升視覺一致性。

 ------

 `5. 設計的好處`
  
 - 資料清理的完整性： 確保每次訂單獨立運行，完成訂單後的狀態乾淨，避免干擾後續訂單。
     
 - 視覺體驗的優化： 分步執行資料清理、視圖解散與導航重置，並通過淡入動畫，減少用戶視覺干擾。
     
 - 可維護性提升： 將導航與資料清理邏輯分開，並利用 `presentingViewController` 簡化邏輯，避免過度依賴全局狀態。
 
 ------

 `6. 總結`

 - 這樣的設計實現了「資料清除」與「頁面返回」之間的協同工作，在訂單完成後不僅清空了所有與該訂單相關的臨時資料，還能讓頁面過渡順暢，帶來更好的用戶體驗。
 - 這樣的整體流程設計確保了用戶的下一次訂單從一個乾淨的狀態開始，且頁面交互更加順暢和一致。
 */


// MARK: - 重點筆記：資料驅動的 UI 配置與手勢處理獨立化
/**
 
 ## 重點筆記：資料驅動的 UI 配置與手勢處理獨立化

 `* 問題描述`
 
    - `遠端資料獲取延遲`：從 Firebase 獲取訂單資料會存在一定的延遲，這可能導致 UI 在資料還未加載完成時顯示不完整或錯誤。
    - `UI 資料依賴性高`：`OrderConfirmation` 頁面中顯示的內容高度依賴於資料的完整性，因此需要在資料完全獲取後再進行配置，確保顯示的準確性。
    - `手勢處理重複問題`：在多次創建 Header View 的情況下，手勢處理程式碼可能導致重複附加手勢辨識器的問題，使得手勢管理變得複雜且難以維護。（重要）
    - `提升用戶體驗`：用戶更能接受的是一個稍晚一點但完整的界面，而不是一個閃爍或者顯示錯誤提示的界面。

 -------

 `* 改進方案`
 
 `1. 採用資料驅動的 UI 配置，延遲初始化 OrderConfirmationHandler：`
 
    - `延遲初始化 OrderConfirmationHandler`：將 `OrderConfirmationHandler` 的初始化移到資料加載完成之後進行，而不是在 `viewDidLoad()` 中。
    - 這樣可以保證在有完整訂單資料後再初始化和設置 UI，避免 UI 顯示不完整或出錯。
 
 `2. 手勢處理邏輯獨立化，改善責任分離和可維護性：`
 
    - `獨立出手勢處理邏輯`：將與 Section Header 的點擊展開/收起相關的手勢處理從 `OrderConfirmationHandler` 中分離出來，放入新的類別 `OrderConfirmationHeaderGestureHandler` 中。
    - `責任分離`:這樣做可以讓 `OrderConfirmationHandler` 專注於數據顯示和 UI 配置，而 `OrderConfirmationHeaderGestureHandler` 專注於手勢的添加與管理，降低耦合度並提高程式碼的可讀性和可維護性。
 
 -------

 `* 具體實現步驟`
 
 `1.將 OrderConfirmationHandler 延遲初始化：`
 
    - 在` viewDidLoad() `中不初始化 `OrderConfirmationHandler`。
    - 改為在 `fetchLatestOrderData() `的資料獲取成功後，才調用 `setupOrderConfirmationHandler() 進行`初始化。
 
 `2.設置 OrderConfirmationHandler 的數據源和委託：`
 
    - 在` setupOrderConfirmationHandler() `方法中，初始化 `OrderConfirmationHandler` 並設置為 `collectionView` 的數據源和委託。
    - 只有在資料獲取完成後，才進行 UI 的配置。
 
 `3.手勢處理邏輯的獨立：`（重要）
 
    - 新增 `OrderConfirmationHeaderGestureHandler` 類別，用於集中管理與 Header View 相關的手勢處理邏輯。
    - 在 `OrderConfirmationHandler` 中使用 `OrderConfirmationHeaderGestureHandler` 來為 Header View 添加手勢。
    - 在初始化 `OrderConfirmationHandler` 時，延遲初始化 `OrderConfirmationHeaderGestureHandler`，並確保其擁有正確的 `delegate`。
 
 -------

 `* 改進後的邏輯流程`
 
 `1.獲取資料：`
 
    - 在 viewDidLoad() 中調用 `fetchLatestOrderData() `獲取最新的訂單資料。
    - 當資料獲取成功後，將資料存儲在 `orderConfirmation` 中。
 
 `2.延遲配置 UI：`
 
    - 當資料成功獲取後，通過` setupOrderConfirmationHandler() `方法來初始化 `OrderConfirmationHandler`，並將其設置為 `collectionView` 的數據源和委託。
    - 確保 `collectionView` 只有在資料完全準備好後才進行顯示，從而避免不完整或錯誤的 UI。
 
` 3. 手勢處理分離：`
 
    - 當配置 Header View 時，使用 `OrderConfirmationHeaderGestureHandler` 為需要展開/收起的 Header View 添加手勢。
    - 確保手勢只在需要時添加，並避免重複附加手勢辨識器。
 
 -------
 
 `* 改進後的好處`
 
 `1.避免顯示不完整的 UI`：
 
 - 在資料完全準備好後再進行 UI 初始化，這樣可以避免顯示不完整或出錯的情況。
 
 `2.用戶體驗提升`：
 
 - 用戶不會看到未加載完全的 UI，整體的界面顯得更加穩定和可靠。
 
 `3.更清晰的程式碼邏輯`：
 
 - 數據獲取和 UI 初始化分開進行，讓程式碼更加易於理解和維護。
 - 手勢處理邏輯獨立後，`OrderConfirmationHandler` 的責任更加專一，使程式碼的可讀性和可維護性顯著提升。
 */


// MARK: - 重點筆記：didToggleSection 的設計
/**
 ## 重點筆記：didToggleSection 的設計
 
` * 目的與設計`
 
    - `目的`：`didToggleSection(_:) `方法的目的是當使用者點擊某個 Section Header，切換該區域的展開或收起狀態時，更新顯示內容，使得使用者可以即時看到變更效果。
    - `功能`：這個方法會使用 `reloadSections(_:) `來重新加載指定的區域，從而更新顯示狀態（例如展開/收起的 `ItemDetails` 部分）。
 
 `* 工作流程`
 
    - `Section Header 點擊`：當使用者點擊區域標題 (HeaderView) 時，會透過 `OrderConfirmationHandler` 中的 `handleHeaderTap(_:) `方法來通知控制器 (`OrderConfirmationViewController`) 切換展開狀態。
    - `通知更新`：`OrderConfirmationHandler` 通過代理 (`OrderConfirmationHandlerDelegate`) 通知控制器進行狀態切換，控制器再使用` didToggleSection(_:) `方法來完成 UI 更新。
 
 `* 優點`
 
    - `保持控制器與 Handler 之間的低耦合`：通過代理方法將 Section 展開或收起的更新操作交由 ViewController 處理，可以保持控制器與 Handler 之間的低耦合。
    - `便於擴展與維護`：如果未來需要改變 Section 的展開狀態顯示邏輯，這些邏輯只需在控制器內進行更新，而無需修改 Handler，有助於代碼的擴展和維護性。
 
 `* 適用情境`
 
    - 訂單確認頁面 (`OrderConfirmationViewController`) 中使用這個方法來切換顯示狀態，讓用戶可以更好地掌握訂單的詳細資訊或隱藏部分細節。
    - 將展開狀態的邏輯與顯示更新分離，讓 Handler 更專注於處理數據的管理和手勢交互，ViewController 則處理具體的顯示更新，使各自的責任更為明確。
 */


// MARK: - OrderConfirmationViewController 筆記
/**
 
 ## OrderConfirmationViewController 筆記

 `* What`
 
 - `OrderConfirmationViewController` 是一個負責展示用戶提交訂單後的確認詳情的頁面。主要功能包括：
 
 1. 顯示訂單資訊：展示顧客資料、訂單項目、總金額等詳細資訊。
 2. 與 Firebase 交互：從 Firebase 獲取最新的訂單數據以更新畫面。
 3. 導航控制：使用 `OrderConfirmationNavigationHandler` 管理返回主頁及重置導航堆疊。

 --------

 `* Why`
 
 1. 資料透明化：用戶可以清楚看到提交訂單的詳細資訊，增強操作透明度。
 2. 一致性：確保訂單數據與伺服器端保持一致，防止因數據不同步引發問題。
 3. 使用體驗優化：支援便捷的返回主頁功能，讓用戶在結束訂單操作後能迅速回到應用的主要功能頁面。
 4. 維護性：將訂單數據處理、UI 更新、導航控制職責分開，提高代碼的可讀性和可維護性。

 --------

 `* How`

 1. 顯示訂單資訊
 
    - 使用 `OrderConfirmationView` 負責構建和顯示訂單詳情 UI。
    - 定義 `OrderConfirmationHandler`，作為 `UICollectionView` 的數據源和委託，管理訂單項目展示邏輯。

 2. 與 Firebase 交互
 
    - 使用 `OrderConfirmationManager` 獲取最新的訂單數據，並在數據成功加載後更新 UI。
    - 透過異步操作 (`Task`) 確保用戶在數據加載過程中獲得良好的體驗，例如顯示加載指示器。
    - 若數據加載失敗，打印錯誤以便開發階段調試。

 3. 導航控制
 
    - 使用 `OrderConfirmationNavigationHandler` 負責處理返回主頁的邏輯，包括：
      1. 解散當前視圖 (`dismiss`)。
      2. 重置所有 Tab 的導航堆疊 (`resetNavigationStacks`)。
      3. 切換到主菜單頁面 (`targetTab: .menu`)。
    - 在點擊 "關閉" 按鈕時，先提示用戶確認操作，避免誤操作導致數據丟失。

 4. 清理操作
 
    - 使用 `CustomerDetailsManager` 和 `OrderItemManager` 重置用戶資料及清空訂單項目，確保返回主頁後的應用狀態乾淨且一致。

 --------

 `* 使用場景`

 - 訂單提交完成：用戶提交訂單後進入此頁面檢視訂單詳情。
 - 主動返回主頁：用戶完成確認後點擊關閉按鈕返回主菜單。

*/


// MARK: - 資料驅動的 UI 配置

import UIKit

/// 訂單確認頁面控制器
///
/// 此控制器負責管理訂單確認頁面的數據加載、顯示和用戶交互，
/// 通過協作多個模組，實現訂單確認的整體功能。
///
/// ### 功能說明
/// 1. 顯示訂單詳細資訊：
///    - 包括顧客資料、訂單項目及總金額等資訊。
/// 2. 與 Firebase 交互：
///    - 使用 `OrderConfirmationManager` 獲取最新訂單資料。
/// 3. 導航控制：
///    - 使用 `OrderConfirmationNavigationHandler` 處理視圖的關閉和返回主菜單的操作。
/// 4. 區域管理：
///    - 配合 `OrderConfirmationHandler` 和其相關模組處理區域的展開/收起邏輯。
///
/// ### 使用場景
/// - 當用戶提交訂單後，此頁面用於確認訂單的詳細資訊，並提供返回主畫面的選項。
class OrderConfirmationViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 用於存放提交後的訂單資料
    ///
    /// - 說明：該屬性存儲從 Firebase 獲取的訂單詳細資訊，用於顯示在 UI 上。
    var orderConfirmation: OrderConfirmation?
    
    /// 訂單確認頁面的主視圖
    ///
    /// - 說明：包含所有 UI 元素的自訂義容器視圖。包含訂單確認頁面詳細資訊的展示。
    private let orderConfirmationView = OrderConfirmationView()
    
    /// 管理數據源和區域展開/收起邏輯的處理器
    ///
    /// - 說明：負責管理 `UICollectionView` 的數據源和委託，處理訂單詳細資料展示。
    /// - 注意：需要在成功加載訂單資料後進行初始化。
    private var orderConfirmationHandler: OrderConfirmationHandler?
    
    /// 管理與 Firebase 的交互
    ///
    /// - 說明：負責從 Firebase 獲取最新的訂單資料。
    private let orderConfirmationManager = OrderConfirmationManager()
    
    /// 處理導航操作的管理器
    ///
    /// - 說明：負責管理返回主畫面及重置導航堆疊的操作。
    private let orderConfirmationNavigationHandler = OrderConfirmationNavigationHandler()
    
    
    // MARK: - Lifecycle Methods
    
    /// 加載訂單確認頁面的主要視圖
    override func loadView() {
        self.view = orderConfirmationView
    }
    
    /// 視圖加載完成後調用
    ///
    /// - 說明：初始化頁面邏輯，開始獲取最新訂單資料。
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLatestOrderData()
    }
    
    // MARK: - Setup Methods
    
    /// 初始化並設置訂單處理器
    ///
    /// - 說明：
    ///   - 創建 `OrderConfirmationHandler` 並設置為 `UICollectionView` 的數據源和委託。
    ///   - 同時負責訂單詳細資訊的展示和區域展開/收起邏輯。
    /// - 使用場景：
    ///   - 在成功獲取訂單資料後調用，確保 UI 與數據一致。
    private func setupOrderConfirmationHandler() {
        
        let handler = OrderConfirmationHandler(
            orderConfirmationHandlerDelegate: self,
            orderConfirmationSectionDelegate: self
        )
        
        self.orderConfirmationHandler = handler
        
        // 設置 collectionView 的數據源和委託
        orderConfirmationView.orderConfirmationCollectionView.dataSource = handler
        orderConfirmationView.orderConfirmationCollectionView.delegate = handler
        
        // 重新加載數據
        orderConfirmationView.orderConfirmationCollectionView.reloadData()
    }
    
    // MARK: - Data Fetching Methods
    
    /// 獲取最新的訂單資料
    ///
    /// - 說明：
    ///   - 調用 `OrderConfirmationManager` 從 Firebase 獲取資料。
    ///   - 成功後初始化數據處理器並刷新 UI；失敗則提示錯誤。
    private func fetchLatestOrderData() {
        HUDManager.shared.showLoadingInView(self.view, text: "Loading Data...")
        Task {
            do {
                let latestOrder = try await orderConfirmationManager.fetchLatestOrder()
                handleFetchedOrder(latestOrder)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: "獲取訂單失敗: \(error.localizedDescription)", inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Helper Methods
    
    /// 處理成功獲取的訂單資料
    ///
    /// - Parameter order: 最新的訂單資料
    /// - 說明：
    ///   - 更新 `orderConfirmation` 屬性，並初始化數據處理器。
    ///   - 調用相關方法更新 UI。
    private func handleFetchedOrder(_ order: OrderConfirmation) {
        self.orderConfirmation = order
        printFetchedOrderDetails(order)
        setupOrderConfirmationHandler()
    }
    
    /// 打印獲取到的訂單詳細資料
    ///
    /// - Parameter order: 需要打印的訂單資料
    /// - 說明：用於開發階段觀察訂單數據是否正確。
    private func printFetchedOrderDetails(_ order: OrderConfirmation) {
        print("成功獲取訂單: \(order)")
        print("訂單時間：\(order.timestamp)")
        print("訂單顧客姓名：\(order.customerDetails.fullName)")
        print("訂單總金額：\(order.totalAmount)")
        print("訂單準備時間：\(order.totalPrepTime)")
        print("訂單項目數量：\(order.orderItems.count)")
    }
    
}


// MARK: - OrderConfirmationHandlerDelegate
extension OrderConfirmationViewController: OrderConfirmationHandlerDelegate {
    
    // MARK: - Order Data Methods
    
    /// 獲取目前的訂單資料
    ///
    /// - Returns: 當前的訂單資料
    /// - 說明：提供給 `OrderConfirmationHandler` 用於顯示訂單內容。
    func getOrder() -> OrderConfirmation? {
        return orderConfirmation
    }
    
    // MARK: - Close Button Handling
    
    /// 當用戶點擊 "關閉" 按鈕時的操作
    ///
    /// - 說明：
    ///   - 顯示確認提示，提示用戶是否返回主菜單。
    ///   - 確認後清空訂單資料並返回主畫面。
    func didTapCloseButton() {
        AlertService.showAlert(
            withTitle: "確認返回",
            message: "您即將返回主菜單，這將會清空目前的訂單資料和顧客資料，是否繼續？",
            inViewController: self,
            showCancelButton: true
        ) {[weak self] in
            self?.proceedWithClosing()
        }
    }
    
    /// 執行返回主菜單的操作
    ///
    /// - 說明：
    ///   - 清空訂單資料並重置導航堆疊。
    ///   - 返回主菜單。
    private func proceedWithClosing() {
        
        // 使用 presentingViewController 獲取 TabBarController
        guard let presentingViewController = self.presentingViewController as? UITabBarController else { return }
        
        CustomerDetailsManager.shared.resetCustomerDetails()    // 重置顧客資料
        OrderItemManager.shared.clearOrder()                    // 清空訂單項目
        
        orderConfirmationNavigationHandler.dismiss(viewController: self) { [weak self] in
            self?.orderConfirmationNavigationHandler.resetNavigationStacks(with: presentingViewController, targetTab: .menu)
        }
    }
    
}

// MARK: - OrderConfirmationSectionDelegate
extension OrderConfirmationViewController: OrderConfirmationSectionDelegate {
    
    /// 切換指定區域的展開/收起狀態
    ///
    /// - Parameter section: 被點擊的區域索引
    /// - 說明：
    ///   - 接收來自 `OrderConfirmationHandler` 的通知。
    ///   - 更新對應區域的 UI。
    func didToggleSection(_ section: Int) {
        print("Section toggled: \(section)")
        orderConfirmationView.orderConfirmationCollectionView.reloadSections(IndexSet(integer: section))
    }
    
}
