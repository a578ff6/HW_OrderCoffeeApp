//
//  ProfileTextFieldCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/24.
//

// MARK: - ProfileTextFieldCell 筆記
/**
 
 ## ProfileTextFieldCell 筆記
 
 `* What`
 
 - `ProfileTextFieldCell` 是一個通用的表單欄位 Cell，用於顯示可配置的文字輸入框，並支援監聽用戶輸入內容的變更。
 - 方便用 `ProfileTextFieldCell` 在 `EditProfileTableHandler` 中 `configureCell` 時透過 `configure` 直接建設不同類型的欄位。
 - 不需要一個欄位就設置一個 cell。

 `1.功能包括：`
 
 - 根據不同類型自動配置輸入框的行為和屬性（如鍵盤類型、佔位符文字）。
 - 提供 `onTextChanged` 閉包，將用戶的文字輸入回傳給外部控制器。
 
 ----------------------------
 
` * Why`
 
 `1.提升可重用性：`
 
 - 多數表單欄位需要顯示標籤和文字輸入框，該類別可用於多種情境，避免重複實現類似功能。
 - 使用一個通用的 `ProfileTextFieldCell` 替代多個專用 `Cell`，避免重複實現相似功能。
 
 `2.減少控制器責任：`
 
 - 控制器只需配置欄位類型與初始值，而無需直接管理輸入框屬性與事件。
 
 `3.即時回饋：`
 
 - 當用戶輸入變更時，透過閉包快速回傳內容更新，方便即時處理。
 
 ----------------------------

 `* How`
 
 `1. 配置文字輸入框屬性：configure 方法`
 
 ```swift
 
 /// 配置文字輸入框的屬性。
 /// - Parameters:
 ///   - fieldType: 欄位類型，用於設定文字輸入框的行為（如電話號碼、姓名等）。
 ///   - text: 預設文字，用於填充輸入框的初始值。
 func configure(fieldType: EditProfileTextField.FieldType, text: String?) {
     profileTextField.fieldType = fieldType
     profileTextField.text = text
 }
 ```
 
 - `參數設置的目的：`

 - `fieldType`: 確保輸入框的行為與欄位需求一致，例如姓名欄位需要自動大寫，而電話欄位需要數字鍵盤。
 - `text`: 用於設置初始值，例如顯示已保存的用戶資料，方便用戶編輯。
 
 - `使用場景：`

 - 在 `EditProfileTableHandler` 中的 `configureCell` 方法中根據 `fieldType` 和現有資料動態設置輸入框：

 ```swift
 cell.onTextChanged = { [weak self] updatedText in
     guard let self = self, let updatedText = updatedText else { return }
     guard var updatedModel = self.delegate?.getProfileEditModel() else { return }
     updatedModel.fullName = updatedText
     self.delegate?.updateProfileEditModel(updatedModel)
 }
 ```
 
 `2.監聽文字變更`
 
 - 使用 `addTarget` 綁定輸入框的 `editingChanged` 事件，觸發 `textFieldDidChange` 方法。
 - 當輸入變更時，透過 onTextChanged 閉包回傳更新：
 
 ```swift
 @objc private func textFieldDidChange() {
     onTextChanged?(profileTextField.text)
 }
```
 
 ----------------------------

 `* 補充`

` 1.EditProfileTextField 的靈活性：`

 - `EditProfileTextField` 通過 `FieldType` 支援多種欄位配置，避免重複代碼。
 - 如需新增欄位，只需擴展 `FieldType` 和對應的屬性配置。
 
 `2. 減少不必要的 Cell 類型：`

 - 無需為每個欄位類型創建單獨的 Cell，使用一個通用的 `ProfileTextFieldCell` 即可適配多種場景。
 
 `3. 關於 configure 方法`
 
 - `強調統一性`： configure 方法提供了統一的接口，確保所有文字輸入框的行為和顯示邏輯集中處理。
 - `避免重複代碼`： 外部只需設置 `fieldType` 和 `text`，內部自動完成行為配置，減少開發者的錯誤可能性。
 
 */


import UIKit

/// 表單中每一個欄位的 UITableViewCell，用於顯示文字輸入框的佈局與行為。
/// - `ProfileTextFieldCell` 支援多種輸入類型（如姓名、電話號碼等），並在用戶輸入變更時透過閉包回傳更新。
class ProfileTextFieldCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ProfileTextFieldCell"
    
    /// 用於監聽輸入框文字變更的回調閉包。
    var onTextChanged: ((String?) -> Void)?
    
    // MARK: - UI Elements
    
    /// 自訂的文字輸入框，根據不同欄位類型進行配置。
    private let profileTextField = EditProfileTextField()
    
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
    
    /// 設置文字輸入框的佈局，
     private func setupLayout() {
         contentView.addSubview(profileTextField)
         
         NSLayoutConstraint.activate([
             profileTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
             profileTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
             profileTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
             profileTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
         ])
     }
    
    /// 配置 Cell 的外觀屬性
    private func setupAppearance() {
        separatorInset = .zero // 確保分隔線完全禁用
        backgroundColor = .clear // 確保背景色與 TableView 一致
        selectionStyle = .none // 禁用點擊高亮效果
    }
    
    // MARK: - Actions
    
    /// 設置按鈕的行為
    private func setupActions() {
        profileTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    /// 當文字輸入框內容變更時觸發，透過 `onTextChanged` 閉包回傳文字更新。
    @objc private func textFieldDidChange() {
        onTextChanged?(profileTextField.text)
    }
    
    // MARK: - Configuration Method
    
    /// 配置文字輸入框的屬性。
    /// - Parameters:
    ///   - fieldType: 欄位類型，用於設定文字輸入框的行為（如電話號碼、姓名等）。
    ///   - text: 預設文字，用於填充輸入框的初始值。
    func configure(fieldType: EditProfileTextField.FieldType, text: String?) {
        profileTextField.fieldType = fieldType
        profileTextField.text = text
    }
    
}

