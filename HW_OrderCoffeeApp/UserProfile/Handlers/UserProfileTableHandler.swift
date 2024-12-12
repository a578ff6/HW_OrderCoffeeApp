//
//  UserProfileTableHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/29.
//

// MARK: - 筆記：UserProfileTableHandler 的設計與實現
/**
 ## 筆記：UserProfileTableHandler 的設計與實現

 ---

 `* What`
 
 - `UserProfileTableHandler` 是負責管理 `UITableView` 的數據源 (DataSource) 和委派 (Delegate) 的類別，主要用途包括：
 
 `1.數據管理：`
 
   - 通過 `UserProfileDataSource` 提供個人資料頁面中每個分區的行數據。
   - 支援四個分區：用戶資訊 (`userInfo`)、常規選項 (`generalOptions`)、社交連結 (`socialLinks`) 和登出按鈕 (`logout`)。
 
 `2.事件處理：`
 
   - 配置不同分區的 Cell 顯示內容。
   - 處理點擊事件並透過 `UserProfileTableHandlerDelegate` 通知控制器，實現分層架構與責任分離。

 ---

 `* Why`
 
` 1. 職責分離：`
 
    - 將 `UITableView` 的數據與邏輯從 `UserProfileViewController` 中抽離，控制器僅需處理業務邏輯與頁面跳轉。
    - 使用 `Delegate` 模式，實現視圖層與控制器層的解耦，便於測試與維護。

 `2. 模組化設計：`
 
    - 各分區的數據與行為通過 `UserProfileSection` 和 `UserProfileRow` 統一管理，易於擴展。
    - 如需新增分區或功能，只需擴展 `UserProfileSection` 和相關數據源。

 `3. 提升可讀性與可維護性：`
 
    - 每個分區的配置方法獨立處理，避免臃腫的控制器代碼。
    - 使用 `UserProfileDataSource` 確保數據與視圖邏輯分離，集中管理頁面數據。

 ---

 `* How`

 `1. 數據源與分區設置：`
 
    - 定義 `UserProfileSection` 枚舉描述頁面區域類型（用戶資訊、常規選項等）。
    - 透過 `UserProfileDataSource` 提供行數據，每個分區的內容由 `UserProfileRow` 結構定義。

 `2. Cell 配置邏輯：`
 
    - 根據分區類型 (`UserProfileSection`) 動態配置 `UITableViewCell`：
      - `userInfo`：顯示用戶頭像、名稱與 Email。
      - `generalOptions`：顯示常規操作（如編輯個人資料、歷史訂單）。
      - `socialLinks`：顯示社交媒體連結。
      - `logout`：顯示登出按鈕。
    - 每個分區的 Cell 配置方法獨立封裝，避免混亂的邏輯。

 `3. 點擊事件處理：`
 
    - 根據點擊的分區和行數，執行相應的處理：
      - `generalOptions`：調用 `delegate` 的 `navigateToEditProfile` 等方法進行導航。
      - `socialLinks`：調用 `delegate` 的 `didSelectSocialLink` 打開網頁。
      - `logout`：調用 `delegate` 的 `confirmLogout` 顯示確認彈窗。

 `4. Delegate 模式：`
 
    - 定義 `UserProfileTableHandlerDelegate` 協議作為溝通接口，實現控制器與 TableHandler 的責任分離。

 ---

 `* 補充說明`

 `1. 資料流向：`
 
    - 數據來源：由 `UserProfileDataSource` 提供靜態數據或 API 加載的動態數據。
    - 數據消費：`UserProfileTableHandler` 負責處理並展示數據。
    - 互動邏輯：由 `UserProfileTableHandlerDelegate` 傳回控制器進行操作。

 `2. 擴展性：`
 
    - 添加新功能只需擴展 `UserProfileSection`、`UserProfileRow` 和對應的 `Cell` 配置方法。
    - 可用於類似的個人資料頁面需求，具有高重用性。

 `3. 注意事項：`
 
    - 確保 `delegate` 的實現正確，否則點擊事件將無法正常響應。
    - `dataSource` 提供的數據需與分區數量一致，避免數據錯位。
 */


