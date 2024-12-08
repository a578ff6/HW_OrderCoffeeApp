//
//  EditProfileTableHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/25.
//

// MARK: - 筆記：為何大頭照邏輯設置 photoDelegate 而非由 EditProfileTableHandler 處理（重要）
/**
 
 # 筆記：為何大頭照邏輯設置 photoDelegate 而非由 EditProfileTableHandler 處理

 `* What`

 `- 問題背景:`
    - 在 `EditProfileTableHandler` 中，透過 `photoDelegate?.didTapChangePhoto`，大頭照的處理邏輯交由主控制器或協調器處理，而非直接由 `EditProfileTableHandler` 完成。

 `- 主要問題包括：`
 
    1. 是否需要設置 `photoDelegate`？
    2. 為什麼大頭照邏輯需要與其他欄位（如文字或日期）分開處理？
    3. 直接在 `EditProfileTableHandler` 處理會產生什麼問題？

 --------------------------------

 `* Why`

 `1. 大頭照邏輯的特殊性`

 - 大頭照的業務流程涉及以下步驟，超出了 `EditProfileTableHandler` 的責任範圍：
 
    - `圖片選擇`：需要調用系統相簿或相機功能。
    - `圖片壓縮`：在上傳到 Firebase Storage 前進行壓縮與格式處理。
    - `上傳與存儲`：與 Firebase Storage 通信，將圖片存儲並獲取下載 URL。
    - `更新模型與界面`：將下載 URL 更新到用戶資料模型，並即時反映在界面上。

 - 與其他欄位邏輯的差異
 
    - 相比其他欄位（如文字或日期）：
    - `文字欄位`：本地模型更新即可完成，無需與外部系統交互。
    - `生日日期`：即便是動態顯示，也僅影響表格的內部邏輯，與 Firebase 無關。

 - `大頭照處理`需要額外處理與 `Firebase Storage `的通信與圖片壓縮，這使得其責任範圍明顯不同。

 ---

 `2. 設置 photoDelegate 的優勢`

` - 符合職責單一原則（SRP）`
 
    - `EditProfileTableHandler` 的核心責任是：
    - 配置表格的顯示與基本交互邏輯。
    - 與主控制器協作，進行模型的本地更新。

 - 透過 `photoDelegate`，圖片選擇與處理邏輯被交由主控制器（如 `EditProfileViewController`）或協調器（如 `ProfileImageCoordinator`），確保 `EditProfileTableHandler` 保持輕量化，專注於表格邏輯。

 `- 提升模組化與可測試性`
 
 `1. 模組化：`
 
    - 主控制器專注於業務邏輯。
    - 表格處理器專注於界面配置與基礎交互。
 
 `2. 測試獨立性：`
 
    - 可以獨立測試表格邏輯（`EditProfileTableHandler`）。
    - 可以針對圖片選擇與上傳流程進行測試（`ProfileImageCoordinator`）。

 `3. 一致性與集中處理原則`
 
    - 邏輯集中處理：主控制器負責所有與 Firebase 的交互，包括用戶資料保存與圖片上傳。
    - 模型與界面同步：主控制器確保圖片 URL 與用戶模型的同步更新，避免邏輯分散。

 --------------------------------

 `* How`

 `1.保留 photoDelegate 的解耦設計`

 `- 表格邏輯：`
 
    - `EditProfileTableHandler` 僅通知圖片更改事件，專注於表格的配置與基礎交互。

 `- 圖片邏輯：`
 
    - 主控制器（或協調器）負責圖片選擇、壓縮、上傳以及模型更新。

 `- 確保一致性`
 
    - 表格的其他欄位（如文字或日期）均通知主控制器進行模型更新。
    - 大頭照事件亦通過 `photoDelegate` 通知主控制器，保持邏輯一致。

 `- 避免責任模糊化與代碼冗長`
 
    - 表格邏輯專注於界面層級，避免處理過多圖片相關邏輯。
    - 測試表格邏輯時無需引入圖片處理的依賴，提升測試效率。

 --------------------------------

 `* 總結`
 
 - 透過 `photoDelegate` 將大頭照處理邏輯從 `EditProfileTableHandler` 中解耦的設計優勢在於：
 
    1. 符合職責單一原則，避免邏輯混亂。
    2. 提升模組化與可測試性，確保邏輯隔離與代碼清晰。
    3. 集中處理與外部交互相關邏輯，保持一致性與可維護性。
 */


