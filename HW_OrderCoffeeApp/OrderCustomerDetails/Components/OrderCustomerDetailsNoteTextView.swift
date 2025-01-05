//
//  OrderCustomerDetailsNoteTextView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/3.
//


// MARK: - OrderCustomerDetailsNoteTextView 筆記
/**
 
 ## OrderCustomerDetailsNoteTextView 筆記

 `* What`
 
 - `OrderCustomerDetailsNoteTextView` 是一個自訂的 `UITextView`，專門用於輸入備註或特殊需求，提供以下功能：
 
 1. 提示文字（Placeholder）：當輸入框為空時顯示提示文字，幫助使用者直觀了解輸入需求。
 2. 字數限制：限制輸入的最大字數，防止超出規定長度，並通知剩餘字數。
 3. 即時更新：每次內容變更時，透過單一回調提供輸入文字和剩餘字數，方便外部同步處理。
 4. 動態樣式切換：根據是否有內容，自動調整文字顏色（灰色或黑色）和樣式，提升使用者體驗。

 ----------------

 `* Why`
 
 1. 解決通用需求：備註輸入框在許多應用場景中是常見需求（例如訂單備註、特殊要求），統一樣式和功能能提升開發效率和一致性。
 2. 減少重複實現：避免多處手動處理字數限制、樣式切換和即時回調邏輯，集中在單一元件中維護。
 3. 提升使用者體驗：
    - 提示文字引導使用者理解輸入需求。
    - 即時顯示剩餘字數，防止內容超長造成操作中斷。
    - 動態樣式切換，使輸入框符合直觀的編輯行為。

 ----------------

 `* How`

` 1.初始化`
 
 - 參數化設置：
    - 提供 `placeholder` 參數設置提示文字。
    - 提供 `maxCharacters` 參數設置最大字數限制，預設為 150。

 `2.功能實現`
 
 - 提示文字與樣式切換：
    - 當輸入框內容為空時：
      - 顯示 `placeholderText` 並設置文字顏色為灰色。
    - 當開始編輯時：
      - 清空提示文字，切換顏色為黑色。
    - 當結束編輯且內容為空時：
      - 恢復顯示提示文字及灰色樣式。

 `3.字數限制與通知：`
 
    - 使用 `maxCharacters` 限制輸入內容長度，超出部分自動截斷。
    - 在輸入內容變更時觸發 `onContentUpdate` 回調，通知當前輸入內容及剩餘字數。

 `4.靜態設置內容：`
 
    - 提供 `setText(_:)` 方法，用於初始化或靜態更新輸入框內容。
    - 設置完成後，自動計算剩餘字數並觸發回調。

 ----------------

 `* 使用方式`
 
 1. 初始化輸入框：
 
    ```swift
    let noteTextView = OrderCustomerDetailsNoteTextView(placeholder: "請輸入您的備註", maxCharacters: 200)
    ```
 
 2. 設置回調監聽：
 
    ```swift
    noteTextView.onContentUpdate = { text, remainingCharacters in
        print("當前內容：\(text)，剩餘字數：\(remainingCharacters)")
    }
    ```
 
 3. 動態或靜態設置內容：
 
    ```swift
    noteTextView.setText("這是初始內容")
    ```

 `* 回調邏輯`
 
 - 使用 `onContentUpdate` 集中管理：
   - 傳遞當前輸入框內容和剩餘字數，外部僅需關注此回調處理邏輯，無需直接操控輸入框內部邏輯。

 ----------------

 `* 補充與最佳實踐`
 
` 1. 區分靜態與動態邏輯：`
 
    - `setText(_:)` 用於初始化和靜態設置內容。
    - `textViewDidChange` 處理動態輸入過程，減少功能重疊。
 
 `2. 統一回調接口：`
 
    - 使用單一回調 `onContentUpdate` 提供內容與剩餘字數，簡化外部邏輯。
 
 `3. 樣式擴展性：`
 
    - 將字體、邊框、顏色等樣式抽象為初始化參數，提升可配置性。
 */


