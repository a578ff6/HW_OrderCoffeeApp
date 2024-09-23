//
//  FavoriteManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/13.
//

/*
 
 ## FavoriteManager：
 
    * 功能：
        - 管理使用者的「我的最愛」功能，允許使用者將飲品加入或移除最愛清單，並同步更新 Firebase 上的資料。
        - 根據飲品的最愛狀態，動態更新 UI 按鈕圖示。
 
    * 主要調整點：
        - 使用 drinkId 來確定飲品，並從 Firebase 獲取或更新最愛清單，確保資料與 UI 的同步。
        - UI 更新部分使用 DispatchQueue.main.async，以確保資料加載後可以在「主線程」即時更新 UI。
 
    * Firebase 資料同步：
        - 當使用者操作「我的最愛」按鈕時，會透過 Firebase 即時更新最愛清單，並同步更新 UI。
        - 所有與 Firebase 相關的操作都被封裝在 FavoriteManager 中，避免 ViewController 負責複雜的資料邏輯。
 
 &. 主要流程：
 
    * toggleFavorite(for:in:)：
        - 切換指定飲品的最愛狀態。會先檢查當前飲品是否已加入最愛，如果是，則將其移除，否則加入。
        - 操作完成後，更新 Firebase 資料，並在主線程上更新 UI 按鈕的圖示狀態。
        - in viewController 參數用於更新指定視圖控制器的按鈕狀態。
 
    * isFavorite(drink:)：
        - 檢查指定的 drinkId 是否已存在於使用者的最愛清單中。結果會透過「回調函數」傳回，用於在主線程上更新 UI。
 
 &. 資料處理與更新：
 
    * Firebase 資料讀取：
        - 使用 getUserFavorites 從 Firebase 獲取當前使用者的最愛清單。若清單存在，則根據內容更新 UI，若不存在則返回空清單。（重要！）
        - 每次資料讀取後，皆會使用 DispatchQueue.main.async 來確保 UI 更新在主線程上執行。
 
    * Firebase 資料更新：
        - updateUserFavorites： 將更新後的最愛清單同步到 Firebase，確保使用者的操作能即時反映在伺服器上，並提供操作成功或失敗的提示。
 
 &. UI 操作：
 
    * 更新按鈕圖示：
        - updateFavoriteButton(for:in:)： 根據當前最愛清單的狀態，將「加入最愛」的按鈕圖示更新為 heart.fill 或空心的 heart，確保視覺效果與資料同步。
 
    * UI 更新與資料同步：
        - 每當資料操作完成後，透過 DispatchQueue.main.async 確保 UI 按鈕能即時反映資料的變更，避免因為異步操作導致按鈕狀態不一致的問題。
 
 &. DrinkDetailViewController 的應用：
 
    - 當飲品詳情頁面加載時，首先使用 isFavorite 檢查飲品是否已加入最愛，並根據結果設定按鈕的圖示狀態。
    - 使用者點擊「我的最愛」按鈕時，會呼叫 FavoriteManager 的 toggleFavorite 方法來切換飲品狀態，並即時更新按鈕圖示。
 
 &. 為什麼兩個地方都要調整：
 
    * 在 DrinkDetailViewController 中：
        - 當頁面加載或飲品資料變更時，按鈕需要根據當前的「我的最愛」狀態顯示正確的圖示和顏色。因此，updateFavoriteButtonAppearance 在頁面初始化時負責設置初始按鈕外觀，或當資料變更後重新更新按鈕的視覺狀態。

    * 在 FavoriteManager 中：
        - 當使用者切換「我的最愛」狀態時，按鈕需要即時反映出這一變更。因此，updateFavoriteButton(for:in:) 負責在切換狀態後，及時更新按鈕的外觀（圖示和顏色），確保使用者在操作時能立刻看到變更效果。
 
 */

