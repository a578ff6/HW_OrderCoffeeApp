//
//  EditProfileTextField.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/4.
//


// MARK: - EditProfileTextField 筆記
/**
 
 ## EditProfileTextField 筆記
 
 `* What`
 
 - `EditProfileTextField` 是一個自訂的 `UITextField`，根據欄位類型（`FieldType`）自動調整其行為和屬性。該類型主要用於個人資料編輯頁面。

 - `支援的欄位類型：`
 
 .phoneNumber：電話號碼輸入框。
 .name：用戶姓名輸入框，支援首字母大寫。
 .address：用戶地址輸入框，配置為全地址模式。
 .none：無特殊行為（預設值）。
 
 ---------------------------
 
 `* Why`
 
 `1.提高可重用性：`
 
 - 將輸入框的配置邏輯集中於一個類別中，避免多處重複實現。
 
 `2.減少控制器的負擔：`
 
 - 控制器無需手動設定每個輸入框的屬性，簡化初始化過程。
 
 `3.提升用戶體驗：`
 
 - 自動配置佔位符與鍵盤類型，提升輸入的直覺性與準確性。
 
 `4.提供即時反饋：`
 
 - 透過 `updateTextFieldAppearance` 方法，針對特定欄位進行視覺化提示，改善表單填寫體驗。
 
 ---------------------------

 `* How`
 
 `1.基於 FieldType 自動配置行為：`

 - 在 `fieldType` 設定後，觸發 `configureTextField` 方法，自動調整屬性。
 - 例如，為電話號碼欄位設置 .`phonePad` 鍵盤類型，為姓名欄位啟用自動大寫。
 
 `2.即時更新外觀：`

 - 當用戶輸入文字時，觸發 `textFieldDidChange` 方法，根據內容狀態更新邊框顏色。
 - 例如，當姓名欄位為空時，邊框顯示為紅色以提示用戶填寫。
 
 `3.靈活擴展：`

 - 新增欄位類型時，只需在 `FieldType` 中定義並擴充 `configureTextField` 方法，無需改動其他邏輯。
 */


import UIKit

/// 自訂的文字輸入框，支援根據不同欄位類型自動配置屬性與行為。
/// - `EditProfileTextField` 提供簡化的初始化和即時外觀更新邏輯，適用於個人資料編輯場景。
class EditProfileTextField: UITextField {
    
    // MARK: - Enum for Field Types
    
    /// 定義文字輸入框的欄位類型，用於根據類型配置輸入框的行為與屬性。
    enum FieldType {
        case phoneNumber
        case name
        case address
        case none
    }
    
    // MARK: - Properties
    
    /// 文字輸入框的欄位類型。設定後會根據類型重新配置輸入框屬性。
    var fieldType: FieldType = .none {
        didSet {
            configureTextField()
        }
    }
    
    // MARK: - Initializer
    
    /// 初始化方法，配置基本屬性。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextFieldProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    /// 設置文字輸入框的基本屬性。
    /// - 包括關閉自動轉換約束、設定邊框樣式以及綁定輸入變更的目標動作。
    private func setupTextFieldProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        borderStyle = .roundedRect
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    /// 根據欄位類型配置文字輸入框的屬性。
    /// - 例如：鍵盤類型、佔位符文字、自動大寫模式等。
    private func configureTextField() {
        switch fieldType {
        case .phoneNumber:
            self.keyboardType = .phonePad
            self.placeholder = "Enter your phone number"
        case .name:
            self.keyboardType = .default
            self.textContentType = .name
            self.autocapitalizationType = .words
            self.placeholder = "Enter your full name"
        case .address:
            self.keyboardType = .default
            self.textContentType = .fullStreetAddress
            self.placeholder = "Enter your address"
        case .none:
            self.keyboardType = .default
            self.textContentType = .none
        }
    }
    
    // MARK: - Actions
    
    /// 當文字輸入框內容變更時的回調方法。
    /// - 此處負責即時更新文字輸入框的外觀，例如根據內容是否有效變更邊框顏色。
    @objc private func textFieldDidChange() {
        updateTextFieldAppearance()
    }
    
    // MARK: - Appearance Updates
    
    /// 更新文字輸入框的外觀。
    /// - 當 `fieldType` 為 `.name` 且內容為空時，顯示紅色邊框提示用戶填寫。
    /// - 否則恢復為清除的邊框樣式。
    private func updateTextFieldAppearance() {
        if fieldType == .name, text?.isEmpty == true {
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 1.0
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0.0
        }
    }
    
}
