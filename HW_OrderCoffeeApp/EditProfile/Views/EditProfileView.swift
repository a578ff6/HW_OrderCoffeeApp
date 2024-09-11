//
//  EditProfileView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/24.
//

/*
 ## EditProfileView
    - 負責處理「個人資料編輯頁面」主要視圖佈局的自訂 UIView。
    - 管理頁面中的大頭照、更換照片按鈕，以及顯示使用者資訊的表單（UITableView）。

 ## 主要功能
    
    * 大頭照顯示與更換按鈕
        - profileImageView: 顯示使用者的大頭照，並設置為圓形邊框。
        - changePhotoButton: 更換大頭照的按鈕，點擊後允許使用者從相機或相簿選擇照片。
 
    * 表單（UITableView）
        - tableView: 顯示使用者資訊的表單，使用 UITableView 來顯示不同的欄位（如姓名、電話號碼、生日等）。
 
    * 佈局設置
        - setupLayout(): 設置表單（UITableView）的 Auto Layout 約束，使其填滿整個視圖。
        - setupTableHeaderView(): 將大頭照和更改照片按鈕放置於 tableHeaderView 中，並設置相應的 Auto Layout 約束。
 
    * 重點
        - 表單滾動時的行為: 大頭照和更換照片按鈕會隨著表單一起滾動，這是透過將這些元素放置在 tableHeaderView 中實現的。    
 */


// MARK: - 已經完善

import UIKit

/// 負責頁面上所有主要區塊的佈局：大頭照、更換照片按鈕、表單（UITableView）。
class EditProfileView: UIView {
    
    // MARK: - UI Elements
    let profileImageView = createProfileImageView()
    let changePhotoButton = createChangePhotoButton()
    let tableView = createTableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupTableHeaderView()
        registerCells()        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup

    /// 設置 tableView 約束
    private func setupLayout() {
        // 表單TableView
        addSubview(tableView)
        
        // 設置Auto Layout約束
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 設置 tableHeaderView 包含大頭照和更改照片按鈕
    private func setupTableHeaderView() {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 220)  // 根據需要調整高度
        headerView.addSubview(profileImageView)
        headerView.addSubview(changePhotoButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 180),
            profileImageView.heightAnchor.constraint(equalToConstant: 180),
            
            changePhotoButton.widthAnchor.constraint(equalToConstant: 40),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 40),
            changePhotoButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            changePhotoButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    /// 註冊 UITableView 的自定義 cell
     private func registerCells() {
         tableView.register(ProfileTextFieldCell.self, forCellReuseIdentifier: ProfileTextFieldCell.reuseIdentifier)
         tableView.register(GenderSelectionCell.self, forCellReuseIdentifier: GenderSelectionCell.reuseIdentifier)
         tableView.register(BirthdaySelectionCell.self, forCellReuseIdentifier: BirthdaySelectionCell.reuseIdentifier)
     }
    
    // MARK: - UI Element Creation
    
    /// 創建大頭照圖片視圖
    private static func createProfileImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 90
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.black.cgColor
        return imageView
    }
    
    /// 創建更改照片按鈕
    private static func createChangePhotoButton() -> UIButton {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "camera.circle.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    /// 建立 UITableView
    private static func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }

}








