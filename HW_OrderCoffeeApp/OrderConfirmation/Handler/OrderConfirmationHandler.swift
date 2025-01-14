//
//  OrderConfirmationHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

// MARK: - OrderConfirmationHandler 設計筆記
/**
 ## OrderConfirmationHandler 重點筆記
 
 `* 功能概述`
    - `OrderConfirmationHandler` 主要用於管理訂單確認頁面上各區域的顯示資料來源及顯示邏輯。它實現了 UICollectionViewDataSource 和 UICollectionViewDelegate，負責管理 UICollectionView 內的各個區域和對應的資料。

 ---------
 
 `* 重點`
 
 `1.委託模式 (delegate)：`
 
    - 使用委託模式 (`OrderConfirmationHandlerDelegate`) 來提供訂單資料。
    - 透過委託方法從外部獲取訂單資料，以保持 `OrderConfirmationHandler` 的通用性和靈活性。

 ---------

` 2. Section 部分：`
 
    - checkMark：顯示訂單確認的勾選圖示。
    - message：訂單確認的訊息提示。
    - customerInfo：顯示顧客的基本資料。
    - itemDetails：顯示訂單內各個商品的詳細資料。
    - details：顯示訂單的摘要（例如訂單編號、總金額等）。
    - closeButton：顯示返回按鈕，讓用戶返回主頁面。
 
 ---------

 `3. 區域數據源的管理 (UICollectionViewDataSource)：`
 
    - 根據不同的 Section 來決定每個區域需要顯示的項目數量。
    - 對於商品細節區域 (`itemDetails`)，顯示的項目數量由訂單的商品數量決定。
    - 對其他區域來說，通常只有一個對應的項目。
 
 ---------

 `4. Cell 的配置 (UICollectionViewCell)：`

`* 提供多個私有的配置方法，用來設置不同區域內的 UICollectionViewCell：`
 
    - configureCheckmarkCell()：設置訂單確認成功的勾選圖示。
    - configureMessageCell()：設置訂單確認訊息提示。
    - configureCustomerInfoCell()：配置顧客的基本資料，例如姓名和電話。
    - configureItemDetailsCell()：設置每個商品的詳細信息，包括名稱、數量等。
    - configureOrderDetailsCell()：設置訂單摘要，例如總金額和準備時間。
    - configureCloseButtonCell()：配置關閉按鈕，點擊後執行返回操作。
 
 ---------

` 5. 委託的 Cell 內容配置：`
 
    - 對於顧客資料、訂單商品等，需要透過委託 (`orderConfirmationHandlerDelegate?.getOrder()`) 來獲取最新的訂單資料，再配置對應的 Cell。
    - 這樣的設計能夠使得 `OrderConfirmationHandler` 較為輕量，只需關注視圖配置，具體數據由外部提供。
 
 ---------

` 6. 委託模式處理按鈕事件：`
 
    - 關閉按鈕的點擊事件由委託處理，`configureCloseButtonCell() `中配置 `onCloseButtonTapped`，讓 `OrderConfirmationHandlerDelegate` 的方法負責關閉操作。
 
 ---------

` 7.Header View 點擊展開/收起功能的分離處理`
 
    - 原本與 `HeaderView` 點擊展開/收起有關的部分，如添加手勢識別器 (`addTapGesture`) 和處理點擊事件 (`handleHeaderTap`) 已被分離至 `OrderConfirmationHeaderGestureHandler` 中。
 
 `* Header Gesture Handler 的作用`
 
    - `OrderConfirmationHeaderGestureHandler` 現在負責管理 `HeaderView` 的手勢處理邏輯。它為 `HeaderView` 添加手勢並在點擊時切換對應 Section 的展開狀態。
    - `OrderConfirmationHandler` 則根據 `orderConfirmationSectionExpansionManager` 的狀態來配置每個 HeaderView，如設置展開箭頭的方向。
 
 `* 責任分離的優點`
 
    - 這樣的設計使得 `OrderConfirmationHandler` 不再負責手勢處理，而專注於數據配置和顯示邏輯。
    - `OrderConfirmationHeaderGestureHandler` 負責管理 `HeaderView` 的點擊手勢，這樣能確保責任分離，並使程式碼更具模塊化且易於維護。
 */


