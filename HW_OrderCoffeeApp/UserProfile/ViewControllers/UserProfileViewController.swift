//
//  UserProfileViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/14.
//


// MARK: - UserProfileViewController 重點筆記
/**
 
 ## UserProfileViewController 重點筆記
 
 `* What`
 
 1.定義： `UserProfileViewController` 是一個專門用於顯示個人資訊頁面的控制器。
 
 2.功能：
 
 - 透過 `TableView` 顯示使用者的個人資訊（如姓名、電子郵件）及相關選項（如編輯資料、歷史訂單）。
 - 負責處理頁面跳轉邏輯（如導航至其他頁面或外部連結）。
 - 整合 `UserProfileView` 作為主視圖，分離視圖與邏輯，提高模組化。
 - 支援從 `Firebase` 獲取個人資料並動態刷新。
 
 ----------------------
 
 `* Why`
 
 `1.單一責任：`

 - `ViewController` 僅負責頁面顯示與互動邏輯，避免直接操作資料或處理複雜業務邏輯。
 - 資料存取與處理交由 `UserProfileManager`，視圖細節交由 `UserProfileView`。
 
 `2.模組化與可讀性：`

 - 使用 `UserProfileTableHandler` 管理 `TableView` 的數據源與互動邏輯，降低控制器的代碼複雜度。
 
 `3.靈活性與可擴展性：`

 - 透過 `UserProfileTableHandlerDelegate`，可以輕鬆添加新的導航或操作功能。
 
 ----------------------

` * How`
 
 `1,結構分層：`

 - 將主視圖封裝為 `UserProfileView`，減少對視圖屬性的直接操作。
 - 使用 `UserProfileNavigationBarManager` 管理導航欄的設置與標題邏輯。
 
 `2.數據處理：`

 - 資料存取與解析交由 `UserProfileManager`。
 - 透過 `loadUserProfile` 方法從 Firebase 動態加載資料，並刷新 TableView。
 
 `3.導航邏輯：`

 - 定義多個 `navigateTo*` 方法處理頁面跳轉，分離業務邏輯與顯示邏輯。
 
 ----------------------

 `* 補充說明`
 
 `1.責任分工`：

 - `UserProfileViewController`：處理頁面跳轉與整體邏輯。
 - `UserProfileView`：管理視圖佈局與 UI 結構。
 - `UserProfileTableHandler`：處理 TableView 的數據源與事件。
 
` 2.靈活應用：`

 - 使用 `Delegate` 模式，實現頁面間的鬆耦合。
 - 通過對 `Firebase` 的異步請求，確保資料的即時性與頁面響應速度。

 */


// MARK: - 使用 `viewWillAppear` 設置 `loadUserProfile` 筆記（重要）
/**
 
 ## 使用 `viewWillAppear` 設置 `loadUserProfile` 筆記

` * What (做了什麼)`
 
 - 在 `UserProfileViewController` 的 `viewWillAppear` 中調用 `loadUserProfile` 方法，以確保每次頁面顯示時，都會重新加載最新的用戶資料（例如姓名、大頭照、信箱）。

 - 程式碼範例如下：

 ```swift
 override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     print("[UserProfileViewController]: viewWillAppear 被觸發")
     loadUserProfile()
 }
 ```

 -------------------------
 
 `* Why (為什麼這樣做)`
 
 `1. 資料一致性：`
 
    - 當用戶在 `EditProfileViewController` 編輯個人資料後返回 `UserProfileViewController` 時，需要即時顯示更新後的資料。
    - 確保頁面展示的資料與後端同步，避免因快取或前端狀態不一致而導致用戶混淆。

 `2. 簡化邏輯：`
 
    - 將資料重新加載的邏輯集中到 `viewWillAppear`，可以簡化資料更新的觸發機制，避免在其他地方手動更新。

 `3. 用戶體驗：`
 
    - 用戶在切換回 `UserProfileViewController` 時，自動更新資料，不需要手動刷新操作。

 -------------------------
 
 `* How (怎麼做)`
 
 `1. 在 viewWillAppear 中調用 loadUserProfile：`
 
    - 每次頁面顯示時觸發資料加載邏輯。

 `2. 確保 loadUserProfile 實現正確：`
 
    - 通過 `Task` 調用後端的 API 獲取用戶資料，並在加載成功後刷新 UI。

    ```swift
    private func loadUserProfile() {
        print("開始執行 loadUserProfile()")
        Task {
            do {
                print("開始請求 UserProfileManager 獲取用戶資料")
                let profile = try await UserProfileManager.shared.loadUserProfile()
                print("用戶資料加載成功：\(profile)")
                self.userProfile = profile
                self.userProfileView.tableView.reloadData()
                print("表格重新加載完成")
            } catch {
                print("加載用戶資料失敗：\(error.localizedDescription)")
                showError(error)
            }
        }
    }
    ```

 -------------------------

 `* 注意事項`
 
 `1. 效能考量：`
 
    - `viewWillAppear` 每次顯示頁面都會觸發，適用於資料更新頻率較低的場景。
    - 如果資料加載過於頻繁，可以考慮加入條件判斷或快取機制（例如 `needsReload` 標誌）。

 `2. 避免多餘請求：`
 
    - 若不希望每次進入頁面都加載資料，可以在 `EditProfileViewController` 返回時設置標誌，僅在資料更改後觸發重新加載。

` 3. 用戶體驗：`
 
    - 確保加載過程有合適的指示（例如 `HUD`），並在加載失敗時提供清晰的提示。

 -------------------------

 `* 結論`
 
 - 採用 `viewWillAppear` 調用 `loadUserProfile` 是一種簡單且有效的方式，適合需要頻繁同步後端資料的小型應用場景。
 - 但需根據具體需求調整，例如引入條件判斷或快取以優化效能。

 */


