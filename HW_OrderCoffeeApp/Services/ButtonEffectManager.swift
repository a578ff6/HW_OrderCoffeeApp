//
//  ButtonEffectManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/18.
//

import UIKit

/// 處理按鈕震動反饋
class ButtonEffectManager {
    
    static let shared = ButtonEffectManager()
    
    /// 震動反饋
    func applyHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
