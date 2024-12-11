//
//  UserProfileLogoutCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/10.
//

// MARK: - 重點筆記：UserProfileLogoutCell 的設計與實現
/**
 
 ## 重點筆記：UserProfileLogoutCell 的設計與實現
 
 `* What`
 
 1.定義：`UserProfileLogoutCell` 是一個自訂的 UITableViewCell，專為處理用戶登出操作設計。
 
 2.功能：
 
 - 顯示加粗紅色的「`Logout`」按鈕文字，強調操作的重要性。
 - 支援點擊效果，適合交互操作。
 
 -----------------

 `* Why`
 
 1.操作清晰：

 - 透過紅色字體與居中排列，明確告知用戶該選項的作用與重要性。
 
 2.模組化設計：

 - 將登出選項抽象化為單獨的 Cell，便於管理與重用。
 
 3.強調交互性：

 - 啟用點擊效果（selectionStyle），讓用戶直觀感受到選項的可操作性。
 
 -----------------

 `* How`
 
 1.結構設計：

 - 僅包含一個居中的標題標籤，通過約束實現內容對齊。
 
 2.動態配置：

 - 支援點擊效果，可通過 TableView 的 didSelectRow 方法觸發具體操作。
 
 3.優化交互：

 - 配置適當的點擊樣式（selectionStyle），使用戶行為得到及時反饋。
 */

// MARK: - (v)

import UIKit

/// 用於顯示登出選項的自訂 UITableViewCell
///
/// 此 Cell 設計為個人資料頁面專屬，僅用於顯示登出操作按鈕。
///
/// 功能特色：
/// - 標題字體為加粗紅色，居中顯示，強調操作的重要性。
/// - 預設啟用點擊效果（`selectionStyle`），支持用戶交互行為。
///
/// 使用場景：適用於個人資料頁面的登出選項行，通常位於列表的最後一個 Section。
class UserProfileLogoutCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "UserProfileLogoutCell"
    
    // MARK: - UI Elements
    
    /// 登出按鈕標題
    private let titleLabel = UserProfileLabel(font: .systemFont(ofSize: 18, weight: .bold), textColor: .systemRed, textAlignment: .center, text: "Logout")
    
    // MARK: - Initializer
    
    /// 初始化 Cell 並配置佈局
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        configureSelectionStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    
    /// 配置佈局與約束條件
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    /// 配置點擊效果
    private func configureSelectionStyle() {
        selectionStyle = .default
    }
    
}
