//
//  EditProfileTableView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/4.
//

// MARK: - EditProfileTableView 筆記
/**
 
 ## EditProfileTableView 筆記
 
 `* What`
 
 - `EditProfileTableView` 是一個專門為「編輯個人資料」頁面設計的自訂義 `UITableView`。
  - 此 TableView 負責顯示用戶的基本資訊（例如姓名、性別、生日等欄位），並支援相應的編輯操作。
  - 承載自訂義的多種類型 Cell，例如 `ProfileImageViewCell`、`ProfileTextFieldCell`、`GenderSelectionCell` 和 `BirthdaySelectionCell`。
 
 ---------------------------
 
 `* Why`

 - `分離視圖邏輯`：將表單部分獨立到 `EditProfileTableView`，使 `EditProfileViewController` 更專注於業務邏輯與用戶行為。
 - `提升可讀性`：集中處理與表單視圖相關的細節，減少控制器中的視圖配置程式碼，增加程式碼的清晰性。
 - `易於維護`：未來若需更新表單的外觀或行為，只需修改 `EditProfileTableView`，避免影響控制器或其他邏輯。
 
 ---------------------------

 `* How`
 
 `1.設計初始化方法：`

 - 在 `init()` 方法中進行 TableView 的初始化設置，包括設定背景色與分隔線樣式。
 - 使用 `.insetGrouped` 樣式來更適合表單的結構化顯示需求。
 
 `2.分離責任：`
 
 - 透過 `setupTableView()` 方法專注於 TableView 的基本屬性配置（如顏色、分隔線樣式）。
  - Cell 的註冊邏輯可選擇保留在 `registerCells()` 或交由 `EditProfileView` 處理，視需求靈活調整。
 
 `3.增強可維護性：`

 - 將視圖的配置邏輯分離到 `EditProfileTableView` 中，使得 `EditProfileViewController` 可以專注於控制邏輯，從而達到更好的分工。
 - 若將來需要修改表單的外觀或行為，可以在 `EditProfileTableView` 內進行修改，而不必影響到控制器的其他邏輯。
 */


// MARK: - UITableView 自動計算高度的筆記
/**
 
 ## UITableView 自動計算高度的筆記
 
 `* 原本硬編碼：`
 
 - 可讀性也不好，過於繁雜。
 
 ```
 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     if indexPath.section == 0 {
         return 220 // 設置為能夠容納圖片和按鈕的高度
     } else if indexPath.section == 4 && indexPath.row == 1 {
         return 216
     }
     return 60
 }
 ```

 ------------------

 `* What`

 - `UITableView` 提供 `automaticDimension` 功能來自動計算每個 Cell 的高度，透過以下設定即可啟用：
 - 這讓 TableView 根據 Cell 的內容自動調整高度，而不需手動指定固定值。
 
 ```swift
 editProfileTableView.rowHeight = UITableView.automaticDimension
 editProfileTableView.estimatedRowHeight = 60
 ```

 ------------------

 `* Why`

 - 使用 `automaticDimension` 的好處包括：

 1. `動態高度`：適應不同內容大小的 Cell（例如文字長短不一、圖片大小不同）。
 2. `減少硬編碼`：不需為每種類型的 Cell 人工計算高度。
 3. `簡化維護`：內容變化時，不需同步更新高度邏輯。

 - 但是，當自動計算高度時，如果 Cell 中的內容視圖約束不明確，可能會導致以下問題：

 1.`高度為零或不正確`：系統無法推斷正確高度，會出現警告。
 2.性`能問題`：無法有效計算高度，可能增加運行成本。

 ------------------

 `* How`

 `1. 確保內容具有完整的垂直方向約束`

 - 每個 Cell 的內容必須有明確的 `top` 和 `bottom` 約束，確保系統能正確推算內容高度。例如：

 ```swift
 NSLayoutConstraint.activate([
     titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
     titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
     titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

     detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
     detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
     detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
     detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
 ])
 ```

 `2. 動態內容控件的設定`

 - 動態內容如 `UILabel` 和 `UITextView`，需正確設置相關屬性以支援內容變化：

 - `UILabel`：
   ```swift
   label.numberOfLines = 0
   label.lineBreakMode = .byWordWrapping
   ```
 - `UITextView`：確保可以正確計算其 `intrinsicContentSize`。

 `3. 減少不必要的固定高度`

 - 避免對 `UITableViewCell` 的內容或 `contentView` 設置固定高度，除非視圖內的某些元素有固定尺寸需求。例如：

 ```swift
 imageView.heightAnchor.constraint(equalToConstant: 100)
 ```

 `4. 測試不同的內容情境`

 - 測試內容為空、短文字、長文字、多行文字的情境，並使用 Xcode Layout Debugger 確保布局正常：
 - 背景測試：為 Cell 設定不同背景顏色，檢查視圖是否完全填滿。
 - 布局檢查：查看約束是否覆蓋了所有方向。

 ------------------

 `* 總結`

 當使用 `UITableView.automaticDimension` 時：

 - 確保所有內容視圖有明確的垂直方向約束（`top` 和 `bottom`）。
 - 動態控件（如 `UILabel`）需支援多行及內容自適應。
 - 測試不同內容下的顯示效果。
 - 這樣可以有效利用自動計算高度功能，實現動態而靈活的表格布局。
 */



import UIKit

/// 自訂義的 EditProfileTableView，負責顯示 EditProfile 頁面的表單
/// - 這個 TableView 用於顯示用戶的基本資訊（例如姓名、性別、生日等），並支持相應的編輯操作
class EditProfileTableView: UITableView {
    
    // MARK: - Initializer
    
    /// 初始化方法，設置表格的樣式和基本屬性
    init() {
        super.init(frame: .zero, style: .insetGrouped)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設定 TableView 的初始配置
    /// - 設定表格的背景色、分隔線樣式以及自適應約束等基本配置
    private func setupTableView() {
        translatesAutoresizingMaskIntoConstraints = false
        separatorStyle = .none
//        backgroundColor = .lightWhiteGray
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 60
    }
    
}
