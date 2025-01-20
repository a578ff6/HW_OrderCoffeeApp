//
//  OrderHistoryNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//


// MARK: - OrderHistory NavigationBar 按鈕狀態管理的設計決策分析（重要）
/**
 
 ## OrderHistory NavigationBar 按鈕狀態管理的設計決策分析

    - 主要是在設置「編輯按鈕」、「刪除按鈕」的狀態時，讓我思考兩者的管理層級問題，以及依照管理層級來決定兩者的職責該如何去區分。
 
 `1. 背景與問題`
    
 - 在 `OrderHistory` 的導航欄中，有「編輯」與「刪除」按鈕。
 
 - 這兩個按鈕的啟用狀態由於依賴不同的因素，分別通過不同的方式來進行管理。目前的設計如下：
 
    - `刪除按鈕的狀態:`是通過 `OrderHistorySelectionDelegate` 的`didChangeSelectionState(hasSelection: Bool)`通知來決定的。
    - `編輯按鈕的狀態:`則是在訂單數據（`orders`）變化時進行設置。

 -----
 
`2. 目前的設計分析`

 `A.刪除按鈕的狀態`
 
 - `方式：`
 
    - 通過 `didChangeSelectionState(hasSelection: Bool)` ，由 `OrderHistoryHandler` 通知 `OrderHistoryNavigationBarManager`，當選取狀態變更時更新刪除按鈕的啟用狀態。
 
 - `適用情境：`
 
    - `刪除按鈕`的`啟用狀態`依賴於當前表格中是否有選中的行，因此使用 `OrderHistorySelectionDelegate` 來通知是合理的設計。
    - 這是基於用戶行為的動態更新，與 UI 互動密切相關。
 
 - `按鈕狀態依賴性分析：`
 
    - 依賴性：取決於當前是否有選中的行，屬於動態的用戶交互依賴。
    - 管理層級：較低層級，具體的行選取狀態和用戶操作。
    - 管理方式：由 `OrderHistoryHandler` 通過 `OrderHistorySelectionDelegate` 通知 `OrderHistoryNavigationBarManager` 更新狀態。

 ---
 
 `B.編輯按鈕的狀態`
 
 - `方式：`
 
    - 在 `updateNavigationBar(for state: OrderHistoryEditingState)` 中，根據 `orderHistoryEditingHandler?.isOrderListEmpty()` 來設置編輯按鈕的狀態。
    - 當訂單數據（`orders`）變化時自動通過 `didSet` 更新。
 
 
 - `適用情境：`
 
    - `編輯按鈕`的狀態基於是否有可編輯的訂單來決定，是一個較為靜態的狀態。
    - 由於這與訂單數據的存在性直接相關，並不依賴用戶交互，使用 `didSet` 來設置可以確保按鈕狀態始終與訂單數據一致。
 
 - `按鈕狀態依賴性分析：`
 
    - 依賴性：取決於是否存在訂單，即屬於靜態的數據依賴。
    - 管理層級：更高層級，處理的是整體訂單的存在性問題。
    - 管理方式：在 `orders` 更新時自動檢查並設置按鈕狀態，以反映是否可以進入編輯模式。

 -----

 `3. 是否應統一使用 delegate？`

 `A. 職責分離考量：`
 
   - `刪除按鈕`：
 
    - 其狀態管理需要根據用戶行為的動態變化，選取和取消選取行都是用戶交互的一部分，因此使用 `OrderHistorySelectionDelegate` 通知合乎邏輯。
 
   - `編輯按鈕`：
 
    - 其狀態取決於數據是否存在，這是一個靜態的依賴，並不需要由用戶交互來觸發更新。因此，使用 `didSet` 來根據訂單數據的變化設置按鈕狀態是合理的。

 
 `B. 一致性與耦合度平衡：`
 
   - 對所有按鈕狀態統一使用 `delegate` 處理確實可以提高 API 的一致性，但也會增加代碼的耦合度和不必要的複雜性，特別是在處理靜態數據變化時。
   - 現有的設計保留了簡潔性，使得各個按鈕的狀態管理方式更加符合它們各自的責任，減少了不必要的耦合。

 -----

 `4. 總結`
 
 - `刪除按鈕 和 編輯按鈕` 的狀態管理方式應根據其職責進行選擇。
 
 - `刪除按鈕`
    
    - 「`根據用戶選擇的情況進行刪除`」依賴於用戶的動態交互，因此使用 `OrderHistorySelectionDelegate` 是合理的。
 
 - `編輯按鈕`
 
    - 「`是否允許進入編輯模式`」，適合基於訂單是否存在的整體層級進行管理。
    - 基於訂單是否存在來設置，因此使用 `didSet` 根據數據變化設置更加合適。
 
 */


