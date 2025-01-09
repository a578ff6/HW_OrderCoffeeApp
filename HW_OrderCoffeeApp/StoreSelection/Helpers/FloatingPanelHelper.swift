//
//  FloatingPanelHelper.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//

// MARK: - FloatingPanelHelper
/**
 
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
/**
 
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


// MARK: - (v)

import UIKit
import FloatingPanel

/// FloatingPanelHelper
///
/// ### 核心功能：
/// 用於初始化和設置 `FloatingPanelController`，包括：
/// 1. 初始化面板並設置其代理。
/// 2. 配置面板外觀（例如圓角、背景色等）。
/// 3. 設置面板內容（ `StoreInfoViewController`）。
/// 4. 將面板加入到父控制器。
///
/// ### 適用場景：
/// 當需要使用 `FloatingPanelController` 作為 UI 元件來展示額外資訊（如店鋪詳細資料）時。
///
/// ### 設計目標：
/// 1. 模組化：
///    - 將面板初始化與設置邏輯集中到一個工具類中，避免在多個控制器中重複相同代碼。
/// 2. 簡化整合：
///    - 通過統一接口方法（`setupFloatingPanel`），輕鬆整合 `FloatingPanelController` 至任何父控制器。
/// 3. 靈活性：
///    - 支持自定義內容控制器與佈局設置，便於未來擴展。
class FloatingPanelHelper {
    
    
    /// 主方法：設置 Floating Panel 的所有設置
    ///
    /// - Parameters:
    ///   - parentViewController: 父控制器，用於容納 Floating Panel。
    /// - Returns: 完整設置好的 `FloatingPanelController` 實例。
    ///
    /// ### 功能：
    /// 1. 初始化 `FloatingPanelController` 並設置其代理。
    /// 2. 配置面板外觀，包括圓角和背景色。
    /// 3. 設置面板的內容控制器與佈局。
    /// 4. 將面板添加到指定的父控制器中。
    static func setupFloatingPanel(for parentViewController: UIViewController) -> FloatingPanelController {
        let floatingPanelController = initializeFloatingPanelController(for: parentViewController)
        setupFloatingPanelAppearance(fpc: floatingPanelController)
        setFloatingPanelContent(fpc: floatingPanelController)
        addFloatingPanelToParent(fpc: floatingPanelController, parent: parentViewController)
        return floatingPanelController
    }
    
    // MARK: - Private Methods
    
    /// 初始化 FloatingPanelController
    ///
    /// - Parameters:
    ///   - parentViewController: 父控制器，用於設置代理。
    /// - Returns: 初始化後的 `FloatingPanelController`。
    ///
    /// ### 功能：
    /// - 創建 `FloatingPanelController` 實例。
    /// - 設置父控制器為其代理（若父控制器符合 `FloatingPanelControllerDelegate` 協議）。
    private static func initializeFloatingPanelController(for parentViewController: UIViewController) -> FloatingPanelController {
        let floatingPanelController = FloatingPanelController()
        if let parentVC = parentViewController as? FloatingPanelControllerDelegate {
            floatingPanelController.delegate = parentVC // 設定代理
        }
        return floatingPanelController
    }
    
    /// 設置 Floating Panel 的外觀
    ///
    /// - Parameters:
    ///   - fpc: 要設置的 `FloatingPanelController`。
    ///
    /// ### 功能：
    /// 配置 `FloatingPanelController` 的外觀：
    /// - 設置面板表面的圓角半徑。
    /// - 設置背景顏色為白色。
    private static func setupFloatingPanelAppearance(fpc: FloatingPanelController) {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 20.0
        appearance.backgroundColor = .white
        fpc.surfaceView.appearance = appearance
    }
    
    /// 設置 Floating Panel 的內容控制器
    ///
    /// - Parameters:
    ///   - fpc: 要設置的 `FloatingPanelController`。
    ///
    /// ### 功能：
    /// - 設置內容控制器為 `StoreInfoViewController`。
    /// - 初始狀態顯示提示資訊。
    /// - 配置自定義佈局 `StoreInfoPanelLayout`。
    private static func setFloatingPanelContent(fpc: FloatingPanelController) {
        let storeInfoVC = StoreInfoViewController()
        storeInfoVC.setState(.initial(message: "請點選門市地圖取得詳細資訊"))
        
        fpc.set(contentViewController: storeInfoVC)
        
        // 設置面板的布局，使用自訂的 StoreInfoPanelLayout
        fpc.layout = StoreInfoPanelLayout()
    }
    
    /// 將 Floating Panel 添加到父控制器
    ///
    /// - Parameters:
    ///   - fpc: 要添加的 `FloatingPanelController`。
    ///   - parent: 目標父控制器。
    ///
    /// ### 功能：
    /// - 將 `FloatingPanelController` 添加至父控制器，顯示為其子視圖。
    private static func addFloatingPanelToParent(fpc: FloatingPanelController, parent: UIViewController) {
        fpc.addPanel(toParent: parent)
    }
    
}