// MARK: - 重點筆記：OrderConfirmationHandler 中與 HeaderView 點擊展開/收起有關的部分
/**
 
 ## 重點筆記：OrderConfirmationHandler 中與 HeaderView 點擊展開/收起有關的部分

 `* 目的與設計`
 
    - `OrderConfirmationHandler`  負責訂單確認頁面的各個區域的資料顯示與管理，尤其是管理 UICollectionView 的數據配置。
    - `OrderConfirmationHandler` 與 `HeaderView` 點擊展開/收起的功能相關，因為它負責管理 HeaderView 的顯示邏輯（如箭頭方向）以及需要展示的內容數量。
    - 這些部分涉及手勢處理、狀態管理、以及更新顯示邏輯，確保使用者可以靈活地控制訂單內容的顯示。
  
 `1.分離手勢處理到 OrderConfirmationHeaderGestureHandler`
 
    - 原先的 `OrderConfirmationHandler` 中包含了手勢處理和狀態管理的邏輯，這部分被移到專門的 `OrderConfirmationHeaderGestureHandler` 中，進行更清晰的責任分離。
    - `OrderConfirmationHeaderGestureHandler` 專門負責為 `HeaderView` 添加點擊手勢並處理點擊事件，這樣使得 `OrderConfirmationHandler` 更加專注於數據源和顯示邏輯，減少了其複雜性。
 
`2.orderConfirmationSectionExpansionManager 的作用`
 
    - `orderConfirmationSectionExpansionManager` 是一個 `OrderConfirmationSectionExpansionManager` 類別，用於集中管理頁面上所有 Section 的展開或收起狀態。
    - 它由 `OrderConfirmationHandler` 管理，用於追蹤每個 Section 是否展開，以便決定應顯示多少內容（如 `itemDetails` 區域的商品數量）。

`3.OrderConfirmationHandler 與 HeaderView 展開/收起的關聯性`
 
    - 雖然手勢處理已經被分離出來，但 `OrderConfirmationHandler` 仍然需要根據 `HeaderGestureHandler` 的手勢結果更新顯示。
    - 在 `viewForSupplementaryElementOfKind` 方法中，`OrderConfirmationHandler` 根據當前的展開狀態來配置 HeaderView，例如設定箭頭方向。
    - 當手勢導致某個 Section 展開或收起時，`expansionManager` 會更新狀態，並通過委託通知 `ViewController` 來刷新對應區域的顯示。

 `4.addTapGesture 方法的調整`
 
    - 原本位於 `OrderConfirmationHandler` 中的 `addTapGesture` 方法已經被移至 `OrderConfirmationHeaderGestureHandler` 中進行專門管理。
    - 在 `OrderConfirmationHandler` 中，對 `itemDetails` 區域的 `HeaderView` 添加手勢時，現在會呼叫` headerGestureHandler.addTapGesture(to:headerView, section: indexPath.section)`，這樣使手勢管理更加集中，責任更加清晰。

 -----------

 `* 改進後的設計流程`
 
 `1.初始化流程：`
 
    - 在初始化 `OrderConfirmationHandler` 時，將 `itemDetails` 區域預設設為展開狀態，使用` orderConfirmationSectionExpansionManager.toggleSection(Section.itemDetails.rawValue) `來管理狀態。
    - 初始化 `OrderConfirmationHeaderGestureHandler` 並將其用於管理 `HeaderView` 點擊手勢，確保在顯示 HeaderView 時能添加手勢處理。
 
 `2.手勢處理與顯示邏輯的分離：`
 
    - `OrderConfirmationHeaderGestureHandler` 負責手勢處理，監聽 HeaderView 的點擊事件，並通過 `orderConfirmationSectionExpansionManager` 切換展開/收起狀態。
    - `OrderConfirmationHandler` 則負責根據 `orderConfirmationSectionExpansionManager` 的狀態來配置每個 HeaderView，以便顯示正確的內容。
 
 `3.用戶交互流程：`
 
    - 當用戶點擊某個 `HeaderView` 時，手勢管理器捕獲到該事件，然後通過 `orderConfirmationSectionExpansionManager` 切換狀態。
    - 接著通過 `orderConfirmationHandlerDelegate` 通知 `OrderConfirmationViewController`，從而使對應的區域顯示或隱藏，保證 UI 狀態與內部資料一致。
 
 -----------

 `* 總結`
 
    - 將 HeaderView 點擊手勢的管理分離到 `OrderConfirmationHeaderGestureHandler` 中，提高了責任分離的清晰度，減少了 `OrderConfirmationHandler` 的負擔，使其能專注於數據顯示。
    - `OrderConfirmationHandler` 與 `HeaderView` 展開/收起仍有關聯，因為它負責配置 HeaderView 的顯示邏輯，而手勢處理結果最終需要反映在這些顯示邏輯上。
 */


