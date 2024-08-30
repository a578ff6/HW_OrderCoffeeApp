//
//  BirthdaySelectionCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/25.
//


/*
 ## BirthdaySelectionCell
    
    * 用途：BirthdaySelectionCell 專門用於顯示使用者選擇生日的界面。這個 Cell 包含兩個主要元素：「標題標籤」和「日期標籤」。

 ## 主要功能包括：
 
    * UI 顯示：
        - titleLabel：顯示「Select Birthday」的提示文字，固定在 Cell 的左側。
        - dateLabel：顯示已選擇的日期；如果尚未選擇日期，則顯示「Not Selected」提示使用者進行選擇。

    * 配置與更新：
        - configure(with:) 方法允許傳入一個 Date 物件，並將其格式化日期格式顯示在 dateLabel 上。如果沒有傳入日期，dateLabel 則顯示「Not Selected」來提示使用者尚未選擇日期。
 */


// MARK: - 已經完善
import UIKit

/// 用於選擇生日的 UITableViewCell
class BirthdaySelectionCell: UITableViewCell {
    
    // MARK: - Static Properties

    static let reuseIdentifier = "BirthdaySelectionCell"
    
    // MARK: - UI Elements

    let titleLabel: UILabel = createLabel(text: "Select Birthday", textColor: .black, textAlignment: .left)
    let dateLabel: UILabel = createLabel(text: "Not Selected", textColor: .gray, textAlignment: .right)
        
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
    
    
    // MARK: - Helper Function

    private static func createLabel(text: String, textColor: UIColor, textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = textColor
        label.textAlignment = textAlignment
        return label
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








