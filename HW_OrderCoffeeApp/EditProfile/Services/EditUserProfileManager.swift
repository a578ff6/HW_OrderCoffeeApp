//
//  EditUserProfileManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/4.
//


// MARK: - EditUserProfileManager Gender 筆記
/**

 ## EditUserProfileManager 筆記
 
 `* What`
 
 `1.主要功能：`

 - 負責用戶資料的讀取與更新操作。
 - 將 Firebase 資料庫中的原始數據轉換為應用層使用的 ProfileEditModel。
 - 確保用戶資料的完整性與一致性。
 
 `2.處理性別 (gender) 的設計：`

 - `加載資料時`：
    - 若 Firebase 中性別字段缺失，則自動使用預設值 "Other"。
 
 - `更新資料時`：
    - 若性別字段為空，則設置為 "Other"，避免提交空值。
 
 `* Why`
 
 `1.提高資料完整性與一致性：`

 - 保證資料層的性別字段永不為空，減少應用邏輯中的空值處理。
 
 `2.提升使用者體驗：`

 - 即使用戶未選擇性別，頁面上仍能顯示默認值，避免出現空白選項。
 
 `3.簡化 Firebase 操作：`

 - 確保更新至 Firebase 的資料格式正確，不會因字段缺失或空值導致更新錯誤。
 
 `* How`
 
 `1.在資料層處理性別：`

 - 從 Firebase 獲取資料時，使用 ?? 運算符設置缺省值：
 
 ```swift
 let gender = userData["gender"] as? String ?? "Other"
 ```
 
 - 更新資料時，檢查 `gender` 是否為空：
 
 ```swift
 "gender": profile.gender.isEmpty ? "Other" : profile.gender
 ```
 
 `2.模型層與 UI 層的一致性：`

 - 使用非可選型別 String，確保性別字段在整個應用中的表現一致。
 - 在模型初始化時設置 "Other" 作為默認值：
 ```swift
 var gender: String = "Other"
 ```
 
 */


// MARK: - EditUserProfileManager 筆記
/**
 
 ## EditUserProfileManager 筆記
 
 `* What`
 
 `1.主要功能：`

 - `用戶資料讀取`： 從 Firebase 加載當前用戶的個人資料，並轉換為應用層的數據模型 ProfileEditModel。
 - `用戶資料更新`： 將用戶編輯後的資料同步到 Firebase，確保伺服器與用戶端資料的一致性。
 - `單例設計`： 使用共享實例，避免多個實例引發的不一致問題。
 
 `2.關鍵方法`：

 - `loadCurrentUserProfile`: 從 Firebase 獲取當前用戶的資料，並轉換為 ProfileEditModel。
 - `updateCurrentUserProfile`: 將 ProfileEditModel 中的數據更新到 Firebase。
 - `convertToProfileEditModel`: 負責將 Firebase 獲取的字典數據轉換為模型。
 
 `3.與其他組件的關係：`

 - `ProfileEditModel`: 作為資料模型，提供前後端資料轉換的標準結構。
 - `Firebase`: 作為後端伺服器，儲存用戶資料。
 - `GenderSelectionCell` 和其他 UI 元件：通過此類加載或更新用戶的資料。
 
 ----------------------
 
 `* Why`
 
 `1.數據與應用分離：`

 - 使用 `ProfileEditModel` 將 `Firebase` 原始數據與應用層代碼隔離，避免 Firebase 的結構變動影響應用邏輯。
 
 `2.減少重複代碼：`

 - 統一管理資料讀取與更新的邏輯，避免將資料處理邏輯分散在多個控制器或視圖中。
 
 `3.提高代碼可讀性與可維護性：`

 - 單例設計確保操作的統一性，代碼邏輯集中，易於追蹤與修改。
 
 `4.保證數據完整性與一致性：`

 - 通過非空處理（例如 `gender` 預設值）和資料格式統一（如 Firebase 字典結構），減少出錯的可能性。
 
 ----------------------

 `* How`
 
 `1.設計模式：`

 - `單例模式`：
    - 確保整個應用只有一個 EditUserProfileManager 實例，避免多處實例化導致的數據不一致。

 ```swift
 static let shared = EditUserProfileManager()
 private init() {}
 ```
 
 - `數據模型與轉換`：
    - 使用 `convertToProfileEditModel` 方法將 Firebase 的原始數據轉換為應用層模型：
    - 確保所有字段都經過統一的預設值處理，避免空值帶來的潛在問題。
 
 ```swift
 private func convertToProfileEditModel(from userData: [String: Any], uid: String) -> ProfileEditModel
 ```
 
 #############
 
 `2.方法解析：`

 - `讀取用戶資料`：
    - 確認用戶已登入，否則丟出錯誤。
    - 通過 Firestore API 獲取資料文件，並轉換為 ProfileEditModel。
 
 ```swift
 let userRef = db.collection("users").document(user.uid)
 let document = try await userRef.getDocument()
 ```

 - `更新用戶資料`：
    - 構建 Firebase 可接受的字典結構（處理可選值與格式轉換）。
    - 將資料同步至 Firebase。

 ```swift
 let userData: [String: Any] = [
     "fullName": profile.fullName,
     "phoneNumber": profile.phoneNumber ?? "",
     "birthday": profile.birthday != nil ? Timestamp(date: profile.birthday!) : NSNull(),
     "address": profile.address ?? "",
     "gender": profile.gender.isEmpty ? "Other" : profile.gender,
     "profileImageURL": profile.profileImageURL ?? ""
 ]
 ```
 
 #############
 
 `3.錯誤處理：`

 - 將常見的錯誤（如未登入、數據缺失）包裝為 NSError，方便應用層顯示錯誤提示或進行補救。
 
 #############
 
` 4.性別字段的特殊處理：`

 - 預設值： 在數據加載與更新時，確保 gender 字段有值，即使 Firebase 中缺失或用戶未選擇性別。
 
 ```swift
 let gender = userData["gender"] as? String ?? "Other"
 
 "gender": profile.gender.isEmpty ? "Other" : profile.gender
 ```
 */


