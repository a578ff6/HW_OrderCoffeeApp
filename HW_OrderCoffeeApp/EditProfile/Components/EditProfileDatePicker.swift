//
//  EditProfileDatePicker.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/5.
//

// MARK: - 筆記：EditProfileDatePicker
/**
 
 ## 筆記：EditProfileDatePicker
 
 `* What`
 
 `1.功能定位：`

 - `EditProfileDatePicker` 是個人資料編輯中用於選擇日期的自定義元件，基於 `UIDatePicker` 進行擴展。
 - 提供統一的配置，適用於需要限制日期範圍（如生日）的場景。
 
 `2.預設行為：`

 - `模式設定`： 預設為 .date 模式，僅顯示日期，不包括時間。
 - `樣式設置`： 使用 .wheels（輪式選擇器）提升用戶體驗，尤其在表單中操作方便。
 - `日期限制`： 最大日期為當天，避免選擇未來日期。
 
 `3.設計範圍：`

 - 適用於個人資料編輯的場景（如生日選擇），也可擴展至其他日期相關的欄位。
 
 -----------
 
 `* Why`
 
 `1.減少重複代碼：`

 - 在多個表單中重複設置 `UIDatePicker` 的屬性會增加代碼複雜度。封裝一個通用元件可重用設置邏輯。
 
 `2.提升一致性：`

 - 通過統一配置，確保所有日期選擇器的樣式、限制條件一致，提升用戶體驗。
 
 `3.避免未來日期選擇錯誤：`

 - 在個人資料編輯中，日期欄位如生日或過去事件不應允許未來日期選擇，提前限制可以減少後端驗證壓力。
 
 `4.適應表單設計需求：`

 - 使用 .`wheels` 样式更適合移動端表單，提供清晰的選擇體驗。
 
 -----------

 `* How`
 
 `1.配置必要屬性以滿足表單需求：`
 
 - datePickerMode = .date: 僅選擇日期。
 - preferredDatePickerStyle = .wheels: 顯示為輪式選擇器。
 - maximumDate = Date(): 限制最大日期為當天。
 */



import UIKit

/// 自訂的 UIDatePicker，用於個人資料編輯中處理日期選擇的通用設置。
/// - 提供預設樣式與限制，適用於生日或其他日期類型的字段。
/// - 預設為輪式選擇器（`.wheels`），限制最大日期為當天，避免未來日期選擇。
class EditProfileDatePicker: UIDatePicker {
    
    // MARK: - Initializer
    
    /// 初始化方法，設置日期選擇器的預設行為。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDatePicker()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Method
    
    /// 設置日期選擇器的屬性。
    /// - 包括日期模式、顯示樣式、最大日期及自動佈局設置。
    private func setupDatePicker() {
        datePickerMode = .date
        preferredDatePickerStyle = .wheels
        maximumDate = Date() // 最大日期為今天，避免選擇未來的日期
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
