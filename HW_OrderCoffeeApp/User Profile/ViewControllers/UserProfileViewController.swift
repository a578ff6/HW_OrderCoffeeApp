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


// MARK: - 已經使用present到編輯頁面（沒有使用tableview）
/*
 import UIKit
 import Kingfisher
 import Firebase

 /// 個人資訊頁面
 ///
 /// `UserProfileViewController` 顯示使用者的個人資訊，包括名字、電子郵件和頭像。會在載入時設置使用者資料，並且實現 `UserDetailsReceiver` 協議來接收來自其他視圖控制器的使用者資訊。
 class UserProfileViewController: UIViewController {

     // MARK: - Properties
     
     /// 用來顯示個人資訊的自定義視圖
     private let userProfileView = UserProfileView()
     
     /// 保存使用者詳細資訊
     private var userDetails: UserDetails?
     
     /// 處理照片選擇與上傳的管理器
     private var photoPickerManager: PhotoPickerManager!
     

     // MARK: - Lifecycle Methods
     
     override func loadView() {
         view = userProfileView
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupChangePhotoButtonAction()
         setupLogoutButtonAction()
         setupEditProfileButtonAction()  // 設置 Edit Profile 按鈕的動作
         photoPickerManager = PhotoPickerManager(viewController: self)
         ActivityIndicatorManager.shared.startLoading(on: view)          // 開始活動指示器
         configureUserData()                                             // 配置使用者資料
     }
     
     
     // MARK: - Configuration

     /// 設置使用者資料顯示在視圖上
     ///
     /// 若 `userDetails` 有值，則使用其資料填充 `userProfileView` 的相關 UI 元件。否則，顯示預設圖片或文字。
     private func configureUserData() {
         guard let userDetails = userDetails else {
             userProfileView.nameLabel.text = "userName"
             userProfileView.emailLabel.text = "user@example.com"
             userProfileView.profileImageView.image = UIImage(named: "UserSymbol")
             ActivityIndicatorManager.shared.stopLoading()
             return
         }
         
         userProfileView.nameLabel.text = userDetails.fullName
         userProfileView.emailLabel.text = userDetails.email
         
         // 加載大頭照
         if let profileImageURL = userDetails.profileImageURL {
             userProfileView.profileImageView.kf.setImage(
                 with: URL(string: profileImageURL),
                 placeholder: UIImage(named: "UserSymbol"),
                 options: nil,
                 completionHandler: { result in
                     // 無論成功或失敗，停止活動指示器
                     ActivityIndicatorManager.shared.stopLoading()
                 }
             )
         } else {
             userProfileView.profileImageView.image = UIImage(named: "UserSymbol")
             ActivityIndicatorManager.shared.stopLoading()
         }
     }

     
     // MARK: - Setup Button Actions
     
     /// 設置變更大頭照按鈕的點擊事件
     private func setupChangePhotoButtonAction() {
         userProfileView.changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
     }
     
     /// 設置登出按鈕的點擊事件
     private func setupLogoutButtonAction() {
         userProfileView.logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
     }
     
     /// 設置 Edit Profile 按鈕的點擊事件
     private func setupEditProfileButtonAction() {
         userProfileView.editProfileButton.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
     }
     
  
     // MARK: - Actions
     
     /// 處理更改大頭照按鈕的點擊事件
     ///
     /// 當用戶點擊按鈕時，顯示選擇照片的選項，然後上傳選擇的圖片並更新大頭照。
     @objc private func changePhotoButtonTapped() {
         photoPickerManager.presentPhotoOptions { [weak self] selectedImage in
             guard let image = selectedImage, let uid = self?.userDetails?.uid else { return }
             self?.userProfileView.profileImageView.image = image
             
             ActivityIndicatorManager.shared.startLoading(on: self!.view)
             FirebaseController.shared.uploadProfileImage(image, for: uid) { result in
                 switch result {
                 case .success(let url):
                     FirebaseController.shared.updateUserProfileImageURL(url, for: uid) { updateResult in
                         ActivityIndicatorManager.shared.stopLoading()
                         switch updateResult {
                         case .success:
                             self?.userDetails?.profileImageURL = url
                             print("Profile image updated successfully")
                         case .failure(let error):
                             print("Failed to update profile image URL: \(error)")
                         }
                     }
                 case .failure(let error):
                     ActivityIndicatorManager.shared.stopLoading()
                     print("Failed to upload image: \(error)")
                 }
             }
         }
     }
     
     /// 處理「Edit Profile」按鈕點擊事件，推送到 EditProfileViewController
     @objc private func editProfileButtonTapped() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         if let editProfileVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.editProfileViewController) as? EditProfileViewController {
             editProfileVC.setupWithUserDetails(userDetails)
             editProfileVC.delegate = self // 設置為 delegate 以接收更新資料

             let navController = UINavigationController(rootViewController: editProfileVC)
             navController.modalPresentationStyle = .pageSheet
             
             if let sheet = navController.sheetPresentationController {
                 sheet.detents = [.large()]
             }
             
             present(navController, animated: true, completion: nil)
         }
     }
     
     /// 處理登出按鈕的點擊事件
     @objc private func logoutButtonTapped() {
         AlertService.showAlert(withTitle: "登出", message: "您確定要登出嗎？", inViewController: self, showCancelButton: true) {
             [weak self] in self?.executeLogout()
         }
     }
     
     /// 處理登出邏輯
     ///
     /// 在用戶確認登出後，應該執行登出操作並顯示活動指示器。這樣可以告知用戶正在處理登出的過程。
     private func executeLogout() {
         ActivityIndicatorManager.shared.startLoading(on: view)
         
         FirebaseController.shared.signOut { [weak self] result in
             ActivityIndicatorManager.shared.stopLoading()
             switch result {
             case .success:
                 NavigationHelper.navigateToLogin(from: self!) // 登出成功後，返回到登入頁面
             case .failure(let error):
                 AlertService.showAlert(withTitle: "登出失敗", message: "無法登出，請稍後再試。", inViewController: self!)
             }
         }
     }

 }


 // MARK: - UserDetailsReceiver Delegate

extension UserProfileViewController: UserDetailsReceiver {
    
    /// 實現 UserDetailsReceiver 協議來接收使用者詳細資訊並更新 UI
    func receiveUserDetails(_ userDetails: UserDetails?) {
        print("Received user details: \(String(describing: userDetails))")
        self.userDetails = userDetails
        configureUserData()
    }
}
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

 ##. navigateToFavorites 中使用 getCurrentUserDetails：
 
    * 功能： 在使用者點擊進入「我的最愛」清單時，透過 Firebase 獲取最新的 UserDetails，特別是最新的「我的最愛」資料，避免顯示舊資料。

    * 為什麼需要 getCurrentUserDetails：
        - 即時同步資料： 由於「我的最愛」資料會在多個地方被更新，例如在 DrinkDetailViewController 中添加或移除「我的最愛」，所以每次進入 FavoritesViewController 前，應確保最新的資料。
        - 減少資料不一致： 避免顯示未更新的最愛清單，確保所有資料都是從 Firebase 獲取的最新狀態。
 
    * 工作流程：
        - 在 navigateToFavorites 中，透過 getCurrentUserDetails 從 Firebase 取得最新的 userDetails。
        - 確保最新的使用者資料（包括 favorites）傳遞到 FavoritesViewController，以便展示正確的內容。
 
    * 補充：
        - getCurrentUserDetails 的使用想法：由於「我的最愛」資料可能經常變動，使用 getCurrentUserDetails 保持資料即時同步是比較保險的方式，尤其是在多個頁面或操作會影響 userDetails 的情況下。

 -----------------------------------------------------------------------------------------------------------------------------

 ## receiveUserDetails 與 navigateToFavorites 的差異用途：
 
 &. receiveUserDetails 的作用：
 
    * receiveUserDetails 是用來接收資料的協議方法，當從其他控制器（例如 MainTabBarController）傳遞或更新 userDetails 時，receiveUserDetails 會被觸發，將新的 userDetails 儲存在控制器內並更新 UI。
    * 它主要用來即時更新畫面上的使用者資訊，但無法主動從 Firebase 獲取最新資料，也無法自動更新「我的最愛」的狀態。
 
 &. navigateToFavorites 的作用：
 
    * 當用戶點擊「我的最愛」按鈕，進入 FavoritesViewController 前，navigateToFavorites 會先透過 getCurrentUserDetails 從 Firebase 獲取最新的使用者資料，確保「我的最愛」清單狀態是最新的。
    * 這樣可以保證 FavoritesViewController 顯示的資料是正確且即時的。
    * receiveUserDetails 無法處理到這部分的資料更新，因此需要 navigateToFavorites 主動從 Firebase 獲取資料來補足。

 &. 具體操作流程：
 
    * UserProfileViewController 透過 receiveUserDetails 接收到新的 userDetails 資訊後，會儲存在內部變數並即時更新畫面。
    * 當使用者點擊「我的最愛」按鈕時，navigateToFavorites 會透過 getCurrentUserDetails 再次從 Firebase 獲取最新的使用者資料，這樣可以確保進入 FavoritesViewController 時顯示的「我的最愛」清單是最新的。
    * FavoritesViewController 加載時，會根據這些最新的 userDetails 顯示使用者收藏的飲品。

 &. 總結：
    
    * receiveUserDetails 是用來接收並更新當前顯示的使用者資訊，而 navigateToFavorites 則是在進入「我的最愛」頁面前，通過 Firebase 獲取最新資料以進行最終確認。兩者配合確保呈現給使用者的資料是最新的。
 
 -----------------------------------------------------------------------------------------------------------------------------

 ##. 依照「導航流程」和「資料流程」，FavoritesViewController 更新「我的最愛」這部分，適合使用 getCurrentUserDetails，而不是設置委託。
    
    * 由於我一開始是採用設置一個處理更新我的最愛委託，來處理，結果導致無法立即更新 FavoritesViewController。
 
 &. 資料同步性：
 
    * 使用 getCurrentUserDetails 可以確保每次進入 FavoritesViewController 時，從 Firebase 取得的資料是最新的。這對於多設備登入或其他情境下，資料變動頻繁的 App 來說，能有效保持資料的一致性。
    * 如果改用委託來傳遞資料，會依賴於上次更新的資料，導致 FavoritesViewController 顯示的「我的最愛」並不是最新的，尤其是在其他地方修改了 favorites（例如其他裝置同步操作）。

 &. 資料流的簡化：
 
    * 透過 getCurrentUserDetails，你可以在任何需要的時刻，簡單地獲取完整的使用者資料，不僅限於「我的最愛」，還可以同步其他可能變動的資訊（例如使用者的姓名、頭像、訂單等）。
    * 委託的方式則會增加資料傳遞的複雜度，並且需要確保每個修改 favorites 的操作都能正確觸發委託更新。這不如直接從 Firebase 重新獲取最新資料來得穩定和安全。
 
 &. 操作的一致性
    
    * 使用 getCurrentUserDetails 能夠在導航到 FavoritesViewController 之前，統一透過 Firebase 取得最新資料，這讓資料更新的流程更加一致和可靠。
    * 如果使用委託方式來更新「我的最愛」，會在不同控制器之間導致資料不同步的情況發生（例如從 DrinkDetailViewController 加入「我的最愛」後，沒有及時更新到 FavoritesViewController）。
 
 &. Firebase 資料為權威資料來源：
 
    * 在 App 中，Firebase 是主要的資料儲存來源，這意味著每次進入 FavoritesViewController 時，從 Firebase 獲取最新資料是保持資料同步的最佳方式。
    * 委託雖然可以即時更新，但它不能保證資料與 Firebase 的一致性，尤其在多設備或多來源變更資料的情況下。

 */


