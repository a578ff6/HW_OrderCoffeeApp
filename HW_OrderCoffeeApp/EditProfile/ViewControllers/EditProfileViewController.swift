//
//  EditProfileViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/24.
//

// MARK: - 筆記：EditProfileViewController
/**
 
 ## 筆記：EditProfileViewController

` * What`
 
 - `EditProfileViewController` 是用於編輯個人資料的主要控制器，負責處理以下功能：
 
 1. 顯示用戶的個人資料，包括大頭照、姓名、電話、地址、生日與性別。
 2. 支援用戶的資料編輯，並即時更新模型。
 3. 提供保存按鈕，將修改後的資料同步更新至 `Firebase`（包括圖片上傳和文字資料更新）。
 4. 使用模組化設計（如 `EditProfileTableHandler` 和 `ProfileImageCoordinator`），提升可讀性與維護性。

 ----------------------

 `* Why`
 
 - 此控制器的設計目標：
 
 `1. 資料驅動 UI：`
    - 將數據拉取後更新模型，並以模型驅動 TableView 的顯示。
 
 `2. 分離邏輯：`
    - 使用 `ProfileImageCoordinator` 將圖片選取與上傳的邏輯與控制器分離。
    - 使用 `EditProfileTableHandler` 負責 TableView 的欄位配置與交互處理。
 
 `3. 提升用戶體驗：`
    - 即時顯示大頭照與其他資料的更新。
    - 若關鍵欄位（如姓名）未填，給出即時錯誤提示，避免不必要的後端請求。

 ----------------------

 `* How`

 `1. 架構設計`
 
 - `主視圖`：`editProfileView` 包含 `UITableView`，顯示所有欄位。
 - `模型`：`profileEditModel` 儲存個人資料的暫存版本，所有修改會即時更新於此模型。
 - `導航欄`：使用 `EditProfileNavigationBarManager` 配置標題與保存按鈕。
 - `圖片邏輯`：`ProfileImageCoordinator` 處理大頭照的選取與上傳，減少控制器負擔。
 - `表格邏輯`：`EditProfileTableHandler` 負責欄位的顯示與交互邏輯，確保低耦合設計。

 ---

 `2. 主要方法解釋`

 `- 資料加載`
 
 - 從 Firebase 拉取用戶資料，並更新 `profileEditModel`。
 - 加載完成後，通過 `setupTableHandler` 初始化 TableView 的配置，並顯示用戶資料。
 
 ```swift
 private func fetchCurrentUserDetails()
 ```

 ---

 `- 保存按鈕點擊事件`
 
 - `驗證欄位`：檢查 `fullName` 是否為空，若無法通過，提示用戶補充。
 - `圖片上傳`：調用 `ProfileImageCoordinator` 將用戶選取的圖片上傳至 Firebase Storage，並獲取其下載 URL。
 - `資料更新`：將完整的個人資料更新至 Firebase Firestore。
 
 ```swift
 @objc private func saveButtonTapped()
 ```

 ---

 `- 圖片選取與更新`
 
 - 通知 `ProfileImageCoordinator` 顯示圖片選取器，並將選取的圖片暫存於 `ProfileImageUploader`。
 - 即時更新大頭照顯示，並清空舊的圖片 URL。
 
 ```swift
 func didTapChangePhoto()
 ```
 
 ---

 `3. 目標`

 - `分離職責，提升可讀性：`
 
    - `saveButtonTapped` 已分解為多個小函數，依序執行欄位驗證、圖片上傳、資料保存與錯誤處理。
    - 每個函數的命名即描述其目的，便於快速理解。

 - `避免耦合，降低複雜度：`
 
    - 圖片邏輯與表格邏輯已透過 `ProfileImageCoordinator` 和 `EditProfileTableHandler` 分離，控制器只需負責主流程。

 ----------------------

 `* 關鍵設計點`
 
 `1. 模組化邏輯：`
 
    - `ProfileImageCoordinator` 處理圖片選取與上傳。
    - `EditProfileTableHandler` 處理 TableView 的欄位配置與交互。

 `2. 資料驅動：`
 
    - 從 Firebase 加載資料後，更新 `profileEditModel` 並驅動 UI 顯示。

 `3. 高可維護性：`
 
    - 主流程邏輯清晰，細節交由專責模組處理，便於調整與擴展。
 */


