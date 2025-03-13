//
//  GenderSelectionCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/25.
//


/**
 ## GenderSelectionCell
    - 在 App 中，讓使用者在註冊後進行性別選擇。
    - 性別選擇是可選的，因此在註冊過程中並未要求用戶填寫此資訊。
    - 為了解決性別選擇欄位在顯示時可能出現的問題，使用了 GenderSelectionCell 來專門處理性別選擇的邏輯。

 ## GenderSelectionCell 的設計
    - GenderSelectionCell` 是自定義的 UITableViewCell，其核心功能是透過 UISegmentedControl 來處理性別選擇。
    - 這個 cell 被用於編輯個人資料的頁面中，並且可以根據現有的使用者性別資訊來設定初始選項。

 ## 想法

 1. 性別選項的顯示：
    - UISegmentedControl 包含三個選項："Male"、"Female" 和 "Other"。
    - 當使用者在註冊時沒有選擇性別（即 gender 值為 nil 或空字串），預設選擇 "Other"，以確保在編輯頁面中有一個選項被選中，避免性別選項處於未選中狀態。
    - 「空字串」的出現在於使用者在首次進入到 EditProfileViewController 時，沒有選擇性別直接點擊save保存，就會呈現「空字串」。

 2. 性別變更的回調：
    - 當使用者在 UISegmentedControl 上進行選擇時，會觸發 genderChanged 方法，將新的性別值透過 onGenderChanged 回調傳遞出去，以供外部控制器（ EditProfileViewController）更新使用者資料。
 
 ## 使用方式
    - 在外部控制器中（如 EditProfileViewController），當需要展示和編輯性別資訊時，可以使用 GenderSelectionCell。
    - 透過 configure(withGender:) 方法，根據使用者的現有性別資訊來設定 UISegmentedControl 的初始選項。`如果性別為 nil 或空字串，則會預設選擇 "Other"。`
 */


// MARK: - GenderSelectionCell 筆記
/**
 
 ## GenderSelectionCell 筆記
 
 `* What`
 
 - `GenderSelectionCell` 是一個專用於表單中性別選擇的通用 Cell。
 - 使用 `EditProfileSegmentedControl` 來實現性別選擇邏輯。
 - 支援三個選項：Male、Female、Other。
 - 當用戶改變選項時，透過閉包 onGenderChanged 即時回傳選擇的結果。
 
 --------------------
 
 `* Why`
 
 `1.高可重用性：`

 - `EditProfileSegmentedControl` 提供了通用邏輯，無需重複開發性別選擇功能。
 - `Cell` 可以用於多種需要性別選擇的場景。
 
 `2.降低耦合性：`

 - 外部控制器只需接收性別選擇結果，無需直接管理選擇邏輯與視圖細節。
 - 內部封裝了佈局與行為，簡化整體邏輯。
 
 `3.即時回饋：`

 - 當用戶選擇性別時，結果即時回傳，方便更新界面或保存數據。
 
 `4.適配多種情境：`

 - `configure` 方法支援動態設置初始性別值，靈活應對不同場景。
 
 --------------------

` * How`
 
 `1.初始化與佈局：`

 - 使用 `EditProfileSegmentedControl` 初始化選項列表。
 - 配置佈局，使控制元件水平置中，並與左右邊緣保持間距。
 
 `2.配置性別值：`

 - `configure(withGender:) `方法接收初始性別值並設置選擇狀態。
 - 若性別值不在選項列表中，則選擇設為未選中狀態。
 
 `3.事件監聽：`

 - 綁定 `valueChanged` 事件，當用戶改變選項時，觸發 `genderChanged` 方法。
 - 使用閉包回傳當前選中的性別字串。

 */


