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
        - 實現 UserDetailsReceiver 協議來接收使用者資料，並透過 configureUserData 方法來更新 UI，確保使用者的所有資訊正確顯示在頁面上。
 */

// MARK: - 保留版本

/*
 import UIKit

 /// 負責處理個人資料編輯頁面的主視圖控制器。它管理使用者資料的顯示與更新。
 class EditProfileViewController: UIViewController {

     // MARK: - Properties
     
     private let editProfileView = EditProfileView()
     private var userDetails: UserDetails?
     private var photoPickerManager: PhotoPickerManager!
     private var tableHandler: EditProfileTableHandler!
     private let datePicker = UIDatePicker()

     
     // MARK: - Lifecycle Methods

     override func loadView() {
         view = editProfileView
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setSimulation()
         
         setupPhotoPickerManager()
         setupTableView()
         setupChangePhotoAction()
         configureUserData()
         setupDatePicker()
     }
     
     /// 設置模擬數據（測試用）
     func setSimulation() {
         userDetails = UserDetails(
             uid: "testUID",
             email: "test@example.com",
             fullName: "Test User",
             profileImageURL: nil,
             phoneNumber: nil,
             birthday: nil,
 //          birthday: Date(timeIntervalSince1970: 631152000), // 1990年1月1日
             address: nil,
             gender: nil,
             orders: []
         )
     }
     
     // MARK: - Setup Methods
     
     /// 負責處理照片選擇和上傳的邏輯。
     private func setupPhotoPickerManager() {
         photoPickerManager = PhotoPickerManager(viewController: self)
     }
     
     /// 設置表格的 delegate 和 data Source，並註冊自定義的 UITableViewCell 類別。
     private func setupTableView() {
         tableHandler = EditProfileTableHandler(userDetails: userDetails, isDatePickerVisible: false, datePicker: datePicker)
         editProfileView.tableView.delegate = tableHandler
         editProfileView.tableView.dataSource = tableHandler
         editProfileView.tableView.separatorStyle = .none
         editProfileView.tableView.backgroundColor = .white
         editProfileView.tableView.register(ProfileTextFieldCell.self, forCellReuseIdentifier: ProfileTextFieldCell.reuseIdentifier)
         editProfileView.tableView.register(GenderSelectionCell.self, forCellReuseIdentifier: GenderSelectionCell.reuseIdentifier)
         editProfileView.tableView.register(BirthdaySelectionCell.self, forCellReuseIdentifier: BirthdaySelectionCell.reuseIdentifier)
     }

     /// 設置更改大頭照按鈕的點擊事件。
     private func setupChangePhotoAction() {
         editProfileView.changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
     }
     
     /// 設置日期選擇器的模式、樣式及最大日期。
     private func setupDatePicker() {
         datePicker.datePickerMode = .date
         datePicker.preferredDatePickerStyle = .wheels
         datePicker.maximumDate = Date()
         datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
     }
     
     // MARK: - Actions
     
     /// 處理更改大頭照按鈕的點擊事件，展示照片選項並上傳選擇的圖片。
     @objc private func changePhotoButtonTapped() {
         photoPickerManager.presentPhotoOptions { [weak self] selectedImage in
             guard let image = selectedImage, let uid = self?.userDetails?.uid else { return }
             self?.updateProfileImage(image, for: uid)
         }
     }
     
     /// 更新使用者的大頭照，並上傳至 Firebase。
     private func updateProfileImage(_ image: UIImage, for uid: String) {
         editProfileView.profileImageView.image = image
         ActivityIndicatorManager.shared.startLoading(on: view)
         
         FirebaseController.shared.uploadProfileImage(image, for: uid) { result in
             switch result {
             case .success(let url):
                 self.updateUserProfileImageURL(url, for: uid)
             case .failure(let error):
                 self.handleImageUploadError(error)
             }
         }
     }

     /// 更新使用者的大頭照 URL，並將其儲存到 Firebase。
     private func updateUserProfileImageURL(_ url: String, for uid: String) {
         FirebaseController.shared.updateUserProfileImageURL(url, for: uid) { result in
             ActivityIndicatorManager.shared.stopLoading()
             switch result {
             case .success:
                 self.userDetails?.profileImageURL = url
                 print("Profile image updated successfully")
             case .failure(let error):
                 print("Failed to update profile image URL: \(error)")
             }
         }
     }

     /// 處理圖片上傳錯誤的情況。
     private func handleImageUploadError(_ error: Error) {
         ActivityIndicatorManager.shared.stopLoading()
         print("Failed to upload image: \(error)")
     }
     
     /// 處理日期選擇器變更的事件，並更新顯示的日期。
     @objc private func dateChanged() {
         userDetails?.birthday = datePicker.date
         tableHandler.userDetails?.birthday = datePicker.date  // 更新 tableHandler 中的 userDetails
         tableHandler.onDateChanged?(datePicker.date)
         
         // 更新 BirthdaySelectionCell 的顯示
         let indexPath = tableHandler.indexPathForBirthdaySelectionCell()
         if let cell = editProfileView.tableView.cellForRow(at: indexPath) as? BirthdaySelectionCell {
             cell.configure(with: datePicker.date)
         }
     }

     
     // MARK: - Configuration Methods
     
     /// 根據 userDetails 配置 UI，若 userDetails 為 nil，顯示預設的大頭照。
     private func configureUserData() {
         guard let userDetails = userDetails else {
             displayDefaultUserProfileImage()
             return
         }
         loadProfileImage(from: userDetails.profileImageURL)
         editProfileView.tableView.reloadData()
     }
     
     /// 顯示預設的大頭照，當 userDetails 為 nil 時使用。
     private func displayDefaultUserProfileImage() {
         editProfileView.profileImageView.image = UIImage(named: "UserSymbol")
         ActivityIndicatorManager.shared.stopLoading()
     }
     
     /// 從給定的 URL 加載使用者的大頭照，若 URL 為 nil，顯示預設的大頭照。
     private func loadProfileImage(from url: String?) {
         if let profileImageURL = url {
             editProfileView.profileImageView.kf.setImage(
                 with: URL(string: profileImageURL),
                 placeholder: UIImage(named: "UserSymbol"),
                 options: nil,
                 completionHandler: { _ in
                     ActivityIndicatorManager.shared.stopLoading()
                 }
             )
         } else {
             displayDefaultUserProfileImage()
         }
     }
     
     // MARK: - UserDetailsReceiver
     
     /// 實現 UserDetailsReceiver 協議，接收並設置使用者詳細資訊，然後更新 UI。
     func receiveUserDetails(_ userDetails: UserDetails?) {
         self.userDetails = userDetails
         configureUserData()
     }
 }

*/


