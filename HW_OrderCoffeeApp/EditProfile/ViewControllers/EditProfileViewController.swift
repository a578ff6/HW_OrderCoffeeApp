//
//  EditProfileViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/24.
//

/*
 
 ## EditProfileViewController
 
    - 是負責處理個人資料編輯頁面的主視圖控制器。它管理使用者資料的顯示與更新，並與多個輔助管理器協作來處理具體功能，如照片選擇、表格顯示等。
 
 ## 主要功能包括：
 
    * 資料顯示與更新：
        - 透過 userDetails ，EditProfileViewController 能夠顯示使用者的個人資料，如名字、性別、生日等，並允許使用者進行編輯。
        - configureUserData 方法負責將 userDetails 中的資訊載入到 UI 元件中。
 
    * 照片選擇與上傳：
        - 使用 PhotoPickerManager 處理使用者大頭照的選擇與上傳，並透過 FirebaseController 來上傳圖片並更新相應的 URL。
 
    * 表格處理：
        - 表格的邏輯由 EditProfileTableHandler 處理，EditProfileViewController 將表格的委派和資料來源設置為這個處理類別，以實現表格的顯示和互動。
  
    * 日期選擇器：
        - 支援日期選擇功能，允許使用者選擇或更改生日。當日期選擇器的值變更時，dateChanged 方法會更新 UI 以反映新的選擇。
 
    * 接收與設定使用者資料：
        -使用 setupWithUserDetails 方法來接收並設定使用者資料，並透過 configureUserData 方法來更新 UI，確保使用者的所有資訊正確顯示在頁面上。

    * 資料回傳：
        - 透過 delegate 的方式，將編輯後的使用者資料回傳給 UserProfileViewController，實現資料的更新。
 
 ------------------------- ------------------------- ------------------------- -------------------------

 ## 關於大頭照的處理邏輯( private func updateProfileImage(_ image: UIImage, for uid: String) )：
    
    * 允許這些圖片保留在存儲中：
        - 每次上傳都會生成新的圖片，無需擔心圖片的管理問題。
        - 由於每個用戶的圖片都是根據 UID 命名的，即使用戶多次上傳圖片，也只會覆蓋同一個文件，避免了存儲的浪費。
 
    * 立即上傳：
        - 這是目前的做法，用戶一旦選擇圖片就會立即上傳到 Firebase Storage。
        - 這樣可以確保圖片及時上傳，但會有圖片未被保存到用戶資料中（因為用戶未點擊 Save）的風險。這種方法的優點是即使用戶關閉了App或發生崩潰，圖片也不會丟失。
 
 ------------------------- ------------------------- ------------------------- -------------------------

 ## EditProfileViewController 內大頭照與更換按鈕邏輯處理的原因：
    
    - 大頭照和更換大頭照按鈕，並不屬於 UITableView 的 sectionHeader，而是屬於整個 EditProfileView 的頭部視圖（tableHeaderView）。
    - 因此這部分邏輯由 EditProfileViewController 來處理，而不是 EditProfileTableHandler。
    - https://reurl.cc/5d190M
 
 ## tableHeaderView 和 sectionHeader 的區別
    
    * tableHeaderView：
        - tableHeaderView 是一個 UIView，顯示在 UITableView 的頂部，覆蓋整個表格的寬度，屬於全局視圖。
        - 用來顯示全局資訊，例如用戶大頭照、標題等。
        - 不屬於某個特定的 section，因此不由 UITableViewDelegate 或 UITableViewDataSource 管理，而是由主控制器 (UIViewController) 直接管理。
 
    * sectionHeader：
        - 是顯示在每個 section 頭部的視圖，每個 section 可以有自己的 sectionHeader。
        - 通常由 UITableViewDelegate 管理，在 tableView(_:viewForHeaderInSection:) 方法中配置。
        - 可以在 `tableView(_:viewForHeaderInSection:)` 方法中配置它。
 
    * 由 EditProfileViewController 負責大頭照邏輯：
        - 大頭照和更換大頭照的按鈕屬於 tableHeaderView，是全局視圖的一部分，應該由 EditProfileViewController 管理。
        - EditProfileTableHandler 主要負責處理表格中的每個 cell 的數據和交互邏輯，與表格之外的視圖無關。
 
    * 結構理解：
        - EditProfileView: 包含 UITableView 和大頭照的頭部視圖 (tableHeaderView)。
        - EditProfileViewController: 管理編輯頁面的邏輯，包括大頭照的設定、更換行為，以及表格數據的更新。
        - EditProfileTableHandler: 專注於表格內部每個 cell 的配置與交互，不處理表格以外的視圖邏輯。
 
 ------------------------- ------------------------- ------------------------- -------------------------
 
 ## 使用 weak var delegate: 的適合與不適合情境整理 ##
 
 1. UserProfileViewController 與 UserProfileTableHandler

    * 適合使用 weak var delegate: UserProfileViewController?
 
    - 事件通知需求： UserProfileTableHandler 需要通知 UserProfileViewController 在用戶點擊某個選項時執行操作（如導航到編輯頁面、登出等）。
 
    - 職責分離： UserProfileTableHandler 負責表格視圖的資料顯示與處理，而 UserProfileViewController 負責更高層次的控制邏輯（例如導航、顯示彈窗等）。
 
    - 避免強耦合： 使用 delegate 可以避免兩個類別之間的強耦合，保持代碼的可維護性，並防止內存泄漏。
 
    - 靈活性： 通過 delegate，UserProfileViewController 可以根據 UserProfileTableHandler 的事件觸發來決定執行哪些操作。

 
 2. EditProfileViewController 與 EditProfileTableHandler

    * 不適合使用 weak var delegate: EditProfileViewController?
 
    - 數據流的單向性： EditProfileTableHandler 的主要職責是根據 EditProfileViewController 提供的資料進行顯示，數據流是從 EditProfileViewController 到 EditProfileTableHandler 單向流動，並不需要反向通知。
    
    - 不需要事件通知： EditProfileTableHandler 的行為（如日期選擇、性別選擇）直接在內部處理，不需要通知 EditProfileViewController 來進行額外操作。
 
    - 簡化設計： 保持 EditProfileTableHandler 的簡單性和專注性，不引入不必要的複雜性，有助於程式碼的清晰和。
 
    - 資料更新邏輯： EditProfileViewController 可以直接從 EditProfileTableHandler 獲取更新的用戶資料，而不需要通過 delegate 進行傳遞。


 3. 結論

 - 使用 delegate 的情境： 當子類別（如 TableHandler）需要通知父類別（如 ViewController）執行某些操作或更新 UI 時，適合使用 `weak var delegate:`。
   這樣可以保持良好的職責分離，避免強耦合，並提高靈活性。
   
 - 不使用 delegate 的情境： 當資料流是單向的，且不需要反向通知父類別時，避免使用 delegate 可以簡化代碼結構，減少不必要的複雜性，保持代碼的簡單性和專注性。

 ------------------------- ------------------------- ------------------------- -------------------------

 */