// MARK: - profileEditModel 在 EditProfileViewController 中的使用與設計考量 _ 在編輯個人資料中使用暫存模型的原因和方法（重要）
/**
 
 ## profileEditModel 在 EditProfileViewController 中的使用與設計考量 _ 在編輯個人資料中使用暫存模型的原因和方法
 
 `* What:`
 
 - 在 `EditProfileViewController` 中的 `fetchCurrentUserDetails()` 方法裡，使用 `profileEditModel` 來保存從 Firebase 獲取的使用者資料，並將其存儲到控制器的屬性 `profileEditModel` 中。
 - 這樣做的目的是在獲取資料後能夠暫存使用者的個人資料，供後續編輯過程和保存操作使用。

 ----------------------------------
 
 `* Why:`
 
 - 這樣設置的原因是為了支持整個編輯過程中的數據持久性。
 - 在用戶進行編輯時，這些資料不會立即提交到 Firebase，而是暫時保存在本地（`profileEditModel` 中），等到用戶確定保存後，才將所有變更一次性更新到 Firebase。這樣設計有以下幾個好處：
 
 1. `減少 Firebase 請求次數`：在用戶完成所有更改前，資料只在本地更改，最後一次性提交減少了對後端的頻繁請求。
 2. `方便支持編輯和保存流程`：用戶可以進行多次編輯，每次編輯的更改會直接修改 `profileEditModel`，而不需要每次都直接操作 UI，這樣也提升了代碼的可讀性和可維護性。
 3. `用戶體驗`：用戶只需要在點擊保存按鈕時提交變更，這樣的交互方式更加自然，且允許用戶在確認所有信息正確後再決定是否保存。

 ----------------------------------

 `* How:`
 
 `1. 保存獲取的資料：`
 
 - 在 `fetchCurrentUserDetails()` 方法中，從 Firebase 獲取資料後，使用 `self.profileEditModel = profileEditModel` 來暫存這些數據，讓控制器的屬性 `profileEditModel` 存儲當前用戶的編輯資料。
 
 ```swift
 private func fetchCurrentUserDetails() {
     HUDManager.shared.showLoading(text: "Loading Details...")
     Task {
         do {
             let profile = try await EditUserProfileManager.shared.loadCurrentUserProfile()
             self.profileEditModel = profile                 // 更新數據
             setupTableHandler()                             // 確保數據完成後再設置 TableView
             print("用戶資料加載成功：\(profile)")
         } catch {
             print("加載用戶資料失敗：\(error)")
         }
         HUDManager.shared.dismiss()
     }
 }
 ```

 `2. 後續操作使用 profileEditModel：`
 
 - 在其他操作（如編輯 UI 或保存更改）中直接使用 `profileEditModel`，例如在保存按鈕按下時，將這些暫存的數據提交到 Firebase 進行更新。
 
    ```swift
    @objc private func saveButtonTapped() {
        guard let profileEditModel = profileEditModel else { return }
        // 修改和驗證資料後進行更新
        Task {
            try await UserProfileDataLoader.shared.updateCurrentUserProfile(profileEditModel)
        }
    }
    ```
 ----------------------------------

 `* 總結：`
 
 - 如果不需要持續引用 `profileEditModel`，只用於設置 UI，那麼可以在獲取數據後直接配置 UI，而不將數據保存到屬性中。
 - 但這樣在需要引用該資料的情況下，可能會使代碼變得更複雜，尤其是在編輯過程中。
 */



// MARK: - (v)

import UIKit