// MARK: - BirthdayDatePickerCell 與 BirthdaySelectionCell 的關聯性筆記
/**
 
 ### BirthdayDatePickerCell 與 BirthdaySelectionCell 的關聯性筆記

 `* What`
 
 - `BirthdayDatePickerCell` 和 `BirthdaySelectionCell` 之間的關聯性體現在用戶選擇生日日期的過程中。
 - `BirthdaySelectionCell` 用於顯示已選擇的生日日期，並在被點擊時展開或收起 `BirthdayDatePickerCell`，讓用戶能夠選擇新的生日日期。

 
 `* Why 需要這樣的關聯性`
 
 - 生日是個人資料中的重要信息，因此需要提供一個簡單且直覺的方式讓用戶查看並修改生日。
 - `BirthdaySelectionCell` 提供了使用者已選擇的日期，並引導使用者點擊後顯示完整的日期選擇器，達到縮減視圖空間的效果，保持介面的簡潔。
 - `BirthdayDatePickerCell` 則提供了用戶改變日期的交互界面，使得日期的選擇操作更加便捷。

 `* How BirthdaySelectionCell 與 BirthdayDatePickerCell 互動`
 
 - `BirthdaySelectionCell` 用於顯示已選擇的生日日期，當點擊 `BirthdaySelectionCell` 時，`EditProfileTableHandler` 會負責展開或收起 `BirthdayDatePickerCell`。
 - `EditProfileTableHandler`中有屬性 `isDatePickerVisible`，用於管理 `BirthdayDatePickerCell` 的顯示與否，通過在用戶點擊 `BirthdaySelectionCell` 時切換這個屬性值，來控制日期選擇器的顯示。
 - `BirthdayDatePickerCell` 中的日期選擇器 (`UIDatePicker`) 允許用戶修改日期，並且在日期變更後會透過回調 (`onDateChanged`) 通知外部。
 - 在 `EditProfileTableHandler` 中，當用戶選擇了新日期時，通過回調更新 `ProfileEditModel` 中的生日資訊，並且更新顯示在 `BirthdaySelectionCell` 上的日期標籤，使得用戶可以即時看到新的選擇結果。

` * 關聯性的詳細步驟`

` 1. 顯示生日選擇 (BirthdaySelectionCell)：`
 
 - 在編輯個人資料頁面中，`BirthdaySelectionCell` 用於顯示用戶目前選擇的生日。
 - 當用戶點擊此 `Cell` 時，`EditProfileTableHandler` 會控制是否需要展開 `BirthdayDatePickerCell`。

 `2. 展開日期選擇器 (BirthdayDatePickerCell)：`
 
 - 點擊 `BirthdaySelectionCell` 後，`EditProfileTableHandler` 透過變更 `isDatePickerVisible` 來決定是否顯示 `BirthdayDatePickerCell`。
 - `BirthdayDatePickerCell` 中的 `UIDatePicker` 可以讓用戶選擇新的日期，並在選擇完成後透過 `onDateChanged` 回調通知 `EditProfileTableHandler`。

 `3. 更新日期顯示與資料模型：`
 
 - 當 `BirthdayDatePickerCell` 中的日期選擇器變更時，透過回調將新的日期傳回 `EditProfileTableHandler`。
 - `EditProfileTableHandler` 更新 `ProfileEditModel` 中的生日日期，並同步更新 `BirthdaySelectionCell` 上的日期標籤，確保用戶在視覺上能即時看到選擇的變化。

 `* Summary`
 
 - `BirthdayDatePickerCell` 和 `BirthdaySelectionCell` 之間的協作是為了提供一個直觀的生日選擇體驗。
 - `BirthdaySelectionCell` 顯示已選擇的生日，當用戶需要修改生日時，可以點擊展開 `BirthdayDatePickerCell`，然後通過選擇器進行日期修改。
 - `EditProfileTableHandler` 負責管理兩者之間的狀態切換和資料的同步更新。

 - `這樣的設計保持了單一職責原則`：
 
 - `BirthdaySelectionCell` 只負責展示已選擇的生日。
 - `BirthdayDatePickerCell` 只負責提供生日選擇器的界面和回調。
 - `EditProfileTableHandler` 則作為控制層，負責管理展開/收起行為以及資料更新。

 */