// MARK: - 處理 drinkId & 調整 UserDetails 結構後，將 favorites 設置為 var favorites: [String] = [] （閉包）
/*
import UIKit
import Firebase

/// 管理飲品「加入最愛」的邏輯
class FavoriteManager {
    
    // MARK: - Singleton Instance

    static let shared = FavoriteManager()
    private init() {}
    
    // MARK: - Public Methods

    /// 切換飲品的「加入最愛」狀態
    /// - Parameters:
    ///   - drinkId: 需要加入或移除最愛的飲品的 ID
    ///   - viewController: 用來更新按鈕圖示的視圖控制器
    func toggleFavorite(for drinkId: String, in viewController: UIViewController) {
        guard let user = Auth.auth().currentUser else { return }

        getUserFavorites(userID: user.uid) { favorites in
            var updatedFavorites = favorites
            
            if updatedFavorites.contains(drinkId) {
                updatedFavorites.removeAll { $0 == drinkId }  // 已在最愛中，移除
            } else {
                updatedFavorites.append(drinkId)  // 不在最愛中，加入
            }
            
            print("當前最愛清單: \(updatedFavorites)")  // 觀察更新後的最愛清單
            self.updateUserFavorites(userID: user.uid, favorites: updatedFavorites)                     // 更新到 Firebase
            DispatchQueue.main.async {
                self.updateFavoriteButton(for: drinkId, in: viewController, favorites: updatedFavorites)
            }
        }
    }
    
    /// 判斷飲品是否已加入「我的最愛」
    /// - Parameters:
    ///   - drinkId: 要檢查的飲品的 ID
    ///   - completion: 回傳是否為最愛
    func isFavorite(drinkId: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(false) }
        
        getUserFavorites(userID: user.uid) { favorites in
            let isFavorite = favorites.contains(drinkId)
            DispatchQueue.main.async {
                completion(isFavorite)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 獲取使用者的「我的最愛」清單
    private func getUserFavorites(userID: String, completion: @escaping ([String]) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(userID)
        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                let favorites = data["favorites"] as? [String] ?? []
                print("獲取最愛清單: \(favorites)")  // 打印從 Firebase 獲取的最愛清單
                completion(favorites)
            } else {
                print("無法獲取最愛清單，回傳空清單")
                completion([]) // 如果出錯或沒有找到 favorites，回傳空陣列
            }
        }
    }
    
    /// 更新使用者的「我的最愛」清單到 Firebase
    private func updateUserFavorites(userID: String, favorites: [String]) {
        let userRef = Firestore.firestore().collection("users").document(userID)
        userRef.updateData(["favorites": favorites]) { error in
            if let error = error {
                print("更新最愛清單失敗: \(error.localizedDescription)")
            } else {
                print("更新最愛清單成功")
            }
        }
    }
    
    /// 更新「加入最愛」按鈕的圖示並設定不同顏色
    private func updateFavoriteButton(for drinkId: String, in viewController: UIViewController, favorites: [String]) {
        if let favoriteButton = viewController.navigationItem.rightBarButtonItems?[1] {
            let isFavorite = favorites.contains(drinkId)
            favoriteButton.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            favoriteButton.tintColor = isFavorite ? UIColor.deepGreen : UIColor.deepGreen
        }
    }
    
}
*/


// MARK: - async 部分

