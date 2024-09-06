//
//  UIView+ScaleAnimation.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/3.
//

/*
    ## UIView+ScaleAnimation：
 
    * 功能： 添加縮放動畫效果，並選擇是否在動畫完成後執行某些操作，例如 segue 跳轉。

    * 方法： addScaleAnimation(duration:scale:performSegue:)

    * 參數：
        - duration: 動畫的持續時間，預設為 0.1 秒。
        - scale: 縮放比例，預設為 0.8，表示縮小至原始尺寸的 80%。
        - performSegue: 選擇性閉包，當動畫結束時，執行跳轉或其他操作。
 
    * 實現邏輯：
        1. 第一次動畫縮放視圖。
        2. 動畫結束後，回復視圖至原始大小。
        3. 動畫結束後，如果有提供 performSegue 閉包，執行該閉包邏輯。
 
    * 適用場景：
        - 當希望在點擊某個 UI 元素時，添加縮放動畫並在動畫完成後執行跳轉操作（例如切換到下一個頁面）。
 
    * 使用方向：
        - 動畫後跳轉：當動畫完成時，會執行 performSegue 或其他的頁面跳轉邏輯。
        - 同步執行動畫與跳轉：不等待動畫完成，點擊後即進行跳轉。
 */

import UIKit

extension UIView {
    
    /// 添加縮放動畫效果，並選擇在動畫完成後執行特定邏輯。
    func addScaleAnimation(duration: TimeInterval = 0.1, scale: CGFloat = 0.8, performSegue: (() -> Void)? = nil) {
        
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)   // 縮小動畫
        }) { finished in
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform.identity              // 回復原始大小
            }) { _ in
                performSegue?()                                          // 動畫結束後執行 segue
            }
        }
    }
    
}