// MARK: - 重點筆記：OrderConfirmationHeaderGestureHandler 的放置位置
/**
 
 ## 重點筆記：OrderConfirmationHeaderGestureHandler 的放置位置

` * 背景描述`
 
    - `OrderConfirmationHandler` 負責管理訂單確認頁面的資料顯示，特別是 UICollectionView 的數據配置和顯示邏輯。
    - `OrderConfirmationHeaderGestureHandler` 負責處理 Header View 的點擊手勢，對應於 UICollectionView 中各區域的展開/收起操作。
    - 需要考慮 `OrderConfirmationHeaderGestureHandler` 放置於 `OrderConfirmationHandler` 或 `OrderConfirmationViewController` 中的合適性。
 
 -------
 
 `* 決策原因`
 
 `1.責任分離原則`
 
    - `OrderConfirmationHandler` 的主要責任是管理 UICollectionView 的顯示和交互，這包含配置標題、添加手勢等操作。
    - `OrderConfirmationHeaderGestureHandler` 專注於 Header View 點擊手勢的處理，這是 UICollectionView 交互的一部分。
    - 將 `headerGestureHandler` 放在 `OrderConfirmationHandler` 中，有助於保持責任單一，符合責任分離的原則。
 
 `2.降低耦合度`
 
    - 如果將 `headerGestureHandler` 放在 `OrderConfirmationViewController` 中，會增加 ViewController 的複雜度，使其必須處理 UICollectionView 的低層級操作。
    - 這樣會導致 ViewController 的耦合度過高，不利於代碼的擴展和維護。
    - 將手勢處理交由 `OrderConfirmationHandler` 管理，可以讓 ViewController 專注於高層級的操作，如初始化、資料獲取等，從而降低耦合度。
 
 `3.關聯性更強`
 
    - `headerGestureHandler` 的行為完全與 UICollectionView 的 Header View 相關，這些行為應由 `OrderConfirmationHandler` 管理，以保持邏輯的一致性。
    - 將其包含在 `OrderConfirmationHandler` 中更符合這些功能的邏輯歸屬和責任範圍。
 
 -------

 `* 結論`
 
    - 將 `OrderConfirmationHeaderGestureHandler` 放在 `OrderConfirmationHandler` 中，符合責任分離原則，降低了耦合度，讓 `OrderConfirmationHandler` 更好地管理 UICollectionView 的展示和交互。
 */


