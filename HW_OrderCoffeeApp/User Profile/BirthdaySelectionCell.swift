//
//  BirthdaySelectionCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/25.
//


/*
 ## BirthdaySelectionCell
    - 專門用於顯示使用者生日選擇的界面。這個 Cell 主要包含兩個元素：一個「標題標籤」和一個「日期標籤」。

 ## 主要功能包括：
 
    * UI 顯示：
        - titleLabel 用於顯示「選擇生日」的提示，並固定在 Cell 的左側。
        - dateLabel 用於顯示已選擇的日期，或者顯示「未選擇」來提示使用者尚未選擇日期。

    * 配置與更新：
        - configure(with:) 方法允許傳入一個 Date 物件，並將其格式化為人類可讀的日期格式顯示在 dateLabel 上。如果未傳入日期，dateLabel 則顯示「未選擇」以提示使用者進行選擇。
 */


import UIKit

class BirthdaySelectionCell: UITableViewCell {
    
    // MARK: - Static Properties

    static let reuseIdentifier = "BirthdaySelectionCell"
    
    // MARK: - UI Elements

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select Birthday"
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.textColor = .gray
        return label
    }()
        
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup

    /// 設定 Cell 的佈局
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    // MARK: - Configuration Method
    
    /// 配置日期標籤的顯示內容
    ///
    /// - Parameter date: 傳入的日期值，若有則顯示為格式化後的日期文字，若無則顯示「Not Selected」
    func configure(with date: Date?) {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "Not Selected"
        }
    }
}
