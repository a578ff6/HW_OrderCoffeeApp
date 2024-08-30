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
    - UISegmentedControl 包含三個選項："Male"、"Female" 和 "Other"。
    - 當使用者在註冊時沒有選擇性別（即 gender 值為 nil 或空字串），預設選擇 "Other"，以確保在編輯頁面中有一個選項被選中，避免性別選項處於未選中狀態。
    - 「空字串」的出現在於使用者在首次進入到 EditProfileViewController 時，沒有選擇性別直接點擊save保存，就會呈現「空字串」。

 2. 性別變更的回調：
    - 當使用者在 UISegmentedControl 上進行選擇時，會觸發 genderChanged 方法，將新的性別值透過 onGenderChanged 回調傳遞出去，以供外部控制器（ EditProfileViewController）更新使用者資料。
 
 ## 使用方式
    - 在外部控制器中（如 EditProfileViewController），當需要展示和編輯性別資訊時，可以使用 GenderSelectionCell。
    - 透過 configure(withGender:) 方法，根據使用者的現有性別資訊來設定 UISegmentedControl 的初始選項。如果性別為 nil 或空字串，則會預設選擇 "Other"。


 ### 注意事項
    - 如果在未來新增或修改性別選項，需要同步更新 genderControl 的選項內容以及 genderIndex(for:) 方法。
    - 確保在控制器中處理性別選擇變更的邏輯，透過 `onGenderChanged` 回調來更新使用者資料。
 
 ### （額外想法）：
    * 如果在一開始在建立帳號的時候，雖然沒讓使用者填寫性別，但是建立的時候直接建立「性別」預設值為 other 而不是 nil，那這樣後續再處理 gender 相關處理邏輯時會比較方便。
        - 這樣可以避免空值導致的問題，並確保在編輯個人資料頁面時， gender 一定會有一個預設值。
        - 這樣的話，在後續處理時，就不需要特別檢查 gender 是否為空，可以直接處理它，讓使用者自行修改。
 */


// MARK: - 已經完善

import UIKit

/// 專門用於顯示使用者性別選擇的界面。這個 Cell 主要包含兩個元素：一個「UISegmentedControl」。
class GenderSelectionCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "GenderSelectionCell"
    
    var onGenderChanged: ((String) -> Void)?
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        genderControl.addTarget(self, action: #selector(genderChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements

    private let genderControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Male", "Female", "Other"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // MARK: - Layout Setup

    private func setupLayout() {
        contentView.addSubview(genderControl)
        
        NSLayoutConstraint.activate([
            genderControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genderControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            genderControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration Method

    /// 根據用戶的性別配置顯示
    ///
    /// - Parameter gender: 用戶當前的性別，如果性別為 nil 或空字串，設置預設值，選擇 "Other"
    func configure(withGender gender: String?) {
        let genderToSet = (gender == nil || gender!.isEmpty) ? "Other" : gender!
        genderControl.selectedSegmentIndex = genderIndex(for: genderToSet)
    }
    
    private func genderIndex(for gender: String) -> Int {
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
    
    // MARK: - Actions

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