// MARK: - 備用
/*
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
        setupTableView()
        tableHandler.delegate = self
    }
    
    // MARK: - Setup Methods

    /// 設置表格視圖
    private func setupTableView() {
        tableView = userProfileView.tableView
        tableView.delegate = tableHandler
        tableView.dataSource = tableHandler
    }
    
    // MARK: - Navigation

    /// 導航到`編輯個人資料`頁面
    ///
    /// 初始化 EditProfileViewController 並將 userDetails 傳遞給它，然後以頁面樣式顯示。
    func navigateToEditProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editProfileVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.editProfileViewController) as? EditProfileViewController {
            editProfileVC.setupWithUserDetails(userDetails)
            editProfileVC.delegate = self

            let navController = UINavigationController(rootViewController: editProfileVC)
            navController.modalPresentationStyle = .pageSheet
            
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
            }
            
            present(navController, animated: true, completion: nil)
        }
    }
    
    /// 導航到`我的最愛清單`頁面
    func navigateToFavorites() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let favoritesVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.favoritesViewController) as? FavoritesViewController {
            favoritesVC.userDetails = userDetails        // 將 userDetails 傳遞給 FavoritesViewController
            navigationController?.pushViewController(favoritesVC, animated: true)
        }
    }
    
    // MARK: - Logout
    
    /// 顯示登出確認彈窗並執行登出邏輯
    func confirmLogout() {
        AlertService.showAlert(withTitle: "登出", message:  "您確定要登出嗎？", inViewController: self, showCancelButton: true) { [weak self] in
            self?.executeLogout()
        }
    }
    
    /// 執行登出操作並處理結果
    ///
    /// 成功登出後會導航至登入頁面，失敗則顯示錯誤訊息。
    private func executeLogout() {
        HUDManager.shared.showLoadingInView(view, text: "Logging out...")
        FirebaseController.shared.signOut { [weak self] result in
            HUDManager.shared.dismiss()
            switch result {
            case .success:
                NavigationHelper.navigateToLogin(from: self!)
            case .failure(let error):
                AlertService.showAlert(withTitle: "登出失敗", message: "無法登出，請稍後再試。", inViewController: self!)
            }
        }
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
       userProfileView.tableView.reloadData()
   }
    
}
*/