// MARK: - 關於性別（`gender`）未選擇的處理方式筆記
/**
 
 ## 關於性別（`gender`）未選擇的處理方式筆記

 `* What`

 `- 當性別（gender）未選擇時的處理邏輯：`
 
 - 預設值為 `"Other"`，避免數據層出現空值。
 - 處理分為兩個層級：

 `1. 資料層級（ProfileEditModel、EditUserProfileManager）：`

 - 確保性別屬性始終有值，並且在存取數據時進行容錯處理。

 `2. UI 層級（GenderSelectionCell、EditProfileSegmentedControl）：`
 
 - 在 UI 組件中對性別選項提供預設顯示，並支援未選擇狀態。

 --------------------

`* Why`

 `1. 資料一致性：`

 - 性別為必填項，透過資料層提供預設值，確保數據的完整性，避免因空值導致的錯誤。

 `2. 使用者體驗：`
 
 - UI 層級允許用戶看到清晰的預設選項（如 `"Other"`），或選擇未選狀態，防止操作上的疑惑。

 `3. 容錯機制：`

 - 避免因性別選項未選中或數據缺失引發的問題，減少資料解析或傳遞過程中的潛在錯誤。

 --------------------

 `* How(重要) `

 `1. 資料層級的處理`

 - `ProfileEditModel`：
   
 - 預設性別為 `"Other"`，無論初始化還是從後端獲取資料，都會補全該屬性。
 - 若性別選項未提供，初始化時會自動設置為 `"Other"`。

      ```swift
      struct ProfileEditModel: Codable {
          var gender: String // 預設值為 "Other"
          
          init(gender: String = "Other") {
              self.gender = gender
          }
      }
      ```

 
 - `EditUserProfileManager`：
     
 - 在存取或更新數據時，若性別為空字串（`""`），強制轉換為預設值 `"Other"`。

      ```swift
      let userData: [String: Any] = [
          "gender": profile.gender.isEmpty ? "Other" : profile.gender // 確保性別有值
      ]
      ```

 `2. UI 層級的處理`

 - `GenderSelectionCell`：
 
 - 透過 `configure(withGender:)` 方法設置 UI 初始值。
 - 若性別選項與預設列表不匹配，則將選項設置為未選擇狀態。

      ```swift
      func configure(withGender gender: String) {
          genderControl.setSelectedOption(gender)
      }
      ```

 - `EditProfileSegmentedControl`：

 - 支援動態設置與獲取當前選項。
 - 若`未選中`任何選項，則`返回空字串`，交由資料層`處理預設值`。（重要）

      ```swift
      func getSelectedOption() -> String {
          return titleForSegment(at: selectedSegmentIndex) ?? ""
      }
      ```

 --------------------

 `* 使用範例`

 `1. 資料初始化：`
 
    ```swift
    let profile = ProfileEditModel(fullName: "John Doe", gender: "") // 自動補全為 "Other"
    ```

` 2. 後端數據處理：`
 
    ```swift
    func updateProfileData(_ profile: ProfileEditModel) {
        let genderToSave = profile.gender.isEmpty ? "Other" : profile.gender
        // 保存到後端
    }
    ```

 `3. UI 與資料同步：`
   
 - 在 `GenderSelectionCell` 中配置初始值，並監聽用戶選擇。
 
    ```swift
    cell.configure(withGender: profile.gender)
    cell.onGenderChanged = { newGender in
        profile.gender = newGender
    }
    ```

 --------------------

 `* 結論`

 - 性別未選擇的處理同時在資料層級與 UI 層級實現容錯，確保一致性與可用性。

 - `資料層`：
 
   - 提供預設值 `"Other"`，確保數據完整性。
   - 存取時進行字串校驗，補全缺失值。

 - `UI 層`：
 
   - 動態配置選項，支援未選狀態。
   - 即時同步用戶選擇，保持視圖與資料一致。
 */



import UIKit

/// 表單中用於性別選擇的 UITableViewCell。
/// - 提供選擇 `Male`、`Female` 或 `Other` 的功能，並支援即時回傳用戶選擇的性別。
/// - 使用通用元件 `EditProfileSegmentedControl` 來實現選擇邏輯與視覺效果。
class GenderSelectionCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "GenderSelectionCell"
    
    /// 當用戶改變選項時的回調閉包。
    /// - 參數：用戶當前選擇的性別字串。
    var onGenderChanged: ((String) -> Void)?
    
    // MARK: - UI Elements
    
    /// 使用 `EditProfileSegmentedControl` 實現性別選擇功能。
    /// - 提供 `Male`、`Female`、`Other` 三個選項。
    private let genderControl = EditProfileSegmentedControl(items: ["Male", "Female", "Other"])
    
    // MARK: - Initializer
    
    /// 初始化方法，設置 Cell 的佈局與行為。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupActions()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    
    /// 設置 `EditProfileSegmentedControl` 的佈局。
    private func setupLayout() {
        contentView.addSubview(genderControl)
        
        NSLayoutConstraint.activate([
            genderControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genderControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            genderControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            genderControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    /// 配置 Cell 的外觀屬性
    private func setupAppearance() {
        separatorInset = .zero // 確保分隔線完全禁用
        backgroundColor = .clear // 確保背景色與 TableView 一致
        selectionStyle = .none // 禁用點擊高亮效果
    }
    
    // MARK: - Actions Setup
    
    /// 設置 `genderControl` 的事件監聽器。
    /// - 當選擇變更時，觸發 `genderChanged` 方法。
    private func setupActions() {
        genderControl.addTarget(self, action: #selector(genderChanged), for: .valueChanged)
    }
    
    /// 當用戶變更性別選擇時觸發。
    /// - 將當前選中的性別字串回傳給外部。
    @objc private func genderChanged() {
        let selectedGender = genderControl.getSelectedOption()
        onGenderChanged?(selectedGender)
    }
    
    // MARK: - Configuration Method
    
    /// 配置性別選擇的初始值。
    /// - Parameter gender: 要設置的初始性別值。
    ///   - 若參數值與選項列表匹配，則自動選中該選項。
    ///   - 若不匹配，則不選擇任何選項。
    func configure(withGender gender: String) {
        genderControl.setSelectedOption(gender)
    }
    
}
