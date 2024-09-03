//
//  UIView+ScaleAnimation.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/3.
//

import UIKit

extension UIView {
    
    /// 添加縮放動畫效果
    func addScaleAnimation(duration: TimeInterval = 0.1,
                           scale: CGFloat = 0.8,
                           completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: duration,
                       animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { finished in
            UIView.animate(withDuration: duration,
                           animations: {
                self.transform = CGAffineTransform.identity
            }, completion: completion)
        })
    }
    
}