// MARK: - 已經完善
/*
import UIKit

/// 負責處理個人資料編輯頁面的主視圖控制器。它管理使用者資料的顯示與更新。
class EditProfileViewController: UIViewController {

    // MARK: - Properties

    private let editProfileView = EditProfileView()
    private var userDetails: UserDetails?
    private var photoPickerManager: PhotoPickerManager!
    private var tableHandler: EditProfileTableHandler!
    private var datePickerHandler: DatePickerHandler!
    
    weak var delegate: UserDetailsReceiver? // 用來傳遞更新後資料的 delegate

    // MARK: - Lifecycle Methods

    override func loadView() {
        view = editProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupManagers()
        setupTableView()
        configureUserData()
        setupNavigationTitle()
        setupNavigationBar()
        setupKeyboardHandling()
        setupChangePhotoAction()
    }
    
    // MARK: - Setup Methods
    
    /// 初始化管理者
    private func setupManagers() {
        setupPhotoPickerManager()
        setupDatePickerHandler()
    }

    /// 設置導航欄的保存按鈕
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
    }
        
    /// 設置導航欄的標題
    private func setupNavigationTitle() {
        title = "Edit Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    ///初始化照片選擇管理器
    private func setupPhotoPickerManager() {
        photoPickerManager = PhotoPickerManager(viewController: self)
    }

    /// 初始化日期選擇器管理器
    private func setupDatePickerHandler() {
        datePickerHandler = DatePickerHandler(datePicker: UIDatePicker())
        datePickerHandler.onDateChanged = { [weak self] date in
            self?.handleDateChanged(date)
        }
    }
    
    /// 設置 UITableView 和相關的行為
    private func setupTableView() {
        tableHandler = EditProfileTableHandler(userDetails: userDetails, datePickerHandler: datePickerHandler)
        editProfileView.tableView.delegate = tableHandler
        editProfileView.tableView.dataSource = tableHandler
        editProfileView.tableView.separatorStyle = .none
        editProfileView.tableView.backgroundColor = .lightWhiteGray
    }

    /// 設置更改照片按鈕的行為
    private func setupChangePhotoAction() {
        editProfileView.changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
    }
    
    /// 設置鍵盤處理
    private func setupKeyboardHandling() {
        setUpHideKeyboardOntap()
        setupKeyboardObservers(for: editProfileView.tableView)
    }
    
    // MARK: - Actions (Button Handlers)

    /// 保存按鈕的行為
    @objc private func saveButtonTapped() {
        guard var userDetails = userDetails else { return }
        guard validateUserDetails() else { return }

        // 從 tableHandler 中獲取用戶修改後的資料
        userDetails.fullName = tableHandler.userDetails?.fullName ?? ""
        userDetails.phoneNumber = tableHandler.userDetails?.phoneNumber
        userDetails.birthday = tableHandler.userDetails?.birthday
        userDetails.address = tableHandler.userDetails?.address
        userDetails.gender = tableHandler.userDetails?.gender
        updateUserDetailsInFirebase(userDetails)
    }

    /// 更改照片按鈕的行為
    @objc private func changePhotoButtonTapped() {
        photoPickerManager.presentPhotoOptions { [weak self] selectedImage in
            guard let image = selectedImage, let uid = self?.userDetails?.uid else { return }
            self?.updateProfileImage(image, for: uid)
        }
    }
    
    // 處理關閉按鈕的行為
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - User Data Methods

    /// 驗證使用者詳細資料
    private func validateUserDetails() -> Bool {
        guard let fullName = tableHandler.userDetails?.fullName, !fullName.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "姓名不能為空，請輸入姓名。", inViewController: self)
            return false
        }
        return true
    }
    
    /// 更新 Firebase 中的使用者資料
     private func updateUserDetailsInFirebase(_ userDetails: UserDetails) {
         HUDManager.shared.showLoading(text: "Saving...")
         FirebaseController.shared.updateUserDetails(userDetails) { [weak self] result in
             HUDManager.shared.dismiss()
             switch result {
             case .success:
                 print("User details updated successfully")
                 self?.userDetails = userDetails                    // 更新本地 userDetails
                 self?.delegate?.receiveUserDetails(userDetails)    // 通知 UserProfileViewController 更新資料
                 self?.dismiss(animated: true, completion: nil)
             case .failure(let error):
                 print("Failed to update user details: \(error)")
             }
         }
     }
     
    // MARK: - Image Handling Methods

    /// 更新使用者的大頭照
    private func updateProfileImage(_ image: UIImage, for uid: String) {
        editProfileView.profileImageView.image = image
        HUDManager.shared.showLoading(text: "Uploading image...")
        FirebaseController.shared.uploadProfileImage(image, for: uid) { [weak self] result in
            HUDManager.shared.dismiss()
            switch result {
            case .success(let url):
                self?.userDetails?.profileImageURL = url             // 更新本地的 userDetails，但不立即保存到 Firebase
                print("Profile image uploaded successfully")
            case .failure(let error):
                self?.handleImageUploadError(error)
            }
        }
    }
    
    /// 處理大頭照上傳錯誤
    private func handleImageUploadError(_ error: Error) {
        HUDManager.shared.dismiss()
        print("Failed to upload image: \(error)")
    }
    
    // MARK: - Date Handling Methods

    /// 處理日期選擇變更
    private func handleDateChanged(_ date: Date) {
        userDetails?.birthday = date
        tableHandler.userDetails?.birthday = date

        // 對應 BirthdaySelectionCell 並更新 dateLabel
        let indexPath = IndexPath(row: 0, section: 3)
        if let cell = editProfileView.tableView.cellForRow(at: indexPath) as? BirthdaySelectionCell {
            cell.configure(with: date)
        }
    }

    // MARK: - Helper Methods

    /// 配置使用者資料
    private func configureUserData() {
        guard let userDetails = userDetails else {
            displayDefaultUserProfileImage()
            return
        }
        loadProfileImage(from: userDetails.profileImageURL)
        editProfileView.tableView.reloadData()
    }
    
    /// 顯示預設的大頭照
    private func displayDefaultUserProfileImage() {
        editProfileView.profileImageView.image = UIImage(named: "UserSymbol")
        HUDManager.shared.dismiss()
    }
    
    /// 加載使用者大頭照
    private func loadProfileImage(from url: String?) {
        if let profileImageURL = url {
            editProfileView.profileImageView.kf.setImage(with: URL(string: profileImageURL), placeholder: UIImage(named: "UserSymbol"), options: nil, completionHandler: nil)
        } else {
            displayDefaultUserProfileImage()
        }
    }

    // MARK: - User Details Setup

    /// 接收使用者詳細資料
    func setupWithUserDetails(_ userDetails: UserDetails?) {
        self.userDetails = userDetails
        configureUserData()
    }
    
}
*/


