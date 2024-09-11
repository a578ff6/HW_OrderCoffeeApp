//
//  DottedLineView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/23.
//

import UIKit

/// 虛線：用於 DrinkPriceInfoCollectionViewCell 中，關於營養名稱、數據彼此之間。
class DottedLineView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        context.setLineDash(phase: 0, lengths: [5, 5])
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(2)
        context.addPath(path.cgPath)
        context.strokePath()
    }
}