// MARK: - OrderConfirmationHandler 筆記
/**
 
 ## OrderConfirmationHandler 筆記

 `* What`
 
 - `OrderConfirmationHandler` 是一個負責訂單確認頁面中數據源與視圖配置的處理器類別。
 
 它的主要功能包括：
 
 1. 管理 `UICollectionView` 的數據源和委託，確保正確顯示每個區域（如訂單項目、顧客資訊等）。
 2. 管理區域展開與收起的狀態邏輯，透過 `OrderConfirmationSectionExpansionManager` 集中處理。
 3. 添加手勢處理，支援用戶點擊區域標題進行展開/收起操作。
 4. 通知外部類別（如 `OrderConfirmationViewController`）更新對應的區域視圖。

 -----------

 `* Why`
 
 1. 單一職責原則 (SRP)：
 
    - 將數據處理與視圖配置邏輯封裝到 `OrderConfirmationHandler` 中，減少控制器的複雜度。
    - 專注處理與 `UICollectionView` 相關的操作，避免其他模組介入展開/收起的邏輯。

 2. 降低耦合性：
 
    - 透過代理模式（`OrderConfirmationHandlerDelegate` 和 `OrderConfirmationSectionDelegate`）與外部溝通，確保與控制器的低耦合性。
    - 使用 `OrderConfirmationSectionExpansionManager` 將展開/收起的狀態邏輯與業務層分離。

 3. 可讀性與擴展性：
 
    - 定義 `Section` 枚舉以清晰區分各區域，便於新增功能或修改邏輯。
    - 使用 `OrderConfirmationHeaderGestureHandler` 處理手勢相關邏輯，提升代碼的可讀性與模組化。

 4. 提升用戶體驗：
 
    - 支援點擊展開/收起區域，提供更清晰的數據展示層次。

 -----------

` * How`
 
 1. 數據與視圖管理：
 
    - `OrderConfirmationHandler` 設置為 `UICollectionView` 的數據源與委託，負責處理區域和項目的顯示。
    - 使用 `numberOfSections` 和 `numberOfItemsInSection` 方法，定義每個區域和區域內項目的數量。
    - 配置每個區域的標題（Header）和內容（Cell），根據展開狀態更新視圖。

 2. 展開/收起邏輯：
 
    - 使用 `OrderConfirmationSectionExpansionManager` 集中管理展開狀態，避免分散到數據源或手勢處理中。
    - 支援用戶點擊 Header 切換展開狀態，並透過代理通知外部更新對應的區域。

 3. 手勢處理：
 
    - `OrderConfirmationHeaderGestureHandler` 為每個 Header 添加點擊手勢，專注於手勢相關邏輯，減少主類別負擔。
    - 當點擊 Header 時，切換展開狀態並通知外部進行 UI 更新。

 4. 視圖更新：
 
    - 外部控制器（如 `OrderConfirmationViewController`）實現 `OrderConfirmationSectionDelegate`，負責在區域狀態變更時更新 UI（例如重新加載特定區域）。

 5. 區域定義與邏輯：
 
    - 使用 `Section` 枚舉明確定義頁面的每個區域，將其分為勾選圖示區域、訊息區域、訂單明細等，提升代碼結構的可讀性和可維護性。

 -----------

 `* 總結`
 
 `OrderConfirmationHandler` 將數據與視圖管理邏輯集中處理，與其他模組（如手勢處理、展開狀態管理）合作，達成清晰的責任分工與低耦合設計：
 
 - 責任分明： 專注於數據源與視圖配置，減少控制器的負擔。
 - 模組化設計： 展開/收起狀態邏輯與手勢處理獨立抽離，易於擴展。
 - 高效與易維護：通過代理與狀態管理器解耦業務邏輯，確保代碼的可讀性與靈活性。
 */


// MARK: - OrderConfirmationViewController`、`OrderConfirmationHandler`、`OrderConfirmationHeaderGestureHandler` 和 `OrderConfirmationSectionExpansionManager` 的層級結構和關係
/**
 
 ## OrderConfirmationViewController`、`OrderConfirmationHandler`、`OrderConfirmationHeaderGestureHandler` 和 `OrderConfirmationSectionExpansionManager` 的層級結構和關係
 
```
# 職責層級關係圖
 
OrderConfirmationViewController
├── OrderConfirmationHandler
│   ├── UICollectionViewDataSource (展示邏輯)
│   ├── OrderConfirmationHeaderGestureHandler (手勢處理)
│   │   ├── 管理 Header 點擊手勢
│   │   └── 通知 OrderConfirmationSectionExpansionManager 切換展開/收起狀態
│   ├── OrderConfirmationSectionExpansionManager (展開狀態管理)
│   │   ├── 管理 Section 展開/收起狀態
│   │   └── 提供狀態查詢和切換接口
│   └── 通過代理與 ViewController 交互
│       ├── OrderConfirmationHandlerDelegate (數據交互)
│       └── OrderConfirmationSectionDelegate (UI 更新)
├── OrderConfirmationView (UI 元素)
└── OrderConfirmationManager (數據加載)
 
```
 
 `* 輸出說明`
 
 `1.OrderConfirmationViewController：`
 
 - 作為主控制器，負責協調數據加載、初始化 `OrderConfirmationHandler`，並通過代理與其他模組交互。
 
` 2.OrderConfirmationHandler：`
 
 - 專注於 `UICollectionView` 的數據源和展示邏輯，管理內部狀態和交互邏輯。
 
   - `OrderConfirmationHeaderGestureHandler`：專注於手勢處理，解耦手勢邏輯並與狀態管理器和控制器互動。
   - `OrderConfirmationSectionExpansionManager`：集中管理展開/收起狀態，保持狀態與展示邏輯分離。
 
 ----
 
 `* 代理模式`
 
 1.`OrderConfirmationHandlerDelegate`：
 
 - 從控制器獲取數據，觸發用戶交互回調。
 
 2.`OrderConfirmationSectionDelegate`：
 
 - 通知控制器進行 UI 更新。
*/


