//
//  Website.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/1.
//

// MARK: - Website 筆記
/**
 
 ## Website 筆記


` * What：`
 
 - `Website` 是一個資料模型，用於表示網站橫幅的相關資料。該模型直接對應 Firestore 的 `websites` 集合中的文件，包含以下屬性：
 
     - `id`：由 Firestore 自動生成的唯一識別符（可選）。
     - `imagePath`：存儲橫幅圖片的 URL 路徑，用於顯示網站圖片。
     - `url`：存儲網站的完整連結，支持導航到指定的網站。

 - 該模型實現了 `Codable` 和 `Identifiable` 協議，方便進行序列化、反序列化和 UI 綁定。

 ------------

 `* Why`

 1. 結構化數據管理
 
    Firestore 的 `websites` 集合存儲了網站橫幅的資料，使用 `Website` 模型可以方便地將這些數據結構化並與應用邏輯綁定。

 2. 方便資料展示
 
    該模型的屬性設計與 Firestore 文件結構直接對應，支持輕鬆地提取並顯示橫幅圖片和網站連結。

 3. 簡化代碼邏輯
 
    通過實現 `Codable` 協議，`Website` 模型能直接利用 `Firestore` 提供的解碼功能，避免手動解析 JSON，減少代碼重複和出錯風險。

 4. 適配 UI 與功能需求
 
    應用程序的菜單頁面需要顯示多個網站橫幅。`Website` 模型統一管理橫幅資料，使數據與 UI 更好地結合，實現可重用性與一致性。

 ------------

 `* How`

 1. 定義結構與屬性
 
    - 使用 `@DocumentID` 標註 `id`，對應 Firestore 文件的唯一標識符。
    - 定義 `imagePath` 和 `url`，分別存儲橫幅圖片路徑與網站連結。

    ```swift
    struct Website: Codable, Identifiable {
        @DocumentID var id: String?
        var imagePath: String
        var url: String
    }
    ```

 2. 集成 Firestore 支援
 
    - 使用 `Firestore` 的 `getDocuments()` 方法獲取集合中的文件。
    - 利用 `data(as:)` 方法將文件轉換為 `Website` 模型的實例。

    ```swift
    let snapshot = try await db.collection("websites").getDocuments()
    let websites = snapshot.documents.compactMap { try? $0.data(as: Website.self) }
    ```

 3. 應用於菜單頁面
 
    - 在 `MenuViewController` 中，通過 `MenuWebsiteManager` 加載 `Website` 資料，並傳遞給 `UICollectionView` 的 data source。
    - 使用 `Website` 模型的 `imagePath` 和 `url`，分別設置橫幅圖片與點擊導航行為。

 4. JSON 結構匹配
 
    - `Website` 的屬性設計完全符合 Firestore 文件的 JSON 結構，確保轉換無縫對接。

    - 範例 JSON 文件：
 
    ```json
    {
        "name": "projects/myorderapp/databases/(default)/documents/websites/幸福盛夏頁面",
        "fields": {
            "imagePath": {
                "stringValue": "https://example.com/image.jpg"
            },
            "url": {
                "stringValue": "https://example.com"
            }
        },
        "createTime": "2024-08-31T16:49:48.838942Z",
        "updateTime": "2024-08-31T16:49:48.838942Z"
    }
    ```

 ------------

` * 應用實例：`

 1. 展示網站橫幅圖片與連結
 
    - 通過 `imagePath` 加載圖片，並在菜單頁面中以橫幅形式展示。
    - 使用 `url` 實現點擊橫幅後的網站導航功能。

    - 代碼示例：
 
        ```swift
        func configureCell(with website: Website) {
            imageView.kf.setImage(with: URL(string: website.imagePath))
            self.websiteURL = URL(string: website.url)
        }
        ```

 ---
 
 2. 菜單頁面加載邏輯
 
    - 在 `MenuViewController` 中，調用 `MenuWebsiteManager` 的 `loadWebsites()` 方法獲取橫幅資料。
    - 加載完成後，更新 `UICollectionView` 顯示內容。

    ```swift
    private func loadWebsites() async {
        do {
            let websites = try await MenuWebsiteManager.shared.loadWebsites()
            self.collectionHandler.websites = websites
            self.menuView.menuCollectionView.reloadData()
        } catch {
            print("Error loading websites: \(error)")
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
    }
    ```
 */



// MARK: - (v)

import Foundation
import FirebaseFirestoreSwift

/// 表示網站橫幅資料的模型，用於菜單頁面顯示網站相關資訊。
///
/// 此結構體對應 Firestore 的 `websites` 集合，包含圖片路徑與網站連結，
/// 並支援 Codable 協議以便於序列化與反序列化操作。
///
/// - 屬性:
///   - id: Firestore 文件的唯一識別符，由 Firestore 自動生成（可選）。
///   - imagePath: 網站橫幅的圖片路徑，用於展示網站圖片。
///   - url: 網站的連結，用於導航到對應的網站。
struct Website: Codable, Identifiable {
    
    /// Firestore 自動生成的文件 ID（可選）。
    @DocumentID var id: String?
    
    /// 網站圖片的路徑。
    var imagePath: String
    
    /// 網站的 URL 連結。
    var url: String
}
