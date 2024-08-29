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


// MARK: - 已經完善

import UIKit

/// 表格處理類別，用於管理 UITableView 的 DataSource 與 Delegate
class EditProfileTableHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    // 定義用戶詳細資料與日期選擇器的處理程序
    var userDetails: UserDetails?
    let datePickerHandler: DatePickerHandler
    var isDatePickerVisible = false

    // MARK: - Initialize
    
    // 初始化，接收用戶詳細資料與日期選擇器
    init(userDetails: UserDetails?, datePickerHandler: DatePickerHandler) {
        self.userDetails = userDetails
        self.datePickerHandler = datePickerHandler
    }
    
    // MARK: - UITableViewDataSource

    // 設定表格的 section 數量
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    // 設定每個 section 的列數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 3 && isDatePickerVisible ? 2 : 1
    }

    // 設定每個列的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 3 && indexPath.row == 1) ? 216 : 60
    }
    
    // 設定每個 section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Name"
        case 1: return "Phone Number"
        case 2: return "Address"
        case 3: return "Birthday"
        case 4: return "Gender"
        default: return nil
        }
    }
    
    // 設定每個列顯示的 Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 && indexPath.row == 1 {
            return datePickerHandler.configureDatePickerCell()
        }
        return configureCell(for: indexPath)
    }

    
    // MARK: - Cell Configuration Methods

    /// 根據 section 與 row 建立對應的 Cell
    private func configureCell(for indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return createProfileTextFieldCell(text: userDetails?.fullName, placeholder: "Enter your full name")
        case 1:
            return createProfileTextFieldCell(text: userDetails?.phoneNumber, placeholder: "Enter your phone number")
        case 2:
            return createProfileTextFieldCell(text: userDetails?.address, placeholder: "Enter your address")
        case 3:
            return createBirthdaySelectionCell()
        case 4:
            return createGenderSelectionCell()
        default:
            return UITableViewCell()
        }
    }
    
    /// 建立 ProfileTextFieldCell 並設定其內容
    private func createProfileTextFieldCell(text: String?, placeholder: String?) -> ProfileTextFieldCell {
        let cell = ProfileTextFieldCell()
        cell.configure(textFieldText: text, placeholder: placeholder)
        cell.backgroundColor = .lightWhiteGray

        cell.onTextChanged = { [weak self] updatedText in
            self?.updateUserDetail(for: placeholder, with: updatedText)
        }
        
        return cell
    }
    
    /// 根據 placeholder 更新對應的使用者資料
    private func updateUserDetail(for placeholder: String?, with updatedText: String?) {
        switch placeholder {
        case "Enter your full name":
            userDetails?.fullName = updatedText ?? ""
        case "Enter your phone number":
            userDetails?.phoneNumber = updatedText
        case "Enter your address":
            userDetails?.address = updatedText
        default:
            break
        }
    }

    // 建立 BirthdaySelectionCell 並設定其內容
    private func createBirthdaySelectionCell() -> BirthdaySelectionCell {
        let cell = BirthdaySelectionCell()
        cell.configure(with: userDetails?.birthday)
        cell.backgroundColor = .lightWhiteGray
        return cell
    }
    
    // 建立 GenderSelectionCell 並設定其內容
    private func createGenderSelectionCell() -> GenderSelectionCell {
        let cell = GenderSelectionCell()
        cell.configure(withGender: userDetails?.gender)
        cell.backgroundColor = .lightWhiteGray
        cell.onGenderChanged = { [weak self] newGender in
            self?.userDetails?.gender = newGender
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate

    /// 處理 Cell 的選取事件，控制 DatePicker 的顯示與隱藏
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            isDatePickerVisible.toggle()
            datePickerHandler.selectedDate = isDatePickerVisible ? userDetails?.birthday : nil
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    /// 決定是否允許選取指定的 Cell
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 3 && indexPath.row == 0 {
            return indexPath
        } else {
            return nil
        }
    }

    /// 設定每個 section 標題的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}



