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
        - 提供使用者選擇取件方式（「到店自取」或「外送服務」）的界面，並根據選擇顯示相關的 UI 元件，包括店家選擇和地址輸入的部分。

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
            - onStoreChange：在選擇店家後設置店家名稱時觸發的回調。
 
        3. 核心邏輯

            * updateUI(for:) 方法
                - 根據選擇的取件方式更新 UI。重要的是，不再強制清空不相應的欄位，而是確保「店家名稱」和「地址」不會同時存在。這樣的改動旨在保護使用者資料，避免不必要的清空操作。
 
            * 切換取件方式後的處理
                - 只在確定對應欄位已經有資料的情況下，才清空不相應的欄位，從而避免用戶輸入的資料在切換時丟失。
                - 切換取件方式後，會透過回調通知外部來更新 CustomerDetails，並確保提交按鈕的狀態正確反映當前表單的完整性。
 
        4. 設計考量

            * 保持資料一致性
                - 保持 storeName 和 address 兩者不會同時存在，這樣可以確保資料符合當前選擇的取件方式。
 
            * 簡化邏輯
                - 由於 storeTextField 無法直接編輯，因此不再需要監聽 storeTextFieldChanged。所有變更均由 selectStoreButtonTapped 處理。
 
            * 回調的使用
                - 每次資料變更時（如地址或店家選擇），都會透過回調通知外部，以確保 CustomerDetails 的同步更新和提交按鈕狀態的即時更新。

        5. 未來改進
 
            * 店家選擇視圖的實現
                - 目前的店家選擇為模擬，未來需要實際的店家選擇視圖來更精確地設置店家名稱。

            * 資料驗證強化
                - 可考慮增加對地址格式的驗證，以提高資料輸入的正確性和一致性。
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


// MARK: - 在選擇店家後 Submit 按鈕未啟用

/*
 1. 問題描述

    - 當使用者選擇「到店自取」並選擇店家（例如「大安店」）後，storeTextField 的內容已更新為 "大安店"，但 onStoreChange 回調未被適當執行，導致 CustomerDetailsManager 中的店家名稱未同步更新。
    - 由於 CustomerDetails 中的 storeName 未被更新，表單驗證未通過，導致提交按鈕保持禁用狀態。

 2. 解決方式

    - 在 selectStoreButtonTapped 方法中，必須確保調用 onStoreChange 回調，這樣可以將最新選擇的店家名稱通知到外部（例如 ViewController），以便 CustomerDetailsManager 進行更新。
    - 通過更新 CustomerDetailsManager 中的資料，可以正確觸發 customerDetailsDidChange()，從而更新提交按鈕的狀態
 
 3. 確保顧客資料正確同步

    - 若未調用 onStoreChange，則 CustomerDetailsManager 中的顧客資料無法正確反映店家選擇，這會導致提交按鈕保持禁用狀態，因為表單驗證認為使用者尚未完成必填項目（店家名稱）。
    - 確保每次選擇店家後，回調都能觸發資料更新，這樣在切換取件方式時，資料也能保持一致，並且提交按鈕狀態能即時更新。
 */


// MARK: - 如何在切換取件方式後有效管理各個欄位的狀態（發生的問題）

/*
 1. 問題描述
 
    - 當使用者在取件方式之間切換（例如從「Home Delivery」切換到「In-Store Pickup」）時，如果未適當清空先前取件方式的欄位內容，可能會導致提交的 CustomerDetails 中包含不一致的資料，例如同時存在地址和店家名稱。

 2. 解決方案
 
    * 資料排他性管理：
        - CustomerDetailsManager 現在負責確保 storeName 和 address 兩者不會同時存在，這樣就不再需要在 OrderPickupMethodCell 中強制清空欄位。

    * 表單驗證與提交按鈕狀態：
        - 當切換取件方式時，保留原先的輸入內容，但 UI 只顯示當前選擇方式下的相應欄位。
        - 提交按鈕的狀態會根據當前取件方式下的資料完整性進行即時更新，確保所有必填欄位已填寫才能提交。
 
 3. 簡化後的行為

    * 保留但不顯示：
        - 當取件方式切換時，保留之前填寫的資料，但不顯示在 UI 上，除非使用者切換回來，以確保用戶體驗不受影響。

    * 回調通知同步：
        - 使用回調（如 onPickupMethodChanged, onAddressChange, onStoreChange）來通知資料變更，確保 CustomerDetails 中的資料與 UI 保持一致，並更新提交按鈕的狀態。
 */


