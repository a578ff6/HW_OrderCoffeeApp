//
//  OrderPickupMethodCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/13.
//


// MARK: - OrderPickupMethodCell 重點筆記

/*
 ## OrderPickupMethodCell 重點筆記：

    * 功能：
        - 用於選擇取件方式（「到店自取」或「外送服務」）並顯示相關 UI，包含取件方式的選擇控制元件，以及店家選擇和地址輸入的元件。

    * 組成部分：

        1. UI 元件
            - pickupMethodSegmentedControl：選擇「到店自取」或「外送服務」的 UISegmentedControl。
            - storeTextField：顯示已選擇的店家名稱，無法直接編輯。
            - selectStoreButton：供使用者選擇店家的按鈕。
            - promptSelectLabel：提示使用者選擇店家的標籤。
            - addressTextField：供使用者輸入外送地址的 UITextField。
            - deliveryFeeLabel：顯示外送服務費用的標籤。
            - mainStackView：包含所有 UI 元素的主垂直 StackView。
            - storeHorizontalStackView：包含店家選取相關元素的水平 StackView。
            - inStoreStackView：垂直排列與到店自取相關的 UI 元素。
            - homeDeliveryStackView：垂直排列與外送服務相關的 UI 元素。

        2. 回調 (Callback)
            - onAddressChange：在使用者更改 addressTextField 的文本時觸發的回調。
            - onStoreButtonTapped：在使用者點擊 selectStoreButton 時觸發，通知外部進行店家選擇。
            - onStoreChange：在選擇店家後設置店家名稱時觸發的回調。（先保留）

        3. 初始化
            - setupViews()：設置所有 UI 元素，並將它們添加到 mainStackView 中，應用佈局約束。
            - setupActions()：為 pickupMethodSegmentedControl、selectStoreButton 和 addressTextField 添加相應的事件監聽。

        4. 更新 UI 方法
            - updateUI(for:)：根據選擇的取件方式更新相關 UI，僅在對應欄位有值時清空不相關的輸入欄位。例如，切換至「到店自取」時，只有 storeTextField 有值時才會清空 addressTextField。
            - segmentedControlValueChanged()：監聽 segmented control 的變更，觸發更新 UI。

        5. 動態邊框設置
            - setTextFieldBorder(_:, isEmpty:)：根據輸入欄位是否為空設置 UITextField 的紅框提示，用於提示必填欄位。
            - selectStoreButtonTapped()：點擊選擇店家按鈕後，更新 storeTextField 並移除紅框提示。

    * 設計考量：

        1. 考量到 UseerDetails 的 address 會有填寫，因此預設顯示「外送服務」，避免因為切換「取件方式」而清空 addressTextField。
            - 避免因為切換「取件方式」而清空 addressTextField，保護使用者的輸入資料。
 
        2. 必填欄位提示
            - storeTextField 和 addressTextField 設置了紅框判斷，以即時提示使用者這些欄位為必填。
            - 根據取件方式的切換，適時地設置或移除紅框。

        3. 簡化事件監聽
            - 因為 storeTextField 是無法直接編輯的，storeTextFieldChanged 可以省略，僅在點擊 selectStoreButton 後更新店家名稱時進行狀態更新。

        4. 清空不相關欄位
            - 切換取件方式時，會僅在需要時清空不相關的輸入欄位。例如：從「外送服務」切換到「到店自取」時，只有 storeTextField 有值時才會清空 addressTextField，確保不會無意中移除使用者已填寫的資料。

    * 未來改進空間：

        1. 店家選擇視圖的實現
            - 目前選擇店家的邏輯是模擬的，未來需實現實際的店家選擇視圖，以便正確設置店家名稱。

        2. 資料驗證強化
            - 目前只對空值進行判斷，可以考慮增加對地址格式的驗證，以提高輸入資料的正確性。
 
## 調整部分：
 
    &. 原先是 updateUI 是只要切換取件方式時，將另一個取件方式的相關欄位`清空`。
 
        * 為什麼要這樣做？
            - 能夠確保用戶在切換取件方式時，不會因為不必要的操作而失去輸入的資料。
            - 僅在相關欄位有資料時才執行清空動作，避免讓用戶感到混淆。
 
        * 現在的邏輯：
            - 只有在對應欄位有資料時才執行清空操作，避免讓用戶在無必要時失去輸入的資料，這樣可以更精確地保護使用者體驗。
 */


// MARK: - 最初想法考量

