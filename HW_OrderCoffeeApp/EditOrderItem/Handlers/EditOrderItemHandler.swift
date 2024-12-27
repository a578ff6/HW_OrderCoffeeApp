//
//  EditOrderItemHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/25.
//


// MARK: - EditOrderItemHandler 筆記
/**
 
 ## EditOrderItemHandler 筆記
 
 - 基本上整體架構都與DrinkDetailHandler差不多，因爲是拆出職責為新增、編輯。
 
 `* What:`
 
 - `EditOrderItemHandler` 是一個負責處理 `編輯飲品項目` 頁面中 `UICollectionView` 的資料來源 (`dataSource`) 和使用者互動 (`delegate`) 的類別。

 - 主要功能包括：
 
 `1. 管理 Section 與 Cell：`
    - 動態生成不同 Section 的資料內容（例如圖片、資訊、尺寸選擇、價格資訊及數量調整）。
    - 為每個 Section 動態配置對應的 Cell 並進行視圖渲染。

 `2. 監聽使用者互動：`
    - 尺寸選擇的點擊事件。
    - 數量調整的輸入或步進事件。
    - 將這些互動回報至控制器進行業務邏輯的處理。

 `3. 與控制器通訊：`
    - 使用 `EditOrderItemHandlerDelegate`，將互動行為（例如尺寸改變、數量調整）通知給控制器。

 ---------------

 `* Why:`
 
 `1. 降低耦合度：`
 
    - 資料的邏輯與操作集中於控制器，而非直接在 Cell 或 Handler 處理。
    - 確保 `UICollectionView` 的邏輯處於一個專注且單一職責的狀態。

 `2. 增強靈活性：`
 
    - 可以動態調整 Section 數量及其內容（例如：是否顯示價格資訊由尺寸選擇決定）。
    - Handler 本身不關心資料的來源，只需透過 `Delegate` 獲取所需的資料。

` 3. 易於維護：`
 
    - 不同的功能（如尺寸選擇、數量調整）都可以通過對應的 Section 進行獨立配置，方便測試與修改。

 ---------------

 `* How`
 
 `1. 初始化與委派設置：`
 
    - 初始化時將 `EditOrderItemHandlerDelegate` 指定為控制器，確保資料的訪問與事件的通知都能正確回傳。

` 2. 資料渲染：`
 
    - 實作 `UICollectionViewDataSource` 方法，分別處理 Section 數量與每個 Section 的內容：
      - `numberOfSections(in:)`: 根據 `EditOrderItemSection` 返回固定的區段數量。
      - `numberOfItemsInSection`: 根據資料模型動態計算每個區段的內容數量，例如：尺寸選擇區根據可用的尺寸數量動態生成。
      - `cellForItemAt`: 根據 Section 返回對應的 Cell，並通過模型渲染視圖。

` 3. 處理使用者互動：`
 
    - 在特定 Cell（如 `sizeSelection` 或 `editOrderOptions`）中，透過閉包將使用者的互動行為回傳給控制器。例如：
      - 在尺寸選擇區，監聽選中的尺寸並通知控制器更新模型。
      - 在數量調整區，傳遞調整後的數量給控制器進行更新。

` 4. 補充視圖：`
 
    - 實作 `viewForSupplementaryElementOfKind` 方法，用於添加區段之間的分隔視圖（例如 Header 或 Footer）。

 ---------------

 `* 範例場景:`
 
 假設使用者點擊了一個尺寸按鈕：
 1. `sizeSelection` 的 Cell 會觸發其閉包，回傳選中的尺寸名稱。
 2. `EditOrderItemHandlerDelegate.didChangeSize(_:)` 方法被呼叫，將尺寸的更新通知控制器。
 3. 控制器接收尺寸更新，更新 `EditOrderItemModel` 並刷新 UI。
 */


// MARK: - (v)

import UIKit

/// `EditOrderItemHandler`
///
/// 此類負責管理「編輯飲品項目」頁面中 `UICollectionView` 的資料來源 (`dataSource`) 和使用者互動 (`delegate`)。
///
/// ### 設計目標：
/// 1. 資料與邏輯分層：
///    - 使用 `EditOrderItemHandlerDelegate` 動態訪問資料，將資料邏輯集中於控制器，減少視圖層的耦合。
/// 2. 專注處理視圖邏輯：
///    - 單一職責，僅負責呈現資料及回應使用者的交互行為，避免與業務邏輯混雜。
///
/// ### 功能說明：
/// 1.資料展示：
///   - 動態生成飲品資訊，包括圖片、描述、尺寸選擇及價格資訊。
/// 2.使用者互動處理：
///   - 接收使用者點擊與操作事件，更新選擇的尺寸或數量，並回報至控制器。
/// 3.與控制器通信：
///   - 透過委派模式 (`EditOrderItemHandlerDelegate`) 與控制器交換資料或傳遞更新事件。
class EditOrderItemHandler: NSObject {
    
