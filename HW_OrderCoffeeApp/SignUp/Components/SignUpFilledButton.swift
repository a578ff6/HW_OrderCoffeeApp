//
//  SignUpFilledButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/30.
//

import UIKit

/// 自訂的帶填充色的按鈕，適用於登入頁面中具有主要行為（例如「登入」或「使用 Google 登入」等）的按鈕
class SignUpFilledButton: UIButton {

    // MARK: - Initializers
    
    /// 初始化 SignUpFilledButton
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