/*
 1. 使用 Segmented Control 切換「取件方式」
 
    * 使用 Segmented Control
        - 採用 Segmented Control 作為「到店自取」或「外送服務」的選擇方式，因為這類選擇通常只有兩種或少量的選項，並且切換時能夠快速反應。這可以讓使用者簡單且快速地選擇取件方式，並且即時更新視圖。

    * 對於 OrderCustomerDetailsHandler 和 OrderCustomerDetailsViewController 的影響
        - 在 Segmented Control 的值改變時，需要影響到 OrderCustomerDetailsHandler 和 OrderCustomerDetailsViewController 的顯示方式。因為不同的取件方式有不同的 UI 顯示需求，例如：

            1.「到店自取」需要顯示店家選擇的按鈕和名稱。
            2.「外送服務」需要顯示用戶填寫地址的 TextField。
 
        - 在實作上，可以在 OrderPickupMethodCell 中使用一個 Segmented Control 來切換顯示不同的內容，並且透過閉包或 Delegate 傳遞狀態變化給 OrderCustomerDetailsHandler，進而更新 UICollectionView 的顯示。


 2. UI 元件佈局應如何處理
 
    * 有兩種設置方案：

    * 方案一：同一個 OrderPickupMethodCell 中處理
        
    - 可以在同一個 OrderPickupMethodCell 中設置所有需要的 UI 元件（例如：店家名稱的 Label、選擇店家按鈕、輸入地址的 TextField），並根據 Segmented Control 的選擇，動態地隱藏或顯示相應的元件。

        優點：簡單易於管理，所有取件方式的邏輯集中在一個 Cell 中。
        缺點：如果元件較多，這個 Cell 的複雜度會增加。
 
 
    * 方案二：兩個不同的 Cell
 
    - 也可以設置兩個不同的 UICollectionViewCell，一個專門用於「到店自取」，另一個專門用於「外送服務」，並透過 Segmented Control 來切換顯示。

        優點：每個 Cell 的邏輯簡單且容易維護，不同的取件方式完全獨立。
        缺點：在切換時可能需要更多的程式碼來更新 UICollectionView，且可能涉及到重複顯示邏輯。
 
3. 具體實作
 
    - 由於 OrderPickupMethodCell 中的「到店自取」或「外送服務」，所需要顯示的UI元件不多，因此採用方案一的構想。(使用UIStackView)
    - 在 OrderPickupMethodCell 中加入 Segmented Control：用於選擇「到店自取」或「外送服務」。
    - 在 cellForItemAt 中進行配置：根據 CustomerDetails 的 pickupMethod 來初始設置 Segmented Control 的選擇項目。
    - 根據 Segmented Control 的值來隱藏或顯示相關的 UI 元件。
 */


// MARK: - 測試邏輯思考方向

/*
 1.為何 setTextFieldBorder 的 storeTextField 是設置在 selectStoreButtonTapped 才解決了問題，而不是設置在 storeTextFieldChanged 呢？

    - 在邏輯中，storeTextFieldChanged 並沒有觸發輸入變更，因為 storeTextField 本身是無法編輯的。
    - 這樣的情況下，使用者無法直接在 storeTextField 上輸入店家名稱，因此並不會觸發這個變更事件。
    - 相反地，當用戶點擊 selectStoreButton 並選擇店家時，才會更新 storeTextField，因此應該在 selectStoreButtonTapped 中設置 setTextFieldBorder。

 2. 為何 configure 中的 setTextFieldBorder(storeTextField, isEmpty: customerDetails.storeName?.isEmpty ?? true) 不需要採用到呢？
 
    - 在 configure 中的 setTextFieldBorder 主要用來初始化欄位的狀態。
    - 因為在 updateUI 裡已經有針對切換取件方式時進行邊框的設定，這個設定已經能覆蓋 configure 的邊框狀態，所以這部分在 configure 中可以考慮不需要重複處理。

 3. 目前 storeTextFieldChanged 相關設置都是必要的嗎？還是說其實可以不用設置那麼多的 storeTextFieldChanged，或是有更好的處理方式，不需要設置那麼多 storeTextFieldChanged 呢？
 
    - storeTextFieldChanged 目前的邏輯其實並不太需要，因為 storeTextField 是不可編輯的，主要的變更是來自於選擇店家按鈕的動作處理 (selectStoreButtonTapped)。
    - 這樣的情況下，可以完全省略 storeTextFieldChanged，並集中在選擇店家按鈕被點擊之後的處理來更新視圖狀態，這樣會讓程式碼簡潔許多，同時減少不必要的事件監聽。
 */


// MARK: - 新增 updatePickupMethod(_ method: PickupMethod):

