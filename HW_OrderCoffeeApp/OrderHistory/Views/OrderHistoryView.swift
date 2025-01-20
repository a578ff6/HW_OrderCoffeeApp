//
//  OrderHistoryView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/6.
//


// MARK: - 關於「可以不要用 translatesAutoresizingMaskIntoConstraints = false」的重點筆記（額外補充）
/**
 
 ## 關於「可以不要用 translatesAutoresizingMaskIntoConstraints = false」的重點筆記
 
 `* 情境描述：`
 
    - 當想要在 `UITableView` 的背景中顯示一個簡單的訊息（例如「無訂單項目」）時，可以使用 UILabel 作為背景視圖。
 
 `* 不設置 translatesAutoresizingMaskIntoConstraints 的原因：`
 
    - 在這個情境下，不設置 `translatesAutoresizingMaskIntoConstraints = false` 代表 UIKit 會自動使用 `AutoresizingMask` 來管理這個 UILabel 的佈局。這使得 UILabel 能自動居中於背景中，符合預期的需求。
 
 `* 適用的情境：`
 
    - 當不需要自訂的佈局約束、且只需簡單顯示訊息時，保持 `translatesAutoresizingMaskIntoConstraints` 為 true 可以簡化佈局程式碼並達到自動置中的效果。
 
 `* 重點：`
 
    - 若想讓 UILabel 的位置和大小由自動調整的遮罩決定並置於 UITableView 背景中，則可以保持默認行為（不設置 translatesAutoresizingMaskIntoConstraints）。
    - 但是，若有自定義佈局需求（如特定位置、距離等），則需要將 translatesAutoresizingMaskIntoConstraints 設為 false 並手動添加約束。
 */


// MARK: - OrderHistoryView 顯示「無訂單項目」的設計筆記
/**
 
 ### OrderHistoryView 顯示「無訂單項目」的設計筆記

 - 當顯示歷史訂單列表時，如果沒有任何訂單，會提供一個提示用戶「無訂單項目」的狀態訊息。
 - 原本是直接使用`UILabel`處理提示訊息，而非`UIView`，後來發現靈活性不好。
 
 ---------

 `* What`
 
 - `OrderHistoryView` 透過 `OrderHistoryEmptyStateView` 處理「無訂單項目」的提示訊息，並將其設置為 `UITableView` 的 `backgroundView`，達到簡單、高效且具擴展性的空狀態顯示效果。

 - 功能特色：
 
   1. 將空狀態提示視圖獨立為 `OrderHistoryEmptyStateView`，提升程式碼的模組化。
   2. 利用 `UITableView.backgroundView` 自動處理佈局和過渡效果，確保提示訊息始終居中。
   3. 符合 iOS 設計模式，簡化主視圖的邏輯負擔。

 ---------

 `* Why`
 
 1. 提高可讀性與可維護性：
 
    - 將空狀態提示邏輯獨立到 `OrderHistoryEmptyStateView`，讓 `OrderHistoryView` 專注於主介面的佈局與控制。
    - 結構更清晰，視圖功能更聚焦。

 2. 提升靈活性：
 
    - 使用 `OrderHistoryEmptyStateView`，可以輕鬆擴展空狀態的顯示內容（例如新增圖示或按鈕）。
    - 提供統一的空狀態設計，避免未來需要處理多種空狀態視圖時重複撰寫程式碼。

 3. 避免潛在問題：
 
    - 過去的 `UILabel` 設計需要手動配置約束，容易出現佈局錯誤或過渡不流暢的情況。
    - 透過 `backgroundView` 自動處理過渡，解決了過去的跳動問題。

 ---------

 * 設計選擇的優勢：
 
 1. 減少視圖層級：
 
    - 不需要額外在父視圖中加入子視圖，直接使用 `backgroundView`。
    - 系統自帶的 `backgroundView` 處理可以減少冗餘邏輯和潛在錯誤。

 2. 更一致的過渡效果：
 
    - 系統自動處理 `UITableView` 的內容變化與空狀態的切換，過渡動畫更平滑一致。

 ---------

 `* How`
 
 1. 定義空狀態視圖
 
    - 建立 `OrderHistoryEmptyStateView` 類別，專注於顯示提示訊息並自動居中：
 
    ```swift
    private let emptyStateView = OrderHistoryEmptyStateView(message: "No Order History")
    ```

 ---

 2. 將空狀態視圖設為背景
 
    - 當列表為空時，將 `emptyStateView` 設置為 `UITableView.backgroundView`：
 
    ```swift
    func updateEmptyState(isEmpty: Bool) {
        orderHistoryTableView.backgroundView = isEmpty ? emptyStateView : nil
    }
    ```
 ---

 3. 保持擴展性
 
    - 未來如果需要擴展空狀態（例如新增按鈕或圖示），可以在 `OrderHistoryEmptyStateView` 中輕鬆修改，不影響現有程式碼。

 ---------

 `* 設計總結`
 
 1. 重構後的優勢：
 
    - 提高程式碼的模組化和靈活性。
    - 符合單一職責原則，讓每個元件專注於自己的任務。
    - 利用系統屬性減少視圖層級和佈局複雜度。

 2. 改進方向：
 
    - 如果未來需要處理多種空狀態（如「網路錯誤」、「無搜尋結果」等），可以進一步抽象出通用的 `EmptyStateView`，讓設計更加一致和高效。
*/