// MARK: - 修改用

import UIKit

/// 負責處理個人資料編輯頁面的主視圖控制器。它管理使用者資料的顯示與更新。
class EditProfileViewController: UIViewController {

    // MARK: - Properties
    
    private let editProfileView = EditProfileView()
    private var userDetails: UserDetails?
    private var photoPickerManager: PhotoPickerManager!
    private var tableHandler: EditProfileTableHandler!
    private let datePicker = UIDatePicker()

    
    // MARK: - Lifecycle Methods

    override func loadView() {
        view = editProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        setupPhotoPickerManager()
        setupTableView()
        setupChangePhotoAction()
        configureUserData()
        setupDatePicker()
    }
    
    // MARK: - Setup Methods
    
    /// 負責處理照片選擇和上傳的邏輯。
    private func setupPhotoPickerManager() {
        photoPickerManager = PhotoPickerManager(viewController: self)
    }
    
    /// 設置表格的 delegate 和 data Source，並註冊自定義的 UITableViewCell 類別。
    private func setupTableView() {
        tableHandler = EditProfileTableHandler(userDetails: userDetails, isDatePickerVisible: false, datePicker: datePicker)
        editProfileView.tableView.delegate = tableHandler
        editProfileView.tableView.dataSource = tableHandler
        editProfileView.tableView.separatorStyle = .none
        editProfileView.tableView.backgroundColor = .white
        editProfileView.tableView.register(ProfileTextFieldCell.self, forCellReuseIdentifier: ProfileTextFieldCell.reuseIdentifier)
        editProfileView.tableView.register(GenderSelectionCell.self, forCellReuseIdentifier: GenderSelectionCell.reuseIdentifier)
        editProfileView.tableView.register(BirthdaySelectionCell.self, forCellReuseIdentifier: BirthdaySelectionCell.reuseIdentifier)
    }

