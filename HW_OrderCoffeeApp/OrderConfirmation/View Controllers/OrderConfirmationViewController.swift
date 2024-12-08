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
 # 訂單提交流程設計

 `What`
 
    * 在 `OrderCustomerDetailsViewController` 中，當用戶提交訂單後，會進入 `OrderConfirmationViewController` 來呈現訂單確認結果。

    - `OrderCustomerDetailsViewController` 用於填寫訂單的顧客資料及相關資訊。
    - 當用戶點擊提交訂單按鈕後，若提交成功，會轉跳到 `OrderConfirmationViewController` 顯示確認訊息。

 `Why`
 
    * 此流程的設計目的在於提供用戶清晰的訂單提交反饋，讓用戶可以確認自己的訂單已成功完成：

    - 在 `OrderConfirmationViewController` 顯示訂單確認圖示及詳情，可以給予用戶視覺上的確認，增強使用體驗。
    - 在用戶手動點擊「關閉」按鈕後返回，這樣用戶可以決定何時結束確認流程，增加使用的自主性。

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

 `* Why: 提供完整清晰的訂單確認資訊，增強用戶體驗`

    - 顧客在提交訂單後，能夠查看詳細的訂單資訊，確認所有內容無誤，以避免因填寫錯誤而產生的問題。這不僅能增加顧客的信心，還能提供更好的使用體驗。
 
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

`### 流程簡述`

`1. 提交訂單：`
    - 當使用者在 `OrderCustomerDetailsViewController` 提交訂單時，該控制器負責將訂單數據上傳至 Firebase。

`2. 顯示訂單確認：`
    - 提交成功後，畫面轉場到 `OrderConfirmationViewController`，此時不再需要傳遞 `Order` 對象。
    - `OrderConfirmationViewController` 在 `viewDidLoad` 中使用 `OrderConfirmationManager` 獲取最近提交的訂單並顯示。

`### 為何使用專屬的 OrderConfirmation 模型`

- `OrderConfirmationViewController` 只需要展示訂單的一部分簡化資訊，因此設計了一個專屬的 `OrderConfirmation` 模型。
- 該模型只包含顯示所需的必要字段（例如訂單 ID、顧客資訊、飲品資訊等），使得資料獲取和解析更簡單，減少不必要的數據負擔。

`### 總結`

這樣的設計使得每個控制器的職責更加清晰，符合單一職責原則（Single Responsibility Principle, SRP），減少控制器之間的耦合，提升程式碼的可讀性和可維護性。
*/


// MARK: - OrderConfirmationViewController 設計的資料獲取方式解釋
/**
 ** OrderConfirmationViewController 設計的資料獲取方式解釋

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
 
 `## 設計總結`
    - 當訂單在 `OrderCustomerDetailsViewController` 中成功提交後，訂單資料會被上傳到 `Firebase`。
    - 在 `OrderConfirmationViewController` 中，透過 `OrderConfirmationManager` 來從 Firebase 獲取最近提交的訂單資料，而不是依賴於前一個頁面直接傳遞 Order 對象。
 
 `## 這樣做的好處`
 
    `1. 資料的即時性和一致性`
        - 確保顯示的訂單資料來自後端，是最新的資料狀態。
 
    `2.降低頁面之間的耦合`
        - `OrderConfirmationViewController` 不再依賴於特定的前置頁面，能夠靈活地在應用程式中不同地方使用，而不受到上下文的限制。
 
    `3. 提高可維護性`
        - 將資料的獲取責任集中於 `OrderConfirmationManager`，而不是在每個控制器中手動管理訂單資料，使得代碼結構更清晰、更具可維護性。
 */


