//
//  OrderHistoryNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - OrderHistoryNavigationBarManager 的設計與功能
/**
 ## OrderHistoryNavigationBarManager 的設計與功能
 
` 1.功能概述：`
 
 - `OrderHistoryNavigationBarManager` 是一個負責管理 `OrderHistory` 導航欄配置的類別。
 - 它不僅負責導航欄按鈕的設置與更新，也管理導航欄標題及大標題顯示模式，旨在將所有與導航欄相關的邏輯從主視圖控制器分離，減少 `OrderHistoryViewController` 的責任。
 
 `2.設計決策：`

 `* 責任分離與簡化視圖控制器`：
    - `OrderHistoryViewController` 專注於視圖的展示和用戶操作，而 `OrderHistoryNavigationBarManager` 則集中管理導航欄的標題、按鈕配置及邏輯處理。
 
 `* 弱引用避免循環引用`：
    - 所有的 `navigationItem`、`navigationController`、`editingHandler`、`sortMenuHandler` 都設置為 weak，以避免強引用循環，導致記憶體泄漏。
 
 `3.主要方法與作用：`
 
 `* configureNavigationBarTitle(title:)：`
    - 設置導航欄的標題及大標題顯示模式，包括顯示大標題。
    - 使用 `largeTitleDisplayMode` 設置為 .always，並通過 navigationController?.navigationBar.prefersLargeTitles 來啟用大標題。

 `* setupInitialNavigationBar()：`
    - 設置初始的導航欄按鈕，包括「排序」和「編輯」按鈕。這些按鈕通常在非編輯模式下顯示。
    - 編輯按鈕的啟用狀態根據是否有訂單進行設置（透過 `editingHandler.isOrderListEmpty()` 方法）。
    - 當訂單列表為空時，禁用編輯按鈕；當有可編輯的訂單時，啟用編輯按鈕。

 `* setupEditingNavigationBar()：`
    - 設置編輯模式下的導航欄按鈕，包括「完成」和「刪除」兩個按鈕。
    - 刪除按鈕的啟用/禁用邏輯：刪除按鈕的啟用狀態取決於是否有選中的訂單項目。
        - 當有選中項目時，刪除按鈕啟用，否則禁用。
        - 通過` editingHandler.hasSelectedRows() `方法來確定當前是否有選中的行。
 
 `* editButtonTapped()：`
    - 處理「編輯/完成」按鈕的切換，當用戶點擊「編輯」時進入編輯模式，並切換按鈕為「完成」和「刪除」；當用戶點擊「完成」時退出編輯模式，恢復為初始狀態。
 
 `* deleteButtonTapped()：`
    -  處理「刪除」按鈕的動作，調用 `editingHandler` 來執行多選刪除的邏輯。
    - 刪除後保持在編輯模式下，並更新導航欄按鈕狀態，確保刪除後狀態正確反映當前可操作的情況。
 
 `4. 編輯按鈕的啟用/禁用邏輯：`
 
 `* 初始化導航欄按鈕的狀態：`
    - 當首次設置導航欄按鈕時（如在視圖加載後），通過 `setupNavigationBar() `方法根據當前的訂單狀態設置編輯按鈕是否可用。
 
 `* 訂單數據的變化處理：`
    - 在 `OrderHistoryViewController` 中，每次訂單數據` (orders) `發生變化時，會調用 `updateEditButtonState()`，這個方法會通過` navigationBarManager?.setupInitialNavigationBar() `重新檢查並設置編輯按鈕的狀態，確保按鈕反映當前的訂單情況。
    - 確保當所有訂單都被刪除後，編輯按鈕會被禁用，防止進入無訂單的編輯狀態。

 `* 刪除按鈕狀態管理`
    - `根據選擇的行來動態設置刪除按鈕`：新增的 `setupEditingNavigationBar() `方法中，使用 `editingHandler.hasSelectedRows() `方法來動態確定刪除按鈕的狀態。
        - 當沒有選擇任何行時，刪除按鈕被禁用，防止誤操作。
        - 當有選中的行時，刪除按鈕才會被啟用，允許用戶執行刪除操作。
 
` 5.責任分離與模組化：`

 `* 導航欄管理模組化`：`
    - `OrderHistoryNavigationBarManager` 不僅獨立於主視圖控制器，負責按鈕的設置，現在也涵蓋標題和大標題顯示模式的管理，確保導航欄所有配置集中在一個類中。
 
 `* 與其他處理器協作`：
    - `OrderHistoryNavigationBarManager` 通過與 `OrderHistoryEditingHandler` 和 `SortMenuHandler` 協作，管理表格的編輯狀態及排序選單。
 
` 6.合作對象：`
 
 - `OrderHistoryEditingHandler`：
    - 負責管理表格的編輯模式和多選刪除操作，通過 `toggleEditingMode() `和 `deleteSelectedRows() `與 `OrderHistoryNavigationBarManager` 互動。
    - `編輯與刪除按鈕狀態管理`：
        - 編輯按鈕的狀態是基於 `isOrderListEmpty() `來決定的。
        - 而刪除按鈕則通過 `hasSelectedRows() `來動態管理。
        - 這使得按鈕的啟用狀態能動態反映當前的訂單和選擇情況。
 
 - `SortMenuHandler`：
    - 負責創建排序選單，通過` createSortMenu() `提供排序按鈕的菜單。方便用戶對歷史訂單進行不同方式的排序。 
 */


