//
//  DatePickerHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/28.
//

/*
 ## DatePickerHandler ：
 
    * 用途：DatePickerHandler 專門管理與 UIDatePicker 相關的邏輯，包括初始化、日期變更處理、以及顯示設定。

 ## 主要功能包括：
    * selectedDate 屬性管理：
        - selectedDate 屬性透過 didSet 監控變更，當其值更新時，自動同步更新 datePicker 的顯示日期，確保 datePicker 與 selectedDate 保持一致。

    * 初始化與設定：
        -  初始化時可以傳入一個初始日期，並自動設置 datePicker 的初始值。
        -  setupDatePicker() 方法用於設定 datePicker 的屬性，確保其配置符合應用的需求，並與 selectedDate 保持同步。
 
    * 日期變更處理：
        - 當使用者在 datePicker 上改變日期時，dateChanged() 方法會更新 selectedDate，並觸發 onDateChanged 閉包，便於 App 執行後續操作。
 
    * 表格視圖中的應用：
        - onfigureDatePickerCell() 方法將 datePicker 嵌入到 UITableViewCell 中，方便在表格視圖中顯示日期選擇器。
 */


// MARK: - 已經完善
import UIKit

/// 專門負責管理 datePicker 的顯示和選擇邏輯。
class DatePickerHandler {

    // MARK: - Properties
    
    let datePicker: UIDatePicker
    
    var selectedDate: Date? {
        didSet {
            if let date = selectedDate {
                datePicker.date = date
            }
        }
    }
    
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - Initializer
    
    /// 初始化時，接受一個 UIDatePicker 實例和一個可選的初始日期。
    init(datePicker: UIDatePicker, initialDate: Date? = nil) {
        self.datePicker = datePicker
        self.selectedDate = initialDate
        setupDatePicker()
    }
    
    // MARK: - Setup Methods
    
    /// 設置 datePicker 的屬性
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        if let date = selectedDate {
            datePicker.date = date
        }
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    /// 當使用者在 datePicker 上選擇日期時，觸發此方法。
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        onDateChanged?(datePicker.date)
    }
    
    // MARK: - Configuration Method
    
    /// 用來將 datePicker 添加到一個 UITableViewCell 中，以便在表格視圖中使用。
    func configureDatePickerCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(datePicker)
        cell.backgroundColor = .lightWhiteGray
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        return cell
    }
}




