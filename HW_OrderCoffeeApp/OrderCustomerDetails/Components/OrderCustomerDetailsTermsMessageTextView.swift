//
//  OrderCustomerDetailsTermsMessageTextView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/2.
//

// MARK: - OrderCustomerDetailsTermsMessageTextView 筆記
/**
 
 ## OrderCustomerDetailsTermsMessageTextView 筆記

 `* What`
 
 - `OrderCustomerDetailsTermsMessageTextView` 是一個自訂的 `UITextView`，用於顯示訂單規範訊息，包括：
 
 - 條款文字（例如 `refund policy` 和 `privacy policy`）。
 - 文字樣式（字體、行距、顏色）。
 - 支援超連結，點擊後可跳轉到相關政策的網頁。

 - 此類別主要功能：
 
 1. 禁用編輯和滾動功能，確保用戶無法修改內容。
 2. 自動檢測並設置文字中的超連結。
 3. 統一設置段落樣式和超連結樣式。

 -----------------

 `* Why`
 
 1. 清晰的責任分工
    - 此類別專注於顯示條款與超連結的邏輯，避免把樣式配置寫在其他容器類別中（如 `UICollectionViewCell`），提升代碼的可讀性與可維護性。

 2. 易於擴展
    - 未來若需修改文字樣式或新增條款內容，只需調整該類別內的邏輯，而不影響其他代碼。

 3. 增強一致性
    - 通過統一的樣式和邏輯，確保條款內容在不同頁面中的展示效果一致。

 4. 使用場景
 - 訂單確認頁面：顯示用戶需要同意的條款與政策。
 - 隱私政策頁面：展示靜態且帶有超連結的條款內容。

 -----------------

 `* How`

 1. 主要結構與功能
 
 - 常量（`Constants`）
   - 使用常量定義條款文字（如 `refund policy`）及超連結 URL，避免硬編碼，增加可維護性。

 - 初始化
   - 配置 `UITextView` 的基本屬性（禁用編輯、滾動，啟用超連結檢測）。
   - 設定文字樣式與內容，統一處理。

 - 樣式設置
   - 行距：通過 `NSMutableParagraphStyle` 設置文字的行距，提升可讀性。
   - 超連結樣式：定義顏色和底線樣式，與其他文字區分。

 - 超連結邏輯
   - 封裝 `setLink(_:url:in:)`，根據文字內容範圍自動設置超連結。
   - 支援多個超連結，易於擴展。

 ---

 2. 片段解析

 `- 初始化與配置`
 
    - 設置不可編輯、不可滾動，並啟用超連結檢測：
 
      ```swift
      isEditable = false
      isScrollEnabled = false
      dataDetectorTypes = .link
      translatesAutoresizingMaskIntoConstraints = false
      ```

 `- 統一樣式設置`
 
    - 使用 `applyAttribute` 將樣式屬性（字體、顏色、段落樣式）統一設置到整段文字：
 
      ```swift
      private func applyAttribute(_ name: NSAttributedString.Key, value: Any, to attributedString: NSMutableAttributedString) {
          attributedString.addAttribute(name, value: value, range: NSRange(location: 0, length: fullText.count))
      }
      ```

 `- 設置超連結`
 
    - 使用 `setLink` 方法指定文字範圍與超連結：
 
      ```swift
      private func setLink(_ text: String, url: String, in attributedString: NSMutableAttributedString) {
          let range = (fullText as NSString).range(of: text)
          attributedString.addAttribute(.link, value: url, range: range)
      }
      ```

 `- 生成樣式文字`
 
    - 將上述功能整合，生成完整的條款文字：
 
      ```swift
      private func createAttributedText() -> NSAttributedString {
          let attributedString = NSMutableAttributedString(string: fullText)
          applyAttribute(.paragraphStyle, value: paragraphStyle, to: attributedString)
          applyAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), to: attributedString)
          applyAttribute(.foregroundColor, value: UIColor.lightGray, to: attributedString)
          setLink(refundPolicyText, url: refundPolicyURL, in: attributedString)
          setLink(privacyPolicyText, url: privacyPolicyURL, in: attributedString)
          return attributedString
      }
      ```
 
 -----------------

 `* 補充：`
 
 1.超連結設置：
 
 - 使用 .linkTextAttributes 設定超連結的顏色和底線樣式。
 - 使用 NSMutableAttributedString 設定超連結文字及樣式，包括字體大小、行間距和顏色。

 2.對齊調整：
 
 - 使用 .textContainer.lineFragmentPadding = 0 來移除 UITextView 預設的內邊距，使其與標題 UILabel 的左對齊保持一致，改善視覺上的整齊感。

 3.元件使用注意事項：
 
 - 當設定富文本 (attributedText) 時，標準的字體和顏色屬性（如 textView.font、textColor）將被覆蓋，需使用 AttributedString 進行樣式設定。
 */