/*
 
 ## FavoriteManager：
 
    * 功能：
        - 管理使用者的「我的最愛」功能，允許使用者將飲品加入或移除最愛清單，並同步更新 Firebase 上的資料。
        - 根動態更新 UI 按鈕圖示，根據飲品的最愛狀態立即反映在 UI 上。
 
    * 主要調整點：
        - 使用 drinkId 來確定飲品，並從 Firebase 獲取或更新最愛清單，確保資料與 UI 的同步。
        - 改為使用 async/await 處理異步操作，這讓程式碼更清晰，並更容易處理錯誤和異步流程。
        - 先立即更新 UI：當使用者點擊「加入最愛」按鈕時，UI 按鈕會立即更新，提供更快的用戶反饋，Firebase 的 I/O 操作則稍後進行。
 
    * Firebase 資料同步：
        - 所有與 Firebase 相關的操作都被封裝在 FavoriteManager 中，避免 ViewController 負責複雜的資料邏輯。
        - 當使用者操作「我的最愛」按鈕時，系統會先即時更新按鈕的圖示狀態，並異步更新 Firebase 上的資料。
        - 資料操作異步進行，使用 async/await 確保資料從 Firebase 加載或更新時不會阻塞主線程。

 &. 主要流程：
 
    * toggleFavorite(for:in:)：
        - 切換指定飲品的最愛狀態。會先檢查當前飲品是否已加入最愛，如果是，則將其移除，否則加入。
        - 切換指定飲品的最愛狀態。當使用者點擊按鈕時，首先立即更新 UI，無需等待 Firebase 操作完成，然後再異步更新 Firebase 中的資料。
        - 使用 async/await 處理資料的同步，操作更簡潔，錯誤處理更明確。
        - 操作完成後，更新 Firebase 資料，並在主線程上更新 UI 按鈕的圖示狀態。
        -  並透過 refreshUserDetails 確保 Firebase 上的最新 UserDetails 同步到 App 中，並傳遞給相關的視圖控制器。
        - in viewController 參數用於更新指定視圖控制器的按鈕狀態。
 
    * isFavorite(drink:)：
        - 檢查指定的 drinkId 是否已存在於使用者的最愛清單中，結果會透過 await 來取得，並更新按鈕狀態。
 
 &. 資料處理與更新：
 
    * Firebase 資料讀取：
        - 資料讀取：getUserFavorites 會從 Firebase 獲取當前使用者的最愛清單，操作透過 await 完成。若清單存在，則根據內容更新 UI，若不存在則返回空清單。（重要！）
        - 資料更新：updateUserFavorites 更新最愛清單到 Firebase，同樣使用 await，確保資料同步不會阻塞 UI 操作。
        - 先更新 UI 再更新 Firebase：在按鈕圖示切換之前，先更新 UI，讓用戶看到即時反應，再進行 Firebase 資料的更新。
 
 &. UI 操作：
    
    * 立即反映按鈕圖示：
        - 在 toggleFavorite 中，按鈕圖示會在主線程立即更新，用戶點擊後可以馬上看到圖示的變化，而後台的 Firebase 操作則稍後進行，這樣提升了用戶體驗。

    * 更新按鈕圖示：
        - updateFavoriteButton(for:in:)： 根據當前最愛清單的狀態，將「加入最愛」的按鈕圖示更新為 heart.fill 或空心的 heart，確保視覺效果與資料同步。
 
    * UI 更新與資料同步：
        - 每當資料操作完成後，透過 DispatchQueue.main.async 確保 UI 按鈕能即時反映資料的變更，避免因為異步操作導致按鈕狀態不一致的問題。
 
 &. DrinkDetailViewController 的應用：
 
    - 當飲品詳情頁面加載時，首先使用 isFavorite 檢查飲品是否已加入最愛，並根據結果設定按鈕的圖示狀態。
    - 使用者點擊「我的最愛」按鈕時，會呼叫 FavoriteManager 的 toggleFavorite 切換最愛狀態，按鈕的圖示立即變更，並異步更新 Firebase 中的資料。

 &. 為什麼兩個地方都要調整：
 
    * 在 DrinkDetailViewController 中：
        - 當頁面加載或飲品資料變更時，按鈕需要根據當前的「我的最愛」狀態顯示正確的圖示和顏色。因此，updateFavoriteButtonAppearance 在頁面初始化時負責設置初始按鈕外觀，或當資料變更後重新更新按鈕的視覺狀態。

    * 在 FavoriteManager 中：
        - 當使用者切換「我的最愛」狀態時，按鈕需要即時反映出這一變更。因此，updateFavoriteButton(for:in:) 負責在切換狀態後，及時更新按鈕的外觀（圖示和顏色），確保使用者在操作時能立刻看到變更效果。
 
 ## 關於 refreshUserDetails：
 
    * 當用戶進行「加入/移除最愛」後，需要即時同步最新的 UserDetails 資料到 App 中，這樣可以確保「我的最愛」在多個頁面保持一致。
    * refreshUserDetails 會從 Firebase 中重新獲取完整的 UserDetails，並將資料回傳給視圖控制器。
    * 透過 refreshUserDetails，可以避免手動更新單一屬性如 favorites，並確保其他相關資料（如姓名、生日、訂單等）保持最新狀態，減少未來擴展時的問題。
  
 &. 使用 getCurrentUserDetails：
 
    * 透過 getCurrentUserDetails 可以取得使用者最新的完整資料，這樣可以確保：
        - 資料一致性： 所有頁面（如個人資料、訂單歷史）都能同步使用者的最新資料，避免各自更新不同資料的複雜性。
        - 避免漏掉其他資料的更新： 如只更新 favorites，其他資料（如訂單、生日等）可能不會即時同步，造成數據不一致的問題。
        - 未來擴展性： 若 App 日後需要更多使用者資料，使用 getCurrentUserDetails 可以減少重複開發和潛在錯誤。
 
 &. 資料處理與 UI 更新：

    * Firebase 資料讀取和更新： 透過 getUserFavorites 從 Firebase 獲取最愛清單，updateUserFavorites 負責更新資料。
    * 即時按鈕圖示更新： updateFavoriteButton(for:in:) 負責更新按鈕圖示，確保視覺效果與資料同步。
    * 刷新使用者資料：透過 refreshUserDetails 確保最新資料回傳到相關的視圖控制器。
 
 &. 現階段設計優點：

    * 資料同步可靠： 每次操作都會重新獲取完整的 UserDetails，確保資料的完整性和一致性。
    * 擴展性強： 未來若需擴充使用者資料，getCurrentUserDetails 只需小幅修改即可適應變更。
    * 易於維護： 將 Firebase 資料讀取和 UI 更新分開模組化處理，讓程式碼易於維護和調整。
 
 （補充：或許可以在 FirebaseController 設置專門獲取 UserDetails 中的 favorites 來單獨處裡，但避免增加維護成本，跟接下來的擴展跟重構，目前先暫時不這麼做。）
 */

