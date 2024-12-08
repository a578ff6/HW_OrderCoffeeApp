//
//  UserProfileViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/14.
//

// MARK: - 未重構成TableView的部分
/*
 大頭照、使用者名稱、信箱
 
 按鈕：
 編輯使用者資料（地址、電話、使用者名稱）
 
 歷史訂單
 
 我的最愛
 
 登出按鈕
 
 ----------------------
 
 設置步驟：
 先處理顯示使用者資料的功能。確保頁面能正確顯示使用者的基本資訊，後續添加其他功能（選取照片功能）

 大致流程：
 ##設置Firebase連接，並且在使用者登入後正確地從後端獲取資料。
 將資料顯示在個人資料頁面上，確保資料的顯示格式、佈局和邏輯都正確。
 確認資料顯示無誤後，再處理選取照片的功能，讓使用者可以修改他們的個人資料照片。
 
 ------------------------- ------------------------- ------------------------- -------------------------

 A. UserProfileViewController 負責顯示使用者的個人資訊，如名稱、電子郵件和頭像。這個視圖控制器會接收來自其他視圖控制器的使用者資訊，並在畫面上顯示。

    * 配置方法 (Configuration):
        - 根據 userDetails 的內容來設置 UI 元素的顯示。如果 userDetails 為 nil，顯示預設值。若 userDetails 包含頭像圖片 URL，使用 Kingfisher 加載圖片，否則顯示預設圖片。
 
    * 協議實現 (UserDetailsReceiver):
        - receiveUserDetails(_:)：接收使用者資訊，並將其存儲在 userDetails 屬性中。接收到資料後，會調用 configureUserData() 更新 UI 顯示。
 
 ------------------------- ------------------------- ------------------------- -------------------------
 
 B. 「receiveUserDetails 中的 configureUserData」 和 「viewDidLoad 中的 configureUserData」 兩者的觸發時機和使用情境差異。
 
    * 觸發時機：
        - viewDidLoad 中的 configureUserData 是在視圖載入時設定初始狀態。
        - receiveUserDetails 中的 configureUserData 是在收到新的使用者資訊時更新 UI。
 
    * 使用情境：
        - viewDidLoad 中的 configureUserData 主要用於設置視圖載入時的預設資料或狀態。
        - receiveUserDetails 中的 configureUserData 用於根據最新的使用者資訊更新 UI 顯示。

 ------------------------- ------------------------- ------------------------- -------------------------
 
 C. 點擊 changePhotoButton 後處理照片選擇並更新 UI。
 
    * 處理點擊 changePhotoButton：
        - 在 changePhotoButtonTapped 中調用 PhotoPickerManager 打開照片選擇器，提供從相簿選擇照片或使用相機拍攝照片的選項。
        - 當用戶選擇照片後，將選擇的圖片顯示在 UI 上，並調用 FirebaseController 上傳照片。
        - 上傳成功後，更新 Firestore 中的圖片 URL，並將新 URL 存儲在 UserDetails 中。
    
    * UI 更新：
        - 在收到新的照片 URL 後，立即更新 profileImageView 中的圖像並將其顯示在 UI 上。
        - 上傳成功後，更新 Firestore 中的圖片 URL，並將新 URL 存儲在 UserDetails 中。
 
    * 錯誤處理：
        - 在照片上傳或URL更新失敗的情況下，可以使用 AlertService 顯示錯誤訊息給用戶。
 
 ------------------------- ------------------------- ------------------------- -------------------------

 D. 登出功能相關邏輯：
 
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
 
 ------------------------- ------------------------- ------------------------- -------------------------

 */


// MARK: - ## UserProfileViewController 筆記 ##