// MARK: - 筆記標題：UserProfileSection、UserProfileRow、UserProfileDataSource 與 UserProfileTableHandler 的關聯與影響（重要）
/**
 
 ## 筆記標題：UserProfileSection、UserProfileRow、UserProfileDataSource 與 UserProfileTableHandler 的關聯與影響

 * What
 
 這三個模組 (`UserProfileSection`、`UserProfileRow`、`UserProfileDataSource`) 的主要目的是為 `UserProfileTableHandler` 提供分區及行數據的結構化支持，實現資料的模組化管理和高效配置。
 避免`硬編碼`以及`分區及行數據`的分散

 - `UserProfileSection` 定義分區的類型和結構，如 `userInfo`、`generalOptions`、`socialLinks` 和 `logout`，幫助 `UserProfileTableHandler` 分辨不同區域的用途及行為。
 - `UserProfileRow` 定義單行的數據模型，如圖示、標題、副標題、連結和對應的操作行為。
 - `UserProfileDataSource` 提供分區對應的行數據，將 `UserProfileSection` 和 `UserProfileRow` 連接起來，成為數據來源的核心。

 ---

 `* Why`

 `1. 分離關注點`
 
    - 目的：將分區邏輯 (`Section`) 與行數據 (`Row`) 從 `UserProfileTableHandler` 中分離，提升代碼的可讀性與擴展性。
    - 原因：直接在 `UserProfileTableHandler` 中處理數據會增加耦合性，導致邏輯臃腫且難以維護。

 `2. 結構化管理`
 
    - 目的：通過 `UserProfileSection` 和 `UserProfileRow` 的結構化設計，讓數據更直觀易於維護。
    - 原因：數據結構化能降低邏輯錯誤，特別是當分區和行數據需要頻繁更新時。

 `3. 易於擴展`
 
    - 目的：新增分區或行數據只需修改 `UserProfileSection` 和 `UserProfileDataSource`，無需對 `UserProfileTableHandler` 的邏輯進行大幅改動。
    - 原因：保持 `UserProfileTableHandler` 僅關注如何使用數據，而非管理數據的來源或結構。

 ---

 `* How`

 `1. 分區與數據模型的設計`
 
    - `UserProfileSection` 定義分區類型及其標題：
      ```swift
      enum UserProfileSection: Int, CaseIterable {
          case userInfo
          case generalOptions
          case socialLinks
          case logout
          
          var title: String? {
              switch self {
              case .userInfo:
                  return nil
              case .generalOptions:
                  return "General"
              case .socialLinks:
                  return "Follow Us"
              case .logout:
                  return nil
              }
          }
      }
      ```

    - `UserProfileRow` 描述單行數據結構：
      ```swift
      struct UserProfileRow {
          let icon: String
          let title: String
          let subtitle: String?
          let urlString: String?
          let action: GeneralOptionAction?
      }
      ```

    - `UserProfileDataSource` 提供數據：
      ```swift
      class UserProfileDataSource {
          func rows(for section: UserProfileSection) -> [UserProfileRow] {
              switch section {
              case .userInfo:
                  return [] // 固定行數處理
              case .generalOptions:
                  return [
                      UserProfileRow(icon: "person.fill", title: "Edit Profile", subtitle: "Change your details", action: .editProfile),
                      UserProfileRow(icon: "clock", title: "Order History", subtitle: "View your past orders", action: .orderHistory)
                  ]
              case .socialLinks:
                  return [
                      UserProfileRow(icon: "facebook", title: "Facebook", subtitle: "Follow us on Facebook", urlString: "https://facebook.com"),
                      UserProfileRow(icon: "instagram", title: "Instagram", subtitle: "Follow us on Instagram", urlString: "https://instagram.com")
                  ]
              case .logout:
                  return []
              }
          }
      }
      ```

` 2. 與 UserProfileTableHandler 的整合`
 
    - 分區數據的處理：`UserProfileTableHandler` 通過 `UserProfileDataSource` 獲取每個分區的行數據。
    - 動態行數配置：根據 `UserProfileSection` 的類型，通過 `dataSource.rows(for:)` 獲取對應行數：
 
      ```swift
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          guard let section = UserProfileSection(rawValue: section) else { return 0 }
          switch section {
          case .userInfo:
              return 1
          case .generalOptions:
              return dataSource.rows(for: .generalOptions).count
          case .socialLinks:
              return dataSource.rows(for: .socialLinks).count
          case .logout:
              return 1
          }
      }
      ```

 `3. 點擊處理的邏輯`
 
    - 當點擊行時，`UserProfileTableHandler` 依賴分區與行數據的結構來執行相應邏輯：
      ```swift
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          guard let section = UserProfileSection(rawValue: indexPath.section) else { return }
          switch section {
          case .userInfo:
              break
          case .generalOptions:
              handleGeneralOptionSelection(at: indexPath.row)
          case .socialLinks:
              handleSocialLinkSelection(at: indexPath.row)
          case .logout:
              handleLogoutSelection()
          }
      }
      ```

 ---

 `* 結論`

 - `清晰的數據分層設計`：`UserProfileSection`、`UserProfileRow` 和 `UserProfileDataSource` 的結合，實現了數據的結構化與模組化管理。
 - `對 UserProfileTableHandler 的影響`：大幅減少數據邏輯在 `UserProfileTableHandler` 中的重複與耦合，提升了代碼的可讀性和維護性。
 - `適合新增功能`：如需新增分區或功能，只需修改數據來源，無需更改主要邏輯。
 */