// MARK: - UITableView 與 UICollectionView 空狀態處理的重點筆記（重要）
/**
 ## UITableView 與 UICollectionView 空狀態處理的重點筆記

 - 主要是先前在 「`我的最愛UICollectionView`」是採用獨立的視圖來處理「空狀態」，就想說「UITableView」也是相同處理方式，結果就產生視圖佈局跟畫面過度的錯亂問題。
 
 
 `* 概述：`
 
    - 在 UI 開發中，當 UITableView 或 UICollectionView 沒有內容時，通常會顯示「無項目」的提示訊息。
    - `UITableView` 和 `UICollectionView` 在處理空狀態的顯示方式上有所不同，這與它們各自的設計特點和靈活性有關。
 
 ------
 
` 1. UITableView 的空狀態處理`

 `* backgroundView 屬性：`
 
    - UITableView 提供了一個 backgroundView 屬性，專門用於處理當表格內容為空的情況。
    - 當 tableView 中沒有任何 cell 需要顯示時，可以將自定義的 `UIView`設置為 `backgroundView`，此視圖會自動顯示在表格中央。
    - 使用 backgroundView 不僅減少額外的佈局處理，而且能確保提示信息在表格為空時自動顯示。
 
 ------

 `2. UICollectionView 的空狀態處理`

 `* 沒有 backgroundView 屬性：`
 
    - 與 UITableView 不同，UICollectionView 並不直接提供一個 backgroundView 屬性來顯示空狀態。
    - 當 `collectionView` 沒有任何 cell 時，通常需要自行設置一個「空狀態」的提示視圖 (`emptyStateView`)，並手動管理其顯示和隱藏。

 `* 常見處理方式：`
 
    - 可以在 UICollectionView 的父視圖中添加一個「空狀態」提示視圖，並根據 collectionView 的數據源來顯示或隱藏它。
    - 這種方法需要手動控制提示視圖和 collectionView 的顯示與隱藏狀態。
 
 ------

 `3. 為什麼設計不同？`

 `* 用戶界面模式差異：`
 
    - `UITableView` 通常是一個垂直滾動的單列表格，當內容為空時顯示提示信息非常常見。因此，Apple 提供了 backgroundView 來簡化空狀態的處理。
    - `UICollectionView` 則更加靈活，可以支持多種佈局（如網格、水平滾動等）。這種靈活性使得開發者在處理空狀態時有更多的自定義需求，因此沒有提供一個預設的 backgroundView 屬性。

 `* 靈活性與自定義需求：`
 
    - `UICollectionView` 的設計更強調靈活性，開發者可以根據需求來設計空狀態的顯示方式，例如特定的動畫效果或自定義佈局。
    - `UITableView` 則相對簡單，適合使用一個固定的空狀態提示視圖來滿足大多數應用場景。

 ------

 `4. 總結`
 
    - 對於 UITableView，可以使用 backgroundView 來方便地顯示空狀態，並且系統自動處理視覺效果。
    - 對於 UICollectionView，開發者需要自行創建和管理「空狀態視圖」，這雖然增加了一些額外工作，但也提供了更高的自由度來設計出符合應用需求的視覺效果。
 */


