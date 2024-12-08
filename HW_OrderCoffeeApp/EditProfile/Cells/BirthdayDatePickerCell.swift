//
//  BirthdayDatePickerCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/5.
//

// MARK: - BirthdayDatePickerCell 筆記
/**
 
 ## BirthdayDatePickerCell 筆記
 
 `* What`
 
 - `BirthdayDatePickerCell` 是一個自訂的 UITableViewCell，用來顯示生日日期選擇器 (`UIDatePicker`)。
 - 這個 cell 用於讓使用者選擇生日，並在日期變更後透過回調通知外部。

 -------------------------

 `* Why`
 
 - 在編輯個人資料的情境中，使用者需要方便地選擇生日日期。`BirthdayDatePickerCell` 提供了一個直覺的介面來完成這個需求。
 - 它的回調機制 (`onDateChanged`) 讓外部可以即時地獲取使用者選擇的新日期，方便更新界面或存取數據。
 
 -------------------------

 `* How`
 
 - 使用 `init(style:reuseIdentifier:) `初始化 cell，並設置日期選擇器的佈局 (setupLayout())，確保選擇器能在 cell 中佔據整個空間。
 - 透過` setupDatePicker() `方法來設置日期選擇器的目標事件，當使用者更改日期時觸發 `dateChanged() `方法。
 - 使用 `configure(with date:) `方法來設置日期選擇器的初始日期，使它能夠反映使用者目前的生日選擇，或提供一個默認的日期。
 
 -------------------------

 `* 總結`
 
 - `BirthdayDatePickerCell` 的目的是提供一個直觀且易用的日期選擇器，讓使用者選擇生日。
 - 使用回調機制來及時通知外部日期的變更。
 */


import UIKit

/// 用於顯示生日選擇器的 UITableViewCell
///
/// BirthdayDatePickerCell 主要用來顯示一個 UIDatePicker，讓使用者能夠選擇他們的生日日期。
/// 當日期被選取時，透過回調傳遞新選擇的日期。
class BirthdayDatePickerCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "BirthdayDatePickerCell"
    
    /// 日期變更的回調，用於通知外部日期變更
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - UI Elements
    
    /// 自訂的日期選擇器，用於編輯使用者生日
    private let birthDayDatePicker = EditProfileDatePicker()
    
    
    // MARK: - Initializer
    
    /// 初始化 BirthdayDatePickerCell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupDatePicker()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    
    /// 設定日期選擇器的佈局
    private func setupLayout() {
        contentView.addSubview(birthDayDatePicker)
        NSLayoutConstraint.activate([
            birthDayDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            birthDayDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            birthDayDatePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            birthDayDatePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    /// 配置 Cell 的外觀屬性
    private func setupAppearance() {
        separatorInset = .zero // 確保分隔線完全禁用
        backgroundColor = .clear // 確保背景色與 TableView 一致
        selectionStyle = .none // 禁用點擊高亮效果
    }
    
    // MARK: - Setup DatePicker
    
    /// 設置日期選擇器的基本屬性與事件目標
    ///
    /// 此方法負責設置日期選擇器的行為，監聽日期變化的事件。
    private func setupDatePicker() {
        birthDayDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    /// 當日期變更時呼叫此方法，並透過回調傳遞新日期
    ///
    /// 此方法在使用者改變日期時觸發，並透過 `onDateChanged` 將選擇的新日期通知外部。
    @objc private func dateChanged() {
        let selectedDate = birthDayDatePicker.date
        onDateChanged?(selectedDate)
    }
    
    // MARK: - Configuration Method
    
    /// 設置 DatePicker 的選定日期
    ///
    /// - Parameter date: 要設置的日期
    ///
    /// 此方法用於設定初始日期，例如從外部傳入的使用者已選生日。
    func configure(with date: Date?) {
        guard let date = date else { return }
        birthDayDatePicker.date = date
    }
    
}
