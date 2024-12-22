//
//  DrinkDetailOrderButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/16.
//


// MARK: -  筆記 DrinkDetailOrderButton
/**
 
 ## 筆記 DrinkDetailOrderButton
 
 `* What`
 
 - `DrinkDetailOrderButton` 是專為飲品訂單設計的自訂按鈕。
 - 採用 UIButton.Configuration 配置樣式，支持圓角、背景色、文字與圖標的靈活設定。
 - 適用於具有統一樣式需求的按鈕，主要用於「加入購物車」操作。

 -------------------------
 
 `* Why`
 
 `1.簡化樣式設置：`
 
 - 使用 UIButton.Configuration 減少對 layer 和 backgroundColor 的手動調整，提升樣式管理的一致性。
 
 `2.現代化 iOS 設計：`
 
 - 利用 iOS 15 引入的 UIButton.Configuration，符合最新的設計原則與 API 規範。
 
 `3.專注單一功能：`
 
 - 按鈕專注於核心操作（如「加入購物車」），不再引入多餘的狀態管理，降低代碼複雜度。

 -------------------------

 * How
 
 `1.初始化按鈕：`
 
 - 預設按鈕文字為 "Add to Cart"，圖標為購物車圖示（cart.fill）。
 - 支持通過初始化參數設定文字、圖標、圓角樣式與背景顏色。
 - 使用 setupStyle 方法集中管理樣式配置。

 `2. 動態樣式配置`
 
 - 配置按鈕的文字、圖標、間距與排列方式：
 - 文字與圖標： 透過 title 與 image 屬性自定義。
 - 間距與排列： 使用 imagePadding 與 imagePlacement 確保圖標與文字間距合理，符合使用者體驗。
 
 -------------------------

 `* 優化後的設計優勢`
 
 1.符合 iOS 設計模式： 採用最新的 UIButton.Configuration，提高樣式管理的可讀性與一致性。
 2.邏輯清晰：將樣式設定與按鈕功能解耦，按鈕專注於核心功能（如「加入購物車」）。
 3.簡化擴展：若未來需要新增其他按鈕（如「立即購買」或「預訂」），只需通過初始化參數調整即可，無需修改現有方法。
 */


// MARK: - 移除編輯模式的按鈕判斷

import UIKit

/// 自訂的訂單按鈕，專為 `DrinkOrderOptionsCollectionViewCell` 設計
///
/// 此按鈕採用 `UIButton.Configuration` 來簡化樣式設置，支持背景色、圓角、文字與圖標的動態設定。
/// 適合使用於具有統一樣式需求的按鈕。
class DrinkDetailOrderButton: UIButton {
    
    // MARK: - Initializer
    
    /// 初始化按鈕
    /// - Parameters:
    ///   - title: 按鈕的顯示文字，預設為 "Add to Cart"
    ///   - image: 按鈕的圖示，預設為購物車圖示
    ///   - cornerRadius: 按鈕的圓角樣式，預設為 `.medium`
    ///   - backgroundColor: 按鈕的背景顏色，預設為深綠色
    init(
        title: String = "Add to Cart",
        image: UIImage? = UIImage(systemName: "cart.fill"),
        cornerRadius: UIButton.Configuration.CornerStyle = .medium,
        backgroundColor: UIColor = .deepGreen
    ) {
        super.init(frame: .zero)
        setupStyle(title: title, image: image, cornerRadius: cornerRadius, backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置按鈕的樣式
    /// - Parameters:
    ///   - title: 按鈕的顯示文字
    ///   - image: 按鈕的圖示
    ///   - cornerRadius: 按鈕的圓角樣式（使用 `UIButton.Configuration.CornerStyle`）
    ///   - backgroundColor: 按鈕的背景顏色
    ///
    /// 此方法透過 `UIButton.Configuration` 配置按鈕的樣式，
    /// 讓按鈕具備圓角與填充顏色，並預設文字或圖標的顏色為白色。
    private func setupStyle(
        title: String,
        image: UIImage?,
        cornerRadius: UIButton.Configuration.CornerStyle,
        backgroundColor: UIColor
    ) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.image = image
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        configuration.cornerStyle = cornerRadius
        configuration.baseBackgroundColor = backgroundColor
        configuration.baseForegroundColor = .white // 文字或圖標的顏色
        self.configuration = configuration
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
