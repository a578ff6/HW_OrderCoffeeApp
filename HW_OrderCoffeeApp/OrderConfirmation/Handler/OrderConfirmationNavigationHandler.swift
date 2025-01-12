//
//  OrderConfirmationNavigationHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/11.
//

// MARK: - OrderConfirmationNavigationHandler 筆記
/**

 ## OrderConfirmationNavigationHandler 筆記

` * What：`
 
 - `OrderConfirmationNavigationHandler` 是一個用於處理 `OrderConfirmationViewController` 與其他頁面導航邏輯的工具類別。
 - 它負責清空導航堆疊、切換 Tab，以及解散模態視圖控制器。

 ---

 `* Why：`

 1. 統一導航邏輯：
 
    - 將複雜的導航操作集中在一個類別中，減少重複代碼，並提高可維護性。

 2. 視圖層級明確：
 
    - 在應用中，`OrderConfirmationViewController` 是以模態全屏的方式呈現，需正確返回父視圖（`UITabBarController`），以確保導航行為符合用戶預期。

 3. 支援多場景導航：
 
    - 提供清空導航堆疊、切換 Tab 和解散視圖控制器的能力，可適配未來更多需求。

 4. 提高可讀性：
 
    - 將導航操作抽象化，讓 `ViewController` 專注於自身的業務邏輯。

 ---

 `* How：`

 1. 重置導航堆疊並切換到目標 Tab
 
    - 當需要清空所有 Tab 的導航堆疊並返回特定頁面時，調用以下方法：
 
    ```swift
    navigationHandler.resetNavigationStacks(with: tabBarController, targetTab: .menu)
    ```

 2. 從父層控制器解散模態視圖
 
    - 使用 `dismiss(viewController:completion:)` 方法解散當前模態頁面：
 
    ```swift
    navigationHandler.dismiss(viewController: self) { [weak self] in
        self?.navigationHandler.resetNavigationStacks(with: tabBarController, targetTab: .menu)
    }
    ```

 3. 獲取 `UITabBarController`
 
    - 當無法直接取得 `UITabBarController` 的情況下，使用 `getTabBarController()` 動態查找：
 
    ```swift
    if let tabBarController = navigationHandler.getTabBarController() {
        navigationHandler.resetNavigationStacks(with: tabBarController, targetTab: .menu)
    }
    ```

 ---

 `* 結論`

 1. 已經調整成根據導航流程直接使用 `presentingViewController`：
 
 - 當導航結構固定，`presentingViewController` 是符合 iOS 設計且效能更高的解法。
 
 2. 保留 `getTabBarController` 作為輔助工具：
 
 - 在未來導航結構可能變化時，`getTabBarController` 是一個靈活的備選方案。
 
 3. 類別設計符合單一職責原則：
 
 - 所有導航相關邏輯集中在 `OrderConfirmationNavigationHandler`，提高代碼清晰度和可維護性。
 
 */


