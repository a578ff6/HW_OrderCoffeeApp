//
//  UserProfileTableHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/29.
//

// MARK: -  ## UserProfileTableHandler 筆記 ##

/*
 ## UserProfileTableHandler 筆記 ##
 
 A. UserProfileTableHandler 的職責：
    - 負責管理 UITableView 的 (DataSource) 和 (Delegate) 功能。
    - 處理使用者的個人資訊顯示和選項的點擊事件。它從 UserProfileViewController 接收使用者資料 (userDetails)，並在不同的 section 中顯示相應的內容。

 ------------------------- ------------------------- ------------------------- -------------------------

 B. UserProfileTableHandler 的架構：
 
    * Properties：
        - userDetails: 儲存來自 UserProfileViewController 的使用者詳細資料。
        - delegate: 用於處理像是導航到編輯頁面或登出的操作，透過 UserProfileViewController 來實現。
 
    * UITableViewDataSource：
        - numberOfSections(in:): 設置表格的 section 數量。
            - Section 0：顯示使用者個人資料 (如大頭照、名字、電子郵件)。
            - Section 1：顯示操作選項 (如編輯個人資料、查看訂單歷史、收藏項目、登出)。
        - tableView(_:numberOfRowsInSection:): 設置每個 section 中的 row 數量。
            - Section 0：包含 1 個 row。
            - Section 1：包含 5 個 row (General、Edit Profile、Order History、Favorites、Logout)。
        - tableView(_:cellForRowAt:): 為每個 row 設置對應的 cell。
            - 根據不同的 section 和 row 返回適當的 cell（例如：ProfileHeaderCell、ProfileOptionCell）。
 
    * UITableViewDelegate：
        - tableView(_:heightForRowAt:): 設置每個 row 的高度。
            - Section 0 的 row 設置為 80。
            - Section 1 的 row 設置為 60。
        - tableView(_:didSelectRowAt:): 處理 row 的點擊事件。
            - Section 1 的不同 row 點擊後執行不同的操作，如導航到編輯頁面 (Edit Profile)、登出等。
 
 */

// MARK: - 處理我的最愛相關
import UIKit

/// 負責管理 UITableView 的 (DataSource) 和 (Delegate) 功能。
class UserProfileTableHandler: NSObject {
    
    // MARK: - Properties

    /// 儲存使用者的詳細資料
    var userDetails: UserDetails?
    
    /// Delegate 用來與 UserProfileViewController 互動
    weak var delegate: UserProfileViewController?
}

// MARK: - UITableViewDataSource
extension UserProfileTableHandler: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1: 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            return configureProfileHeaderCell(for: tableView, at: indexPath)
        } else if indexPath.section == 1 {
            return indexPath.row == 0 ? configureGeneralCell(for: tableView, at: indexPath) : configureProfileOptionCell(for: tableView, at: indexPath, optionIndex: indexPath.row)
        }
        return UITableViewCell()
    }
    
    /// 配置 ProfileHeaderCell
    private func configureProfileHeaderCell(for tableView: UITableView, at indexPath: IndexPath) -> ProfileHeaderCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileHeaderCell.reuseIdentifier, for: indexPath) as? ProfileHeaderCell else {
            return ProfileHeaderCell()
        }
        
        let profileImageURL = userDetails?.profileImageURL
        cell.profileImageView.kf.setImage(with: URL(string: profileImageURL ?? ""), placeholder: UIImage(named: "UserSymbol"))
        cell.configure(profileImage: cell.profileImageView.image, name: userDetails?.fullName ?? "User Name", email: userDetails?.email ?? "user@example.com")
        cell.selectionStyle = .none
        return cell
    }
    
    /// 配置 General Cell
    private func configureGeneralCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "BasicCell")
        cell.textLabel?.text = "General"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cell.textLabel?.textColor = .lightGray
        cell.selectionStyle = .none
        return cell
    }
     
    /// 配置 ProfileOptionCell
    private func configureProfileOptionCell(for tableView: UITableView, at indexPath: IndexPath, optionIndex: Int) -> ProfileOptionCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileOptionCell.reuseIdentifier, for: indexPath) as? ProfileOptionCell else {
            return ProfileOptionCell()
        }
        switch optionIndex {
        case 1:
            cell.configure(icon: UIImage(systemName: "person.circle"), title: "Edit Profile", subtitle: "Change your details")
        case 2:
            cell.configure(icon: UIImage(systemName: "clock"), title: "Order History", subtitle: "View your past orders")
        case 3:
            cell.configure(icon: UIImage(systemName: "heart"), title: "Favorites", subtitle: "Your favorite items")
        case 4:
            cell.configure(icon: UIImage(systemName: "arrow.backward.circle"), title: "Logout", subtitle: nil)
        default:
            break
        }
        return cell
    }

}

// MARK: - UITableViewDelegate
extension UserProfileTableHandler: UITableViewDelegate {

    /// 設置每個 row 的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 80 : 60
    }
    
    /// 處理 row 的點擊事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1:
                print("Edit Profile Tapped")
                delegate?.navigateToEditProfile()
            case 2:
                // 這裡可以處理點擊 "Order History" 的邏輯
                print("Order History Tapped")
            case 3:
                print("Favorites Tapped")
                delegate?.navigateToFavorites()
            case 4:
                print("Logout Tapped")
                delegate?.confirmLogout()
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