/*
 
 ## 關鍵方法與邏輯

    * segmentedControlValueChanged():
        - 用於處理當使用者在 Segmented Control 中切換取件方式時的動作。根據選擇更新取件方式，並呼叫 CustomerDetailsManager.shared.updatePickupMethod()，確保顧客資料同步更新。
        - 然後呼叫 updateUI(for:) 方法更新 UI，以顯示相應取件方式的相關元素。

    * updatePickupMethod(_ method: PickupMethod):
        - CustomerDetailsManager 中的方法，用於更新顧客的取件方式，以確保顧客資料的統一管理和資料同步。這樣不論在哪裡更改取件方式，都能保持資料的一致性。
 
 ## 設計考量

    * 資料同步更新
        - 在 segmentedControlValueChanged() 方法中直接使用 CustomerDetailsManager.shared.updatePickupMethod(selectedMethod) 是為了保持取件方式的資料一致性，確保顧客的所有資料都經過統一的資料管理器更新。

    * 維護方便性
        - 集中管理資料更新，方便未來如有新需求，只需要修改 CustomerDetailsManager 即可，減少重複代碼並提高可維護性。

    * 未來改進方向
        - 可以考慮在 updatePickupMethod 方法中添加其他的業務邏輯，比如當切換為「外送服務」時，更新訂單的總金額以包含額外的運費。這樣可以使邏輯更集中，並減少界面層級中的複雜性。
 */

// MARK: - 在選擇店家後 Submit 按鈕未啟用

/*
 * 未執行 onStoreChange 回調：
 
    - 在選擇「到店自取」時，將設置好的「大安店」傳到 storeTextField 時，雖然 storeTextField 的內容被設置為 "大安店"。
    - 但 onStoreChange 回調未被觸發，從而無法通知 CustomerDetailsManager 更新店家名稱，最終導致表單驗證未通過。
 
 * 解決方式：
 
    - 在 selectStoreButtonTapped 方法中，調用 onStoreChange 回調，告訴外部（如 ViewController）顧客的店家選擇已經更改。
    - 這樣做可以確保 storeName 的更新會正確反映到 CustomerDetailsManager 中，並且觸發 customerDetailsDidChange() 方法來更新提交按鈕的狀態。
 
 * 顧客資料未正確更新：
 
    - 如果 onStoreChange 沒有被調用，則 CustomerDetailsManager 中的顧客資料不會更新，導致在驗證表單時，系統認為顧客尚未選擇店家，進而使提交按鈕保持禁用狀態。
 */


// MARK: - 如何在切換取件方式後有效管理各個欄位的狀態（發生的問題）

/*
 1. 問題描述
 
    - 當使用者選擇「Home Delivery」時填寫了addressTextField，接著切換到「In-Store Pickup」，雖然 storeTextField 沒有填寫值，但由於之前的addressTextField已經有內容，提交按鈕仍然處於啟用狀態，這就導致顧客資料（customerDetails）在提交時包含了與當前取件方式不一致的資訊。

    - 這樣的行為顯示出在切換取件方式後，原有的資料沒有被適當清空，導致資料不一致。

 2. 主要問題與需求
 
    - 當切換取件方式時，應該根據新的取件方式去判斷相對應欄位的填寫狀況，若新的方式下相對應欄位沒有填寫，提交按鈕應該被禁用。
    - 需要保留原有填寫的資訊，以便當使用者切換回來時不用重新輸入。
    - 保持資料的同步和一致性，確保 CustomerDetails 中的資料符合當前的取件方式。
 
 3. 建議的解決方案（我選擇方法1）
 
    &. 方法1：切換取件方式時保留資料，但不影響驗證
 
       * 在切換取件方式時，可以選擇不自動清空資料，但當提交訂單時，要根據取件方式來檢查必填欄位是否已經正確填寫。具體的處理方式如下：

        - 在每次切換取件方式後，更新提交按鈕的狀態。
        - 當切換到「In-Store Pickup」時，如果 storeTextField 沒有值，則即使 addressTextField 有值，提交按鈕應當被禁用。
        - 保留切換取件方式之前的輸入值，但不在顯示的 UI 上展示這些資料（即使資料在 CustomerDetails 中），這樣可以確保當切回時能夠復原之前的內容。
 
 
    &. 方法2：每次切換取件方式時自動清空相對應的資料
 
        - 當切換取件方式時，自動清空不相應的資料欄位。例如，從「Home Delivery」切換到「In-Store Pickup」時，清空地址欄位 addressTextField，並相應地更新 CustomerDetails。
        - 儲存使用者的輸入資料，以便切回取件方式時能自動恢復，但這可能會增加一些狀態管理的複雜性。
 */

// MARK: - 如何在切換取件方式後有效管理各個欄位的狀態（重點筆記：取件方式切換與資料同步更新）