// MARK: - configureUserInfoCell 不需要「獲取對應數據」（重要）
/**

 ## configureUserInfoCell 不需要「獲取對應數據」
 
` * What`
 
 - `configureUserInfoCell` 是用於配置  userInfo 區域的 Cell 方法。它的數據來自於 delegate 提供的用戶資料（userProfile），而不是從 dataSource.rows(for:) 中獲取。

 ----------------
 
 `* Why`
 
 `1.本質不同：`

 - `userInfo` 是一個單一固定顯示的 Cell，用於呈現用戶頭像、姓名、Email 等個人資料。
 - 它的數據來源是 `UserProfileViewController` 中的 `userProfile`，直接與用戶的核心信息相關，與其他動態行數（`generalOptions` 和 `socialLinks`）不同。
 
 `2.職責單一：`

 - 將 `userInfo` 的數據來源限定為` delegate.getUserProfile()`，避免將其納入通用的 `dataSource`，保持結構清晰，責任分明。
 
 `3.靈活性：`

 - `delegate` 提供數據的方式讓 `UserProfileTableHandler` 能夠輕鬆與 `ViewController` 通信，無需對 `dataSource` 做額外的修改。
 
 ----------------

 `* How`
 
 `1.透過 delegate 提供數據：`

 ```swift
 private func configureUserInfoCell(for tableView: UITableView, at indexPath: IndexPath) -> UserProfileInfoCell {
     guard let cell = tableView.dequeueReusableCell(
         withIdentifier: UserProfileInfoCell.reuseIdentifier,
         for: indexPath
     ) as? UserProfileInfoCell else {
         return UserProfileInfoCell()
     }
     
     guard let profile = delegate?.getUserProfile() else {
         return cell
     }
     
     cell.setProfileImageFromURL(profile.profileImageURL)
     cell.setUserInfo(name: profile.fullName, email: profile.email)
     return cell
 }
 ```
 
 `2.與其他區域分開處理：`

 - `configureUserInfoCell` 不使用 `dataSource`，僅通過 `delegate.getUserProfile() `獲取數據。
 
 `3.保持職責單一：`

 - 避免將 `userInfo` 納入 `dataSource.rows(for:)`，使其數據來源與其他區域的數據結構隔離，保持清晰的責任邊界。
 
 ----------------

 `* 總結`
 
 - `configureUserInfoCell` 的數據來自 `delegate`，不使用 `dataSource`，保持數據來源單一且清晰。
 */