/*
 ## UserProfileViewController 筆記 ##

 A. UserProfileViewController 的職責：
    - 負責顯示使用者的個人資訊，如名稱、電子郵件和頭像。這個視圖控制器會接收來自其他視圖控制器的使用者資訊，並在畫面上顯示。

    * 配置方法 (Configuration)
        - 根據 userDetails 的內容來設置 UI 元素的顯示。如果 userDetails 為 nil，顯示預設值。若 userDetails 包含頭像圖片 URL，使用 Kingfisher 加載圖片，否則顯示預設圖片。
 
    * 協議實現 (UserDetailsReceiver)
        - receiveUserDetails(_:)：接收使用者資訊，並將其存儲在 userDetails 屬性中。接收到資料後，會調用 tableHandler.userDetails 更新 UITableView 顯示。
 
 B. receiveUserDetails 中的資料處理邏輯
 
    * 觸發時機
        - 當 UserProfileViewController 接收到最新的使用者資訊時（通常來自「登入」或「更新了使用者資料」後），透過 receiveUserDetails(_:) 更新顯示內容。
        - receiveUserDetails 中的資料處理邏輯是在收到新的使用者資訊後更新 UI。

    * 使用情境
        -  更新 userDetails 屬性，確保最新資料可用。
        -  通過 tableHandler.userDetails 更新 UITableView 的顯示內容。
        - receiveUserDetails 中的資料處理邏輯用於根據最新的使用者資訊更新 UITableView 中的顯示內容。
 
 C. 登出功能相關邏輯
 
    * 確認登出
        - 當用戶點擊登出按鈕時，先顯示一個確認提示框，以防止錯誤操作。

    * 執行登出
        - 在用戶確認登出後，顯示活動指示器，並調用 FirebaseController 進行登出操作。
 
    * 處理結果
        - 如果登出成功，則通過 NavigationHelper 重設 App 的根視圖控制器並返回到登入頁面。
        - 如果登出失敗，則顯示錯誤訊息，通知用戶稍後再試。
 
 D. UITableViewDelegate 和 UITableViewDataSource 的分工
    
    * UserProfileViewController 負責：
        - 設置 UITableView 的 delegate 和 dataSource。使 UserProfileViewController 主要管理 UITableView 的行為邏輯，例如處理點擊事件的導航或登出邏輯。

    * UserProfileTableHandler 負責：
        - 實際執行 UITableViewDelegate 和 UITableViewDataSource 的具體邏輯，如單元格的配置、行高、以及處理具體的用戶交互邏輯。
  
 -----------------------------------------------------------------------------------------------------------------------------

 ##. navigateToFavorites 方法的調整：
 
    1. 功能變化
        - 原先的實作： 在使用者點擊進入「我的最愛」清單時，透過 getCurrentUserDetails 從 Firebase 獲取最新的 userDetails，並將其傳遞給 FavoritesViewController。
        - 調整後的實作： 簡化 navigateToFavorites 方法，直接實例化並 push FavoritesViewController，不再在此處獲取或傳遞 userDetails。
 
    2. 為什麼不再需要在這裡獲取 userDetails
        - 責任劃分明確： FavoritesViewController 已經在 viewWillAppear 中自行從 Firebase 獲取最新的 userDetails，因此不需要從外部傳遞。
        - 避免資料不一致：讓 FavoritesViewController 自行獲取資料，確保資料的即時性和一致性。
 
    3. 調整後的工作流程
        - 導航： UserProfileViewController 透過 navigateToFavorites 方法，直接 push FavoritesViewController。
        - 資料加載： FavoritesViewController 在 viewWillAppear 中，從 Firebase 獲取最新的 userDetails，並加載收藏的飲品資料。

 -----------------------------------------------------------------------------------------------------------------------------

 ## receiveUserDetails 與 navigateToFavorites 的差異用途：
 
 &. receiveUserDetails 的作用：
 
    * receiveUserDetails 是用來接收資料的協議方法，當從其他控制器（例如 MainTabBarController）傳遞或更新 userDetails 時，receiveUserDetails 會被觸發，將新的 userDetails 儲存在控制器內並更新 UI。
    * 它主要用來即時更新畫面上的使用者資訊，但無法主動從 Firebase 獲取最新資料，也無法自動更新「我的最愛」的狀態。
 
 &. navigateToFavorites 的作用：
 
    * 導航到「我的最愛」頁面： 負責導航到 FavoritesViewController。
    * 簡化流程： 不再在此處獲取或傳遞 userDetails，讓 FavoritesViewController 自行處理資料的獲取。
    * 這樣可以保證 FavoritesViewController 顯示的資料是正確且即時的。
    * receiveUserDetails 無法處理到這部分的資料更新，因此需要 navigateToFavorites 主動從 Firebase 獲取資料來補足。

 &. 具體操作流程：
  
    * UserProfileViewController 透過 receiveUserDetails 接收到新的 userDetails 資訊後，會儲存在內部變數並即時更新畫面。
    * 當使用者點擊「我的最愛」按鈕時，透過 navigateToFavorites 直接導航到 FavoritesViewController。

 &. 總結：
    
    * 責任明確： UserProfileViewController 負責顯示使用者資訊和導航；FavoritesViewController 負責獲取並顯示收藏的飲品資料。
    * 資料一致性： 讓 FavoritesViewController 自行從 Firebase 獲取資料，確保資料的最新和一致。
    * receiveUserDetails 是用來接收並更新當前顯示的使用者資訊，而 navigateToFavorites 則是在進入「我的最愛」頁面前，通過 Firebase 獲取最新資料以進行最終確認。兩者配合確保呈現給使用者的資料是最新的。

 */


