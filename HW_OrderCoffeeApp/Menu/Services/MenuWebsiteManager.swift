//
//  MenuWebsiteManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/1.
//

// MARK: - MenuWebsiteManager 筆記
/**
 
 ## MenuWebsiteManager 筆記

 ---

 `* What`
 
 - `MenuWebsiteManager` 是一個專門處理網站橫幅資料加載的單例類別，用於從 Firestore 獲取數據並提供給展示層（如 `MenuViewController`）。
 - `private init() `使得外部無法直接初始化這個類別，強制使用單例。
 - https://reurl.cc/GpjreA
 
 - 職責：
 
   1. 負責與 Firestore 交互，非同步加載 `websites` 集合中的橫幅資料。
   2. 提供統一的數據接口，將數據轉換為 `Website` 模型供展示層使用。
   3. 確保數據加載邏輯集中化，隔離視圖層與數據層。

 ---

 `* Why`

 1. 清晰的職責分離
 
    - 根據單一職責原則 (SRP)，`MenuViewController` 不應直接處理數據加載邏輯，而應通過專門的管理器負責與數據層交互。

 2. 集中管理數據邏輯
 
    - 提高數據處理的模組化，確保數據邏輯集中，方便維護和擴展（如新增緩存機制或多數據源支持）。

 3. 高內聚低耦合
 
    - 通過單例模式實現全局唯一性，避免重複實例化，並使用專門接口供視圖層調用，降低依賴性。

 4. 可擴展性
 
    - 遵循開閉原則 (OCP)，未來可擴展功能（如本地緩存、數據同步）而不影響現有邏輯。

 ---

 `* How`

 1. 設計單例類別
 
    - 使用 `static let shared` 實現單例模式，確保全局唯一性並統一數據加載入口。

    ```swift
    static let shared = MenuWebsiteManager()
    ```

 ---
 
 2. 實現非同步數據加載方法
 
    - 通過 Firestore SDK 的非同步 API 加載 `websites` 集合數據，並使用 `compactMap` 轉換為 `Website` 模型。

    ```swift
    func loadWebsites() async throws -> [Website] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("websites").getDocuments()
        let websites = snapshot.documents.compactMap { try? $0.data(as: Website.self) }
        return websites
    }
    ```

 ---

 3. 在 `MenuViewController` 中使用
 
    - `MenuViewController` 調用 `loadWebsites()` 獲取數據並更新視圖。

    ```swift
    private func loadWebsites() async {
        do {
            let websites = try await MenuWebsiteManager.shared.loadWebsites()
            self.menuCollectionHandler.websites = websites
            self.menuView.menuCollectionView.reloadData()
        } catch {
            print("[MenuViewController]: Error loading websites: \(error)")
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
    }
    ```

 ---

 4. 數據模型設計
 
    - 使用 `Website` 模型表示橫幅數據，支持 Firestore 的 `Codable` 協議以便於序列化和反序列化。

    ```swift
    struct Website: Codable, Identifiable {
        @DocumentID var id: String?
        var imagePath: String
        var url: String
    }
    ```

 ---

 `* 優化與擴展想法`

 1. 本地緩存支持
 
    - 增加本地緩存邏輯，避免每次都向 Firestore 發出請求，可在無網絡狀態下顯示上一次的加載結果。

    ```swift
    func loadCachedWebsites() -> [Website] {
        // 使用 UserDefaults 或其他輕量級存儲工具加載緩存
    }
    ```

 2. 錯誤處理改進
 
    - 增加錯誤類型區分，例如網絡錯誤、數據解析錯誤，並提供更詳細的用戶反饋。

 ---

 `* 總結`

 - What: `MenuWebsiteManager` 是一個專注於網站橫幅數據加載的單例類別，負責從 Firestore 提取數據並提供給視圖層使用。
 - Why: 符合單一職責與高內聚低耦合設計原則，減少控制器內部的數據邏輯代碼，提升模組化與可維護性。
 - How: 提供統一的數據加載接口，結合非同步方法加載數據並更新視圖，並支持未來的擴展需求（如緩存與過濾）。
 */






// MARK: - (v)

import Foundation
import FirebaseFirestore

/// MenuWebsiteManager 負責處理網站橫幅資料的加載邏輯。
///
/// - 職責:
///   1. 作為網站橫幅數據的管理者，負責與 Firestore 交互以加載 `Website` 資料。
///   2. 確保資料加載邏輯集中，並提供統一的數據接口給視圖控制器使用。
///
/// - 功能:
///   1. 從 Firestore 的 `websites` 集合中加載橫幅數據，並轉換為 `Website` 模型陣列。
///   2. 使用單例模式確保全局唯一性，避免重複實例化。
///
/// - 使用場景:
///   - `MenuViewController` 的網站橫幅展示區域。
///
/// - 設計原則:
///   1. 單一職責原則 (SRP):
///      - 負責網站橫幅資料的加載，不涉及其他業務邏輯。
///   2. 開閉原則 (OCP):
///      - 若需擴展資料來源（如新增本地緩存功能），可通過擴展方法或屬性實現，無需修改現有邏輯。
///   3. 高內聚低耦合:
///      - 集中管理與 Firestore 的交互，隔離視圖層與數據層的耦合。
class MenuWebsiteManager {
    
    // MARK: - Singleton Instance

    /// 靜態實例，確保單例模式的全局唯一性。
    static let shared = MenuWebsiteManager()
    
    // MARK: - Initializer

    /// 私有化初始化方法，防止外部創建新實例。
    private init() {}
    
    // MARK: - Data Loading Methods

    /// 非同步從 Firestore 加載網站橫幅數據。
    ///
    /// - 邏輯:
    ///   1. 通過 Firestore 的 `websites` 集合加載所有橫幅資料。
    ///   2. 使用 `compactMap` 將數據轉換為 `Website` 模型。
    ///   3. 返回包含所有網站橫幅數據的陣列。
    ///
    /// - Returns: 包含網站橫幅的 `Website` 模型陣列。
    /// - Throws: 若數據加載失敗，向上拋出錯誤。
    func loadWebsites() async throws -> [Website] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("websites").getDocuments()
        let websites = snapshot.documents.compactMap { try? $0.data(as: Website.self) }
        return websites
    }
    
}