// MARK: - numberOfRowsInSection 的固定行數處理
/**
 
 ## numberOfRowsInSection 的固定行數處理

 `* What`
 
 
 1.在 `numberOfRowsInSection` 方法中，針對某些固定行數的區域（如 `userInfo` 和 `logout`），直接返回固定值而非依賴動態數據源 (`dataSource`)。

 2.固定行數的區域：
 
 - `userInfo`：行數固定為 1，表示僅顯示用戶頭像、名稱與 Email。
 - `logout`：行數固定為 1，表示僅顯示登出按鈕。

 ----------------

 `* Why`
 
 `1.固定行數的特性：`
 
 - `userInfo` 和 `logout` 是設計為固定內容的區域，無需動態行數管理。例如：
 - `userInfo` 始終僅包含一行，顯示用戶的基本信息。
 - `logout` 始終僅包含一行，用於顯示登出按鈕。
 - 動態數據管理適用於可能發生數量變化的區域（如 `generalOptions` 和 `socialLinks`）。
 
 
 `2.避免不必要的依賴：`

 - `dataSource.rows(for:)` 對應的是其他動態數據（如 `generalOptions` 和 `socialLinks`），不適用於固定行數的 `userInfo`、`logout`。
 - 如果使用 `dataSource.rows(for:)` 為固定區域提供行數，會因數據為空數組`（[]）`而導致不顯示行。
 -  固定行數的區域與動態數據無關，直接返回固定值能提升穩定性與可讀性。

 `3.提升可讀性與穩定性：`

 - 直接返回固定行數` 1`，清楚地表明 `userInfo` 、`logout`的性質。
 -  與其他區域（如 generalOptions）分開處理，確保代碼的邏輯一致性與擴展性。
 
 ----------------

 `* How`
 
 `1.固定行數為 1：`

 ```swift
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     guard let section = UserProfileSection(rawValue: section) else { return 0 }
     
     switch section {
     case .userInfo:
         return 1 // 確保用戶信息區域始終僅顯示一行
     case .generalOptions:
         return dataSource.rows(for: .generalOptions).count
     case .socialLinks:
         return dataSource.rows(for: .socialLinks).count
     case .logout:
         return 1 // 登出區域始終僅顯示一行
     }
 }
 ```
 
 `2.避免使用空數據返回行數：`

 - 如果嘗試這樣設計，會導致 `userInfo` 不顯示：
 
 ```swift
 case .userInfo:
     return dataSource.rows(for: .userInfo).count // 此處返回 0
 ```
 
 `3.與其他區域的動態數據分開處理：`

 - `generalOptions` 和 `socialLinks` 使用` dataSource.rows(for:)`，而 `userInfo` 行數獨立處理，避免混淆。
 
 ----------------

 `* 總結`
  
 `1.資料流向：`

 - `固定行數`：userInfo 和 logout 的行數直接由代碼控制，無需動態數據。
 - `動態行數`：generalOptions 和 socialLinks 使用 dataSource 提供數據支持。
 
 `2.適用範例：`

 - `固定行數區域`：
    - `userInfo`：僅顯示個人資訊。
    - `logout`：僅顯示登出按鈕。
 
 - `動態行數區域`：
    - `generalOptions`：可能隨功能增加而變動行數。
    - `socialLinks`：可能因新增社交媒體連結而改變行數。
 */


