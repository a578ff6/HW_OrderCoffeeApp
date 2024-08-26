//
//  EditProfileTableHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/25.
//

/*
 ## EditProfileTableHandler 
    - 負責處理 EditProfileViewController 中的 UITableView 的 Delegate 與 DataSource 。
 
 ## 主要功能包括：

    * 管理使用者資料顯示：
        - 根據 userDetails 的內容來配置和顯示不同的資料欄位，如名字、電話號碼、生日、地址、性別等。

    * 日期選擇器的顯示與隱藏：
        - 控制 DatePicker 的顯示與隱藏，並確保在使用者改變日期後能即時更新顯示的日期。

    * 資料的動態更新：
        - 使用回調 onDateChanged 來處理日期變更，並及時反映在 userDetails 中，確保顯示的內容與選擇的內容一致。

    * 分離責任：
        - 將 UITableViewDelegate 和 UITableViewDataSource 的邏輯與視圖控制器分開。
 */


// MARK: - 保留
/*

 import UIKit

 /// 表格處理類別，用於管理 UITableView 的 DataSource 與 Delegate
 class EditProfileTableHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
     
     // MARK: - Properties
     
     var userDetails: UserDetails?
     var isDatePickerVisible = false
     let datePicker: UIDatePicker
     
     /// 當日期改變時的回調
     var onDateChanged: ((Date) -> Void)?
     
     // MARK: - Initialize
     
     init(userDetails: UserDetails?, isDatePickerVisible: Bool, datePicker: UIDatePicker) {
         self.userDetails = userDetails
         self.isDatePickerVisible = isDatePickerVisible
         self.datePicker = datePicker
     }
     
     // MARK: - UITableViewDataSource

     func numberOfSections(in tableView: UITableView) -> Int {
         return 5
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return section == 2 && isDatePickerVisible ? 2 : 1
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return (indexPath.section == 2 && indexPath.row == 1) ? 216 : 60
     }
     
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         switch section {
         case 0: return "Name"
         case 1: return "Phone Number"
         case 2: return "Birthday"
         case 3: return "Address"
         case 4: return "Gender"
         default: return nil
         }
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if indexPath.section == 2 && indexPath.row == 1 {
             return configureDatePickerCell()
         }
         return configureCell(for: indexPath)
     }
     
     // MARK: - 設定每一個 cell

     ///配置顯示日期選擇器的 UITableViewCell
     private func configureDatePickerCell() -> UITableViewCell {
         let cell = UITableViewCell()
         cell.contentView.addSubview(datePicker)
         datePicker.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             datePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
             datePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
             datePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
             datePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
         ])
         if let birthday = userDetails?.birthday {
             datePicker.date = birthday
         }
         return cell
     }
     
     /// 根據區塊和行配置對應的 UITableViewCell
     private func configureCell(for indexPath: IndexPath) -> UITableViewCell {
         switch indexPath.section {
         case 0:
             return configureProfileTextFieldCell(text: userDetails?.fullName, placeholder: "Enter your full name")
         case 1:
             return configureProfileTextFieldCell(text: userDetails?.phoneNumber, placeholder: "Enter your phone number")
         case 2:
             return configureBirthdaySelectionCell()
         case 3:
             return configureProfileTextFieldCell(text: userDetails?.address, placeholder: "Enter your address")
         case 4:
             return configureGenderSelectionCell()
         default:
             return UITableViewCell()
         }
     }
     
     // MARK: - 各類型的 cell 設定方法

     /// 配置顯示輸入框的 UITableViewCell
     private func configureProfileTextFieldCell(text: String?, placeholder: String?) -> ProfileTextFieldCell {
         let cell = ProfileTextFieldCell()
         cell.configure(textFieldText: text, placeholder: placeholder)
         return cell
     }
     
     /// 配置顯示生日選擇的 UITableViewCell
     private func configureBirthdaySelectionCell() -> BirthdaySelectionCell {
         let cell = BirthdaySelectionCell()
         cell.configure(with: userDetails?.birthday)
         return cell
     }
     
     /// 配置顯示性別選擇的 UITableViewCell
     private func configureGenderSelectionCell() -> GenderSelectionCell {
         let cell = GenderSelectionCell()
         cell.configure(withGender: userDetails?.gender)
         cell.onGenderChanged = { [weak self] newGender in
             self?.userDetails?.gender = newGender
         }
         return cell
     }
     
     // MARK: - UITableViewDelegate

     /// 處理行選擇時的操作
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if indexPath.section == 2 && indexPath.row == 0 {
             isDatePickerVisible.toggle()
             tableView.beginUpdates()
             tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
             tableView.endUpdates()
         }
     }
     
     /// 根據 indexPath 來判斷哪些 Cell 是可以被選取的，並返回 nil 來使某些 Cell 不可選取。
     func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
         if indexPath.section == 2 && indexPath.row == 0 {
             return indexPath
         } else {
             return nil
         }
     }

     /// 調整 Header Height
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 30
     }

     
     // MARK: - Helper Method

     /// 返回「生日選擇行」的 IndexPath
     func indexPathForBirthdaySelectionCell() -> IndexPath {
         return IndexPath(row: 0, section: 2)
     }
     
 }

*/


