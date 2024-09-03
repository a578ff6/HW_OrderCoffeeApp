//
//  UIView+SpringAnimation.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/30.
//

import UIKit

extension UIView {
    
    /// 添加彈簧動畫效果
    func addSpringAnimation(duration: TimeInterval = 0.2,
                            delay: TimeInterval = 0,
                            usingSpringWithDamping damping: CGFloat = 1.0,
                            initialSpringVelocity velocity: CGFloat = 0.0,
                            options: UIView.AnimationOptions = .allowUserInteraction,
                            scale: CGFloat = 1.1,
                            completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity,
                       options: options,
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
