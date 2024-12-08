//
//  ProfileImageCoordinator.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/7.
//

// MARK: - ProfileImageCoordinator 筆記
/**
 
 ## ProfileImageCoordinator 筆記
 
 - 本來是`PhotoPickerManager`、`ProfileImageUploader`分開個別在`ViewController`使用，但邏輯太過於分散。
 - 試著將 `PhotoPickerManager`、`ProfileImageUploader` 整個結合又會有職責模糊的問題。
 - 因此設置 ProfileImageCoordinator 統一處理。
 
 ------------------------
 
 `* What`
 
 - `ProfileImageCoordinator` 是一個專注於用戶大頭照管理的類別，負責協調圖片的選取與上傳邏輯。
 
 `1.它整合了以下功能：`
 
 - 使用 `PhotoPickerManager` 提供圖片選取功能。
 - 使用 `ProfileImageUploader` 完成圖片的上傳與 URL 獲取。
 
 ------------------------

 `* Why`
 
` 1.解耦業務邏輯與 UI 邏輯：`

 - 大頭照的選取和上傳是獨立的業務邏輯，與控制器的其他功能解耦有助於提高可讀性與可測試性。
 
` 2.重用與靈活性：`

 - `PhotoPickerManager` 和 `ProfileImageUploader` 是通用的工具類別，`ProfileImageCoordinator` 將這些工具封裝為具體業務場景（大頭照管理）的一部分，使得邏輯易於重用。
 
 `3.改善用戶體驗：`

 - 支援即時圖片選取與預覽，提升用戶操作的直觀性與響應速度。
 
 `4.設計一致性：`

 - 將與大頭照相關的操作集中在一個類別中，減少控制器中的業務邏輯負擔，符合單一職責原則。
 
 ------------------------

 `* How`
 
 `1.選取圖片：`

 - 調用 `handleChangePhotoButtonTapped` 顯示選取界面（相簿或相機），並通過回調獲取用戶選取的圖片。
 - 使用 `PhotoPickerManager` 處理圖片選取邏輯，包含相機與相簿的選取操作。
 
 `2.上傳圖片：`

 - 使用 `startProfileImageUploadForUser` 方法將圖片上傳至 Firebase Storage。
 - 上傳成功後，獲取並返回圖片的下載 URL。
 
 `3.暫存圖片：`

 - 將用戶選取的圖片暫存於 `ProfileImageUploader` 中，為後續的上傳操作準備。
 */


// MARK: - Design Notes （ 圖片上傳與個人資料更新的職責分離設計 ） （重要）
/**
 
 `## 圖片上傳與個人資料更新的職責分離設計`
 
 - 圖片上傳涉及 Firebase Storage，不同於 EditUserProfileManager 的 Firestore 操作。
 - 圖片上傳與個人資料更新屬於不同的邏輯範疇，應保持職責獨立。
 
 ------------------------

 `* ProfileImageCoordinator 的設計目標：`
 
 - 將圖片選取與上傳邏輯與主控制器解耦。
 - 通過 `ProfileImageUploader` 處理 `Firebase Storage `上傳。
 - 通過 `PhotoPickerManager` 實現圖片選取交互。

 ------------------------

 `* What`
 
 - 圖片上傳涉及 `Firebase Storage`，而個人資料更新則基於 `Firestore`。
 - 圖片上傳與個人資料更新屬於不同的邏輯範疇，因此在設計時應保持職責獨立。

 ------------------------

 `* Why`
 
 `1. 單一職責原則 (Single Responsibility Principle)`
 
 - `圖片上傳邏輯`：專注於處理用戶圖片的選取、壓縮、上傳，以及獲取下載 URL。
 - `個人資料更新邏輯`：專注於將用戶的文字資料（如姓名、生日等）同步至 Firestore。
 - `將這兩個邏輯分離`，可以確保每個模組的責任單一、專注，便於維護與擴展。

 `2. 模組化設計 (Modularity)`
 
 - 圖片上傳涉及` Firebase Storage API，`而個人資料更新與 `Firestore` 互動。
 - 不同的 API 或服務應保持邏輯分離，避免模組間的高度耦合，降低修改某一部分邏輯時影響其他功能的風險。

 `3. 重用性 (Reusability)`
 
 - 圖片上傳邏輯可能在其他場景重複使用，例如用戶封面圖片上傳或其他圖片類型的操作。
 - 分離圖片上傳模組有助於在不同情境中重用，避免重複實現。

 `4. 減少依賴與複雜度`
 
 - 如果圖片上傳與個人資料更新合併，將導致 API 方法過於複雜。
 - 使用者需處理額外的圖片處理邏輯，增加不必要的依賴。

 ------------------------

` * How`
 
 `1. 保持現有分離設計`
 
 - `ProfileImageCoordinator`：
   
    - 負責處理圖片的選取與上傳邏輯。
    - 與 `PhotoPickerManager` 和 `ProfileImageUploader` 協作，完成圖片操作。

 - `EditUserProfileManager`：
 
    - 專注於處理個人資料（文字數據）的 Firebase Firestore 更新。
    - 提供單一責任的資料更新方法。

 `2. 規範協作流程`
 
 - `用戶修改圖片時的流程`：
 
   1. 使用 `ProfileImageCoordinator` 完成圖片的選取與上傳，獲取圖片 URL。
   2. 使用 `EditUserProfileManager` 更新個人資料（包含圖片 URL）。

 - `責任劃分`：
 
   - `ProfileImageCoordinator` 負責返回圖片下載 URL，無需涉及用戶其他資料。
   - `EditUserProfileManager` 專注處理 Firestore 的更新邏輯。

 ------------------------

 `* 總結`
 
 - 圖片上傳與個人資料更新屬於不同的邏輯範疇，保持分離符合單一職責原則。
 - 分離設計可提升系統的模組化、可重用性與維護性。
 - 若需整合，應確保方法內部責任劃分清晰，避免過多耦合。

 */


