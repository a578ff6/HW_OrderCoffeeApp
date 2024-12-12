//
//  UserProfileSocialLinkCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/10.
//

// MARK: -  重點筆記：UserProfileSocialLinkCell 的設計與實現
/**
 
 ## 重點筆記：UserProfileSocialLinkCell 的設計與實現
 
 `* What`
 
 1.定義：`UserProfileSocialLinkCell` 是一個自訂的 UITableViewCell，專為顯示社交媒體連結設計。
 
 2.功能：
 
 - 顯示社交媒體的圖標、標題與副標題。
 - 支援點擊效果，適合交互操作。
 - 圖標使用 Assets 資源，標題與副標題可動態配置。
 
 -----------------
 
 `* Why`
 
 1.模組化設計：

 - 將社交媒體相關行項目抽象化，提升重用性與維護性。
 
 2.清晰的結構：

 - 使用兩層 StackView 組織 UI 元素，確保佈局整潔且符合設計需求。
 
 3.提升用戶體驗：

 - 提供點擊效果（selectionStyle）和清晰的層次結構，支援快速交互行為。
 
 -----------------

 `* How`
 
 1.結構設計：

 - 使用水平 StackView 組織圖標與文字內容，垂直 StackView 組織主標題與副標題，確保可讀性與擴展性。
 
 2.動態配置：

 - 提供 configure 方法，用於設置圖標、標題與副標題。
 
 3.優化重用：

 - 在 prepareForReuse 方法中清空所有內容，確保重用時不會出現殘留數據。
 */


// MARK: - (v)

import UIKit

/// 用於顯示社交媒體連結的自訂 UITableViewCell
///
/// 此 Cell 用於個人資料頁面中的社交媒體區域，每行包含圖標、標題與副標題，
/// 並透過垂直與水平的 StackView 組織佈局。
///
/// 功能特色：
/// - 圖標使用 `Assets` 中的圖片資源，支援動態設置與清空。
/// - 主標題顯示社交媒體名稱，副標題顯示相關描述。
/// - 預設啟用點擊效果（`selectionStyle`）以支持交互行為。
///
/// 使用場景：適用於個人資料頁面的社交媒體連結行。
class UserProfileSocialLinkCell: UITableViewCell {
    
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "UserProfileSocialLinkCell"
    
    // MARK: - UI Elements
    
    /// 社交媒體圖標
    private let iconImageView = UserProfileIconImageView(size: 28)
    
    /// 社交媒體標題
    private let titleLabel = UserProfileLabel(font: UIFont.systemFont(ofSize: 14, weight: .regular), textColor: .black)
    
    /// 社交媒體副標題
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
    
    // MARK: - Layout Setup
    
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
    
    /// 配置點擊樣式與指示器
    private func configureSelectionAndAccessoryType() {
        selectionStyle = .default
        accessoryType = .none
    }
    
    // MARK: - Configuration Method
    
    /// 配置 Cell 的顯示內容
    ///
    /// - Parameters:
    ///   - icon: 圖標名稱，從 Assets 加載。
    ///   - title: 主標題文字。
    ///   - subtitle: 副標題文字，默認為空。
    func configure(icon: String, title: String, subtitle: String?) {
        iconImageView.image = UIImage(named: icon)
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