// MARK: - 處理 favorite的結構模式
/*
import UIKit
import Firebase

/// 管理飲品「加入最愛」的邏輯
class FavoriteManager {
    
    // MARK: - Singleton Instance

    static let shared = FavoriteManager()
    private init() {}
    
    // MARK: - Public Methods
    
    /// 切換飲品的「加入最愛」狀態
    /// - Parameters:
    ///   - favoriteDrink: 需要加入或移除最愛的 `FavoriteDrink` 結構
    ///   - viewController: 用來更新按鈕圖示的視圖控制器
    func toggleFavorite(for favoriteDrink: FavoriteDrink, in viewController: UIViewController) async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            var favorites = try await getUserFavorites(userID: user.uid)
            // 檢查是否已經在 favorites 中
            if let index = favorites.firstIndex(where: { $0.drinkId == favoriteDrink.drinkId}) {
                favorites.remove(at: index)  // 已在最愛中，移除
            } else {
                favorites.append(favoriteDrink)  // 不在最愛中，加入
            }
            print("當前最愛清單: \(favorites)")
            updateFavoriteButton(for: favoriteDrink.drinkId, in: viewController, favorites: favorites)
            try await updateUserFavorites(userID: user.uid, favorites: favorites)
        } catch {
            print("更新最愛失敗：\(error)")
        }
    }
    
    /// 判斷飲品是否已加入「我的最愛」
    /// - Parameters:
    ///   - drinkId: 要檢查的飲品的 ID
    func isFavorite(drinkId: String) async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        do {
            let favorites = try await getUserFavorites(userID: user.uid)
            return favorites.contains { $0.drinkId == drinkId }
        } catch {
            print("檢查最愛狀態失敗：\(error)")
            return false
        }
    }
    
    // MARK: - Private Methods
    
    /// 獲取使用者的「我的最愛」清單
    private func getUserFavorites(userID: String) async throws -> [FavoriteDrink] {
        let userRef = Firestore.firestore().collection("users").document(userID)
        let document = try await userRef.getDocument()
        if let data = document.data(), let favoritesData = data["favorites"] as? [[String: Any]] {
            return favoritesData.compactMap { dict in
                guard let categoryId = dict["categoryId"] as? String, let subcategoryId = dict["subcategoryId"] as? String, let drinkId = dict["drinkId"] as? String else { return nil }
                return FavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
            }
        }
        return []
    }
    
    /// 更新使用者的「我的最愛」清單到 Firebase
    private func updateUserFavorites(userID: String, favorites: [FavoriteDrink]) async throws {
        let userRef = Firestore.firestore().collection("users").document(userID)
        let favoritesData = favorites.map {[
            "categoryId": $0.categoryId,
            "subcategoryId": $0.subcategoryId,
            "drinkId": $0.drinkId
        ]}
        try await userRef.updateData(["favorites": favoritesData])
    }

    /// 更新「加入最愛」按鈕的圖示並設定不同顏色
    private func updateFavoriteButton(for drinkId: String, in viewController: UIViewController, favorites: [FavoriteDrink]) {
        DispatchQueue.main.async {
            if let favoriteButton = viewController.navigationItem.rightBarButtonItems?[1] {
                let isFavorite = favorites.contains { $0.drinkId == drinkId }
                favoriteButton.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                favoriteButton.tintColor = isFavorite ? UIColor.deepGreen : UIColor.deepGreen
            }
        }
    }
    
}
*/