// MARK: - OrderConfirmationHandler 的職責層級設計
/**
 
 ## OrderConfirmationHandler 的職責層級設計

` * What`
 
 - `OrderConfirmationHandler` 是訂單確認頁面數據邏輯的核心管理器，負責 `UICollectionView` 的展示邏輯和數據源管理，並通過 `OrderConfirmationHeaderGestureHandler` 和 `OrderConfirmationSectionExpansionManager` 協調手勢與展開狀態。

 - 核心組件：
 
 1. `OrderConfirmationHeaderGestureHandler`：
    
 - 管理 `Section Header` 的點擊手勢，確保手勢處理邏輯模組化。
 
 2. `OrderConfirmationSectionExpansionManager`：
 
 - 集中管理 `Section` 的展開/收起狀態，避免狀態邏輯分散。
 
 3. 代理模式：
 
 - `OrderConfirmationHandlerDelegate`：獲取訂單數據和處理用戶交互（如關閉按鈕）。
 - `OrderConfirmationSectionDelegate`：通知外部類別（如 ViewController）更新 UI。

 ---------------

 `* Why`
 
 1. 單一職責原則（SRP）：
 
 - 將手勢處理、展開狀態管理和數據展示拆分到不同的模組中，保持每個模組的單一責任。
 - 控制器專注於數據協調和 UI 驅動，避免過度膨脹。
 
 2. 低耦合性：
 
 - 使用代理與外部溝通，`OrderConfirmationHandler` 不直接依賴控制器，增加模組的可重用性和測試性。
 
 3. 可擴展性：
 
 - 模組劃分明確，如需新增功能（如更多展開邏輯或自定義手勢），只需擴展相關模組，而無需改動整體結構。

 ---------------

 `* How`
 
 1. `OrderConfirmationHandler` 初始化：
   
 - 接收 `OrderConfirmationHandlerDelegate` 和 `OrderConfirmationSectionDelegate` 以實現數據交互與 UI 通知。
 - 初始化 `OrderConfirmationHeaderGestureHandler` 和 `OrderConfirmationSectionExpansionManager`，負責協調手勢與狀態。

 ---

 2. 關鍵模組職責分配：
   
 - `OrderConfirmationHeaderGestureHandler`：
      - 綁定 `Section Header` 點擊手勢。
      - 通知 `OrderConfirmationSectionExpansionManager` 切換展開狀態，並使用代理通知控制器更新 UI。
 
    - `OrderConfirmationSectionExpansionManager`：
      - 提供 `isSectionExpanded` 與 `toggleSection` 方法集中管理狀態，避免邏輯分散。
 
    - 代理模式：
      - `OrderConfirmationHandlerDelegate` 提供訂單數據並處理按鈕交互。
      - `OrderConfirmationSectionDelegate` 負責刷新對應區域的 UI。

 ---

 3. 實現範例：
 
    - 綁定手勢：
 
      ```swift
      orderConfirmationHeaderGestureHandler?.addTapGesture(to: headerView, section: indexPath.section)
      ```
 
    - 切換展開狀態：
 
      ```swift
      orderConfirmationSectionExpansionManager.toggleSection(section)
      orderConfirmationSectionDelegate?.didToggleSection(section)
      ```
 
    - 通知控制器：
 
      ```swift
      func didToggleSection(_ section: Int) {
          orderConfirmationView.orderConfirmationCollectionView.reloadSections(IndexSet(integer: section))
      }
      ```
 */



// MARK: - (v)

import UIKit

