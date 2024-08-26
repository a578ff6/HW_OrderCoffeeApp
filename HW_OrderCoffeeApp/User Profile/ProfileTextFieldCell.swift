//
//  ProfileTextFieldCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/24.
//

/*
 在處理像「編輯個人資料」這類的表單頁面時，使用 UITableViewCell 來管理每個表單欄位是非常常見且有效的做法。以下是為什麼 UITableViewCell 是一個不錯選擇的原因：

 為什麼使用 UITableViewCell？
 靈活性：使用 UITableViewCell 可以讓你輕鬆管理多個表單欄位，每個欄位可以是一個 UITableViewCell，這樣即使未來需要增加或修改欄位也可以很方便地操作。

 可重用性：UITableViewCell 支援重用機制，能夠有效地管理記憶體和提升性能。當表單欄位較多時，這點尤為重要。

 自定義：你可以輕鬆地自定義每一個 UITableViewCell，例如你可以為每個欄位設置不同的輸入框、標籤或按鈕，這樣更有助於實現具體的 UI 需求。

 分隔欄位：UITableView 自帶的分隔線可以幫助清晰地分隔每個表單欄位，使頁面更有條理和易於閱讀。

 使用 UITableViewCell 的情境：
 姓名欄位：一個標籤和一個輸入框。
 電話欄位：一個標籤和一個輸入框。
 生日欄位：一個標籤和一個日期選擇器。
 性別欄位：一個標籤和一個性別選擇按鈕（例如選擇男或女）。
 地址欄位：一個標籤和一個多行的文字輸入框。
 每個這樣的欄位都可以是一個 UITableViewCell，讓整個表單結構非常清晰且易於管理。

 如何實現：
 自定義 UITableViewCell：你可以為每個欄位創建自定義的 UITableViewCell，設置標籤和輸入框的佈局。

 在 UITableView 中顯示表單：在 EditProfileViewController 中的 UITableView 內，為每個欄位配置對應的 UITableViewCell。
 */





// MARK: - 保留
/*
import UIKit

/// 是表單中每一個欄位的 UITableViewCell，它負責顯示標籤和輸入框的佈局。
class ProfileTextFieldCell: UITableViewCell {
    
    // MARK: - Static Properties

    static let reuseIdentifier = "ProfileTextFieldCell"
    
    // MARK: - UI Elements

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup

    /// 設定 Cell 的佈局
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
    }

}
*/



// MARK: - 修改用

import UIKit

/// 是表單中每一個欄位的 UITableViewCell，它負責顯示標籤和輸入框的佈局。
class ProfileTextFieldCell: UITableViewCell {
    
    // MARK: - Static Properties

    static let reuseIdentifier = "ProfileTextFieldCell"
    
    // MARK: - UI Elements

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup

    /// 設定 Cell 的佈局
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
    }

}
