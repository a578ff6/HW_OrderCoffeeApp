//
//  UserProfileView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/14.
//


// MARK: - 重點筆記：UserProfileView 的設計理念與實現
/**
 
 ## 重點筆記：UserProfileView 的設計理念與實現
 
 `* What`
 
 1.定義： UserProfileView 是專為個人資訊頁面設計的自訂視圖，封裝 UITableView 及其相關配置。

 2.功能：

 - 提供 UITableView，用於顯示使用者個人資訊與選項。
 - 管理 UITableView 的佈局與 Cell 註冊，確保結構清晰。
 - 外部只需訪問 tableView 屬性，即可操作表格，避免暴露內部細節。
 
 -------------
 
 `* Why`
 
 `1.提高模組化：`

 - 分離佈局邏輯，減少 ViewController 的負擔，提升程式碼可讀性與可維護性。
 
 `2.封裝性：`

 - 隱藏 UITableView 的實現細節，僅暴露必要的訪問介面，確保內部邏輯不被外部干擾。
 
 `3.降低耦合性：`

 - 將 Cell 註冊與佈局配置集中在 View 中，ViewController 僅需專注於業務邏輯與互動。
 
 `4.擴展性：`

 - 易於新增或修改 Cell，僅需在 registerCells 方法中調整，而無需更改其他程式碼。
 
 -------------

 `* How`
 
 `1.封裝 UITableView：`

 - 使用私有變數 userProfileTableView 來管理表格，避免外部直接操作。
 
 `2.佈局與約束：`

 - 使用 setupLayout 方法，通過 Auto Layout 設定表格充滿整個視圖。
 
 `3.Cell 註冊：`

 - 提供 registerCells 方法，統一註冊所有使用的自訂 Cell，確保程式碼集中管理。
 
 -------------

 `* 補充說明`
 
 `1.只讀屬性 tableView：`

 - 提供一個安全的訪問方式，允許外部使用 UITableView，但無法修改內部實現。
 
 `2.擴展性：`

 - 若需新增更多自訂 Cell，只需在 registerCells 方法中新增註冊程式碼。
 - 可引入動態配置方法，根據不同頁面需求，靈活設定需要註冊的 Cell。
 
 `4.實踐：`

 - 將 UserProfileView 作為 ViewController 的主視圖，避免在 ViewController 中直接操作其他 UI 元素，確保單一責任原則。
 */


// MARK: - (v)

import UIKit

/// 用於個人資訊頁面佈局的自訂視圖
///
/// 此視圖專為個人資料頁面設計，提供 `UITableView` 用於顯示使用者資訊、選項及操作功能。
///
/// 功能特色：
/// - 封裝 `UITableView`，統一管理佈局與 Cell 的註冊，減少 ViewController 的負擔。
/// - 提供 `tableView` 的只讀訪問屬性，允許外部存取 `UITableView` 而不直接暴露內部實現。
///
/// 使用場景：
/// - 配合 `UserProfileViewController`，顯示使用者個人資訊頁面，包括姓名、Email、其他選項（如編輯、我的最愛）及登出功能。
class UserProfileView: UIView {
    
    // MARK: - UI Elements
    
    /// 私有的 `UITableView` 實例，用於顯示個人資訊內容與操作選項
    private let userProfileTableView = UserProfileTableView()
    
    /// 對外暴露的只讀屬性，允許外部存取 `UITableView`，避免直接操作內部實現
    var tableView: UITableView {
        return userProfileTableView
    }
    
    // MARK: - Initializers
    
    /// 初始化視圖，設置佈局與註冊 Cell
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        registerCells()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    
    /// 配置 `TableView` 的佈局與約束條件
    ///
    /// - 說明：讓 `UITableView` 貼合父視圖，覆蓋整個頁面。
    private func setupLayout() {
        addSubview(userProfileTableView)
        
        NSLayoutConstraint.activate([
            userProfileTableView.topAnchor.constraint(equalTo: topAnchor),
            userProfileTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userProfileTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userProfileTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Cell Registration
    
    /// 註冊個人資料頁面的所有自定義 TableView Cell
    ///
    /// - 包括：
    ///   - `UserProfileInfoCell`：顯示個人資訊（姓名、Email、大頭照）
    ///   - `UserProfileGeneralOptionCell`：顯示一般選項（如編輯個人資料）
    ///   - `UserProfileSocialLinkCell`：顯示社交媒體連結
    ///   - `UserProfileLogoutCell`：顯示登出按鈕
    private func registerCells() {
        userProfileTableView.register(UserProfileInfoCell.self, forCellReuseIdentifier: UserProfileInfoCell.reuseIdentifier)
        userProfileTableView.register(UserProfileGeneralOptionCell.self, forCellReuseIdentifier: UserProfileGeneralOptionCell.reuseIdentifier)
        userProfileTableView.register(UserProfileSocialLinkCell.self, forCellReuseIdentifier: UserProfileSocialLinkCell.reuseIdentifier)
        userProfileTableView.register(UserProfileLogoutCell.self, forCellReuseIdentifier: UserProfileLogoutCell.reuseIdentifier)
    }
    
}