/// `OrderConfirmationHandler`
///
/// 負責管理訂單確認頁面的資料顯示，包括配置和更新 `UICollectionView` 的內容。
///
/// - 設計目標:
///   1. 單一職責原則 (SRP):
///      - 此類專注於處理訂單確認頁面的數據源邏輯和 `UICollectionView` 的展示配置。
///   2. 與外部解耦:
///      - 使用代理模式 (`OrderConfirmationHandlerDelegate` 和 `OrderConfirmationSectionDelegate`) 與外部交互，確保與控制器的低耦合性。
///   3. 易於擴展:
///      - 提供明確的區域管理 (`Section`) 和展開狀態處理 (`OrderConfirmationSectionExpansionManager`)，便於後續新增功能或修改。
///
/// - 功能概述:
///   - 負責設定 `UICollectionView` 的數據源和委託。
///   - 通過 `OrderConfirmationSectionExpansionManager` 管理區域的展開與收起邏輯。
///   - 通知外部類別進行區域視圖的更新。
///
/// - 使用情境:
///   1. 當用戶進入訂單確認頁面時，展示訂單的各個區域（如訂單項目明細、顧客資訊等）。
///   2. 用戶點擊區域 Header 時，切換展開或收起狀態並更新對應的內容展示。
///   3. 使用自定義的 `OrderConfirmationHeaderGestureHandler` 添加手勢處理，提升可讀性與模組化。
class OrderConfirmationHandler: NSObject {

    // MARK: - Properties

    /// 提供訂單詳細資料的代理
    ///
    /// - 用途: 用於獲取顧客資料、訂單項目等詳細資訊。
    weak var orderConfirmationHandlerDelegate: OrderConfirmationHandlerDelegate?
    
    /// 用於管理區域展開狀態的管理器
    ///
    /// - 用途: 集中管理各 `Section` 的展開/收起狀態，避免將狀態邏輯分散到數據源和手勢處理中。
    private let orderConfirmationSectionExpansionManager = OrderConfirmationSectionExpansionManager()
    
    /// Header 手勢處理器
    ///
    /// - 用途: 負責添加手勢處理並通知外部更新視圖。
    private var orderConfirmationHeaderGestureHandler: OrderConfirmationHeaderGestureHandler?

    // MARK: - Initialization

    /// 初始化方法
    ///
    /// - Parameters:
    ///   - orderConfirmationHandlerDelegate: 提供訂單資料的代理。
    ///   - orderConfirmationSectionDelegate: 負責更新 UI 的外部代理。
    init(
        orderConfirmationHandlerDelegate: OrderConfirmationHandlerDelegate?,
        orderConfirmationSectionDelegate: OrderConfirmationSectionDelegate?
    ) {
        super.init()
        
        self.orderConfirmationHandlerDelegate = orderConfirmationHandlerDelegate
        
        // 初始化手勢處理器，並傳入展開狀態管理器和外部代理
        self.orderConfirmationHeaderGestureHandler = OrderConfirmationHeaderGestureHandler(
            orderConfirmationSectionExpansionManager: orderConfirmationSectionExpansionManager,
            orderConfirmationSectionDelegate: orderConfirmationSectionDelegate
        )
        
        // 預設展開 "Item Details" 區域
        orderConfirmationSectionExpansionManager.toggleSection(Section.itemDetails.rawValue)
    }
    
    
    // MARK: - Section
    
    /// 定義訂單確認頁面的區域
    ///
    /// - 功能: 分別代表訂單確認頁面的各部分，用於區分數據展示內容。
    enum Section: Int, CaseIterable {
        case checkMark       // 勾選圖示區域，表示訂單確認成功。
        case message         // 訂單確認的訊息提示區域。
        case itemDetails     // 訂單內商品的詳細資料區域。
        case customerInfo    // 顧客基本資料（例如姓名、電話）的區域。
        case details         // 訂單摘要（例如訂單編號、總金額等）的區域。
        case closeButton     // 關閉按鈕，讓用戶返回上一頁面。
    }
    
}

// MARK: - UICollectionViewDataSource
extension OrderConfirmationHandler: UICollectionViewDataSource {
    
    // MARK: - CollectionView DataSource Methods
    
