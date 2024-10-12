//
//  OrderTermsMessageCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/12.
//

/*
 
 ## OrderTermsMessageCell 筆記：

    * 功能：
        - 顯示訂單規範訊息，包含確認訂單的標題及條款細節。
        - 提供用戶理解並同意相關條款、退款政策和隱私政策的訊息。

    * 視圖設置：
        - 使用 UILabel 顯示訂單確認標題。
        - 使用 UITextView 顯示條款的詳細訊息，其中包括可點擊的超連結，指向退款政策及隱私政策的網頁。
        - 透過 UIStackView 組織標題和條款訊息，排列為垂直方向以保持清晰佈局。
 
    * 超連結設置：
        - 使用 textView.linkTextAttributes 設定超連結的顏色和底線樣式。
        - 使用 NSMutableAttributedString 設定超連結文字及樣式，包括字體大小、行間距和顏色。
 
    * 對齊調整：
        - 使用 textView.textContainer.lineFragmentPadding = 0 來移除 UITextView 預設的內邊距，使其與標題 UILabel 的左對齊保持一致，改善視覺上的整齊感。
 
    * 元件使用注意事項：
        - 當設定富文本 (attributedText) 時，標準的字體和顏色屬性（如 textView.font、textColor）將被覆蓋，需使用 AttributedString 進行樣式設定。
 
 */


import UIKit

/// 用於顯示`訂單規範訊息`
class OrderTermsMessageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderTermsMessageCell"
    
    // MARK: - UI Elements
    
    /// 大標題
    private let titleLabel = createLabel(withText: "Please confirm and submit your order", font: UIFont.systemFont(ofSize: 18, weight: .semibold), textColor: .black)
    /// 訊息文字
    private let termsMessageTextView = createTermsMessageTextView()
    /// 包含標題和訊息的 StackView
    private let orderTermsStackView = createStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置視圖和佈局
    private func setupView() {
        orderTermsStackView.addArrangedSubview(titleLabel)
        orderTermsStackView.addArrangedSubview(termsMessageTextView)
        
        contentView.addSubview(orderTermsStackView)
        NSLayoutConstraint.activate([
            orderTermsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            orderTermsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            orderTermsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            orderTermsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    // MARK: - Factory Methods
    
    /// 建立 Label
    private static func createLabel(withText text: String, font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        return label
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
    
    /// 建立 Terms Message TextView
    private static func createTermsMessageTextView() -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link               // 自動檢測超連結
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // 移除文本片段的內邊距，確保與其他視圖對齊（titleLabel）
        textView.textContainer.lineFragmentPadding = 0
        
        // 設置超連結樣式，包括顏色和底線
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.gray,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        // 設定文字內容及樣式
        let fullText = "By clicking submit order, you agree to our terms and conditions, refund policy, and privacy policy."
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // 設定 paragraphStyle（行間距）
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullText.count))
        
        // 設定整體文字的字體和顏色
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 0, length: fullText.count))
        
        // 設定 refund policy 的超連結
        let refundPolicyRange = (fullText as NSString).range(of: "refund policy")
        attributedString.addAttribute(.link, value: "https://www.starbucks.com.tw/faq/products_3.jspx", range: refundPolicyRange)
        
        // 設定 privacy policy 的超連結
        let privacyPolicyRange = (fullText as NSString).range(of: "privacy policy")
        attributedString.addAttribute(.link, value: "https://www.starbucks.com.tw/faq/faq.jspx", range: privacyPolicyRange)
        
        textView.attributedText = attributedString
        
        return textView
    }
    
}