// MARK: - async/await

import UIKit

/// 負責處理個人資料編輯頁面的主視圖控制器。它管理使用者資料的顯示與更新。
class EditProfileViewController: UIViewController {

    // MARK: - Properties

    private let editProfileView = EditProfileView()
    private var userDetails: UserDetails?
    private var photoPickerManager: PhotoPickerManager!
    private var tableHandler: EditProfileTableHandler!
    private var datePickerHandler: DatePickerHandler!
    
    weak var delegate: UserDetailsReceiver? // 用來傳遞更新後資料的 delegate

    // MARK: - Lifecycle Methods

    override func loadView() {
        view = editProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupManagers()
        setupTableView()
        configureUserData()
        setupNavigationTitle()
        setupNavigationBar()
        setupKeyboardHandling()
        setupChangePhotoAction()
    }
    
    // MARK: - Setup Methods
    
    /// 初始化管理者
    private func setupManagers() {
        setupPhotoPickerManager()
        setupDatePickerHandler()
    }

    /// 設置導航欄的保存按鈕
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
    }
        
    /// 設置導航欄的標題
    private func setupNavigationTitle() {
        title = "Edit Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    ///初始化照片選擇管理器
    private func setupPhotoPickerManager() {
        photoPickerManager = PhotoPickerManager(viewController: self)
    }

    /// 初始化日期選擇器管理器
    private func setupDatePickerHandler() {
        datePickerHandler = DatePickerHandler(datePicker: UIDatePicker())
        datePickerHandler.onDateChanged = { [weak self] date in
            self?.handleDateChanged(date)
        }
    }
    
    /// 設置 UITableView 和相關的行為
    private func setupTableView() {
        tableHandler = EditProfileTableHandler(userDetails: userDetails, datePickerHandler: datePickerHandler)
        editProfileView.tableView.delegate = tableHandler
        editProfileView.tableView.dataSource = tableHandler
        editProfileView.tableView.separatorStyle = .none
        editProfileView.tableView.backgroundColor = .lightWhiteGray
    }

    /// 設置更改照片按鈕的行為
    private func setupChangePhotoAction() {
        editProfileView.changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
    }
    
    /// 設置鍵盤處理
    private func setupKeyboardHandling() {
        setUpHideKeyboardOntap()
        setupKeyboardObservers(for: editProfileView.tableView)
    }
    
    // MARK: - Actions (Button Handlers)

    /// 保存按鈕的行為
    @objc private func saveButtonTapped() {
        guard var userDetails = userDetails else { return }
        guard validateUserDetails() else { return }

        // 從 tableHandler 中獲取用戶修改後的資料
        userDetails.fullName = tableHandler.userDetails?.fullName ?? ""
        userDetails.phoneNumber = tableHandler.userDetails?.phoneNumber
        userDetails.birthday = tableHandler.userDetails?.birthday
        userDetails.address = tableHandler.userDetails?.address
        userDetails.gender = tableHandler.userDetails?.gender
        
        Task {
            await updateUserDetailsInFirebase(userDetails)
        }
    }

    /// 更改照片按鈕的行為
    @objc private func changePhotoButtonTapped() {
        photoPickerManager.presentPhotoOptions { [weak self] selectedImage in
            guard let image = selectedImage, let uid = self?.userDetails?.uid else { return }
            Task {
                await self?.updateProfileImage(image, for: uid)
            }
        }
    }
    
    // 處理關閉按鈕的行為
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - User Data Methods

    /// 驗證使用者詳細資料
    private func validateUserDetails() -> Bool {
        guard let fullName = tableHandler.userDetails?.fullName, !fullName.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "姓名不能為空，請輸入姓名。", inViewController: self)
            return false
        }
        return true
    }
    
    /// 更新 Firebase 中的使用者資料
    private func updateUserDetailsInFirebase(_ userDetails: UserDetails) async {
        HUDManager.shared.showLoading(text: "Saving...")
        do {
            try await FirebaseController.shared.updateUserDetails(userDetails)
            HUDManager.shared.dismiss()
            self.userDetails = userDetails                    // 更新本地 userDetails
            self.delegate?.receiveUserDetails(userDetails)    // 通知 UserProfileViewController 更新資料
            dismiss(animated: true, completion: nil)
        } catch {
            print("Failed to update user details: \(error)")
        }
        HUDManager.shared.dismiss()
    }
 
    // MARK: - Image Handling Methods
    
    /// 更新使用者的大頭照
    private func updateProfileImage(_ image: UIImage, for uid: String) async {
        editProfileView.profileImageView.image = image
        HUDManager.shared.showLoading(text: "Uploading image...")
        do {
            let url = try await FirebaseController.shared.uploadProfileImage(image, for: uid)
            userDetails?.profileImageURL = url                                         // 更新本地的 userDetails，但不立即保存到 Firebase
            print("Profile image uploaded successfully")
        } catch {
            print("Failed to upload image: \(error)")
        }
        HUDManager.shared.dismiss()
    }
    
    // MARK: - Date Handling Methods

    /// 處理日期選擇變更
    private func handleDateChanged(_ date: Date) {
        userDetails?.birthday = date
        tableHandler.userDetails?.birthday = date

        // 對應 BirthdaySelectionCell 並更新 dateLabel
        let indexPath = IndexPath(row: 0, section: 3)
        if let cell = editProfileView.tableView.cellForRow(at: indexPath) as? BirthdaySelectionCell {
            cell.configure(with: date)
        }
    }

    // MARK: - Helper Methods

    /// 配置使用者資料
    private func configureUserData() {
        guard let userDetails = userDetails else {
            displayDefaultUserProfileImage()
            return
        }
        loadProfileImage(from: userDetails.profileImageURL)
        editProfileView.tableView.reloadData()
    }
    
    /// 顯示預設的大頭照
    private func displayDefaultUserProfileImage() {
        editProfileView.profileImageView.image = UIImage(named: "UserSymbol")
        HUDManager.shared.dismiss()
    }
    
    /// 加載使用者大頭照
    private func loadProfileImage(from url: String?) {
        if let profileImageURL = url {
            editProfileView.profileImageView.kf.setImage(with: URL(string: profileImageURL), placeholder: UIImage(named: "UserSymbol"), options: nil, completionHandler: nil)
        } else {
            displayDefaultUserProfileImage()
        }
    }

    // MARK: - User Details Setup

    /// 接收使用者詳細資料
    func setupWithUserDetails(_ userDetails: UserDetails?) {
        self.userDetails = userDetails
        configureUserData()
    }
    
}
