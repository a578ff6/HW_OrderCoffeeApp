//
//  OrderCustomerNoteCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/14.
//

// MARK: - OrderCustomerNoteCell 重點筆記
/*
 
 ## OrderCustomerNoteCell 重點筆記：
 
    * 功能：
        - 用於顯示並處理顧客的備註輸入框，備註屬於選填，可以用於填寫特殊需求或提醒事項。
 
    * 組成部分：

        1. UI 元素：
            - noteTextView：用於輸入備註的 UITextView，提供提示文字供用戶知道該欄位為選填。
            - characterCountLabel：顯示剩餘字數，提示用戶輸入字數的限制。
            - characterCountAndNoteStackView：包含 noteTextView 和 characterCountLabel，垂直排列的 UIStackView。
        
        2. 回調 (Callback)：
            - onNoteChange：當用戶更改 noteTextView 的內容時觸發，用於通知外部更新備註。

        3. 初始化：
            - setupViews()：設置 UI 結構，將所有元素添加到 contentView 中，並應用自動佈局約束。
            - setupActions()：設置 UITextView 的委派，以便處理開始、結束編輯和內容變更的邏輯。
 
        4. 初始提示文字和字數限制：
            - noteTextView 使用了初始提示文字來告知使用者這是選填項目。
            - updateCharacterCount() 用於更新剩餘字數顯示，以確保用戶了解最大輸入限制。
 
        5. 重要方法：
            - configure(with:)：用於配置初始的備註內容。如果有現有的備註資料，將顯示備註，否則顯示初始提示文字。
            - textViewDidBeginEditing() 和 textViewDidEndEditing()：處理提示文字的顯示與清除。
            - textViewDidChange()：當用戶編輯 TextView 時，更新剩餘字數，並將變更通知外部。

    * 設計考量：
 
        1. 用戶體驗：
            - 使用提示文字和字數限制來引導用戶。
            - 當用戶點擊備註輸入框時，自動清除提示文字，讓用戶有直觀的輸入體驗。
 
        2. 靈活性：
            - configure(with:) 方法的設計讓 OrderCustomerNoteCell 可以在需要時配置現有的備註資料，使得該元件可重複使用於不同情境下。
            - cconfigure(with:) 方法的使用，由於 UserDetails 中並沒有 notes 屬性，但 CustomerDetails 中有。因此，OrderCustomerNoteCell 的 configure 方法應從 CustomerDetails 中填充 notes，而不是從 UserDetails。
        3. 即時反饋：
            - 通過剩餘字數的顯示和字數限制的應用，確保用戶輸入的內容符合限制，並且不會因為輸入過多內容而影響使用者體驗。

    * 未來改進空間：
        - 字數警告： 可以考慮在用戶即將超過字數限制時，改變 characterCountLabel 的顏色，以引起用戶的注意。
        - UI 改善：目前的邊框顏色是淺灰色，可以根據應用的主題顏色進一步調整，以提升視覺一致性。
        - 驗證格式：儘管備註沒有固定格式，但可以考慮提供一些快速填寫模板，方便用戶輸入常見的需求。
        - 保持文字：回到上一個視圖時，可以保留填寫的文字，而非回到該頁面時，再次清空 TextView 的 note 內容。
 */


// MARK: - UITextViewDelegate

/*
 1. 為什麼設置 `textViewDidBeginEditing`、`textViewDidEndEditing`、`textViewDidChange`？

    &. 這些委託方法的目的是為了管理 `UITextView` 的顯示與使用者的互動，具體作用如下：

        * textViewDidBeginEditing(_:)：
            - 當用戶開始編輯 UITextView 時，檢查當前文本是否是預設佔位文字（例如 "Add any special requests or notes..."），如果是，就清空它並改變字體顏色。這樣可以讓用戶明確知道這是用來輸入的框，不會混淆預設文字和實際輸入內容。

        * textViewDidEndEditing(_:)：
            - 當用戶完成編輯並結束 UITextView 的焦點時，如果輸入框是空的，則將預設佔位文字重新設置到 UITextView 中，並把顏色改成灰色（表示提示用途）。這樣可以引導用戶明確輸入要求，並讓未填寫時顯示佔位提示。

        * textViewDidChange(_:)：
            - 當 UITextView 的文本內容改變時，透過回調（callback）來通知外部，例如上層視圖控制器，可以即時獲取使用者輸入的內容並更新狀態。

 
 2. configure 方法中的 noteTextView.text = "Add any special requests or notes..." 與
    UITextViewDelegate 中的 textViewDidEndEditing 和初始化中的 noteTextView.text = "Add any special requests or notes..."
    主要差別在於它們的使用時機：
 
        * 初始化中的設置：
            - 這個是在 noteTextView 建立時就預設設置好初始的佔位文字和顏色。此時 textColor 設為 .lightGray，表示這是佔位文字。

        * configure 方法中的設置：
            - 這是當重新使用這個 cell 時，需要根據外部傳入的內容來設置初始狀態。
 
        * textViewDidEndEditing 中的設置：
            - 這個方法主要是在用戶編輯完成且未輸入任何文字時，把佔位文字重新設置回去，並改成灰色，作為提示用途。
 
 
 3. textView.text 會有兩個不同的 textColor 是因為它們用於不同的狀況來區分內容是佔位文字還是用戶輸入的文字：
 
        * 佔位文字（預設文字）：
            - 當 textView 沒有內容時，顯示佔位文字，例如 "Add any special requests or notes..."，並使用 灰色 (.lightGray) 來提示用戶這是一個預設的說明文字，而非用戶已經輸入的內容。
 
        * 用戶輸入的文字：
            - 當用戶開始編輯並輸入內容後，textColor 會被改為 深灰色 (.black)，這樣用戶可以明確看到這是他們自己輸入的內容，而不是系統預設的佔位文字。
 */