// MARK: - 如何在切換取件方式後有效管理各個欄位的狀態（重點筆記：取件方式切換與資料同步更新）

/*
 
 ## 重點筆記：簡化的取件方式切換與資料同步邏輯

 * 目標：
 
    - 確保在任意時間點，storeName 和 address 兩者不會同時存在，這樣可以確保取件方式間的排他性。
    - 提交按鈕狀態能夠即時更新，反映表單的完整性，防止提交不完整的資料。
    - 在切換取件方式後，根據當前取件方式顯示相應欄位，而非強制清空所有欄位，確保用戶輸入的資料盡量保留。
 
 * 調整的原因：
 
    - 隨著 CustomerDetailsManager 負責更詳細的資料處理，包括確保取件方式的排他性，OrderPickupMethodCell 不再需要過於複雜的邏輯來清空欄位。
    - 取而代之的是，資料處理更加集中於 CustomerDetailsManager，只需要在切換取件方式時進行必要的同步操作。
 
 * 核心邏輯調整：
 
    1. 資料排他性管理：

        - 排他性確保： CustomerDetailsManager 確保在填寫店家名稱時會清空地址，反之亦然。這樣在 OrderPickupMethodCell 中不需要再手動清空不相關的欄位。
        - UI 顯示更新： OrderPickupMethodCell 根據選擇的取件方式，隱藏或顯示相應的 UI 元件，但不再強制清空欄位的值。
 
    2.提交按鈕狀態更新：
 
        - 即時同步： 通過回調 (onPickupMethodChanged, onAddressChange, onStoreChange)，每當取件方式或欄位內容發生變更時，更新 CustomerDetails，並進行資料驗證，確保提交按鈕狀態與資料的完整性同步。
 
    3. 不再需要 storeTextFieldChanged 的監聽：
 
        - storeTextField 是不可編輯的，所有變更都來自於按下 selectStoreButton 的操作。
        - 因此，通過 selectStoreButtonTapped 已經能夠完成對 storeTextField 和資料的更新，storeTextFieldChanged 的監聽已經冗餘，不再需要設置監聽器。
 
 * 總結
 
    - OrderPickupMethodCell 現在的主要作用是顯示取件方式並提供基本的選擇功能，而資料管理和欄位排他性邏輯則由 CustomerDetailsManager 負責。
    - 這樣的分工使得 OrderPickupMethodCell 的實現更加簡單，提升了代碼的可維護性和整體結構的清晰度。
    - 在切換取件方式後，只隱藏不相應的 UI 元件，但不清空已輸入的資料，確保使用者的資料不會因誤操作而丟失。
    - 提交按鈕的狀態會根據資料的完整性進行更新，確保只有在所有必填欄位填寫完整時，才能進行提交操作。
 */


// MARK: - setupActions 與欄位變更處理

/*
 ## 筆記：setupActions 與欄位變更處理

 &. setupAction 中的必要設置：
 
    1.pickupMethodSegmentedControl：

        用途：監聽取件方式的變更。
        行為邏輯：當使用者切換取件方式時，觸發 segmentedControlValueChanged，用於更新 UI 和同步資料，確保顯示狀態與資料一致。
 
    2.addressTextField：

        用途：監聽外送地址的輸入變更。
        行為邏輯：當使用者輸入或修改地址時，觸發 addressTextFieldChanged，即時更新資料並確保資料的一致性（例如，清空店家名稱以確保排他性）。

    3.selectStoreButton：
 
        用途：監聽選擇店家的按鈕點擊事件。
        行為邏輯：當使用者點擊「選擇店家」按鈕時，觸發 selectStoreButtonTapped，進入選擇店家視圖，並在選擇後更新 storeTextField 的顯示與資料（透過 onStoreChange 回調）。
 
 &. storeTextField 不需要設置監聽
 
    * 原因：
        - 不可編輯欄位：storeTextField 是不可編輯的，因此使用者無法直接對此欄位進行輸入或更改。
 
    * 變更處理方式：
        - 所有涉及店家名稱的變更都由 selectStoreButtonTapped 來處理，包括手動更新 storeTextField 的顯示並透過回調通知外部 (onStoreChange)。
        - 因此，storeTextFieldChanged 是不必要的，因為所有的店家選取邏輯都是透過按鈕操作觸發的，沒有用戶直接修改的情況。
 
 &. 核心邏輯
 
    * 資料一致性處理：
        - 當「外送地址欄位」被填寫時，應確保清空「店家欄位」。
        - 當「店家名稱」被選擇時，應清空「外送地址」。
        - 這些排他性邏輯由 CustomerDetailsManager 集中處理，確保資料在變更後保持一致。
 
    * 使用回調進行資料更新：
        - 即時更新：每當 addressTextFieldChanged 或 selectStoreButtonTapped 觸發變更時，使用回調（onAddressChange 和 onStoreChange）來通知資料的更新。
        - 同步顧客資料：確保 CustomerDetails 能夠及時反映最新的資料。
 
    * 更新提交按鈕狀態：
        - 每次資料變更後，會即時檢查資料的完整性，並更新提交按鈕的啟用/禁用狀態。
        - 這樣可以確保只有在必填資料完整時，提交按鈕才被啟用，避免不完整資料提交訂單的情況。
 
 &. 調整後的關鍵重點
 
    * 資料集中管理：
        - 排他性邏輯、欄位清空等行為均由 CustomerDetailsManager 集中處理，使得 OrderPickupMethodCell 的設計更加簡化，僅負責顯示和與用戶的互動。
 
    * 不需要監聽 storeTextField：
        - 因為 storeTextField 是不可編輯的，其變更僅來自按鈕操作，且資料更新都集中處理於按鈕回調中，因此 storeTextFieldChanged 成為冗餘的部分，不再需要。
 */