// MARK: - EditProfileTableHandler 的角色與設計

/**
 
 ## EditProfileTableHandler 的角色與設計

 `* What`

 - `EditProfileTableHandler` 是編輯個人資料頁面的表格邏輯處理器，負責管理表格的顯示與交互。主要功能如下：
 
 1. 配置每個欄位（如姓名、電話、地址、大頭照等）的單元格內容與交互行為。
 2. 與主控制器 `EditProfileViewController` 通過協定進行數據的雙向同步。
 3. 動態控制表格內容，例如根據用戶操作切換生日選擇器的顯示狀態。

 --------------------

 `* Why`

` 1. 將表格邏輯抽離至 EditProfileTableHandler，模組化設計，提升代碼清晰度。`
 
 - 職責分離：將表格的配置與交互邏輯與主控制器解耦，減少主控制器的複雜度。
 - 模組化代碼：每個欄位的處理邏輯封裝在對應的方法中，便於閱讀與維護。

 `2. 支援動態行為`
 
 - `isDatePickerVisible` 屬性控制生日選擇器是否顯示，支持用戶操作帶來的界面更新。
 - 動態改變表格的行數和內容，提升用戶體驗。

 `3. 降低耦合性`
 
 - 透過協定 (`EditProfileTableHandlerDelegate` 和 `PhotoChangeHandlerDelegate`)，將以下行為與主控制器分開：
 - 簡單欄位的數據同步（例如姓名、電話）。
 - 複雜交互（例如更改大頭照）的通知與處理。

 --------------------

 `* How`

 `1. 協定的應用`
 
 - `EditProfileTableHandlerDelegate`：通知主控制器更新模型數據，例如用戶編輯姓名或電話號碼後。
 - `PhotoChangeHandlerDelegate`：專門處理大頭照更改邏輯，通知主控制器觸發照片選取或上傳。

 - 範例：
 
 ```swift
 cell.onTextChanged = { [weak self] updatedText in
     guard let self = self, let updatedText = updatedText else { return }
     var updatedModel = model
     updatedModel.fullName = updatedText
     self.delegate?.updateProfileEditModel(updatedModel)
 }
 ```

 ---

 `2. 欄位配置方法`
 
 - `configureCell(for:indexPath:in:)` 方法根據表格區域和索引位置動態配置單元格：
 - 文字欄位：配置 `ProfileTextFieldCell`，支援即時文字更新。
 - 性別欄位：配置 `GenderSelectionCell`，支援性別切換。
 - 生日欄位：根據 `indexPath.row` 區分為選擇器顯示與日期選擇器。

 - 範例：生日選擇器邏輯
 
 ```swift
 if indexPath.row == 0 {
     // 配置 BirthdaySelectionCell
 } else {
     // 配置 BirthdayDatePickerCell，支援日期變更通知
     cell.onDateChanged = { [weak self] newDate in
         guard let self = self else { return }
         var updatedModel = model
         updatedModel.birthday = newDate
         self.delegate?.updateProfileEditModel(updatedModel)
     }
 }
 ```

 ---

 `3. 處理大頭照邏輯`
 
 - 透過 `photoDelegate`，通知主控制器進行大頭照相關處理，而非直接在表格處理器中進行：
 
 `1. 當用戶點擊大頭照的更改按鈕時，觸發以下回調：`
 
    ```swift
    cell.onChangePhotoButtonTapped = { [weak self] in
        self?.photoDelegate?.didTapChangePhoto()
    }
    ```
 
 `2. 主控制器響應此通知，執行照片選取或上傳邏輯。確保表格處理器僅專注於配置與交互邏輯。`

 ---

 `4. 動態行數與顯示控制`
 
 - `isDatePickerVisible` 控制生日選擇器的顯示，根據用戶點擊行為切換顯示狀態：
 
 ```swift
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     if indexPath.section == 5 && indexPath.row == 0 {
         isDatePickerVisible.toggle()
         tableView.beginUpdates()
         tableView.reloadSections(IndexSet(integer: 5), with: .automatic)
         tableView.endUpdates()
     }
 }
 ```

 --------------------

 `* 優勢總結`

 - `模組化`：將表格邏輯與主控制器分離，提升代碼的清晰度與可讀性。
 - `動態性`：支持用戶交互帶來的即時界面更新，例如顯示/隱藏生日選擇器。
 - `職責單一`：大頭照相關的複雜邏輯（例如圖片選取和上傳）交由主控制器處理，確保表格處理器的簡單性。
 - `可測試性`：每個欄位的處理邏輯分開實現，便於單元測試。
 
 */