// MARK: - OrderHistoryView 筆記
/**
 
 ## OrderHistoryView 筆記

 
 `* What`
 
 - `OrderHistoryView` 是一個專門用於顯示歷史訂單的自訂視圖，結合了訂單列表顯示與空狀態提示功能。

 - 功能特色：
 
   1. 提供一個 `UITableView` 用於顯示歷史訂單內容。
   2. 當訂單列表為空時，顯示一個空狀態視圖 (`OrderHistoryEmptyStateView`) 作為背景提示。
   3. 使用簡單的布局設計，確保表格和提示訊息能正確顯示。

 - 使用場景：
 
   當應用需要顯示歷史訂單時，可以使用該視圖進行顯示。如果訂單列表為空，用戶能清楚地看到提示訊息，避免界面看起來像是錯誤或未加載完成。

 ----------

 `* Why`

 1. 分離責任：
 
    - 將訂單顯示的主視圖與其他邏輯（如控制器的數據處理）分離，讓 `OrderHistoryView` 專注於視圖佈局和顯示邏輯，符合單一職責原則。

 2. 改善用戶體驗：
 
    - 當訂單列表為空時，顯示空狀態提示視圖，提供清楚的用戶指引，避免空白頁面帶來的混淆。

 3. 提高模組化與可維護性：
 
    - 通過將空狀態提示封裝到 `OrderHistoryEmptyStateView` 中，方便未來擴展其他空狀態提示功能，例如新增圖片或按鈕。

 --------
 
 `* 為什麼選擇 UITableView.backgroundView？`
 
 1. 簡化佈局：
 
    - 使用 `backgroundView` 自動處理佈局邏輯，系統會自動將背景視圖置於正確的位置，減少開發者手動處理約束的負擔。

 2. 一致的動畫過渡：
 
    - 系統會自動處理表格內容變化和背景視圖的過渡效果，提供一致且流暢的用戶體驗。

 3. 符合 UIKit 設計原則：
 
    - `UITableView.backgroundView` 是為了解決內容為空時的提示問題而設計，使用該屬性能保持程式碼的語意清晰和結構簡單。

 ----------

 *` How`

 1. 定義訂單表格與空狀態視圖
 
    - 初始化 `OrderHistoryTableView` 作為主表格。
    - 定義 `OrderHistoryEmptyStateView` 作為空狀態提示視圖。
 
    ```swift
    private(set) var orderHistoryTableView = OrderHistoryTableView(frame: .zero, style: .plain)
    private let orderHistoryEmptyStateView = OrderHistoryEmptyStateView(message: "No Order History")
    ```

 -----
 
 2. 設置表格佈局
 
    - 通過 Auto Layout 將 `orderHistoryTableView` 填滿整個 `OrderHistoryView`：
 
    ```swift
    private func setupLayout() {
        addSubview(orderHistoryTableView)
        NSLayoutConstraint.activate([
            orderHistoryTableView.topAnchor.constraint(equalTo: topAnchor),
            orderHistoryTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            orderHistoryTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            orderHistoryTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    ```

 -----

 3. 更新空狀態邏輯
 
    - 根據訂單列表是否為空，動態設置 `backgroundView` 顯示空狀態視圖或清除背景：
 
    ```swift
    func updateEmptyState(isEmpty: Bool) {
        orderHistoryTableView.backgroundView = isEmpty ? orderHistoryEmptyStateView : nil
    }
    ```

 -----

 4. 擴展性
 
    - 如果未來需要加入更多提示內容（如圖片或按鈕），可以在 `OrderHistoryEmptyStateView` 中進行擴展，而無需修改主視圖邏輯。

 ----------

 `* 設計總結`

 1. 優勢：
 
    - 符合單一職責原則，將顯示邏輯與數據邏輯分離。
    - 使用 `backgroundView` 減少視圖層級和佈局複雜性。
    - 高模組化設計，方便擴展空狀態的顯示功能。

 2. 適用場景：
 
    - 需要顯示動態列表內容（如歷史訂單）的情境。
    - 當列表為空時，需要提示用戶當前狀態，避免不必要的混淆。

 3. 改進方向：
 
    - 若未來需要處理多種空狀態（如「無搜尋結果」、「網路錯誤」等），可以考慮建立通用的空狀態視圖模組，進一步提高設計一致性與重用性。

 */



