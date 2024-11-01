//
//  FloatingPanelHelper.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//

// MARK: - FloatingPanelHelper
/*
 ## FloatingPanelHelper：

    - 功能分拆：將浮動面板的所有設置邏輯放入 FloatingPanelHelper 類中，並按照你的原有的設置方式進行劃分，使每個功能模組化。
    - 主設置方法 (setupFloatingPanel)：此方法內部依次調用了初始化、外觀設置、內容設置和添加到父控制器的各個步驟，保證面板設置完整。
 
 1. 使用 Helper 類的好處：

    - 增強可讀性：將面板的設置邏輯與控制器分開，使 StoreSelectionViewController 更加簡潔，控制器只關心它的主要功能（地圖交互和顯示）。
    - 可重複使用：如果其他控制器需要設置浮動面板，現在可以直接使用 FloatingPanelHelper，而不需要重複代碼，減少了維護成本。
 
 2. 職責清晰：

    - StoreSelectionViewController 負責管理地圖顯示和用戶交互。
    - FloatingPanelHelper 負責浮動面板的初始化、設置和添加到父控制器。
 */


// MARK: - StoreSelectionViewController Floating Panel Setup 重點筆記
/*
## StoreSelectionViewController Floating Panel Setup 重點筆記

 1. Floating Panel 設置方法總覽
 
    * setupFloatingPanel()：
        - 負責初始化和設置浮動面板的外觀、內容、以及將其添加到父控制器。
        - 將面板的設置邏輯拆分為多個步驟，以保持簡潔和易於維護。
 
 2. 設置 Floating Panel 主要包括的四個步驟
 
    * initializeFloatingPanelController()：
        - 負責初始化 FloatingPanelController，並設置其代理。
        - 這是最基本的初始化，為後續設置外觀和內容做準備。
 
    * setupFloatingPanelAppearance()：
        - 負責設置面板的外觀，例如圓角和背景顏色。
        - 使用 SurfaceAppearance 來控制面板的樣式，使其符合 UI 設計需求。
 
    * setFloatingPanelContent()：
        - 設定浮動面板的內容視圖控制器，例如這裡的 StoreInfoViewController。
        - 同時，將布局設置為自訂的 StoreInfoPanelLayout 以定義各種狀態下的高度。
 
    * addFloatingPanelToParent()：
        - 將浮動面板控制器添加到父視圖控制器中，讓它真正顯示在螢幕上。
 
 3. 重點方法設計與註解
    
    * 單一職責原則：每個方法只負責一項設置操作，確保 Floating Panel 的設置過程清晰且易於維護。
    * 代理模式的使用：FloatingPanelController 被設置了代理 (delegate)，可以用來管理面板行為，提升交互性。
 */

import UIKit
import FloatingPanel

/// 用於初始化和設置 FloatingPanel 的所有設置，包括初始化、外觀、內容與加入到父控制器
class FloatingPanelHelper {
    
    /// 主方法：設置 Floating Panel 的所有設置，包括初始化、外觀、內容與加入到父控制器
    static func setupFloatingPanel(for parentViewController: UIViewController) -> FloatingPanelController {
        let floatingPanelController = initializeFloatingPanelController(for: parentViewController)
        setupFloatingPanelAppearance(fpc: floatingPanelController)
        setFloatingPanelContent(fpc: floatingPanelController)
        addFloatingPanelToParent(fpc: floatingPanelController, parent: parentViewController)
        
        return floatingPanelController
    }
    
    /// 初始化 FloatingPanelController
    private static func initializeFloatingPanelController(for parentViewController: UIViewController) -> FloatingPanelController {
        let floatingPanelController = FloatingPanelController()
        if let parentVC = parentViewController as? FloatingPanelControllerDelegate {
            floatingPanelController.delegate = parentVC // 設定代理
        }
        return floatingPanelController
    }
    
    /// 設置 Floating Panel 的外觀（例如圓角、背景色等）
    private static func setupFloatingPanelAppearance(fpc: FloatingPanelController) {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 20.0                  // 設置圓角
        appearance.backgroundColor = .white           
        fpc.surfaceView.appearance = appearance
    }

    /// 設置 Floating Panel 的內容視圖控制器
    private static func setFloatingPanelContent(fpc: FloatingPanelController) {
        let storeInfoVC = StoreInfoViewController()
        storeInfoVC.configureInitialState(with: "請點選門市地圖取得詳細資訊")
        fpc.set(contentViewController: storeInfoVC)
        
        // 設置面板的布局，使用自訂的 StoreInfoPanelLayout
        fpc.layout = StoreInfoPanelLayout()
    }
    
    /// 將 Floating Panel 添加到父控制器
    private static func addFloatingPanelToParent(fpc: FloatingPanelController, parent: UIViewController) {
        fpc.addPanel(toParent: parent)
    }
}