// MARK: - 處理 favorite的結構模式( 測試 同步最新的 UserDetails )成功！
/*
import UIKit
import Firebase

/// 管理飲品「加入最愛」的邏輯
class FavoriteManager {
    
    // MARK: - Singleton Instance

    static let shared = FavoriteManager()
    private init() {}
    
    // MARK: - Public Methods

    /// 切換飲品的「加入最愛」狀態，並更新相關UI
    ///
    /// - Parameters:
    ///   - favoriteDrink: 要加入或移除最愛的 `FavoriteDrink` 結構
    ///   - viewController: 用於更新按鈕UI的視圖控制器
    ///
    /// 此方法會根據`favoriteDrink`的狀態（已存在於最愛或未存在）來決定將其加入或從清單中移除。然後會更新Firebase並同步最新的`UserDetails`資料給當前的視圖控制器。
    func toggleFavorite(for favoriteDrink: FavoriteDrink, in viewController: UIViewController) async {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            var favorites = try await getUserFavorites(userID: user.uid)
            /// 檢查是否已經在 favorites 中（`已在最愛中，移除` / `不在最愛中，加入`）
            if let index = favorites.firstIndex(where: { $0.drinkId == favoriteDrink.drinkId }) {
                favorites.remove(at: index)
            } else {
                favorites.append(favoriteDrink)
            }
            print("當前最愛清單: \(favorites)")
            // 更新UI的「加入最愛」按鈕
            updateFavoriteButton(for: favoriteDrink.drinkId, in: viewController, favorites: favorites)
            // 更新Firebase的「我的最愛」清單
            try await updateUserFavorites(userID: user.uid, favorites: favorites)
            // 更新UserDetails資料
            await refreshUserDetails(for: viewController)
        } catch {
            print("更新最愛失敗：\(error)")
        }
    }

    /// 判斷飲品是否已加入「我的最愛」
    ///
    /// - Parameters:
    ///   - drinkId: 飲品的 ID
    /// - Returns: 如果飲品已在我的最愛中，則返回 `true`，否則返回 `false`
    func isFavorite(drinkId: String) async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        
        do {
            let favorites = try await getUserFavorites(userID: user.uid)
            return favorites.contains { $0.drinkId == drinkId }
        } catch {
            print("檢查最愛狀態失敗：\(error)")
            return false
        }
    }
    
    // MARK: - Private Methods
    
    /// 從 Firebase 獲取使用者的「我的最愛」清單
    ///
    /// - Parameter userID: 使用者的ID
    /// - Returns: `FavoriteDrink` 的陣列，包含使用者所有的收藏飲品
    private func getUserFavorites(userID: String) async throws -> [FavoriteDrink] {
        let userRef = Firestore.firestore().collection("users").document(userID)
        let document = try await userRef.getDocument()
        
        if let data = document.data(), let favoritesData = data["favorites"] as? [[String: Any]] {
            return favoritesData.compactMap { dict in
                guard let categoryId = dict["categoryId"] as? String, let subcategoryId = dict["subcategoryId"] as? String, let drinkId = dict["drinkId"] as? String else { return nil }
                return FavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
            }
        }
        
        return []
    }
    
    /// 將更新後的「我的最愛」清單寫入 Firebase
    ///
    /// - Parameters:
    ///   - userID: 使用者的ID
    ///   - favorites: 更新後的「我的最愛」清單
    private func updateUserFavorites(userID: String, favorites: [FavoriteDrink]) async throws {
        let userRef = Firestore.firestore().collection("users").document(userID)
        let favoritesData = favorites.map {[
            "categoryId": $0.categoryId,
            "subcategoryId": $0.subcategoryId,
            "drinkId": $0.drinkId
        ]}
        try await userRef.updateData(["favorites": favoritesData])
    }

    /// 更新「我的最愛」按鈕的狀態
    ///
    /// - Parameters:
    ///   - drinkId: 飲品的 ID
    ///   - viewController: 使用此按鈕的視圖控制器
    ///   - favorites: 當前的「我的最愛」清單
    private func updateFavoriteButton(for drinkId: String, in viewController: UIViewController, favorites: [FavoriteDrink]) {
        DispatchQueue.main.async {
            if let favoriteButton = viewController.navigationItem.rightBarButtonItems?[1] {
                let isFavorite = favorites.contains { $0.drinkId == drinkId }
                favoriteButton.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                favoriteButton.tintColor = isFavorite ? UIColor.deepGreen : UIColor.deepGreen
            }
        }
    }
    
    /// 從 Firebase 獲取最新的 `UserDetails` 並更新視圖控制器
    ///
    /// - Parameter viewController: 接收並處理最新的 `UserDetails` 的視圖控制器
    private func refreshUserDetails(for viewController: UIViewController) async {
        FirebaseController.shared.getCurrentUserDetails { result in
            switch result {
            case .success(let updatedUserDetails):
                if let viewController = viewController as? UserDetailsReceiver {
                    viewController.receiveUserDetails(updatedUserDetails)
                }
                print("更新後的 userDetails: \(updatedUserDetails.favorites)")
            case .failure(let error):
                print("獲取更新的userDetails失敗: \(error)")
            }
        }
    }
    
}
*/