/*
 
 ## 重點筆記：取件方式切換與資料同步更新

    * 目標（在切換取件方式後）：

        - 僅在欄位有填寫值時，才清空相應的欄位，避免不必要的資料丟失。
        - 確保提交按鈕狀態即時更新，正確反映當前表單的完整性，防止不完整資料被提交。
        - 當切換取件方式時，如果 `conditionTextField`（店家欄位或地址欄位）有值，則清空另一個取件方式相關的欄位（從「到店取件」切換回「外送服務」時，若店家欄位有值，則清空地址欄位）。同時，通知對應的變更以更新 `CustomerDetails` 和提交按鈕狀態。

 &. 問題：
 
    1. 資料沒有即時清空：
 
        * 描述：
            - 當使用者切換取件方式時，上一個取件方式的對應欄位（例如，地址或店家名稱）並沒有被適當清空，導致保留了與當前選擇的取件方式不相關的資料。

        * 具體例子：
            - 當取件方式從「Home Delivery」切換到「In-Store Pickup」時，addressTextField（外送地址欄位）仍保留先前輸入的地址。
            - 當用戶在「In-Store Pickup」填寫店家名稱後，再次切回「Home Delivery」，本應被清空的地址卻未被及時清空，導致資料錯誤，且在提交訂單時可能包含不一致的資訊（如同時包含地址和店家名稱）。
 
    2. 提交按鈕狀態不正確：
 
        * 描述：
            - 當使用者在表單中未正確填寫所有必填欄位時，提交按鈕仍處於啟用狀態，這樣可能導致提交不完整或錯誤的資料。

        * 具體例子：
            - 當取件方式是「Home Delivery」時，如果 addressTextField 未填寫地址，提交按鈕仍處於可點擊狀態。這可能會導致用戶在未提供必要配送資訊的情況下成功提交訂單。
            - 當取件方式從「In-Store Pickup」切換回「Home Delivery」時，由於地址欄位沒有即時清空和更新狀態，提交按鈕沒有禁用，導致可以在沒有地址的情況下提交資料。

 &. 解決方案：
 
    1. 保留資料但不影響 UI 顯示

        - 當切換取件方式時，保留之前填寫的資料，但 UI 僅顯示當前取件方式相關的欄位（如地址或店家名稱）。
        - 切回之前的取件方式時，自動恢復先前輸入的資料。
 
    2. 同步清空相應欄位
 
        - 透過 updateUI(for:) 方法，在切換取件方式時，只在對應欄位有值時才清空不相應的欄位。
        - 例如，從「Home Delivery」切換到「In-Store Pickup」時，若地址欄位有值則清空，同時需要確保店家欄位正確更新。
 
    3. 取件方式變更後立即進行表單驗證
 
        - 在取件方式變更後，立即重新驗證所有必填欄位，確保提交按鈕的狀態正確。
        - 例如，若切換到「Home Delivery」而地址未填寫，應禁用提交按鈕。
 
    4. 提交按鈕的即時狀態更新
 
        - 當欄位變更時，使用回調通知外部視圖控制器，以即時更新提交按鈕的狀態。
        - 在每次欄位變更或取件方式切換後，調用 updateSubmitButtonState() 確保按鈕狀態與資料同步。
 
 &. 具體實施步驟：
 
    1. OrderPickupMethodCell 的更新
 
        - 在 updateUI(for:) 方法中，切換取件方式時，根據當前方式顯示或隱藏相關的 UI 元件。
        - 若欄位有填寫值，才會清空對應的另一個欄位，確保用戶資料不丟失。清空操作使用 clearTextFieldIfNeeded 方法。
 
    2. 使用回調來通知資料變更
 
        - 在 OrderPickupMethodCell 中，設置 onPickupMethodChanged 回調，每次取件方式變更時，回調通知 Handler。
        - 在 OrderPickupMethodCell 添加 onPickupMethodChanged 回調，以及在 segmentedControlValueChanged 設置此回調，每次取件方式變更時呼叫回調，回調通知 Handler 進行資料驗證和更新提交按鈕狀態。
        - 在 OrderCustomerDetailsHandler 中使用此回調來更新 CustomerDetailsManager 並進行資料驗證。
 
    3. 更新 CustomerDetailsManager 的驗證邏輯
 
        - 確保根據當前取件方式正確地驗證相應的必填欄位。
        - 如選擇「Home Delivery」，需檢查地址是否填寫；如選擇「In-Store Pickup」，則需檢查店家名稱是否填寫。
 
    4. 即時更新提交按鈕的狀態
 
        - 在 OrderCustomerDetailsViewController 中，通過 OrderCustomerDetailsHandler 的回調，當資料或取件方式變更時，調用 updateSubmitButtonState() 來確保提交按鈕狀態與最新資料同步。
 
    5. 關鍵步驟的補充（清空欄位的變更通知與回調）
 
        - 當欄位被清空時，透過回調通知 Handler，更新 CustomerDetailsManager 內的資料，並確保 UI 與提交按鈕狀態保持一致。具體在 clearTextFieldIfNeeded() 方法中，負責通知欄位被清空後的變更。

 &. 最終結果
 
    - 切換取件方式後，只有在欄位有填寫值的情況下才清空對應的資料。
    - UI 上的欄位顯示僅反映當前取件方式相關的資料。
    - 提交按鈕的狀態即時更新，確保在所有必要欄位未正確填寫時禁用按鈕，避免提交不完整的資料。
    - 使用者輸入的資料能夠保留，提升用戶體驗。
 */