import UIKit

/// 用於顯示訂單規範訊息的自訂 TextView。
/// 此類別負責顯示訂單相關的條款與政策，包含文字樣式設定與超連結。
class OrderCustomerDetailsTermsMessageTextView: UITextView {
    
    // MARK: - Constants
    
    private let fullText = "By clicking submit order, you agree to our terms and conditions, refund policy, and privacy policy."
    private let refundPolicyText = "refund policy"
    private let privacyPolicyText = "privacy policy"
    private let refundPolicyURL = "https://www.starbucks.com.tw/faq/products_3.jspx"
    private let privacyPolicyURL = "https://www.starbucks.com.tw/faq/faq.jspx"
    
    // MARK: - Initializer
    
    /// 初始化方法，建立並配置 TextView。
    /// 預設為不可編輯、不可滾動，並自動檢測超連結。
    init() {
        super.init(frame: .zero, textContainer: nil)
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設定 TextView 的屬性與樣式。
    /// 包括：
    /// - 禁用編輯與滾動功能。
    /// - 啟用超連結檢測。
    /// - 設定字體、顏色、行距以及超連結樣式。
    private func setupTextView() {
        isEditable = false
        isScrollEnabled = false
        dataDetectorTypes = .link
        translatesAutoresizingMaskIntoConstraints = false
        textContainer.lineFragmentPadding = 0
        
        // 設置超連結樣式，包括顏色和底線
        linkTextAttributes = [
            .foregroundColor: UIColor.gray,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        // 設置文字內容及樣式
        attributedText = createAttributedText()
    }
    
    /// 生成包含條款內容的帶樣式文字。
    /// 包含：
    /// - 條款文字的字體與顏色設定。
    /// - 行距樣式的設置。
    /// - 超連結（如退款政策與隱私政策）的設定。
    /// - 返回處理好的 `NSAttributedString`。
    private func createAttributedText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // 設置段落樣式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        applyAttribute(.paragraphStyle, value: paragraphStyle, to: attributedString)
        
        // 設置文字字體與顏色
        applyAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), to: attributedString)
        applyAttribute(.foregroundColor, value: UIColor.lightGray, to: attributedString)
        
        // 設置超連結
        setLink(refundPolicyText, url: refundPolicyURL, in: attributedString)
        setLink(privacyPolicyText, url: privacyPolicyURL, in: attributedString)
        
        return attributedString
    }
    
    // MARK: - Helper Methods
    
    /// 統一設置屬性到整段文字。
    private func applyAttribute(_ name: NSAttributedString.Key, value: Any, to attributedString: NSMutableAttributedString) {
        attributedString.addAttribute(name, value: value, range: NSRange(location: 0, length: fullText.count))
    }
    
    /// 統一設置超連結。
    private func setLink(_ text: String, url: String, in attributedString: NSMutableAttributedString) {
        let range = (fullText as NSString).range(of: text)
        attributedString.addAttribute(.link, value: url, range: range)
    }
    
}