// MARK: - 刪除操作的 UI 更新問題
/**
## 刪除操作的 UI 更新問題

`1. 問題描述`

- 刪除操作後，導航欄按鈕的顯示變為「排序按鈕」和「編輯按鈕」，而不是保持在「編輯模式」的狀態。
- 這會導致用戶在刪除後如果還想繼續編輯，需額外再次點擊「編輯」按鈕，影響使用流暢度。
 
`2. 所遇到的問題`
 
 * `原先的導航欄按鈕 UI 與邏輯不同`
    - 在原本的設計中，刪除後導航欄的按鈕狀態與預期的「編輯模式」不一致，造成按鈕的行為邏輯與界面顯示不符。

`3. 原因`

- 在刪除操作後調用了 `setupInitialNavigationBar()`，使導航欄按鈕恢復成了非編輯狀態。

`4. 解決方案`

- 在 `deleteButtonTapped` 中使用 `setupEditingNavigationBar()`，確保刪除後的導航欄按鈕仍保持在編輯狀態，以優化用戶體驗。
*/


// MARK: - editButtonTapped 與 deleteButtonTapped 的行為差異
/**
## 差異分析

`1. editButtonTapped 與 deleteButtonTapped 的行為差異`

- `editButtonTapped`：
    - 負責在「編輯模式」和「完成模式」之間切換。
    - 使用 `editingHandler?.isEditing == true ? setupEditingNavigationBar() : setupInitialNavigationBar()` 來根據當前狀態動態設置導航欄按鈕。
    - 主要給`doneButton`、`editButton`使用。
 
- `deleteButtonTapped`：
    - 負責刪除選中項目後，保持在「編輯模式」。
    - 使用 `setupEditingNavigationBar()` 直接保持導航欄的編輯狀態配置，以確保用戶在刪除後可以繼續進行編輯操作。
*/


// MARK: - 按鈕狀態管理的層級與職責分析：以編輯與刪除按鈕為例（重要）
/**
 ## 按鈕狀態管理的層級與職責分析：以編輯與刪除按鈕為例
 
 `1.背景：`
 
 - 在設計 OrderHistory 視圖的導航欄按鈕時，考慮了「編輯按鈕」和「刪除按鈕」在狀態管理上的不同。

` 2.按鈕狀態依賴性分析：`
 
` * 編輯按鈕：`
 - 依賴性：取決於是否存在訂單，即屬於靜態的數據依賴。
 - 管理層級：更高層級，處理的是整體訂單的存在性問題。
 - 管理方式：在 `orders` 更新時自動檢查並設置按鈕狀態，以反映是否可以進入編輯模式。
 
 `* 刪除按鈕：`
 - 依賴性：取決於當前是否有選中的行，屬於動態的用戶交互依賴。
 - 管理層級：較低層級，具體的行選取狀態和用戶操作。
 - 管理方式：由 `OrderHistoryHandler` 通過 `delegate` 通知 `OrderHistoryNavigationBarManager` 更新狀態。
 
 `3.職責區分與管理方式選擇：`

 - 編輯按鈕 的職責是「是否允許進入編輯模式」，適合基於訂單是否存在的整體層級進行管理。
 - 刪除按鈕 的職責是「根據用戶選擇的情況進行刪除」，因此需要即時響應用戶選擇的動態變化，適合由 delegate 來進行狀態更新。
 
 `4.總結：`

 - 在設計按鈕的狀態管理方式時，不應為了統一而忽略各按鈕的特定職責與依賴性。
 - 根據不同按鈕的職責、依賴性和管理層級，選擇不同的管理方式可以讓代碼結構更加清晰，也更符合各自的需求。
 - 遵循單一責任原則（SRP），按鈕狀態的管理應基於其具體角色進行劃分，從而確保更靈活、更可維護的設計。
 */