// MARK: - setupActions 與欄位變更處理

/*
 ## 筆記：setupActions 與欄位變更處理

 1. setupAction 中的必要設置：
    
    - pickupMethodSegmentedControl： 需要監聽取件方式的變更，當使用者切換取件方式時，觸發 segmentedControlValueChanged ，進行 UI 和資料同步的更新。
    - addressTextField： 需要監聽地址輸入變更，當使用者輸入或修改地址時，觸發 addressTextFieldChanged ，進行資料更新和清空店家名稱的邏輯。
    - selectStoreButton： 需要監聽按鈕點擊事件，當使用者選擇店家時，觸發 selectStoreButtonTapped，進行資料更新，並清空地址的邏輯。

 2. storeTextField 不需要設置在 setupActions：
 
    - 由於 storeTextField 是不可編輯的，所有的變更都是透過 selectStoreButtonTapped 來處理，因此不需要在 setupActions 中對 storeTextField 設置監聽。
    - selectStoreButtonTapped 中已經手動觸發了 onStoreChange，用來更新店家名稱並進行必要的資料處理。

 3. 核心邏輯：
 
    - 每次變更欄位後，需要確保資料一致性：
      - 當「地址欄位」被填寫時，應清空「店家欄位」。
      - 當「店家欄位」被選擇時，應清空「地址欄位」。
 
    - 使用回調來通知資料更新： 每當 addressTextFieldChanged 或 selectStoreButtonTapped 發生變更時，透過回調 (onAddressChange 和 onStoreChange) 通知更新，並確保 CustomerDetails 同步變更。
 
    - 即時更新提交按鈕狀態： 每次資料變更後，立即檢查資料完整性並更新提交按鈕的啟用/禁用狀態，確保只有必填資料完整時才允許提交。

 ---

 ## 重要觀察點：
    - addressTextFieldChanged 與 storeTextFieldChanged 都應在變更後及時更新相應的資料狀態，並清空與取件方式無關的欄位。
    - 不需要監聽 `storeTextField`，因為變更都是透過 `selectStoreButton` 完成。
 */


// MARK: - `addressTextFieldChanged`、`storeTextFieldChanged` 和 `selectStoreButtonTapped` 調整後問題解決

/*
 ## 筆記： addressTextFieldChanged 、 storeTextFieldChanged 和 selectStoreButtonTapped 調整後問題解決

 1. addressTextFieldChanged 的調整：
    - 當使用者在「外送地址」欄位輸入或修改地址時，透過 addressTextFieldChanged 觸發回調 (onAddressChange)，來即時更新顧客的 CustomerDetails 資料。
    - 每次地址變更時，檢查是否有值，若有值，應清空店家名稱 (storeName)，以確保取件方式資料一致。

 2. storeTextFieldChanged 的調整：
    - 儘管 storeTextField 是不可編輯的欄位，但當店家被選擇後，必須透過回調 (onStoreChange) 來更新資料，這裡需要手動處理。
    - 每次店家名稱被更新後，應清空外送地址 (address)，以確保兩種取件方式不會同時存在相關資料。

 3. selectStoreButtonTapped 的調整：
    - 點擊「選擇店家」按鈕時，會觸發 selectStoreButtonTapped ，這時候需手動賦值給 storeTextField，並透過回調更新 CustomerDetails 的店家名稱。
    - 選擇店家後，同樣需要清空外送地址，確保當前顧客資料只反映一種取件方式。

 ## 關鍵調整重點：
    - 資料同步： 每次欄位變更後，確保相關資料欄位同步更新，並及時清空與取件方式無關的資料。
    - 透過回調更新資料： 無論是地址或店家名稱的變更，都要透過回調通知外部邏輯，以便更新 CustomerDetails 並確保按鈕狀態同步。

 這些調整確保了在不同取件方式間的欄位切換時，資料得以正確更新並避免重複儲存多餘的資料。
 */


// MARK: - onfigure(with:) 和 segmentedControlValueChanged （重要）