// MARK: - OrderHistoryNavigationBarManager 筆記
/**
 
 ## OrderHistoryNavigationBarManager 筆記

 ---

 `* What`
 
 - `OrderHistoryNavigationBarManager` 是一個專門負責 `OrderHistory` 頁面中導航欄邏輯的管理類別。
 
 - 它的核心職責包括：
 
 1. 配置導航欄的按鈕組合與狀態。
 2. 根據當前頁面模式（一般模式或編輯模式）動態更新按鈕。
 3. 設置導航欄標題及大標題的顯示樣式，確保視覺一致性。

 ---

 `* Why`

 1. 提升模組化與可維護性：
 
    - 把導航欄相關的邏輯從 `ViewController` 中抽離，降低頁面控制器的複雜度，使程式碼更易於維護和理解。

 2. 狀態驅動按鈕切換：
 
    - 導航欄按鈕需要根據頁面的狀態進行切換（如一般模式與編輯模式），確保用戶交互的直覺性。

 ---

` * How`

 1. 導航標題設置：
 
    - 使用 `configureNavigationBarTitle(title:)` 方法設置導航標題及其顯示樣式（支援大標題模式）。

 2. 按鈕狀態更新：
 
    - 提供 `updateNavigationBar(for:)` 方法，根據當前模式（`normal` 或 `editing`）動態更新按鈕組合。
 
      - 一般模式： 顯示「排序」和「編輯」按鈕，若訂單列表為空，禁用「編輯」按鈕。
      - 編輯模式： 顯示「完成」和「刪除」按鈕，並根據是否有選中行啟用/禁用「刪除」按鈕。

 3. 按鈕生成與更新邏輯：
 
    - 內部使用 `createBarButton` 方法生成導航欄按鈕，確保按鈕的圖標和操作統一。
    - 使用 `updateNavigationBarButtons` 方法更新導航欄按鈕組合，支援不同模式的按鈕切換。

 4. 依賴協作：
 
    - 與 `OrderHistoryEditingHandler` 協作，檢查列表是否為空或是否有選中行，並根據狀態執行相應邏輯。
    - 與 `OrderHistorySortMenuHandler` 協作，生成排序選單按鈕。

 5. 行為驅動（Button Actions）：
 
    - `editButtonTapped`：切換頁面模式，更新按鈕。
    - `deleteButtonTapped`：刪除選中行並更新按鈕狀態。

 ---

` * 典型使用場景`

 - 一般模式（Normal）：
 
   - 用戶進入頁面時，導航欄顯示「排序」與「編輯」按鈕。
   - 若訂單列表為空，「編輯」按鈕自動禁用，避免無效操作。

 - 編輯模式（Editing）：
   - 用戶進入編輯模式時，導航欄切換為「完成」與「刪除」按鈕。
   - 當沒有選中任何行時，「刪除」按鈕自動禁用。

 ---

 `* 實現設計特色`

 1. 狀態驅動設計：
 
    - 使用 `OrderHistoryEditingState` 作為導航欄狀態的核心驅動，透過 `switch` 動態決定按鈕配置。

 2. 清晰的責任分離：
 
    - 將導航欄按鈕邏輯與其他功能（如排序、編輯）分開，確保單一責任。
 
 */



// MARK: - (v)

import UIKit


/// 負責 `OrderHistory` 頁面中導航欄的按鈕配置與狀態更新
///
/// ### 職責範圍
/// - 負責導航欄按鈕的配置與更新，確保根據當前編輯模式的狀態動態切換按鈕。
/// - 設置導航欄標題以及大標題的顯示模式，提供一致性的視覺效果。
///
/// ### 為何需要
/// - 提升代碼的模組化與可維護性：將導航欄的按鈕邏輯集中於此，減少 `ViewController` 的複雜度。
/// - 狀態驅動的按鈕切換：根據編輯模式的不同，動態更新按鈕狀態，例如啟用或禁用「刪除」按鈕。
///
/// ### 功能概述
/// - 導航標題設置
///   - 提供 `configureNavigationBarTitle(title:)` 方法設置導航欄標題及其顯示樣式（大標題模式）。
///
/// - 按鈕狀態更新
///   - 提供 `updateNavigationBar(for:)` 方法根據當前的編輯模式更新導航欄上的按鈕。
///   - 在一般模式（`normal`）與編輯模式（`editing`）下切換按鈕組合，並動態決定按鈕的啟用狀態。
///
/// - 內部按鈕生成邏輯
///   - 動態生成排序按鈕（`Sort`）與編輯按鈕（`Edit`），確保按鈕行為與 UI 要求相符。
///   - 通過 `createBarButton` 方法，快速生成具備圖標和動作的按鈕。
///
/// ### 典型使用場景
/// - 一般模式（Normal）
///   - 預設顯示「排序」按鈕與「編輯」按鈕，當訂單列表為空時，禁用「編輯」按鈕。
///
/// - 編輯模式（Editing）
///   - 切換為「完成」按鈕與「刪除」按鈕，並根據是否有選中行來動態決定「刪除」按鈕的啟用狀態。
///
/// ### 設計細節
/// - 依賴關係
///   - 與 `OrderHistoryEditingHandler` 協作，負責檢查是否有選中行並觸發刪除邏輯。
///   - 與 `OrderHistorySortMenuHandler` 協作，生成排序選單的按鈕。
///
/// - 狀態驅動
///   - 使用 `OrderHistoryEditingState` 表示當前導航欄的狀態，通過 `switch` 動態更新按鈕組合。
class OrderHistoryNavigationBarManager {
    