// MARK: - 關於 characterCountLabel 顯示剩餘字數為 114 的問題：

/*
    1. 初始提示文字影響字數計算：
        - 在 noteTextView 初始化時，設定了一段初始提示文字 Add any special requests or notes...。
        - 該文字實際上會被計入 noteTextView.text 的內容，所以在一開始初始化時，updateCharacterCount() 計算的字數並不是 0，而是減去初始提示文字的長度，導致 characterCountLabel 顯示 "剩餘字數：114"。

    2. updateCharacterCount() 使用：
        - updateCharacterCount() 計算 noteTextView.text.count，初始提示文字的字元數大約是 36 個，因此 150 - 36 大約等於 114。因此，一開始的剩餘字數是 114。
 
    3. 解決方式：
        - 在 updateCharacterCount() 中加入邏輯，以忽略提示文字的影響。具體來說，當提示文字顯示時，可以將剩餘字數顯示為最大值 150。
        - 這樣一來，在 noteTextView 中顯示提示文字時，characterCountLabel 會顯示為 "剩餘字數：150"，而當用戶開始輸入時，會顯示實際的剩餘字數。這樣就可以避免初始提示文字影響剩餘字數的顯示。
 */


// MARK: - print 觀察整理流程

/*
 1. 當 OrderCustomerDetailsViewController 從 Firebase 獲取到 UserDetails 並通過 CustomerDetailsManager 填充顧客資料時，notes 最初是 nil。
 
 2. 當 OrderCustomerNoteCell 被顯示時，會根據 CustomerDetails 中的 notes 來配置。若是 nil，則顯示提示文字。
 
 3. 當用戶在備註欄中輸入文字時，回調 (onNoteChange) 被觸發，並通過 CustomerDetailsManager.updateCustomerDetails() 來更新顧客資料。
 
 4. 每次變更時，可以通過 print 觀察到 notes 的內容變化。
 */


import UIKit

/// 設置 TextView，讓CustomerDetails中的notes進行額外備註（選填），可填寫特殊需求或提醒事項
class OrderCustomerNoteCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "OrderCustomerNoteCell"
    
    /// 最大字數限制
    private let maxCharacters = 150
    
    /// 初始提示文字
    private let placeholderText = "This field is optional. Add any special requests or notes..."

    // MARK: - UI Elements
    
    /// 剩餘字數顯示標籤
    private let characterCountLabel = createLabel(withText: "Characters Left：150", font: UIFont.systemFont(ofSize: 14), textColor: .darkGray, alignment: .right, numberOfLines: 1)
    
    /// 備註輸入框
    private let noteTextView = createNoteTextView()

    private let characterCountAndNoteStackView = createStackView(axis: .vertical, spacing: 15, alignment: .fill, distribution: .fill)
    
    // MARK: - Callbacks
    
    /// 備註變更時的回調
    var onNoteChange: ((String) -> Void)?
    
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
        characterCountAndNoteStackView.addArrangedSubview(characterCountLabel)
        characterCountAndNoteStackView.addArrangedSubview(noteTextView)
        contentView.addSubview(characterCountAndNoteStackView)
        
        NSLayoutConstraint.activate([
            characterCountAndNoteStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            characterCountAndNoteStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            characterCountAndNoteStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            characterCountAndNoteStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    /// 設置 UI 元件的動作
    private func setupActions() {
        noteTextView.delegate = self
        updateCharacterCount()  // 初始化時更新剩餘字數
    }
    
    // MARK: - Factory Methods
    
    private static func createNoteTextView() -> UITextView {
        let textView = UITextView()
        textView.text = "This field is optional. Add any special requests or notes..." // 設置初始提示文字
        textView.textColor = .lightGray // 設置提示文字顏色
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8.0
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = true
        return textView
    }
    
    private static func createLabel(withText text: String, font: UIFont, textColor: UIColor, alignment: NSTextAlignment, numberOfLines: Int) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Helper Methods
    
    /// 更新剩餘字數 Label
    ///
    /// 避免初始提示文字影響剩餘字數的顯示。
    private func updateCharacterCount() {
        if noteTextView.text == placeholderText {
            characterCountLabel.text = "Characters Left：\(maxCharacters)"
        } else {
            let remainingCharacters = maxCharacters - noteTextView.text.count
            characterCountLabel.text = "Characters Left：\(max(remainingCharacters, 0))"
        }
    }
    
    // MARK: - Configure Method
    
    /// 配置備註內容
    /// - Parameter note: 備註內容
    func configure(with note: String?) {
        if let note = note, !note.isEmpty {
            noteTextView.text = note
            noteTextView.textColor = .black         // 使用者自定義備註時的文字顏色
        } else {
            noteTextView.text = placeholderText
            noteTextView.textColor = .lightGray      // 顯示提示文字的顏色
        }
        updateCharacterCount() // 配置時更新剩餘字數
    }
    
}

// MARK: - UITextViewDelegate
extension OrderCustomerNoteCell: UITextViewDelegate {
    
    /// 當使用者開始編輯 TextView 時，清除提示文字
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    /// 當使用者結束編輯且沒有輸入內容時，恢復顯示提示文字
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
    
    /// 當 TextView 內容變更時，通知外部處理
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count > maxCharacters {
            textView.text = String(textView.text.prefix(maxCharacters))
        }
        updateCharacterCount()           // 更新剩餘字數
        onNoteChange?(textView.text)
    }
    
}
