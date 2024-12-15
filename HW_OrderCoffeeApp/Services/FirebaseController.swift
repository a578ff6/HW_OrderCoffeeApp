//
//  FirebaseController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

/*
 A. addDocument 與 setData
 
 * 使用 addDocument
    - 優點：
        - addDocument 方法會自動生成一個唯一的文檔 ID，無需手動指定 ID。
        - 適用於不關心文檔 ID 的場景。
    - 缺點：
        - 無法直接使用 uid 作為文檔 ID，因為 addDocument 會生成一個隨機 ID。
        - 如果想要使用用戶的 uid 作為文檔 ID，需要在其他地方額外存取或檢索文檔ID。

 * 使用 setData
    - 優點：
        - 使用 setData 可以手動指定文檔 ID，使用用戶的 uid 最為文檔 ID。
        - 便於以後通過 uid 快速檢索用戶文檔。
    - 缺點：
        - 如果 uid 已經存在，會覆蓋原有資料（可通過 merge 參數控制是否覆蓋））。
 
 ----------------------------------- ----------------------------------- -----------------------------------

 B. 避免覆蓋現有資料並區分不同登入來源的方法：
    * 避免覆蓋現有資料：
        - 在更新資料庫中的使用者資料時，應檢查是否有必要更新每個欄位。例如，只有在該欄位為空或有特定更新需求時才更新。
    * 儲存登入來源：
        - 儲存登入來源（如 Google、Apple 等）有助於後續對使用者行為的分析和管理。
    * 資料合併：
        - 當需要更新使用者資料時，使用合併操作（如 Firebase 的 merge: true）來確保新資料不會覆蓋掉已有的重要資料。
    * 唯一識別符（UID）：
        - 使用唯一識別符（如 Firebase 的 UID）來管理使用者資料，確保每個使用者都有一個唯一的標識符。
 
 ----------------------------------- ----------------------------------- -----------------------------------

C. 確保使用者可以通過不同的身份驗證提供者（如電子郵件、Google、Apple）登入同一個 Firebase 帳戶。
    - 我這邊在電子郵件/密碼登入部分也進行憑證關聯處理。這樣用戶可以在使用不同的身份驗證方式時，仍然能夠訪問同一個帳戶和數據。
 
    * 處理流程：
        - registerUser： 創建新用戶並儲存用戶資料到 Firestore。
        - loginUser： 使用電子郵件和密碼進行用戶登入，並且處理將電子郵件憑證與現有帳號關聯。
        - linkEmailCredential： 將電子郵件憑證與現有帳號關聯，或者如果連結失敗，則使用電子郵件憑證進行登入。
        - signInWithEmailCredential： 使用電子郵件憑證進行登入。
        - storeUserData： 將用戶數據保存到 Firestore，確保用戶無論使用哪種身份驗證方式登入，都能訪問到同一個 Firebase 帳戶和數據。
 
 ----------------------------------- ----------------------------------- -----------------------------------
 
 D. 三者登入流程模式：
    * Apple 第一次登入註冊時的處理
        - 獲取 Apple 憑證：Apple 返回用戶的憑證，包括用戶的名稱和郵箱地址。
        - 鏈接憑證：使用 linkAppleCredential 方法將 Apple 憑證與當前 Firebase 用戶帳戶關聯。
        - 保存用戶數據：在 storeAppleUserData 方法中，將用戶的名稱、郵箱和其他數據保存到 Firestore。
    
    * 電子郵件註冊
        - 創建新用戶：使用 registerUser 方法創建新用戶，並獲取用戶的認證結果。
        - 保存用戶數據：使用 storeUserData 方法將用戶的名稱、郵箱和其他數據保存到 Firestore。
    
    * Google 註冊
        - Google 登入或註冊：通過 signInWithGoogle 方法進行 Google 登入或註冊。
        - 鏈接憑證：使用 linkGoogleCredential 方法將 Google 憑證與當前 Firebase 用戶帳戶關聯。
        - 保存用戶數據：在 storeGoogleUserData 方法中，將用戶的名稱、郵箱和其他數據保存到 Firestore。
    
    * 總結
        - Apple 登入註冊：在 linkAppleCredential 和 signInWithAppleCredential 中處理，用戶的名稱和郵箱在 storeAppleUserData 方法中保存。
        - 電子郵件註冊：在 registerUser 和 loginUser 中處理，用戶的名稱和郵箱在 storeUserData 方法中保存。
        - Google 登入註冊：在 signInWithGoogle 和 linkGoogleCredential 中處理，用戶的名稱和郵箱在 storeGoogleUserData 方法中保存。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 E. 不同的身份驗證提供者（Apple、Google、Email）在處理有用戶數據時：
    * 電子郵件身份驗證（Email）
        1.電子郵件註冊
            - 若用戶使用電子郵件註冊，會調用 registerUser 方法。
            - 該方法會創建新用戶並保存用戶數據（包括 fullName 和 email）到 Firestore。
            - 如果用戶數據已存在，則更新該數據。
        2. 電子郵件登入
            - 若用戶使用電子郵件登入，會調用 loginUser 方法。
            - 該方法會生成憑證並嘗試將憑證與現有帳號關聯。如果失敗，則使用憑證直接登入。
            - 登入成功後，會更新用戶數據。
 
    * Google 身份驗證
        1. Google 登入或註冊
            - 若用戶使用 Google 登入或註冊，會調用 signInWithGoogle 方法。
            - 該方法會生成 Google 憑證，並嘗試將憑證與現有帳號關聯。如果失敗，則使用憑證直接登入。
            - 登入成功後，會調用 storeGoogleUserData 方法保存或更新用戶數據（包括 fullName 和 email）。
 
    * Apple 身份驗證
        1. Apple 登入或註冊
            - 若用戶使用 Apple 登入或註冊，會調用 signInWithApple 方法。
            - 該方法會生成 Apple 憑證，並嘗試將憑證與現有帳號關聯。如果失敗，則使用憑證直接登入。
            - 登入成功後，會調用 storeAppleUserData 方法保存或更新用戶數據（包括 fullName 和 email）。
 
    * 處理有用戶數據的情況：當用戶數據已存在時，不同身份驗證提供者會按以下步驟處理：
        1. 檢查現有數據
            - 在保存用戶數據之前，會檢查 Firestore 中是否已存在用戶數據（通過 userRef.getDocument 方法）。
            - 如果已存在數據，會根據不同的身份驗證提供者更新相關欄位（如 loginProvider 和 fullName）。
        2. 更新數據
            - 如果數據已存在，且某些欄位需要更新（例如使用新的身份驗證提供者登入），則會更新這些欄位。
        3. 保存數據
            - 最後，會將更新後的數據保存到 Firestore（通過 userRef.setData 方法）。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 F. 上傳圖片到 Firebase Storage 並更新 Firestore 中的資料。

    * 上傳圖片至 Firebase Storage：
        - 使用 uploadProfileImage 方法將用戶選擇的照片上傳至 Firebase Storage。
        - 使用 updateUserProfileImageURL 方法將照片的下載 URL 更新到 Firestore 中的 UserDetails 資料結構。
 
    * 使用使用者的 uid 作為照片的檔名：
        - 每個使用者都有一個唯一的 uid，將其作為檔名可以保證每個使用者的照片檔名都是唯一的，不會與其他使用者的照片發生衝突。
        - 使用 uid 作為檔名可以很容易地將照片與特定的使用者關聯起來，方便在需要時進行管理或查找。
        - 直接使用 uid 作為檔名可以省去生成新的唯一識別碼的步驟，簡化了上傳和存儲照片的流程。
        - 這樣，上傳的照片將存儲在 profile_images 資料夾下，並以 uid.jpg 為檔名。當需要更新或替換使用者的照片時，只需覆蓋相同的檔名即可，無需再為每張新照片生成新的檔名。

 ---------------------------------------- ---------------------------------------- ----------------------------------------

 G. 登出功能相關邏輯：
 
    * 登出操作：
        - 調用 Firebase 的登出方法，並將結果以成功或失敗的方式返回給調用者。

 ---------------------------------------- ---------------------------------------- ----------------------------------------

 H. 關於 orders 屬性的設置：

    * orders 只有在歷史訂單視圖中會用到，因此將 orders 的處理從 getCurrentUserDetails 中分離，並使用專門的函數來動態獲取 Firebase 中的訂單列表。

    * 移除 getCurrentUserDetails 中的 orders 處理：
        - 因為 orders 在大部分場景中並不需要，將它移除出 getCurrentUserDetails。這樣可以讓 getCurrentUserDetails 更聚焦於使用者的基本資訊，如姓名、郵件、電話等。
 
    * 新增一個專門處理訂單資料的函數：
        - 建立一個新的函數，專門從 Firebase 中抓取指定使用者的訂單資料，這樣可以在需要的時候（例如在歷史訂單視圖中）才進行訂單資料的抓取，減少不必要的資料讀取。
 
 */