// MARK: - addressTextFieldChanged、selectStoreButtonTapped 調整後的邏輯

/*
 ## 筆記：  addressTextFieldChanged、selectStoreButtonTapped 調整後的邏輯

 1. addressTextFieldChanged
 
    * 用途：
        - 當使用者在「外送地址」欄位輸入或修改地址時，會透過 addressTextFieldChanged 觸發回調 (onAddressChange) 來即時更新顧客的 CustomerDetails 資料。
 
    * 行為邏輯：
        - 每次地址變更後，使用回調來通知外部邏輯更新資料。
        - 排他性邏輯已由 CustomerDetailsManager 處理，因此 OrderPickupMethodCell 不再直接清空店家名稱。
 
 
 2. selectStoreButtonTapped
 
    * 用途：
        - 點擊「選擇店家」按鈕時，會觸發 selectStoreButtonTapped，並導向店家選擇界面。
 
    * 行為邏輯：
        - 當店家選擇完成後，會手動賦值給 storeTextField，並透過回調 (onStoreChange) 更新 CustomerDetails 的店家名稱。
        - 店家名稱與地址的排他性：不再在 OrderPickupMethodCell 中直接清空外送地址，而是透過 CustomerDetailsManager 來確保資料的唯一性。

 3. 不再需要 storeTextFieldChanged

    * 原因：
        - 不可編輯的欄位：storeTextField 是不可編輯的欄位，因此用戶無法直接對此欄位進行更改。
        - 資料變更透過按鈕觸發：店家名稱的更改是透過點擊「選擇店家」按鈕 (selectStoreButtonTapped) 來完成的，並直接透過回調 (onStoreChange) 更新 CustomerDetails。因此，不需要額外的 storeTextFieldChanged 方法來監聽輸入變更。
        - 集中資料管理：所有與欄位相關的排他性邏輯均已由 CustomerDetailsManager 集中處理，使得 storeTextFieldChanged 的作用變得重複且不必要。

 ## 調整後的關鍵重點
 
    * 資料同步：
        - 每次欄位變更後，確保相關資料透過回調同步更新至 CustomerDetailsManager，並由其負責進行排他性檢查。
 
    * 更簡化的邏輯：
        - 由於欄位排他性的邏輯集中於 CustomerDetailsManager，OrderPickupMethodCell 的行為主要是觸發回調以通知外部更新，而不再需要直接管理清空的邏輯。
 
 ## 調整總結
 
    - 這些改動使得資料更新與邏輯集中於 CustomerDetailsManager，使得 OrderPickupMethodCell 更加關注於 UI 的顯示與用戶交互，從而簡化了欄位變更的處理流程，提升了代碼的可讀性與可維護性。
    - 此外，storeTextFieldChanged 不再需要，是因為店家名稱的選取不涉及用戶直接輸入，而是由按鈕操作來觸發的，這樣更加符合欄位的交互設計。
 */


// MARK: - configure(with:) 和 segmentedControlValueChanged （重要）

