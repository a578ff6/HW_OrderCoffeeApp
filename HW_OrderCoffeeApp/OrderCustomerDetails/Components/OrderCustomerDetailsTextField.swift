//
//  OrderCustomerDetailsTextField.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/2.
//

// MARK: - OrderCustomerDetailsTextField 筆記

/**
 
 ## OrderCustomerDetailsTextField 筆記

` * What`
 
 - `OrderCustomerDetailsTextField` 是一個自訂的 `UITextField`，用於統一管理訂單客戶資訊輸入欄位的樣式與行為。

 - `功能：`
 
   1. 提供自定義的 Placeholder（提示文字）。
   2. 支援設置鍵盤類型（如數字鍵盤、文字鍵盤）。
   3. 支援設置 `textContentType`，加強系統自動填充與建議功能（如姓名、電話）。
   4. 當輸入內容為空時，自動顯示紅色邊框作為錯誤提示；內容有效時移除紅框。
   5. 預設支援 AutoLayout，無需手動配置尺寸。

 ----------------

 `* Why`
 
 `1. 統一樣式與行為：`
 
    - 減少重複代碼，讓專案中所有輸入欄位維持一致的設計。
    - 適合多處重複使用，例如姓名、電話、地址等欄位。

 `2. 提升用戶體驗：`
 
    - 顯示紅色邊框時能直觀提醒使用者未輸入必填內容。
    - 利用 `textContentType`，系統可以自動建議或填充資料（如電話號碼、姓名），加速輸入流程。

 `3. 提高開發效率與可維護性：`
 
    - 集中管理輸入框行為，當需要修改樣式或行為時，只需調整此類別，避免重複修改多處代碼。

 ----------------

 `* How`
 
 `1. 初始化 TextField`
 
 初始化方法讓開發者可以設定：
 - `placeholder`：提示文字。
 - `keyboardType`：指定鍵盤類型（預設為 `.default`）。
 - `textContentType`：提升系統整合性，支援自動填充（如 `.name`、`.telephoneNumber`）。

 範例：
 
 ```swift
 let nameTextField = OrderCustomerDetailsTextField(
     placeholder: "Enter your name",
     keyboardType: .default,
     textContentType: .name
 )
 ```

 ---

 `2. 樣式與屬性設置`
 
 `setupTextField` 方法內：
 - 設置圓角邊框樣式（`borderStyle`）。
 - 設定 `keyboardType` 和 `textContentType`。
 - 預設隱藏邊框顏色（透明），以便僅在錯誤時顯示紅框。

 ---

 `3. 驗證輸入內容`
 
 調用 `validateContent` 方法，檢查內容是否為空：
 - 當內容為空時，邊框顯示紅色。
 - 當內容有效時，移除紅色邊框。

 範例：
 ```swift
 nameTextField.validateContent()
 ```

 ---
 
 `4. 邊框顏色更新`
 
 `updateBorderColor` 是內部方法，依據 `isEmpty` 狀態動態更新邊框顏色與寬度：
 - 空值時：紅框（`UIColor.red.cgColor`）。
 - 有效值時：清除邊框（`UIColor.clear.cgColor`）。

 ----------------

 `* 適用場景`
 
 `1. 必填欄位驗證：`
 
 - 當需要即時驗證輸入值（例如姓名、電話）是否填寫時，顯示紅框提醒使用者。

 `2. 多次重複使用的輸入框：`
 
 - 減少樣式與邏輯重複，讓專案中所有輸入欄位保持一致設計。

 ----------------

 `* 延伸想法`
 
 1. 若輸入框有更複雜的驗證邏輯（如正則表達式檢查），可以擴展 `validateContent`，接收驗證條件作為參數。
 2. 如果欄位需要更高自由度（例如不同邊框顏色、提示文字動畫），可以考慮增加參數進一步自定義行為。
 
*/


import UIKit

/// 自訂的 `OrderCustomerDetailsTextField`，提供統一的樣式與行為設定，適用於訂單客戶資訊的輸入欄位。
///
/// ### 功能特色
/// - 支援自定義 Placeholder、鍵盤類型和輸入內容類型。
/// - 預設具有圓角邊框的樣式。
/// - 可根據輸入內容是否為空，動態更新邊框顏色（紅框提示）。
/// - 適配 AutoLayout，無需手動調整尺寸或額外配置。
class OrderCustomerDetailsTextField: UITextField {
    
    // MARK: - Initializer
    
    /// 初始化 `OrderCustomerDetailsTextField`。
    /// - Parameters:
    ///   - placeholder: 輸入框的提示文字（Placeholder），用於提示使用者該欄位的輸入內容。
    ///   - keyboardType: 鍵盤類型，預設為 `.default`，可根據欄位需求調整，例如 `.numberPad` 或 `.emailAddress`。
    ///   - textContentType: 輸入內容類型（Text Content Type），用於提升系統整合性，例如自動填充功能。
    ///   - isUserInteraction: 是否允許使用者互動，預設為 `true`。
    init(placeholder: String,
         keyboardType: UIKeyboardType = .default,
         textContentType: UITextContentType? = nil,
         isUserInteraction: Bool = true
    ) {
        super.init(frame: .zero)
        setupTextField(
            placeholder: placeholder,
            keyboardType: keyboardType,
            textContentType: textContentType,
            isUserInteraction: isUserInteraction
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 TextField 的基本樣式與屬性。
    /// - Parameters:
    ///   - placeholder: 輸入框的提示文字。
    ///   - keyboardType: 鍵盤類型，用於控制鍵盤顯示的模式。
    ///   - textContentType: 系統提供的內容類型，用於提升自動填充或建議功能的準確性。
    ///   - isUserInteraction: 是否允許使用者互動，預設為 `true`。
    private func setupTextField(
        placeholder: String,
        keyboardType: UIKeyboardType,
        textContentType: UITextContentType?,
        isUserInteraction: Bool
    ) {
        self.borderStyle = .roundedRect
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.isUserInteractionEnabled = isUserInteraction
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Public Methods
    
    /// 驗證輸入內容是否為空，並根據結果更新邊框顏色。
    /// - 空值時顯示紅色邊框以提示使用者輸入。
    /// - 有效值時移除紅框。
    func validateContent() {
        let isEmpty = self.text?.isEmpty ?? true
        updateBorderColor(isEmpty: isEmpty)
    }
    /// 更新邊框顏色以反映輸入狀態。
    /// - Parameters:
    ///   - isEmpty: 輸入內容是否為空。`true` 表示空值，顯示紅色邊框；`false` 表示有值，移除紅框。
    private func updateBorderColor(isEmpty: Bool) {
        self.layer.borderColor = isEmpty ? UIColor.red.cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = isEmpty ? 1.0 : 0.0
    }
    
}