// MARK: - (v)

import UIKit

/// `OrderHistoryView`
///
/// 用於顯示歷史訂單列表的自訂視圖，包含：
///
/// - 一個 `UITableView` 用於展示歷史訂單的內容。
/// - 一個空狀態視圖 (`OrderHistoryEmptyStateView`)，當訂單列表為空時顯示提示訊息。
///
/// - 功能特色：
///   1. 提供整體佈局，確保 `UITableView` 填滿視圖。
///   2. 使用空狀態視圖作為 `UITableView` 的 `backgroundView`，提供簡潔流暢的提示訊息顯示。
///   3. 符合 iOS 設計原則，簡化視圖管理與佈局處理。
///
/// - 使用場景：
///   該視圖通常用於歷史訂單頁面，當訂單列表為空時提示用戶，當有內容時顯示完整的訂單列表。
class OrderHistoryView: UIView {
    
    // MARK: - UI Elements
    
    /// 用於顯示歷史訂單的 `UITableView`
    ///
    /// - 功能：
    ///   1. 動態顯示歷史訂單的列表內容。
    ///   2. 支援內容為空時顯示空狀態視圖。
    private(set) var orderHistoryTableView = OrderHistoryTableView(frame: .zero, style: .plain)
    
    /// 用於顯示「無訂單項目」的空狀態視圖
    ///
    /// - 當訂單列表為空時，顯示提示訊息，告知用戶目前沒有可顯示的訂單。
    private let orderHistoryEmptyStateView = OrderHistoryEmptyStateView(message: "No Order History")
    
    
    // MARK: - Initializers
    
    /// 初始化 `OrderHistoryView`
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCells()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置表格的佈局
    private func setupLayout() {
        addSubview(orderHistoryTableView)
        
        NSLayoutConstraint.activate([
            orderHistoryTableView.topAnchor.constraint(equalTo: topAnchor),
            orderHistoryTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            orderHistoryTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            orderHistoryTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 註冊表格視圖使用的 Cell 類型
    private func registerCells() {
        orderHistoryTableView.register(OrderHistoryCell.self, forCellReuseIdentifier: OrderHistoryCell.reuseIdentifier)
    }
    
    // MARK: - Empty State Management
    
    /// 更新表格視圖的空狀態
    ///
    /// - 說明：
    ///   根據訂單列表是否為空，切換 `UITableView` 的 `backgroundView` 顯示狀態。
    ///
    /// - Parameters:
    ///   - isEmpty: `true` 表示訂單列表為空，將顯示 `orderHistoryEmptyStateView`；否則隱藏。
    func updateEmptyState(isEmpty: Bool) {
        orderHistoryTableView.backgroundView = isEmpty ? orderHistoryEmptyStateView : nil
    }
    
}