// MARK: - 筆記：導航處理方式選擇（`presentingViewController` vs `getTabBarController`）_（重要）
/**
 
 ## 筆記：導航處理方式選擇（`presentingViewController` vs `getTabBarController`）

 - 原本使用 getTabBarController，但在重構的過程中發現，在明確知道導航架構，的情況下，直接採用 `presentingViewController` 來處理比較方便。
 - 因此製作該筆記。
 
 -----------

 `* What：導航處理方式的選擇`

 - 在處理 `OrderConfirmationViewController` 的返回導航邏輯時，有兩種主要方法可供選擇：
 
 1. `presentingViewController`：
 
 - 直接使用 `OrderConfirmationViewController` 的 `presentingViewController` 屬性，取得 `UITabBarController` 的參考。
 
 2. `getTabBarController`：
 
 - 透過遍歷應用程式的 Window 層級，動態查找目前活躍的 `UITabBarController`。

 兩種方法在導航結構固定的情況下都可以使用，但在不同的場景下有其適用性與優劣勢。

 -----------

 `* Why：選擇 presentingViewController 的原因`

 1. 符合 iOS 的層級設計邏輯：
 
    - `presentingViewController` 是系統內建的屬性，用於追蹤模態呈現的父控制器，符合 iOS 系統對於視圖控制器層級的管理設計。
    - 符合直觀的父子關係表達，更具語意化，代碼可讀性更高。

 2. 執行效能更佳：
 
    - 透過 `presentingViewController` 直接取得父層控制器，不需要遍歷窗口層級，減少不必要的查找邏輯。
    - 若導航結構固定，這種方式是效能最佳的解法。

 3. 簡潔明瞭：
 
    - 使用 `presentingViewController` 更加直觀，無需額外的條件檢查或查找邏輯，減少了可能的錯誤或混淆。

 4. 導航結構清晰：
 
    - 在目前的導航流程中，`OrderConfirmationViewController` 的父層固定是 `UITabBarController`，因此可以直接利用 `presentingViewController` 確保導航邏輯正確。

 -----------

 `* Why：getTabBarController 的適用場景`

 1. 導航結構不固定：
 
    - 若應用可能存在多個 `UITabBarController` 或需要根據窗口層級查找特定的 `UITabBarController`，`getTabBarController` 提供了一個通用的查找方式。
    - 當導航結構靈活且未來可能變化時，保留該方法可以增加代碼適配性。

 2. 特殊需求或自定義場景：
 
    - 若某些情況下無法使用 `presentingViewController`（例如複雜的自定義導航邏輯），則 `getTabBarController` 是可行的替代方案。

 -----------

` * How：選擇 presentingViewController 並進行實作`

 依據目前的導航流程，使用 `presentingViewController` 實現返回邏輯：

 ```swift
 private func proceedWithClosing() {
     // 使用 presentingViewController 獲取 TabBarController
     guard let presentingViewController = self.presentingViewController as? UITabBarController else { return }
     
     CustomerDetailsManager.shared.resetCustomerDetails() // 清空顧客資料
     OrderItemManager.shared.clearOrder()                // 清空訂單資料
     
     navigationHandler.dismiss(viewController: self) { [weak self] in
         self?.navigationHandler.resetNavigationStacks(with: presentingViewController, targetTab: .menu)
     }
 }
 ```

 -----------

 `* How：保留 getTabBarController 作為備選方案`

 若未來應用的導航結構可能改變，保留 `getTabBarController`，應用於需要通用性更高的場景：

 ```swift
 private func proceedWithClosing() {
     guard let tabBarController = navigationHandler.getTabBarController() else { return }
     
     CustomerDetailsManager.shared.resetCustomerDetails() // 清空顧客資料
     OrderItemManager.shared.clearOrder()                // 清空訂單資料
     
     navigationHandler.dismiss(viewController: self) { [weak self] in
         self?.navigationHandler.resetNavigationStacks(with: tabBarController, targetTab: .menu)
     }
 }
 ```

 -----------

 `* 結論`

 1. 目前使用 `presentingViewController`：
 
 - 導航結構固定的情況下，該方式更貼合 iOS 設計，效能更高且代碼簡潔。
 
 2. 保留 `getTabBarController` 作為擴展：
 
 - 在未來需要適配多樣導航結構時，仍可考慮使用該方法以增強靈活性。
 */


// MARK: - 重點筆記：導航堆疊重置與動畫過渡調整
/**
 
 ## 重點筆記：導航堆疊重置與動畫過渡調整

` * What`
 
 - 功能：
   - `resetNavigationStacks()` 方法負責將應用中所有主要頁面的導航堆疊重置至根視圖控制器。
   - 提供平滑的過渡動畫，確保用戶在結束特定流程（如訂單確認）後，應用的導航狀態始終保持一致。
 
 -------
 
 `* Why`
 
 - 導航狀態一致性：
 
   - 結束操作後，若導航堆疊仍停留在深層頁面，可能導致用戶再次訪問時看到未預期的內容。
   - 重置堆疊能確保用戶回到根頁面，提升應用的易用性與體驗一致性。
 
 - 視覺過渡體驗：
 
   - 淡入動畫減少多層視圖切換的跳躍感，讓導航過程更自然流暢，避免用戶感受到突兀的切換。
 
 - 簡化狀態管理：
 
   - 統一導航堆疊的狀態管理，減少不一致狀態引發的潛在錯誤，並降低維護成本。
 
 -------

 `* How`
 
 - 實現細節：
 
   1. 重置所有頁面的導航堆疊：
 
      - 使用 `UIView.transition` 與 `transitionCrossDissolve` 為每個頁面的返回操作提供淡入動畫。
      - 確保所有頁面一視同仁，避免視覺體驗的差異。
   
   2. 切換到目標 Tab：
 
      - 若指定了 `targetTab`，在導航堆疊重置後，透過 `selectedIndex` 切換到目標 Tab。
      - 確保用戶結束操作後返回預期的主畫面（如主選單）。
 
 ---

 - 程式碼邏輯：
 
   ```swift
   for tabIndex in TabIndex.allCases {
       guard let navigationController = tabBarController.viewControllers?[tabIndex.rawValue] as? UINavigationController else { continue }
       UIView.transition(with: navigationController.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
           navigationController.popToRootViewController(animated: false)
       })
   }
   guard let targetTab = targetTab else { return }
   tabBarController.selectedIndex = targetTab.rawValue
   ```
 
 ---
 
 - 問題與解決方案：
 
   - 問題： 訂單確認流程結束後，某些頁面可能殘留多層導航堆疊，導致用戶返回時導航狀態不一致。
 
   - 解決：
     - 通過 `TabIndex` 精準定位各頁面的 `NavigationController`，並使用 `popToRootViewController` 確保回到根視圖。
     - 對導航過渡加入動畫效果，提升用戶體驗。
 
 -------

 `* 結論`
 
 - `resetNavigationStacks()` 方法提供了簡潔的解決方案，實現了導航狀態的一致性與用戶體驗的優化。
 - 適用於結束特定流程（如訂單確認）後返回主畫面的場景，能有效提升應用的穩定性與視覺一致性。
 
 */