// MARK: - *OrderCustomerDetailsNoteTextView: `setText` 與 `textViewDidChange` 的處理邏輯
/**
 
 ## OrderCustomerDetailsNoteTextView: `setText` 與 `textViewDidChange` 的處理邏輯

 `* What`

 - `setText`
   - 設定輸入框的初始文字內容，適用於初始化或靜態內容設置場景。
   - 自動計算剩餘字數並觸發回調，確保外部同步更新狀態。
   - 用於靜態的外部指派內容，如配置模型數據時。

 - `textViewDidChange`
   - 即時監聽使用者輸入，檢查字數限制並更新當前輸入內容。
   - 在每次輸入變更時計算剩餘字數，適合動態交互場景。
   - 負責處理使用者輸入過程中的邏輯，如動態更新剩餘字數顯示。

 ---------------

 `* Why`

 - `不同場景需求：`
 
   - `setText` 解決的是靜態內容初始化，讓外部可以指定輸入框的預設值並確保狀態同步。
   - `textViewDidChange` 處理的是動態輸入邏輯，專注於即時響應使用者交互。

 - `提升可讀性與責任分離：`
 
   - 兩者目的明確，避免邏輯交叉或混淆：
     - `setText`：靜態內容設置 + 初始同步狀態。
     - `textViewDidChange`：動態輸入監控 + 字數限制。

 - `減少外部重複邏輯：`
 
   - `setText` 自動計算剩餘字數，讓外部不必重複處理相關計算，提升代碼簡潔性。
   - `textViewDidChange` 同樣提供內容和剩餘字數回調，讓外部只需關注結果。

 ---------------

 `* How`

 1. 設置靜態內容時使用 `setText`：
 
    - 用於初始化或需要直接指派內容的情況。
    - 通過 `onContentUpdate` 回調通知外部剩餘字數和內容。

    ```swift
    noteTextView.setText("Hello, this is a test note.")
    ```

 ----
 
 2. 即時監聽動態輸入使用 `textViewDidChange`：
 
    - 使用者每次輸入變更，內部會自動檢查字數限制並更新狀態。
    - 外部無需直接調用，通過監聽回調即可獲得輸入內容和剩餘字數。

    ```swift
    noteTextView.onContentUpdate = { text, remainingCharacters in
        print("輸入內容：\(text)，剩餘字數：\(remainingCharacters)")
    }
    ```

 ----

 3. 職責分離的好處：
 
    - **`setText`** 保持簡潔，僅負責初始化內容，同時確保外部同步狀態。
    - **`textViewDidChange`** 完全集中於使用者的輸入過程，處理字數限制和回調。

 ---------------

 `* 總結`

 `1.Why`
 - `setText` 與 `textViewDidChange` 的分離是為了清晰劃分靜態與動態邏輯，確保每個方法的單一職責。
 - 兩者互補，減少重複邏輯，提高代碼的可維護性和易讀性。

 `2.How`
 - 在初始化時使用 `setText` 配置靜態內容。
 - 在用戶輸入時透過 `textViewDidChange` 自動處理輸入限制與更新狀態。

 `3.結果`
 - 統一的回調接口 `onContentUpdate`，外部可以簡單地監聽輸入內容和剩餘字數，達成清晰、模組化的設計。
 */



import UIKit