import UIKit

/// `EditProfileTableHandler` 負責處理編輯個人資料頁面的表格邏輯。
///
/// ### 核心職責
/// 1. 配置表格每個欄位（如姓名、電話、地址、大頭照等）的顯示內容與交互邏輯。
/// 2. 與主控制器（`EditProfileViewController`）協作，實現數據的雙向傳遞。
///
/// ### 特點
/// - 通過協定（`EditProfileTableHandlerDelegate` 和 `PhotoChangeHandlerDelegate`）進行數據通信和事件傳遞，實現低耦合設計。
/// - 動態控制欄位的數量（例如生日日期選擇器的顯示與隱藏）。
///
/// ### 模組化優勢
/// - 將表格邏輯與主控制器分離，提升代碼的可讀性與可維護性。
/// - 允許針對每個欄位的配置進行獨立測試與調整。
class EditProfileTableHandler: NSObject {
    
    // MARK: - Properties
    
    /// 主控制器的數據協定，用於更新或獲取個人資料模型。
    weak var delegate: EditProfileTableHandlerDelegate?
    
    /// 處理照片更改行為的協定，用於通知主控制器。
    weak var photoDelegate: PhotoChangeHandlerDelegate?
    
    /// 控制生日日期選擇器的可見狀態。
    var isDatePickerVisible = false
    
    // MARK: - Initialization
    
    /// 初始化表格處理器
    /// - Parameters:
    ///   - delegate: 負責數據處理的協定。
    ///   - photoDelegate: 負責照片更改行為的協定。
    init(delegate: EditProfileTableHandlerDelegate, photoDelegate: PhotoChangeHandlerDelegate) {
        self.delegate = delegate
        self.photoDelegate = photoDelegate
    }
    
    // MARK: - Section Enum
    
    /// 定義表格的各個區域
    /// - 每個區域對應一種個人資料欄位（如大頭照、姓名、電話等）。
    enum Section: Int, CaseIterable {
        case profileImage, name, phoneNumber, address, gender, birthday
    }
    
    // MARK: - Cell Configuration Methods
    
