//
//  HomePageFilledButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/3.
//

// MARK: - 重點筆記 - HomePageFilledButton
/**
 
 ## 重點筆記 - HomePageFilledButton
 
 * What
 
 - HomePageFilledButton 是一個自訂的 UIButton，主要用於首頁上需要明顯顯示的操作按鈕，例如「註冊」或「開始」等主要行為。
 - 此按鈕具有填充樣式，並支持自定義的標題、字體、顏色和外觀屬性。
 
 * Why
 
 - 統一樣式：在首頁上，有些按鈕需要具有統一且醒目的樣式，以便用戶能清楚識別主要操作，例如「立即開始」等。
 - 減少重複代碼：通過定義一個自訂的按鈕類別，可以減少重複的樣式設置代碼，使代碼更簡潔，維護更容易。
 - 提高可讀性：將按鈕的配置與外觀設置分離成單獨的方法，增加了代碼的可讀性，並且易於理解每個部分的職責。
 
 * How
 
 `1. 初始化按鈕：`

 - 使用初始化方法 init(title:font:backgroundColor:titleColor:)，可以快速設置標題文字、字體、背景顏色和標題顏色，確保按鈕的外觀符合需求。
 
 ```swift
 let startButton = HomePageFilledButton(title: "Get Started", font: .boldSystemFont(ofSize: 18), backgroundColor: .systemBlue, titleColor: .white)
 ```
 
` 2.方法設計：`

 - `setupButtonConfiguration` ：負責按鈕的基本配置，如標題、顏色、字體等。這樣的抽取能讓初始化方法保持簡潔。
 - `setupButtonAppearance` ：負責按鈕的邊框、圓角等外觀屬性設置。這樣的分離確保外觀設置的邏輯集中且易於修改。
 */


import UIKit

/// 自訂的填充按鈕，適用於首頁的主要操作按鈕（例如前往註冊、登入等）
class HomePageFilledButton: UIButton {
    
    // MARK: - Initializers

    /// 初始化 HomePageFilledButton
    /// - Parameters:
    ///   - title: 按鈕的標題文字
    ///   - font: 標題字體
    ///   - backgroundColor: 背景顏色
    ///   - titleColor: 標題顏色
    init(title: String, font: UIFont, backgroundColor: UIColor, titleColor: UIColor) {
        super.init(frame: .zero)
        setupButtonConfiguration(title: title, font: font, backgroundColor: backgroundColor, titleColor: titleColor)
        setupButtonAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置按鈕的配置
    /// - Parameters:
    ///   - title: 按鈕標題文字
    ///   - font: 按鈕標題字體
    ///   - backgroundColor: 按鈕背景顏色
    ///   - titleColor: 按鈕標題顏色
    private func setupButtonConfiguration(title: String, font: UIFont, backgroundColor: UIColor, titleColor: UIColor) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = titleColor
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        self.configuration = config
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// 設置按鈕的外觀屬性
    private func setupButtonAppearance() {
        self.layer.borderColor = UIColor.deepBrown.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
}
