//
//  HUDManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//

/*
 ## 重點筆記：為何要在 Main Thread 中執行 HUD 操作:
 
    - 一開始我沒有在 Main Thread 執行，導致我的HUD在顯示的過程時，位置都會變化，此外我設置 blockAllTouches 都沒反應。
    - 所有與 UI 相關的更新或操作都必須在主執行緒（Main Thread）上執行。若在背景執行緒中進行 UI 操作，可能會導 App 或出現未預期的行為。

    * 為什麼 HUD 需要在 Main Thread 執行？
        
    - UI 安全性：HUD 本質上是一個 UI 元件，它的顯示和隱藏都涉及到畫面更新，因此必須在主執行緒上執行。
    - 避免競態條件：在非主執行緒上更新 UI 可能會與其他 UI 操作產生競態條件，導致顯示錯誤或其他問題。
    - 一致性：確保所有的 HUD 操作在同一個執行緒上執行，避免因執行緒錯誤導致的邏輯錯亂。

    * 結論：將 HUD 操作放在 DispatchQueue.main.async 中，不僅能確保操作在主執行緒上執行，也可以保證 UI 更新的正確性與穩定性。
 */


import UIKit
import JGProgressHUD

/// 用於集中管理 JGProgressHUD 的相關操作。
class HUDManager {
    static let shared = HUDManager()
    
    private let hud = JGProgressHUD(style: .dark)
    
    private init() {
        hud.interactionType = .blockAllTouches  // 禁用所有背景元件的互動，防止在 HUD 顯示時與背景進行任何操作
        hud.backgroundColor = UIColor(white: 0, alpha: 0.4)  // 設置半透明的背景遮罩
    }
    
    /// 顯示加載指示器，將 HUD 顯示在應用的最頂層（即 window 上）。
    /// 該方法保證 HUD 始終顯示在畫面的最頂層，並覆蓋所有內容，包括 TabBar 和 NavigationBar。
    ///
    /// - Parameter text: 要顯示在 HUD 上的文字，例如 "Loading"。
    func showLoading(text: String) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                self.hud.textLabel.text = text
                self.hud.show(in: window)  // 加載到整個畫面的最頂層 UIWindow 上
            }
        }
    }
    
    /// 顯示加載指示器，將 HUD 顯示在指定的視圖上。
    /// 此方法適合用於將 HUD 加載到特定的視圖控制器範圍內，避免影響到其他視圖控制器。
    /// 例如：當執行特定頁面的加載操作時，HUD 只會顯示在該頁面上，隨著視圖控制器的切換，HUD 也會隨之消失。
    ///
    /// - Parameters:
    ///   - view: HUD 將被添加到的具體 UIView（通常是當前的視圖控制器的主視圖）。
    ///   - text: 要顯示在 HUD 上的文字，例如 "Loading"。
    func showLoadingInView(_ view: UIView, text: String) {
        DispatchQueue.main.async {
            self.hud.textLabel.text = text
            self.hud.show(in: view)  // 加載到具體的視圖
        }
    }

    /// 隱藏加載指示器
    /// 使用 DispatchQueue.main.async 確保隱藏 HUD 的操作在main執行
    func dismiss() {
        DispatchQueue.main.async {
            self.hud.dismiss()
        }
    }
    
}

