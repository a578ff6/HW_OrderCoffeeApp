//
//  DrinkDetailFavoriteStateCoordinator.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/23.
//


// MARK: - DrinkDetailFavoriteStateCoordinator 筆記
/**

 ## DrinkDetailFavoriteStateCoordinator 筆記

 - 當初是在 DrinkDetailViewController 協調 DrinkDetailNavigationBarManager 與 DrinkDetailFavoritesHandler，導致 DrinkDetailViewController 再處理「我的最愛」UI上變得很肥大。
 
 -------------------

 `* What：`

 - `DrinkDetailFavoriteStateCoordinator` 是一個負責`協調收藏功能`的中間層，主要功能包括：

` 1. 收藏邏輯管理：`
 
    - 集中處理收藏按鈕的狀態切換邏輯。
    - 將業務邏輯（後端狀態同步）與 UI 更新解耦。

 `2. UI 與後端同步：`
 
    - 根據後端的收藏狀態更新收藏按鈕的顯示。
    - 確保收藏按鈕的狀態與後端資料一致。

 `3. 使用範圍：`
 
    - 用於 `DrinkDetailViewController`，處理收藏按鈕的點擊事件與狀態更新。

 -------------------

 `* Why：`

 1. 單一職責原則 (SRP)：
 
    - 將收藏邏輯與視圖控制器的其他業務邏輯分離，讓 `DrinkDetailViewController` 的責任更加專注。

 2. 提升可讀性與可維護性：
 
    - 將 UI 更新與業務邏輯交由不同的元件管理，使程式碼更具結構性。
    - 減少控制器中的程式碼冗長，讓邏輯更易於閱讀。

 3. 提高可測性：
 
    - 集中收藏邏輯在單一類別中，便於進行單元測試。
    - 測試 `DrinkDetailFavoriteStateCoordinator` 不需要依賴 `UIViewController` 或其他 UI 元件。

 -------------------

 `* How：`

 1. 初始化時注入依賴：
 
    - 在 `init` 方法中接收 `DrinkDetailNavigationBarManager` 和 `DrinkDetailFavoritesHandler` 作為依賴，分別負責：
 
      - 導航欄管理：更新收藏按鈕的圖示。
      - 收藏邏輯：處理收藏狀態與後端同步。

 2. 核心方法：
 
    - `handleFavoriteToggle(for:)`：
      - 用於處理收藏按鈕的點擊事件。
      - 包括即時切換按鈕狀態、同步後端邏輯，以及根據後端返回結果校正按鈕狀態。
 
    - `refreshFavoriteState(drinkId:)`：
      - 根據後端狀態刷新收藏按鈕的顯示，用於控制器生命週期的狀態同步。

 3. 私有方法：
 
    - `toggleFavoriteButtonUIState(drinkId:)`：
      - 在點擊收藏按鈕時即時更新按鈕的圖示，提供良好的用戶體驗。
 
    - `updateFavoriteButtonUIIfNeeded(finalState:)`：
      - 校正按鈕圖示，確保與後端狀態同步。

 -------------------

 `* 總結`

 `DrinkDetailFavoriteStateCoordinator` 是 `DrinkDetailViewController` 的協調層，旨在實現以下目標：
 
 1. 解耦：將 UI 更新邏輯與後端同步邏輯分離。
 2. 提升結構性：使 `DrinkDetailViewController` 更聚焦於控制層責任。
 3. 易於測試與擴展：集中收藏邏輯，簡化測試並支持未來功能擴展。

 這種設計降低控制器的複雜度，符合單一職責原則，並為應用提供更清晰的架構基礎。
 */



