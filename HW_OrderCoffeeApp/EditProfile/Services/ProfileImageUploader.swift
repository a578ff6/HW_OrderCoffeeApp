//
//  ProfileImageUploader.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/5.
//

// MARK: - 筆記：ProfileImageUploader
/**
 
 ## 筆記：ProfileImageUploader
 
 `* What`
 
 `1.核心功能：`

 - `ProfileImageUploader` 專注於處理用戶大頭照的管理，包括選擇、上傳和獲取下載 URL。
 
` 2.組件職責：`

 - 暫存用戶選取的圖片，避免重複選擇。
 - 將圖片轉換為高效格式（JPEG）並壓縮，提升上傳效率。
 - 將圖片上傳至 Firebase Storage，並生成唯一的存放路徑。
 - 提供下載 URL，以便其他功能（如顯示或同步至後端）使用。
 
 `3.限制與邏輯：`

 - 僅當選取了有效圖片時才執行上傳操作。
 - 圖片存放路徑基於用戶唯一標識符（userID），確保數據分離與管理便捷。
 
 --------------------------
 
 `* Why`
 
 `1.專注單一職責：`

 - 分離大頭照處理邏輯，避免控制器或其他管理元件負責過多功能，遵循單一職責原則（SRP）。
 
 `2.提升代碼復用性：`

 - 通過封裝圖片處理邏輯，便於多個模組或功能重用，例如用於註冊、個人資料編輯等場景。
 
 `3.保證圖片一致性：`

 - 統一壓縮與格式轉換，確保上傳圖片在大小與格式上的一致性，減少後端處理壓力。
 
 `4.錯誤控制與容錯機制：`

 - 在圖片選擇與上傳過程中檢查潛在錯誤，降低出錯風險並提升用戶體驗。
 
 --------------------------

 `* How`
 
 `1.圖片暫存：`

 - 使用 `setSelectedImage` 方法，接收用戶選取的圖片並暫存於本地，便於後續上傳操作。
 
 `2.圖片上傳：`

 - 使用 `uploadImageToStorage` 方法，將暫存圖片上傳至 Firebase Storage：
    - 路徑設置為 `profileImages/{userID}.jpg`，確保路徑唯一。
    - 使用 JPEG 格式壓縮圖片，設定壓縮比例為 0.8，在畫質與大小間取得平衡。
    - 上傳成功後，返回下載 URL。
 
 `3.異步處理：`

 - 使用 async/await 確保圖片上傳與下載 URL 獲取過程異步執行，不阻塞主線程。
 
 --------------------------

 `* 使用場景建議`
 
` 1.註冊與資料編輯：`

 - 可用於用戶註冊時的頭像設置，或在個人資料編輯中更新頭像。
 
 `2.圖片管理與顯示：`

 - 與其他元件（如 `ProfileImageViewCell` ）結合，實現圖片的即時顯示與更新。
 
 --------------------------

 `* 為何使用 userID 作為參數：`
 
 - 使用 userID 作為參數的目的是確保每個用戶的大頭照能夠被存放在唯一且可識別的位置。
 - 例如，每個用戶的大頭照可以存儲在 `profileImages/{userID}.jpg `的路徑下，這樣可以避免不同用戶的圖片被覆蓋，並且可以方便地查找和管理每個用戶的圖片資源。

 - 好處：

 1.`唯一性`：每個用戶都有自己唯一的 userID，能確保存儲的圖片文件不會發生名稱衝突，避免覆蓋其他用戶的資料。
 2.`易於管理`：透過使用 userID，我們可以輕鬆地找到與特定用戶相關的大頭照，這對於後續的圖片更新和查找非常有幫助。
 3.`安全性`：使用 userID 作為圖片的存儲名稱可以確保只有具有相應權限的用戶才能存取或更新自己的圖片，增強了應用的安全性。
 */


// MARK: - 為何 ProfileImageUploader 中的 selectedImage 屬性是必要的