// MARK: - 重點筆記：為何在 signOut() 中清除訂單和重置顧客資料

/*
 1. 確保用戶狀態的清晰與資料一致性：

    - 登出操作意味著用戶即將離開應用的當前狀態，為了保證下次登入的用戶不會看到前一個用戶的資料，需要在登出時清除內存中與訂單相關的所有資料，包括 訂單項目 (orderItems) 和 顧客詳細資料 (customerDetails)。
    - 如果不進行這樣的清除，可能會導致資料不一致，甚至讓新登錄的用戶看到其他用戶的私人資訊，存在隱私洩露的風險。
 
 2. 清空當前用戶的所有臨時資料：

    - OrderItemManager.shared.clearOrder() 會清空當前用戶正在處理的訂單項目。
    - CustomerDetailsManager.shared.resetCustomerDetails() 重置顧客詳細資料，使得 App 重新回到最初的狀態，為下一次使用做好準備。
 
 3. 避免過期資料干擾：

    - 訂單流程中涉及用戶的多個資料，例如訂單項目列表和顧客資料等。登出後，這些資料應該被重置，以避免在新用戶登入時引入舊資料帶來的干擾。
    - 保證用戶登錄後看到的資料都是和自己的帳號相關的，不受前一用戶登錄影響，提供更好的用戶體驗。
 
 4. 集中管理登出行為的邏輯：

    - 在 signOut() 方法中進行訂單和顧客資料的清除，將與登出相關的操作集中在一起，可以使得邏輯更加清晰，避免需要在其他地方手動記得清除這些資料，減少出錯的機會。
 */


