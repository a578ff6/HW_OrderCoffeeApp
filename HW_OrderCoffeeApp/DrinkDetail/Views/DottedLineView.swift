//
//  DottedLineView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/23.
//

// MARK: - 筆記：DottedLineView
/**
 
 ## 筆記：DottedLineView
 
 `* What`
 
 - `DottedLineView` 是一個自訂的 UIView，專門用於繪製水平方向的虛線，通常用於分隔標題與數值。它支援以下屬性：

 1.虛線寬度（`lineWidth`）。
 2.虛線模式（`dashPattern`），例如 [線段長度, 空格長度]。
 3.虛線顏色（`lineColor`）。
 
 -----------------
 
 `* Why`
 
 - 設計 `DottedLineView` 的主要目的：

 1.`視覺分隔`：在 UI 中提供直觀的分隔效果，增強資訊結構的可讀性。
 2.`自訂化需求`：讓開發者能根據設計需求，調整虛線的寬度、顏色及模式，適應多樣化的場景。
 3.`封裝繪製邏輯`：將虛線繪製的邏輯集中在單一類別內，避免重複代碼並提升可維護性。
 
 -----------------

 `* How`
 
 - `DottedLineView` 的設計邏輯與使用方式：

 `1.初始化：`
 
 - 提供默認參數，使用者可直接調用或根據需求自訂虛線屬性。
 
 `2.核心繪製邏輯：`
 
 - 使用 Core Graphics 在 draw(_:) 方法中繪製虛線，透過 setLineDash 定義虛線模式。
 - 將繪製範圍限制於水平方向（y = rect.height / 2）。
 
 `3.封裝性：`
 
 - 將虛線繪製所需的寬度、顏色及模式作為私有屬性，避免外部直接修改。
 
 -----------------

 `* 總結`
 
 `1.保持現有封裝：`

 - `DottedLineView` 的封裝已經滿足單一職責原則，便於擴展與維護。
 
` 2.適當使用 DottedLineView：`

 - 在所有需要虛線分隔的地方，保持使用 `DottedLineView`，不要直接在其他類中重複繪製邏輯。
 
 `3.可以補充使用說明：`

 - 在需要添加分隔線的 StackView 或 Cell 中，直接添加一個 DottedLineView，並根據需求設置寬度與顏色屬性即可。
 */



// MARK: - (v)

import UIKit

/// `DottedLineView`
///
/// 自訂虛線視圖，用於在 DrinkDetail 的資訊堆疊中作為分隔線。
/// - 支援自訂虛線的寬度、間距模式及顏色，適用於多種需求的分隔視覺效果。
/// - 使用 `draw(_:)` 方法，透過 Core Graphics 繪製虛線於水平方向上。
class DottedLineView: UIView {
    
    // MARK: - Properties
    
    /// 虛線的寬度
    private let lineWidth: CGFloat
    
    /// 虛線的模式，格式為 `[線段長度, 空格長度]`
    private let dashPattern: [NSNumber]
    
    /// 虛線的顏色
    private let lineColor: UIColor
    
    // MARK: - Initializer
    
    /// 初始化虛線視圖
    /// - Parameters:
    ///   - lineWidth: 虛線的寬度，預設為 2。
    ///   - dashPattern: 虛線的間距模式，格式為 `[線段長度, 空格長度]`，預設為 `[5, 5]`。
    ///   - lineColor: 虛線的顏色，預設為 `lightGray`。
    init(lineWidth: CGFloat = 2, dashPattern: [NSNumber] = [5, 5], lineColor: UIColor = .lightGray) {
        self.lineWidth = lineWidth
        self.dashPattern = dashPattern
        self.lineColor = lineColor
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    
    /// 使用 Core Graphics 繪製虛線
    /// - Parameter rect: 當前視圖的繪製區域
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(lineWidth)
        context.setLineDash(phase: 0, lengths: dashPattern.map { CGFloat(truncating: $0) })
        context.setStrokeColor(lineColor.cgColor)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        
        context.addPath(path.cgPath)
        context.strokePath()
    }
    
}