// MARK: - 修改處理 favorite的結構模式( 測試 同步最新的 UserDetails )

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
        setupTableView()
        tableHandler.delegate = self
    }
    
    // MARK: - Setup Methods

    /// 設置表格視圖
    private func setupTableView() {
        tableView = userProfileView.tableView
        tableView.delegate = tableHandler
        tableView.dataSource = tableHandler
    }
    
    // MARK: - Navigation

    /// 導航到`編輯個人資料`頁面
    ///
    /// 初始化 EditProfileViewController 並將 userDetails 傳遞給它，然後以頁面樣式顯示。
    func navigateToEditProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editProfileVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.editProfileViewController) as? EditProfileViewController {
            editProfileVC.setupWithUserDetails(userDetails)
            editProfileVC.delegate = self

            let navController = UINavigationController(rootViewController: editProfileVC)
            navController.modalPresentationStyle = .pageSheet
            
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
            }
            
            present(navController, animated: true, completion: nil)
        }
    }
  
    /// 導航到`我的最愛清單`頁面
    ///
    /// 進入 `FavoritesViewController` 前，會先從 Firebase 更新最新的使用者詳細資料，確保呈現正確的資料。
    func navigateToFavorites() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let favoritesVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.favoritesViewController) as? FavoritesViewController {
            // 更新UserDetails，確保是最新的
            FirebaseController.shared.getCurrentUserDetails { [weak self] result in
                switch result {
                case .success(let updatedUserDetails):
                    self?.userDetails = updatedUserDetails                  // 更新當前的userDetails
                    favoritesVC.userDetails = updatedUserDetails            // 傳遞最新的userDetails到FavoritesViewController
                    print("最新的favorites: \(updatedUserDetails.favorites.map { $0.drinkId })")
                    
                    let navController = UINavigationController(rootViewController: favoritesVC)
                    navController.modalPresentationStyle = .fullScreen
                    self?.present(navController, animated: true, completion: nil)
                    
                case .failure(let error):
                    print("無法更新 userDetails: \(error)")
                }
            }
        }
    }
    
    // MARK: - Logout Setup
    
    /// 顯示登出確認彈窗並執行登出邏輯
    func confirmLogout() {
        AlertService.showAlert(withTitle: "登出", message:  "您確定要登出嗎？", inViewController: self, showCancelButton: true) { [weak self] in
            self?.executeLogout()
        }
    }
    
    /// 執行登出操作
    ///
    /// 成功登出後會導航至登入頁面，失敗則顯示錯誤訊息。
    private func executeLogout() {
        HUDManager.shared.showLoadingInView(view, text: "Logging out...")
        FirebaseController.shared.signOut { [weak self] result in
            HUDManager.shared.dismiss()
            switch result {
            case .success:
                NavigationHelper.navigateToLogin(from: self!)
            case .failure(let error):
                AlertService.showAlert(withTitle: "登出失敗", message: "無法登出，請稍後再試。", inViewController: self!)
            }
        }
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
