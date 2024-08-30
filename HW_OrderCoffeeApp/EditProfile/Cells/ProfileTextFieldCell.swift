//
//  ProfileTextFieldCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/24.
//

/*

 使用 UITableViewCell 而不是直接使用 UITextField：
    
    * 與 UITableView 的整合性：
        - 使用 UITableViewCell 可以讓 UITextField 更容易與 UITableView 進行整合。
        - UITableViewCell 提供的佈局和配置方式可以讓 UITextField 更加符合表單中的欄位需求，且容易管理整個表單的顯示與互動。
 
    * 支援複雜佈局：
        - UITableViewCell 可以輕鬆地擴展，例如在單個 cell 中添加其他 UI 元件（如標籤、按鈕等），以滿足複雜的佈局需求。
        - 這使得每一個「表單欄位」可以有更多的自定義選項，而不只是單純的文字輸入。
 
    * 一致性：
        - 使用 UITableViewCell 可以保持整個 App 中表單欄位的樣式和行為一致，減少重複代碼，提高可維護性。

 ------------------------- ------------------------- ------------------------- -------------------------
 
 ## ProfileTextFieldCell：
        - 是一個自定義的 UITableViewCell，專門用於顯示表單中的文字輸入欄位。

    * 配置方法：
        - configure(textFieldText:placeholder:)：用來配置 textField 的顯示內容與鍵盤類型。根據 placeholder 的內容動態設定鍵盤類型。

    * 事件處理：
        - textFieldDidChange()：當 textField 內容變更時觸發。如果 textField 的 fullName的布且內容為空，會顯示紅色邊框提示。
 ------------------------- ------------------------- ------------------------- -------------------------

 */


// MARK: - 已經完善

import UIKit

/// 是表單中每一個欄位的 UITableViewCell，它負責顯示標籤和輸入框的佈局。
class ProfileTextFieldCell: UITableViewCell {
    
    // MARK: - Properties

    static let reuseIdentifier = "ProfileTextFieldCell"
    
    var onTextChanged: ((String?) -> Void)?
    
    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    // MARK: - Layout Setup

    private func setupLayout() {
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration Method

    /// 配置 textField 的顯示內容
    ///
    /// - Parameter textFieldText: 用來設定 textField 的文本內容
    /// - Parameter placeholder: 設定 textField 的 placeholder 提示文字
    func configure(textFieldText: String?, placeholder: String? = nil) {
        textField.text = textFieldText
        textField.placeholder = placeholder
        configureKeyboardType(for: placeholder)
    }
    
    /// 鍵盤樣是設置
    ///
    /// - Parameter placeholder: 根據 TextField 的 placeholder 設置鍵盤樣式
    private func configureKeyboardType(for placeholder: String?) {
        if placeholder == "Enter your phone number" {
            textField.keyboardType = .phonePad
        } else {
            textField.keyboardType = .default
        }
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange() {
        onTextChanged?(textField.text)
        updateTextFieldAppearance()
    }
    
    /// 當 fullName 欄位為空時，顯示紅色邊框
    private func updateTextFieldAppearance() {
        if textField.placeholder == "Enter your full name", textField.text?.isEmpty == true {
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1.0
        } else {
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.borderWidth = 0.0
        }
    }

}