// MARK: - 測試處理我的最愛頁面的刪除部分


import UIKit
import Firebase

/// 管理飲品「加入最愛」的邏輯
class FavoriteManager {
    
    // MARK: - Singleton Instance

    static let shared = FavoriteManager()
    private init() {}
    
    // MARK: - Public Methods
    
    /// 移除飲品的「我的最愛」狀態，並更新相關UI
    ///
    /// - Parameter drink: 要從最愛中移除的 `Drink`
    /// 此方法會根據`drinkId`來確定該飲品是否在收藏列表中，並且移除後同步更新 Firebase 資料和 `UserDetails`
    func removeFavorite(for drink: Drink) async {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            var favorites = try await getUserFavorites(userID: user.uid)
            /// 在 favorites 中查找並移除該 drink
            if let index = favorites.firstIndex(where: { $0.drinkId == drink.id }) {
                favorites.remove(at: index)
            } else {
                print("無法移除，因為該飲品不在收藏清單中。")
                return
            }
            print("當前最愛清單: \(favorites)")
            try await updateUserFavorites(userID: user.uid, favorites: favorites)                   // 更新 Firebase 資料
            await refreshUserDetails()                                                              // 更新 UserDetails
        } catch {
            print("移除最愛失敗：\(error)")
        }
    }
    
    /// 切換飲品的「加入最愛」狀態，並更新相關UI
    ///
    /// - Parameters:
    ///   - favoriteDrink: 要加入或移除最愛的 `FavoriteDrink` 結構
    ///   - viewController: 用於更新按鈕UI的視圖控制器
    ///
    /// 此方法會根據`favoriteDrink`的狀態（已存在於最愛或未存在）來決定將其加入或從清單中移除。然後會更新Firebase並同步最新的`UserDetails`資料給當前的視圖控制器。
    func toggleFavorite(for favoriteDrink: FavoriteDrink, in viewController: UIViewController) async {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            var favorites = try await getUserFavorites(userID: user.uid)
            /// 檢查是否已經在 favorites 中（`已在最愛中，移除` / `不在最愛中，加入`）
            if let index = favorites.firstIndex(where: { $0.drinkId == favoriteDrink.drinkId }) {
                favorites.remove(at: index)
            } else {
                favorites.append(favoriteDrink)
            }
            print("當前最愛清單: \(favorites)")
            updateFavoriteButton(for: favoriteDrink.drinkId, in: viewController, favorites: favorites)                  // 更新UI的「加入最愛」按鈕
            try await updateUserFavorites(userID: user.uid, favorites: favorites)                                       // 更新Firebase的「我的最愛」清單
            await refreshUserDetails(for: viewController)                                                               // 更新UserDetails資料
        } catch {
            print("更新最愛失敗：\(error)")
        }
    }

    /// 判斷飲品是否已加入「我的最愛」
    ///
    /// - Parameters:
    ///   - drinkId: 飲品的 ID
    /// - Returns: 如果飲品已在我的最愛中，則返回 `true`，否則返回 `false`
    func isFavorite(drinkId: String) async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        
        do {
            let favorites = try await getUserFavorites(userID: user.uid)
            return favorites.contains { $0.drinkId == drinkId }
        } catch {
            print("檢查最愛狀態失敗：\(error)")
            return false
        }
    }
    
    // MARK: - Private Methods
    
    /// 從 Firebase 獲取使用者的「我的最愛」清單
    ///
    /// - Parameter userID: 使用者的ID
    /// - Returns: `FavoriteDrink` 的陣列，包含使用者所有的收藏飲品
    private func getUserFavorites(userID: String) async throws -> [FavoriteDrink] {
        let userRef = Firestore.firestore().collection("users").document(userID)
        let document = try await userRef.getDocument()
        
        if let data = document.data(), let favoritesData = data["favorites"] as? [[String: Any]] {
            return favoritesData.compactMap { dict in
                guard let categoryId = dict["categoryId"] as? String, let subcategoryId = dict["subcategoryId"] as? String, let drinkId = dict["drinkId"] as? String else { return nil }
                return FavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
            }
        }
        
        return []
    }
    
    /// 將更新後的「我的最愛」清單寫入 Firebase
    ///
    /// - Parameters:
    ///   - userID: 使用者的ID
    ///   - favorites: 更新後的「我的最愛」清單
    private func updateUserFavorites(userID: String, favorites: [FavoriteDrink]) async throws {
        let userRef = Firestore.firestore().collection("users").document(userID)
        let favoritesData = favorites.map {[
            "categoryId": $0.categoryId,
            "subcategoryId": $0.subcategoryId,
            "drinkId": $0.drinkId
        ]}
        try await userRef.updateData(["favorites": favoritesData])
    }

    /// 更新「我的最愛」按鈕的狀態
    ///
    /// - Parameters:
    ///   - drinkId: 飲品的 ID
    ///   - viewController: 使用此按鈕的視圖控制器
    ///   - favorites: 當前的「我的最愛」清單
    private func updateFavoriteButton(for drinkId: String, in viewController: UIViewController, favorites: [FavoriteDrink]) {
        DispatchQueue.main.async {
            if let favoriteButton = viewController.navigationItem.rightBarButtonItems?[1] {
                let isFavorite = favorites.contains { $0.drinkId == drinkId }
                favoriteButton.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                favoriteButton.tintColor = isFavorite ? UIColor.deepGreen : UIColor.deepGreen
            }
        }
    }
    
    /// 從 Firebase 獲取最新的 `UserDetails` 並更新視圖控制器
    ///
    /// - Parameter viewController: 接收並處理最新的 `UserDetails` 的視圖控制器
    private func refreshUserDetails(for viewController: UIViewController? = nil) async {
        FirebaseController.shared.getCurrentUserDetails { result in
            switch result {
            case .success(let updatedUserDetails):
                if let viewController = viewController as? UserDetailsReceiver {
                    viewController.receiveUserDetails(updatedUserDetails)
                }
                print("更新後的 favorites: \(updatedUserDetails.favorites.map { $0.drinkId })")
            case .failure(let error):
                print("無法獲取更新的 userDetails: \(error)")
            }
        }
    }
    
}
