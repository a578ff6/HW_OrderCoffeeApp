//
//  HUDManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//

import UIKit
import JGProgressHUD

/// 用於集中管理 JGProgressHUD 的相關操作。
class HUDManager {
    static let shared = HUDManager()
    
    private let hud = JGProgressHUD(style: .dark)
    
    private init() {
        hud.interactionType = .blockAllTouches  // 禁用所有背景元件的互動
    }
    
    /// 顯示加載指示器
    /// - Parameters:
    ///   - view: HUD 將被添加到的 UIView。
    ///   - text: 要顯示的文字資訊。
    func showLoading(in view: UIView, text: String) {
        hud.textLabel.text = text
        hud.show(in: view)
    }

    /// 隱藏加載指示器
    func dismiss() {
        hud.dismiss()
    }
    
}