// MARK: - 多層視圖控制器返回過程的動畫處理優化（重要）
/**
 ## 多層視圖控制器返回過程的動畫處理優化
 
 `* 問題描述`
    - 在點擊關閉按鈕後，應該要從 `OrderConfirmationViewController` 離開並返回到 `MenuViewController`，但由於這兩者位於不同的 `Tab`，因此需要處理 `TabBarController` 的切換以及多層視圖控制器的過渡。
    - 一開始嘗試直接禁用動畫（`animated: false`）進行切換，以為可以更快速地進入目標視圖，但實際上這樣的過渡在視覺上顯得非常突兀。因此，為了解決這個問題，逐步調整了過渡方式，讓返回的過程更加流暢和自然。
    - 在實作返回主菜單（MenuViewController）的過程中，遇到了一些視覺上的問題。這些問題主要包括：

`1.過渡視圖層級複雜：`
    - 由於 `OrderConfirmationViewController` 是由 `OrderCustomerDetailsViewController` 全螢幕呈現 (`modalPresentationStyle.fullScreen`)，返回到 MenuViewController 的過程涉及多層視圖控制器的解散，並且還需要正確切換 UITabBarController 的選中索引。這使得返回過程較為複雜，容易出現視覺上的跳動或不順暢。
 
`2.視覺上不流暢的跳動感：`
    - 在執行返回動畫時，有些視圖控制器會交疊出現，特別是 `TabBar` 和 `MenuViewController`，會感覺到一些“彈跳”效果，這會影響用戶的視覺體驗。
 
 
 `* 解決方案的關鍵改變`
    - 成功地實作這個過程，是因為採取了一些關鍵的改變，這些改變讓過渡動畫變得更平順，具體有以下幾個：
 
`1.先切換 Tab，再解散視圖控制器：`
    - 在解散 (`dismiss`) 當前的 `OrderConfirmationViewController` 之前，先將 `UITabBarController` 的選中索引設定為 `Menu` 的部分（`TabIndex.menu.rawValue`）。
    - 這樣一來，當 `OrderConfirmationViewController` 被解散後，畫面會直接顯示 `MenuViewController`，不會再出現多餘的跳轉，減少了過渡過程中的重複感和跳動感，讓用戶的視覺體驗更流暢。

`2.關閉視圖控制器時無動畫 (animated: false)：`
    - 在解散 `presentingViewController` 時，選擇將動畫設置為` false（dismiss(animated: false)）`，這樣可以避免多個動畫在相同過程中交疊，導致的不同步或不協調，進而減少畫面上的“跳動”或“閃爍”。
    - 沒有淡出的動畫，使整個過程變得更加同步和平滑，視覺上不會因為動畫時間不一致而影響過渡效果。

`3.在 resetNavigationStacksWithAnimation() 中針對 NavigationController 層級做動畫處理：`
    - 將動畫處理集中在 `menuNavigationController.view` 上，利用 `UIView.transition` 進行淡入動畫，而不是對整個 `keyWindow` 進行處理。這樣可以更精準地控制動畫範圍，避免影響到其他 UI 元件，如 `TabBarController` 的閃爍。
    - 當對 `menuNavigationController.view` 進行淡入動畫時，只有 `MenuViewController` 及其導航層級會受到影響，`TabBarController` 不會因為動畫而閃爍，整體轉場更加集中和自然。
 
 
 `* 成功的原因總結`
 
 `1.動畫分離處理：`
    - 將 `UITabBarController` 的 `selectedIndex` 切換和 `dismiss` 視圖控制器的操作分開進行，避免了兩個動畫交疊進行，這樣能夠減少由於動畫時間不匹配而導致的不協調。
 
 `2,淡出動畫與淡入動畫的合理分配：`
    - 在解散時選擇沒有動畫`（dismiss(animated: false)）`，避免了多重動畫之間的干擾，隨後針對具體的 `menuNavigationController.view` 進行淡入動畫，使得動畫更集中在具體目標，減少了對 `TabBarController` 的影響。
 
` 3.適當的動畫位置和順序：`
    - 先切換 `Tab`，再執行解散視圖控制器和導航堆疊重置，這樣可以更好地控制過渡過程，使每個動畫階段更流暢地銜接。
 */


