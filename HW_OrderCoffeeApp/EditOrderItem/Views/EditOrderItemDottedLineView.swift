//
//  EditOrderItemDottedLineView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import UIKit

/// `EditOrderItemDottedLineView`
///
/// 自訂虛線視圖，用於在 EditOrderItem 的資訊堆疊中作為分隔線。
/// - 支援自訂虛線的寬度、間距模式及顏色，適用於多種需求的分隔視覺效果。
/// - 使用 `draw(_:)` 方法，透過 Core Graphics 繪製虛線於水平方向上。
class EditOrderItemDottedLineView: UIView {

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