// MARK: - OrderHistory NavigationBar 按鈕狀態管理的設計決策分析（重要）
/**
 ## OrderHistory NavigationBar 按鈕狀態管理的設計決策分析

    - 主要是在設置「編輯按鈕」、「刪除按鈕」的狀態時，讓我思考兩者的管理層級問題，以及依照管理層級來決定兩者的職責該如何去區分。
 
 `1. 背景與問題`
 
 * 在 `OrderHistory` 的導航欄中，有「編輯」與「刪除」按鈕。這兩個按鈕的啟用狀態由於依賴不同的因素，分別通過不同的方式來進行管理。目前的設計如下：
 
 - `刪除按鈕的狀態:`是通過 `delegate` 通知來決定的。
 - `編輯按鈕的狀態:`則是在訂單數據（`orders`）變化時進行設置。

 * `這引發了一個設計上的問題`：是否應該統一這些按鈕的狀態管理方式，例如都透過 `delegate` 來進行，或者說這兩者在職責層面有所不同，因此適合用不同的管理方式。

 
`2. 目前的設計分析`

 `* 刪除按鈕的狀態`
 
 - `方式：` 通過 `didChangeSelectionState()` 方法，由 `OrderHistoryHandler` 通知 `OrderHistoryNavigationBarManager`，當選取狀態變更時更新刪除按鈕的啟用狀態。
 - `適用情境：` 刪除按鈕的啟用狀態依賴於當前表格中是否有選中的行，因此使用 `delegate` 來通知是合理的設計。這是基於用戶行為的動態更新，與 UI 互動密切相關。

 `* 編輯按鈕的狀態`
 
 - `方式：` 在 `setupInitialNavigationBar()` 方法中，根據 `editingHandler.isOrderListEmpty()` 來設置編輯按鈕的狀態。當訂單數據（`orders`）變化時自動通過 `didSet` 更新。
 - `適用情境：` 編輯按鈕的狀態基於是否有可編輯的訂單來決定，是一個較為靜態的狀態。由於這與訂單數據的存在性直接相關，並不依賴用戶交互，使用 `didSet` 來設置可以確保按鈕狀態始終與訂單數據一致。

 
 `3. 是否應統一使用 delegate？`

 `* 職責分離考量：`
 
   - `刪除按鈕`：  其狀態管理需要根據用戶行為的動態變化，選取和取消選取行都是用戶交互的一部分，因此使用 `delegate` 通知合乎邏輯。
   - `編輯按鈕`：  其狀態取決於數據是否存在，這是一個靜態的依賴，並不需要由用戶交互來觸發更新。因此，使用 `didSet` 來根據訂單數據的變化設置按鈕狀態是合理的。

 `* 一致性與耦合度平衡：`
 
   - 對所有按鈕狀態統一使用 `delegate` 處理確實可以提高 API 的一致性，但也會增加代碼的耦合度和不必要的複雜性，特別是在處理靜態數據變化時。
   - 現有的設計保留了簡潔性，使得各個按鈕的狀態管理方式更加符合它們各自的責任，減少了不必要的耦合。

 
 `4. 建議改進方案`

 `* 保留現有設計：`
 
    - 刪除按鈕使用 `delegate` 來管理，因為它需要根據用戶選擇動態更新狀態。
    - 編輯按鈕基於訂單是否存在來設置，因此使用 `didSet` 是合理的。

` * 擴展性考慮：`
    - 如果未來的需求變得更加複雜，可以考慮使用更多的通知機制（如 `NotificationCenter` 或 `Combine`）來處理數據變化與 UI 的聯動，以解耦按鈕狀態的更新邏輯。

 
 `5. 總結`
 
 - `刪除按鈕 和 編輯按鈕` 的狀態管理方式應根據其職責進行選擇。
 - `刪除按鈕` 依賴於用戶的動態交互，因此使用 `delegate` 是合理的。
 - `編輯按鈕`基於訂單是否存在來設置，因此使用 `didSet` 根據數據變化設置更加合適。
 - 不需要為了統一而統一，應該根據不同按鈕的行為特徵和職責選擇適合的管理方式。
 */


import UIKit

/// 負責 `OrderHistory` 導航欄按鈕的配置和更新
/// - 包含導航欄按鈕的設置、大標題顯示模式及標題的設置。
class OrderHistoryNavigationBarManager {
    
    // MARK: - Properties