/*
 
 * configure(with:) 的邏輯和 segmentedControlValueChanged 不同。
 
 &. configure(with:) 方法：

    * 用途：
        - 用於初始化和重新配置 OrderPickupMethodCell 的顯示狀態，通常在首次載入畫面或重新載入資料時使用。
 
    * 行為邏輯：
        - 根據 CustomerDetails 中的數據設置取件方式及相關欄位的內容。
        - 清空不相關的欄位： 在初始化或重新配置時，為保證 UI 和資料一致性，無條件清空不相關的欄位。例如：
 
            1.若選擇「Home Delivery」，清空 storeTextField。
            2.若選擇「In-Store Pickup」，清空 addressTextField。

    * 原因：
        - 由於這是初始化或重新配置，因此不考慮用戶已經輸入的資料，而是以 CustomerDetails 中的資料為基礎來呈現。

 &. segmentedControlValueChanged 方法：

    * 用途：
        - 當使用者切換取件方式時呼叫，用於即時更新畫面。
 
    * 行為邏輯：
        - 條件性清空不相關欄位： 只有在欄位有值時才進行清空，避免過多清除，保留使用者可能有用的輸入。
        - 以使用者互動為主： 這部分的設計是基於用戶互動行為，以減少不必要的干擾，與初始化邏輯不同，不會強制清空所有不相關欄位。
 
 &. 總結：
    - configure(with:) 是在初始化或重新配置資料時使用，無條件清空不相關欄位以保證資料和 UI 的一致性。
    - segmentedControlValueChanged 則是針對使用者的互動，即時更新畫面，只有在需要時才清空欄位，以保留用戶的輸入。
 */


// MARK: - 預設顯示為「外送服務」，並且調整了updateUI對於欄位的判斷邏輯

import UIKit

