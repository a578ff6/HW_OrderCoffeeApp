//
//  BirthdaySelectionCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/25.
//


// MARK: - BirthdaySelectionCell 筆記
/**
 
 ## BirthdaySelectionCell 筆記
 
` * What`
 
 - `BirthdaySelectionCell` 是一個自訂的 `UITableViewCell`，用來顯示使用者的生日選擇。它包含兩個主要的 UI 元件：

 1.`titleLabel` - 顯示標題 "Select Birthday"。
 2.`dateLabel` - 顯示使用者已選擇的日期或默認的「尚未選擇」文字。

 -------------------------
 
 `* Why`
 
 - 在個人資料編輯頁面中，用戶需要選擇或查看他們的生日。`BirthdaySelectionCell` 提供了一個清晰且易於理解的 UI 元件，能夠顯示當前選擇的生日。
 - 該 cell 的設計使得在使用者未選擇日期時，顯示「尚未選擇」，以提供友好的使用者體驗。
 
 -------------------------
 
 `* How`
 
 - 使用` init(style:reuseIdentifier:) `初始化 cell，並設置 UI 元件的佈局 (setupLayout())，包括 titleLabel 和 dateLabel。
 
 - 透過 `configure(with date:) `方法來更新 `dateLabel` 的顯示內容：
 
 1.如果有選擇的日期，則顯示日期的格式化值。
 2.如果沒有選擇的日期，顯示默認的「Not Selected」。
 */



import UIKit

/// 用於顯示使用者生日選擇的 UITableViewCell
///
/// BirthdaySelectionCell 負責顯示生日選擇的標題和已選日期的標籤，並在需要時顯示使用者目前選擇的生日日期。
/// 如果使用者還未選擇日期，則顯示「尚未選擇」的提示。
class BirthdaySelectionCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "BirthdaySelectionCell"
    
    // MARK: - UI Elements
    
    /// 顯示標題文字 "Select Birthday"
    private let titleLabel = EditProfileLabel(text: "Select Birthday", fontSize: 16, weight: .regular, textColor: .black, textAlignment: .left)
    
    /// 顯示已選擇的日期或「尚未選擇」
    private let dateLabel = EditProfileLabel(text: "Not Selected", fontSize: 16, weight: .regular, textColor: .gray, textAlignment: .right)
    
    // MARK: - Initializer
    
    /// 初始化 BirthdaySelectionCell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    
    /// 設定 Cell 的佈局
    ///
    /// 負責設置標題標籤和日期標籤的佈局。
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    /// 配置 Cell 的外觀屬性
    private func setupAppearance() {
        separatorInset = .zero // 確保分隔線完全禁用
        backgroundColor = .clear // 確保背景色與 TableView 一致
        selectionStyle = .none // 禁用點擊高亮效果
    }
    
    // MARK: - Configuration Method
    
    /// 配置日期標籤的顯示內容
    ///
    /// - Parameter date: 傳入的日期值，若有則顯示為格式化後的日期文字，若無則顯示「Not Selected」
    func configure(with date: Date?) {
        guard let date = date else {
            dateLabel.text = "Not Selected"
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: date)
    }
    
}