// MARK: - 重點筆記：導航堆疊重置與動畫過渡調整
/**
 
 ## 重點筆記：導航堆疊重置與動畫過渡調整

 `1. 功能概述`
 
 - `resetNavigationStacksWithAnimation()` 方法負責重置應用中各個主要頁面的導航堆疊，使其返回到根視圖控制器。
 - 這樣的重置操作能保證應用在某些流程（如訂單確認後）結束時，導航狀態保持一致，提升用戶的整體體驗。

 `2. 具體調整與細節`
 
 - `Menu 頁面 (主選單)：`
    - 使用 `UIView.transition` 與 `transitionCrossDissolve` 動畫效果返回到根視圖控制器。
    - 動畫的設計使過渡更加平順，提升用戶對主要頁面的視覺體驗。
    
 - `Search、Order、UserProfile 頁面：`
      - 使用 `popToRootViewController(animated: false)` 返回根視圖控制器，不使用動畫。
      - 頁面主要關注操作效率，因此不需要額外的動畫過渡。

 `3. 使用這樣設計的好處`
 
 - 一致性：每次結束操作後，所有主要頁面都回到根視圖控制器，保證導航狀態一致，避免用戶再次訪問時看到未預期的內容。
 - 簡化導航狀態管理：回到根視圖能減少導航堆疊的深度，降低因不一致狀態引發的錯誤。
 - 平衡體驗與效率：對主頁面（Menu）使用動畫過渡，增強體驗，而對於其他次要頁面（Search、Order、UserProfile），使用簡潔直接的返回，保證操作的流暢性和效率。

 `4. 遇到的問題與解決方案`
 
 - `問題`： 在訂單確認流程結束後，返回到主菜單時，某些頁面未回到根視圖控制器，導致用戶再次訪問時出現不一致的導航狀態。
 - `解決方案`： 使用 `TabIndex` 確保正確定位各個頁面的 `NavigationController`，並通過 `popToRootViewController` 方法，將導航堆疊重置到根視圖控制器，並且根據不同頁面的性質，選擇是否使用過渡動畫。
 
 */


// MARK: - 訂單完成後的資料清除與頁面返回操作 - 重點筆記（重要）