/// 在 OrderPickupMethodCell 中透過 Segmented Control：用於選擇「到店自取」或「外送服務」。
class OrderPickupMethodCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderPickupMethodCell"

    // MARK: - 取件方式的 SegmentedControl
    
    /// 使用 UISegmentedControl 來讓使用者選擇取件方式
    private let pickupMethodSegmentedControl = createSegmentedControl(items: ["Home Delivery", "In-Store Pickup"])
    
    // MARK: - 地址輸入相關元件

    private let addressTextField = createTextField(withPlaceholder: "Enter Delivery Address")
    private let deliveryFeeLabel = createLabel(withText: "(Delivery service fee is $60)", font: UIFont.systemFont(ofSize: 14), textColor: .lightGray, alignment: .center)
    
    // MARK: - 店家選取相關元件
    
    private let storeTextField = createTextField(withPlaceholder: "Select Store", isUserInteraction: false)
    private let selectStoreButton = createButton(title: "", font: nil, backgroundColor: .deepGreen, titleColor: .white, iconName: "storefront")
    private let promptSelectLabel = createLabel(withText: "(Tap to select a store)", font: UIFont.systemFont(ofSize: 14), textColor: .lightGray, alignment: .center)
    
    // MARK: - StackView
    
    /// 主 StackView，包含所有元素
    private let mainStackView = createStackView(axis: .vertical, spacing: 30, alignment: .fill, distribution: .fill)
    
    /// 店家選取相關元素的水平 StackView
    private let storeHorizontalStackView = createStackView(axis: .horizontal, spacing: 12, alignment: .fill, distribution: .fill)
    
    /// 到店自取相關元素的垂直 StackView
    private let inStoreStackView = createStackView(axis: .vertical, spacing: 20, alignment: .fill, distribution: .fill)
    
    /// 外送服務相關元素的垂直 StackView
    private let homeDeliveryStackView = createStackView(axis: .vertical, spacing: 20, alignment: .fill, distribution: .fill)
    
    // MARK: - Callbacks

    /// 地址變更時的回調
    var onAddressChange: ((String) -> Void)?
    /// 點擊選擇店家按鈕時的回調
    var onStoreButtonTapped: (() -> Void)?      // 在點擊「選擇店家」按鈕時觸發，通知外部（如 ViewController）進行下一步的處理，比如進入「店家選擇視圖」。
    /// 店家選擇完成後更新店家名稱的回調
    var onStoreChange: ((String) -> Void)?     // 當店家選擇完成後（從店家選擇視圖返回）設置店家名稱時觸發，用於更新 storeTextField 的顯示。（先保留，後續可能移除）
    /// 取件方式變更時的回調
    var onPickupMethodChanged: ((PickupMethod) -> Void)?

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
        updateUI(for: .homeDelivery) // 預設顯示「外送服務」
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        contentView.addSubview(mainStackView)
        
        setupSegmentedControl()
        setupHomeDeliveryView()
        setupInStoreView()
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    /// 設置 Segmented Control
    private func setupSegmentedControl() {
        mainStackView.addArrangedSubview(pickupMethodSegmentedControl)
    }
    
    /// 設置外送服務相關視圖
    private func setupHomeDeliveryView() {
        homeDeliveryStackView.addArrangedSubview(addressTextField)
        homeDeliveryStackView.addArrangedSubview(deliveryFeeLabel)
        mainStackView.addArrangedSubview(homeDeliveryStackView)
    }
    
    /// 設置到店自取相關視圖
    private func setupInStoreView() {
        storeHorizontalStackView.addArrangedSubview(storeTextField)
        storeHorizontalStackView.addArrangedSubview(selectStoreButton)
        inStoreStackView.addArrangedSubview(storeHorizontalStackView)
        inStoreStackView.addArrangedSubview(promptSelectLabel)
        mainStackView.addArrangedSubview(inStoreStackView)
    }
    
    /// 設置各種 UI 元件的動作
    private func setupActions() {
        pickupMethodSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        addressTextField.addTarget(self, action: #selector(addressTextFieldChanged), for: .editingChanged)
        selectStoreButton.addTarget(self, action: #selector(selectStoreButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Update UI Method

    /// 根據選取的取件方式更新 UI
    @objc private func segmentedControlValueChanged() {
        let selectedMethod: PickupMethod = pickupMethodSegmentedControl.selectedSegmentIndex == 0 ? .homeDelivery : .inStore
        //        CustomerDetailsManager.shared.updatePickupMethod(selectedMethod)            // 使用 CustomerDetailsManager 更新取件方式
        print("SegmentedControl 改變，新的取件方式為：\(selectedMethod.rawValue)") // 觀察取件方式
        updateUI(for: selectedMethod)
        onPickupMethodChanged?(selectedMethod)
        logPickupMethodUpdate()
    }
    
    /// 更新 UI 顯示不同的取件方式相關視圖
    ///
    /// 根據選取的取件方式，切換顯示相關視圖，並在需要時清空另一種取件方式的欄位。只有在對應欄位有值時，才會執行清空操作，以保留用戶輸入的有效資訊。
    private func updateUI(for method: PickupMethod) {
        switch method {
        case .homeDelivery:
            inStoreStackView.isHidden = true
            homeDeliveryStackView.isHidden = false
            
            /// 檢查`店家欄位`有值才清空`外送地址`
            clearTextFieldIfNeeded(addressTextField, basedOn: storeTextField)
            setTextFieldBorder(addressTextField, isEmpty: addressTextField.text?.isEmpty ?? true)
            
        case .inStore:
            inStoreStackView.isHidden = false
            homeDeliveryStackView.isHidden = true
            
            /// 檢查`外送地址欄位`有值才清空`店家名稱`
            clearTextFieldIfNeeded(storeTextField, basedOn: addressTextField)
            setTextFieldBorder(storeTextField, isEmpty: storeTextField.text?.isEmpty ?? true)
        }
    }
    
    /// 根據指定條件清空對應的 TextField 並通知變更
    ///
    /// - Parameters:
    ///   - textFieldToClear: 要清空的 TextField（例如地址或店家名稱）。
    ///   - conditionTextField: 作為清空依據的 TextField。如果此欄位有值，則清空 textFieldToClear。
    /// 當切換取件方式時，如果 `conditionTextField`（店家欄位或地址欄位）有值，則清空另一個取件方式相關的欄位。
    /// 同時，通知對應的變更以更新 `CustomerDetails` 和提交按鈕狀態。
    private func clearTextFieldIfNeeded(_ textFieldToClear: UITextField, basedOn conditionTextField: UITextField) {
        if conditionTextField.text?.isEmpty == false {
            textFieldToClear.text = ""              // 清空指定的欄位
            
            // 通知欄位清空後的變更，更新 CustomerDetails 和提交按鈕狀態
            if textFieldToClear == addressTextField {
                onAddressChange?("")
            } else if textFieldToClear == storeTextField {
                onStoreChange?("")
            }
        }
    }
    
    /// 確認 `CustomerDetailsManager` 中的取件方式是否已更新（觀察取件方式）
    private func logPickupMethodUpdate() {
        if let updatedCustomerDetails = CustomerDetailsManager.shared.getCustomerDetails() {
            print("CustomerDetailsManager 中的取件方式：\(updatedCustomerDetails.pickupMethod.rawValue)")
        } else {
            print("CustomerDetailsManager 尚未有顧客詳細資料")
        }
    }
    
    // MARK: - Action Handlers

    /// 點擊選擇店家按鈕的動作處理（會進入到「選取店家視圖控制器」）
    @objc private func selectStoreButtonTapped() {
        onStoreButtonTapped?()
        // 模擬選擇店家名稱為 "大安店"（由於還沒設置「選取店家視圖控制器」，因此先透過selectStoreButtonTapped模擬）
        let storeName = "大安店"
        storeTextField.text = storeName
        
        print("Store Button Tapped, selected store: \(storeName)")  // 增加觀察 storeTextField 被賦值
        
        // 更新顧客資料
        onStoreChange?(storeName)
        // 觸發 storeTextFieldChanged，確保資料同步
        storeTextFieldChanged()
        // 更新紅框狀態，因為已經選擇了店家，應移除紅框
        setTextFieldBorder(storeTextField, isEmpty: storeTextField.text?.isEmpty ?? true)
    }

    /// 店家名稱變更的處理，主要用於確保店家名稱在填寫或選擇後，資料與顯示保持一致。
    /// 雖然 storeTextField 是不可直接編輯的，但仍需要在 (selectStoreButtonTapped)選擇店家後透過此方法來進行同步資料的更新。
    /// 當 storeTextField 被更新後，此方法會觸發清空不相關的欄位（例如外送地址），以保持顧客資料的一致性。
    @objc private func storeTextFieldChanged() {
        let text = storeTextField.text ?? ""
        print("Store Text Field Changed: \(text)")  // 增加觀察 storeTextField 變更
        onStoreChange?(text)
        
        // 當選擇店家時，清空外送地址
        if !text.isEmpty {
            print("Store name is filled, clearing address text field.")  // 觀察清空外送地址
            clearTextFieldIfNeeded(addressTextField, basedOn: storeTextField)
        }
    }
    
    /// 當 `addressTextField` 變更時的處理，顯示紅框提示
    @objc private func addressTextFieldChanged() {
        let text = addressTextField.text ?? ""
        onAddressChange?(text)
        setTextFieldBorder(addressTextField, isEmpty: text.isEmpty)
        
        // 當填寫外送地址時，清空店家名稱
        if !text.isEmpty {
            clearTextFieldIfNeeded(storeTextField, basedOn: addressTextField)
        }
    }
    
    // MARK: - Helper Methods

    /// 設置 TextField 邊框顏色，提示是否為空
    private func setTextFieldBorder(_ textField: UITextField, isEmpty: Bool) {
        textField.layer.borderColor = isEmpty ? UIColor.red.cgColor : UIColor.clear.cgColor
        textField.layer.borderWidth = isEmpty ? 1.0 : 0.0
    }
    
    // MARK: - Factory Methods
    
    /// 建立一個 SegmentedControl
    private static func createSegmentedControl(items: [String]) -> UISegmentedControl {
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }
    
    /// 建立一個帶有`圖標`和`文字`的按鈕
    private static func createButton(title: String?, font: UIFont?, backgroundColor: UIColor, titleColor: UIColor, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        
        // 使用 UIButton.Configuration 來設置按鈕外觀
        var config = UIButton.Configuration.filled()
        config.title = title ?? ""
        config.baseForegroundColor = titleColor
        config.baseBackgroundColor = backgroundColor
        config.image = UIImage(systemName: iconName)
        config.imagePadding = 8
        config.imagePlacement = .leading
        
        // 只有當 title 不為空時才設置字體
        if let font = font, let title = title, !title.isEmpty {
            var titleAttr = AttributedString(title)
            titleAttr.font = font
            config.attributedTitle = titleAttr
        }
        
        button.configuration = config
        return button
    }
    
    /// 建立 Label
    private static func createLabel(withText text: String, font: UIFont, textColor: UIColor, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 建立 TextField
    private static func createTextField(withPlaceholder placeholder: String, isUserInteraction: Bool = true) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.isUserInteractionEnabled = isUserInteraction
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    /// 建立 StackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Configure Method
    
    /// 根據 CustomerDetails 設定初始畫面狀態
    /// - Parameter customerDetails: 包含顧客取件方式、店家名稱、送達地址等資訊的資料結構
    ///
    /// 此方法用於在初始化或重新配置畫面狀態時執行（例如切換訂單或重新加載畫面時）。
    /// 根據顧客的取件方式設定相關欄位，並清空不相關的欄位以保證 UI 和資料的一致性。
    func configure(with customerDetails: CustomerDetails) {
        if customerDetails.pickupMethod == .homeDelivery {
            // 如果顧客的取件方式是 Home Delivery，清空店家名稱欄位，並設定地址
            addressTextField.text = customerDetails.address ?? ""
            storeTextField.text = "" // 清空店家名稱
            setTextFieldBorder(addressTextField, isEmpty: customerDetails.address?.isEmpty ?? true)
            updateUI(for: .homeDelivery)
        } else {
            // 如果顧客的取件方式是 In-Store Pickup，清空外送地址欄位，並設定店家名稱
            storeTextField.text = customerDetails.storeName ?? ""
            addressTextField.text = "" // 清空外送地址
            updateUI(for: .inStore)
        }
    }
    
}
