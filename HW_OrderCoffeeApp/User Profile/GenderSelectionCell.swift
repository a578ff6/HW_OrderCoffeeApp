//
//  GenderSelectionCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/25.
//


/*
 ## GenderSelectionCell
    - 在 App 中，讓使用者在註冊後進行性別選擇。
    - 性別選擇是可選的，因此在註冊過程中並未要求用戶填寫此資訊。
    - 為了解決性別選擇欄位在顯示時可能出現的問題，使用了 GenderSelectionCell 來專門處理性別選擇的邏輯。

 ## GenderSelectionCell 的設計
    - GenderSelectionCell` 是自定義的 UITableViewCell，其核心功能是透過 UISegmentedControl 來處理性別選擇。
    - 這個 cell 被用於編輯個人資料的頁面中，並且可以根據現有的使用者性別資訊來設定初始選項。

 ## 想法

 1. 性別選項的顯示：
    - UISegmentedControl 被初始化為包含三個選項："Male"、"Female" 和 "Other"。
    - 當使用者沒有在註冊時選擇性別（即 gender 值為 nil），預設選擇 "Other" 以避免沒有選項被選中。

 2. 性別變更的回調：
    - 當使用者在 UISegmentedControl 上進行選擇時，會觸發 genderChanged 方法，將新的性別值透過 onGenderChanged 回調傳遞出去，供外部的控制器使用。

 ## 使用方式
    - 在外部控制器中（如 EditProfileViewController），當需要展示和編輯性別資訊時，可以使用 GenderSelectionCell。
    - 透過 configure 方法，根據使用者的現有性別資訊來設定 UISegmentedControl 的初始選項。如果性別為 nil，則會預設選擇 "Other"。

 ### 注意事項
    - 如果在未來新增或修改性別選項，需要同步更新 genderControl 的選項內容以及 genderIndex(for:) 方法。
    - 確保在控制器中處理性別選擇變更的邏輯，透過 `onGenderChanged` 回調來更新使用者資料。
 */


import UIKit

class GenderSelectionCell: UITableViewCell {

    static let reuseIdentifier = "GenderSelectionCell"

    private let genderControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Male", "Female", "Other"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    var onGenderChanged: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        genderControl.addTarget(self, action: #selector(genderChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(genderControl)
        NSLayoutConstraint.activate([
            genderControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genderControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            genderControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(withGender gender: String?) {
        if let gender = gender {
            genderControl.selectedSegmentIndex = genderIndex(for: gender)
        } else {
            genderControl.selectedSegmentIndex = 2                      // 如果性別為 nil，設置預設值，選擇 "Other"
        }
        
    }
    
    private func genderIndex(for gender: String?) -> Int {
        switch gender {
        case "Male":
            return 0
        case "Female":
            return 1
        case "Other":
            return 2
        default:
            return UISegmentedControl.noSegment
        }
    }
    
    @objc private func genderChanged() {
        let selectedGender: String
        switch genderControl.selectedSegmentIndex {
        case 0:
            selectedGender = "Male"
        case 1:
            selectedGender = "Female"
        case 2:
            selectedGender = "Other"
        default:
            return
        }
        onGenderChanged?(selectedGender)
    }
    
}