/**
 ## 訂單完成後的資料清除與頁面返回操作 - 重點筆記

 `1. 問題背景`
 
    - `訂單完成後的處理`：當用戶完成訂單並確認後，應對訂單資料進行清理，確保下一次訂單開始於一個乾淨的狀態。並返回主菜單頁面。
    -` 視覺體驗需求`：返回頁面的過程應當流暢，避免多重動畫干擾帶來的跳動或不自然感。
 
 `2. 訂單完成後的資料清除`
 
 `* 清空 OrderItem：`
    - 使用` OrderItemManager.shared.clearOrder()` 清空所有訂單項目。
    - 這樣設計的原因在於每個訂單都是獨立的，完成後應清空舊訂單項目，為下一次訂單做好準備。
 
 `* 重置 CustomerDetails：`
    - 使用 `CustomerDetailsManager.shared.resetCustomerDetails() `方法重置顧客詳細資料。
    - 清除的資料包含顧客的姓名、電話、地址等，以防止這些資料影響下一次訂單。
    - 這樣可以確保顧客每次下訂單時都從新開始，尤其是當顧客的資料在本次訂單中有修改時。
 
 `3. 頁面返回操作的步驟`
 
 `* 先切換 Tab，再解散視圖控制器：`
    - 在執行 dismiss（關閉視圖控制器）之前，先將 `UITabBarController` 的 `selectedIndex` 設置為` TabIndex.menu.rawValue`，即 MenuViewController 對應的索引。
    - 這樣可以保證當前視圖控制器解散後，主頁面會正確顯示為菜單頁，而不是原來的訂單頁。
 
 `* 解散呈現的視圖控制器：`
    - 使用 dismiss(animated: false) 關閉當前的 `OrderConfirmationViewController`，此時沒有動畫，避免多重動畫之間的干擾。
 
 `* 重置導航堆疊並加入淡入動畫：`
    - 對於導航堆疊的重置操作，應使用 UIView.transition 對具體的 `menuNavigationController.view` 進行淡入動畫，確保回到根視圖控制器（即 MenuViewController）。
    - 這樣可以避免影響 UITabBarController 的其他部分，讓過渡效果集中在需要的部分，過程更加平滑自然。
 
 `4. 實作細節說明`
 
 `* 先切換 Tab，避免動畫交叉影響：`
    - 在關閉 `OrderConfirmationViewController` 之前，先將 `tabBarController.selectedIndex` 設置為` TabIndex.menu.rawValue`（主菜單）。
    - 這樣做的目的是減少在解散動畫與 Tab 切換動畫之間的干擾，防止多重動畫疊加導致不流暢。
 
 `* 清空資料：`
    - 在按下關閉按鈕的操作中，除了 dismiss，還需要執行 `CustomerDetailsManager.shared.resetCustomerDetails()` 和 `OrderItemManager.shared.clearOrder()`。
    - 這些操作保證當前訂單完成後，所有臨時資料被清空，以免影響下一次訂單。
 
 `* 加入淡入動畫的導航堆疊重置：`
    - 在 `resetNavigationStacksWithAnimation() `方法中，使用 UIView.transition 對 `menuNavigationController.view` 進行淡入動畫。
    - 確保畫面過渡更加自然，減少用戶看到多層視圖重疊或跳轉的感覺。
    - 同樣地，對於其他的 NavigationController（如 Search、Order、UserProfile）也應確保其返回根視圖控制器，避免殘留的視圖影響後續操作。
 
 `5. 這樣設計的好處`
    - `資料清理`：保證每次訂單都是獨立的，完成訂單後所有相關資料會被清除，為下一次訂單做好準備。
    - `視覺體驗優化`：透過分步執行 selectedIndex 設置和 dismiss，並對導航堆疊進行適當的動畫處理，減少了多重動畫交叉干擾，使畫面更加流暢、自然。
    - `一致性與同步`：清空資料與視圖返回操作是同步進行的，確保用戶在確認訂單後立即回到主頁，且資料狀態已被重置，減少錯誤操作的風險。
 
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

 `* 改進方案`
 
 `* 採用資料驅動的 UI 配置，延遲初始化 OrderConfirmationHandler：`
    - `延遲初始化 OrderConfirmationHandler`：將 `OrderConfirmationHandler` 的初始化移到資料加載完成之後進行，而不是在 `viewDidLoad()` 中。
    - 這樣可以保證在有完整訂單資料後再初始化和設置 UI，避免 UI 顯示不完整或出錯。
 
 `* 手勢處理邏輯獨立化，改善責任分離和可維護性：`
    - `獨立出手勢處理邏輯`：將與 Section Header 的點擊展開/收起相關的手勢處理從 `OrderConfirmationHandler` 中分離出來，放入新的類別 `OrderConfirmationHeaderGestureHandler` 中。
    - `責任分離`:這樣做可以讓 `OrderConfirmationHandler` 專注於數據顯示和 UI 配置，而 `OrderConfirmationHeaderGestureHandler` 專注於手勢的添加與管理，降低耦合度並提高程式碼的可讀性和可維護性。
 
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
 
 `* 改進後的好處`
 
 `1.避免顯示不完整的 UI`：在資料完全準備好後再進行 UI 初始化，這樣可以避免顯示不完整或出錯的情況。
 `2.用戶體驗提升`：用戶不會看到未加載完全的 UI，整體的界面顯得更加穩定和可靠。
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

// MARK: - 資料驅動的 UI 配置
import UIKit
import Firebase

/// 訂單確認頁面控制器，負責顯示訂單確認後的詳情，例如顧客資訊、訂單項目和總金額。
class OrderConfirmationViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 用於存放提交後的訂單資料
    var orderConfirmation: OrderConfirmation?
    
    /// 自訂的 OrderConfirmationView，用於顯示訂單確認頁面的畫面
    private let orderConfirmationView = OrderConfirmationView()
    
    /// 處理訂單確認頁面中顯示資訊的 Handler，負責處理 UICollectionView 的數據和委託
    /// - 需要在訂單資料成功加載後初始化
    private var orderConfirmationHandler: OrderConfirmationHandler?

    /// 負責與 Firebase 互動以獲取訂單資料的管理器
    private let orderConfirmationManager = OrderConfirmationManager()
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        self.view = orderConfirmationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLatestOrderData()
    }
    
    // MARK: - Setup Methods
    
    /// 初始化並設置 `OrderConfirmationHandler`，並將其設置為 collectionView 的數據源和委託
    /// - 說明：此方法需要在成功獲取訂單資料後調用，以確保在資料完整的前提下進行 UI 配置
    /// - 設置步驟：
    ///   1. 初始化 `OrderConfirmationHandler`，並將 `delegate` 設置為當前的 ViewController
    ///   2. 將 `OrderConfirmationHandler` 設置為 `collectionView` 的數據源和委託
    private func setupOrderConfirmationHandler() {
        guard let orderConfirmation = orderConfirmation else { return }
        
        // 初始化 Handler，並將自己設置為 `delegate`
        let handler = OrderConfirmationHandler(delegate: self)
        self.orderConfirmationHandler = handler
        
        // 設置 collectionView 的數據源和委託
        orderConfirmationView.collectionView.dataSource = handler
        orderConfirmationView.collectionView.delegate = handler
        
        // 重新加載數據
        orderConfirmationView.collectionView.reloadData()
    }
    
    // MARK: - Data Fetching Methods
    
    /// 獲取最新的訂單資料並更新畫面，使用非同步方式從 Firebase 獲取資料。
    private func fetchLatestOrderData() {
        HUDManager.shared.showLoadingInView(self.view, text: "Loading Data...")
        Task {
            do {
                guard let userID = Auth.auth().currentUser?.uid else {
                    throw OrderConfirmationManager.OrderConfirmationError.missingField("User ID")
                }
                let latestOrder = try await orderConfirmationManager.fetchLatestOrder(for: userID)
                handleFetchedOrder(latestOrder)
            } catch {
                handleFetchOrderError(error)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Helper Methods

    /// 處理成功獲取的訂單資料，並設置 UI
    /// - Parameter order: 最新的訂單資料
    private func handleFetchedOrder(_ order: OrderConfirmation) {
        self.orderConfirmation = order
        printFetchedOrderDetails(order)
        setupOrderConfirmationHandler()             // 在成功獲取訂單後初始化 Handler 並設置 UI
    }
    
    /// print 獲取到的訂單詳細資料以進行觀察
    /// - Parameter order: 需要打印的訂單資料
    private func printFetchedOrderDetails(_ order: OrderConfirmation) {
        print("成功獲取訂單: \(order)")
        print("訂單時間：\(order.timestamp)")
        print("訂單顧客姓名：\(order.customerDetails.fullName)")
        print("訂單總金額：\(order.totalAmount)")
        print("訂單準備時間：\(order.totalPrepTime)")
        print("訂單項目數量：\(order.orderItems.count)")
    }
    
    /// 處理獲取訂單資料時出現的錯誤
    /// - Parameter error: 出現的錯誤
    private func handleFetchOrderError(_ error: Error) {
        print("獲取訂單失敗: \(error.localizedDescription)")
    }
    
}

// MARK: - OrderConfirmationHandlerDelegate
extension OrderConfirmationViewController: OrderConfirmationHandlerDelegate {
    
    // MARK: - Section Handling

    /// 切換指定區域的展開/收起狀態
    /// - Parameter section: 被點擊的區域索引
    /// - 說明：收到 `OrderConfirmationHandler` 的通知後，重新載入對應的區域顯示，以反映使用者的展開或收起操作
    func didToggleSection(_ section: Int) {
        // 更新指定區域的顯示，切換展開/收起狀態
        print("Did toggle section: \(section)")
        orderConfirmationView.collectionView.reloadSections(IndexSet(integer: section))
    }
    
    // MARK: - Order Data Methods

    /// 返回目前的訂單資料
    /// - 用於提供給 `OrderConfirmationHandler` 來顯示訂單詳細內容
    func getOrder() -> OrderConfirmation? {
        return orderConfirmation
    }
    
    // MARK: - Close Button Handling

    /// 當按下 "關閉" 按鈕時的操作，返回主菜單頁面。
    func didTapCloseButton() {
        AlertService.showAlert(withTitle: "確認返回", message: "您即將返回主菜單，這將會清空目前的訂單資料和顧客資料，是否繼續？", inViewController: self, showCancelButton: true) {[weak self] in
            self?.proceedWithClosing()
        }
    }
    
    /// 執行返回主菜單頁面的操作
    private func proceedWithClosing() {
        // 切換至主菜單頁面的 Tab
        switchToMenuTab()
        // 清空顧客資料和訂單項目
        clearOrderData()
        // 淡出解散當前的 OrderConfirmationViewController。
        dismissViewController()
    }
    
    /// 切換至主菜單頁面的 Tab
    private func switchToMenuTab() {
        guard let tabBarController = getTabBarController() else { return }
        // 設置 TabBarController 選擇的索引為 Menu 頁面 (使用 TabIndex)
        tabBarController.selectedIndex = TabIndex.menu.rawValue
    }
    
    /// 清空顧客資料和訂單項目
    private func clearOrderData() {
        CustomerDetailsManager.shared.resetCustomerDetails()    // 重置顧客資料
        OrderItemManager.shared.clearOrder()                    // 清空訂單項目
    }
    
    /// 淡出解散當前的視圖控制器（OrderConfirmationViewController）
    private func dismissViewController() {
        if let presentingViewController = self.presentingViewController {
            presentingViewController.dismiss(animated: false) { [weak self] in
                self?.resetNavigationStacksWithAnimation()
            }
        }
    }
    
    // MARK: - Navigation Handling

    /// 重置導航堆疊並加入淡入動畫，使過渡更加平順。
    private func resetNavigationStacksWithAnimation() {
        guard let tabBarController = getTabBarController() else { return }
        
        let tabIndicesWithAnimation: [TabIndex] = [.menu]
        let tabIndicesWithoutAnimation: [TabIndex] = [.search, .order, .profile]
        
        // 回到根視圖控制器，使用動畫效果（例如 Menu）
        for tabIndex in tabIndicesWithAnimation {
            if let navigationController = tabBarController.viewControllers?[tabIndex.rawValue] as? UINavigationController {
                UIView.transition(with: navigationController.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    navigationController.popToRootViewController(animated: false)
                })
            }
        }
        
        // 回到根視圖控制器，不使用動畫效果（例如 Search、Order、UserProfile）
        for tabIndex in tabIndicesWithoutAnimation {
            if let navigationController = tabBarController.viewControllers?[tabIndex.rawValue] as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
    }
    
    /// 獲取當前的 UITabBarController
    private func getTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
              let tabBarController = keyWindow.rootViewController as? UITabBarController else {
            return nil
        }
        return tabBarController
    }
    
}



// MARK: - 還沒實踐「資料驅動的 UI 配置」
/*
import UIKit
import Firebase

/// 訂單確認頁面控制器，負責顯示訂單確認後的詳情，例如顧客資訊、訂單項目和總金額。
class OrderConfirmationViewController: UIViewController {

    // MARK: - Properties

    /// 用於存放提交後的訂單資料
    var orderConfirmation: OrderConfirmation?
     
    /// 自訂的 OrderConfirmationView，用於顯示訂單確認頁面的畫面
    private let orderConfirmationView = OrderConfirmationView()
    
    /// 處理訂單確認頁面中顯示資訊的 Handler，負責處理 UICollectionView 的數據和委託
    private let orderConfirmationHandler = OrderConfirmationHandler()
    
    /// 負責與 Firebase 互動以獲取訂單資料的管理器
    private let orderConfirmationManager = OrderConfirmationManager()
 
    // MARK: - Lifecycle Methods

    override func loadView() {
        self.view = orderConfirmationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupCollectionView()
        fetchLatestOrderData()
    }
    
    // MARK: - Setup Methods

    /// 設置 Handler 及委託的相關操作
    private func setupDelegates() {
        orderConfirmationHandler.delegate = self
    }
    
    /// 設置 `UICollectionView` 的數據源和委託，以便顯示訂單確認內容。
    private func setupCollectionView() {
        orderConfirmationView.collectionView.dataSource = orderConfirmationHandler
        orderConfirmationView.collectionView.delegate = orderConfirmationHandler
    }
    
    // MARK: - Data Fetching Methods
    
    /// 獲取最新的訂單資料並更新畫面，使用非同步方式從 Firebase 獲取資料。
    ///
    /// - 獲取當前用戶的 ID。
    /// - 處理獲取到的訂單資料。
    private func fetchLatestOrderData() {
        Task {
            do {
                guard let userID = Auth.auth().currentUser?.uid else {
                    throw OrderConfirmationManager.OrderConfirmationError.missingField("User ID")
                }
                let latestOrder = try await orderConfirmationManager.fetchLatestOrder(for: userID)
                handleFetchedOrder(latestOrder)
            } catch {
                handleFetchOrderError(error)
            }
        }
    }
    
    // MARK: - Helper Methods

    /// 處理成功獲取的訂單資料
    /// - Parameter order: 最新的訂單資料
    private func handleFetchedOrder(_ order: OrderConfirmation) {
        self.orderConfirmation = order
        printFetchedOrderDetails(order)
        self.orderConfirmationView.collectionView.reloadData()
    }

    /// print 獲取到的訂單詳細資料以進行觀察
    /// - Parameter order: 需要打印的訂單資料
    private func printFetchedOrderDetails(_ order: OrderConfirmation) {
        print("成功獲取訂單: \(order)")
        print("訂單時間：\(order.timestamp)")
        print("訂單顧客姓名：\(order.customerDetails.fullName)")
        print("訂單總金額：\(order.totalAmount)")
        print("訂單準備時間：\(order.totalPrepTime)")
        print("訂單項目數量：\(order.orderItems.count)")
    }
    
    /// 處理獲取訂單資料時出現的錯誤
    /// - Parameter error: 出現的錯誤
    private func handleFetchOrderError(_ error: Error) {
        print("獲取訂單失敗: \(error.localizedDescription)")
    }
    
}

// MARK: - OrderConfirmationHandlerDelegate
extension OrderConfirmationViewController: OrderConfirmationHandlerDelegate {
    
    /// 返回目前的訂單資料
    /// - 用於提供給 `OrderConfirmationHandler` 來顯示訂單詳細內容
    func getOrder() -> OrderConfirmation? {
        return orderConfirmation
    }
    
    /// 當按下 "關閉" 按鈕時的操作，返回主菜單頁面。
    func didTapCloseButton() {
        AlertService.showAlert(withTitle: "確認返回", message: "您即將返回主菜單，這將會清空目前的訂單資料和顧客資料，是否繼續？", inViewController: self, showCancelButton: true) {[weak self] in
            self?.proceedWithClosing()
        }
    }
    
    /// 執行返回主菜單頁面的操作
    private func proceedWithClosing() {
        // 切換至主菜單頁面的 Tab
        switchToMenuTab()
        // 清空顧客資料和訂單項目
        clearOrderData()
        // 淡出解散當前的 OrderConfirmationViewController。
        dismissViewController()
    }
    
    /// 切換至主菜單頁面的 Tab
    private func switchToMenuTab() {
        guard let tabBarController = getTabBarController() else { return }
        // 設置 TabBarController 選擇的索引為 Menu 頁面 (Menu 是索引0)
        tabBarController.selectedIndex = 0
    }
    
    /// 清空顧客資料和訂單項目
    private func clearOrderData() {
        CustomerDetailsManager.shared.resetCustomerDetails()    // 重置顧客資料
        OrderItemManager.shared.clearOrder()                    // 清空訂單項目
    }
    
    /// 淡出解散當前的視圖控制器（OrderConfirmationViewController）
    private func dismissViewController() {
        if let presentingViewController = self.presentingViewController {
            presentingViewController.dismiss(animated: false) { [weak self] in
                self?.resetNavigationStacksWithAnimation()
            }
        }
    }
    
    /// 重置導航堆疊並加入淡入動畫，使過渡更加平順。
    private func resetNavigationStacksWithAnimation() {
        guard let tabBarController = getTabBarController() else { return }
        
        // 確保選中的 NavigationController 回到根視圖控制器。
        if let menuNavigationController = tabBarController.viewControllers?[0] as? UINavigationController {
            // 使用淡入動畫返回根視圖控制器
            UIView.transition(with: menuNavigationController.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                menuNavigationController.popToRootViewController(animated: false)
            })
        }
        
        // 確保 Order 的 NavigationController 也回到根視圖控制器，但不加動畫。
        if let orderNavigationController = tabBarController.viewControllers?[1] as? UINavigationController {
            orderNavigationController.popToRootViewController(animated: false)
        }
    }
    
    /// 獲取當前的 UITabBarController
    private func getTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
              let tabBarController = keyWindow.rootViewController as? UITabBarController else {
            return nil
        }
        return tabBarController
    }
    
}
*/