/**
 
 ## 為何 ProfileImageUploader 中的 selectedImage 屬性是必要的
 
 `* What`
 
 `1.ProfileImageUploader 的角色與責任：`

 - 它是負責 圖片壓縮與上傳 的專門模組。
 - 提供低層次的上傳接口，直接與 Firebase Storage 進行交互。
 - 暫存用戶選取的圖片 (`selectedImage`)，以支持用戶預覽或保存前的操作，但不涉及 UI 操作。
 
 ------------------
 
 `* Why`
 
 `1. 專注圖片處理與上傳的職責`
 
 - `ProfileImageUploader` 僅處理圖片數據的技術性操作，例如：
 
 - 圖片壓縮（格式轉換為 `JPEG`）。
 - 圖片上傳至 `Firebase Storage`。
 - 獲取圖片的下載 `URL`。
 - 將圖片選取與 UI 邏輯（如照片選取器的呈現）分離，使其專注於業務邏輯。
 
 `2. 支援上層抽象的靈活性`
 
 - 透過 `selectedImage`，允許上層（如 `ProfileImageCoordinator` 或 `EditProfileViewController`）進行更細緻的流程控制，例如：
 - 用戶選取圖片後暫存，而不立即上傳。
 - 用戶可以更換選取的圖片，或取消更改。
 - 確保只有用戶確認保存時才執行上傳，減少無效操作。
 
 `3. 簡化上層邏輯`
 
 - 上層（如 `ProfileImageCoordinator`）可以專注於圖片選取流程和上傳的高層次邏輯。
 - 通過調用 `ProfileImageUploader`，避免直接處理圖片壓縮和上傳細節。
 
 ------------------

 `* How`
 
 - 圖片選取與上傳的流程分工
 
` 1.圖片選取：`

 - 用戶通過 `PhotoPickerManager` 選取圖片。
 - 選取的圖片由 `ProfileImageCoordinator` 接收並傳遞給 `ProfileImageUploader` 暫存。
 
 `2.圖片上傳：`

 - 當用戶點擊「保存」按鈕時，`ProfileImageCoordinator` 調用 `ProfileImageUploader.uploadImageToStorage(forUser:) `方法，將暫存的圖片上傳至` Firebase Storage`。
 - 成功後，獲取下載 `URL` 並更新用戶模型。
 
 */



import UIKit
import FirebaseStorage

/// `ProfileImageUploader` 負責處理用戶大頭照的相關業務邏輯，包括圖片選擇、上傳至 Firebase Storage，以及獲取圖片下載 URL。
/// - 支援圖片壓縮和格式化為 JPEG 格式，提升上傳效率。
/// - 確保圖片存放路徑與用戶唯一標識符關聯，便於管理。
class ProfileImageUploader {
    
    // MARK: - Properties
    
    /// 暫存用戶選取的圖片，以便後續上傳或更新大頭照時使用
    private var selectedImage: UIImage?
    
    // MARK: - Public Methods
    
    /// 設定用戶選取的新大頭照。
    ///
    /// - Parameter image: 用戶選取的新大頭照圖片，若為 `nil` 則清除已選取的圖片。
    func setSelectedImage(_ image: UIImage?) {
        self.selectedImage = image
    }
    
    /// 將大頭照圖片上傳至 Firebase Storage，並返回下載 URL。
    ///
    /// - Parameter userID: 用戶唯一標識符，用於生成圖片的存放路徑。
    /// - Returns: 上傳成功後的圖片下載 URL（字串形式）；若未選取圖片，則返回 `nil`。
    /// - Throws: 若圖片轉換或上傳過程中發生錯誤，會拋出相關錯誤。
    func uploadImageToStorage(forUser userID: String) async throws -> String? {
        
        // 若無選取新圖片，則無需上傳
        guard let image = selectedImage else { return nil }
        
        // 設定圖片在 Firebase Storage 中的存放路徑
        let storageRef = Storage.storage().reference().child("profileImages/\(userID).jpg")
        
        // 將圖片轉換為 JPEG 格式
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data could not be created"])
        }
        
        // 設定圖片的 metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 上傳圖片至 Firebase Storage
        print("Uploading image to Firebase Storage...")
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        
        // 獲取上傳後的圖片下載 URL
        let downloadURL = try await storageRef.downloadURL()
        print("Successfully retrieved download URL for uploaded image.")
        return downloadURL.absoluteString
    }
    
}