// MARK: - handleFavoriteToggle(for:) 筆記
/**
 
 ## handleFavoriteToggle(for:) 筆記

 `* What`

 - `handleFavoriteToggle(for:)` 是 `DrinkDetailFavoriteStateCoordinator` 中處理收藏按鈕點擊事件的核心方法。它的主要功能是：

 `1. 即時切換收藏按鈕的 UI 狀態：`
 
    - 在後端響應之前，立即更新收藏按鈕的顯示，提升用戶體驗。

` 2. 更新後端的收藏狀態：`
 
    - 根據目前的收藏狀態，執行新增或移除收藏操作，並返回新的收藏狀態。

 `3. 校正收藏按鈕的 UI 狀態：`
 
    - 根據後端返回的最終結果，校正按鈕圖示，確保 UI 與後端資料一致。

 ---------------------

`* Why`

 1. 提升用戶體驗：
 
    - 通過即時更新按鈕 UI，在後端響應之前給用戶即時反饋，避免點擊後無回應造成的體驗不佳。
    - 用戶能快速感知收藏狀態的變化，即使在網路延遲的情況下，也能獲得即時回饋。

 2. 確保數據與 UI 一致性：
 
    - 使用後端的最終結果來校正 UI，防止因網路錯誤或後端同步失敗導致按鈕顯示不準確。

 3. 單一職責分離：
 
    - 將 UI 更新與後端邏輯結合到 `DrinkDetailFavoriteStateCoordinator`，使控制器不需要處理具體的收藏業務邏輯。
    - 提高程式碼的可讀性與模組化程度。

 4. 適應非同步操作：
 
    - 收藏狀態的切換涉及到後端非同步操作，通過 `Task` 與 `async/await`，可以清晰地管理流程，避免複雜的回調地獄。

 ---------------------

 `* How`

 - `執行流程`
 
 `1. 即時切換 UI 狀態：`
 
    - 呼叫 `toggleFavoriteButtonUIState(drinkId:)` 方法。
    - 根據目前收藏狀態，臨時切換按鈕圖示為相反狀態。

 `2. 更新收藏狀態：`
 
    - 使用 `DrinkDetailFavoritesHandler` 的 `toggleFavorite(for:)` 方法，非同步地向後端執行新增或移除操作。
    - 根據操作結果返回新的收藏狀態（已收藏或未收藏）。

 `3. 校正 UI 狀態：`
 
    - 呼叫 `updateFavoriteButtonUIIfNeeded(finalState:)` 方法。
    - 根據後端返回的最終狀態，更新按鈕圖示，確保 UI 與後端一致。

 ---------------------

 `* 程式碼結構解析`

 ```swift
 func handleFavoriteToggle(for favoriteDrink: FavoriteDrink) {
     Task {
         // Step 1: 即時切換按鈕 UI 狀態
         await toggleFavoriteButtonUIState(drinkId: favoriteDrink.drinkId)
         
         // Step 2: 更新收藏狀態
         let finalState = await favoritesHandler.toggleFavorite(for: favoriteDrink)
         
         // Step 3: 校正按鈕狀態
         await updateFavoriteButtonUIIfNeeded(finalState: finalState)
     }
 }
 ```

 `1.Step 1: 即時切換按鈕 UI 狀態：`
 
    - 調用 `toggleFavoriteButtonUIState(drinkId:)`，將按鈕狀態臨時切換為相反值。
    - 使用 `MainActor` 確保 UI 更新在主執行緒中執行，避免 UI 操作錯誤。

 `2. Step 2: 更新收藏狀態：`
 
    - 呼叫 `favoritesHandler.toggleFavorite(for:)`，負責與後端交互，執行收藏狀態切換邏輯。
    - 返回新的收藏狀態，用於後續的 UI 校正。

 `3. Step 3: 校正按鈕狀態：`
 
    - 使用 `updateFavoriteButtonUIIfNeeded(finalState:)` 方法，根據後端返回的結果再次校正按鈕圖示。

 ---------------------

 `* 總結`

 - `handleFavoriteToggle(for:)` 是 `DrinkDetailFavoriteStateCoordinator` 的核心邏輯，設計上遵循以下原則：
 
 1. 以用戶為中心：即時更新 UI，提供快速反饋。
 2. 確保數據準確性：後端結果校正按鈕狀態，保證一致性。
 3. 分層架構清晰：UI 和業務邏輯分離，提升模組化程度。
 4. 非同步友好：利用 `Task` 和 `async/await` 簡化非同步邏輯。

 */



// MARK: - refreshFavoriteState` 與 `toggleFavoriteButtonUIState` 差異
/**
 
 ## refreshFavoriteState` 與 `toggleFavoriteButtonUIState` 差異
 
 - `refreshFavoriteState` 與 `toggleFavoriteButtonUIState` 雖然都涉及更新收藏按鈕的狀態，但它們在職責和使用情境上有明顯的不同：

 ---------------------

 `1. refreshFavoriteState`

 `- 職責`
 
 - 檢查當前收藏狀態並同步到 UI。
 - 根據後端的收藏狀態，確保 UI 顯示正確的按鈕圖示。

 `- 層級與使用情境`
 
 - 用途：當需要重新檢查收藏狀態時使用，例如頁面載入或返回到頁面時。
 - 觸發層級：高層級操作，在控制器的 `viewWillAppear` 或初始化階段觸發。

 `- 程式碼行為`
 
 ```swift
 func refreshFavoriteState(drinkId: String?) {
     guard let drinkId else { return }
     Task {
         let isFavorite = await favoritesHandler.isFavorite(drinkId: drinkId)
         await MainActor.run {
             navigationBarManager?.updateFavoriteButton(isFavorite: isFavorite)
         }
     }
 }
 ```
 
 `- 執行流程：`
 
   1. 呼叫後端檢查該飲品是否已收藏。
   2. 根據後端返回的結果，更新收藏按鈕的圖示。

 `- 適合情境`
 
    1.用於確保 UI 與後端同步。
    2.適合在頁面載入、刷新動作中使用，因為此時需要從後端獲取狀態並更新 UI。

 ---------------------

 `2. toggleFavoriteButtonUIState`

 `- 職責`
 
 - 即時切換收藏按鈕的狀態。
 - 用於提升用戶體驗，在後端響應之前，快速給出視覺回饋。

 `- 層級與使用情境`
 
 - 用途：在用戶點擊收藏按鈕時，臨時切換按鈕的圖示。
 - 觸發層級：局部互動層級，僅在用戶點擊按鈕的交互事件中使用。

 `- 程式碼行為`
 
 ```swift
 @MainActor
 private func toggleFavoriteButtonUIState(drinkId: String) async {
     let currentState = await favoritesHandler.isFavorite(drinkId: drinkId)
     navigationBarManager?.updateFavoriteButton(isFavorite: !currentState)
 }
 ```
 
 `- 執行流程：`
 
   1. 查詢當前收藏狀態。
   2. 將按鈕的顯示狀態臨時切換為相反值。

` - 適合情境`
 
 - 用於即時回饋按鈕的狀態，提升用戶互動體驗。
 - 不負責校正最終狀態，只做臨時切換。

 ---------------------

` * 設計的好處`
 
 1. 清晰的職責分離：
 
    - `refreshFavoriteState` 關注後端同步，確保資料一致性。
    - `toggleFavoriteButtonUIState` 關注用戶即時互動回饋。

 `2. 提升用戶體驗：`
 
    - 用戶點擊時立即切換按鈕狀態，讓操作更直觀。
    - 同時保留後端同步校正按鈕狀態的能力，防止按鈕與真實狀態不一致。

 ---------------------

 `* 總結`
 
 - `refreshFavoriteState` 和 `toggleFavoriteButtonUIState` 的責任是互補的。
 - 前者偏向後端同步，後者專注即時互動。它們在層級設計上清晰分工，讓 `DrinkDetailFavoriteStateCoordinator` 能同時滿足用戶體驗與資料一致性的需求。
 */