    /// 設置更改大頭照按鈕的點擊事件。
    private func setupChangePhotoAction() {
        editProfileView.changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
    }
    
    /// 設置日期選擇器的模式、樣式及最大日期。
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    /// 處理更改大頭照按鈕的點擊事件，展示照片選項並上傳選擇的圖片。
    @objc private func changePhotoButtonTapped() {
        photoPickerManager.presentPhotoOptions { [weak self] selectedImage in
            guard let image = selectedImage, let uid = self?.userDetails?.uid else { return }
            self?.updateProfileImage(image, for: uid)
        }
    }
    
    /// 更新使用者的大頭照，並上傳至 Firebase。
    private func updateProfileImage(_ image: UIImage, for uid: String) {
        editProfileView.profileImageView.image = image
        ActivityIndicatorManager.shared.startLoading(on: view)
        
        FirebaseController.shared.uploadProfileImage(image, for: uid) { result in
            switch result {
            case .success(let url):
                self.updateUserProfileImageURL(url, for: uid)
            case .failure(let error):
                self.handleImageUploadError(error)
            }
        }
    }

    /// 更新使用者的大頭照 URL，並將其儲存到 Firebase。
    private func updateUserProfileImageURL(_ url: String, for uid: String) {
        FirebaseController.shared.updateUserProfileImageURL(url, for: uid) { result in
            ActivityIndicatorManager.shared.stopLoading()
            switch result {
            case .success:
                self.userDetails?.profileImageURL = url
                print("Profile image updated successfully")
            case .failure(let error):
                print("Failed to update profile image URL: \(error)")
            }
        }
    }

    /// 處理圖片上傳錯誤的情況。
    private func handleImageUploadError(_ error: Error) {
        ActivityIndicatorManager.shared.stopLoading()
        print("Failed to upload image: \(error)")
    }
    
    /// 處理日期選擇器變更的事件，並更新顯示的日期。
    @objc private func dateChanged() {
        userDetails?.birthday = datePicker.date
        tableHandler.userDetails?.birthday = datePicker.date  // 更新 tableHandler 中的 userDetails
        tableHandler.onDateChanged?(datePicker.date)
        
        // 更新 BirthdaySelectionCell 的顯示
        let indexPath = tableHandler.indexPathForBirthdaySelectionCell()
        if let cell = editProfileView.tableView.cellForRow(at: indexPath) as? BirthdaySelectionCell {
            cell.configure(with: datePicker.date)
        }
    }

    
    // MARK: - Configuration Methods
    
    /// 根據 userDetails 配置 UI，若 userDetails 為 nil，顯示預設的大頭照。
    private func configureUserData() {
        guard let userDetails = userDetails else {
            displayDefaultUserProfileImage()
            return
        }
        loadProfileImage(from: userDetails.profileImageURL)
        editProfileView.tableView.reloadData()
    }
    
    /// 顯示預設的大頭照，當 userDetails 為 nil 時使用。
    private func displayDefaultUserProfileImage() {
        editProfileView.profileImageView.image = UIImage(named: "UserSymbol")
        ActivityIndicatorManager.shared.stopLoading()
    }
    
    /// 從給定的 URL 加載使用者的大頭照，若 URL 為 nil，顯示預設的大頭照。
    private func loadProfileImage(from url: String?) {
        if let profileImageURL = url {
            editProfileView.profileImageView.kf.setImage(
                with: URL(string: profileImageURL),
                placeholder: UIImage(named: "UserSymbol"),
                options: nil,
                completionHandler: { _ in
                    ActivityIndicatorManager.shared.stopLoading()
                }
            )
        } else {
            displayDefaultUserProfileImage()
        }
    }
    
    // MARK: - UserDetailsReceiver
    
    /// 實現 UserDetailsReceiver 協議，接收並設置使用者詳細資訊，然後更新 UI。
    func receiveUserDetails(_ userDetails: UserDetails?) {
        self.userDetails = userDetails
        configureUserData()
    }
}
