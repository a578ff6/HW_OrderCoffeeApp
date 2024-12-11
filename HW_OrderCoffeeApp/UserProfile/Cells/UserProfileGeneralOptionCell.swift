//
//  UserProfileGeneralOptionCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/29.
//

// MARK: -  重點筆記：UserProfileGeneralOptionCell 的設計與實現
/**
 
 ## 重點筆記：UserProfileGeneralOptionCell 的設計與實現
 
` * What`
 
 - 定義：
 
 - `UserProfileGeneralOptionCell` 是一個自訂的 `UITableViewCell`，專為個人資料頁面的選項行設計。
 
 - 功能：
 
 1.顯示選項圖標、標題與副標題。
 2.支援動態內容配置。
 3.提供點擊效果與附加指示器。
 
 -------------------
 
 `* Why`
 
 `1.模組化設計：`
 
 - 將常見的選項行設計抽象化，提升重用性與維護性。
 
 `2.清晰的層級結構：`
 
 - 透過 StackView 組織 UI 元素，確保易於理解與擴展。
 
 `3.提升用戶體驗：`
 
 - 設置 `selectionStyle` 與 `accessoryType`，提供即時的點擊回饋與導航提示。
 
 -------------------

 `* How`
 
 `1.結構設計：`

 - 使用兩層 StackView 組織圖標與文字內容，確保佈局整潔且符合視覺設計需求。
 
 `2.動態內容配置：`

 - 提供 `configure` 方法動態設置圖標、標題與副標題。
 */

// MARK: - (v)


import UIKit

/// 用於顯示一般選項的自訂 UITableViewCell
///
/// 此 Cell 用於顯示個人資料頁面中的一般選項，例如編輯個人資料、歷史訂單與我的最愛。
/// 提供圖標、標題、副標題，並以垂直與水平的 StackView 組織佈局。
///
/// 功能特色：
/// - 圖標使用 SF Symbols，支援自訂大小與色彩。
/// - 標題與副標題分別提供主要資訊與輔助描述。
/// - 配置點擊效果（`selectionStyle`）與附加指示器（`accessoryType`）。
///
/// 使用場景：適用於個人資料頁面的通用選項行。
class UserProfileGeneralOptionCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "UserProfileGeneralOptionCell"
    
    // MARK: - UI Elements
    
    /// 選項圖標
    private let iconImageView = UserProfileIconImageView(size: 28, tintColor: .black)
    
    /// 選項標題
    private let titleLabel = UserProfileLabel(font: UIFont.systemFont(ofSize: 14, weight: .regular), textColor: .black)
    
    /// 選項副標題
    private let subtitleLabel = UserProfileLabel(font: UIFont.systemFont(ofSize: 12, weight: .medium), textColor: .lightGray)
    
    /// 排列標題與副標題的垂直 StackView
    private let textStackView = UserProfileStackView(axis: .vertical, spacing: 4, alignment: .leading, distribution: .fill)
    
    /// 排列圖標與文字區域的主 StackView
    private let mainStackView = UserProfileStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
    
    // MARK: - Initializer
    
    /// 初始化 Cell 並設置佈局
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
        // 添加 titleLabel 和 subtitleLabel 到 textStackView
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        
        // 添加 iconImageView 和 textStackView 到 mainStackView
        mainStackView.addArrangedSubview(iconImageView)
        mainStackView.addArrangedSubview(textStackView)
        
        // 添加 mainStackView 到 contentView
        contentView.addSubview(mainStackView)
        
        // 設置約束
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    /// 配置點擊樣式與附加指示器
    private func configureSelectionAndAccessoryType() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator
    }
    
    // MARK: - Configuration Method
    
    /// 配置 Cell 的內容
    ///
    /// - Parameters:
    ///   - icon: SF Symbol 名稱，用於設置圖標。
    ///   - title: 主標題文字。
    ///   - subtitle: 副標題文字，預設為空。
    ///   - tintColor: 圖標的顏色，預設為黑色。
    func configure(icon: String, title: String, subtitle: String?, tintColor: UIColor = .darkGray) {
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = tintColor
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    // MARK: - Lifecycle Methods
    
    /// 在 Cell 重用前清空內容
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
}
