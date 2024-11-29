//
//  LoginFilledButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/28.
//

// MARK: - LoginFilledButton 筆記
/**
 
 ## LoginFilledButton 筆記
 
 `* What`
 
 - LoginFilledButton 是一個自訂的 UIButton，用於設置填充樣式的按鈕，通常應用於登入頁面中的主要行為按鈕，例如「登入」或「使用 Google 登入」。
 - 這些按鈕具有填充背景顏色、標題文字及可選的圖片（例如社交媒體圖標）。

 ---------------------------
 
 `* Why`
 
 - 在登入頁面中，某些按鈕是具有主要行為的，例如「登入」、「使用 Google 登入」等。
 - 這些按鈕通常需要顯著的外觀以吸引用戶的注意力，並明確指出它們的功能。
 - 透過使用 `LoginFilledButton`，可以統一這些主要行為按鈕的樣式和設置，減少樣式變更時的重複代碼，提高代碼的可讀性和維護性。

 ---------------------------

 `* How`
 
 `1. 繼承 UIButton：`

 - LoginFilledButton 繼承自 UIButton，並提供了一個自訂的初始化方法，方便快速設置按鈕的標題、字體、顏色、背景色、以及可選的圖片。
 
 `2. 初始化方法：`

 - `init(title:textFont:textColor:backgroundColor:imageName:imageSize:)：`
    - 初始化按鈕，設置標題文字、字體、文字顏色、背景色等屬性。這些參數的設置使按鈕具有一致的外觀風格。
 
 `3. 抽出設置按鈕外觀的私有方法：`

 - 將按鈕的配置代碼抽取到私有方法中：
    - `setupButton`：設置按鈕的基本外觀，包括標題、顏色、背景色等。
    - `configureBaseAppearance`：設置按鈕的標題、文字樣式及顏色，集中處理基本配置，增強了代碼的模組化。
    - `configureImage`：如果按鈕有圖標，則用此方法來配置圖標，並處理圖片的位置和大小。
 
 `4. 圖片的調整方法：`

 - 提供 resizeImage(named:size:) 方法來調整圖片的大小，以符合按鈕的要求，特別是在需要顯示社交登入圖標時。
 
 `5. 使用範例：`

 - 在登入頁面中使用這個按鈕：
 
 ```swift
 let loginButton = LoginFilledButton(title: "Login", textFont: UIFont.systemFont(ofSize: 18, weight: .bold), textColor: .white, backgroundColor: .blue)
 let googleLoginButton = LoginFilledButton(title: "Login with Google", textFont: UIFont.systemFont(ofSize: 16, weight: .medium), textColor: .black, backgroundColor: .white, imageName: "googleIcon")
 ```
 
 - 這樣可以確保所有主要行為按鈕擁有一致的外觀和樣式，方便後續的修改與維護。
 
 */


import UIKit

/// 自訂的帶填充色的按鈕，適用於登入頁面中具有主要行為（例如「登入」或「使用 Google 登入」等）的按鈕
class LoginFilledButton: UIButton {
    
    // MARK: - Initializers
    
    /// 初始化 LoginFilledButton
    /// - Parameters:
    ///   - title: 按鈕的標題文字
    ///   - textFont: 標題文字的字體
    ///   - textColor: 標題文字的顏色
    ///   - backgroundColor: 按鈕的背景顏色
    ///   - imageName: 圖片的名稱，可選（通常用於社交登入按鈕的圖標）
    ///   - imageSize: 圖片的大小，默認為 25x25
    init(title: String, textFont: UIFont, textColor: UIColor, backgroundColor: UIColor, imageName: String? = nil, imageSize: CGSize = CGSize(width: 25, height: 25)) {
        super.init(frame: .zero)
        setupButton(title: title, textFont: textFont, textColor: textColor, backgroundColor: backgroundColor, imageName: imageName, imageSize: imageSize)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置按鈕的外觀和屬性
    /// - Parameters:
    ///   - title: 按鈕的標題文字
    ///   - textFont: 標題文字的字體
    ///   - textColor: 標題文字的顏色
    ///   - backgroundColor: 按鈕的背景顏色
    ///   - imageName: 圖片的名稱，可選（通常用於社交登入按鈕的圖標）
    ///   - imageSize: 圖片的大小
    private func setupButton(title: String, textFont: UIFont, textColor: UIColor, backgroundColor: UIColor, imageName: String?, imageSize: CGSize) {
        configureBaseAppearance(title: title, textFont: textFont, textColor: textColor, backgroundColor: backgroundColor)
        if let imageName = imageName {
            configureImage(imageName: imageName, imageSize: imageSize)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// 配置按鈕的基本外觀
    private func configureBaseAppearance(title: String, textFont: UIFont, textColor: UIColor, backgroundColor: UIColor) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = textColor
        config.baseBackgroundColor = backgroundColor
        config.cornerStyle = .medium
        
        // 設置標題字體
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var updated = incoming
            updated.font = textFont
            return updated
        }
        
        self.configuration = config
    }
    
    /// 配置按鈕的圖標
    private func configureImage(imageName: String, imageSize: CGSize) {
        guard let resizedImage = resizeImage(named: imageName, size: imageSize) else {
            return
        }
        self.configuration?.image = resizedImage
        self.configuration?.imagePlacement = .leading
        self.configuration?.imagePadding = 8.0
    }
    
    /// 調整圖片大小以符合按鈕的要求
    /// - Parameters:
    ///   - named: 圖片的名稱
    ///   - size: 調整後的圖片大小
    /// - Returns: 調整過大小的 UIImage，如果無法找到圖片則返回 nil
    private func resizeImage(named: String, size: CGSize) -> UIImage? {
        guard let originalImage = UIImage(named: named) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            originalImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
}