// MARK: - 筆記：移除數據源中對登出功能的支持
/**
 
 ## 筆記：移除數據源中對登出功能的支持


 `* What：數據源移除登出功能的數據支持`
 
 - 在 `UserProfileDataSource` 中移除 `logout` 區段的數據支持，將其改為專屬的 `UserProfileLogoutCell` 負責顯示與處理登出功能。

 ----------------

` * Why：強調職責分離與簡化`

 `1. 職責清晰化`
 
    - 數據源 (`UserProfileDataSource`)： 應專注於提供需要動態數據支持的區域（如 `generalOptions` 和 `socialLinks`）。
    - 登出功能 (`UserProfileLogoutCell`)： 作為固定樣式與行為的單元，與動態數據無關，應專注於其獨立的行為處理。

 `2. 減少冗餘與混淆`
 
    - 將 `"Logout"` 相關數據與專屬 Cell 的固定樣式混合在數據源中，會導致數據冗餘和開發者混淆。

 `3. 簡化維護與擴展`
 
    - 移除數據源中的 `logout` 數據後，登出功能樣式和行為集中在 `UserProfileLogoutCell` 中，未來只需修改專屬 Cell 即可完成更新。

 ----------------

 `* How：具體步驟與實現`

 1. 移除數據源中的登出數據支持
 
    - 在 `UserProfileDataSource` 中刪除 `logout` 區段的數據支持，保持其他區段不變。

 - 調整前：
    ```swift
    case .logout:
        return [("arrow.backward.circle", "Logout", nil, nil)]
    ```

 - 調整後：
    ```swift
    case .logout:
        return [] // 不需要數據支持
    ```

 ---

 `2. 直接渲染專屬登出 Cell`
 
    - 在 `UserProfileTableHandler` 中，直接為 `logout` 區段渲染專屬的 `UserProfileLogoutCell`，無需從數據源提取數據：

    ```swift
    private func configureLogoutCell(for tableView: UITableView, at indexPath: IndexPath) -> UserProfileLogoutCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileLogoutCell.reuseIdentifier, for: indexPath) as? UserProfileLogoutCell else {
            return UserProfileLogoutCell()
        }
        return cell
    }
    ```

 ---

` 3. 簡化 numberOfRowsInSection`
 
    - 固定 `logout` 區段的行數為 1，避免通過數據源計算：

    ```swift
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = UserProfileSection(rawValue: section) else { return 0 }
        
        switch section {
        case .userInfo:
            return 1
        case .generalOptions:
            return dataSource.rows(for: .generalOptions).count
        case .socialLinks:
            return dataSource.rows(for: .socialLinks).count
        case .logout:
            return 1 // 登出區段固定 1 行
        }
    }
    ```

 ---

 `4. 在 didSelectRowAt 中處理登出邏輯`
 
    - 確保登出行為在 `UITableViewDelegate` 中按區段單獨處理：

    ```swift
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = UserProfileSection(rawValue: indexPath.section) else { return }
        switch section {
        case .logout:
            delegate?.confirmLogout() // 單獨處理登出操作
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    ```

 ----------------

 `* 總結`

 - `數據源移除 logout`：減少冗餘，保持數據與固定功能分離。
 - `專屬 Cell 負責登出`： 明確 `UserProfileLogoutCell` 的職責，便於管理與修改。
 - `固定行數與單獨處理邏輯`：簡化 `numberOfRowsInSection` 和點擊事件的邏輯，確保代碼更清晰可維護。
 
 */


// MARK: - 關於「分區標題」與「導航標題」的間距的筆記（重要）
/**
 
 ## 關於「分區標題」與「導航標題」的間距的筆記（重要）
 
 `* What`
 
 - 當採用 `UITableView.Style.insetGrouped` 且啟用大標題 (`Large Titles`) 的導航欄時，第一個分區的 `cell` 與大標題之間可能出現過近的情況。這是因為：
 
 - 第一個分區沒有 `sectionHeader` 時，會緊貼 `UITableView` 的頂部。
 - 預設的 `UITableView` 不會自動調整與大標題之間的間距。

 --------------------

 `* Why 原因分析`
 
 `1. 缺少分區標題或 Header View：`
 
    - 預設情況下，如果分區沒有標題 (`titleForHeaderInSection` 返回 `nil`) 或自定義 Header View (`viewForHeaderInSection`) 的情況，UITableView 的第一個 Cell 會直接貼近頂部，與導航欄大標題相鄰。

 `2. UITableView.Style.insetGrouped 的設計特性：`
 
    - 在 `insetGrouped` 樣式中，分區間的間距被設計得更緊湊，特別是在沒有 Header 的分區中，會更靠近 UITableView 的邊緣。

 `3. 導航欄與 TableView 的佈局關係：`
 
    - 大標題導航欄與 TableView 的間距由系統控制，缺少分區標題時不會主動增加額外的空白。

 --------------------

 `* How 解決方式`

 方式 1：使用空白標題（已採用的方法）

 - 透過 `UserProfileSection` 擴展，為第一個分區添加一個空白標題：

 ```swift
 enum UserProfileSection: Int, CaseIterable {
     case userInfo
     case generalOptions
     case socialLinks
     case logout
     
     var title: String? {
         switch self {
         case .userInfo:
             return nil
         case .generalOptions:
             return "General"
         case .socialLinks:
             return "Follow Us"
         case .logout:
             return nil
         }
     }
     
     var requiresSpacing: Bool {
         switch self {
         case .userInfo:
             return true
         default:
             return false
         }
     }
 }
 ```

 - 在 `titleForHeaderInSection` 方法中，為需要間距的分區返回空白標題 (`" "`)，其他分區返回對應標題或 `nil`：

 ```swift
 func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     guard let section = UserProfileSection(rawValue: section) else { return nil }
     return section.requiresSpacing ? " " : section.title
 }
 ```

 ------
 
 
 `方式 2：使用自定義空白 Header View`

 - 如果需要更精細的間距控制，可以自定義空白的 Header View：

 ```swift
 func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     guard section == 0 else { return nil }
     let spacerView = UIView()
     spacerView.backgroundColor = .clear
     return spacerView
 }

 func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return section == 0 ? 20 : 0
 }
 ```

 --------------------

 `* 總結`

 - `優化背景`：為了解決第一個分區 Cell 與大標題過近的問題，採用了「為第一個分區設置空白標題」的方式，通過 `UserProfileSection.requiresSpacing` 屬性統一管理分區邏輯。
 - `未來擴展`： 如果需要更精細的視覺控制，可以考慮使用自定義空白 Header View。

 */