    /// `UINavigationItem` 用於設置導航欄上的按鈕和標題
    private weak var navigationItem: UINavigationItem?
    
    /// `UINavigationController` 用於設置導航欄的大標題顯示模式
    private weak var navigationController: UINavigationController?

    /// 負責管理編輯模式的 `OrderHistoryEditingHandler`，處理多選和刪除邏輯
    private weak var editingHandler: OrderHistoryEditingHandler?
    
    /// 排序選單的處理器，用於創建排序選項
    private weak var sortMenuHandler: OrderHistorySortMenuHandler?

    // MARK: - Initialization

    /// 初始化方法
    /// - Parameters:
    ///   - navigationItem: 傳入的 `UINavigationItem`，用於管理導航欄上的按鈕和標題
    ///   - navigationController: 傳入的 `UINavigationController`，用於設置大標題顯示模式
    ///   - editingHandler: 負責管理編輯模式的處理器
    ///   - sortMenuHandler: 負責創建排序選單的處理器
    init(navigationItem: UINavigationItem, navigationController: UINavigationController?, editingHandler: OrderHistoryEditingHandler, sortMenuHandler: OrderHistorySortMenuHandler) {
        self.navigationItem = navigationItem
        self.navigationController = navigationController
        self.editingHandler = editingHandler
        self.sortMenuHandler = sortMenuHandler
    }
    
    // MARK: - Setup NavigationBar
    
    /// 設置導航欄上的標題及大標題顯示模式
    /// - Parameter title: 要顯示的導航大標題
    func configureNavigationBarTitle(title: String) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    /// 更新導航欄上的按鈕
    /// - Parameter buttons: 要顯示在導航欄右側的按鈕陣列
    private func updateNavigationBarButtons(_ buttons: [UIBarButtonItem]) {
        navigationItem?.rightBarButtonItems = buttons
    }
    
    /// 設置`初始`的導航欄按鈕
    /// - 包含「排序」和「編輯」按鈕，適合初始非編輯模式的情境
    /// - `「排序」按鈕`提供多種排序選項；`「編輯」按鈕`允許進入編輯模式
    /// - `編輯按鈕狀態`根據是否有訂單來決定是否啟用
    func setupInitialNavigationBar() {
        guard let sortMenuHandler = sortMenuHandler, let editingHandler = editingHandler else { return }
        
        // 創建排序按鈕
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            primaryAction: nil,
            menu: sortMenuHandler.createSortMenu()
        )
                
        // 創建編輯按鈕
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil.and.list.clipboard"),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        // 根據訂單是否為空來決定編輯按鈕的啟用狀態
        editButton.isEnabled = !editingHandler.isOrderListEmpty()

        updateNavigationBarButtons([sortButton, editButton])
    }
    
    /// 設置`編輯模式`下的導航欄按鈕
    /// - 說明：包含「完成」和「刪除」按鈕，適合在進入編輯模式後使用
    /// - `「完成」按鈕`允許用戶結束編輯；`「刪除」按鈕`允許刪除選中的訂單
    /// - 根據是否有選中的行來啟用或禁用「刪除」按鈕
    func setupEditingNavigationBar() {
        guard let editingHandler = editingHandler else { return }

        // 創建完成按鈕
        let doneButton = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .done
            , target: self,
            action: #selector(editButtonTapped)
        )
        
        // 創建刪除按鈕
        let deleteButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain
            , target: self,
            action: #selector(deleteButtonTapped)
        )
        // 根據是否有選中的項目來啟用或禁用刪除按鈕
        deleteButton.isEnabled = !(editingHandler.isOrderListEmpty()) && (editingHandler.hasSelectedRows())
        print("Delete button is enabled: \(deleteButton.isEnabled)")
        
        updateNavigationBarButtons([doneButton, deleteButton])
    }
    
    // MARK: - Button Actions
    
    /// 處理「編輯/完成」按鈕的動作
    /// - 根據當前是否處於編輯模式，切換導航欄上的按鈕
    @objc private func editButtonTapped() {
        
        // 切換編輯模式
        editingHandler?.toggleEditingMode()
        
        // 根據當前編輯模式更新導航欄
        editingHandler?.isEditing == true ? setupEditingNavigationBar() : setupInitialNavigationBar()
    }
    
    /// 處理「刪除」按鈕的動作
    /// - 調用 `editingHandler` 來刪除選中的行
    @objc private func deleteButtonTapped() {
        editingHandler?.deleteSelectedRows()
        // 保持在編輯模式下，更新導航欄按鈕為編輯狀態
        setupEditingNavigationBar()
    }
    
}