    // MARK: - Properties
    
    /// `UINavigationItem` 用於設置導航欄的按鈕和標題
    private weak var navigationItem: UINavigationItem?
    
    /// `UINavigationController` 用於配置導航欄的大標題顯示模式
    private weak var navigationController: UINavigationController?
    
    /// `OrderHistoryEditingHandler` 負責管理編輯模式的處理器
    private weak var orderHistoryEditingHandler: OrderHistoryEditingHandler?
    
    /// `OrderHistorySortMenuHandler` 負責排序選單的處理器
    private weak var orderHistorySortMenuHandler: OrderHistorySortMenuHandler?
    
    
    // MARK: - Initialization
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - navigationItem: 用於管理導航欄按鈕與標題的 `UINavigationItem`
    ///   - navigationController: 用於設置大標題樣式的 `UINavigationController`
    ///   - orderHistoryEditingHandler: 處理編輯模式的邏輯處理器
    ///   - orderHistorySortMenuHandler: 用於生成排序選單的處理器
    init(
        navigationItem: UINavigationItem,
        navigationController: UINavigationController?,
        orderHistoryEditingHandler: OrderHistoryEditingHandler,
        orderHistorySortMenuHandler: OrderHistorySortMenuHandler
    ) {
        self.navigationItem = navigationItem
        self.navigationController = navigationController
        self.orderHistoryEditingHandler = orderHistoryEditingHandler
        self.orderHistorySortMenuHandler = orderHistorySortMenuHandler
    }
    
    // MARK: - Setup NavigationBar
    
    /// 設置導航欄的標題及大標題顯示模式
    ///
    /// - Parameter title: 要顯示的導航標題
    func configureNavigationBarTitle(title: String) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    /// 根據當前編輯狀態更新導航欄的按鈕
    ///
    /// - Parameter state: 當前的編輯模式狀態
    func updateNavigationBar(for state: OrderHistoryEditingState) {
        print("[OrderHistoryNavigationBarManager]: Updating navigation bar to state: \(state)")
        switch state {
        case .normal:
            print("[OrderHistoryNavigationBarManager]: Setting normal buttons")
            let sortButton = createSortButton()
            let editButton = createBarButton(imageName: "pencil.and.list.clipboard", style: .plain, action: #selector(editButtonTapped))
            editButton.isEnabled = !(orderHistoryEditingHandler?.isOrderListEmpty() ?? true)
            updateNavigationBarButtons([sortButton, editButton])
            
        case .editing(let hasSelection):
            print("[OrderHistoryNavigationBarManager]: Setting editing buttons, hasSelection: \(hasSelection)")
            let doneButton = createBarButton(imageName: "rectangle.portrait.and.arrow.right", style: .done, action: #selector(editButtonTapped))
            let deleteButton = createBarButton(imageName: "trash", style: .plain, action: #selector(deleteButtonTapped))
            deleteButton.isEnabled = hasSelection
            updateNavigationBarButtons([doneButton, deleteButton])
        }
    }
    
    // MARK: - Button Actions
    
    /// 切換編輯模式
    ///
    /// - 根據當前是否處於編輯模式，切換導航欄上的按鈕
    @objc private func editButtonTapped() {
        let newState = orderHistoryEditingHandler?.toggleEditingMode() ?? .normal
        updateNavigationBar(for: newState)
    }
    
    /// 刪除選中項目
    ///
    /// - 調用 `orderHistoryEditingHandler` 來刪除選中的行
    @objc private func deleteButtonTapped() {
        orderHistoryEditingHandler?.deleteSelectedRows()
        updateNavigationBar(for: .editing(hasSelection: false)) // 刪除後更新按鈕狀態
    }
    
    // MARK: - Private Methods
    
    /// 創建導航欄按鈕
    private func createBarButton(imageName: String, style: UIBarButtonItem.Style, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: style,
            target: self,
            action: action
        )
    }
    
    /// 創建排序按鈕
    private func createSortButton() -> UIBarButtonItem {
        guard let sortMenuHandler = orderHistorySortMenuHandler else { return UIBarButtonItem() }
        return UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            primaryAction: nil,
            menu: sortMenuHandler.createSortMenu()
        )
    }
    
    /// 更新導航欄上的按鈕
    ///
    /// - Parameter buttons: 要顯示在導航欄右側的按鈕陣列
    private func updateNavigationBarButtons(_ buttons: [UIBarButtonItem]) {
        navigationItem?.rightBarButtonItems = buttons
    }
    
}