// MARK: - 登出功能相關邏輯
/**
 ## 登出功能相關邏輯：
 
    * 確認登出：
        - 當用戶點擊登出按鈕時，先顯示一個確認提示框，以防止錯誤操作。
    
    * 執行登出：
        - 在用戶確認登出後，顯示活動指示器，並調用 FirebaseController 進行登出操作。

    * 處理結果：
        - 如果登出成功，則通過 NavigationHelper 重設 App 的根視圖控制器並返回到登入頁面。
        - 如果登出失敗，則顯示錯誤訊息，通知用戶稍後再試。
 
    * 總結流程：
        - 用戶點擊登出按鈕後，UserProfileViewController 會先顯示確認提示框。
        - 用戶確認登出後，UserProfileViewController 調用 FirebaseController 進行登出操作，並顯示活動指示器。
        - 如果登出成功，NavigationHelper 會重設 App 的根視圖控制器為 HomePageViewController，清除所有之前的狀態。
        - 如果登出失敗，則顯示錯誤訊息，通知用戶稍後再試。
 */


// MARK: - (v)

import UIKit

/// 個人資訊頁面
///
/// `UserProfileViewController` 負責顯示使用者的個人資料頁面，
/// 包括名字、電子郵件及其他選項（如編輯個人資料、歷史訂單、社交媒體連結）。
/// 此控制器專注於資料呈現與頁面跳轉，避免直接處理資料存取與操作。
///
/// - 功能特點:
///   - 使用 `UserProfileView` 作為主視圖，統一管理頁面佈局。
///   - 透過 `UserProfileTableHandler` 管理 TableView 的數據源與互動邏輯。
///   - 提供導航功能，處理頁面間的跳轉邏輯。
///   - 支援從 Firebase 獲取並顯示用戶資料。
class UserProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 當前使用者的個人資料
    private var userProfile: UserProfile?
    
    /// 自訂的主視圖，包含 TableView 用於顯示個人資訊
    private let userProfileView = UserProfileView()
    
    /// 負責管理 TableView 的 DataSource 與 Delegate
    private let tableHandler = UserProfileTableHandler()
    
    /// 導航欄管理器，負責設定導航標題等功能
    private var navigationBarManager: UserProfileNavigationBarManager?
    
    
    // MARK: - Lifecycle Methods
    
    /// 加載主視圖
    ///
    /// 使用 `UserProfileView` 作為主視圖，統一管理頁面 UI。
    override func loadView() {
        view = userProfileView
    }
    
    /// 視圖載入完成
    ///
    /// 設置導航欄、TableView 與其他必要配置。
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    /// 畫面即將顯示時更新資料
    ///
    /// 在畫面即將顯示前，透過 `loadUserProfile` 獲取最新用戶資料並刷新 UI。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[UserProfileViewController]: viewWillAppear 被觸發")
        loadUserProfile()
    }
    
    // MARK: - Setup Methods
    
    /// 設定導航欄標題
    ///
    /// 使用 `UserProfileNavigationBarManager` 來管理導航欄的標題設定。
    private func setupNavigationBar() {
        navigationBarManager = UserProfileNavigationBarManager(navigationItem: self.navigationItem, navigationController: self.navigationController)
        navigationBarManager?.configureNavigationBarTitle(title: "User Profile", prefersLargeTitles: true)
    }
    
    /// 初始化並設定 TableView
    ///
    /// - 將 `tableHandler` 設為 TableView 的 DataSource 和 Delegate
    /// - 設置 `tableHandler` 的委派給當前 ViewController
    private func setupTableView() {
        let tableView = userProfileView.userProfileTableView
        tableView.delegate = tableHandler
        tableView.dataSource = tableHandler
        tableHandler.delegate = self
    }
    
    // MARK: - Fetch Data
    
    /// 加載使用者的個人資料
    ///
    /// 通過 `UserProfileManager` 從 Firebase 獲取使用者資料，
    /// 並將資料加載至 `userProfile`，更新 UI 顯示。
    private func loadUserProfile() {
        Task {
            do {
                let profile = try await UserProfileManager.shared.loadUserProfile()
                print("[UserProfileViewController]: 用戶資料加載成功：\(profile)")
                self.userProfile = profile
                self.userProfileView.userProfileTableView.reloadData()  // 刷新表格
            } catch {
                print("[UserProfileViewController]: 加載用戶資料失敗：\(error.localizedDescription)")
                AlertService.showAlert(withTitle: "Error", message: "Failed to load user profile. Please try again later.", inViewController: self)
            }
        }
    }
    
    // MARK: - Navigation
    
    /// 執行登出操作
    ///
    /// 嘗試登出使用者並導回登入畫面，若失敗則顯示錯誤訊息。
    private func executeLogout() async {
        do {
            try FirebaseController.shared.signOut()
            NavigationHelper.navigateToHomePageNavigation()
        } catch {
            print("[UserProfileViewController]: 登出失敗 - \(error.localizedDescription)")
            AlertService.showAlert(withTitle: "登出失敗", message: "無法登出，請稍後再試。", inViewController: self)
        }
    }
    
}