// MARK: - 圖片上傳部分
/**
 
## 圖片上傳部分
 
` 1. 更新大頭照的時機`
 
 - 根據設計思路，點擊按鈕來選取新大頭照圖片時，`並不會立即更新 Firebase 上的資料`，而是先在視圖中顯示選取的圖片。
 - 當點擊「`保存（Save）`」按鈕時，才會將新的圖片 URL 更新到 Firebase。這樣做的目的是為了保持和其他欄位的資料一致性。

 `2.如果選擇了新圖片，但不點擊「保存」按鈕：`
 
 - 大頭照只會在應用的本地視圖上更改，Firebase 並不會更新。
 - 在下一次進入編輯頁面時，由於未儲存，Firebase 會提供舊的圖片 URL，導致新選取的圖片不會顯示。
 - 這樣的方式使得「大頭照圖片的更新」與其他資料欄位一樣需要經過確認，確保用戶意圖無誤後再進行更新。

 `3. 大頭照圖片的處理是否與其他欄位一致`
 
 - 在編輯頁面中，大頭照的處理與其他欄位類似，都是在用戶進行編輯後，等到點擊「保存（Save）」按鈕時才進行 Firebase 的更新。
 - 這樣的設計有以下優勢：
    - `一致的行為模式`：用戶無論是更改文字欄位還是大頭照，都是在點擊「保存」後才應用變更，這對用戶來說更直觀。
    - `減少非必要的網路請求`：每次修改圖片就馬上更新 Firebase 會造成過多的網路請求。將所有的修改統一在保存時處理，可以有效減少 Firebase 的操作次數。

 `4.處理方式`
 
 - 當用戶選取新圖片時，更新 `profileImageView` 的顯示，但不要馬上更新到 Firebase。
 - 當用戶按下「保存（Save）」按鈕時，將 `profileEditModel` 中的 `profileImageURL` 設為新圖片的 URL，然後再統一更新到 Firebase。

 這樣設計能夠確保用戶所有的修改都需要經過「保存」確認，避免意外變更未被存儲的情況發生。
 */



import Foundation
import Firebase

/// 管理用戶個人資料的工具類，負責從 Firebase 獲取和更新用戶資料。
/// - 提供獲取當前用戶資料並轉換為 `ProfileEditModel` 的功能。
/// - 支援將編輯後的用戶資料同步更新至 Firebase。
class EditUserProfileManager {
    
    // MARK: - Singleton Instance
    
    /// 單例模式
    static let shared = EditUserProfileManager()
    
    /// 私有初始化方法，防止其他地方新建實例，強制使用單例
    private init() {}
    
    // MARK: - Public Methods
    
    /// 獲取當前用戶的個人資料並轉換為 `ProfileEditModel`。
    /// - 從 Firebase 讀取當前用戶的資料，並進行數據模型轉換為 `ProfileEditModel。
    /// - Throws: 若用戶未登入或資料未找到，則丟出錯誤。
    /// - Returns: 當前用戶的 `ProfileEditModel` 實例。
    func loadCurrentUserProfile() async throws -> ProfileEditModel {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        let document = try await userRef.getDocument()
        
        guard let userData = document.data() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
        }
        
        // 將 Firestore 中獲取的資料轉換為 ProfileEditModel
        return convertToProfileEditModel(from: userData, uid: user.uid)
    }
    
    /// 更新當前用戶的個人資料至 Firebase。
    /// - 將編輯後的用戶資料以字典形式更新至 Firestore。
    /// - Throws: 若用戶未登入或更新資料失敗，則丟出錯誤。
    /// - Parameter profile: 使用者編輯後的 `ProfileEditModel`。
    func updateCurrentUserProfile(_ profile: ProfileEditModel) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        // 準備更新用戶資料的字典
        let userData: [String: Any] = [
            "fullName": profile.fullName,
            "phoneNumber": profile.phoneNumber ?? "",
            "birthday": profile.birthday != nil ? Timestamp(date: profile.birthday!) : NSNull(),
            "address": profile.address ?? "",
            "gender": profile.gender.isEmpty ? "Other" : profile.gender, // 確保性別有值
            "profileImageURL": profile.profileImageURL ?? ""
        ]
        
        // 異步方式更新 Firestore 中的用戶資料
        try await userRef.updateData(userData)
    }
    
    // MARK: - Private Methods
    
    /// 將 Firestore 中獲取的資料轉換為 ProfileEditModel。
    /// - 將 Firebase 獲取的字典數據映射為`ProfileEditModel`應用層模型。
    /// - Parameters:
    ///   - userData: 從 Firestore 獲得的用戶資料字典。
    ///   - uid: 用戶的唯一標識符。
    /// - Returns: 對應的 `ProfileEditModel` 實例。
    private func convertToProfileEditModel(from userData: [String: Any], uid: String) -> ProfileEditModel {
        let fullName = userData["fullName"] as? String ?? ""
        let profileImageURL = userData["profileImageURL"] as? String
        let phoneNumber = userData["phoneNumber"] as? String
        let birthday = (userData["birthday"] as? Timestamp)?.dateValue()
        let address = userData["address"] as? String
        let gender = userData["gender"] as? String ?? "Other" // 使用 "Other" 作為預設值
        
        return ProfileEditModel(
            uid: uid,
            fullName: fullName,
            profileImageURL: profileImageURL,
            phoneNumber: phoneNumber,
            birthday: birthday,
            address: address,
            gender: gender
        )
    }
    
}