// MARK: - (v)

import UIKit

/// 負責管理 `UITableView` 的數據源 (DataSource) 和委派 (Delegate) 功能。
///
/// 此類封裝了 `UserProfileViewController` 中 TableView 的邏輯處理，
/// 包括分區數據的配置及點擊事件的處理，並透過 Delegate 回傳互動行為，
/// 實現視圖與控制器間的解耦設計。
///
/// ### 功能
/// - 分區管理: 根據 `UserProfileSection` 配置不同的分區與行內容。
/// - 數據來源: 使用 `UserProfileDataSource` 提供行數據，減少耦合。
/// - 點擊處理: 點擊事件透過 `UserProfileTableHandlerDelegate` 回傳控制器處理。
class UserProfileTableHandler: NSObject {
    
    // MARK: - Properties
    
    /// 用於與控制器溝通的委派，回傳用戶互動結果
    weak var delegate: UserProfileTableHandlerDelegate?
    
    /// 資料來源，用於提供 TableView 各區域的行內容
    private let dataSource = UserProfileDataSource()
    
    
    // MARK: - Cell Configuration Methods
    
    /// 配置對應的 TableView Cell
    ///
    /// 根據分區類型調用特定的 Cell 配置方法。
    private func configureCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let section = UserProfileSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .userInfo:
            return configureUserInfoCell(for: tableView, at: indexPath)

        case .generalOptions:
            return configureGeneralOptionCell(for: tableView, at: indexPath)
            
        case .socialLinks:
            return configureSocialLinkCell(for: tableView, at: indexPath)
            
        case .logout:
            return configureLogoutCell(for: tableView, at: indexPath)
        }
    }
    
    /// 配置 UserInfo 分區的 Cell
    ///
    /// 用於顯示用戶的個人資訊（頭像、名稱、Email）。
    private func configureUserInfoCell(for tableView: UITableView, at indexPath: IndexPath) -> UserProfileInfoCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileInfoCell.reuseIdentifier, for: indexPath) as? UserProfileInfoCell else {
            return UserProfileInfoCell()
        }
        
        guard let profile = delegate?.getUserProfile() else {
            return cell
        }
        
        /// 更新頭像圖片 URL
        cell.setProfileImageFromURL(profile.profileImageURL)
        /// 配置使用者資訊
        cell.setUserInfo(name: profile.fullName, email: profile.email)
        
        return cell
    }
    
    /// 配置 GeneralOptions 分區的 Cell
    ///
    /// 用於顯示常規操作選項，例如編輯資料、查看歷史訂單。
    private func configureGeneralOptionCell(for tableView: UITableView, at indexPath: IndexPath) -> UserProfileGeneralOptionCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileGeneralOptionCell.reuseIdentifier, for: indexPath) as? UserProfileGeneralOptionCell else {
            return UserProfileGeneralOptionCell()
        }
        
        /// 獲取對應數據
        let rows = dataSource.rows(for: .generalOptions)
        guard indexPath.row < rows.count else { return cell }
        
        let row = rows[indexPath.row]
        
        /// 使用 `UserProfileRow` 的屬性配置 Cell
        cell.configure(icon: row.icon, title: row.title, subtitle: row.subtitle)
        return cell
    }
    
    /// 配置 SocialLinks 分區的 Cell
    ///
    /// 用於顯示社交媒體連結。
    private func configureSocialLinkCell(for tableView: UITableView, at indexPath: IndexPath) -> UserProfileSocialLinkCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileSocialLinkCell.reuseIdentifier, for: indexPath) as? UserProfileSocialLinkCell else {
            return UserProfileSocialLinkCell()
        }
        
        let rows = dataSource.rows(for: .socialLinks)
        guard indexPath.row < rows.count else { return cell }
        
        let row = rows[indexPath.row]
        
        cell.configure(icon: row.icon, title: row.title, subtitle: row.subtitle)
        return cell
    }
    
    /// 配置 Logout 分區的 Cell
    ///
    /// 用於顯示登出按鈕。
    private func configureLogoutCell(for tableView: UITableView, at indexPath: IndexPath) -> UserProfileLogoutCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileLogoutCell.reuseIdentifier, for: indexPath) as? UserProfileLogoutCell else {
            return UserProfileLogoutCell()
        }
        return cell
    }
}