// MARK: - UserProfileTableHandlerDelegate
extension UserProfileViewController: UserProfileTableHandlerDelegate {

    /// 提供最新的使用者資料給 TableHandler
    func getUserProfile() -> UserProfile? {
        return userProfile
    }
    
    /// 導航到「編輯個人資料」頁面
    func navigateToEditProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editProfileVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.editProfileViewController) as? EditProfileViewController else {
            print("[Error]: Failed to instantiate EditProfileViewController")
            return
        }
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    /// 導航到「歷史訂單」頁面
    func navigateToOrderHistory() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let orderHistoryVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.orderHistoryViewController) as? OrderHistoryViewController else {
            print("[Error]: Failed to instantiate OrderHistoryViewController")
            return
        }
        self.navigationController?.pushViewController(orderHistoryVC, animated: true)
    }

    /// 導航到「我的最愛清單」頁面
    func navigateToFavorites() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let favoritesVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.favoritesViewController) as? FavoritesViewController else {
            print("[Error]: Failed to instantiate FavoritesViewController")
            return
        }
        self.navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    // MARK: - Socail Links
    
    /// 處理點擊社交媒體連結的行為
    func didSelectSocialLink(title: String, urlString: String) {
        guard let url = URL(string: urlString) else { return }
        AlertService.showAlert(withTitle: title, message: "確定要前往該網頁？", inViewController: self, confirmButtonTitle: "前往", cancelButtonTitle: "取消", showCancelButton: true) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Logout Setup
    
    /// 顯示登出確認彈窗並執行登出
    func confirmLogout() {
        AlertService.showAlert(withTitle: "登出", message: "您確定要登出嗎？", inViewController: self, showCancelButton: true) { [weak self] in
            Task {
                await self?.executeLogout()
            }
        }
    }
}