import UIKit

/// `DrinkDetailFavoriteStateCoordinator`
///
/// ### 功能說明
/// 負責協調收藏功能的邏輯與 UI 狀態同步，包括：
/// - 管理收藏按鈕的即時切換與狀態更新。
/// - 處理後端收藏邏輯，確保收藏狀態與後端同步。
///
/// ### 設計目標
/// - 單一職責：集中管理與收藏相關的邏輯與狀態更新，將業務邏輯與控制器分離。
/// - 可測性高：透過單一類別集中處理收藏邏輯，便於單元測試。
///
/// ### 使用情境
/// 1. 使用於 `DrinkDetailViewController` 中，用於處理收藏按鈕點擊事件。
/// 2. 根據後端狀態更新收藏按鈕的圖示，保持 UI 與後端資料一致。
class DrinkDetailFavoriteStateCoordinator {
    
    // MARK: - Properties
    
    /// 管理導航列的實例，用於更新收藏按鈕圖示
    private weak var navigationBarManager: DrinkDetailNavigationBarManager?
    
    /// 收藏邏輯處理器，負責與後端交互
    private let favoritesHandler: DrinkDetailFavoritesHandler

    // MARK: - Initializer
    
    /// 初始化協調器
    /// - Parameters:
    ///   - navigationBarManager: 管理導航列的實例，用於更新收藏按鈕圖示
    ///   - favoritesHandler: 負責與後端交互的收藏邏輯處理器
    init(navigationBarManager: DrinkDetailNavigationBarManager, favoritesHandler: DrinkDetailFavoritesHandler) {
        self.navigationBarManager = navigationBarManager
        self.favoritesHandler = favoritesHandler
    }
    
    // MARK: - Public Methods
    
    /// 處理收藏按鈕的點擊事件
    /// - Parameter favoriteDrink: 收藏的飲品數據模型
    func handleFavoriteToggle(for favoriteDrink: FavoriteDrink) {
        Task {
            // Step 1: 即時切換按鈕 UI 狀態
            await toggleFavoriteButtonUIState(drinkId: favoriteDrink.drinkId)
            
            // Step 2: 更新收藏狀態
            let finalState = await favoritesHandler.toggleFavorite(for: favoriteDrink)
            
            // Step 3: 校正按鈕狀態
            await updateFavoriteButtonUIIfNeeded(finalState: finalState)
        }
    }
    
    /// 刷新收藏按鈕的狀態
    /// - Parameter drinkId: 飲品的唯一識別碼
    func refreshFavoriteState(drinkId: String?) {
        guard let drinkId else { return }
        Task {
            let isFavorite = await favoritesHandler.isFavorite(drinkId: drinkId)
            await MainActor.run {
                navigationBarManager?.updateFavoriteButton(isFavorite: isFavorite)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 即時切換收藏按鈕的 UI 狀態
    /// - Parameter drinkId: 飲品的唯一識別碼
    @MainActor
    private func toggleFavoriteButtonUIState(drinkId: String) async {
        let currentState = await favoritesHandler.isFavorite(drinkId: drinkId)
        navigationBarManager?.updateFavoriteButton(isFavorite: !currentState)
    }
    
    /// 根據後端的最終狀態校正收藏按鈕的 UI
    /// - Parameter finalState: 後端返回的最終收藏狀態
    @MainActor
    private func updateFavoriteButtonUIIfNeeded(finalState: Bool) async {
        navigationBarManager?.updateFavoriteButton(isFavorite: finalState)
    }
    
}