// MARK: - 測試修改用（ async/await ）
import UIKit
import Firebase
import FirebaseStorage

/// 處理 Firebase 資料庫相關
class FirebaseController {
    
    static let shared = FirebaseController()
    
    /// 獲取當前用戶的詳細資料
    /// 使用 Firebase Auth 確認當前用戶是否登入，並從 Firestore 中抓取對應的使用者資料。
    /// 如果抓取成功，會返回解析後的 UserDetails 資料結構，包含用戶的基本資訊及「我的最愛」清單。
    /// 如果抓取過程中發生錯誤，則會拋出對應的錯誤。
    func getCurrentUserDetails() async throws -> UserDetails {
        
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        /// 連接至 Firestore 資料庫，取得當前用戶的 document 參考
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        /// 從 Firestore 獲取當前用戶的 document 資料
        let document = try await userRef.getDocument()
        
        guard let userData = document.data() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
        }
        
        // 解析使用者的基本資訊，從 Firestore document 中取出對應欄位的資料
        let email = userData["email"] as? String ?? ""
        let fullName = userData["fullName"] as? String ?? ""
        let profileImageURL = userData["profileImageURL"] as? String
        let phoneNumber = userData["phoneNumber"] as? String
        let birthday = (userData["birthday"] as? Timestamp)?.dateValue()
        let address = userData["address"] as? String
        let gender = userData["gender"] as? String
        
        /// 解析 favorites 資料，將 Firestore 的「我的最愛」轉換為 FavoriteDrink 的陣列
//        let favorites = parseFavorites(from: userData["favorites"] as? [[String: Any]])
        
        // 將所有解析後的資料封裝進 UserDetails 結構並返回
        return UserDetails(
            uid: user.uid,
            email: email,
            fullName: fullName,
            profileImageURL: profileImageURL,
            phoneNumber: phoneNumber,
            birthday: birthday,
            address: address,
            gender: gender
//            orders: nil,            // 因為 orders 在大部分場景中並不需要，只有在歷史訂單的頁面才會用到。
//            favorites: favorites        // 將 favorites 轉換後的 [FavoriteDrink] 加入 UserDetails
        )
    }
    
    /// 解析 favorites 資料
    /// 將從 Firestore 中獲取的「我的最愛」清單資料（favorites）解析為 [FavoriteDrink] 陣列。
    /// 如果資料為空或無效，則返回一個空陣列。
//    private func parseFavorites(from data: [[String: Any]]?) -> [FavoriteDrink] {
//        
//        guard let favoritesData = data else { return [] }
//        
//        // 使用 compactMap 遍歷 favoritesData 陣列，將每一個資料字典轉換為 FavoriteDrink 結構
//        return favoritesData.compactMap { dict in
//            guard let categoryId = dict["categoryId"] as? String,
//                  let subcategoryId = dict["subcategoryId"] as? String,
//                  let drinkId = dict["drinkId"] as? String else { return nil }
//            return FavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
//        }
//    }
    
    /// 執行登出操作
    /// 執行 Firebase Auth 的登出操作，並清除當前的訂單資料。
    /// 若登出過程中發生錯誤，會拋出相應錯誤。
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            OrderItemManager.shared.clearOrder() // 在登出時清除內存中的 orderItems（訂單項目）
            CustomerDetailsManager.shared.resetCustomerDetails()
        } catch let signOutError as NSError {
            throw signOutError
        }
    }
    
}