// MARK: - (v)

import UIKit

/// 負責管理 OrderConfirmation 頁面相關的導航操作
///
/// 此類別的目的是統一處理 `OrderConfirmationViewController` 與其他視圖之間的導航邏輯，提供簡潔且易於維護的解決方案。
///
/// 功能說明：
///
/// 1. 重置導航堆疊：可清空所有 Tab 的導航堆疊，並選擇性切換到指定的目標 Tab。
/// 2. 獲取 TabBarController：透過系統屬性動態獲取當前活躍的 `UITabBarController`。（暫時取消）
/// 3. 解散視圖控制器：處理模態視圖的解散操作，並支援自定義完成操作。
///
/// 使用場景：
/// - 當需要返回主畫面或清空導航堆疊時。
/// - 在多層視圖結構中統一處理導航。
class OrderConfirmationNavigationHandler {
    
    /// 重置所有 Tab 的導航堆疊並加入淡入動畫，讓視覺過渡更加平順。
    ///
    /// - Parameters:
    ///   - tabBarController: 當前的 `UITabBarController`，用於操作各 Tab 的導航堆疊。
    ///   - targetTab: （選填）目標 Tab 的索引，若提供此參數，將在完成堆疊重置後切換到該目標 Tab。
    ///
    /// 使用場景：
    /// - 當需要清空所有 Tab 的導航堆疊，例如從深層頁面返回主畫面時，可使用此方法。
    func resetNavigationStacks(with tabBarController: UITabBarController, targetTab: TabIndex? = nil) {
        for tabIndex in TabIndex.allCases {
            guard let navigationController = tabBarController.viewControllers?[tabIndex.rawValue] as? UINavigationController else { continue }
            UIView.transition(with: navigationController.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                navigationController.popToRootViewController(animated: false)
            })
        }
        
        // 切換到目標 Tab（若有提供）
        guard let targetTab = targetTab else { return }
        tabBarController.selectedIndex = targetTab.rawValue
    }
    
    /*
    /// 獲取當前的 UITabBarController
    ///
    /// 此方法負責從應用程式的 Window 中找到當前活躍的 `UITabBarController`。
    ///
    /// - Returns: 若成功找到 `UITabBarController`，則返回該實例；否則返回 nil。
    ///
    /// 使用場景：
    /// - 在需要操作 TabBarController（例如切換 Tab 或重置堆疊）時使用。
    /// - 當導航結構複雜且無法直接從父視圖獲取 TabBarController 時。
    func getTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
              let tabBarController = keyWindow.rootViewController as? UITabBarController else {
            return nil
        }
        return tabBarController
    }
     */
    
    /// 解散當前的視圖控制器
    ///
    /// 此方法用於解散當前的視圖控制器，並在解散完成後執行指定的完成操作。
    ///
    /// - Parameters:
    ///   - viewController: 要解散的視圖控制器。
    ///   - completion: （選填）解散完成後執行的回呼操作。
    ///
    /// 使用場景：
    /// - 當用戶操作需要返回上一層時，例如在確認頁面返回主頁。
    func dismiss(viewController: UIViewController, completion: (() -> Void)? = nil) {
        viewController.dismiss(animated: false, completion: completion)
    }
    
}



