//
//  DrinkDetailSizeButton.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/16.
//


// MARK: - 筆記 DrinkDetailSizeButton
/**
 
 ## 筆記 DrinkDetailSizeButton
 
 `* What`
 
 - `DrinkDetailSizeButton` 是一個 自訂 UIButton，主要用於飲品尺寸選擇功能，提供以下特性：

 1.設定 圓角 (`cornerStyle`)、背景顏色、文字顏色。
 2.提供一個 `updateAppearance` 方法，可以根據選中狀態動態更新按鈕外觀。
 
 -------------------

 `* Why`
 
 `1.職責單一化：`
 
 - 將按鈕的樣式和狀態邏輯封裝於自訂類別，方便重複使用並提高維護性。
 
 `2.提高彈性：`
 
 - 允許初始化時自定義 圓角樣式、背景顏色、前景顏色，適應不同設計需求。
 
 `3.易於狀態管理：`
 
 - 提供 `updateAppearance` 方法，使外部呼叫時能輕鬆切換按鈕的選中與未選中狀態，符合 iOS 設計模式。
 
 -------------------

 `* How`
 
 `1.自訂初始化：`
 
 - 初始化時透過 UIButton.Configuration 設定基本樣式，包括 `cornerStyle`、`baseBackgroundColor` 和 `baseForegroundColor`。

 ```swift
 init(cornerStyle: .small, baseBackgroundColor: .lightWhiteGray, baseForegroundColor: .black)
 ```
 
 `2.按鈕狀態管理：`
 
 - 使用 `updateAppearance(isSelected: Bool) 方法`切換選中與未選中狀態，動態調整外觀。

 ```swift
 func updateAppearance(isSelected: Bool) {
     self.configuration?.baseBackgroundColor = isSelected ? .deepGreen.withAlphaComponent(0.8) : .lightWhiteGray
     self.configuration?.baseForegroundColor = isSelected ? .white : .black
 }
 ```
 
 `3.彈性設計：`
 
 - 提供靈活的初始化參數，讓使用者根據需求設定不同風格。

 ```swift
 let sizeButton = DrinkDetailSizeButton(cornerStyle: .medium, baseBackgroundColor: .blue, baseForegroundColor: .white)
 ```
 
 -------------------

 `* 優勢`
 
` 1.封裝性強：`

 - 將樣式設定與狀態管理集中在 DrinkDetailSizeButton，降低外部程式碼的複雜度。
 
 `2.彈性高：`

 - 透過初始化參數控制按鈕外觀，避免硬編碼，提高設計彈性。
 
 `3.符合 iOS 設計模式：`

 - 使用 UIButton.Configuration，符合 Apple 建議的新按鈕設計方式，簡化程式碼並提供一致的外觀管理。
 
 `4.可重複使用：`

 - 按鈕邏輯和樣式是獨立的，方便在不同場景中重複使用。
 
 -------------------
 
 `* 適用場景`
 
 1.飲品尺寸選擇：適合顯示選項並根據使用者點擊切換按鈕狀態。
 2.狀態切換按鈕：當需要根據狀態改變按鈕外觀時，updateAppearance 提供了良好的封裝方式。
 3.客製化設計：允許靈活設置按鈕風格，便於在不同 UI 設計中應用。

 */


// MARK: - (v)

import UIKit

/// 自訂的飲品尺寸按鈕，用於飲品尺寸選擇功能
///
/// 此按鈕具有：
/// - 圓角設計
/// - 動態填充背景顏色
/// - 根據選中狀態變更外觀樣式
class DrinkDetailSizeButton: UIButton {
    
    // MARK: - Initializer
    
    /// 初始化按鈕樣式
    /// - Parameters:
    ///   - cornerStyle: 圓角樣式，預設為 `.small`
    ///   - baseBackgroundColor: 按鈕背景顏色，預設為淺灰色
    ///   - baseForegroundColor: 按鈕文字/圖標顏色，預設為黑色
    init(cornerStyle: UIButton.Configuration.CornerStyle = .small, baseBackgroundColor: UIColor = .lightWhiteGray, baseForegroundColor: UIColor = .black) {
        super.init(frame: .zero)
        setupStyle(cornerStyle: cornerStyle, baseBackgroundColor: baseBackgroundColor, baseForegroundColor: baseForegroundColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置按鈕的初始樣式
    /// - Parameters:
    ///   - cornerStyle: 圓角樣式
    ///   - baseBackgroundColor: 初始背景顏色
    ///   - baseForegroundColor: 初始文字或圖標顏色
    private func setupStyle(cornerStyle: UIButton.Configuration.CornerStyle, baseBackgroundColor: UIColor, baseForegroundColor: UIColor) {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = cornerStyle
        configuration.baseBackgroundColor = baseBackgroundColor
        configuration.baseForegroundColor = baseForegroundColor
        self.configuration = configuration
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - State Management
    
    /// 更新按鈕外觀，根據是否被選中
    /// - Parameter isSelected: 傳入 `true` 設為選中狀態，`false` 設為未選中狀態
    func updateAppearance(isSelected: Bool) {
        self.configuration?.baseBackgroundColor = isSelected ? .deepGreen.withAlphaComponent(0.8) : .lightWhiteGray
        self.configuration?.baseForegroundColor = isSelected ? .white : .black
    }
    
}



