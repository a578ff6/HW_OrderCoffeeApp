//
//  LoginCustomImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/28.
//

// MARK: - LoginCustomImageView 筆記
/**
 
 ## LoginCustomImageView 筆記
 
 `* What`
 
 - `LoginCustomImageView` 是一個自訂的 UIImageView 類別，用於設置標準樣式的圖片視圖，主要是針對登入頁面中的圖示需求。
 - 它提供了圖片顯示的預設屬性，例如圖片模式、佈局控制，並動態調整圖片的高度來適應不同裝置的螢幕大小。

 `* Why`
 
 `1.統一設計風格：`

 - 在登入頁面中，常常會有如 logo 這類需要保持一致顯示風格的圖片。使用 LoginCustomImageView 可以讓這些圖片的設置統一化，減少重複設置屬性的工作，並提高代碼的可讀性與可維護性。
 
 `2.動態適應不同裝置：`

 - 由於不同裝置的螢幕大小不同，直接固定圖片的大小可能會導致在某些裝置上圖片過大或過小。
 - `adjustHeightForScreenSize` 可以根據螢幕大小動態設置圖片高度，保證在各種裝置上圖片都能以適當的比例呈現，提升使用者體驗。
 
 `3.便於修改與維護：`

 透過自訂這個類別，當日後需求變更時，只需在這個類別中更新一次，就能應用於所有相關的圖片視圖，確保修改成本最小化。
 
 `* How`
 
 `1. 繼承 UIImageView：`

 - `LoginCustomImageView` 繼承了 UIImageView，並進行擴展以符合登入頁面的需求。通過自訂初始化和設置方法，使圖片視圖具備標準化的外觀。
 
 `2. 初始化：`

 - 提供自訂初始化方法，通過圖片名稱來設置圖片，並在初始化完成後調用 setupImageView() 方法來配置共通屬性，然後調用 adjustHeightForScreenSize() 方法進行動態高度設置。

 `3. 標準屬性設置 (setupImageView())：`

 - 設置 contentMode 為 .scaleAspectFill，確保圖片在視圖中保持比例填充，防止圖片變形，並設置 translatesAutoresizingMaskIntoConstraints 為 false 以便於使用自動佈局。

 `4. 動態高度調整 (adjustHeightForScreenSize())：`
 
 - 根據螢幕的高度來設定圖片的高度：當螢幕高度較小時（例如 iPhone SE 這類裝置），使用較小的圖片高度，當螢幕較大時，使用較大的圖片高度。這樣能確保在不同裝置上都能獲得理想的顯示效果。

 `5. 使用範例：`

 - 創建一個 LoginCustomImageView，例如在登入頁面中顯示應用程式的 logo：
    ```swift
    let logoImageView = LoginCustomImageView(imageName: "starbucksLogo2")
    ```
 */


import UIKit

/// 自訂的 UIImageView 類別，用於設置標準樣式的圖片視圖
/// - 用於 LoginView 需要標準樣式圖片的場景
/// - 預設圖片模式為 `.scaleAspectFill`
class LoginCustomImageView: UIImageView {
    
    // MARK: - Initializers
    
    /// 使用圖片名稱初始化 LoginCustomImageView
    /// - Parameter imageName: 圖片的名稱，用於從資源中載入圖片
    init(imageName: String) {
        let image = UIImage(named: imageName)
        super.init(image: image)
        setupImageView()
        adjustHeightForScreenSize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置圖片視圖的標準屬性
    /// - 設置 `contentMode` 為 `.scaleAspectFill`，確保圖片在視圖中保持比例填充
    private func setupImageView() {
        contentMode = .scaleAspectFill
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// 根據螢幕大小動態調整圖片高度
    /// - 當螢幕較小時使用較小的高度，較大時使用較大的高度
    private func adjustHeightForScreenSize() {
        let screenHeight = UIScreen.main.bounds.height
        let logoHeight: CGFloat = screenHeight <= 667 ? 60 : 90
        self.heightAnchor.constraint(equalToConstant: logoHeight).isActive = true
    }
}