// MARK: - ProfileImageHandler 與 PhotoPickerManager 的職責區分筆記（重要）
/**
 
 ## ProfileImageHandler 與 PhotoPickerManager 的職責區分筆記

`* What`
 
 - `ProfileImageHandler` 和 `PhotoPickerManager` 是兩個負責不同功能的管理器。這兩者各有不同的單一職責，應該保持分離，以確保代碼的可維護性和清晰度。
 
 1.`PhotoPickerManager` ：負責用戶選擇照片的操作，如從相簿選取或使用相機拍攝。它專注於與 UI 的交互，處理照片選擇的流程。
 2. `ProfileImageHandler` ：負責圖片的業務邏輯，包括上傳圖片至 Firebase Storage 和獲取上傳後的 URL，保持後端交互的邏輯處理。
 
 `* Why`
 
 - 分離 `PhotoPickerManager` 和 `ProfileImageHandler` 是為了遵守單一職責原則（Single Responsibility Principle）。
 - `PhotoPickerManager` 與界面和用戶的交互有關，而 `ProfileImageHandler` 更側重於圖片的上傳和與後端服務的交互。
 - 將這兩者合併在一起會使管理器變得過於龐大，且混合不同層級的職責，降低代碼的可讀性和可維護性。
 - 保持它們分離可以提高代碼的模組化、重用性，並減少日後修改代碼時出錯的風險。

 `* How`
 
 `1. 保持兩個管理器的分離：`
 
 - `PhotoPickerManager` 專注於用戶從設備中選取照片的操作，保持與用戶界面的交互邏輯，提供用戶友好的照片選擇體驗。
 - `ProfileImageHandler` 獨立負責處理圖片的業務邏輯，包括上傳至 Firebase Storage 和獲取 URL，確保數據處理和上傳的邏輯與 UI 交互保持分離。
 
 
 `2. 與 EditUserProfileManager 分離：`
 
 - 不將 `ProfileImageHandler` 放進 `EditUserProfileManager`，而是保持其獨立。
 - 這樣可以避免 `EditUserProfileManager` 負責的範圍過於廣泛，確保它僅專注於處理用戶資料的載入與更新。
 - `ProfileImageHandler` 與圖片業務相關，而 `EditUserProfileManager` 應專注於用戶資料的 Firebase 讀寫，這樣分工明確、責任分離，有助於日後的擴展和維護。

 
 `3. 依據職責調整管理器的使用方式：`
  
 - 在需要圖片上傳的情況下，調用 `ProfileImageHandler`。
 - 當用戶需要選擇照片時，則調用 `PhotoPickerManager`。

 */




import UIKit

/// `ProfileImageCoordinator` 負責用戶大頭照的管理，包括圖片選取與上傳邏輯。
/// - 功能：
///   1. 調用 `PhotoPickerManager` 顯示相簿或相機選取界面，允許用戶選取圖片。
///   2. 使用 `ProfileImageUploader` 將圖片上傳至 Firebase Storage，並獲取下載 URL。
/// - 設計目標：
///   - 提供解耦的設計，使得`大頭照選取`與`上傳`的邏輯與 UI 層分離。
///   - 支援即時的圖片選取與處理，提升用戶體驗。
class ProfileImageCoordinator {
    
    // MARK: - Properties
    
    /// 照片選取管理器，負責顯示相簿或相機選取功能
    private let photoPickerManager: PhotoPickerManager
    
    /// 圖片上傳管理器，負責將圖片上傳至 Firebase Storage 並獲取 URL。
    private let profileImageUploader: ProfileImageUploader
    
    // MARK: - Initializer
    
    /// 初始化 `ProfileImageCoordinator`
    /// - Parameter viewController: 用於呈現照片選取器的父視圖控制器
    init(viewController: UIViewController) {
        self.photoPickerManager = PhotoPickerManager(viewController: viewController)
        self.profileImageUploader = ProfileImageUploader()
    }
    
    // MARK: - Public Methods
    
    /// 處理用戶點擊「更換照片」按鈕的行為
    /// - Parameter completion: 回調，返回用戶選取的圖片或操作結果
    /// - 流程：
    ///   1. 調用 `PhotoPickerManager` 顯示照片選取界面。
    ///   2. 獲取用戶選取的圖片並暫存於 `ProfileImageUploader`。
    ///   3. 將選取的圖片通過回調傳遞給外部。
    func handleChangePhotoButtonTapped(completion: @escaping (UIImage?) -> Void) {
        photoPickerManager.presentPhotoOptions { [weak self] selectedImage in
            guard let self = self else { return }
            if let selectedImage = selectedImage {
                print("圖片選取成功")
                self.profileImageUploader.setSelectedImage(selectedImage) // 暫存圖片
            }
            completion(selectedImage) // 將選取結果傳遞給外部
        }
    }
    
    /// 發起用戶大頭照的上傳流程，並返回上傳成功後的圖片 URL。
    /// - Parameter userID: 用戶唯一識別符，用於生成圖片的存放路徑
    /// - Returns: 上傳成功後的圖片 URL，若無選取圖片則返回 nil
    func startProfileImageUploadForUser(forUser userID: String) async throws -> String? {
        return try await profileImageUploader.uploadImageToStorage(forUser: userID)
    }
    
}