// MARK: - UITableViewDataSource
extension UserProfileTableHandler: UITableViewDataSource {
    
    /// 返回分區數量
    func numberOfSections(in tableView: UITableView) -> Int {
        return UserProfileSection.allCases.count
    }
    
    /// 返回每個分區的行數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = UserProfileSection(rawValue: section) else { return 0 }
        
        switch section {
        case .userInfo:
            return 1    // 確保頭像區段始終只有一行
        case .generalOptions:
            return dataSource.rows(for: .generalOptions).count
        case .socialLinks:
            return dataSource.rows(for: .socialLinks).count
        case .logout:
            return 1        // 登出區域始終只有一行
        }
    }
    
    /// 返回配置完成的 Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(for: tableView, at: indexPath)
    }
}


// MARK: - UITableViewDelegate
extension UserProfileTableHandler: UITableViewDelegate {
    
    /// 提供分區標題
    ///
    /// 根據分區類型返回對應的標題文字，用於在 `UITableView` 的分區頂部顯示。
    ///
    /// ### 設計細節
    /// - 間距處理：
    ///   第一個分區（`userInfo`）為了解決與導航欄大標題過近的問題，返回空白標題（" "）以增加間距。
    ///   其他分區則根據 `UserProfileSection.title` 返回對應的標題文字。
    ///
    /// ### 注意事項
    /// - 此邏輯依賴於 `UserProfileSection.requiresSpacing` 屬性，確保間距需求與分區設計保持一致性。
    /// - 詳情請參考筆記《分區標題與導航標題間距的處理》。
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = UserProfileSection(rawValue: section) else { return nil }
        
        // 如果需要間距，返回空白標題；否則返回正常標題
        return section.requiresSpacing ?  " " : section.title
    }
    
    /// 處理分區內行點擊事件
    ///
    /// 根據點擊的行所屬分區執行相應的操作。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = UserProfileSection(rawValue: indexPath.section) else { return }
        
        // 根據分區類型進行點擊處理
        switch section {
        case .userInfo:
            break
        case .generalOptions:
            handleGeneralOptionSelection(at: indexPath.row)
        case .socialLinks:
            handleSocialLinkSelection(at: indexPath.row)
        case .logout:
            handleLogoutSelection()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// 處理 `GeneralOption` 的點擊事件
    ///
    /// - Parameter row: 點擊的行索引。
    /// - 說明: 根據行數據的 `action` 屬性執行對應的導航操作。
    private func handleGeneralOptionSelection(at row: Int) {
        let rows = dataSource.rows(for: .generalOptions)
        guard row < rows.count else { return }
        
        let selectedAction = rows[row].action
        
        // 執行相應的導航操作
        switch selectedAction {
        case .editProfile:
            delegate?.navigateToEditProfile()
        case .orderHistory:
            delegate?.navigateToOrderHistory()
        case .favorites:
            delegate?.navigateToFavorites()
        case .none:
            break
        }
    }
    
    /// 處理社交媒體連結的點擊事件
    ///
    /// - Parameter row: 點擊的行索引。
    /// - 說明: 打開對應的社交媒體連結，透過委派通知控制器處理。
    private func handleSocialLinkSelection(at row: Int) {
        let rows = dataSource.rows(for: .socialLinks)
        guard row < rows.count else { return }
        let socialLink = rows[row]
        delegate?.didSelectSocialLink(title: socialLink.title, urlString: socialLink.urlString ?? "")
    }
    
    /// 處理登出按鈕的點擊事件
    ///
    /// - 說明: 顯示登出確認彈窗，並執行登出邏輯。
    private func handleLogoutSelection() {
        delegate?.confirmLogout()
    }
    
}