/*
 * 這裡是關於 OrderPickupMethodCell 中的兩個核心方法：configure(with:) 和 segmentedControlValueChanged 的筆記。

 
 &. configure(with:) 方法：

    * 用途：
        - 用於初始化和重新配置 OrderPickupMethodCell 的顯示狀態，通常在首次載入畫面或重新載入資料時使用。
 
    * 行為邏輯：
        - 根據 CustomerDetails 中的資料設置取件方式以及相關欄位的內容。
        - 重點在於根據資料狀態顯示正確的欄位，而不是無條件清空所有欄位。

 &. segmentedControlValueChanged 方法：

    * 用途：
        - 當使用者在 segmentedControl 中切換取件方式時被呼叫，用於即時更新畫面。
 
    * 行為邏輯：
        - 根據用戶選擇的取件方式顯示相應的 UI 區塊（例如：顯示「外送服務」相關欄位，隱藏「到店取件」相關欄位）。
        - 不會強制清空另一個取件方式的欄位，而是依賴於 CustomerDetailsManager 來確保 storeName 和 address 之間的排他性。
 
 &. 總結：
    - configure(with:) 是為了初始化或重新配置 OrderPickupMethodCell，以顯示基於 CustomerDetails 的正確資料。
    - segmentedControlValueChanged 則是響應用戶的互動，即時更新 UI，但清空欄位的邏輯已被簡化，因為新的邏輯重點在於「storeName 和 address 之間不應同時存在」。
 */


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
    /// 點擊選擇店家按鈕時的回調（進入「店家選擇視圖」）
    var onStoreButtonTapped: (() -> Void)?
    /// 店家選擇完成後更新店家名稱的回調
    var onStoreChange: ((String) -> Void)?
    /// 取件方式變更時的回調
    var onPickupMethodChanged: ((PickupMethod) -> Void)?

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
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
    
    // MARK: - Helper Methods

    /// 設置 TextField 的邊框顏色來提示是否為必填項
    ///
    /// - Parameter textField: 需要進行驗證的 UITextField
    ///
    /// 此方法根據 TextField 的當前狀態（是否有值）來設置邊框的顏色和寬度。
    /// 當 TextField 為空時，邊框顯示紅色，提示使用者該欄位為必填項；當 TextField 有填寫時，邊框顏色設為透明以取消提示。
    private func setTextFieldBorder(_ textField: UITextField) {
        let isFilled = !(textField.text?.isEmpty ?? true)
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = isFilled ? UIColor.clear.cgColor : UIColor.red.cgColor
    }
    
    // MARK: - Update UI Method

    /// 根據選取的取件方式更新 UI
    @objc private func segmentedControlValueChanged() {
        let selectedMethod: PickupMethod = pickupMethodSegmentedControl.selectedSegmentIndex == 0 ? .homeDelivery : .inStore
        onPickupMethodChanged?(selectedMethod)
        updateUI(for: selectedMethod)
    }
    
    /// 更新 UI 顯示不同的取件方式相關視圖
    private func updateUI(for method: PickupMethod) {
        switch method {
        case .homeDelivery:
            inStoreStackView.isHidden = true
            homeDeliveryStackView.isHidden = false
            setTextFieldBorder(addressTextField)
            
        case .inStore:
            inStoreStackView.isHidden = false
            homeDeliveryStackView.isHidden = true
            setTextFieldBorder(storeTextField)
        }
    }
    
    // MARK: - Action Handlers

    /// 點擊選擇店家按鈕的動作處理（會進入到「選取店家視圖控制器」）
    @objc private func selectStoreButtonTapped() {
        onStoreButtonTapped?()
        // 模擬選擇店家名稱為 "大安店"（由於還沒設置「選取店家視圖控制器」，因此先透過selectStoreButtonTapped模擬）
        let storeName = "大安店"
        storeTextField.text = storeName
        print("Store Button Tapped, selected store: \(storeName)")
        
        onStoreChange?(storeName)               // 更新顧客資料，確保資料變更能通知到外部
        setTextFieldBorder(storeTextField)
    }
    
    /// 當地址變更時的處理
    @objc private func addressTextFieldChanged() {
        let text = addressTextField.text ?? ""
        print("Address text changed to: \(text)")
        onAddressChange?(text)
        setTextFieldBorder(addressTextField)
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
    
    /// 設定初始的取件方式
    /// - Parameter pickupMethod: 取件方式（外送或到店取件）
    func configure(with customerDetails: CustomerDetails) {
        pickupMethodSegmentedControl.selectedSegmentIndex = (customerDetails.pickupMethod == .homeDelivery) ? 0 : 1
        updateUI(for: customerDetails.pickupMethod)
        
        // 根據顧客資料來初始化地址和店家名稱
        addressTextField.text = customerDetails.address ?? ""
        storeTextField.text = customerDetails.storeName ?? ""
    }
}
