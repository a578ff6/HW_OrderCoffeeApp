//
//  ProfileHeaderTableViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/6.
//

// MARK: - ProfileImageViewCell筆記 _ updateProfileImageFromURL 與 updateProfileImageWithImage 的差異

/**
 
 `## updateProfileImageFromURL 與 updateProfileImageWithImage 的差異`
 
 `* 概述`
 
 - `ProfileImageViewCell` 是一個專門用於顯示和處理用戶大頭照的 `UITableViewCell`，包含以下功能：

 1.顯示用戶的大頭照。
 2.點擊按鈕更換大頭照。
 3.提供兩種大頭照更新方式以處理不同資料來源：
    - 遠端 `URL` 加載圖片。
    - 本地 `UIImage` 即時顯示。
 
 -----------------
 
 `* What`
 
 - `ProfileImageViewCell` 是一個用於顯示及更新用戶大頭照的 `UITableViewCell`，包含大頭照顯示區域與更換照片按鈕。提供了兩種更新大頭照的方法：

 1.`updateProfileImageFromURL`：用於從遠端 URL 加載圖片。
 2.`updateProfileImageWithImage`：用於本地 UIImage 的即時顯示。
 
 -----------------

 `* Why 設計兩種方法的原因：`

 `1.不同資料來源的需求：`
 
 - 遠端 `URL` 的圖片需經過非同步下載，適合用於伺服器儲存的圖片。
 - 本地 `UIImage` 的圖片通常來源於用戶操作（例如相簿或相機），需要即時更新顯示。
 
 `2.提升代碼的重用性：`
 
 - 針對不同的圖片來源，提供清晰的接口，避免混淆或多餘的條件判斷。
 
 -----------------

 `* How`
 
 - 在需要顯示伺服器圖片時，調用 `updateProfileImageFromURL` 方法，並確保提供有效的圖片 URL。
 - 在用戶完成圖片選取後，立即使用 `updateProfileImageWithImage` 方法更新顯示，提供即時的視覺反饋。
 - 將兩者的共同邏輯封裝在 `ProfileImageViewCell`，外部只需關心調用適當的方法，減少代碼重複。

 `1.遠端圖片更新：updateProfileImageFromURL`

 - 使用 `updateProfileImageFromURL(with: url) `方法。
 - 提供圖片的遠端 `URL`，內部處理非同步下載並更新顯示。
 - 適合從伺服器載入圖片的場景，例如用戶個人資料頁面首次加載。
 
 `2.本地圖片更新：updateProfileImageWithImage`

 - 使用 `updateProfileImageWithImage(with: image) `方法。
 - 傳入用戶選取的 `UIImage` 圖片，立即更新顯示。
 - 適合用戶操作相簿或相機後的即時圖片反饋。
 
 `3.設計注意事項：`

 - 方法內部包含對圖片有效性的檢查，無需額外處理。
 - 預設佔位圖（person.circle）確保了用戶體驗的一致性。
 
 -----------------

` * 設計原則`

 `1.單一職責原則（SRP）：`
 
 - 大頭照的更新邏輯集中於 ProfileImageViewCell，外部只需選擇適合的方法調用，減少控制器的負擔。
 
 `2.封裝性：`
 
 - 將圖片更新的細節封裝在方法內，外部無需關注圖片加載或顯示的邏輯細節。
 
 `3.擴展性：`
 
 - 若需要支援其他圖片來源（例如從 Cache 加載），可以新增方法而不影響現有邏輯。
 
 -----------------
 
 `* 範例`
 
 `1. 遠端圖片加載`
 
 ```swift
 let cell = ProfileImageViewCell()
 let imageURL = "https://example.com/profileImage.jpg"
 cell.updateProfileImageFromURL(with: imageURL)
 ```
 
 `2. 本地圖片更新`
 
 ```swift
 let cell = ProfileImageViewCell()
 let selectedImage = UIImage(named: "exampleImage")
 cell.updateProfileImageWithImage(with: selectedImage)
 ```
 
 -------------------------------
 
 `* 總結`
 
 `1.設計目的：`
 
 - 將大頭照的圖片更新邏輯集中在 ProfileImageViewCell，減少控制器的責任，提高代碼的清晰度和可維護性。

 `2.優點：`

 - 方法設計簡單易用，根據不同資料來源提供清晰的接口。
 - 支援即時更新與非同步加載兩種場景，提升用戶體驗。
 */



import UIKit

/// 負責顯示用戶大頭照和更改照片按鈕的 TableViewCell。
/// - `ProfileImageViewCell` 提供了顯示使用者個人頭像的功能，並包含一個按鈕，允許使用者更換頭像。
class ProfileImageViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    static let reuseIdentifier = "ProfileImageViewCell"
    
    /// 用於顯示使用者大頭照的 UIImageView
    ///
    /// - 預設為 `person.circle` 圖案，且具有圓形邊框樣式。
    private let profileImageView = EditProfileImageView(sfSymbolName: "person.circle", contentMode: .scaleAspectFill, backgroundColor: .white, cornerRadius: 90, borderWidth: 2.0, borderColor: .deepGreen)
    
    /// 用於更改使用者大頭照的 UIButton
    ///
    /// - 顯示圖示為相機圖案，位於大頭照的右下角。
    private let changePhotoButton = EditProfileButton(imageName: "camera.circle.fill", tintColor: .systemGray, backgroundColor: .white)
    
    // MARK: - Properties
    
    /// 當按下更改照片按鈕時執行的閉包
    var onChangePhotoButtonTapped: (() -> Void)?
    
    // MARK: - Initializers
    
    /// 初始化方法，配置 cell 的佈局和行為
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupActions()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置大頭照和更改照片按鈕的佈局
    private func setupLayout() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(changePhotoButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 180),
            profileImageView.heightAnchor.constraint(equalToConstant: 180),
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),

            changePhotoButton.widthAnchor.constraint(equalToConstant: 40),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 40),
            changePhotoButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            changePhotoButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor)
        ])
    }
    
    /// 配置 Cell 的外觀屬性
    private func setupAppearance() {
        separatorInset = .zero // 確保分隔線完全禁用
        backgroundColor = .clear // 確保背景色與 TableView 一致
        selectionStyle = .none // 禁用點擊高亮效果
    }

    // MARK: - Actions
    
    /// 設置按鈕的行為
    private func setupActions() {
        changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
    }
    
    /// 當按下更改照片按鈕時觸發的行為
    @objc private func changePhotoButtonTapped() {
        onChangePhotoButtonTapped?()
    }
    
    // MARK: - Public Methods
    
    /// 使用 URL 更新大頭照的顯示。
    /// - Parameter url: 大頭照的遠端 URL 字串。
    ///   若 URL 無效，則顯示預設圖案。
    /// - 使用場合：
    ///   - 用於從遠端伺服器下載圖片時，例如 Firebase 儲存的檔案。
    func updateProfileImageFromURL(with url: String?) {
        guard let urlString = url, let imageURL = URL(string: urlString) else {
            profileImageView.image = UIImage(systemName: "person.circle")
            return
        }
        profileImageView.kf.setImage(with: imageURL, placeholder: UIImage(systemName: "person.circle"))
    }
    
    /// 使用本地圖片更新大頭照的顯示。
    /// - Parameter image: 本地的 UIImage。
    ///   若傳入 nil，則顯示預設圖案。
    /// - 使用場合：
    ///   - 用於用戶從相簿或相機選取圖片後立即更新顯示。
    func updateProfileImageWithImage(with image: UIImage?) {
        profileImageView.image = image ?? UIImage(systemName: "person.circle")
    }
    
}
