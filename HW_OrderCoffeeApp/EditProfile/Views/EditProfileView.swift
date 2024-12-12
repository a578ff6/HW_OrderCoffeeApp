//
//  EditProfileView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/24.
//

// MARK: - 筆記：EditProfileView
/**
 
 ## 筆記：EditProfileView
 
 `* What`
 
 - EditProfileView 是用於管理編輯個人資料頁面的主要視圖，包含了一個 TableView (editProfileTableView) 作為核心元件，用於顯示個人資料的各種項目（例如大頭照、文字輸入欄位、性別選擇、生日日期選擇等）。

 ------------------------------
 
 `* Why`
 
 `1.分離視圖與控制器職責：`
 
 - 將 `TableView` 的設置和管理（包括佈局與 Cell 註冊）封裝在 `EditProfileView` 中，讓 `EditProfileViewController` 不需處理過多的視圖邏輯，專注於業務流程與互動。
 
 `2.提高重用性與維護性：`
 
 - 通過封裝與清晰的 API（例如 `getTableView`），可以更方便地修改視圖內部邏輯，而不影響外部控制器。
 
 `3.保持代碼結構清晰：`
 
 - 集中處理佈局與 Cell 註冊邏輯，避免散落於多處，提升可讀性。
 
 ------------------------------

 `* How`
 
 `1.視圖初始化與佈局：`

 - `setupLayout` 方法確保 `editProfileTableView` 填滿整個主視圖，且遵守 Auto Layout 規則。
 - 使用 `NSLayoutConstraint` 創建必要的佈局約束，保持視圖結構穩定。
 
 `2.Cell 註冊：`

 - 在 `registerCells` 方法中，為 `editProfileTableView` 註冊所有自定義的 `UITableViewCell` 類型。
 - 每個 Cell 使用唯一的 reuseIdentifier，確保 TableView 能夠正確重用。
 
 `3.對外接口：`

 - `getTableView` 方法提供 `TableView` 的訪問權限，讓控制器或其他邏輯可以操作 `TableView`（如設置數據源與代理、刷新數據等）。
 
 ------------------------------
 
 `* 設計優化補充`
 
 `1.為什麼將 registerCells 獨立為方法？`

 - 確保所有的 Cell 註冊邏輯集中管理，避免註冊遺漏或分散。
 - 方便未來擴充新功能，例如新增類型的 Cell 時，只需在 registerCells 中添加註冊邏輯。
 
 `2.為什麼使用 getTableView 而不直接公開 editProfileTableView？`

 - 封裝內部細節，僅暴露必要接口。
 - 提升元件的可維護性，避免外部直接操作內部屬性造成潛在問題。
 
 */



import UIKit

/// 編輯個人資料的主視圖，包含個人資料的 TableView
class EditProfileView: UIView {

    // MARK: - UI Elements
    
    /// 顯示用戶個人資料的 TableView
     private(set) var editProfileTableView = EditProfileTableView()

    // MARK: - Initializers

    /// 初始化方法，設置佈局
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        registerCells()        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods

    /// 設置 TableView 的佈局，確保其填滿整個視圖。
    private func setupLayout() {
        addSubview(editProfileTableView)
        NSLayoutConstraint.activate([
            editProfileTableView.topAnchor.constraint(equalTo: topAnchor),
            editProfileTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            editProfileTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            editProfileTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊 TableView 所需的自定義 Cells。
    /// - 使用唯一的 `reuseIdentifier`，確保 TableView 正確重用。
    /// - 註冊的 Cells 包括：
    ///   - `ProfileImageViewCell`：用於顯示用戶大頭照。
    ///   - `ProfileTextFieldCell`：用於顯示用戶可編輯文字欄位。
    ///   - `GenderSelectionCell`：用於顯示性別選擇按鈕。
    ///   - `BirthdaySelectionCell`：用於顯示生日選擇欄位。
    ///   - `BirthdayDatePickerCell`：用於顯示生日日期選擇器。
    private func registerCells() {
        editProfileTableView.register(ProfileImageViewCell.self, forCellReuseIdentifier: ProfileImageViewCell.reuseIdentifier)
        editProfileTableView.register(ProfileTextFieldCell.self, forCellReuseIdentifier: ProfileTextFieldCell.reuseIdentifier)
        editProfileTableView.register(GenderSelectionCell.self, forCellReuseIdentifier: GenderSelectionCell.reuseIdentifier)
        editProfileTableView.register(BirthdaySelectionCell.self, forCellReuseIdentifier: BirthdaySelectionCell.reuseIdentifier)
        editProfileTableView.register(BirthdayDatePickerCell.self, forCellReuseIdentifier: BirthdayDatePickerCell.reuseIdentifier)
    }
    
}
