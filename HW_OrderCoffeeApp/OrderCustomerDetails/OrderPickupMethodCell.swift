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
        CustomerDetailsManager.shared.updatePickupMethod(selectedMethod)            // 使用 CustomerDetailsManager 更新取件方式
        
        print("SegmentedControl 改變，新的取件方式為：\(selectedMethod.rawValue)") // 觀察取件方式
        
        updateUI(for: selectedMethod)   // 更新 UI
        logPickupMethodUpdate()         // 確認 `CustomerDetailsManager` 中的取件方式是否已更新
    }
    
    /// 更新 UI 顯示不同的取件方式相關視圖
    ///
    /// 根據選取的取件方式，切換顯示相關視圖，並在需要時清空另一種取件方式的欄位。只有在對應欄位有值時，才會執行清空操作，以保留用戶輸入的有效資訊。
    private func updateUI(for method: PickupMethod) {
        switch method {
        case .homeDelivery:
            inStoreStackView.isHidden = true
            homeDeliveryStackView.isHidden = false
            
            // 檢查店家欄位有值才清空外送地址
            clearTextFieldIfNeeded(addressTextField, basedOn: storeTextField)
            
            // 更新 addressTextField 的紅框狀態
            setTextFieldBorder(addressTextField, isEmpty: addressTextField.text?.isEmpty ?? true)
            
        case .inStore:
            inStoreStackView.isHidden = false
            homeDeliveryStackView.isHidden = true
            
            // 檢查外送地址欄位有值才清空店家名稱
            clearTextFieldIfNeeded(storeTextField, basedOn: addressTextField)

            // 更新 storeTextField 的紅框狀態
            setTextFieldBorder(storeTextField, isEmpty: storeTextField.text?.isEmpty ?? true)
        }
    }
    
    /// 根據條件清空指定的 TextField
    ///
    /// - Parameters:
    ///   - textFieldToClear: 要清空的 TextField。
    ///   - conditionTextField: 作為判斷依據的 TextField。如果這個欄位有值，則清空 `textFieldToClear`。
    private func clearTextFieldIfNeeded(_ textFieldToClear: UITextField, basedOn conditionTextField: UITextField) {
        if conditionTextField.text?.isEmpty == false {
            textFieldToClear.text = ""
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
        // 假設選擇店家後名稱被設為 "大安店"（由於還沒設置「選取店家視圖控制器」，因此先透過selectStoreButtonTapped模擬）
        let storeName = "大安店"
        storeTextField.text = storeName
        
        // 更新顧客資料
        onStoreChange?(storeName)
        // 更新紅框狀態，因為已經選擇了店家，應移除紅框
        setTextFieldBorder(storeTextField, isEmpty: storeTextField.text?.isEmpty ?? true)
    }

    /// 店家名稱變更的處理，顯示紅框提示（先留著）
    /// 目前的邏輯其實並不太需要，因為 storeTextField 是不可編輯的，主要的變更是來自於選擇店家按鈕的動作處理 (selectStoreButtonTapped)。
    /// 這樣的情況下，可以完全省略 storeTextFieldChanged，並集中在選擇店家按鈕被點擊之後的處理來更新視圖狀態，這樣會讓程式碼簡潔許多，同時減少不必要的事件監聽。
    @objc private func storeTextFieldChanged() {
        let text = storeTextField.text ?? ""
        onStoreChange?(text)
    }
    
    /// 外送地址變更的處理，顯示紅框提示
    @objc private func addressTextFieldChanged() {
        let text = addressTextField.text ?? ""
        onAddressChange?(text)
        setTextFieldBorder(addressTextField, isEmpty: text.isEmpty)
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
    /// 初始化顯示的視圖是「外送服務」，因此需要設置紅框檢查，而「到店自取」的部分則是交由 updateUI 去處理。
    func configure(with customerDetails: CustomerDetails) {
        if customerDetails.pickupMethod == .homeDelivery {
            pickupMethodSegmentedControl.selectedSegmentIndex = 0
            addressTextField.text = customerDetails.address
            setTextFieldBorder(addressTextField, isEmpty: customerDetails.address?.isEmpty ?? true)
            updateUI(for: .homeDelivery)
        } else {
            pickupMethodSegmentedControl.selectedSegmentIndex = 1
            storeTextField.text = customerDetails.storeName
            updateUI(for: .inStore)

        }
    }
    
}