    // MARK: - Properties
    
    /// 用於通知控制器處理互動事件的委派
    /// - 透過 `EditOrderItemHandlerDelegate` 訪問資料與傳遞互動事件。
    private weak var editOrderItemHandlerDelegate: EditOrderItemHandlerDelegate?
    
    // MARK: - Initializer

    /// 初始化 `EditOrderItemHandler`，並設置委派
    /// - Parameter editOrderItemHandlerDelegate: 控制器，需實作 `EditOrderItemHandlerDelegate`
    init(editOrderItemHandlerDelegate: EditOrderItemHandlerDelegate) {
        self.editOrderItemHandlerDelegate = editOrderItemHandlerDelegate
    }
    
}

// MARK: - UICollectionViewDataSource
extension EditOrderItemHandler: UICollectionViewDataSource {
    
    /// 返回 `UICollectionView` 的 section 數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return EditOrderItemSection.allCases.count
    }
    
    /// 返回指定 section 的 item 數量
    ///
    /// ### 功能：
    /// - 根據資料模型與選中的尺寸，動態返回不同 section 的數量。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let delegate = editOrderItemHandlerDelegate else { fatalError("Delegate is not set")}
        let editOrderItemModel = delegate.getEditOrderItemModel()
        let selectedSize = editOrderItemModel.selectedSize  // 測試

        
        let section = EditOrderItemSection.allCases[section]
        switch section {
        case .image, .info, .editOrderOptions:
            return 1
        case .sizeSelection:
            return editOrderItemModel.sortedSizes.count
        case .priceInfo:
            return selectedSize.isEmpty ? 0 : 1
        }
    }
    
    /// 返回指定位置的 Cell
    ///
    /// - 根據 section 動態返回對應的 Cell，並配置相關資料。
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = editOrderItemHandlerDelegate else { fatalError("Delegate is not set") }
        let editOrderItemModel = delegate.getEditOrderItemModel()
        let selectedSize = editOrderItemModel.selectedSize
        
        let section = EditOrderItemSection.allCases[indexPath.section]
        switch section {
        case .image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditOrderItemImageCollectionViewCell.reuseIdentifier, for: indexPath) as? EditOrderItemImageCollectionViewCell else {
                fatalError("Cannot dequeue EditOrderItemImageCollectionViewCell")
            }
            cell.configure(with: editOrderItemModel.imageUrl)
            return cell
            
        case .info:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditOrderItemInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? EditOrderItemInfoCollectionViewCell else {
                fatalError("Cannot dequeue EditOrderItemInfoCollectionViewCell")
            }
            cell.configure(with: editOrderItemModel)
            return cell
            
        case .sizeSelection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditOrderItemSizeSelectionCollectionViewCell.reuseIdentifier, for: indexPath) as? EditOrderItemSizeSelectionCollectionViewCell else {
                fatalError("Cannot dequeue EditOrderItemSizeSelectionCollectionViewCell")
            }
            let size = editOrderItemModel.sortedSizes[indexPath.item]
            cell.configure(with: size, isSelected: size == selectedSize)
            cell.sizeSelected = { selectedSize in
                delegate.didChangeSize(selectedSize)
            }
            return cell
            
        case .priceInfo:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditOrderItemPriceInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? EditOrderItemPriceInfoCollectionViewCell else {
                fatalError("Cannot dequeue EditOrderItemPriceInfoCollectionViewCell")
            }
            let sizeInfo = editOrderItemModel.sizeInfo(for: selectedSize)
            cell.configure(with: sizeInfo)
            return cell
            
        case .editOrderOptions:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditOrderItemOptionsCollectionViewCell.reuseIdentifier, for: indexPath) as? EditOrderItemOptionsCollectionViewCell else {
                fatalError("Cannot dequeue EditOrderItemOptionsCollectionViewCell")
            }
            // 確保傳遞數量
            cell.configure(with: editOrderItemModel.quantity)
            cell.editOrderItem = { quantity in
                delegate.didChangeQuantity(to: quantity)
            }
            return cell
        }
    }
    
    /// 處理 section 的補充視圖 (`header 和 footer`)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter || kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        guard let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EditOrderItemSeparatorView.reuseIdentifier, for: indexPath) as? EditOrderItemSeparatorView else {
            fatalError("Cannot create separator view")
        }
        return separatorView
    }
    
}

// MARK: - UICollectionViewDelegate
extension EditOrderItemHandler: UICollectionViewDelegate {
    
}
