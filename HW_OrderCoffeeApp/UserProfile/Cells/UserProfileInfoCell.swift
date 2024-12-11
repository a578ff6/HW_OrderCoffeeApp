//
//  UserProfileHeaderCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/29.
//

// MARK: - 筆記：UserProfileInfoCell 的設計理念與實現
/**
 
 ## 筆記：UserProfileInfoCell 的設計理念與實現
 
 `* What`

 1.`UserProfileInfoCell` 是一個自訂 `UITableViewCell`，專為顯示用戶的頭像、名稱與 Email 設計。
 
 2.此 Cell 包含以下元件：
 
 - `用戶頭像`（支持動態加載）。
 - `名稱與 Email`（通過垂直 StackView 排列）。
 - `水平 StackView 將頭像與文字區域整合。`
 
 --------------------------
 
` * Why`

` 1.單一責任：`

 - Cell 負責 UI 的顯示與基本配置。
 - 數據來源由 `TableHandler` 提供，避免職責混淆。
 
 `3.模組化：`

 - 使用 StackView 組織布局，易於調整結構與樣式。
 - 頭像、名稱與 Email 可單獨配置，增強靈活性。
 
 `4.可讀性與重用性：`

 - 將佈局邏輯集中於 setupLayout，點擊樣式與指示器設置於 `configureSelectionAndAccessoryType`，清晰分工。
 
 --------------------------

 `* How`

 `1.元件設置：`

 - 頭像預設為 SF Symbol，並支持從 URL 加載。
 - 標籤提供預設文字，避免在內容未加載時出現空白。
 
` 2.點擊樣式與指示器：`

 - 透過 `configureSelectionAndAccessoryType` 集中管理：
 - selectionStyle = .none：禁用點擊效果。
 - accessoryType = .none：移除右側附加指示器。
 - 此設置是視圖層面的樣式，適合直接在 Cell 中配置。
 
 `3.動態更新：`

 - `setUserInfo` 用於動態更新名稱與 Email。
 - `setProfileImageFromURL` 提供靈活的頭像加載。
 
 `4.最佳實踐：`

 - 在 `prepareForReuse` 中重置內容，避免 Cell 重用時出現殘留數據。
 
 --------------------------

 `* 關於 selectionStyle 和 accessoryType`
 
 1.設置位置：

 - `selectionStyle` 和 `accessoryType` 屬於視圖層的樣式配置，直接設置於 Cell 是合理的。
 - 這些屬性與數據無關，符合 Cell 的職責範圍。
 */


// MARK: - 重點筆記：UserProfileInfoCell 預設圖片設置的設計理念
/**
 
 ## 重點筆記：UserProfileInfoCell 預設圖片設置的設計理念
 
` * What`
 
 1. 在 `UserProfileInfoCell` 中，使用 SF Symbol "`person.circle`" 作為用戶頭像的預設圖片。
 
 2. `person.circle `它們出現在不同的生命週期階段：

 - 初始化時需要一個預設值。
 - URL 無效時提供回退值。
 - Cell 重用時清空內容。
 - 它在不同情境中有不同的用途，具備實際需求。
 
 ---------------
 
 `* Why`
 
 `1.一致性：`

 - 確保在無法獲取圖片時，頭像顯示一致的預設樣式。
 
 `2.回退機制：`

 - `URL` 無效或下載失敗時提供回退圖片，避免視覺元素缺失。
 
 `3.提升體驗：`

 - 預設圖片能讓用戶在圖片尚未加載時，仍有清晰的頭像標記。
 
 ---------------

 `* How`
 
 `1.設置方式：`

 - 初始化 `profileImageView` 時設置。
 - 在 `setProfileImageFromURL` 方法中，提供 URL 無效時的回退值。
 - 在 `prepareForReuse` 中，重設為預設圖片。
 */


// MARK: - (v)

import UIKit

/// 用於顯示用戶大頭照、姓名、Email 的自訂 UITableViewCell
///
/// 此 Cell 提供用戶頭像、姓名標籤及 Email 標籤，並透過垂直與水平的 StackView 組織佈局
///
/// - 頭像預設為 SF Symbol（`person.circle`），當有圖片 URL 時支援動態加載。
/// - 提供方法設定用戶名稱與 Email，適合動態更新內容。
///
/// 功能特色：
/// - 使用垂直 StackView 排列用戶名稱與 Email，並通過水平 StackView 將頭像與文字區域整合。
/// - 預設禁用點擊效果（`selectionStyle`）及附加指示器（`accessoryType`）。
class UserProfileInfoCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "UserProfileInfoCell"
    
    // MARK: - UI Elements
    
    /// 用戶頭像視圖
    private let profileImageView = UserProfileImageView(defaultImage: UIImage(systemName: "person.circle"), cornerRadius: 35, backgroundColor: .white, contentMode: .scaleAspectFill)
    
    /// 用戶姓名標籤
    private let nameLabel = UserProfileLabel(font: .systemFont(ofSize: 20, weight: .medium), textColor: .black, text: "Loading Name...")

    /// 用戶 Email 標籤
    private let emailLabel = UserProfileLabel(font: .systemFont(ofSize: 14, weight: .regular), textColor: .gray, text: "Loading Email...")
    
    /// 用於垂直排列姓名與 Email 的 StackView
    private let nameAndEmailStackView = UserProfileStackView(axis: .vertical, spacing: 10, alignment: .leading, distribution: .fill)
    
    /// 用於水平排列頭像與姓名-Email 組合的主 StackView
    private let mainStackView = UserProfileStackView(axis: .horizontal, spacing: 20, alignment: .center, distribution: .fill)
    
    
    // MARK: - Initializer
    
    /// 使用程式碼初始化 Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        configureSelectionAndAccessoryType()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置佈局與約束條件
    private func setupLayout() {
        // 組合 name 和 email 到垂直 StackView
        nameAndEmailStackView.addArrangedSubview(nameLabel)
        nameAndEmailStackView.addArrangedSubview(emailLabel)
        
        // 組合 profileImageView 和 nameAndEmailStackView 到主 StackView
        mainStackView.addArrangedSubview(profileImageView)
        mainStackView.addArrangedSubview(nameAndEmailStackView)
        
        // 將主 StackView 添加到 contentView
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor)
        ])
    }
    
    /// 配置點擊樣式與附加指示器
    private func configureSelectionAndAccessoryType() {
        selectionStyle = .none
        accessoryType = .none
    }
    
    // MARK: - Configuration Methods
    
    /// 設定用戶名稱與 Email
    ///
    /// - Parameters:
    ///   - name: 用戶名稱
    ///   - email: 用戶 Email
    func setUserInfo(name: String, email: String) {
        nameLabel.text = name
        emailLabel.text = email
    }
    
    /// 設定頭像圖片 URL
    ///
    /// - Parameter url: 用戶頭像圖片的 URL 字串，若為空則顯示預設圖片。
    func setProfileImageFromURL(_ url: String?) {
        guard let url = url, let validURL = URL(string: url) else {
            profileImageView.image = UIImage(systemName: "person.circle")
            return
        }
        profileImageView.kf.setImage(with: validURL, placeholder: UIImage(systemName: "person.circle"))
    }
    
    // MARK: - Lifecycle Methods
    
    /// 在 Cell 重用前清空內容
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(systemName: "person.circle")
        nameLabel.text = nil
        emailLabel.text = nil
    }
    
}