// MARK: - 分離 Tab Bar 和 Navigation Bar 標題設定 （重要）
/**
 
 ## 筆記：分離 Tab Bar 和 Navigation Bar 標題設定
 
 - 在` Main Storyboard` 上，我已經將` Tab Bar Item `的名稱設置為 `Profile`。
 - 而在程式碼中，我在 `UserProfileViewController` 裡將 `UIViewController` 的 `title` 屬性設置為 `User Profile`，以顯示在 `Navigation Ba`r 中。
 - 因為 `iOS 預設情況`下，`UIViewController` 的` title` 屬性會同時影響 `Navigation Bar` 的標題 和 `Tab Bar Item` 的標題。
 - 所以當我點擊 Tab Bar Item 進入到 UserProfileViewController 時，Tab Bar Item 的名稱從 Profile 被改為 User Profile。
 - 這種行為是由於 `title` 和 `tabBarItem.title` 預設同步所導致的。
 
 ---------------------------


 `* 問題 (What)`
 
 - 當使用者點擊 `Profile` tab 項目進入到 `UserProfileViewController` 時，發現 `tab bar item` 的名稱會從原本設定的 "`Profile`" 變成 "`User Profile`"。

 ---------------------------

 `* 原因 (Why)`
 
 - 這個問題的發生是因為 iOS 的 `UIViewController` 中 `title` 屬性同時影響了：
 
 1. Navigation Bar 的標題 (`navigationItem.title`)
 2. Tab Bar 的標題 (`tabBarItem.title`)

 - 在 `UserProfileViewController` 中，
 - 這行程式碼將 `title` 設為 "User Profile"，導致 Tab Bar 的 `tabBarItem.title` 也被同步修改。
 - 這是 iOS 的預設行為，當 `title` 被改變時，如果沒有特別指定 `tabBarItem.title`，兩者會保持一致。
 
 ```swift
 /// 設置導航欄的標題
 private func setupNavigationTitle() {
     title = "User Profile"     // 這行程式碼影響
     self.navigationController?.navigationBar.prefersLargeTitles = true
     self.navigationItem.largeTitleDisplayMode = .always
 }
 ```
 
 ---------------------------

 `* 解決方式 (How)`
 
 - 要解決這個問題並保留 `Tab Bar` 的名稱為 "`Profile`"，而 `Navigation Bar` 顯示 "`User Profile`"，可以透過以下步驟進行：

 
 `方法一：`
 
 - 分開設置 `navigationItem.title` 和 `tabBarItem.title`
 - 在 `UserProfileViewController` 中：

 ```swift
 override func viewDidLoad() {
     super.viewDidLoad()
     
     // 設置 Navigation Bar 的標題
     self.navigationItem.title = "User Profile" // 僅影響 Navigation Bar

     // 確保 Tab Bar 的標題不變
     self.tabBarItem.title = "Profile"
 }
 ```

 `方法二：`
 
 - 在 `MainTabBarController` 確保 Tab Bar 標題
 - 在 `MainTabBarController` 中初始化 Tab Bar 項目時，明確設定每個 tab 的標題：

 ```swift
 override func viewDidLoad() {
     super.viewDidLoad()

     if let viewControllers = self.viewControllers {
         viewControllers[TabIndex.profile.rawValue].tabBarItem.title = "Profile"
     }
 }
 ```

 `方法三：`
 
 - 避免修改 `title`，僅修改 `navigationItem.title`
 - 如果不需要使用 `title` 來設置 `Navigation Bar `的標題，可以直接設定 `navigationItem.title`：

 ```swift
 private func setupNavigationTitle() {
     self.navigationItem.title = "User Profile" // 僅影響 Navigation Bar 標題
     self.navigationController?.navigationBar.prefersLargeTitles = true
     self.navigationItem.largeTitleDisplayMode = .always
 }
 ```

 ---------------------------

 `* 補充說明`
 
 - 這種分開設置 `tabBarItem.title` 和 `navigationItem.title` 的情況是非常常見的設計需求。例如：
 - Tab Bar 簡潔顯示 "Profile"，而頁面標題提供更多上下文，如 "User Profile"。
 - Tab Bar 顯示 "Orders"，頁面標題可能顯示 "My Recent Orders"。

 通過以上方式，可以達到 Tab Bar 和 Navigation Bar 標題的分離，提升用戶體驗和設計一致性。
 */