    /// 配置表格的每個欄位
    /// - Parameters:
    ///   - indexPath: 表格的索引位置。
    ///   - tableView: 表格視圖。
    /// - Returns: 配置完成的單元格。
    private func configureCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard let profileEditModel = delegate?.getProfileEditModel(),
              let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .profileImage:
            return configureProfileImageCell(for: indexPath, in: tableView, model: profileEditModel)
        case .name:
            return configureTextFieldCell(for: indexPath, in: tableView, model: profileEditModel, fieldType: .name, text: profileEditModel.fullName)
        case .phoneNumber:
            return configureTextFieldCell(for: indexPath, in: tableView, model: profileEditModel, fieldType: .phoneNumber, text: profileEditModel.phoneNumber)
        case .address:
            return configureTextFieldCell(for: indexPath, in: tableView, model: profileEditModel, fieldType: .address, text: profileEditModel.address)
        case .gender:
            return configureGenderCell(for: indexPath, in: tableView, model: profileEditModel)
        case .birthday:
            return configureBirthdayCell(for: indexPath, in: tableView, model: profileEditModel)
        }
    }
    
    // MARK: - Private Cell Configuration
    
    /// 配置大頭照欄位的 Cell
    /// - Parameters:
    ///   - indexPath: 表格的索引位置。
    ///   - tableView: 表格視圖。
    ///   - model: 用於配置的資料模型。
    /// - Returns: 配置完成的單元格。
    private func configureProfileImageCell(for indexPath: IndexPath, in tableView: UITableView, model: ProfileEditModel) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileImageViewCell.reuseIdentifier, for: indexPath) as? ProfileImageViewCell else {
            fatalError("Cannot create ProfileImageViewCell")
        }
        cell.updateProfileImageFromURL(with: model.profileImageURL)
        cell.onChangePhotoButtonTapped = { [weak self] in
            self?.photoDelegate?.didTapChangePhoto()
        }
        return cell
    }
    
    /// 配置文字欄位的 Cell（例如姓名、電話、地址）
    /// - Parameters:
    ///   - indexPath: 表格的索引位置。
    ///   - tableView: 表格視圖。
    ///   - model: 用於配置的資料模型。
    ///   - fieldType: 欄位類型（例如姓名或電話）。
    ///   - text: 預設文字。
    /// - Returns: 配置完成的單元格。
    private func configureTextFieldCell(for indexPath: IndexPath, in tableView: UITableView, model: ProfileEditModel, fieldType: EditProfileTextField.FieldType, text: String?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTextFieldCell.reuseIdentifier, for: indexPath) as? ProfileTextFieldCell else {
            fatalError("Cannot create ProfileTextFieldCell")
        }
        cell.configure(fieldType: fieldType, text: text)
        cell.onTextChanged = { [weak self] updatedText in
            guard let self = self, let updatedText = updatedText else { return }
            var updatedModel = model
            switch fieldType {
            case .name:
                updatedModel.fullName = updatedText
            case .phoneNumber:
                updatedModel.phoneNumber = updatedText
            case .address:
                updatedModel.address = updatedText
            case .none:
                fatalError("FieldType .none should not be used in configureTextFieldCell")
            }
            self.delegate?.updateProfileEditModel(updatedModel)
        }
        return cell
    }
    
    /// 配置性別欄位的 Cell
    /// - Parameters:
    ///   - indexPath: 表格的索引位置。
    ///   - tableView: 表格視圖。
    ///   - model: 用於配置的資料模型。
    /// - Returns: 配置完成的單元格。
    private func configureGenderCell(for indexPath: IndexPath, in tableView: UITableView, model: ProfileEditModel) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GenderSelectionCell.reuseIdentifier, for: indexPath) as? GenderSelectionCell else {
            fatalError("Cannot create GenderSelectionCell")
        }
        cell.configure(withGender: model.gender)
        cell.onGenderChanged = { [weak self] updatedGender in
            guard let self = self else { return }
            var updatedModel = model
            updatedModel.gender = updatedGender
            self.delegate?.updateProfileEditModel(updatedModel)
        }
        return cell
    }
    
    /// 配置生日欄位的 Cell
    /// - Parameters:
    ///   - indexPath: 表格的索引位置。
    ///   - tableView: 表格視圖。
    ///   - model: 用於配置的資料模型。
    /// - Returns: 配置完成的單元格。
    private func configureBirthdayCell(for indexPath: IndexPath, in tableView: UITableView, model: ProfileEditModel) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BirthdaySelectionCell.reuseIdentifier, for: indexPath) as? BirthdaySelectionCell else {
                fatalError("Cannot create BirthdaySelectionCell")
            }
            cell.configure(with: model.birthday)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BirthdayDatePickerCell.reuseIdentifier, for: indexPath) as? BirthdayDatePickerCell else {
                fatalError("Cannot create BirthdayDatePickerCell")
            }
            cell.configure(with: model.birthday)
            cell.onDateChanged = { [weak self] newDate in
                guard let self = self, let birthdayCell = tableView.cellForRow(at: IndexPath(row: 0, section: Section.birthday.rawValue)) as? BirthdaySelectionCell else { return }
                var updatedModel = model
                updatedModel.birthday = newDate
                self.delegate?.updateProfileEditModel(updatedModel)
                birthdayCell.configure(with: newDate)
            }
            return cell
        }
    }

}

// MARK: - UITableViewDataSource
extension EditProfileTableHandler: UITableViewDataSource {
    
    /// 返回表格的區域數量
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    /// 返回指定區域中的行數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 5 && isDatePickerVisible ? 2 : 1
    }
    
    /// 返回指定位置的單元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(for: indexPath, in: tableView)
    }
    
    // MARK: - Section Headers
    
    /// 返回區域的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .profileImage: return nil
        case .name: return "Name"
        case .phoneNumber: return "Phone Number"
        case .address: return "Address"
        case .gender: return "Gender"
        case .birthday: return "Birthday"
        default: return nil
        }
    }
    
}

// MARK: - UITableViewDelegate
extension EditProfileTableHandler: UITableViewDelegate {
    
    /// 當用戶點擊某行時觸發的行為
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 5 && indexPath.row == 0 {
            isDatePickerVisible.toggle()
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: 5), with: .automatic)
            tableView.endUpdates()
        }
    }
    
}