/// 自訂的備註輸入框（Note TextView），提供統一的樣式與行為設定，適用於輸入備註或特殊需求。
///
/// ### 功能特色
/// - 提示文字（Placeholder）： 當輸入框內容為空時，自動顯示提示文字，幫助使用者快速了解輸入需求。
/// - 字數限制： 內建最大字數限制，避免輸入過多內容，並透過回調通知剩餘字數，提升使用體驗。
/// - 即時更新： 當內容變更時，透過單一回調提供最新的輸入內容及剩餘字數，方便外部同步處理。
/// - 動態樣式切換： 根據是否有內容，自動調整文字顏色與樣式，增強使用者互動感受。
///
/// ### 使用場景
/// 適用於需要輸入附加說明或備註的情境，例如：
///    - 訂單備註（例如外送地址、特殊需求）。
///    - 客戶需求描述（例如產品需求、個人偏好）。
///
/// ### 使用方式
/// 1. 初始化：傳入提示文字（Placeholder）及最大字數限制（可選）。
/// 2. 回調監聽：設定 `onContentUpdate` 回調處理輸入內容及剩餘字數的變化。
/// 3. 靜態設置內容：使用 `setText(_:)` 方法設置初始內容，並觸發回調同步更新狀態。
///
/// ### 注意事項
/// - 使用 `setText(_:)` 設置初始內容時，會自動計算剩餘字數並觸發回調，需確保外部處理邏輯能正確應對回調更新。
/// - 動態輸入的字數限制檢查及更新由內部代理方法 `textViewDidChange` 負責，外部無需額外處理。
class OrderCustomerDetailsNoteTextView: UITextView {
    
    // MARK: - Properties
    
    /// 最大字數限制
    private let maxCharacters: Int
    
    /// 初始提示文字
    private let placeholderText: String
    
    // MARK: - Callbacks
    
    /// 回調：當輸入內容或剩餘字數變更時，通知外部
    ///
    /// - Parameters:
    ///   - text: 輸入框當前的內容文字
    ///   - remainingCharacters: 剩餘可輸入的字數
    var onContentUpdate: ((String, Int) -> Void)?
    
    // MARK: - Initializer
    
    /// 初始化自訂輸入框
    /// - Parameters:
    ///   - placeholder: 提示文字，當輸入框為空時顯示。
    ///   - maxCharacters: 最大字數限制，預設為 150。
    init(placeholder: String, maxCharacters: Int = 150) {
        self.placeholderText = placeholder
        self.maxCharacters = maxCharacters
        super.init(frame: .zero, textContainer: nil)
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置輸入框的樣式與行為
    ///
    /// - 設置文字樣式、字體大小、邊框等屬性，並初始化為提示文字狀態。
    /// - 設置自身為 UITextView 的代理。
    private func setupTextView() {
        self.text = placeholderText
        self.textColor = .lightGray
        self.font = .systemFont(ofSize: 16)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 8.0
        self.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.isScrollEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = self
    }
    
    /// 設定輸入框內容
    ///
    /// - 用於初始化或靜態設置內容。
    /// - 自動計算剩餘字數並觸發回調，保證外部狀態同步。
    /// - 如果文字為空，顯示提示文字；否則顯示正常內容。
    ///
    /// - Parameter text: 要設定的文字內容。
    func setText(_ text: String?) {
        if let text = text, !text.isEmpty {
            self.text = text
            self.textColor = .black
        } else {
            self.text = placeholderText
            self.textColor = .lightGray
        }
        
        // 初始設置時觸發回調，計算剩餘字數
        let remainingCharacters = maxCharacters - (text?.count ?? 0)
        onContentUpdate?(self.text, remainingCharacters)
    }
    
}

// MARK: - UITextViewDelegate
extension OrderCustomerDetailsNoteTextView: UITextViewDelegate {
    
    /// 當使用者開始編輯時，清除提示文字
    ///
    /// 如果輸入框目前內容為提示文字，清空內容並切換至正常文字樣式。
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    /// 當使用者結束編輯時，恢復提示文字
    ///
    /// 如果輸入框內容為空，恢復提示文字及其樣式。
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
    
    /// 當輸入框內容變更時，檢查字數限制並通知外部
    ///
    /// - 如果輸入字數超過限制，自動截斷為允許的最大字數。
    /// - 通知外部當前輸入內容及剩餘字數。
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        
        if text.count > maxCharacters {
            textView.text = String(text.prefix(maxCharacters))
        }
        
        let remainingCharacters = maxCharacters - textView.text.count
        onContentUpdate?(textView.text, remainingCharacters)
    }
}