// MARK: - 修改用

import UIKit

/// 表格處理類別，用於管理 UITableView 的 DataSource 與 Delegate
class EditProfileTableHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var userDetails: UserDetails?
    var isDatePickerVisible = false
    let datePicker: UIDatePicker
    
    /// 當日期改變時的回調
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - Initialize
    
    init(userDetails: UserDetails?, isDatePickerVisible: Bool, datePicker: UIDatePicker) {
        self.userDetails = userDetails
        self.isDatePickerVisible = isDatePickerVisible
        self.datePicker = datePicker
    }
    
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 && isDatePickerVisible ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 2 && indexPath.row == 1) ? 216 : 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Name"
        case 1: return "Phone Number"
        case 2: return "Birthday"
        case 3: return "Address"
        case 4: return "Gender"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 && indexPath.row == 1 {
            return configureDatePickerCell()
        }
        return configureCell(for: indexPath)
    }
    
    // MARK: - 設定每一個 cell

    ///配置顯示日期選擇器的 UITableViewCell
    private func configureDatePickerCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        if let birthday = userDetails?.birthday {
            datePicker.date = birthday
        }
        return cell
    }
    
    /// 根據區塊和行配置對應的 UITableViewCell
    private func configureCell(for indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return configureProfileTextFieldCell(text: userDetails?.fullName, placeholder: "Enter your full name")
        case 1:
            return configureProfileTextFieldCell(text: userDetails?.phoneNumber, placeholder: "Enter your phone number")
        case 2:
            return configureBirthdaySelectionCell()
        case 3:
            return configureProfileTextFieldCell(text: userDetails?.address, placeholder: "Enter your address")
        case 4:
            return configureGenderSelectionCell()
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - 各類型的 cell 設定方法

    /// 配置顯示輸入框的 UITableViewCell
    private func configureProfileTextFieldCell(text: String?, placeholder: String?) -> ProfileTextFieldCell {
        let cell = ProfileTextFieldCell()
        cell.configure(textFieldText: text, placeholder: placeholder)
        return cell
    }
    
    /// 配置顯示生日選擇的 UITableViewCell
    private func configureBirthdaySelectionCell() -> BirthdaySelectionCell {
        let cell = BirthdaySelectionCell()
        cell.configure(with: userDetails?.birthday)
        return cell
    }
    
    /// 配置顯示性別選擇的 UITableViewCell
    private func configureGenderSelectionCell() -> GenderSelectionCell {
        let cell = GenderSelectionCell()
        cell.configure(withGender: userDetails?.gender)
        cell.onGenderChanged = { [weak self] newGender in
            self?.userDetails?.gender = newGender
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate

    /// 處理行選擇時的操作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            isDatePickerVisible.toggle()
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    /// 根據 indexPath 來判斷哪些 Cell 是可以被選取的，並返回 nil 來使某些 Cell 不可選取。
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 && indexPath.row == 0 {
            return indexPath
        } else {
            return nil
        }
    }

    /// 調整 Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    
    // MARK: - Helper Method

    /// 返回「生日選擇行」的 IndexPath
    func indexPathForBirthdaySelectionCell() -> IndexPath {
        return IndexPath(row: 0, section: 2)
    }
    
}