    /// 設定顯示的區域數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    /// 設定每個區域中顯示的項目數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .itemDetails:
            /// 返回展開狀態下的`訂單飲品項目數量`
            return orderConfirmationSectionExpansionManager.isSectionExpanded(section) ? (orderConfirmationHandlerDelegate?.getOrder()?.orderItems.count ?? 0) : 0
        default:
            return 1
        }
    }
    
    /// 配置區域的標題視圖
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = Section(rawValue: indexPath.section),
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OrderConfirmationSectionHeaderView.headerIdentifier, for: indexPath) as? OrderConfirmationSectionHeaderView else {
            fatalError("Invalid supplementary element configuration")
        }
        
        /// 根據區域類型配置 Header
        switch sectionType {
        case .itemDetails:
            let isExpanded = orderConfirmationSectionExpansionManager.isSectionExpanded(indexPath.section)
            headerView.configure(with: "Item Details", isExpanded: isExpanded, showArrow: true)
            // 添加手勢處理
            orderConfirmationHeaderGestureHandler?.addTapGesture(to: headerView, section: indexPath.section)
            
        case .customerInfo:
            headerView.configure(with: "Customer Information", isExpanded: false, showArrow: false)
        case .details:
            headerView.configure(with: "Order Summary", isExpanded: false, showArrow: false)
        default:
            break
        }
        
        return headerView
    }
    
    // MARK: - Cell Configuration Methods
    
    /// 配置區域的 Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section")
        }
        
        switch sectionType {
        case .checkMark:
            return configureCheckmarkCell(for: collectionView, at: indexPath)
        case .message:
            return configureMessageCell(for: collectionView, at: indexPath)
        case .itemDetails:
            return configureItemDetailsCell(for: collectionView, at: indexPath)
        case .customerInfo:
            return configureCustomerInfoCell(for: collectionView, at: indexPath)
        case .details:
            return configureOrderDetailsCell(for: collectionView, at: indexPath)
        case .closeButton:
            return configureCloseButtonCell(for: collectionView, at: indexPath)
        }
    }
    
    // MARK: - Private Cell Configuration Methods
    
    /// 配置勾選圖示 Cell，表示訂單確認成功
    private func configureCheckmarkCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderConfirmationCheckmarkCell.reuseIdentifier, for: indexPath) as? OrderConfirmationCheckmarkCell else {
            fatalError("Cannot create OrderConfirmationCheckmarkCell")
        }
        return cell
    }
    
    /// 配置訂單訊息提示 Cell
    private func configureMessageCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderConfirmationMessageCell.reuseIdentifier, for: indexPath) as? OrderConfirmationMessageCell else {
            fatalError("Cannot create OrderConfirmationMessageCell")
        }
        return cell
    }
    
    /// 配置訂單項目詳細資料的 Cell
    private func configureItemDetailsCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderrConfirmationItemDetailsCell.reuseIdentifier, for: indexPath) as? OrderrConfirmationItemDetailsCell else {
            fatalError("Cannot create OrderrConfirmationItemDetailsCell")
        }
        
        // 根據 indexPath 配置對應的訂單項目資料
        guard let orderItems = orderConfirmationHandlerDelegate?.getOrder()?.orderItems else {
            print("Warning: Missing order items for section \(indexPath.section)")
            return cell
        }
        let orderItem = orderItems[indexPath.item]
        cell.configure(with: orderItem)
        return cell
    }
    
    /// 配置顧客基本資料的 Cell
    private func configureCustomerInfoCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderConfirmationCustomerInfoCell.reuseIdentifier, for: indexPath) as? OrderConfirmationCustomerInfoCell else {
            fatalError("Cannot create OrderConfirmationCustomerInfoCell")
        }
        
        // 獲取訂單資料並配置 Cell
        guard let customerDetails = orderConfirmationHandlerDelegate?.getOrder()?.customerDetails else {
            print("Warning: Missing customer details for section \(indexPath.section)")
            return cell
        }
        
        cell.configure(with: customerDetails)
        return cell
    }
    
    /// 配置訂單摘要的 Cell（例如訂單編號、總金額等）
    private func configureOrderDetailsCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderrConfirmationDetailsCell.reuseIdentifier, for: indexPath) as? OrderrConfirmationDetailsCell else {
            fatalError("Cannot create OrderrConfirmationDetailsCell")
        }
        
        // 獲取訂單資料並配置 Cell
        guard let order = orderConfirmationHandlerDelegate?.getOrder() else {
            print("Warning: Missing order details for section \(indexPath.section)")
            return cell
        }
        
        cell.configure(with: order)
        return cell
    }
    
    /// 配置關閉按鈕 Cell，讓使用者能夠返回上一頁面
    private func configureCloseButtonCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderrConfirmationCloseButtonCell.reuseIdentifier, for: indexPath) as? OrderrConfirmationCloseButtonCell else {
            fatalError("Cannot create OrderrConfirmationCloseButtonCell")
        }
        
        // 配置 close button 的 action
        cell.onCloseButtonTapped = {
            self.orderConfirmationHandlerDelegate?.didTapCloseButton()
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension OrderConfirmationHandler: UICollectionViewDelegate {
    
}