import UIKit
import Kingfisher
import Firebase

/// 個人資訊頁面
///
/// `UserProfileViewController` 顯示使用者的個人資訊，包括名字、電子郵件和頭像。會在載入時設置使用者資料，並且實現 `UserDetailsReceiver` 協議來接收來自其他視圖控制器的使用者資訊。
class UserProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let userProfileView = UserProfileView()
    private let tableHandler = UserProfileTableHandler()
    private var tableView: UITableView!
    
    /// 保存使用者詳細資訊
    private var userDetails: UserDetails?
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        view = userProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupTableView()
        tableHandler.delegate = self
    }
    
    // MARK: - Setup Methods
    
    /// 設置表格視圖
    private func setupTableView() {
        tableView = userProfileView.tableView
        tableView.delegate = tableHandler
        tableView.dataSource = tableHandler
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)            // 增加 tableView 與 large title 的距離
    }
    
    /// 設置導航欄的標題
    private func setupNavigationTitle() {
        self.navigationItem.title = "User Profile" // 只影響 Navigation Bar 標題
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - Navigation
    
    // 導航到`編輯個人資料`頁面
    ///
    /// 初始化 EditProfileViewController 並將 userDetails 傳遞給它，然後以 push 的方式顯示。
    func navigateToEditProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editProfileVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.editProfileViewController) as? EditProfileViewController {
            self.navigationController?.pushViewController(editProfileVC, animated: true)
        }
    }
    
    /// 導航至「我的最愛清單」頁面
    ///
    /// 由於 `FavoritesViewController` 會在 `viewWillAppear` 中自行加載最新的使用者資料，因此不需要在這裡傳遞 `userDetails`。
    func navigateToFavorites() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let favoritesVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.favoritesViewController) as? FavoritesViewController {
            self.navigationController?.pushViewController(favoritesVC, animated: true)
        }
    }
    
    /// 導航至「歷史訂單」頁面
    func navigateToOrderHistory() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let orderHistoryVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.orderHistoryViewController) as? OrderHistoryViewController {
            self.navigationController?.pushViewController(orderHistoryVC, animated: true)
        }
    }
    
    // MARK: - Logout Setup
    
    /// 顯示登出確認彈窗並執行登出邏輯
    func confirmLogout() {
        AlertService.showAlert(withTitle: "登出", message: "您確定要登出嗎？", inViewController: self, showCancelButton: true) { [weak self] in
            Task {
                await self?.executeLogout()
            }
        }
    }
    
    /// 執行登出操作
    private func executeLogout() async {
        HUDManager.shared.showLoadingInView(view, text: "Logging out...")
        do {
            try FirebaseController.shared.signOut()
            NavigationHelper.navigateToLogin(from: self)
        } catch {
            AlertService.showAlert(withTitle: "登出失敗", message: "無法登出，請稍後再試。", inViewController: self)
        }
        HUDManager.shared.dismiss()
    }
    
}

// MARK: - UserDetailsReceiver Delegate

extension UserProfileViewController: UserDetailsReceiver {
   
    /// 實現 `UserDetailsReceiver` 協議，用於接收並更新使用者詳細資訊
    ///
    /// 當接收到使用者資訊時，會更新 `userDetails` 並刷新表格視圖的顯示內容。
   func receiveUserDetails(_ userDetails: UserDetails?) {
       print("Received user details: \(String(describing: userDetails))")
       self.userDetails = userDetails
       tableHandler.userDetails = userDetails
    
       /// 觀察 favorites 的部分
       guard let favorites = userDetails?.favorites else {
           print("No favorites found.")
           return
       }
       print("User favorites: \(favorites.map { $0.drinkId })")
       
       userProfileView.tableView.reloadData()
   }
    
}