/// 負責處理編輯個人資料頁面的主控制器
///
/// `EditProfileViewController` 是一個提供用戶編輯個人資料功能的頁面，
/// 包含處理資料顯示、交互邏輯以及將更新結果儲存至遠端的相關業務邏輯。
class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 用戶的個人資料數據模型，用於顯示和編輯
    private var profileEditModel: ProfileEditModel?
    
    /// 主視圖，包含個人資料的 TableView
    private let editProfileView = EditProfileView()
    
    /// 負責管理導航欄設定的工具類別
    private var navigationBarManager: EditProfileNavigationBarManager?
    
    /// 負責處理 TableView 的邏輯，例如配置單元格和處理用戶交互
    private var tableHandler: EditProfileTableHandler?
    
    /// 負責處理個人資料圖片邏輯的協調器
    private var profileImageCoordinator: ProfileImageCoordinator?
    
    
    // MARK: - Lifecycle Methods
    
    /// 設定控制器的主視圖
    override func loadView() {
        view = editProfileView
    }
    
    /// 視圖載入完成後的初始化邏輯
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupProfileImageCoordinator()
        fetchCurrentUserDetails()
    }
    
    // MARK: - Setup Methods
    
    /// 配置導航欄，包括標題和保存按鈕
    private func configureNavigationBar() {
        navigationBarManager = EditProfileNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        navigationBarManager?.configureNavigationBarTitle(title: "Edit Profile", prefersLargeTitles: false)
        navigationBarManager?.setupBarButton(title: "Save", style: .done, position: .right, target: self, action: #selector(saveButtonTapped))
    }
    
    /// 初始化並設置 `ProfileImageCoordinator`，用於處理個人資料圖片的邏輯
    private func setupProfileImageCoordinator() {
        profileImageCoordinator = ProfileImageCoordinator(viewController: self)
    }
    
    /// 初始化並設置 `EditProfileTableHandler`，負責 TableView 的邏輯處理
    private func setupTableHandler() {
        tableHandler = EditProfileTableHandler(delegate: self, photoDelegate: self)
        let tableView = editProfileView.getTableView()
        tableView.dataSource = tableHandler
        tableView.delegate = tableHandler
        tableView.reloadData()
    }
    
    // MARK: - Dismiss Keyboard
    
    /// 統一的鍵盤收起方法
    /// - 收起當前視圖中活動的鍵盤
    /// - 使用於各種按鈕操作開始前，確保畫面整潔、避免鍵盤遮擋重要資訊或 HUD
    private func dismissKeyboard() {
        view?.endEditing(true)
    }
    
    // MARK: - Data Fetching
    
    /// 從遠端（ Firebase）加載當前用戶資料並更新介面
    ///
    /// - 該方法會顯示加載指示器，拉取用戶的個人資料後更新 `profileEditModel`，
    /// - 並刷新 TableView 的顯示。（資料驅動UI）
    private func fetchCurrentUserDetails() {
        HUDManager.shared.showLoading(text: "Loading Details...")
        Task {
            do {
                let profile = try await EditUserProfileManager.shared.loadCurrentUserProfile()
                self.profileEditModel = profile                 // 更新數據
                setupTableHandler()                             // 確保數據完成後再設置 TableView
                print("用戶資料加載成功：\(profile)")
            } catch {
                print("加載用戶資料失敗：\(error)")
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Actions
    
    /// 處理保存按鈕的點擊事件
    ///
    /// - 保存用戶修改的資料到遠端，包括圖片上傳與資料更新。
    /// - 若 fullName 關鍵欄位為空，會彈出提示。
    /// - 「驗證資料 -> 上傳圖片 -> 保存資料 -> 處理異常」
    @objc private func saveButtonTapped() {
        dismissKeyboard()
        guard var profileEditModel = profileEditModel else {
            print("無法保存，未加載用戶資料")
            return
        }
        
        if !validateRequiredFields(for: profileEditModel) { return }
        
        HUDManager.shared.showLoading(text: "Saving...")
        Task {
            do {
                // 更新圖片 URL
                try await updateProfileImageIfNeeded(for: &profileEditModel)
                // 保存用戶資料
                try await saveUserProfile(profileEditModel)
            } catch {
                handleSaveError(error)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Helper Methods ( saveButtonTapped )

    /// 驗證必填欄位
    private func validateRequiredFields(for profile: ProfileEditModel) -> Bool {
        if profile.fullName.isEmpty {
            AlertService.showAlert(withTitle: "錯誤", message: "Full Name cannot be empty.", inViewController: self)
            return false
        }
        return true
    }
    
    /// 更新用戶的圖片 URL
    private func updateProfileImageIfNeeded(for profile: inout ProfileEditModel) async throws {
        if let imageURL = try await profileImageCoordinator?.startProfileImageUploadForUser(forUser: profile.uid) {
            profile.profileImageURL = imageURL
            print("圖片上傳成功，URL: \(imageURL)")
        }
    }
 
    /// 保存用戶資料至 Firebase
    private func saveUserProfile(_ profile: ProfileEditModel) async throws {
        try await EditUserProfileManager.shared.updateCurrentUserProfile(profile)
        print("用戶資料保存成功")
    }
    
    /// 處理保存過程中的錯誤
    private func handleSaveError(_ error: Error) {
        print("保存用戶資料失敗：\(error)")
        AlertService.showAlert(withTitle: "錯誤", message: "Failed to save profile. Please try again.", inViewController: self)
    }
    
}

// MARK: - EditProfileTableHandlerDelegate
extension EditProfileViewController: EditProfileTableHandlerDelegate {
    
    /// 更新用戶模型
    ///
    /// 當用戶在 TableView 中修改資料後，通過該方法同步更新數據。
    /// - Parameter model: 修改後的用戶模型
    func updateProfileEditModel(_ model: ProfileEditModel) {
        self.profileEditModel = model
        print("用戶模型已更新：\(model)")
    }
    
    /// 獲取當前的用戶模型
    /// - Returns: 用戶的個人資料模型，若尚未加載則為 `nil`
    func getProfileEditModel() -> ProfileEditModel? {
        return profileEditModel
    }
    
}

// MARK: - PhotoChangeHandlerDelegate
extension EditProfileViewController: PhotoChangeHandlerDelegate {
    
    /// 處理點擊更改大頭照按鈕的事件
    ///
    /// 通過 `profileImageCoordinator` 處理用戶選取的圖片，並更新暫存模型和 UI 顯示。
    func didTapChangePhoto() {
        profileImageCoordinator?.handleChangePhotoButtonTapped { [weak self] selectedImage in
            guard let self = self, let selectedImage = selectedImage else {
                print("用戶未選擇新圖片")
                return
            }
            print("更新 UI 和暫存模型數據")
            // 更新暫存的模型數據，清除舊 URL
            self.profileEditModel?.profileImageURL = nil
            
            // 通知 TableHandler 更新 UI
            let tableView = self.editProfileView.getTableView()
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileImageViewCell {
                cell.updateProfileImageWithImage(with: selectedImage)
            }
        }
    }
    
}
